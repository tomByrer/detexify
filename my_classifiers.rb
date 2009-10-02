require 'classifiers'
require 'extractors'
require 'elastic_matcher'

include Classifiers

classifier :default do |cache|
  KnnClassifier.new(Detexify::Extractors::Strokes::Features.new, lambda { |v,w| (v-w).r }, :cache => cache)
end

classifier :largek do |cache|
  KnnClassifier.new(Detexify::Extractors::Strokes::Features.new, lambda { |v,w| (v-w).r }, :k => 25, :cache => cache)
end

classifier :ten do |cache|
  KnnClassifier.new(Detexify::Extractors::Strokes::Features.new, lambda { |v,w| (v-w).r }, :k => 10, :limit => 10, :cache => cache)
end

classifier :tenelastic do
  Classifiers::KnnClassifier.new(
    Detexify::Preprocessors::Pipe.new(
      Detexify::Preprocessors::Strokes::SizeNormalizer.new,
      Detexify::Preprocessors::Strokes::EquidistantPoints.new(:distance => 0.3)
    ),
    MultiElasticMatcher, # measure
    :k => 6, # to bubble down impostors
    :limit => 10
  )
end

classifier :dcelastic do
  Classifiers::DCPruningKnnClassifier.new(
    Detexify::Preprocessors::Pipe.new(
      Detexify::Preprocessors::Strokes::SizeNormalizer.new,
      Detexify::Preprocessors::Strokes::EquidistantPoints.new(:distance => 0.3)
    ),
    MultiElasticMatcher,
    [lambda { |i| i.size }, Detexify::Extractors::Strokes::AspectRatio.new(4)],
    :k => 6, # to bubble down impostors
    :limit => 10
  )
end

From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Thu, 22 Feb 2007 03:00:32 -0800
Message-ID: <f2b55d220702220300t4734dd9bxb97f8f63724817f9@mail.gmail.com>
References: <200702211038.24349.dada1@cosmosbay.com>
	 <20070221095755.GB308@2ka.mipt.ru>
	 <f2b55d220702211315h1266d25el4a0f46c4fb65e12a@mail.gmail.com>
	 <20070222.010638.27784211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, dada1@cosmosbay.com, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:7269 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932847AbXBVLAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 06:00:37 -0500
Received: by ug-out-1314.google.com with SMTP id 44so79459uga
        for <netdev@vger.kernel.org>; Thu, 22 Feb 2007 03:00:33 -0800 (PST)
In-Reply-To: <20070222.010638.27784211.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/22/07, David Miller <davem@davemloft.net> wrote:
> From: "Michael K. Edwards" <medwards.linux@gmail.com>
> Date: Wed, 21 Feb 2007 13:15:51 -0800
>
> > it had better be a 2-left hash with a compact
> > overflow pool for the rare case of second collision.
>
> Just like Evgeniy, you should do your research too :-))))

Fair enough.  :-)

> The gain for multiple-hash schemes, such as 2-left, exists only if you
> can parallelize the N lookups in hardware.  This is an assumption
> built into all the papers you will read on this subject, including the
> one you reference by Mitzenmacher.

Er, no.  The principal gain for the 2-left hash is that the only time
you ever look at the right hash is when you have a collision in the
left.  The right hash is therefore substantially less occupied and the
odds of second collision are lower.  If you happen to be able to
prefetch the left and right buckets in parallel, that's gravy.

Roughly speaking, for a single hash, P(0) = (1 - 1/k)^n \approx
e^{-n/k}, where P(0) is the probability that a given bucket has 0
entries, k is the number of buckets, and n is the number of elements.
One entry in the bucket replaces a factor (1-1/k) with a factor n/k,
the second entry replaces another (1-1/k) with (n-1)/2k, and so forth.
 It's the good old birthday problem.

Take the simple example of an equal number of items and of one-entry
buckets, and compare the simple and 2-left hashes.  When n/k \approx
1, you have about 37% empty buckets, but when n/k \approx 2 you only
have about 13% empty buckets.  On the other hand, when n/k \approx 1
and the buckets only hold one entry, about 37% of the items overflow;
when n/k \approx 2, about 57% do.  Result: a 2-left hash with exactly
as many 1-item buckets as there are items will only see about 20% of
the items overflow (collide in the left hash and then collide again in
the right hash), versus the 37% that would have overflowed in a single
hash of the same size.

In practical applications you try to make your hash buckets cache-line
sized and fit 2 or 4 items into them so that overflows are farther out
on the tail of the distribution.  The result can be a hash that is
only oversized by a factor of two or so relative to the space occupied
by the filled slots, yet has an amortized cost of less than 1.5 cache
misses and has a fraction of a percent of items that overflow the
right hash.  That fraction of a percent can go into a single overflow
pool (a way oversized hash or an rbtree or something else you've
already coded; it's a rare case) rather than having to chain from each
hash bucket.

> If you read any paper on IP route lookup algorithms, prefix
> your reading of that paper with something that reads like:
>
>         And by the way we are targeting implementations in
>         hardware that can parallelize and pipeline memory
>         accesses to fast SRAM.  Do not consider this algorithm
>         seriously for running on general purpose processors
>         in software.

I generally agree with this statement.  However, the 2-left hash is a
very useful data structure for lots of things other than IP route
lookups, especially in memory-constrained systems where you don't want
to oversize the hash table by _too_ much but you still want actual
overflow chaining to be quite rare.  It's much simpler than
next-empty-bucket types of schemes, simple enough that I've coded it
for little DSP cores, and almost as good at minimizing overflows.

> Probably a few read's of Network Algorithmics would help your
> understanding in this area as well.

Hey, I don't think a hash is the right solution in the first place.
If you're on the open Internet you have to assume a DDoS half-open
connection load a thousandfold higher than the number of real traffic
flows.  If you don't have the memory bandwidth and cache architecture
to bend over and take it (and on a commodity processor, you don't, not
unless you're a hell of a lot cleverer about hinting to the cache
controller than I am), you want a data structure that rotates the real
connections up into a frequently traversed set.

Besides, RCUing a hash of any sort sounds like a nightmare, whereas
something like a splay tree is reputed to be very straightforward to
make "persistent" in the functional-programming sense.  I haven't
coded that one myself but surely it's in the current edition of Knuth.
 Network Algorithmics is fine as far as it goes, but if you want to
distribute the networking stack across a NUMA box and still not have
it go pear-shaped under sophisticated DDoS, I think you probably have
to think it out for yourself.

In any case, I am not setting myself up as some kind of networking or
data structure guru, just trying to articulate what's wrong with
Evgeniy's analysis and why RCUing a naive hash is a complete waste of
time.

> Tries and similar structures do help in the case of our routing
> because we're going from a potential 32-hashtable probe down
> to a relatively small number of probes into a trie.  That's what
> Robert's LC-Trie and upcoming TRASH work do.
>
> But it won't help the same when going from hashes to a trie,
> as would be the case for TCP.

Well, I arrived in this discussion in the middle, and haven't really
looked at what people are proposing to replace.  Robert's analysis
looks sane, and I certainly haven't invested the research to pick
holes in it.  :-)  Would be nice to know how it fares under massive
half-open connection attacks, though.

> If we can get the sockets into the TRASH entries, as Eric will
> experiment with, we'll be able to eliminate the TCP hash lookup
> in the fast path entirely.  It is the only reasonable suggestion
> I've seen made in this area to date.

Agreed.  You are much better off obtaining all per-flow state with a
single data structure lookup.  It would be kind of nice if state for
other layers like IPSec and NAT could live there too.  By the way, are
these flows unidirectional or bidirectional?  If memory serves, TCP is
going to want a bidirectional session construct, right?  So do you
canonicalize the tuple in some way (lower IP address first?) before
hashing it for lookup?

Cheers,
- Michael

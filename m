From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 13:22:06 +0300
Message-ID: <20070220102206.GA7237@2ka.mipt.ru>
References: <200702191614.49666.dada1@cosmosbay.com> <200702191913.08125.dada1@cosmosbay.com> <20070220092523.GA6238@2ka.mipt.ru> <20070220.015745.48806097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: dada1@cosmosbay.com, akepner@sgi.com, linux@horizon.com,
	netdev@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33102 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932845AbXBTKXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 05:23:01 -0500
Content-Disposition: inline
In-Reply-To: <20070220.015745.48806097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 01:57:45AM -0800, David Miller (davem@davemloft.net) wrote:
> > What you miss is the fact, that upper layers of the tree are always in the
> > cache. So its access cost nothing compared to every time new entry in
> > the hash table.
> 
> It will not be on a real computer spending reasonable if not
> predominant time in userspace.
> 
> I agree with others here in this thread, in that your test program is
> not accurate at all in several aspects as it makes many incorrect
> assumptions about the environment in which these lookups run:
> 
> 1) cache must be assumed cold, ALWAYS
> 2) large PTE mappings must be used to simulate kernel costs
>    and timings accurately
> 
> Even on computer not spending much time in userspace, cache will
> be cold too in most of these paths.  Do you remember the cpu cycle
> counter experiment I ran in the tg3 driver a few years back?
> 
> That test showed that in NAPI loop, second packet was always processed
> some 40 times faster than first one, and it's all because of cache
> warming done by first packet.
> 
> It is a very essential and sometimes non-intuitive aspect of packet
> input processing.  You must code for the cold cache case.  Therefore
> you cannot run silly loops in userspace to measure the performance of
> a flow demux algorithm, it is a completely pointless exercise in fact
> :-)

It is not correct.
Getting size of the table for 2^20 entries is about 4Mb, we get
half/third of it in the cache in my userspace test - and it still performs 
bad (well, it is noticebly better than all other approaches (yet), but it 
is not that good as expected it to be).

With my trie test, _smaller_ part of the trie is in the cache due to
size of the node, which includes _a lot_ of additional information used
for wildcard processing (needed for netfilter and/or route
implementation in netchannels).

Above words are _only_ correct for hash tables - yes, in that case cache
is always cold, since each new flow goes into completely different
entry. With tree/trie (and _especially_ on SMP_) access to low-level
entry _requires_ all above entries to be in the cache, so until load
fully flushes it away, there will be a win for tree implementation.
If load is that, that it flushes the whole cache each time, then we are
going to die just because populating of the struct sock and/or tcp
socket is much worse than several tree/trie entris in the lookup.

> > And there is _no_ O(1) - O(1) is just a hash entry selection, then you
> > need to add the whole chain path, which can be long enough.
> > For example for the length 9 you have 1000 entries - it is exactly size
> > of the tree - sum of all entries upto and including 2^9.
> 
> Hash table should grow to exactly number of hash chains as number
> of sockets that are active.  That is how we program every dynamically
> grown hash table algorithm in the kernel, and we would do the same
> for TCP once dynamic growth is possible.

Eric's test shows that only one third of the sockets is in the chains
with 1 length, so it does not work that way, which is not a bad or good
- table scaling is not trivial operation indeed.

> It is assumption of every hash algorithm.  We choose poor sizes at
> boot time on Eric's computer, or there is some limit preventing from
> using a proper size.  It does not make a flaw in the hash approach.
> 
> People don't use trees or tries for socket demux in any modern
> operating system, there is a reason and it is not because this
> approach has not been tried. :-)

Trees are used _always_ in huge route tables - not just because it is
too ugly to implement wildcards in hash tables :).

I would agree that routers do not perform any real work besides packet
forwarding, so they do have theirs caches filled with all needed
information (especially if all above is implemented in hardware and thus
is completely different), but it does not mean that existing systems do
not allow to scale with trees with existing cache issues.

-- 
	Evgeniy Polyakov

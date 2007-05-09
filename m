From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1 take 2] Unified socket storage. (with small bench).
Date: Wed, 9 May 2007 14:22:53 +0400
Message-ID: <20070509102253.GC10028@2ka.mipt.ru>
References: <20070509093443.GA10028@2ka.mipt.ru> <20070509.024445.71552569.davem@davemloft.net> <20070509095740.GB10028@2ka.mipt.ru> <20070509.030200.123972145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40337 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755111AbXEIKXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 06:23:18 -0400
Content-Disposition: inline
In-Reply-To: <20070509.030200.123972145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 09, 2007 at 03:02:00AM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Wed, 9 May 2007 13:57:40 +0400
> 
> > That is only because we have very different way of working with udp.
> > In udp hash table we can have multiple sockets bound to different ip
> > addresses, but with the same port, so it will be placed into the same
> > hash chain. With trie each socket will have differnet key, since
> > addresses are different (or bound device number), so it automatically
> > fixes problem with broken hash for udp (which is a bit fixed with
> > extended hashing).
> 
> Yes it is power of trie.
> 
> So connection rates are interesting, but what about raw lookup
> performance?  Last time this topic came up you went into some
> cave when you looked at the trie lookup assembly and compared
> it to hash. :)

Sky was bluer and grass was greener that days...
We discussed raw trie with completely different lookup algo (32 bits
keys only, 32 checks per lookup), current implementation (and that one
in previous patchset) is a serious step further.

> It does make more memory references than hash by definition, and we
> need to figure out whether that matters enough or not.

Due to algorithm changes, on each new level we get upto 256 nodes which 
can store a pointer to data, so usual number of lookups should be 3 
(max 4) for the current key organization.
One of the worst cases is when the same source and destination address 
are used, but with different ports (like in shown example), in that case
upto 8 lookups can be performed.
We can even tune key organization to put fields known to be different
first (admin can setup some kind of a policy on bootup/runtime) or
perform non-destructive hashing (exchange bits in the key according to
some law, like change first bit and the last one), which will speedup 
lookup, but that looks more like a ugly mental exercises and should not
be considered in tests for now.

-- 
	Evgeniy Polyakov

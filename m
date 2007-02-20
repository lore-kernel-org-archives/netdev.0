From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 12:25:23 +0300
Message-ID: <20070220092523.GA6238@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <20070219142504.GA5626@2ka.mipt.ru> <200702191614.49666.dada1@cosmosbay.com> <200702191913.08125.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53844 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932752AbXBTJ06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 04:26:58 -0500
Content-Disposition: inline
In-Reply-To: <200702191913.08125.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 07:13:07PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> On Monday 19 February 2007 16:14, Eric Dumazet wrote:
> >
> > Because O(1) is different of O(log(N)) ?
> > if N = 2^20, it certainly makes a difference.
> > Yes, 1% of chains might have a length > 10, but yet 99% of the lookups are
> > touching less than 4 cache lines.
> > With a binary tree, log(2^20) is 20. or maybe not ? If you tell me it's 4,
> > I will be very pleased.
> >
> 
> Here is the tcp ehash chain length distribution on a real server :
> ehash_addr=0xffff810476000000
> ehash_size=1048576
> 333835 used chains, 3365 used twchains
> Distribution of sockets/chain length
> [chain length]:number of sockets
> [1]:221019 37.4645%
> [2]:56590 56.6495%
> [3]:21250 67.4556%
> [4]:12534 75.9541%
> [5]:8677 83.3082%
> [6]:5862 89.2701%
> [7]:3640 93.5892%
> [8]:2219 96.5983%
> [9]:1083 98.2505%
> [10]:539 99.1642%
> [11]:244 99.6191%
> [12]:112 99.8469%
> [13]:39 99.9329%
> [14]:16 99.9708%
> [15]:6 99.9861%
> [16]:3 99.9942%
> [17]:2 100%
> total : 589942 sockets
>
> So even with a lazy hash function, 89 % of lookups are satisfied with less 
> than 6 compares.

This is only 2^19 sockets.

What you miss is the fact, that upper layers of the tree are always in the
cache. So its access cost nothing compared to every time new entry in
the hash table.

And there is _no_ O(1) - O(1) is just a hash entry selection, then you
need to add the whole chain path, which can be long enough.
For example for the length 9 you have 1000 entries - it is exactly size
of the tree - sum of all entries upto and including 2^9.
One third of the table is accessible within 17 lookups (hash chain
length is 1), but given into account size of the entry - let's say it 
is equal to
32+32+32 - size of the key
32+32+32 - size of the left/right/parent pointer
so 192 bytes per entry - given into acount that 1/4 of the 1-2 MB cache is
filled with it, we get about 1300 top-level entries in the hash, so
about _10_ first lookups are in the cache _always_ due to nature of the
tree lookup.

-- 
	Evgeniy Polyakov

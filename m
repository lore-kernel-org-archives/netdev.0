From: David Miller <davem@davemloft.net>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 01:57:45 -0800 (PST)
Message-ID: <20070220.015745.48806097.davem@davemloft.net>
References: <200702191614.49666.dada1@cosmosbay.com>
	<200702191913.08125.dada1@cosmosbay.com>
	<20070220092523.GA6238@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, akepner@sgi.com, linux@horizon.com,
	netdev@vger.kernel.org, bcrl@kvack.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49985
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932566AbXBTJ5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 04:57:47 -0500
In-Reply-To: <20070220092523.GA6238@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 20 Feb 2007 12:25:23 +0300

> What you miss is the fact, that upper layers of the tree are always in the
> cache. So its access cost nothing compared to every time new entry in
> the hash table.

It will not be on a real computer spending reasonable if not
predominant time in userspace.

I agree with others here in this thread, in that your test program is
not accurate at all in several aspects as it makes many incorrect
assumptions about the environment in which these lookups run:

1) cache must be assumed cold, ALWAYS
2) large PTE mappings must be used to simulate kernel costs
   and timings accurately

Even on computer not spending much time in userspace, cache will
be cold too in most of these paths.  Do you remember the cpu cycle
counter experiment I ran in the tg3 driver a few years back?

That test showed that in NAPI loop, second packet was always processed
some 40 times faster than first one, and it's all because of cache
warming done by first packet.

It is a very essential and sometimes non-intuitive aspect of packet
input processing.  You must code for the cold cache case.  Therefore
you cannot run silly loops in userspace to measure the performance of
a flow demux algorithm, it is a completely pointless exercise in fact
:-)

> And there is _no_ O(1) - O(1) is just a hash entry selection, then you
> need to add the whole chain path, which can be long enough.
> For example for the length 9 you have 1000 entries - it is exactly size
> of the tree - sum of all entries upto and including 2^9.

Hash table should grow to exactly number of hash chains as number
of sockets that are active.  That is how we program every dynamically
grown hash table algorithm in the kernel, and we would do the same
for TCP once dynamic growth is possible.

It is assumption of every hash algorithm.  We choose poor sizes at
boot time on Eric's computer, or there is some limit preventing from
using a proper size.  It does not make a flaw in the hash approach.

People don't use trees or tries for socket demux in any modern
operating system, there is a reason and it is not because this
approach has not been tried. :-)

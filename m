From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 11:18:56 -0800
Message-ID: <f2b55d220702191118n1dc95ce2n9f2b82496fbfaef8@mail.gmail.com>
References: <20070204074143.26312.qmail@science.horizon.com>
	 <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain>
	 <20070217131302.GA22732@2ka.mipt.ru> <45D89EFE.4080103@cosmosbay.com>
	 <20070218191009.GA28216@2ka.mipt.ru> <45D8B54A.70903@cosmosbay.com>
	 <f2b55d220702181323l5d2640a4g18df6d1ee051e987@mail.gmail.com>
	 <p73zm7ae4lf.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org,
	bcrl@linux.intel.com
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:56417 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932487AbXBSTS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 14:18:59 -0500
Received: by ug-out-1314.google.com with SMTP id 44so643518uga
        for <netdev@vger.kernel.org>; Mon, 19 Feb 2007 11:18:57 -0800 (PST)
In-Reply-To: <p73zm7ae4lf.fsf@bingen.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19 Feb 2007 13:04:12 +0100, Andi Kleen <andi@firstfloor.org> wrote:
> LRU tends to be hell for caches in MP systems, because it writes to
> the cache lines too and makes them exclusive and more expensive.

That's why you let the hardware worry about LRU.  You don't write to
the upper layers of the splay tree when you don't have to.  It's the
mere traversal of the upper layers that keeps them in cache, causing
the cache hierarchy to mimic the data structure hierarchy.

RCU changes the whole game, of course, because you don't write to the
old copy at all; you have to clone the altered node and all its
ancestors and swap out the root node itself under a spinlock.  Except
you don't use a spinlock; you have a ring buffer of root nodes and
atomically increment the writer index.  That atomically incremented
index is the only thing on which there's any write contention.
(Obviously you need a completion flag on the new root node for the
next writer to poll on, so the sequence is atomic-increment ... copy
and alter from leaf to root ... wmb() ... mark new root complete.)

When you share TCP sessions among CPUs, and packets associated with
the same session may hit softirq in any CPU, you are going to eat a
lot of interconnect bandwidth keeping the sessions coherent.  (The
only way out of this is to partition the tuple space by CPU at the NIC
layer with separate per-core, or perhaps per-cache, receive queues; at
which point the NIC is so smart that you might as well put the DDoS
handling there.)  But at least it's cache coherency protocol bandwidth
and not bandwidth to and from DRAM, which has much nastier latencies.
The only reason the data structure matters _at_all_ is that DDoS
attacks threaten to evict the working set of real sessions out of
cache.  That's why you add new sessions at the leaves and don't rotate
them up until they're hit a second time.

Of course the leaf layer can't be RCU, but it doesn't have to be; it's
just a bucket of tuples.  You need an auxiliary structure to hold the
session handshake trackers for the leaf layer, but you assume that
you're always hitting cold cache when diving into this structure and
ration accesses accordingly.  Maybe you even explicitly evict entries
from cache after sending the SYNACK, so they don't crowd other stuff
out; they go to DRAM and get pulled into the new CPU (and rotated up)
if and when the next packet in the session arrives.  (I'm assuming
T/TCP here, so you can't skimp much on session tracker size during the
handshake.)

Every software firewall I've seen yet falls over under DDoS.  If you
want to change that, you're going to need more than the
back-of-the-napkin calculations that show that session lookup
bandwidth exceeds frame throughput for min-size packets.  You're going
to need to strategize around exploiting the cache hierarchy already
present in your commodity processor to implicitly partition real
traffic from the DDoS storm.  It's not a trivial problem, even in the
mathematician's sense (in which all problems are either trivial or
unsolved).

Cheers,
- Michael

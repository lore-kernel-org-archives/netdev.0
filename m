From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 00:59:49 -0700 (PDT)
Message-ID: <20060426.005949.125174303.davem@davemloft.net>
References: <200604261147.34221.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48288
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751164AbWDZH7s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 03:59:48 -0400
To: kelly@au1.ibm.com
In-Reply-To: <200604261147.34221.kelly@au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok I have comments already just glancing at the initial patch.

With the 32-bit descriptors in the channel, you indeed end up
with a fixed sized pool with a lot of hard-to-finesse sizing
and lookup problems to solve.

So what I wanted to do was finesse the entire issue by simply
side-stepping it initially.  Use a normal buffer with a tail
descriptor, when you enqueue you give a tail descriptor pointer.

Yes, it's weirder to handle this in hardware, but it's not
impossible and using real pointers means two things:

1) You can design a simple netif_receive_skb() channel that works
   today, encapsulation of channel buffers into an SKB is like
   15 lines of code and no funny lookups.

2) People can start porting the input path of drivers right now and
   retain full functionality and test anything they want.  This is
   important for getting the drivers stable as fast as possible.

And it also means we can tackle the buffer pool issue of the 32-bit
descriptors later, if we actually want to do things that way, I
think we probably don't.

To be honest, I don't think using a 32-bit descriptor is so critical
even from a hardware implementation perspective.  Yes, on 64-bit
you're dealing with a 64-bit quantity so the number of entries in the
channel are halfed from what a 32-bit arch uses.

Yes I say this for 2 reasons:

1) We have no idea whether it's critical to have "~512" entries
   in the channel which is about what a u32 queue entry type
   affords you on x86 with 4096 byte page size.

2) Furthermore, it is sized by page size, and most 64-bit platforms
   use an 8K base page size anyways, so the number of queue entries
   ends of being the same.  Yes, I know some 64-bit platforms use
   a 4K page size, please see #1 :-)

I really dislike the pools of buffers, partly because they are fixed
size (or dynamically sized and even more expensive to implement), but
moreso because there is all of this absolutely stupid state management
you eat just to get at the real data.  That's pointless, we're trying
to make this as light as possible.  Just use real pointers and
describe the packet with a tail descriptor.

We can use a u64 or whatever in a hardware implementation.

Next, you can't even begin to work on the protocol channels before you
do one very important piece of work.  Integration of all of the ipv4
and ipv6 protocol hash tables into a central code, it's a total
prerequisite.  Then you modify things to use a generic
inet_{,listen_}lookup() or inet6_{,listen_}lookup() that takes a
protocol number as well as saddr/daddr/sport/dport and searches
from a central table.

So I think I'll continue working on my implementation, it's more
transitional and that's how we have to do this kind of work.

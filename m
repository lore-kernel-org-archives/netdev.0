From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 09:57:22 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143AE16@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:27914 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932269AbWDZQ5f convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 12:57:35 -0400
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> Ok I have comments already just glancing at the initial patch.
> 
> With the 32-bit descriptors in the channel, you indeed end up
> with a fixed sized pool with a lot of hard-to-finesse sizing
> and lookup problems to solve.
> 
> So what I wanted to do was finesse the entire issue by simply
> side-stepping it initially.  Use a normal buffer with a tail
> descriptor, when you enqueue you give a tail descriptor pointer.
> 
> Yes, it's weirder to handle this in hardware, but it's not
> impossible and using real pointers means two things:
> 
> 1) You can design a simple netif_receive_skb() channel that works
>    today, encapsulation of channel buffers into an SKB is like
>    15 lines of code and no funny lookups.
> 
> 2) People can start porting the input path of drivers right now and
>    retain full functionality and test anything they want.  This is
>    important for getting the drivers stable as fast as possible.
> 
> And it also means we can tackle the buffer pool issue of the
> 32-bit descriptors later, if we actually want to do things
> that way, I think we probably don't.
> 
> To be honest, I don't think using a 32-bit descriptor is so
> critical even from a hardware implementation perspective.
> Yes, on 64-bit you're dealing with a 64-bit quantity so the
> number of entries in the channel are halfed from what a 32-bit arch
> uses. 
> 
> Yes I say this for 2 reasons:
> 
> 1) We have no idea whether it's critical to have "~512" entries
>    in the channel which is about what a u32 queue entry type
>    affords you on x86 with 4096 byte page size.
> 
> 2) Furthermore, it is sized by page size, and most 64-bit platforms
>    use an 8K base page size anyways, so the number of queue entries
>    ends of being the same.  Yes, I know some 64-bit platforms use
>    a 4K page size, please see #1 :-)
> 
> I really dislike the pools of buffers, partly because they
> are fixed size (or dynamically sized and even more expensive
> to implement), but moreso because there is all of this
> absolutely stupid state management you eat just to get at the
> real data.  That's pointless, we're trying to make this as
> light as possible.  Just use real pointers and describe the
> packet with a tail descriptor.
> 
> We can use a u64 or whatever in a hardware implementation.
> 
> Next, you can't even begin to work on the protocol channels
> before you do one very important piece of work.  Integration
> of all of the ipv4 and ipv6 protocol hash tables into a
> central code, it's a total prerequisite.  Then you modify
> things to use a generic
> inet_{,listen_}lookup() or inet6_{,listen_}lookup() that
> takes a protocol number as well as saddr/daddr/sport/dport
> and searches from a central table.
> 
> So I think I'll continue working on my implementation, it's
> more transitional and that's how we have to do this kind of work. -

The major element I liked about Kelly's approach is that the ring
is clearly designed to allow a NIC to place packets directly into
a ring that is directly accessible by the user. Evolutionary steps
are good, but isn't direct placement into a user-accessible simple
ring buffer the ultimate justification of netchannels?

But that doesn't mean that we have to have a very artificial definition
of the ring based on presumptions that hardware only understands 512<<n
sized buffers. Hardware today is typically just as smart as the
processors
that IP networks were first designed on, if not more so.

Central integration also will need to be integrated with packet
filtering.
In particular, once a flow has been assigned to a netchannel ring, who
is
responsible for doing the packet filtering? Or is it enough to check the
packet filter when the net channel flow is created?




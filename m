From: Johann Baudy <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 05 Nov 2008 11:55:07 +0100
Message-ID: <1225882507.5273.66.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g19.free.fr ([212.27.42.36]:59577 "EHLO smtp6-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbYKEKzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 05:55:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

> Right, but check out http://www.mjmwired.net/kernel/Documentation/memory-barriers.txt - namely the implicit nature of ULOCK operations, IMPLICIT KERNEL MEMORY BARRIERS, & ATOMIC OPERATIONS.
>
> However, I'm not sure why currently in the code it's a full memory barrier after __packet_set_status - it could be downgraded to a write barrier.

So you assume an implicit read or data dep barrier before packet_current_rx_frame()?

>
> Also, there is a bug in the current code I believe:
>
> Around line 726:
>
> @@ -723,8 +723,9 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
>        else
>                sll->sll_ifindex = dev->ifindex;
>
> +       smp_wmb();
>        __packet_set_status(po, h.raw, status);
> -       smp_mb();
> +       smp_wmb();
>
>        {
>                struct page *p_start, *p_end;
>
> We only really need 1 memory barrier: for architectures where flush_dcache_page is a no-op and writes may be re-ordered, we need the smp_wmb before (if writes may not be re-ordered, ala x86, then a simple barrier() will suffice).  With architectures that actually need the data flushed, we put it after the __packet_set_status (and this can't be a simple barrier).  However, to generically do it, we do both (I couldn't find a pre-processor that gets defined to indicate if flush_dcache_page is no-op or actually does something).  If we don't do it this way it's possible (however unlikely), that the status is set before the data is filled in correctly.  This'll come up if the compiler moves the set status around or the CPU re-orders writes and flush_dcache_page is a no-op.
>
> Should I submit this as a patch, or am I missing something?
>
> "I'm afraid that once a barrier discussion comes up and we insert them, then I become dazedly paranoid and it's very hard to shake me from seeing a need for barriers everywhere, including a barrier before and after every barrier ad infinitum to make sure they're really barriers."
> -- Hugh Dickins
>
> Vitali
>
If my understanding is correct, smp_wmb should ensure that "all the
STORE operations specified before the barrier will appear to happen
before all the STORE operations specified after the barrier with respect
to the other components of the system.". 
I think that those barriers address reordering effects at the hardware
level and depend on architecture. But again, I'm not an expert of this.

Moreover if we look into Kernel code, most of the time, smp_wmb() is
used immediately after shared data update . (not before)
(ex:kernel/marker.c, kernel/trace/ftrace.c, ...).

I would like to integrate this barrier mechanism in __packet_[set|
get]_status() function. Thoughts?

Best regards,
Johann











-- 
Johann Baudy
johaahn@gmail.com




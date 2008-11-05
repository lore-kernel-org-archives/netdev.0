From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 5 Nov 2008 09:32:23 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60EC2@NASANEXMB10.na.qualcomm.com>
References: <1225882507.5273.66.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:49267 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbYKERc1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 12:32:27 -0500
In-Reply-To: <1225882507.5273.66.camel@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Johann Baudy [mailto:johaahn@gmail.com]
> Sent: November-05-08 2:55 AM
> To: Lovich, Vitali
> Cc: netdev@vger.kernel.org; Evgeniy Polyakov
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> Hi Vitali,
> 
> > Right, but check out
> http://www.mjmwired.net/kernel/Documentation/memory-barriers.txt -
> namely the implicit nature of ULOCK operations, IMPLICIT KERNEL MEMORY
> BARRIERS, & ATOMIC OPERATIONS.
> >
> > However, I'm not sure why currently in the code it's a full memory
> barrier after __packet_set_status - it could be downgraded to a write
> barrier.
> 
> So you assume an implicit read or data dep barrier before
> packet_current_rx_frame()?
> 
I think you're misunderstanding the data dependency - there's a dependency between the data in the rest of the buffer and the status flag - thus we need a read barrier between when we read the flag and when we read the data - everywhere I looked in the code, there's an atomic operation that has a barrier.  Again, barriers are only to enforce some kind of indirect data dependency, not to make sure that we're reading the data consistently (i.e.  we see the change as soon as it happens in user-space).
> >
> > Also, there is a bug in the current code I believe:
> >
> > Around line 726:
> >
> > @@ -723,8 +723,9 @@ static int tpacket_rcv(struct sk_buff *skb,
> struct net_device *dev, struct packe
> >        else
> >                sll->sll_ifindex = dev->ifindex;
> >
> > +       smp_wmb();
> >        __packet_set_status(po, h.raw, status);
> > -       smp_mb();
> > +       smp_wmb();
> >
> >        {
> >                struct page *p_start, *p_end;
> >
> > We only really need 1 memory barrier: for architectures where
> flush_dcache_page is a no-op and writes may be re-ordered, we need the
> smp_wmb before (if writes may not be re-ordered, ala x86, then a simple
> barrier() will suffice).  With architectures that actually need the
> data flushed, we put it after the __packet_set_status (and this can't
> be a simple barrier).  However, to generically do it, we do both (I
> couldn't find a pre-processor that gets defined to indicate if
> flush_dcache_page is no-op or actually does something).  If we don't do
> it this way it's possible (however unlikely), that the status is set
> before the data is filled in correctly.  This'll come up if the
> compiler moves the set status around or the CPU re-orders writes and
> flush_dcache_page is a no-op.
> >
> > Should I submit this as a patch, or am I missing something?
> >
> > "I'm afraid that once a barrier discussion comes up and we insert
> them, then I become dazedly paranoid and it's very hard to shake me
> from seeing a need for barriers everywhere, including a barrier before
> and after every barrier ad infinitum to make sure they're really
> barriers."
> > -- Hugh Dickins
> >
> > Vitali
> >
> If my understanding is correct, smp_wmb should ensure that "all the
> STORE operations specified before the barrier will appear to happen
> before all the STORE operations specified after the barrier with
> respect
> to the other components of the system.".
> I think that those barriers address reordering effects at the hardware
> level and depend on architecture. But again, I'm not an expert of this.
That's exactly write with a caveat: there's different kind of barriers, write.  barrier() is a compiler load & store barrier (i.e. the compiler won't reorder it).  The wmb() & rmb() variants also enforce it at the CPU level if the CPU can re-order these kinds of things. The hardware barriers also imply a compiler barrier obviously.

> Moreover if we look into Kernel code, most of the time, smp_wmb() is
> used immediately after shared data update . (not before)
> (ex:kernel/marker.c, kernel/trace/ftrace.c, ...).
> 
> I would like to integrate this barrier mechanism in __packet_[set|
> get]_status() function. Thoughts?
I haven't looked at the code you mentioned (I'll do that later), but I'm sure it's not either before or after.  It's always between (otherwise the barriers are useless).  Again, the barriers are there to enforce in what order data is actually written to or read from memory - thus it must happen between memory accesses that have an indirect dependence.  So again, above we only need 1 write barrier.  On architectures where flush_dcache_page is not a noop, presumably the user-space won't see our writes until after we flush.  But we need to ensure that we flush after the data has been written (or else it might flush the status update without flushing the data change).  Similarly where it's a noop, we need the barrier before the status update - otherwise the user-space can see the status change
  but the data is actually put into memory later.

Cheers,
Vitali

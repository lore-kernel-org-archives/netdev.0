From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 4 Nov 2008 17:50:01 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60E9F@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
 <1225838038.6116.10.camel@fry>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:1447 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445AbYKEBuG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 20:50:06 -0500
In-Reply-To: <1225838038.6116.10.camel@fry>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Johann Baudy [mailto:johaahn@gmail.com]
> Sent: November-04-08 2:34 PM
> To: Lovich, Vitali
> Cc: netdev@vger.kernel.org; Evgeniy Polyakov
> Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> 
> > > So, If my understanding of those memory barriers is correct, we
> should
> > > have a smp_rmb() before status reading and smp_wmb() after status
> > > writing in skb destructor and send procedure.
> > I'm not 100% sure about this - for this I was just referring to how
> the RX ring buffer does it.  However, I don't think so.  My
> understanding of the smp_wmb is that it's there so that the data cache
> is flushed properly.  In other words, when you change the tp_status
> field, you need to make sure that it's actually been written before you
> flush.  However, for reading, this is not a problem I think.  I also
> think that since TP_STATUS_COPY is only used only within the kernel,
> when you set TP_STATUS_COPY, you don't need to do the smp_wmb or the
> data cache flush.
> >
> > Perhaps someone who's more comfortable with memory barriers could
> respond on this issue?
> 
> According to memory-barrier documentation, "A write barrier should
> always be paired with a data dependency barrier or read
> barrier" (cf. below).
> 
> SMP BARRIER PAIRING
> -------------------
> 
> When dealing with CPU-CPU interactions, certain types of memory barrier
> should
> always be paired.  A lack of appropriate pairing is almost certainly an
> error.
> 
> A write barrier should always be paired with a data dependency barrier
> or read
> barrier, though a general barrier would also be viable.  Similarly a
> read
> barrier or a data dependency barrier should always be paired with at
> least an
> write barrier, though, again, a general barrier is viable:
> 
> 	CPU 1		CPU 2
> 	===============	===============
> 	a = 1;
> 	<write barrier>
> 	b = 2;		x = b;
> 			<read barrier>
> 			y = a;
> 
> Best regards,
> Johann
> 

Right, but check out http://www.mjmwired.net/kernel/Documentation/memory-barriers.txt - namely the implicit nature of ULOCK operations, IMPLICIT KERNEL MEMORY BARRIERS, & ATOMIC OPERATIONS.

However, I'm not sure why currently in the code it's a full memory barrier after __packet_set_status - it could be downgraded to a write barrier.

Also, there is a bug in the current code I believe:

Around line 726:

@@ -723,8 +723,9 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	else
 		sll->sll_ifindex = dev->ifindex;

+ 	smp_wmb();
 	__packet_set_status(po, h.raw, status);
- 	smp_mb();
+ 	smp_wmb();

 	{
 		struct page *p_start, *p_end;

We only really need 1 memory barrier: for architectures where flush_dcache_page is a no-op and writes may be re-ordered, we need the smp_wmb before (if writes may not be re-ordered, ala x86, then a simple barrier() will suffice).  With architectures that actually need the data flushed, we put it after the __packet_set_status (and this can't be a simple barrier).  However, to generically do it, we do both (I couldn't find a pre-processor that gets defined to indicate if flush_dcache_page is no-op or actually does something).  If we don't do it this way it's possible (however unlikely), that the status is set before the data is filled in correctly.  This'll come up if the compiler moves the set status around or the CPU re-orders writes and flush_dcache_page is a no-op.

Should I submit this as a patch, or am I missing something?

"I'm afraid that once a barrier discussion comes up and we insert them, then I become dazedly paranoid and it's very hard to shake me from seeing a need for barriers everywhere, including a barrier before and after every barrier ad infinitum to make sure they're really barriers."
-- Hugh Dickins

Vitali

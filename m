From: Johann Baudy <johaahn@gmail.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 04 Nov 2008 23:33:58 +0100
Message-ID: <1225838038.6116.10.camel@fry>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:53539 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754034AbYKDWeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 17:34:01 -0500
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

> Actually, it represents the number of skbs allocated, which represents the number of pending skbs.  Consider the following scenario:
> 
> atomic_inc(pending_skb) 		(pending_skb = 1)
> skb is allocated
> for some reason the filling in of the skb fails after the destructor is set (i.e. tp_len is too big)
> we go to out_free & free the skb
> our destructor gets called
> atomic_dec(pending_skb)             (pending_skb = 0)
> atomic_dec(pending_skb)             (pending_skb = -1)
> 
> That is why it needs to be set after the skb is allocated (so that you don't need that atomic_dec).
> 
Oh ! Yes thanks! That's an obvious mistake. I'll fix it. 

> > 
> > atomic_dec() will be needed anyway if tpacket_fill_skb() or
> > dev_queue_xmit() are failing (If performed after skb alloc).
> > 
> No, because when you call kfree_skb it'll call the destructor (which tpacket_fill_skb should fill as the first thing, before any error conditions can happen).
> 
> > > Also, you've got a potential threading issue - you're not protecting
> > > the frame index behind the spinlock.
> > 
> > You are right, I think I will spin-lock outside the do_while loop.
> Can't do that I think - dev_queue_xmit sleeps AFAIK and you can't hold a spinlock when you sleep.  
> Can you explain why you need a spinlock though?  I think you're trying to make it thread-safe if multiple threads make calls to send, correct?
>   In this case, just change it to a semaphore, and protect the entire send call (well - at least in a safe enough way to make sure you're properly unlocking upon exit).  Also, a better question is - is there any particular reason we need to support multiple threads calling send?  Just stipulate that the behaviour is undefined when there are calls to send from different threads.

Yes, this is to protect this mechanism against simultaneous send() calls.
Indeed, using Mutex seems to be a more appropriate manner as it allows
cpu to do other things.
 
> > So, If my understanding of those memory barriers is correct, we should
> > have a smp_rmb() before status reading and smp_wmb() after status
> > writing in skb destructor and send procedure.
> I'm not 100% sure about this - for this I was just referring to how the RX ring buffer does it.  However, I don't think so.  My understanding of the smp_wmb is that it's there so that the data cache is flushed properly.  In other words, when you change the tp_status field, you need to make sure that it's actually been written before you flush.  However, for reading, this is not a problem I think.  I also think that since TP_STATUS_COPY is only used only within the kernel, when you set TP_STATUS_COPY, you don't need to do the smp_wmb or the data cache flush.
> 
> Perhaps someone who's more comfortable with memory barriers could respond on this issue?

According to memory-barrier documentation, "A write barrier should always be paired with a data dependency barrier or read
barrier" (cf. below).

SMP BARRIER PAIRING
-------------------

When dealing with CPU-CPU interactions, certain types of memory barrier should
always be paired.  A lack of appropriate pairing is almost certainly an error.

A write barrier should always be paired with a data dependency barrier or read
barrier, though a general barrier would also be viable.  Similarly a read
barrier or a data dependency barrier should always be paired with at least an
write barrier, though, again, a general barrier is viable:

	CPU 1		CPU 2
	===============	===============
	a = 1;
	<write barrier>
	b = 2;		x = b;
			<read barrier>
			y = a;

Best regards,
Johann





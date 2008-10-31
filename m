From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Fri, 31 Oct 2008 10:07:58 -0700
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:42904 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbYJaRIC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 13:08:02 -0400
In-Reply-To: <1225450706.5301.94.camel@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Johann Baudy [mailto:johaahn@gmail.com]
> Sent: October-31-08 3:58 AM
> To: Lovich, Vitali
> Cc: David Miller; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> Hi Vitali,
> 
> > There's no need to keep the index (packet_index).  Just store the
> pointer directly (change it to void *) - saves an extra lookup.
> 
> Indeed, it will be faster. I'll do the change.
Actually, I just realized that we don't need to modify the sock_buff structure.  We're already filling in the fragments of the skb - just take the first fragment and reverse the process to determine the starting address of the frame.
> 
> > Also, I don't think setting TP_STATUS_COPY is necessary since the
> user
> > can't really do anything with that information. Simply leave it at
> > TP_STATUS_USER & TP_STATUS_KERNEL.
> 
> This information is not useful for user. It is to prevent kernel from
> sending a packet twice or more. Inside the tx ring lock, queued packets
> must be tagged as "Kernel has already handled this packet" to not send
> it again at next turn of tx ring.
> (That case can happen if device/queue is very slow or if you have only
> few frames)
Sorry - you are correct.

> 
> > The atomic_inc of pending_skb should happen after the skb was
> > allocated - the atomic_dec in out_status can also be removed.
> > out_status can be removed completely if you get rid of
> > TP_STATUS_COPY.  If you leave it, you still need the barriers as
> above
> > after changing tp_status, or the user may not see the change.
> 
> I don't understand why "atomic_inc of pending_skb should happen after
> the skb was allocated". This counter is used to monitor the number of
> TX
> packets queued. So as requirement, we have to increment it before
> dev_queue_xmit().
Actually, it represents the number of skbs allocated, which represents the number of pending skbs.  Consider the following scenario:

atomic_inc(pending_skb) 		(pending_skb = 1)
skb is allocated
for some reason the filling in of the skb fails after the destructor is set (i.e. tp_len is too big)
we go to out_free & free the skb
our destructor gets called
atomic_dec(pending_skb)             (pending_skb = 0)
atomic_dec(pending_skb)             (pending_skb = -1)

That is why it needs to be set after the skb is allocated (so that you don't need that atomic_dec).

> 
> atomic_dec() will be needed anyway if tpacket_fill_skb() or
> dev_queue_xmit() are failing (If performed after skb alloc).
> 
No, because when you call kfree_skb it'll call the destructor (which tpacket_fill_skb should fill as the first thing, before any error conditions can happen).

> > Also, you've got a potential threading issue - you're not protecting
> > the frame index behind the spinlock.
> 
> You are right, I think I will spin-lock outside the do_while loop.
Can't do that I think - dev_queue_xmit sleeps AFAIK and you can't hold a spinlock when you sleep.  Can you explain why you need a spinlock though?  I think you're trying to make it thread-safe if multiple threads make calls to send, correct?  In this case, just change it to a semaphore, and protect the entire send call (well - at least in a safe enough way to make sure you're properly unlocking upon exit).  Also, a better question is - is there any particular reason we need to support multiple threads calling send?  Just stipulate that the behaviour is undefined when there are calls to send from different threads.

> 
> > Also, when you set the status back to TP_STATUS_KERNEL in the
> destructor, you need
> >  to add the following barriers:
> >
> > __packet_set_status(po, ph, TP_STATUS_KERNEL);
> > smp_mb();   // make sure the TP_STATUS_KERNEL was actually written to
> > memory before this - couldn't this actually be just a smp_wmb?
> > flush_dcache_page(virt_to_page(ph));  // on non-x86 architectures
> like
> > ARM that have a moronic cache (i.e cache by virtual rather than
> > physical address). on x86 this is a noop.
> >
> 
> So, If my understanding of those memory barriers is correct, we should
> have a smp_rmb() before status reading and smp_wmb() after status
> writing in skb destructor and send procedure.
I'm not 100% sure about this - for this I was just referring to how the RX ring buffer does it.  However, I don't think so.  My understanding of the smp_wmb is that it's there so that the data cache is flushed properly.  In other words, when you change the tp_status field, you need to make sure that it's actually been written before you flush.  However, for reading, this is not a problem I think.  I also think that since TP_STATUS_COPY is only used only within the kernel, when you set TP_STATUS_COPY, you don't need to do the smp_wmb or the data cache flush.

Perhaps someone who's more comfortable with memory barriers could respond on this issue?


From: Johann Baudy <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Fri, 31 Oct 2008 11:58:26 +0100
Message-ID: <1225450706.5301.94.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g19.free.fr ([212.27.42.28]:53644 "EHLO smtp2-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbYJaK6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 06:58:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

> There's no need to keep the index (packet_index).  Just store the
pointer directly (change it to void *) - saves an extra lookup.  

Indeed, it will be faster. I'll do the change.

> Also, I don't think setting TP_STATUS_COPY is necessary since the user
> can't really do anything with that information. Simply leave it at
> TP_STATUS_USER & TP_STATUS_KERNEL.

This information is not useful for user. It is to prevent kernel from
sending a packet twice or more. Inside the tx ring lock, queued packets
must be tagged as "Kernel has already handled this packet" to not send
it again at next turn of tx ring. 
(That case can happen if device/queue is very slow or if you have only
few frames)

> The atomic_inc of pending_skb should happen after the skb was
> allocated - the atomic_dec in out_status can also be removed. 
> out_status can be removed completely if you get rid of
> TP_STATUS_COPY.  If you leave it, you still need the barriers as above
> after changing tp_status, or the user may not see the change.  

I don't understand why "atomic_inc of pending_skb should happen after
the skb was allocated". This counter is used to monitor the number of TX
packets queued. So as requirement, we have to increment it before
dev_queue_xmit().

atomic_dec() will be needed anyway if tpacket_fill_skb() or
dev_queue_xmit() are failing (If performed after skb alloc).

> Also, you've got a potential threading issue - you're not protecting
> the frame index behind the spinlock.

You are right, I think I will spin-lock outside the do_while loop.

> Also, when you set the status back to TP_STATUS_KERNEL in the
destructor, you need
>  to add the following barriers:
>
> __packet_set_status(po, ph, TP_STATUS_KERNEL);
> smp_mb();   // make sure the TP_STATUS_KERNEL was actually written to
> memory before this - couldn't this actually be just a smp_wmb?
> flush_dcache_page(virt_to_page(ph));  // on non-x86 architectures like
> ARM that have a moronic cache (i.e cache by virtual rather than
> physical address). on x86 this is a noop.
>

So, If my understanding of those memory barriers is correct, we should
have a smp_rmb() before status reading and smp_wmb() after status
writing in skb destructor and send procedure.

> Also, I think that I looked at your code while working on my version
> and there may have been some logical problems with the way you're
> building packets.  I'll compare it within the next few days as I start
> cleaning up my code.

I've noticed "data += dev->hard_header_len; to_write -=
dev->hard_header_len;" that must be in (sock->type != SOCK_DGRAM)
condition. 

> As a benchmark on a 10G card (and not performing any optimizations
> like using syspart & dedicating a cpu for tx), I was able to hit 8.6
> GBits/s using a dedicated kernel thread for the transmission.  With
> the dedicated CPU, I'm confident the line-rate will go up
> significantly
>
> .I'll try to test your changes within the next few days.  TCPdump
> maxes out at around 1.5 GBits/s
>
> As for CPU usage, there's a noticeable advantage to traditional send. 
> Using tcpreplay  - there's about 80% CPU utilization when sending. 
> Using the tx ring, there's maybe 10-15%.
>

On my side, I'm using a 1G device with a PPC405.
I've reached 107MBytes/s with TX RING against 25MBytes/S with standard
packet socket raw and 107MBytes with pktgen.

> I'm going to have latency numbers soon as well (i.e. how much jitter
> is introduced by the kernel).
>

Many thanks Vitali for your comments and help :)


-- 
Johann Baudy
johaahn@gmail.com




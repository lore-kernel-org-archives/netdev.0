From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] Deadlock in af_packet/packet_rcv
Date: Tue, 30 Nov 2004 12:31:50 +0100
Message-ID: <41AC5A26.6000400@tpack.net>
References: <20041125205503.GA18083@suse.de> <41AC3E2F.2030003@tpack.net> <20041130110110.GD16970@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041130110110.GD16970@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Olaf Kirch wrote:
> On Tue, Nov 30, 2004 at 10:32:31AM +0100, Tommy Christensen wrote:
> 
>>An interrupt handler shouldn't call dev_queue_xmit() directly. If
>>this indeed happens, it needs to be fixed. Which handler is this?
> 
> 
> The call path according to KDB goes like this:
> 
> 	application does sendmsg()
> 	udp_push_pending_frames 
> 	ip_push_pending_frames 
> 	ip_output 
> 	dev_queue_xmit 
> 	dev_queue_xmit_nit 
> 		calls ptype->func(skb2, skb->dev, ptype),
> 		where func=packet_rcv 
> 	packet_rcv (and this runs with BHs enabled)
> 		take the &sk->sk_receive_queue spinlock 
> *** timer interrupt
> 	net_tx_action
> 		take the dev->queue_lock spin lock
> 	qdisc_run
> 	qdisc_restart
> 	dev_queue_xmit_nit
> 		as above
> 	packet_rcv
> 		blocks on the &sk->sk_receive_queue spinlock
> 
> Before lockless-loopback this never triggered because we did a
> spin_lock_bh(&dev->xmit_lock) around the call to dev_queue_xmit_nit.
> 
> Olaf

Ahh, back-traces are *so* nice to have.

I still don't agree with the conclusion, though. The spin_lock_bh()
is changed to a local_bh_disable() and an optional spin_lock().
That should not lead to what you are seeing!

I think perhaps your 'BH disabled count' has been corrupted.

There's a fix for that in 2.6.10-rc2.

-Tommy

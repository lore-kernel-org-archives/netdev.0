From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Deadlock in af_packet/packet_rcv
Date: Tue, 30 Nov 2004 12:01:10 +0100
Message-ID: <20041130110110.GD16970@suse.de>
References: <20041125205503.GA18083@suse.de> <41AC3E2F.2030003@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <41AC3E2F.2030003@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 30, 2004 at 10:32:31AM +0100, Tommy Christensen wrote:
> An interrupt handler shouldn't call dev_queue_xmit() directly. If
> this indeed happens, it needs to be fixed. Which handler is this?

The call path according to KDB goes like this:

	application does sendmsg()
	udp_push_pending_frames 
	ip_push_pending_frames 
	ip_output 
	dev_queue_xmit 
	dev_queue_xmit_nit 
		calls ptype->func(skb2, skb->dev, ptype),
		where func=packet_rcv 
	packet_rcv (and this runs with BHs enabled)
		take the &sk->sk_receive_queue spinlock 
*** timer interrupt
	net_tx_action
		take the dev->queue_lock spin lock
	qdisc_run
	qdisc_restart
	dev_queue_xmit_nit
		as above
	packet_rcv
		blocks on the &sk->sk_receive_queue spinlock

Before lockless-loopback this never triggered because we did a
spin_lock_bh(&dev->xmit_lock) around the call to dev_queue_xmit_nit.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"

From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Wed, 20 Feb 2008 22:37:57 +0000
Message-ID: <47BCABC5.9080204@katalix.com>
References: <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080219230640.GA2755@ami.dom.local> <47BC4F2C.4000802@katalix.com> <20080220183837.GA2881@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030606050709080006050200"
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:60730 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbYBTWiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 17:38:03 -0500
In-Reply-To: <20080220183837.GA2881@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030606050709080006050200
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jarek Poplawski wrote:

>>> (testing patch #1)
> 
> But I hope you tested with the fixed (take 2) version of this patch...

Yes I did. :)

But I just got another lockdep error (attached).

> Since it's quite experimental (testing) this patch could be wrong
> as it is, but I hope it should show the proper way to solve this
> problem. Probably you did some of these, but here are a few of my
> suggestions for testing this:
> 
> 1) try my patch with your full bh locking changing patch;
> 2) add while loops to these trylocks on failure, with e.g.  __delay(1);
>    this should work like full locks again, but there should be no (this
>    kind of) lockdep reports;

Hmm, isn't this just bypassing the lockdep checks?

> 3) I send here another testing patch with this second way to do this:
>    on the write side, but it's even more "experimental" and only a
>    proof of concept (should be applied on vanilla ppp_generic).

I'll look over it. I think I need to take a step back and look at what's 
happening in more detail though.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development


--------------030606050709080006050200
Content-Type: text/plain;
 name="lockdep.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lockdep.log"

Feb 20 22:11:41 localhost kernel: =================================
Feb 20 22:11:43 localhost kernel: [ INFO: inconsistent lock state ]
Feb 20 22:11:44 localhost kernel: 2.6.24.2 #1
Feb 20 22:11:44 localhost kernel: ---------------------------------
Feb 20 22:11:44 localhost kernel: inconsistent {softirq-on-W} -> {in-softirq-R} usage.
Feb 20 22:11:44 localhost kernel: pppd/3744 [HC0[0]:SC1[5]:HE1:SE0] takes:
Feb 20 22:11:44 localhost kernel:  (&sk->sk_dst_lock){---?}, at: [<f8bac857>] pppol2tp_xmit+0x320/0x3d9 [pppol2tp]
Feb 20 22:11:45 localhost kernel: {softirq-on-W} state was registered at:
Feb 20 22:11:45 localhost kernel:   [<c0449046>] __lock_acquire+0x48b/0xbf1
Feb 20 22:11:45 localhost kernel:   [<c0448594>] mark_held_locks+0x39/0x53
Feb 20 22:11:45 localhost kernel:   [<c043083a>] local_bh_enable+0x10e/0x115
Feb 20 22:11:45 localhost kernel:   [<c05da996>] inet_csk_get_port+0xc1/0x1cb
Feb 20 22:11:45 localhost kernel:   [<c044981c>] lock_acquire+0x70/0x8a
Feb 20 22:11:45 localhost kernel:   [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 20 22:11:45 localhost kernel:   [<c061b2c7>] _write_lock+0x29/0x34
Feb 20 22:11:45 localhost kernel:   [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 20 22:11:45 localhost kernel:   [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 20 22:11:45 localhost kernel:   [<c05f66da>] inet_listen+0x3b/0x5e
Feb 20 22:11:45 localhost kernel:   [<c05ab68f>] sys_listen+0x43/0x5f
Feb 20 22:11:45 localhost kernel:   [<c05acba8>] sys_socketcall+0xbd/0x261
Feb 20 22:11:45 localhost kernel:   [<c0404ead>] sysenter_past_esp+0x9a/0xa5
Feb 20 22:11:45 localhost kernel:   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 20 22:11:45 localhost kernel:   [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 20 22:11:45 localhost kernel:   [<ffffffff>] 0xffffffff
Feb 20 22:11:45 localhost kernel: irq event stamp: 41702
Feb 20 22:11:45 localhost kernel: hardirqs last  enabled at (41702): [<c047a1bd>] kfree+0x9f/0xa6
Feb 20 22:11:45 localhost kernel: hardirqs last disabled at (41701): [<c047a135>] kfree+0x17/0xa6
Feb 20 22:11:45 localhost kernel: softirqs last  enabled at (41630): [<c05ceed4>] rt_run_flush+0x64/0x8b
Feb 20 22:11:45 localhost kernel: softirqs last disabled at (41631): [<c040709f>] do_softirq+0x5e/0xc7
Feb 20 22:11:45 localhost kernel: 
Feb 20 22:11:45 localhost kernel: other info that might help us debug this:
Feb 20 22:11:45 localhost kernel: 10 locks held by pppd/3744:
Feb 20 22:11:45 localhost kernel:  #0:  (rtnl_mutex){--..}, at: [<c05f53bd>] devinet_ioctl+0xf4/0x539
Feb 20 22:11:45 localhost kernel:  #1:  ((inetaddr_chain).rwsem){..--}, at: [<c04411c9>] __blocking_notifier_call_chain+0x22/0x51
Feb 20 22:11:45 localhost kernel:  #2:  (rcu_read_lock){..--}, at: [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 20 22:11:45 localhost kernel:  #3:  (rcu_read_lock){..--}, at: [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 20 22:11:45 localhost kernel:  #4:  (rcu_read_lock){..--}, at: [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 20 22:11:45 localhost kernel:  #5:  (slock-AF_INET){-+..}, at: [<c05f2d21>] icmp_reply+0x52/0x1a4
Feb 20 22:11:45 localhost kernel:  #6:  (rcu_read_lock){..--}, at: [<c05b7e60>] dev_queue_xmit+0x125/0x2e9
Feb 20 22:11:45 localhost kernel:  #7:  (_xmit_PPP){-+..}, at: [<c05c4cb1>] __qdisc_run+0x5b/0x156
Feb 20 22:11:45 localhost kernel:  #8:  (&ppp->wlock){-+..}, at: [<f8b9ef10>] ppp_xmit_process+0x15/0x5a1 [ppp_generic]
Feb 20 22:11:45 localhost kernel:  #9:  (&pch->downl){-+..}, at: [<f8b9e6db>] ppp_push+0x63/0x50d [ppp_generic]
Feb 20 22:11:45 localhost kernel: 
Feb 20 22:11:45 localhost kernel: stack backtrace:
Feb 20 22:11:45 localhost kernel: Pid: 3744, comm: pppd Not tainted 2.6.24.2 #1
Feb 20 22:11:45 localhost kernel:  [<c0447933>] print_usage_bug+0x139/0x143
Feb 20 22:11:45 localhost kernel:  [<c04482d2>] mark_lock+0x1cb/0x454
Feb 20 22:11:45 localhost kernel:  [<c04480a2>] find_usage_forwards+0x67/0x8b
Feb 20 22:11:45 localhost kernel:  [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 20 22:11:46 localhost kernel:  [<c0448b8e>] check_noncircular+0x66/0x93
Feb 20 22:11:46 localhost kernel:  [<c0448594>] mark_held_locks+0x39/0x53
Feb 20 22:11:46 localhost kernel:  [<c047a1bd>] kfree+0x9f/0xa6
Feb 20 22:11:46 localhost kernel:  [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 20 22:11:46 localhost kernel:  [<c044981c>] lock_acquire+0x70/0x8a
Feb 20 22:11:46 localhost kernel:  [<f8bac857>] pppol2tp_xmit+0x320/0x3d9 [pppol2tp]
Feb 20 22:11:46 localhost kernel:  [<c061b3a7>] _read_lock+0x29/0x34
Feb 20 22:11:46 localhost kernel:  [<f8bac857>] pppol2tp_xmit+0x320/0x3d9 [pppol2tp]
Feb 20 22:11:46 localhost kernel:  [<f8bac857>] pppol2tp_xmit+0x320/0x3d9 [pppol2tp]
Feb 20 22:11:46 localhost kernel:  [<f8b9e6db>] ppp_push+0x63/0x50d [ppp_generic]
Feb 20 22:11:46 localhost kernel:  [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 20 22:11:46 localhost kernel:  [<f8b9e6ee>] ppp_push+0x76/0x50d [ppp_generic]
Feb 20 22:11:46 localhost kernel:  [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 20 22:11:46 localhost kernel:  [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 20 22:11:46 localhost kernel:  [<f8b9f3f1>] ppp_xmit_process+0x4f6/0x5a1 [ppp_generic]
Feb 20 22:11:46 localhost kernel:  [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 20 22:11:46 localhost kernel:  [<f8b9f5d2>] ppp_start_xmit+0x136/0x167 [ppp_generic]
Feb 20 22:11:46 localhost kernel:  [<c05b5d29>] dev_hard_start_xmit+0x245/0x29f
Feb 20 22:11:46 localhost kernel:  [<c061b25a>] _spin_lock+0x29/0x34
Feb 20 22:11:46 localhost kernel:  [<c05c4cc0>] __qdisc_run+0x6a/0x156
Feb 20 22:11:46 localhost kernel:  [<c05b7ee0>] dev_queue_xmit+0x1a5/0x2e9
Feb 20 22:11:46 localhost kernel:  [<c05b7e60>] dev_queue_xmit+0x125/0x2e9
Feb 20 22:11:46 localhost kernel:  [<c05d62f5>] ip_finish_output+0x1f4/0x21e
Feb 20 22:11:46 localhost kernel:  [<c05d4f78>] ip_push_pending_frames+0x2dc/0x33b
Feb 20 22:11:46 localhost kernel:  [<c05f2de5>] icmp_reply+0x116/0x1a4
Feb 20 22:11:46 localhost kernel:  [<c05f32b6>] icmp_echo+0x49/0x4d
Feb 20 22:11:46 localhost kernel:  [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 20 22:11:46 localhost kernel:  [<c05f2f67>] icmp_rcv+0xf4/0x116
Feb 20 22:11:46 localhost kernel:  [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 20 22:11:46 localhost kernel:  [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 20 22:11:46 localhost kernel:  [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 20 22:11:46 localhost kernel:  [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 20 22:11:46 localhost kernel:  [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 20 22:11:46 localhost kernel:  [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 20 22:11:46 localhost kernel:  [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 20 22:11:46 localhost kernel:  [<c05b7c53>] process_backlog+0x6c/0xb9
Feb 20 22:11:46 localhost kernel:  [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 20 22:11:46 localhost kernel:  [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 20 22:11:46 localhost kernel:  [<c0430a9a>] __do_softirq+0x69/0xde
Feb 20 22:11:46 localhost kernel:  [<c040709f>] do_softirq+0x5e/0xc7
Feb 20 22:11:47 localhost kernel:  [<c05ceed4>] rt_run_flush+0x64/0x8b
Feb 20 22:11:47 localhost kernel:  [<c05ceed4>] rt_run_flush+0x64/0x8b
Feb 20 22:11:47 localhost kernel:  [<c04308ee>] local_bh_enable_ip+0xad/0xd5
Feb 20 22:11:47 localhost kernel:  [<c05ceed4>] rt_run_flush+0x64/0x8b
Feb 20 22:11:47 localhost kernel:  [<c05fa7e7>] fib_disable_ip+0x1e/0x26
Feb 20 22:11:47 localhost kernel:  [<c05faf99>] fib_inetaddr_event+0x19c/0x1b0
Feb 20 22:11:47 localhost kernel:  [<c061d06c>] notifier_call_chain+0x2a/0x47
Feb 20 22:11:47 localhost kernel:  [<c04411e5>] __blocking_notifier_call_chain+0x3e/0x51
Feb 20 22:11:47 localhost kernel:  [<c044120f>] blocking_notifier_call_chain+0x17/0x1a
Feb 20 22:11:47 localhost kernel:  [<c05f450b>] __inet_del_ifa+0x12f/0x1f0
Feb 20 22:11:47 localhost kernel:  [<c05f45e3>] inet_del_ifa+0x17/0x1a
Feb 20 22:11:47 localhost kernel:  [<c05f5716>] devinet_ioctl+0x44d/0x539
Feb 20 22:11:47 localhost kernel:  [<c05b7188>] dev_ioctl+0x46f/0x5e0
Feb 20 22:11:47 localhost kernel:  [<c05ab078>] sock_ioctl+0x1bb/0x1e0
Feb 20 22:11:47 localhost kernel:  [<c05aaebd>] sock_ioctl+0x0/0x1e0
Feb 20 22:11:47 localhost kernel:  [<c0488827>] do_ioctl+0x1f/0x62
Feb 20 22:11:47 localhost kernel:  [<c0458df0>] audit_syscall_entry+0x10d/0x137
Feb 20 22:11:47 localhost kernel:  [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 20 22:11:47 localhost kernel:  [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 20 22:11:47 localhost kernel:  [<c0404efa>] syscall_call+0x7/0xb
Feb 20 22:11:47 localhost kernel:  =======================

--------------030606050709080006050200--

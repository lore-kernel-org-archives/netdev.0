From: Li Frank-B20596 <B20596@freescale.com>
Subject: RE: [PATCH v5 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Tue, 14 May 2013 02:29:16 +0000
Message-ID: <1F990F8245A4214A8CC4BFFBD9F790F9089423D7@039-SN1MPN1-002.039d.mgd.msft.net>
References: <1367971724-1974-1-git-send-email-Frank.Li@freescale.com>
 <20130513045710.GA4440@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"r.schwebel@pengutronix.de" <r.schwebel@pengutronix.de>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"festevam@gmail.com" <festevam@gmail.com>,
	"lznuaa@gmail.com" <lznuaa@gmail.com>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:30194
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756270Ab3ENC3X convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 May 2013 22:29:23 -0400
In-Reply-To: <20130513045710.GA4440@S2101-09.ap.freescale.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Hi Frank,
> 
> On Wed, May 08, 2013 at 08:08:44AM +0800, Frank Li wrote:
> > reproduce steps
> >  1. flood ping from other machine
> >  	ping -f -s 41000 IP
> >  2. run below script
> >     while [ 1 ]; do ethtool -s eth0 autoneg off;
> >     sleep 3;ethtool -s eth0 autoneg on; sleep 4; done;
> >
> > You can see oops in one hour.
> >
> > The reason is fec_restart clear BD but NAPI may use it.
> > The solution is disable NAPI and stop xmit when reset BD.
> > disable NAPI may sleep, so fec_restart can't be call in atomic
> > context.
> >
> > Signed-off-by: Frank Li <Frank.Li@freescale.com>
> > Reviewed-by: Lucas Stach <l.stach@pengutronix.de>
> > Tested-by: Lucas Stach <l.stach@pengutronix.de>
> 
> The patch has landed on 3.10-rc1.  Seems that it introduces a lock warning as
> below.  Turn on CONFIG_PROVE_LOCKING and you will be able to see it.

I will investigate it. 

> 
> Shawn
> 
> libphy: 2188000.ethernet:01 - Link is Up - 100/Full
> IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> 
> =================================
> [ INFO: inconsistent lock state ]
> 3.10.0-rc1+ #1 Not tainted
> ---------------------------------
> inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
> swapper/0/0 [HC0[0]:SC1[5]:HE1:SE0] takes:
>  (_xmit_ETHER#2){+.?...}, at: [<8047a7b4>] sch_direct_xmit+0xb4/0x2fc
> {SOFTIRQ-ON-W} state was registered at:
>   [<80068a04>] mark_lock+0x150/0x6d0
>   [<800695a8>] __lock_acquire+0x624/0x1ce0
>   [<8006b16c>] lock_acquire+0x68/0x7c
>   [<8054d1a4>] _raw_spin_lock+0x34/0x44
>   [<80380788>] fec_restart+0x614/0x694
>   [<803811f4>] fec_enet_adjust_link+0x84/0xbc
>   [<8037d0ac>] phy_state_machine+0x184/0x39c
>   [<8003dbfc>] process_one_work+0x1a4/0x42c
>   [<8003e298>] worker_thread+0x138/0x3a8
>   [<8004462c>] kthread+0xac/0xb8
>   [<8000e688>] ret_from_fork+0x14/0x2c
> irq event stamp: 9252
> hardirqs last  enabled at (9252): [<8002bc08>] local_bh_enable_ip+0x84/0xec
> hardirqs last disabled at (9251): [<8002bbc8>] local_bh_enable_ip+0x44/0xec
> softirqs last  enabled at (9202): [<8002b8b0>] _local_bh_enable+0x14/0x18
> softirqs last disabled at (9203): [<8002be80>] irq_exit+0xac/0xe8
> 
> other info that might help us debug this:
>  Possible unsafe locking scenario:
> 
>        CPU0
>        ----
>   lock(_xmit_ETHER#2);
>   <Interrupt>
>     lock(_xmit_ETHER#2);
> 
>  *** DEADLOCK ***
> 
> 4 locks held by swapper/0/0:
>  #0:  (((&idev->mc_ifc_timer))){+.-...}, at: [<80031384>]
> call_timer_fn+0x0/0xf0
>  #1:  (rcu_read_lock){.+.+..}, at: [<80501d58>] mld_sendpack+0x0/0x55c
>  #2:  (rcu_read_lock_bh){.+....}, at: [<804e1e54>]
> ip6_finish_output2+0x44/0x748
>  #3:  (rcu_read_lock_bh){.+....}, at: [<804641e4>] dev_queue_xmit+0x0/0x658
> 
> stack backtrace:
> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.0-rc1+ #1
> Backtrace:
> [<80011ebc>] (dump_backtrace+0x0/0x10c) from [<8001205c>]
> (show_stack+0x18/0x1c)
>  r6:80763fc8 r5:80763c08 r4:808a0358 r3:00000000 [<80012044>]
> (show_stack+0x0/0x1c) from [<80549188>] (dump_stack+0x20/0x28) [<80549168>]
> (dump_stack+0x0/0x28) from [<805471f4>] (print_usage_bug+0x26c/0x2dc)
> [<80546f88>] (print_usage_bug+0x0/0x2dc) from [<80068f0c>]
> (mark_lock+0x658/0x6d0) [<800688b4>] (mark_lock+0x0/0x6d0) from [<80069560>]
> (__lock_acquire+0x5dc/0x1ce0) [<80068f84>] (__lock_acquire+0x0/0x1ce0) from
> [<8006b16c>] (lock_acquire+0x68/0x7c) [<8006b104>] (lock_acquire+0x0/0x7c)
> from [<8054d1a4>] (_raw_spin_lock+0x34/0x44)  r7:00000000 r6:bf8e0800
> r5:00000002 r4:bf8b5440 [<8054d170>] (_raw_spin_lock+0x0/0x44) from
> [<8047a7b4>] (sch_direct_xmit+0xb4/0x2fc)  r5:bf8b5400 r4:bfbe7600
> [<8047a700>] (sch_direct_xmit+0x0/0x2fc) from [<80464474>]
> (dev_queue_xmit+0x290/0x658) [<804641e4>] (dev_queue_xmit+0x0/0x658) from
> [<8046caf4>] (neigh_resolve_output+0x114/0x218)
> [<8046c9e0>] (neigh_resolve_output+0x0/0x218) from [<804e21d8>]
> (ip6_finish_output2+0x3c8/0x748) [<804e1e10>] (ip6_finish_output2+0x0/0x748)
> from [<804e5798>] (ip6_finish_output+0xb0/0x1dc) [<804e56e8>]
> (ip6_finish_output+0x0/0x1dc) from [<804e5964>] (ip6_output+0xa0/0x244)
> r5:bf8e0800 r4:bf022480 [<804e58c4>] (ip6_output+0x0/0x244) from [<805021f0>]
> (mld_sendpack+0x498/0x55c)  r7:00000000 r6:bfbe5400 r5:0000004c r4:bf022480
> [<80501d58>] (mld_sendpack+0x0/0x55c) from [<805028f4>]
> (mld_ifc_timer_expire+0x1d4/0x2b0)
> [<80502720>] (mld_ifc_timer_expire+0x0/0x2b0) from [<800313f8>]
> (call_timer_fn+0x74/0xf0) [<80031384>] (call_timer_fn+0x0/0xf0) from
> [<80031668>] (run_timer_softirq+0x1f4/0x210)  r8:807e5d70 r7:00000000
> r6:8075a0c0 r5:807e5540 r4:80759e38 [<80031474>] (run_timer_softirq+0x0/0x210)
> from [<8002b9b4>] (__do_softirq+0x100/0x1f4) [<8002b8b4>]
> (__do_softirq+0x0/0x1f4) from [<8002be80>] (irq_exit+0xac/0xe8) [<8002bdd4>]
> (irq_exit+0x0/0xe8) from [<8000eef8>] (handle_IRQ+0x58/0xb4)
>  r4:80760c78 r3:00000220
> [<8000eea0>] (handle_IRQ+0x0/0xb4) from [<80008604>]
> (gic_handle_irq+0x30/0x64)  r8:807a2f6d r7:f4000100 r6:80759f18 r5:80760dbc
> r4:f400010c r3:00000000 [<800085d4>] (gic_handle_irq+0x0/0x64) from
> [<8000e124>] (__irq_svc+0x44/0x5c) Exception stack(0x80759f18 to 0x80759f60)
> 9f00:                                                       00000001 00000001
> 9f20: 00000000 80763c08 80758000 00000000 807a2f6d 00000001 807a2f6d 8055042c
> 9f40: 8076092c 80759f6c 80759f30 80759f60 8006badc 8000f2a4 20000113 ffffffff
> r7:80759f4c r6:ffffffff r5:20000113 r4:8000f2a4 [<8000f27c>]
> (arch_cpu_idle+0x0/0x44) from [<8005badc>] (cpu_startup_entry+0x74/0x160)
> [<8005ba68>] (cpu_startup_entry+0x0/0x160) from [<80540e34>]
> (rest_init+0xb0/0xd8)  r7:81512400 [<80540d84>] (rest_init+0x0/0xd8) from
> [<80712848>] (start_kernel+0x2c4/0x31c)
>  r6:807493e8 r5:807a3080 r4:80760990
> [<80712584>] (start_kernel+0x0/0x31c) from [<10008074>] (0x10008074)
> r7:80764fec r6:807493e4 r5:807608d0 r4:10c53c7d

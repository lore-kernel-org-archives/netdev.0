From: Dave Jones <davej@redhat.com>
Subject: softirq lockdep trace when ethernet (tg3) brought up.
Date: Thu, 14 Nov 2013 14:16:21 -0500
Message-ID: <20131114191621.GB9630@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754821Ab3KNTQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 14:16:29 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rAEJGS03007891
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 14:16:29 -0500
Received: from gelk.kernelslacker.org (ovpn-113-174.phx2.redhat.com [10.3.113.174])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id rAEJGMMT002694
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 14:16:28 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.7) with ESMTP id rAEJGLFf019115
	for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 14:16:21 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id rAEJGLlb019113
	for netdev@vger.kernel.org; Thu, 14 Nov 2013 14:16:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

See this during boot on one of my test boxes:
Not sure why it only shows up on that machine. TG3 specific ?

=================================
[ INFO: inconsistent lock state ]
3.12.0+ #1 Not tainted
---------------------------------
inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
swapper/1/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
 (&af_inet_stats->syncp.seq){+.?...}, at: [<c14d18f8>] __netif_receive_skb_core+0x85d/0xb94
{SOFTIRQ-ON-W} state was registered at:
  [<c1090dfa>] __lock_acquire+0x558/0x1808
  [<c10926cf>] lock_acquire+0x7d/0x18b
  [<c1534cce>] ip4_datagram_connect+0x38e/0x3b2
  [<c1544479>] inet_dgram_connect+0x2a/0x68
  [<c14ba636>] SYSC_connect+0xaf/0xc9
  [<c14bb422>] SYSC_socketcall+0x20d/0x937
  [<c14bbc0b>] SyS_socketcall+0x13/0x15
  [<c15f33bb>] sysenter_do_call+0x12/0x32
irq event stamp: 147986
hardirqs last  enabled at (147986): [<c15ebcb7>] _raw_spin_unlock_irqrestore+0x4e/0x59
hardirqs last disabled at (147985): [<c15eba8f>] _raw_spin_lock_irqsave+0x18/0x7e
softirqs last  enabled at (147960): [<c1045a79>] _local_bh_enable+0x1f/0x42
softirqs last disabled at (147961): [<c100414b>] do_softirq_own_stack+0x2e/0x34

other info that might help us debug this:
  Possible unsafe locking scenario:

        CPU0
        ----
   lock(&af_inet_stats->syncp.seq);
   <Interrupt>
     lock(&af_inet_stats->syncp.seq);
 
 *** DEADLOCK ***

1 lock held by swapper/1/0:
 #0:  (rcu_read_lock){.+.+..}, at: [<c14d11ac>] __netif_receive_skb_core+0x111/0xb94

stack backtrace:
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.12.0+ #1 
Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
 c1d53dc0 00000000 efe95ce0 c15e3b8e efe44260 efe95d1c c15e06f1 c178edb4
 c178f110 00000000 00000000 00000000 00000001 00000001 00000001 00000000
 c178f110 00000004 efe4475c 00000010 efe95d50 c109031d 00000004 c1077fc8
Call Trace:
 [<c15e3b8e>] dump_stack+0x4b/0x75
 [<c15e06f1>] print_usage_bug+0x1cf/0x1d9
 [<c109031d>] mark_lock+0x1ea/0x26b
 [<c1077fc8>] ? sched_clock_local+0x42/0x12e
 [<c108fa61>] ? check_usage_backwards+0x109/0x109
 [<c1090db5>] __lock_acquire+0x513/0x1808
 [<c1078223>] ? sched_clock_cpu+0xcd/0x130
 [<c109041f>] ? mark_held_locks+0x81/0xe7
 [<c108d6e5>] ? trace_hardirqs_off+0xb/0xd
 [<c108dd1e>] ? put_lock_stats.isra.30+0xd/0x20
 [<c108e119>] ? lock_release_holdtime.part.31+0x8b/0xd4
 [<c10926cf>] lock_acquire+0x7d/0x18b
 [<c14d18f8>] ? __netif_receive_skb_core+0x85d/0xb94
 [<c150a1aa>] ip_rcv+0x6a/0x5d0
 [<c14d18f8>] ? __netif_receive_skb_core+0x85d/0xb94
 [<c14d18f8>] __netif_receive_skb_core+0x85d/0xb94
 [<c14d11ac>] ? __netif_receive_skb_core+0x111/0xb94
 [<c14d1c45>] __netif_receive_skb+0x16/0x51
 [<c14d1c9f>] netif_receive_skb+0x1f/0x1a7
 [<c14d26b3>] napi_gro_receive+0x5f/0x7e
 [<f8533cfe>] tg3_poll_work+0xc61/0xeaa [tg3]
 [<c108d6e5>] ? trace_hardirqs_off+0xb/0xd
 [<f853ed4c>] tg3_poll+0x6a/0x314 [tg3]
 [<c1090523>] ? trace_hardirqs_on_caller+0x9e/0x1aa
 [<c14d2888>] net_rx_action+0x11a/0x29a
 [<c1046c78>] __do_softirq+0xd2/0x38d
 [<c1046ba6>] ? __tasklet_schedule+0x131/0x131
 <IRQ>  [<c104725a>] ? irq_exit+0xa8/0xb0
 [<c15f39d5>] ? do_IRQ+0x45/0xb0
 [<c10ad1e5>] ? rcu_irq_exit+0x5a/0x93
 [<c15f38b5>] ? common_interrupt+0x35/0x3c
 [<c109007b>] ? print_irqtrace_events+0x2d/0xe5
 [<c100976e>] ? default_idle+0x1e/0x210
 [<c100a0b6>] ? arch_cpu_idle+0x24/0x26
 [<c10a283c>] ? cpu_startup_entry+0x219/0x39d
 [<c1028032>] ? setup_APIC_timer+0xa5/0x102
 [<c10266d8>] ? start_secondary+0x22e/0x340

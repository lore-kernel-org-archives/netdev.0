From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [BUG] INFO: inconsistent lock state
Date: Tue, 06 Jan 2009 10:34:10 +0800
Message-ID: <4962C322.8000201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63114 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbZAFCfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 21:35:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am using Linus' tree, and the top commit is:

commit fe0bdec68b77020281dc814805edfe594ae89e0f
Merge: 099e657... 5af75d8...
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sun Jan 4 16:32:11 2009 -0800

    Merge branch 'audit.b61' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current

don't know how I triggered this, and not sure whom to CC, network related?

=================================
[ INFO: inconsistent lock state ]
2.6.28 #483
---------------------------------
inconsistent {softirq-on-W} -> {in-softirq-W} usage.
swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
 (&fbc->lock){-+..}, at: [<c05127a6>] __percpu_counter_add+0x52/0x7a
{softirq-on-W} state was registered at:
  [<c044bcd2>] __lock_acquire+0x539/0x700
  [<c044bef6>] lock_acquire+0x5d/0x7a
  [<c061ca68>] _spin_lock+0x20/0x2f
  [<c05127a6>] __percpu_counter_add+0x52/0x7a
  [<c049d615>] get_empty_filp+0x97/0x135
  [<c04a59c2>] path_lookup_open+0x23/0x7a
  [<c04a5ac0>] do_filp_open+0xa7/0x659
  [<c049af1d>] do_sys_open+0x49/0xbe
  [<c049afde>] sys_open+0x23/0x2b
  [<c040332a>] syscall_call+0x7/0xb
  [<ffffffff>] 0xffffffff
irq event stamp: 3606392
hardirqs last  enabled at (3606392): [<c061ce03>] _spin_unlock_irqrestore+0x3b/0x41
hardirqs last disabled at (3606391): [<c061cd31>] _spin_lock_irqsave+0x14/0x39
softirqs last  enabled at (3606338): [<c0430aef>] __do_softirq+0x135/0x13d
softirqs last disabled at (3606369): [<c0404ab6>] do_softirq+0x6a/0xc0

other info that might help us debug this:
4 locks held by swapper/0:
 #0:  (rcu_read_lock){..--}, at: [<c05c3226>] net_rx_action+0x57/0x194
 #1:  (rcu_read_lock){..--}, at: [<c05c0a7b>] netif_receive_skb+0x123/0x2c3
 #2:  (rcu_read_lock){..--}, at: [<c05da9dc>] ip_local_deliver+0x4b/0x119
 #3:  (slock-AF_INET/1){-+..}, at: [<c05f1eec>] tcp_v4_rcv+0x237/0x50f

stack backtrace:
Pid: 0, comm: swapper Not tainted 2.6.28-mc #483
Call Trace:
 [<c0449246>] print_usage_bug+0x155/0x161
 [<c0449e2e>] mark_lock+0x34b/0x905
 [<c044bc5a>] __lock_acquire+0x4c1/0x700
 [<c044bef6>] lock_acquire+0x5d/0x7a
 [<c05127a6>] ? __percpu_counter_add+0x52/0x7a
 [<c061ca68>] _spin_lock+0x20/0x2f
 [<c05127a6>] ? __percpu_counter_add+0x52/0x7a
 [<c05127a6>] __percpu_counter_add+0x52/0x7a
 [<c05f1403>] tcp_v4_destroy_sock+0x15d/0x165
 [<c05e184b>] inet_csk_destroy_sock+0x8c/0xbd
 [<c05e2a5d>] tcp_done+0x5e/0x61
 [<c05eba12>] tcp_rcv_state_process+0x7b9/0x8ad
 [<c05f1eec>] ? tcp_v4_rcv+0x237/0x50f
 [<c05f0901>] tcp_v4_do_rcv+0x138/0x17d
 [<c05f217d>] tcp_v4_rcv+0x4c8/0x50f
 [<c05daa2d>] ip_local_deliver+0x9c/0x119
 [<c05daeb5>] ip_rcv+0x40b/0x452
 [<c05c0bd5>] netif_receive_skb+0x27d/0x2c3
 [<f83f06f0>] rtl8169_rx_interrupt+0x2de/0x39a [r8169]
 [<f83f1963>] rtl8169_poll+0x34/0x155 [r8169]
 [<c05c3291>] net_rx_action+0xc2/0x194
 [<c0430a44>] __do_softirq+0x8a/0x13d
 [<c04309ba>] ? __do_softirq+0x0/0x13d
 <IRQ>  [<c046891f>] ? handle_fasteoi_irq+0x0/0xb5
 [<c043098c>] ? irq_exit+0x49/0x77
 [<c0404bbf>] ? do_IRQ+0xb3/0xcc
 [<c04038ac>] ? common_interrupt+0x2c/0x34
 [<c044007b>] ? hrtimer_get_next_event+0x55/0xc0
 [<c0408541>] ? mwait_idle+0x41/0x4c
 [<c0401dd0>] ? cpu_idle+0x78/0x91
 [<c0617ad4>] ? start_secondary+0x193/0x198

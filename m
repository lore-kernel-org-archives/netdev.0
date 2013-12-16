From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: NET 3.13.0-rc4 inconsistent lock state  (&(&sk->sk_dst_lock)->rlock){+.?...}, at: [<ffffffff818a89e4>] __udp4_lib_rcv+0x9d4/0xa90
Date: Mon, 16 Dec 2013 16:06:09 +0100
Message-ID: <4810128955.20131216160609@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:57954 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754494Ab3LPPGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:06:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a Xen HVM guest i encountered this lock warning on boot, it looks like it's from the last net pull from Linus.
Not sure if it's the Xen-changes or the udp4 ones.

--
Sander


[   15.534739] =================================
[   15.534739] [ INFO: inconsistent lock state ]
[   15.534739] 3.13.0-rc4-20131216+ #1 Not tainted
[   15.534739] ---------------------------------
[   15.534739] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[   15.534739] swapper/0/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   15.534739]  (&(&sk->sk_dst_lock)->rlock){+.?...}, at: [<ffffffff818a89e4>] __udp4_lib_rcv+0x9d4/0xa90
[   15.534739] {SOFTIRQ-ON-W} state was registered at:
[   15.534739]   [<ffffffff810b30d2>] __lock_acquire+0x592/0x2040
[   15.534739]   [<ffffffff810b51ad>] lock_acquire+0xbd/0x100
[   15.534739]   [<ffffffff819516fc>] _raw_spin_lock+0x2c/0x40
[   15.534739]   [<ffffffff818b20ed>] inet_bind+0x1ed/0x230
[   15.534739]   [<ffffffff817cc35c>] SyS_bind+0x6c/0xa0
[   15.534739]   [<ffffffff81952eb9>] system_call_fastpath+0x16/0x1b
[   15.534739] irq event stamp: 232072
[   15.534739] hardirqs last  enabled at (232072): [<ffffffff81077c89>] local_bh_enable+0x99/0x100
[   15.534739] hardirqs last disabled at (232071): [<ffffffff81077c4d>] local_bh_enable+0x5d/0x100
[   15.534739] softirqs last  enabled at (232044): [<ffffffff810773fd>] _local_bh_enable+0x1d/0x50
[   15.534739] softirqs last disabled at (232045): [<ffffffff81077e12>] irq_exit+0xa2/0xd0
[   15.534739]
[   15.534739] other info that might help us debug this:
[   15.534739]  Possible unsafe locking scenario:
[   15.534739]
[   15.534739]        CPU0
[   15.534739]        ----
[   15.534739]   lock(&(&sk->sk_dst_lock)->rlock);
[   15.534739]   <Interrupt>
[   15.534739]     lock(&(&sk->sk_dst_lock)->rlock);
[   15.534739]
[   15.534739]  *** DEADLOCK ***
[   15.534739]
[   15.534739] 3 locks held by swapper/0/0:
[   15.534739]  #0:  (&(&np->rx_lock)->rlock){+.-...}, at: [<ffffffff81672cfd>] xennet_poll+0x4d/0xdc0
[   15.534739]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff817e24c4>] __netif_receive_skb_core+0x114/0x880
[   15.534739]  #2:  (rcu_read_lock){.+.+..}, at: [<ffffffff81879acc>] ip_local_deliver_finish+0x3c/0x1a0
[   15.534739]
[   15.534739] stack backtrace:
[   15.534739] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0-rc4-20131216+ #1
[   15.534739] Hardware name: Xen HVM domU, BIOS 4.4-unstable 12/13/2013
[   15.534739]  ffffffff822cf160 ffff88003f403838 ffffffff81947f94 ffffffff81e134e0
[   15.534739]  ffffffff81e134e0 ffff88003f403898 ffffffff819436b0 0000000000000001
[   15.534739]  ffffffff00000001 ffff880000000000 ffffffff8101bd7a ffffffff81e3d580
[   15.534739] Call Trace:
[   15.534739]  <IRQ>  [<ffffffff81947f94>] dump_stack+0x46/0x58
[   15.534739]  [<ffffffff819436b0>] print_usage_bug.part.34+0x285/0x294
[   15.534739]  [<ffffffff8101bd7a>] ? save_stack_trace+0x2a/0x50
[   15.534739]  [<ffffffff810b0070>] ? check_usage_backwards+0x120/0x120
[   15.534739]  [<ffffffff810b0e94>] mark_lock+0x284/0x6a0
[   15.534739]  [<ffffffff810b2f96>] __lock_acquire+0x456/0x2040
[   15.534739]  [<ffffffff81811aa0>] ? nfnetlink_has_listeners+0x10/0x20
[   15.534739]  [<ffffffff8182342c>] ? ctnetlink_conntrack_event+0x62c/0x770
[   15.534739]  [<ffffffff810b51ad>] lock_acquire+0xbd/0x100
[   15.534739]  [<ffffffff818a89e4>] ? __udp4_lib_rcv+0x9d4/0xa90
[   15.534739]  [<ffffffff8181f548>] ? nf_ct_deliver_cached_events+0x98/0x130
[   15.534739]  [<ffffffff819516fc>] _raw_spin_lock+0x2c/0x40
[   15.534739]  [<ffffffff818a89e4>] ? __udp4_lib_rcv+0x9d4/0xa90
[   15.534739]  [<ffffffff818a89e4>] __udp4_lib_rcv+0x9d4/0xa90
[   15.534739]  [<ffffffff81879acc>] ? ip_local_deliver_finish+0x3c/0x1a0
[   15.534739]  [<ffffffff818a8f75>] udp_rcv+0x15/0x20
[   15.534739]  [<ffffffff81879b60>] ip_local_deliver_finish+0xd0/0x1a0
[   15.534739]  [<ffffffff81879acc>] ? ip_local_deliver_finish+0x3c/0x1a0
[   15.534739]  [<ffffffff81879da4>] ip_local_deliver+0x34/0x90
[   15.534739]  [<ffffffff818795d8>] ip_rcv_finish+0x148/0x600
[   15.534739]  [<ffffffff8187a02b>] ip_rcv+0x22b/0x370
[   15.534739]  [<ffffffff817e2a62>] __netif_receive_skb_core+0x6b2/0x880
[   15.534739]  [<ffffffff817e24c4>] ? __netif_receive_skb_core+0x114/0x880
[   15.534739]  [<ffffffff817e2c4c>] __netif_receive_skb+0x1c/0x70
[   15.534739]  [<ffffffff817e2e8e>] netif_receive_skb+0x1e/0xf0
[   15.534739]  [<ffffffff817e3ff8>] napi_gro_receive+0x88/0xc0
[   15.534739]  [<ffffffff8167352e>] xennet_poll+0x87e/0xdc0
[   15.534739]  [<ffffffff817e3309>] net_rx_action+0x159/0x250
[   15.534739]  [<ffffffff81077831>] ? __do_softirq+0x91/0x210
[   15.534739]  [<ffffffff8107788d>] __do_softirq+0xed/0x210
[   15.534739]  [<ffffffff81077e12>] irq_exit+0xa2/0xd0
[   15.534739]  [<ffffffff8146518f>] xen_evtchn_do_upcall+0x2f/0x40
[   15.534739]  [<ffffffff81954492>] xen_hvm_callback_vector+0x72/0x80
[   15.534739]  <EOI>  [<ffffffff810465b6>] ? native_safe_halt+0x6/0x10
[   15.534739]  [<ffffffff810b162d>] ? trace_hardirqs_on+0xd/0x10
[   15.534739]  [<ffffffff81017228>] default_idle+0x18/0x20
[   15.534739]  [<ffffffff81017aae>] arch_cpu_idle+0x2e/0x40
[   15.534739]  [<ffffffff810bd8f1>] cpu_startup_entry+0x71/0x220
[   15.534739]  [<ffffffff8193c877>] rest_init+0xb7/0xc0
[   15.534739]  [<ffffffff8193c7c0>] ? csum_partial_copy_generic+0x170/0x170
[   15.534739]  [<ffffffff81ef3eb5>] start_kernel+0x3cd/0x3da
[   15.534739]  [<ffffffff81ef38e7>] ? repair_env_string+0x5e/0x5e
[   15.534739]  [<ffffffff81ef35cd>] x86_64_start_reservations+0x2a/0x2c
[   15.534739]  [<ffffffff81ef36d3>] x86_64_start_kernel+0x104/0x113

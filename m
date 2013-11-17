From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: kernel BUG at net/core/skbuff.c:2839 RIP  [<ffffffff819109a2>] skb_segment+0x6b2/0x6d0
Date: Sun, 17 Nov 2013 20:17:44 +0100
Message-ID: <1287049824.20131117201744@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:41720 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab3KQTRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 14:17:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

With the linux-net changes from this merge window i get the kernel panic below (not with 3.12.0).

It's on a machine running Xen, 2x rtl8169 nic, and using a bridge for guest networking.
This panic in the host kernel only seems to occur when generating a lot of network traffic to and from a guest.

I tried reverting "tcp: gso: fix truesize tracking" 0d08c42cf9a71530fef5ebcfe368f38f2dd0476f, but that didn't help.

--
Sander

[ 1164.511712] ------------[ cut here ]------------
[ 1164.518446] kernel BUG at net/core/skbuff.c:2839!
[ 1164.525226] invalid opcode: 0000 [#2] PREEMPT SMP 
[ 1164.532024] Modules linked in:
[ 1164.538713] CPU: 0 PID: 3 Comm: ksoftirqd/0 Tainted: G      D      3.12.0-mw-20131117+ #1
[ 1164.545649] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS V1.8B1 09/13/2010
[ 1164.552659] task: ffff880059b8a180 ti: ffff880059b96000 task.ti: ffff880059b96000
[ 1164.559649] RIP: e030:[<ffffffff819109a2>]  [<ffffffff819109a2>] skb_segment+0x6b2/0x6d0
[ 1164.566860] RSP: e02b:ffff880059b97448  EFLAGS: 00010216
[ 1164.574023] RAX: 0000000000000011 RBX: 0000000000006612 RCX: 0000000000006612
[ 1164.581169] RDX: 00000000000005a8 RSI: 0000000000006612 RDI: ffff8800478ff682
[ 1164.588115] RBP: ffff880059b97518 R08: ffff88004ca06a00 R09: 0000000000000011
[ 1164.595169] R10: 000000000000606a R11: 0000000000000011 R12: 0000000000000000
[ 1164.602214] R13: ffff88004ca06900 R14: ffff88004ca06a00 R15: ffff88004bb57f00
[ 1164.609274] FS:  00007eff7dc67700(0000) GS:ffff88005f600000(0000) knlGS:0000000000000000
[ 1164.616394] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1164.623562] CR2: 00007faa868fff30 CR3: 000000005877e000 CR4: 0000000000000660
[ 1164.630807] Stack:
[ 1164.637959]  ffff880059b97458 ffffffff810d90dd ffff880059b97478 ffffffff8109f69a
[ 1164.645296]  ffff88004b824628 ffff88004b824400 ffff880059b974e8 ffff88004ca06a00
[ 1164.652626]  0000001100000001 0000000000000040 0000000000000042 ffffffffffffffbe
[ 1164.659816] Call Trace:
[ 1164.667034]  [<ffffffff810d90dd>] ? trace_hardirqs_on+0xd/0x10
[ 1164.674313]  [<ffffffff8109f69a>] ? local_bh_enable+0xaa/0x110
[ 1164.681543]  [<ffffffff819dafc2>] tcp_gso_segment+0x102/0x3e0
[ 1164.688691]  [<ffffffff819b8224>] ? ip_queue_xmit+0x194/0x480
[ 1164.695741]  [<ffffffff819e9fe4>] inet_gso_segment+0x124/0x350
[ 1164.702836]  [<ffffffff8191cb25>] skb_mac_gso_segment+0xd5/0x1d0
[ 1164.709735]  [<ffffffff8191ca92>] ? skb_mac_gso_segment+0x42/0x1d0
[ 1164.716739]  [<ffffffff8191cc7b>] __skb_gso_segment+0x5b/0xc0
[ 1164.723802]  [<ffffffff8191ce80>] dev_hard_start_xmit+0x1a0/0x500
[ 1164.730744]  [<ffffffff81939780>] sch_direct_xmit+0x100/0x280
[ 1164.737531]  [<ffffffff8191d404>] dev_queue_xmit+0x224/0x600
[ 1164.744403]  [<ffffffff8191d1e0>] ? dev_hard_start_xmit+0x500/0x500
[ 1164.751317]  [<ffffffff8194765e>] ? nf_hook_slow+0x11e/0x160
[ 1164.758332]  [<ffffffff81a14040>] ? deliver_clone+0x60/0x60
[ 1164.765264]  [<ffffffff81a140d7>] br_dev_queue_push_xmit+0x97/0x140
[ 1164.772082]  [<ffffffff81a1419d>] br_forward_finish+0x1d/0x60
[ 1164.778925]  [<ffffffff81a12490>] ? br_dev_free+0x30/0x30
[ 1164.785714]  [<ffffffff81a142f2>] __br_deliver+0x52/0x180
[ 1164.792355]  [<ffffffff81a146cd>] br_deliver+0x3d/0x50
[ 1164.798950]  [<ffffffff81a126be>] br_dev_xmit+0x22e/0x290
[ 1164.805576]  [<ffffffff81a12490>] ? br_dev_free+0x30/0x30
[ 1164.812106]  [<ffffffff8191d18d>] dev_hard_start_xmit+0x4ad/0x500
[ 1164.818729]  [<ffffffff8191d55e>] dev_queue_xmit+0x37e/0x600
[ 1164.825314]  [<ffffffff8191d1e0>] ? dev_hard_start_xmit+0x500/0x500
[ 1164.831898]  [<ffffffff819b7043>] ip_finish_output+0x293/0x610
[ 1164.838483]  [<ffffffff819b8a44>] ? ip_output+0x54/0xf0
[ 1164.845055]  [<ffffffff819b8a44>] ip_output+0x54/0xf0
[ 1164.851400]  [<ffffffff819b3e71>] ip_forward_finish+0x71/0x1a0
[ 1164.857725]  [<ffffffff819b42d8>] ip_forward+0x338/0x420
[ 1164.864167]  [<ffffffff819b1ca0>] ip_rcv_finish+0x150/0x660
[ 1164.870477]  [<ffffffff819b275b>] ip_rcv+0x22b/0x370
[ 1164.876707]  [<ffffffff81a0de22>] ? packet_rcv_spkt+0x42/0x190
[ 1164.883040]  [<ffffffff8191a3a2>] __netif_receive_skb_core+0x6e2/0x8b0
[ 1164.889193]  [<ffffffff81919dd4>] ? __netif_receive_skb_core+0x114/0x8b0
[ 1164.895039]  [<ffffffff810f28b9>] ? getnstimeofday+0x9/0x30
[ 1164.900704]  [<ffffffff8191a58c>] __netif_receive_skb+0x1c/0x70
[ 1164.906327]  [<ffffffff8191a7af>] netif_receive_skb+0x3f/0x50
[ 1164.911892]  [<ffffffff8191a8d4>] napi_gro_complete+0x114/0x140
[ 1164.917459]  [<ffffffff8191a7e0>] ? napi_gro_complete+0x20/0x140
[ 1164.923048]  [<ffffffff810dcf3a>] ? lock_release+0x12a/0x240
[ 1164.928595]  [<ffffffff819e9cb7>] ? inet_gro_receive+0x57/0x260
[ 1164.934042]  [<ffffffff8191b552>] dev_gro_receive+0x2b2/0x3f0
[ 1164.939384]  [<ffffffff8191b48b>] ? dev_gro_receive+0x1eb/0x3f0
[ 1164.944704]  [<ffffffff8191b849>] napi_gro_receive+0x29/0xc0
[ 1164.949906]  [<ffffffff816d9253>] rtl8169_poll+0x2d3/0x680
[ 1164.955036]  [<ffffffff8191aba1>] net_rx_action+0x171/0x270
[ 1164.960180]  [<ffffffff8109f27d>] __do_softirq+0xed/0x210
[ 1164.965285]  [<ffffffff8109f3f5>] run_ksoftirqd+0x55/0x90
[ 1164.970334]  [<ffffffff810c1e29>] smpboot_thread_fn+0x199/0x2a0
[ 1164.975402]  [<ffffffff810c1c90>] ? SyS_setgroups+0x150/0x150
[ 1164.980438]  [<ffffffff810bb00f>] kthread+0xdf/0x100
[ 1164.985309]  [<ffffffff810baf30>] ? __init_kthread_worker+0x70/0x70
[ 1164.990221]  [<ffffffff81a8a9cc>] ret_from_fork+0x7c/0xb0
[ 1164.995085]  [<ffffffff810baf30>] ? __init_kthread_worker+0x70/0x70
[ 1164.999925] Code: ff 4c 8b 85 68 ff ff ff 44 8b 8d 50 ff ff ff 44 8b 95 48 ff ff ff 44 8b 9d 40 ff ff ff 0f 85 2c fe ff ff e9 23 fe ff ff 90 0f 0b <0f> 0b 48 c7 45 b0 ea ff ff ff e9 cf fc ff ff 0f 0b 0f 0b 66 66 
[ 1165.010399] RIP  [<ffffffff819109a2>] skb_segment+0x6b2/0x6d0
[ 1165.015512]  RSP <ffff880059b97448>
[ 1165.020980] ---[ end trace 88f75f0c791ac25c ]---
[ 1165.026033] Kernel panic - not syncing: Fatal exception in interrupt

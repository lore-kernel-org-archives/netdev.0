From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Bug in skb_segment: fskb->len != len
Date: Mon, 28 Oct 2013 12:55:52 +0100
Message-ID: <20131028115552.GC4408@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:56021 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755683Ab3J1L4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 07:56:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have been seeing the below BUG in skb_segment with the latest net-next
head on my router.

I am forwarding Multipath TCP-traffic on this router. The MPTCP-sender is simply
doing an iperf-session. Strangely, I cannot reproduce the bug when sending
regular TCP-traffic across the router.
Note: The crash happens on a vanilla net-next kernel. It does not has any
MPTCP-code in it.

I bisected it down to 8a29111c7c (net: gro: allow to build full sized skb),
but I guess 8a29111c7c is just revealing a more fundamental bug in skb_segment.

Some info I found:
In skb_segment, when the bug happens, fskb->len is 4284 but the mss and len is 1428.
Shortly before the bug happens, skb_gro_receive is building a packet where
lp->len is equal to 4284 inside the frag_list.


Seems like skb_segment cannot handle those bigger skb's in the frag_list.


Cheers,
Christoph


Here the crash-dump:

[  399.832854] ------------[ cut here ]------------
[  399.888048] kernel BUG at /home/cpaasch/builder/net-next/net/core/skbuff.c:2796!
[  399.976504] invalid opcode: 0000 [#1] SMP 
[  400.025675] Modules linked in:
[  400.062270] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 3.12.0-rc6-mptcp #231
[  400.145531] Hardware name: HP ProLiant DL120 G6/ProLiant DL120 G6, BIOS O26    09/06/2010
[  400.243342] task: ffff88042d8a4680 ti: ffff88042d8ce000 task.ti: ffff88042d8ce000
[  400.332841] RIP: 0010:[<ffffffff81447d21>]  [<ffffffff81447d21>] skb_segment+0x1aa/0x5fa
[  400.429722] RSP: 0018:ffff88043fd03770  EFLAGS: 00010212
[  400.493231] RAX: 0000000000000594 RBX: ffff8800ba89ac00 RCX: 00000000000064be
[  400.578574] RDX: 0000000000000000 RSI: 0000000000000011 RDI: ffff8804273a7080
[  400.663918] RBP: ffff88043fd03820 R08: 0000000000000000 R09: ffff88042c4d4600
[  400.749259] R10: 0000000000010000 R11: ffff88042d801900 R12: ffff88042c7ca000
[  400.834596] R13: ffff88042c5d5400 R14: 0000000000001650 R15: 0000000000000056
[  400.919934] FS:  0000000000000000(0000) GS:ffff88043fd00000(0000) knlGS:0000000000000000
[  401.016711] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  401.085422] CR2: ffffffffff600400 CR3: 000000042c86b000 CR4: 00000000000007e0
[  401.170765] Stack:
[  401.194780]  ffff88042d94e900 ffff88042c4d46f0 0000000000000000 0000000000000042
[  401.283663]  0100000000000000 0000000000000001 0000001100000594 0000000000000056
[  401.372555]  0000000000000000 0000004200000098 ffffffffffffffaa 0000001100000001
[  401.461445] Call Trace:
[  401.490658]  <IRQ> 
[  401.513631]  [<ffffffff8149b077>] tcp_gso_segment+0x168/0x395
[  401.584644]  [<ffffffff814a5ba1>] inet_gso_segment+0x175/0x2a9
[  401.654396]  [<ffffffff8144fb40>] skb_mac_gso_segment+0x10a/0x16a
[  401.727264]  [<ffffffff81451062>] __skb_gso_segment+0xaf/0xb4
[  401.795977]  [<ffffffff814515ae>] dev_hard_start_xmit+0x215/0x40a
[  401.868846]  [<ffffffff814689ed>] sch_direct_xmit+0x6b/0x195
[  401.936519]  [<ffffffff81451988>] dev_queue_xmit+0x1e5/0x3ac
[  402.004193]  [<ffffffff814b6461>] ? iptable_filter_hook+0x41/0x4c
[  402.077061]  [<ffffffff8148039d>] ip_finish_output+0x2f6/0x351
[  402.146812]  [<ffffffff8147c6dc>] ? ip_frag_mem+0x34/0x34
[  402.211366]  [<ffffffff81480470>] ip_output+0x78/0x7f
[  402.271765]  [<ffffffff8147c71c>] ip_forward_finish+0x40/0x44
[  402.340475]  [<ffffffff8147c9c5>] ip_forward+0x2a5/0x300
[  402.403993]  [<ffffffff8147b104>] ip_rcv_finish+0x214/0x22c
[  402.470625]  [<ffffffff8147b3cd>] ip_rcv+0x2b1/0x2e9
[  402.529983]  [<ffffffff81446a19>] ? skb_gro_receive+0x562/0x582
[  402.600773]  [<ffffffff8144dcd8>] __netif_receive_skb_core+0x49a/0x4cd
[  402.678840]  [<ffffffff8144dd60>] __netif_receive_skb+0x55/0x5a
[  402.749631]  [<ffffffff81450190>] netif_receive_skb+0x71/0x78
[  402.818344]  [<ffffffff8149af07>] ? tcp4_gro_receive+0xf4/0xfc
[  402.888095]  [<ffffffff81450249>] napi_gro_complete+0xb2/0xba
[  402.956808]  [<ffffffff8145045f>] dev_gro_receive+0x20e/0x34d
[  403.025519]  [<ffffffff81450ae5>] napi_gro_receive+0x92/0xf1
[  403.093195]  [<ffffffff813acfe2>] netxen_process_rcv_ring+0x1b0/0x767
[  403.170222]  [<ffffffff810b3ae8>] ? kmem_cache_free+0xef/0xf3
[  403.238931]  [<ffffffff81450fb1>] ? dev_kfree_skb_any+0x2e/0x30
[  403.309723]  [<ffffffff813acc42>] ? netxen_process_cmd_ring+0x33/0x223
[  403.387790]  [<ffffffff813a8f70>] netxen_nic_poll+0x35/0x9a
[  403.454423]  [<ffffffff814506dc>] net_rx_action+0xa7/0x1d2
[  403.520017]  [<ffffffff8103605d>] __do_softirq+0xbd/0x17e
[  403.584572]  [<ffffffff815289bc>] call_softirq+0x1c/0x26
[  403.648085]  [<ffffffff81003bbb>] do_softirq+0x33/0x68
[  403.709523]  [<ffffffff81035efb>] irq_exit+0x40/0x4e
[  403.768880]  [<ffffffff81003423>] do_IRQ+0x98/0xaf
[  403.826158]  [<ffffffff8152716a>] common_interrupt+0x6a/0x6a
[  403.893829]  <EOI> 
[  403.916800]  [<ffffffff8100933d>] ? default_idle+0x6/0x8
[  403.982604]  [<ffffffff81009542>] arch_cpu_idle+0x13/0x18
[  404.047159]  [<ffffffff8105ea2b>] cpu_startup_entry+0xa4/0xf1
[  404.115873]  [<ffffffff8102320b>] start_secondary+0x1b2/0x1b7
[  404.184582] Code: bd 7f ff ff ff 00 74 04 44 8b 75 c0 45 85 f6 0f 85 e5 00 00 00 8b 75 84 39 75 ac 0f 8c d9 00 00 00 45 8b 75 68 44 3b 75 c0 74 04 <0f> 0b eb fe 4c 89 ef be 20 00 00 00 e8 08 f1 ff ff 48 85 c0 48 
[  404.417106] RIP  [<ffffffff81447d21>] skb_segment+0x1aa/0x5fa
[  404.485928]  RSP <ffff88043fd03770>
[  404.527614] ---[ end trace 32152a68c7bdc3ac ]---

From: Chris Caputo <ccaputo@alt.net>
Subject: BUG_ONs in net/core/skbuff.c in kernels 3.14.28/29 and 3.18.3
Date: Wed, 21 Jan 2015 23:09:44 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.1501212251540.8217@nacho.alt.net>
Reply-To: Chris Caputo <ccaputo-dated-1432249784.3e732b@alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nacho.alt.net ([208.90.169.18]:53383 "EHLO nacho.alt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665AbbAUXQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 18:16:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I opened a ticket for ixgbe at https://sourceforge.net/p/e1000/bugs/450/ 
but this might be a non-ixgbe issue, so forwarding details to netdev.

I had no problems with 3.5.7 which I used for many months. Then after 
upgrading to 3.14.28, 3.14.29 and 3.18.3 I have experienced several BUG_ON 
crashes. I put my config up at:

  https://www.caputo.com/foss/config_3.18.3_20150121.txt

This server is a router with a HotLava Systems Tambora 64G6 Part 
#6ST2830A2, PCI-e 2.0 (5GT/s), x8, 6-port, Intel 82599ES based NIC. 2x 
Intel Xeon E5420. SuperMicro X7DBE+ Rev 2.01. Intel 5000P (Blackford) 
Chipset. 32GB RAM.

Four of the 10G ports are bonded and trunked. There are packets being 
received and forwarded from one VLAN to another on the same bond1. Total 
utilization is under 5 Gbps. The traffic type is IP and generally TCP, 
with the vast majority of traffic in the 1,024 to 1,522 byte range. 
Example, I just cleared counters on the switch, and for one of the four 
10G's that make up the bundle, stats as follows after several minutes:

Input  
Port                64 Byte      65-127 Byte     128-255 Byte     256-511 
Byte  
------------------------------------------------------------------------------  
Et1                 1451474           278417            72206            59056  
  
Port          512-1023 Byte   1024-1522 Byte    1523-MAX Byte  
-------------------------------------------------------------  
Et1                   77757         55304548                0  

Crash dumps as follows:

With 3.18.3 I had this crash:

[49356.792102] ------------[ cut here ]------------
[49356.792185] kernel BUG at net/core/skbuff.c:2019!
[49356.792260] invalid opcode: 0000 [#1] SMP
[49356.792336] Modules linked in: w83627hf_wdt ip_vs_wlc ip_vs_wlib ip_vs libcrc32c nf_conntrack bonding e1000e e1000
[49356.793074]  [<ffffffff813c0cc8>] netif_receive_skb_internal+0x28/0x90
[49356.793074]  [<ffffffff813c0de4>] napi_gro_complete+0xa4/0xe0
[49356.793074]  [<ffffffff813c0e85>] napi_gro_flush+0x65/0x90
[49356.793074]  [<ffffffff8131bf94>] ixgbe_poll+0x474/0x7c0
[49356.793074]  [<ffffffff813c0fdb>] net_rx_action+0xfb/0x1a0
[49356.793074]  [<ffffffff8105461b>] __do_softirq+0xdb/0x1f0
[49356.793074]  [<ffffffff8105493d>] irq_exit+0x9d/0xb0
[49356.793074]  [<ffffffff810043a7>] do_IRQ+0x57/0xf0
[49356.793074]  [<ffffffff81526f6a>] common_interrupt+0x6a/0x6a
[49356.793074]  <EOI>
[49356.793074]  [<ffffffff8100b6b6>] ? default_idle+0x6/0x10
[49356.793074]  [<ffffffff8100bf1a>] arch_cpu_idle+0xa/0x10
[49356.793074]  [<ffffffff81081a12>] cpu_startup_entry+0x262/0x290
[49356.793074]  [<ffffffff810a01b3>] ? clockevents_register_device+0xe3/0x140
[49356.793074]  [<ffffffff8102ec0f>] start_secondary+0x13f/0x150
[49356.793074] Code: 44 8b 4d b0 48 8b 45 b8 e9 40 fe ff ff be d2 07 00 00 48 c7
               c7 2f 0d 74 81 44 89 5d b8 e8 bd 1b ca ff 44 8b 4d b8 e9 14 ff ff ff <0f> 0b 66
               90 55 48 89 e5 48 83 ec 10 4c 8d 45 f0 48 c7 45 f0 f0
[49356.793074] RIP  [<ffffffff813afa7c>] __skb_checksum+0x28c/0x290
[49356.793074]  RSP <ffff88082fcc37e8>
[49356.798627] ---[ end trace c0598b5bc30231bf ]---
[49356.798752] Kernel panic - not syncing: Fatal exception in interrupt
[49356.798892] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
[49356.799092] Rebooting in 10 seconds..

__skb_checksum+0x28c/0x290 (skbuff.c line 2019):

        skb_walk_frags(skb, frag_iter) {
                int end;

                WARN_ON(start > offset + len);

                end = start + frag_iter->len;
                if ((copy = end - offset) > 0) {
                        __wsum csum2;
                        if (copy > len)
                                copy = len;
                        csum2 = __skb_checksum(frag_iter, offset - start,
                                               copy, 0, ops);
                        csum = ops->combine(csum, csum2, pos, copy);
                        if ((len -= copy) == 0)
                                return csum;
                        offset += copy;
                        pos    += copy;
                }                               
                start = end;
        }
        BUG_ON(len);

3.14.28 crash:

[375129.789047] BUG: unable to handle kernel NULL pointer dereference at 0000000
[375129.790004]  [<ffffffff813a16f5>] napi_gro_flush+0x65/0x80
[375129.790004]  [<ffffffff813a1729>] napi_complete+0x19/0x30
[375129.790004]  [<ffffffff812f9fbe>] ixgbe_poll+0x4ee/0x940
[375129.790004]  [<ffffffff813a183b>] net_rx_action+0xfb/0x1a0
[375129.790004]  [<ffffffff8104ec3c>] __do_softirq+0xdc/0x1f0
[375129.790004]  [<ffffffff8104ef5d>] irq_exit+0x9d/0xb0
[375129.790004]  [<ffffffff81003e33>] do_IRQ+0x53/0xf0
[375129.790004]  [<ffffffff814fddaa>] common_interrupt+0x6a/0x6a
[375129.790004]  <EOI>
[375129.790004]  [<ffffffff81074ac8>] ? sched_clock_cpu+0x88/0xb0
[375129.790004]  [<ffffffff8100a526>] ? default_idle+0x6/0x10
[375129.790004]  [<ffffffff8100ac96>] arch_cpu_idle+0x16/0x20
[375129.790004]  [<ffffffff810863c1>] cpu_startup_entry+0x91/0x180
[375129.790004]  [<ffffffff8102c13f>] start_secondary+0x19f/0x1f0
[375129.790004] Code: 4c 24 60 eb 21 0f 1f 80 00 00 00 00 41 83 c5 01 49 83 c4 10
                48 83 c1 10 41 39 c3 0f 86 7b 01 00 00 41 89 c7 89 c2 45 39 e9 7f 37 <41> 8b 46
                6c 41 39 46 68 0f 85 6d 03 00 00 45 8b a6 c4 00 00 00
[375129.790004] RIP  [<ffffffff8139567f>] skb_segment+0x5df/0x980
[375129.790004]  RSP <ffff88082fcc3828>
[375129.790004] CR2: 000000000000006c
[375129.790004] ---[ end trace ce413143217a96ad ]---
[375129.790004] Kernel panic - not syncing: Fatal exception in interrupt
[375129.790004] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0x [ffffffff80000000-0xffffffff9fffffff)
[375129.790004] Rebooting in 10 seconds..

And then just after rebooting:

[   53.268587] BUG: unable to handle kernel NULL pointer dereference at 00000000
[   53.269532]  [<ffffffff813a1729>] napi_complete+0x19/0x30
[   53.269532]  [<ffffffff812f9fbe>] ixgbe_poll+0x4ee/0x940
[   53.269532]  [<ffffffff812032c4>] ? timerqueue_del+0x24/0x70
[   53.269532]  [<ffffffff81203230>] ? timerqueue_add+0x60/0xb0
[   53.269532]  [<ffffffff813a183b>] net_rx_action+0xfb/0x1a0
[   53.269532]  [<ffffffff8104ec3c>] __do_softirq+0xdc/0x1f0
[   53.269532]  [<ffffffff8104ef5d>] irq_exit+0x9d/0xb0
[   53.269532]  [<ffffffff81003e33>] do_IRQ+0x53/0xf0
[   53.269532]  [<ffffffff814fddaa>] common_interrupt+0x6a/0x6a
[   53.269532]  <EOI>
[   53.269532]  [<ffffffff8100a526>] ? default_idle+0x6/0x10
[   53.269532]  [<ffffffff8100ac96>] arch_cpu_idle+0x16/0x20
[   53.269532]  [<ffffffff810863c1>] cpu_startup_entry+0x91/0x180
[   53.269532]  [<ffffffff8102c13f>] start_secondary+0x19f/0x1f0
[   53.269532] Code: 4c 24 60 eb 21 0f 1f 80 00 00 00 00 41 83 c5 01 49 83 c4 10
[              48 83 c1 10 41 39 c3 0f 86 7b 01 00 00 41 89 c7 89 c2 45 39 e9 7f 37 <41> 8b 46
[              6c 41 39 46 68 0f 85 6d 03 00 00 45 8b a6 c4 00 00 00
[   53.269532] RIP  [<ffffffff8139567f>] skb_segment+0x5df/0x980
[   53.269532]  RSP <ffff88082fd43840>
[   53.269532] CR2: 000000000000006c
[   53.269532] ---[ end trace 1c1a68627fa9d6de ]---
[   53.269532] Kernel panic - not syncing: Fatal exception in interrupt
[   53.269532] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
[   53.269532] Rebooting in 10 seconds..

The code which triggered the BUG is in skb_segment() in net/core/skbuff.c 
(line 3001 of kernel 3.14.28):

                while (pos < offset + len) {
                        if (i >= nfrags) {
                                BUG_ON(skb_headlen(list_skb));

                                i = 0;

Crash with 3.14.29:

[ 4010.835995] BUG: unable to handle kernel NULL pointer dereference at 000000000000006c 
[ 4010.836048] IP: [<ffffffff813955df> skb_segment+0x5df/0x980
[ 4010.836075] PGD 7f8296067 PUD 7f8298067 PMD 0
[ 4010.836130] Oops: 0000 [#1] SMP
[ 4010.836158] Modules linked in: w83627hf_wdt ip_vs_wlc ip_vs_wlib ip_vs libcrc32 nf_conntrack bonding e1000 e1000e 
[ 4010.836250] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.29 
[ 4010.836261] Hardware name: Supermicro X7DB8/X7DB8, BIOS 2.1 06/23/2008
[ 4010.836301] task: ffffffff81810460 ti: ffffffff81800000 task.ti: ffffffff81800000
[ 4010.836346] RIP: 0010:[<ffffffff813955df>]  [<ffffffff813955df>] skb_segment+0x5df/0x980 
[ 4010.836407] RSP: 0018:ffff88082fc03730  EFLAGS: 00010246                     
[ 4010.836503] RAX: 0000000000000a95 RBX: ffff88080b1ddb00 RCX: ffff8805e2edff10
[ 4010.836591] RDX: 0000000000000a95 RSI: 00000000000004d1 RDI: ffffea00032c6480
[ 4010.836680] RBP: ffff88082fc03800 R08: 0000000000010496 R09: 0000000000000002
[ 4010.836769] R10: ffff88080b1dcd00 R11: 0000000000010a12 R12: ffff8808073c9810
[ 4010.836842] R13: 0000000000000002 R14: 0000000000000000 R15: 0000000000000a95
[ 4010.836842] FS:  0000000000000000(0000) GS:ffff88082fc00000(0000) knlGS:0000000000000000 
[ 4010.836842] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 4010.836842] CR2: 000000000000006c CR3: 00000000c9fc8000 CR4: 0000000 0000007f0
[ 4010.836842] Stack:
[ 4010.836842]  ffffffff813a2f0b ffff88082fc03758 0000000000010496 fffffffffffefb6a
[ 4010.836842]  0000000000010a12 0000000000000066 ffff88080b1dcd00 0000000100001ee0 
[ 4010.836842]  ffffffffffffffda 00000000000104bc 000000260000057c ffff88080b1ddb00 
[ 4010.836842] Call Trace:
[ 4010.836842]  <IRQ>
[ 4010.836842]  [<ffffffff813a2f0b>] ? dev_queue_xmit+0xb/0x10
[ 4010.836842]  [<ffffffff8143c91d>] tcp_gso_segment+0x10d/0x3f0
[ 4010.836842]  [<ffffffff814ccf42>] ipv6_gso_segment+0x102/0x2c0
[ 4010.836842]  [<ffffffff813a22e3>] skb_mac_gso_segment+0x93/0x170
[ 4010.836842]  [<ffffffff8145adaf>] gre_gso_segment+0x12f/0x360
[ 4010.836842]  [<ffffffff8144c38d>] inet_gso_segment+0x12d/0x360
[ 4010.836842]  [<ffffffff813a22e3>] skb_mac_gso_segment+0x93/0x170
[ 4010.836842]  [<ffffffff813a241b>] __skb_gso_segment+0x5b/H0xc0
[ 4010.836842]  [<ffffffff813a273d>] dev_hard_start_xmit+0x17d/0x4d0
[ 4010.836842]  [<ffffffff813be290>] sch_direct_xmit+0xe0/0x1c0
[ 4010.836842]  [<ffffffff813be3f9>] __qdisc_run+0x89/0x150
[ 4010.836842]  [<ffffffff813a2d12>] __dev_queue_xmit+0x282/0x470
[ 4010.836842]  [<ffffffff813a2f0b>] dev_queue_xmit+0xb/0x10
[ 4010.836842]  [<ffffffff813aa832>] neigh_connected_output+0xb2/0xf0
[ 4010.836842]  [<ffffffff81419778>] ip_finish_output+0x1c8/0x400
[ 4010.836842]  [<ffffffff8141acd8>] ip_output+0x88/0x90
[ 4010.836842]  [<ffffffff81416cb6>] ip_forward_finish+0x86/0x1c0
[ 4010.836842]  [<ffffffff81417163>] ip_forward+0x373/0x440
[ 4010.836842]  [<ffffffff81414ea8>] ip_rcv_finish+0x78/0x340
[ 4010.836842]  [<ffffffff814157dc>] ip_rcv+0x2cc/0x3e0
[ 4010.836842]  [<ffffffff813a120e>] __netif_receive_skb_core+0x5be/0x7d0
[ 4010.836842]  [<ffffffff814cd162>] ? tcp6_gro_complete+0x62/0x70
[ 4010.836842]  [<ffffffff813a1438>] __netif_receive_skb+0x18/0x60
[ 4010.836842]  [<ffffffff813a14a8>] netif_receive_skb_internal+0x28/0x90
[ 4010.836842]  [<ffffffff813a15bc>] napi_gro_complete+0x9c/0xd0
[ 4010.836842]  [<ffffffff813a1ad6>] dev_gro_receive+0x296/0x440
[ 4010.836842]  [<ffffffff813a1d7d>] napi_gro_receive+0xd/0x80
[ 4010.836842]  [<ffffffff812f8c1c>] ixgbe_clean_rx_irq+0x62c/0x9e0
[ 4010.836842]  [<ffffffff812f9ec3>] ixgbe_poll+0x493/0x940
[ 4010.836842]  [<ffffffff8107fb8f>] ? __wake_up+0x3f/0x50
[ 4010.836842]  [<ffffffff813a179b>] net_rx_action+0xfb/0x1a0
[ 4010.836842]  [<ffffffff8104ec3c>] __do_softirq+0xdc/0x
[ 4010.836842]  [<ffffffff8104ef5d>] irq_exit+0x9d/0xb0
[ 4010.836842]  [<ffffffff81003e33>] do_IRQ+0x53/0xf0
[ 4010.836842]  [<ffffffff814fdd2a>] common_interrupt+0x6a/0x6a
[ 4010.836842]  <EOI>
[ 4010.836842]  [<ffffffff8100a526>] ? default_idle+0x6/0x10
[ 4010.836842]  [<ffffffff8100ac96>] arch_cpu_idle+0x16/0x20
[ 4010.836842]  [<ffffffff810863a1>] cpu_startup_entry+0x91/0x180
[ 4010.836842]  [<ffffffff814f1202>] rest_init+0x72/0x80
[ 4010.836842]  [<ffffffff81892da6>] start_kernel+0x340/0x34b
[ 4010.836842]  [<ffffffff8189286f>] ? repair_env_string+0x5c/0x5c
[ 4010.836842]  [<ffffffff818925ad>] x86_64_start_reservations+0x2a/0x2c
[ 4010.836842]  [<ffffffff81892676>] x86_64_start_kernel+0xc7/0xca
[ 4010.836842] Code: 4c 24 60 eb 21 0f 1f 80 00 00 00 00 41 83 c5 01 49 83 c4 10
[ 4010.836842] 48 83 c1 10 41 39 c3 0f 86 7b 01 00 00 41 89 c7 89 c2 45 39 e9 7f 37 <41> 8b 46
[ 4010.836842] 6c 41 39 46 68 0f 85 6d 03 00 00 45 8b a6 c4 00 00 00
[ 4010.836842] RIP  [<ffffffff813955df>] skb_segment+0x5df/0x980
[ 4010.836842]  RSP <ffff88082fc03730>
[ 4010.836842] CR2: 000000000000006c
[ 4010.836842] ---[ end trace ad63244a1b43b393 ]---
[ 4010.836842] Kernel panic - not syncing: Fatal exception in interrupt
[ 4010.836842] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
[ 4010.836842] Rebooting in 10 seconds..

Thanks,
Chris

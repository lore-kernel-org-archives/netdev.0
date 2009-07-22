From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: ixgbe: panic in ixgbe_clean_rx_irq()
Date: Wed, 22 Jul 2009 14:44:38 +0200
Message-ID: <1248266678.17215.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:55498 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794AbZGVMok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 08:44:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter,

Got a panic from the ixgbe driver on my 82599 based NICs, while running
two pktgen tests (1500 bytes packets) against the machine.

Kernel: 2.6.31-rc1-net-2.6-00122-ge594e96 with preemption

The panic occurs in ixgbe_clean_rx_irq+0x319/0x53b

Using objdump I can see that it seems to occur in an inlined function
ixgbe_transform_rsc_queue() in objdump "line" "2811:"
(ixgbe_clean_rx_irq starts 0x24f8 + 0x319 = 0x2811)

static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb)
{
        unsigned int frag_list_size = 0;

        while (skb->prev) {
    2811:       48 8b 7b 08             mov    0x8(%rbx),%rdi
    2815:       48 85 ff                test   %rdi,%rdi
    2818:       75 e9                   jne    2803 <ixgbe_clean_rx_irq+0x30b>
                frag_list_size += skb->len;
                skb->prev = NULL;
                skb = prev;
        }

        skb_shinfo(skb)->frag_list = skb->next;
    281a:       48 8b 03                mov    (%rbx),%rax
    281d:       8b 8b c8 00 00 00       mov    0xc8(%rbx),%ecx
    2823:       48 8b 93 d0 00 00 00    mov    0xd0(%rbx),%rdx
    282a:       48 89 44 0a 20          mov    %rax,0x20(%rdx,%rcx,1)
        skb->next = NULL;
    282f:       48 c7 03 00 00 00 00    movq   $0x0,(%rbx)
        skb->len += frag_list_size;
    2836:       01 73 60                add    %esi,0x60(%rbx)
        skb->data_len += frag_list_size;
    2839:       01 73 64                add    %esi,0x64(%rbx)
        skb->truesize += frag_list_size;
    283c:       01 b3 e0 00 00 00       add    %esi,0xe0(%rbx)
                }


Let me know if you want the objdump, its quite large.
-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer



root@firesoul:~# 
[ 9437.550709] general protection fault: 0000 [#1] PREEMPT SMP 
[ 9437.567818] last sysfs file: /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
[ 9437.590784] CPU 6 
[ 9437.596933] Modules linked in: asus_atk0110 ixgbe hwmon mdio r8169
[ 9437.615601] Pid: 0, comm: swapper Not tainted 2.6.31-rc1-net-2.6-00122-ge594e96 #8 System Product Name
[ 9437.643775] RIP: 0010:[<ffffffffa001a811>]  [<ffffffffa001a811>] ixgbe_clean_rx_irq+0x319/0x53b [ixgbe]
[ 9437.672232] RSP: 0018:ffff880001925dc0  EFLAGS: 00010202
[ 9437.688275] RAX: 0000000000000000 RBX: 0100000000000000 RCX: ffff8800b2974000
[ 9437.709794] RDX: ffffc90011db7d20 RSI: 00000000000005dc RDI: 0100000000000000
[ 9437.731310] RBP: ffff880001925e50 R08: ffff8800af797c00 R09: ffff880080000000
[ 9437.752825] R10: ffff8800af797548 R11: ffff880001925da0 R12: ffffc90011db7cf8
[ 9437.774341] R13: ffff88003766c640 R14: ffff8800ba8ea580 R15: 0000000040000073
[ 9437.795856] FS:  0000000000000000(0000) GS:ffff880001922000(0000) knlGS:0000000000000000
[ 9437.820385] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[ 9437.837724] CR2: 00007f54f87a1315 CR3: 0000000001001000 CR4: 00000000000006a0
[ 9437.859244] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 9437.880759] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 9437.902276] Process swapper (pid: 0, threadinfo ffff8800bef02000, task ffff8800beef1e00)
[ 9437.926803] Stack:
[ 9437.932942]  0000004001925de0 ffff880001925e6c ffff8800bb2cf500 ffff8800be572000
[ 9437.954743] <0> ffff8800b2976530 ffff8800b2976540 00000254ad917000 0000002a00000000
[ 9437.978016] <0> 000005dc00000002 000005b200000001 ffff8800bb2cf510 0000000000000254
[ 9438.001963] Call Trace:
[ 9438.009411]  <IRQ> 
[ 9438.015833]  [<ffffffffa001aa81>] ixgbe_clean_rxonly+0x4e/0xd2 [ixgbe]
[ 9438.035534]  [<ffffffff8138a7b5>] net_rx_action+0xb2/0x234
[ 9438.052099]  [<ffffffff8103fb35>] __do_softirq+0x10c/0x211
[ 9438.068668]  [<ffffffff8100cc2c>] call_softirq+0x1c/0x28
[ 9438.084717]  [<ffffffff8100de84>] do_softirq+0x34/0x72
[ 9438.100243]  [<ffffffff8103f83f>] irq_exit+0x36/0x85
[ 9438.115250]  [<ffffffff8100d75f>] do_IRQ+0xa6/0xbd
[ 9438.129738]  [<ffffffff8100c493>] ret_from_intr+0x0/0xa
[ 9438.145524]  <EOI> 
[ 9438.151946]  [<ffffffff81012355>] ? mwait_idle+0x89/0x9f
[ 9438.167991]  [<ffffffff81012348>] ? mwait_idle+0x7c/0x9f
[ 9438.187996]  [<ffffffff8142c948>] ? atomic_notifier_call_chain+0xf/0x11
[ 9438.207953]  [<ffffffff8100aedb>] ? cpu_idle+0x4f/0xb3
[ 9438.223479]  [<ffffffff81424478>] ? start_secondary+0x17f/0x184
[ 9438.241350] Code: 48 eb 09 48 6b 55 c8 28 49 03 55 08 41 f6 c7 02 74 60 31 f6 48 83 7b 08 00 75 10 eb 3f 03 73 60 48 c7 43 08 00
 00 00 00 48 89 fb <48> 8b 7b 08 48 85 ff 75 e9 48 8b 03 8b 8b c8 00 00 00 48 8b 93 
[ 9438.298386] RIP  [<ffffffffa001a811>] ixgbe_clean_rx_irq+0x319/0x53b [ixgbe]
[ 9438.319652]  RSP <ffff880001925dc0>
[ 9438.330593] ---[ end trace f60de63a65a43085 ]---
[ 9438.344593] Kernel panic - not syncing: Fatal exception in interrupt
[ 9438.363810] Pid: 0, comm: swapper Tainted: G      D    2.6.31-rc1-net-2.6-00122-ge594e96 #8
[ 9438.389159] Call Trace:
[ 9438.396655]  <IRQ>  [<ffffffff81427c6b>] panic+0xaa/0x155
[ 9438.413056]  [<ffffffff8103f88c>] ? irq_exit+0x83/0x85
[ 9438.428627]  [<ffffffff8100c493>] ? ret_from_intr+0x0/0xa
[ 9438.444975]  [<ffffffff8142b039>] ? oops_end+0x6b/0xba
[ 9438.460543]  [<ffffffff8142b078>] oops_end+0xaa/0xba
[ 9438.475589]  [<ffffffff8100f0d1>] die+0x55/0x5e
[ 9438.489332]  [<ffffffff8142ac8e>] do_general_protection+0x123/0x12b
[ 9438.508288]  [<ffffffff813b39ad>] ? ip_rcv+0x2a7/0x2de
[ 9438.523853]  [<ffffffff8142a5df>] general_protection+0x1f/0x30
[ 9438.541509]  [<ffffffffa001a811>] ? ixgbe_clean_rx_irq+0x319/0x53b [ixgbe]
[ 9438.562298]  [<ffffffffa001aa81>] ixgbe_clean_rxonly+0x4e/0xd2 [ixgbe]
[ 9438.582036]  [<ffffffff8138a7b5>] net_rx_action+0xb2/0x234
[ 9438.598641]  [<ffffffff8103fb35>] __do_softirq+0x10c/0x211
[ 9438.615250]  [<ffffffff8100cc2c>] call_softirq+0x1c/0x28
[ 9438.631337]  [<ffffffff8100de84>] do_softirq+0x34/0x72
[ 9438.646904]  [<ffffffff8103f83f>] irq_exit+0x36/0x85
[ 9438.661949]  [<ffffffff8100d75f>] do_IRQ+0xa6/0xbd
[ 9438.676476]  [<ffffffff8100c493>] ret_from_intr+0x0/0xa
[ 9438.692303]  <EOI>  [<ffffffff81012355>] ? mwait_idle+0x89/0x9f
[ 9438.710264]  [<ffffffff81012348>] ? mwait_idle+0x7c/0x9f
[ 9438.726354]  [<ffffffff8142c948>] ? atomic_notifier_call_chain+0xf/0x11
[ 9438.746348]  [<ffffffff8100aedb>] ? cpu_idle+0x4f/0xb3
[ 9438.761914]  [<ffffffff81424478>] ? start_secondary+0x17f/0x184



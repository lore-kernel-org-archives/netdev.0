From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: ixgbe: panic in ixgbe_clean_rx_irq()
Date: Thu, 23 Jul 2009 10:46:19 +0200
Message-ID: <1248338779.17215.23.camel@localhost.localdomain>
References: <1248266678.17215.15.camel@localhost.localdomain>
	 <Pine.WNT.4.64.0907221110550.9360@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:54500 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbZGWIqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 04:46:21 -0400
In-Reply-To: <Pine.WNT.4.64.0907221110550.9360@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-22 at 11:13 -0700, Waskiewicz Jr, Peter P wrote:
> On Wed, 22 Jul 2009, Jesper Dangaard Brouer wrote:
> 
> > Hi Peter,
> > 
> > Got a panic from the ixgbe driver on my 82599 based NICs, while running
> > two pktgen tests (1500 bytes packets) against the machine.
> > 
> > Kernel: 2.6.31-rc1-net-2.6-00122-ge594e96 with preemption

Got a new panic.  The strange thing its not happening in the same
place... and the anoying thing is that its hard to reproduce, as I have
to run pktgen a very long time before it dies.

I'm starting to suspect it could be related to CPU freq scaling, as the
last sysfs file is /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
and the call stack originates from mwait_idle().


[27925.077996] general protection fault: 0000 [#1] PREEMPT SMP 
[27925.095080] last sysfs file: /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
[27925.118042] CPU 7 
[27925.124196] Modules linked in: asus_atk0110 ixgbe hwmon mdio r8169
[27925.142863] Pid: 0, comm: swapper Not tainted 2.6.31-rc1-net-2.6-00122-ge594e96 #8 System Product Name
[27925.171033] RIP: 0010:[<ffffffff81382b29>]  [<ffffffff81382b29>] skb_release_head_state+0x69/0xba
[27925.197904] RSP: 0018:ffff880001942d70  EFLAGS: 00010286
[27925.213938] RAX: 0000000000000000 RBX: ffff8800b0022100 RCX: 0000000000000400
[27925.235443] RDX: 00000000000003d6 RSI: 00000000b9c03000 RDI: d100000000000000
[27925.256958] RBP: ffff880001942d80 R08: 00000000000002a3 R09: ffffc90011e6a428
[27925.278474] R10: 0000000101a5abfb R11: ffffffff813828c5 R12: ffff8800bac7c580
[27925.299990] R13: 0000000000002a40 R14: 00000000000002a5 R15: 00000000000002a4
[27925.321504] FS:  0000000000000000(0000) GS:ffff88000193f000(0000) knlGS:0000000000000000
[27925.346030] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[27925.363373] CR2: 00007fecde5734a8 CR3: 00000000a5015000 CR4: 00000000000006a0
[27925.384878] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[27925.406380] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[27925.427884] Process swapper (pid: 0, threadinfo ffff8800bef0c000, task ffff8800beef3480)
[27925.452409] Stack:
[27925.458553]  00000000000002a3 ffff8800b0022100 ffff880001942da0 ffffffff81382854
[27925.480328] <0> ffffc90011e6a428 ffffc900119ee480 ffff880001942db0 ffffffff813828f5
[27925.503588] <0> ffff880001942dc0 ffffffff8138b441 ffff880001942de0 ffffffffa001ab3e
[27925.527521] Call Trace:
[27925.534971]  <IRQ> 
[27925.541385]  [<ffffffff81382854>] __kfree_skb+0x11/0x87
[27925.557169]  [<ffffffff813828f5>] consume_skb+0x2b/0x2d
[27925.572943]  [<ffffffff8138b441>] dev_kfree_skb_any+0x2e/0x30
[27925.590287]  [<ffffffffa001ab3e>] ixgbe_unmap_and_free_tx_resource+0x39/0x4c [ixgbe]
[27925.613772]  [<ffffffffa001acb5>] ixgbe_clean_tx_irq+0xcf/0x366 [ixgbe]
[27925.633721]  [<ffffffffa001af88>] ixgbe_clean_txonly+0x3c/0xbd [ixgbe]
[27925.653410]  [<ffffffff8138a7b5>] net_rx_action+0xb2/0x234
[27925.669966]  [<ffffffff8103fb35>] __do_softirq+0x10c/0x211
[27925.686521]  [<ffffffff8100cc2c>] call_softirq+0x1c/0x28
[27925.702556]  [<ffffffff8100de84>] do_softirq+0x34/0x72
[27925.718070]  [<ffffffff8103f83f>] irq_exit+0x36/0x85
[27925.733065]  [<ffffffff8100d75f>] do_IRQ+0xa6/0xbd
[27925.747540]  [<ffffffff8100c493>] ret_from_intr+0x0/0xa
[27925.767191]  <EOI> 
[27925.773603]  [<ffffffff81012355>] ? mwait_idle+0x89/0x9f
[27925.789646]  [<ffffffff81012348>] ? mwait_idle+0x7c/0x9f
[27925.805682]  [<ffffffff8142c948>] ? atomic_notifier_call_chain+0xf/0x11
[27925.825624]  [<ffffffff8100aedb>] ? cpu_idle+0x4f/0xb3
[27925.841137]  [<ffffffff81424478>] ? start_secondary+0x17f/0x184
[27925.858994] Code: 00 ff 03 74 11 be 8e 01 00 00 48 c7 c7 fc d3 5f 81 e8 7f 79 cb ff 48 89 df ff 93 80 00 00 00 48 8b bb 88 00 00
 00 48 85 ff 74 0f <f0> ff 0f 0f 94 c0 84 c0 74 05 e8 68 1f 02 00 48 8b bb 90 00 00 
[27925.915956] RIP  [<ffffffff81382b29>] skb_release_head_state+0x69/0xba
[27925.935656]  RSP <ffff880001942d70>
[27925.946574] ---[ end trace acd86b5373a70766 ]---
[27925.960578] Kernel panic - not syncing: Fatal exception in interrupt
[27925.979798] Pid: 0, comm: swapper Tainted: G      D    2.6.31-rc1-net-2.6-00122-ge594e96 #8
[27926.005157] Call Trace:
[27926.012654]  <IRQ>  [<ffffffff81427c6b>] panic+0xaa/0x155
[27926.029070]  [<ffffffff8103f88c>] ? irq_exit+0x83/0x85
[27926.044644]  [<ffffffff8100c493>] ? ret_from_intr+0x0/0xa
[27926.061002]  [<ffffffff8142b039>] ? oops_end+0x6b/0xba
[27926.076571]  [<ffffffff8142b078>] oops_end+0xaa/0xba
[27926.091628]  [<ffffffff8100f0d1>] die+0x55/0x5e
[27926.105374]  [<ffffffff8142ac8e>] do_general_protection+0x123/0x12b
[27926.124324]  [<ffffffff8142a1af>] ? _spin_unlock+0x2a/0x35
[27926.140936]  [<ffffffff8142a5df>] general_protection+0x1f/0x30
[27926.158595]  [<ffffffff813828c5>] ? __kfree_skb+0x82/0x87
[27926.174946]  [<ffffffff81382b29>] ? skb_release_head_state+0x69/0xba
[27926.194169]  [<ffffffff81382854>] __kfree_skb+0x11/0x87
[27926.210008]  [<ffffffff813828f5>] consume_skb+0x2b/0x2d
[27926.225834]  [<ffffffff8138b441>] dev_kfree_skb_any+0x2e/0x30
[27926.243231]  [<ffffffffa001ab3e>] ixgbe_unmap_and_free_tx_resource+0x39/0x4c [ixgbe]
[27926.266772]  [<ffffffffa001acb5>] ixgbe_clean_tx_irq+0xcf/0x366 [ixgbe]
[27926.286785]  [<ffffffffa001af88>] ixgbe_clean_txonly+0x3c/0xbd [ixgbe]
[27926.306524]  [<ffffffff8138a7b5>] net_rx_action+0xb2/0x234
[27926.323147]  [<ffffffff8103fb35>] __do_softirq+0x10c/0x211
[27926.339765]  [<ffffffff8100cc2c>] call_softirq+0x1c/0x28
[27926.355853]  [<ffffffff8100de84>] do_softirq+0x34/0x72
[27926.371417]  [<ffffffff8103f83f>] irq_exit+0x36/0x85
[27926.386466]  [<ffffffff8100d75f>] do_IRQ+0xa6/0xbd
[27926.400990]  [<ffffffff8100c493>] ret_from_intr+0x0/0xa
[27926.416819]  <EOI>  [<ffffffff81012355>] ? mwait_idle+0x89/0x9f
[27926.434794]  [<ffffffff81012348>] ? mwait_idle+0x7c/0x9f
[27926.450881]  [<ffffffff8142c948>] ? atomic_notifier_call_chain+0xf/0x11
[27926.470877]  [<ffffffff8100aedb>] ? cpu_idle+0x4f/0xb3
[27926.486454]  [<ffffffff81424478>] ? start_secondary+0x17f/0x184

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


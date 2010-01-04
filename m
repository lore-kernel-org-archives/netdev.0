From: Ben Greear <greearb@candelatech.com>
Subject: ixgbe NULLL pointer dereference on OOM condition, 2.6.31.7
Date: Mon, 04 Jan 2010 11:57:25 -0800
Message-ID: <4B424825.2070608@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48252 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909Ab0ADT51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 14:57:27 -0500
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o04JvQF0012915
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2010 11:57:26 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is on a hacked 2.6.31.7 kernel.  I'm testing an application that creates
30,000+ TCP connections (to self).  The system is 64-bit with 12GB of RAM, but
it can still run out of usable RAM (say, when I start another 10k connections
to bring it up to 40k).

It looks like something in ixgbe isn't properly checking for inability
to allocate (or to have previously allocated) an skb, or perhaps some other
chunk of memory:

[root@ct503-10G-09 ~]# BUG: unable to handle kernel NULL pointer dereference at 00000000000000e8
IP: [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
PGD 0
Oops: 0000 [#1] PREEMPT SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1/stat
CPU 6
Modules linked in: 8021q garp stp llc veth fuse arc4 michael_mic macvlan wanlink(P) pktgen sunrpc ipv6 dm_multipath uinput ixg]
Pid: 33, comm: events/6 Tainted: P           2.6.31.7 #11 X8STi
RIP: 0010:[<ffffffffa0054ca0>]  [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
RSP: 0018:ffff8800280e5dc0  EFLAGS: 00010287
RAX: ffff88030a838000 RBX: 0000000000000000 RCX: ffff88030a838000
RDX: ffff8800280e5e64 RSI: 0000000000000000 RDI: ffff88032e9330c0
RBP: ffff8800280e5e40 R08: 000000000000004e R09: ffff88032e933680
R10: ffff88033fc08000 R11: 0000000000000080 R12: ffffc90014dd9000
R13: ffff88033043d1e0 R14: ffff88032dcd05c0 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8800280e2000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000000000e8 CR3: 0000000001001000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process events/6 (pid: 33, threadinfo ffff880332594000, task ffff880332573720)
Stack:
  000000000000002b 000000402490b420 ffff8800280e5e64 ffff88032e9330c0
<0> ffff880332744800 ffff88030a838000 000000000000002b 0000006300000000
<0> 0000000000000000 0000000000000000 ffff8800280e5e30 ffff88033043d1e0
Call Trace:
  <IRQ>
  [<ffffffffa00575c8>] ixgbe_clean_rxonly+0x6b/0xbd [ixgbe]
  [<ffffffff8135aa1e>] net_rx_action+0xd0/0x248
  [<ffffffffa0054569>] ? napi_schedule+0x1d/0x22 [ixgbe]
  [<ffffffff81056772>] __do_softirq+0x10e/0x21a
  [<ffffffff81096912>] ? handle_IRQ_event+0xa2/0x1a5
  [<ffffffff81012ddc>] call_softirq+0x1c/0x30
  [<ffffffff81014533>] do_softirq+0x42/0x8b
  [<ffffffff810565b2>] irq_exit+0x3f/0x94
  [<ffffffff810142cd>] do_IRQ+0x94/0xab
  [<ffffffff810125d3>] ret_from_intr+0x0/0x11
  <EOI>
  [<ffffffffa0059523>] ? ixgbe_disable_pcie_master+0x80/0xa9 [ixgbe]
  [<ffffffffa005ff89>] ? ixgbe_reset_hw_82599+0x63/0x19f [ixgbe]
  [<ffffffffa0059063>] ? ixgbe_init_hw_generic+0xf/0x1d [ixgbe]
  [<ffffffffa00530c3>] ? ixgbe_reset+0x1e/0xef [ixgbe]
  [<ffffffffa005657c>] ? ixgbe_down+0x1e6/0x24f [ixgbe]
  [<ffffffffa0057a13>] ? ixgbe_reset_task+0x0/0x24 [ixgbe]
  [<ffffffffa0057549>] ? ixgbe_reinit_locked+0x57/0x6b [ixgbe]
  [<ffffffffa0057a35>] ? ixgbe_reset_task+0x22/0x24 [ixgbe]
  [<ffffffff81063045>] ? worker_thread+0x19a/0x244
  [<ffffffff81066d5b>] ? autoremove_wake_function+0x0/0x38
  [<ffffffff81062eab>] ? worker_thread+0x0/0x244
  [<ffffffff81066ae4>] ? kthread+0x7b/0x83
  [<ffffffff81012cda>] ? child_rip+0xa/0x20
  [<ffffffff81066a69>] ? kthread+0x0/0x83
  [<ffffffff81012cd0>] ? child_rip+0x0/0x20
Code: f8 05 3d 00 01 00 00 44 0f 46 c0 48 8b 45 a8 44 0f b7 78 0c eb 0c 48 8b 55 a8 45 31 ff 44 0f b7 42 0c 49 8b 1c 24 49 8b
RIP  [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
  RSP <ffff8800280e5dc0>
CR2: 00000000000000e8
BUG: unable to handle kernel
---[ end trace db48be5c67f6f225 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 33, comm: events/6 Tainted: P      D    2.6.31.7 #11
Call Trace:
  <IRQ>  [<ffffffff81050a4b>] panic+0xaf/0x16e
  [<ffffffff810127a3>] ? apic_timer_interrupt+0x13/0x20
  [<ffffffff8105072e>] ? print_oops_end_marker+0x1e/0x20
  [<ffffffff813fb588>] oops_end+0xb1/0xc1
  [<ffffffff810339c6>] no_context+0x1ef/0x1fe
  [<ffffffff81033c0d>] __bad_area_nosemaphore+0x17e/0x1a1
  [<ffffffff81096912>] ? handle_IRQ_event+0xa2/0x1a5
  [<ffffffff81033ca6>] bad_area_nosemaphore+0xe/0x10
  [<ffffffff813fc9f2>] do_page_fault+0x157/0x275
  [<ffffffff813faac5>] page_fault+0x25/0x30
  [<ffffffffa0054ca0>] ? ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
  [<ffffffffa00575c8>] ixgbe_clean_rxonly+0x6b/0xbd [ixgbe]
  [<ffffffff8135aa1e>] net_rx_action+0xd0/0x248
  [<ffffffffa0054569>] ? napi_schedule+0x1d/0x22 [ixgbe]
  [<ffffffff81056772>] __do_softirq+0x10e/0x21a
  [<ffffffff81096912>] ? handle_IRQ_event+0xa2/0x1a5
  [<ffffffff81012ddc>] call_softirq+0x1c/0x30
  [<ffffffff81014533>] do_softirq+0x42/0x8b
  [<ffffffff810565b2>] irq_exit+0x3f/0x94
  [<ffffffff810142cd>] do_IRQ+0x94/0xab
  [<ffffffff810125d3>] ret_from_intr+0x0/0x11
  <EOI>  [<ffffffffa0059523>] ? ixgbe_disable_pcie_master+0x80/0xa9 [ixgbe]
  [<ffffffffa005ff89>] ? ixgbe_reset_hw_82599+0x63/0x19f [ixgbe]
  [<ffffffffa0059063>] ? ixgbe_init_hw_generic+0xf/0x1d [ixgbe]
  [<ffffffffa00530c3>] ? ixgbe_reset+0x1e/0xef [ixgbe]
  [<ffffffffa005657c>] ? ixgbe_down+0x1e6/0x24f [ixgbe]
  [<ffffffffa0057a13>] ? ixgbe_reset_task+0x0/0x24 [ixgbe]
  [<ffffffffa0057549>] ? ixgbe_reinit_locked+0x57/0x6b [ixgbe]
  [<ffffffffa0057a35>] ? ixgbe_reset_task+0x22/0x24 [ixgbe]
  [<ffffffff81063045>] ? worker_thread+0x19a/0x244
  [<ffffffff81066d5b>] ? autoremove_wake_function+0x0/0x38
  [<ffffffff81062eab>] ? worker_thread+0x0/0x244
  [<ffffffff81066ae4>] ? kthread+0x7b/0x83
  [<ffffffff81012cda>] ? child_rip+0xa/0x20
  [<ffffffff81066a69>] ? kthread+0x0/0x83
  [<ffffffff81012cd0>] ? child_rip+0x0/0x20
NULL pointer dereference at 00000000000000e8
IP: [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
PGD 0
Oops: 0000 [#2] PREEMPT SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1/stat
CPU 2
Modules linked in: 8021q garp stp llc veth fuse arc4 michael_mic macvlan wanlink(P) pktgen sunrpc ipv6 dm_multipath uinput ixg]
Pid: 0, comm: swapper Tainted: P      D    2.6.31.7 #11 X8STi
RIP: 0010:[<ffffffffa0054ca0>]  [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
RSP: 0000:ffff880028071dc0  EFLAGS: 00010287
RAX: ffff88030a8c4000 RBX: 0000000000000000 RCX: ffff88030a8c4000
RDX: ffff880028071e64 RSI: 0000000000000000 RDI: ffff88032e933540
RBP: ffff880028071e40 R08: 000000000000004e R09: ffff88032e933430
R10: ffff88033fc08000 R11: ffff880028071f58 R12: ffffc90014de5000
R13: ffff88033043d240 R14: ffff88032dcd05c0 R15: 000000000000059c
FS:  0000000000000000(0000) GS:ffff88002806e000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000000000e8 CR3: 0000000001001000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff8803324fc000, task ffff8803324c5e80)
Stack:
  0000000000000023 000000402490b3c0 ffff880028071e64 ffff88032e933540
<0> ffff880332744800 ffff88030a8c4000 0000000000000023 0000006300000000
<0> 0000000000000000 0000000000000000 ffff880028071e30 ffff88033043d240
Call Trace:
  <IRQ>
  [<ffffffffa00575c8>] ixgbe_clean_rxonly+0x6b/0xbd [ixgbe]
  [<ffffffff8135aa1e>] net_rx_action+0xd0/0x248
  [<ffffffffa0054569>] ? napi_schedule+0x1d/0x22 [ixgbe]
  [<ffffffff81056772>] __do_softirq+0x10e/0x21a
  [<ffffffff81096912>] ? handle_IRQ_event+0xa2/0x1a5
  [<ffffffff81012ddc>] call_softirq+0x1c/0x30
  [<ffffffff81014533>] do_softirq+0x42/0x8b
  [<ffffffff810565b2>] irq_exit+0x3f/0x94
  [<ffffffff810142cd>] do_IRQ+0x94/0xab
  [<ffffffff810125d3>] ret_from_intr+0x0/0x11
  <EOI>
  [<ffffffff81254bde>] ? acpi_idle_enter_simple+0xe6/0x117
  [<ffffffff81254bd7>] ? acpi_idle_enter_simple+0xdf/0x117
  [<ffffffff81254cdc>] ? acpi_idle_enter_bm+0xcd/0x251
  [<ffffffff813304bf>] ? cpuidle_idle_call+0x7c/0xb5
  [<ffffffff81010d6c>] ? cpu_idle+0x58/0xa8
  [<ffffffff813f48d4>] ? start_secondary+0x1a2/0x1a7
Code: f8 05 3d 00 01 00 00 44 0f 46 c0 48 8b 45 a8 44 0f b7 78 0c eb 0c 48 8b 55 a8 45 31 ff 44 0f b7 42 0c 49 8b 1c 24 49 8b
RIP  [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
  RSP <ffff880028071dc0>
CR2: 00000000000000e8
BUG: unable to handle kernel NULL pointer dereference at 00000000000000e8
IP: [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
PGD 0
Oops: 0000 [#3] PREEMPT SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1/stat
CPU 1
Modules linked in: 8021q garp stp llc veth fuse arc4 michael_mic macvlan wanlink(P) pktgen sunrpc ipv6 dm_multipath uinput ixg]
Pid: 0, comm: swapper Tainted: P      D    2.6.31.7 #11 X8STi
RIP: 0010:[<ffffffffa0054ca0>]  [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
RSP: 0018:ffff880028054dc0  EFLAGS: 00010287
RAX: ffff88030a864000 RBX: 0000000000000000 RCX: ffff88030a864000
RDX: ffff880028054e64 RSI: 0000000000000000 RDI: ffff88032e933300
RBP: ffff880028054e40 R08: 000000000000004e R09: ffff88032e933070
R10: 0000000000000002 R11: ffffffff81387046 R12: ffffc90014df1000
R13: ffff88033043d2a0 R14: ffff88032dcd05c0 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff880028051000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000000000e8 CR3: 0000000001001000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff8803324f0000, task ffff8803324c3f00)
Stack:
  ffffffff816988a0 000000402e933000 ffff880028054e64 ffff88032e933300
<0> ffff880332744800 ffff88030a864000 0000000028054e40 0000006300000000
<0> 0000000000000000 0000000000000000 ffff88032e933070 ffff88033043d2a0
Call Trace:
  <IRQ>
  [<ffffffffa00575c8>] ixgbe_clean_rxonly+0x6b/0xbd [ixgbe]
  [<ffffffff8135aa1e>] net_rx_action+0xd0/0x248
  [<ffffffffa0054569>] ? napi_schedule+0x1d/0x22 [ixgbe]
  [<ffffffff81056772>] __do_softirq+0x10e/0x21a
  [<ffffffff81096912>] ? handle_IRQ_event+0xa2/0x1a5
  [<ffffffff81012ddc>] call_softirq+0x1c/0x30
  [<ffffffff81014533>] do_softirq+0x42/0x8b
  [<ffffffff810565b2>] irq_exit+0x3f/0x94
  [<ffffffff810142cd>] do_IRQ+0x94/0xab
  [<ffffffff810125d3>] ret_from_intr+0x0/0x11
  <EOI>
  [<ffffffff81254bde>] ? acpi_idle_enter_simple+0xe6/0x117
  [<ffffffff81254bd7>] ? acpi_idle_enter_simple+0xdf/0x117
  [<ffffffff81254cdc>] ? acpi_idle_enter_bm+0xcd/0x251
  [<ffffffff813304bf>] ? cpuidle_idle_call+0x7c/0xb5
  [<ffffffff81010d6c>] ? cpu_idle+0x58/0xa8
  [<ffffffff813f48d4>] ? start_secondary+0x1a2/0x1a7
Code: f8 05 3d 00 01 00 00 44 0f 46 c0 48 8b 45 a8 44 0f b7 78 0c eb 0c 48 8b 55 a8 45 31 ff 44 0f b7 42 0c 49 8b 1c 24 49 8b
RIP  [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
  RSP <ffff880028054dc0>
CR2: 00000000000000e8

  CTRL-A Z for help | 38400 8N1 | NOR | Minicom 2.1    | VT102 | Online 00:17

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


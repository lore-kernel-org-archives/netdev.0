From: Laurent Riffard <laurent.riffard@free.fr>
Subject: [BUG] netconsole broken by scheduler updates
Date: Thu, 26 May 2011 11:21:01 +0200
Message-ID: <4DDE1B7D.7080707@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:38696 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757229Ab1EZJbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 05:31:35 -0400
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr [212.27.42.2])
	by smtpfb1-g21.free.fr (Postfix) with ESMTP id 179612CB08
	for <netdev@vger.kernel.org>; Thu, 26 May 2011 11:21:39 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Recently, netconsole was broken by some scheduler updates. Kernel hangs 
on boot near the network card initialization. I noticed that it does 
hang just where a "inconsistent lock state" message normally appears.

I did a bisection : e4a52bcb9a18142d79e231b6733cabdbf2e67c1f is the 
first bad commit.
commit e4a52bcb9a18142d79e231b6733cabdbf2e67c1f
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date:   Tue Apr 5 17:23:54 2011 +0200

    sched: Remove rq->lock from the first half of ttwu()


Before this commit, kernel was booting succesfully despite the 
"inconsistent lock state" message. After this commit, the kernel does 
hang on boot, I have to push the reset button.


Here are some lines from dmesg :

Initializing cgroup subsys cpu
Linux version 2.6.39-rc3-00102-g8f42ced (laurent@calimero) (gcc version 4.5.2 (Ubuntu/Linaro 4.5.2-8ubuntu4) ) #137 SMP PREEMPT Wed May 25 10:09:13 CEST 2011
Command line: BOOT_IMAGE=/vmlinuz-2.6.39-rc3-00102-g8f42ced root=/dev/mapper/vglinux1-lv_ubuntu_64bits ro debug netconsole=4444@192.168.0.9/eth0,6666@192.168.
0.10/6C:62:6D:48:4B:C7 splash vt.handoff=7
[....]
Linux agpgart interface v0.103
forcedeth: Reverse Engineered nForce ethernet driver. Version 0.64.
ACPI: PCI Interrupt Link [APCH] enabled at IRQ 23
forcedeth 0000:00:0a.0: PCI INT A -> Link[APCH] -> GSI 23 (level, low) -> IRQ 23
forcedeth 0000:00:0a.0: setting latency timer to 64
forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x732 @ 1, addr 00:1f:d0:53:49:ae
forcedeth 0000:00:0a.0: highdma pwrctl mgmt gbit lnktim msi desc-v3
netconsole: local port 4444
netconsole: local IP 192.168.0.9
netconsole: interface 'eth0'
netconsole: remote port 6666
netconsole: remote IP 192.168.0.10
netconsole: remote ethernet address 6c:62:6d:48:4b:c7
netconsole: device eth0 not up yet, forcing it
forcedeth 0000:00:0a.0: irq 40 for MSI/MSI-X
forcedeth 0000:00:0a.0: eth0: no link during initialization
forcedeth 0000:00:0a.0: eth0: link up
                                       <============== kernel does hang here
=================================
[ INFO: inconsistent lock state ]
2.6.39-rc3-00102-g8f42ced #137
---------------------------------
inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
swapper/1 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (&(&napi->poll_lock)->rlock){+.?...}, at: [<ffffffff812385a5>] netpoll_poll_dev+0x9e/0x4f1
{IN-SOFTIRQ-W} state was registered at:
  [<ffffffff81066607>] __lock_acquire+0x319/0xd62
  [<ffffffff8106750e>] lock_acquire+0xd7/0x102
  [<ffffffff81295a81>] _raw_spin_lock+0x36/0x45
  [<ffffffff81227a13>] net_rx_action+0x8d/0x1e6
  [<ffffffff810409b9>] __do_softirq+0xe0/0x1be
  [<ffffffff81297e1c>] call_softirq+0x1c/0x30
  [<ffffffff810042de>] do_softirq+0x46/0x9c
  [<ffffffff81040d0a>] irq_exit+0x4d/0xa2
  [<ffffffff81003f92>] do_IRQ+0x88/0x9f
  [<ffffffff81296613>] ret_from_intr+0x0/0x1a
  [<ffffffff810094b2>] default_idle+0x40/0x74
  [<ffffffff810095ca>] c1e_idle+0xe4/0xe6
  [<ffffffff81001270>] cpu_idle+0x5e/0x94
  [<ffffffff8129018d>] start_secondary+0x18a/0x18f
irq event stamp: 1010077
hardirqs last  enabled at (1010077): [<ffffffff81296086>] _raw_spin_unlock_irqrestore+0x40/0x75
hardirqs last disabled at (1010076): [<ffffffff81295b54>] _raw_spin_lock_irqsave+0x1a/0x57
softirqs last  enabled at (1008710): [<ffffffff8122cf91>] __dev_mc_add+0x5d/0x6b
softirqs last disabled at (1008704): [<ffffffff81295bdf>] _raw_spin_lock_bh+0x11/0x4a

other info that might help us debug this:
1 lock held by swapper/1:
 #0:  (target_list_lock){+.+...}, at: [<ffffffff811e258a>] write_msg+0x34/0xd2

stack backtrace:
Pid: 1, comm: swapper Not tainted 2.6.39-rc3-00102-g8f42ced #137
Call Trace:
 [<ffffffff81066104>] valid_state+0x17e/0x190
 [<ffffffff81065a4c>] ? check_usage_forwards+0x85/0x85
 [<ffffffff810661f8>] mark_lock+0xe2/0x1d8
 [<ffffffff81066685>] __lock_acquire+0x397/0xd62
 [<ffffffff8115e0b5>] ? pci_bus_write_config_dword+0x5e/0x6a
 [<ffffffff81296086>] ? _raw_spin_unlock_irqrestore+0x40/0x75
 [<ffffffff8106792a>] ? trace_hardirqs_on_caller+0x10b/0x12f
 [<ffffffff812385a5>] ? netpoll_poll_dev+0x9e/0x4f1
 [<ffffffff8106750e>] lock_acquire+0xd7/0x102
 [<ffffffff812385a5>] ? netpoll_poll_dev+0x9e/0x4f1
 [<ffffffff81295fbf>] _raw_spin_trylock+0x4a/0x7f
 [<ffffffff812385a5>] ? netpoll_poll_dev+0x9e/0x4f1
 [<ffffffff812385a5>] netpoll_poll_dev+0x9e/0x4f1
 [<ffffffff81238b95>] netpoll_send_skb_on_dev+0x112/0x216
 [<ffffffff81238e84>] netpoll_send_udp+0x1eb/0x1fa
 [<ffffffff811e258a>] ? write_msg+0x34/0xd2
 [<ffffffff811e25e2>] write_msg+0x8c/0xd2
 [<ffffffff8103b215>] __call_console_drivers+0x72/0x84
 [<ffffffff8103b280>] _call_console_drivers+0x59/0x5e
 [<ffffffff8103babb>] console_unlock+0xf3/0x1ac
 [<ffffffff8103c30f>] register_console+0x228/0x2b3
 [<ffffffff816a71ec>] init_netconsole+0x15d/0x1e4
 [<ffffffff8116379b>] ? __pci_register_driver+0x9b/0xcd
 [<ffffffff816a708f>] ? option_setup+0x1f/0x1f
 [<ffffffff8100030f>] do_one_initcall+0x7a/0x137
 [<ffffffff81685be1>] kernel_init+0xb0/0x130
 [<ffffffff811553ce>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff81297d24>] kernel_thread_helper+0x4/0x10
 [<ffffffff812966d8>] ? retint_restore_args+0x13/0x13
 [<ffffffff81685b31>] ? start_kernel+0x379/0x379
 [<ffffffff81297d20>] ? gs_change+0x13/0x13
------------[ cut here ]------------
WARNING: at net/core/netpoll.c:346 netpoll_send_skb_on_dev+0x15f/0x216()
Hardware name: M68SM-S2L
netpoll_send_skb(): eth0 enabled interrupts in poll (nv_start_xmit_optimized+0x0/0x487)
Modules linked in:
Pid: 1, comm: swapper Not tainted 2.6.39-rc3-00102-g8f42ced #137
Call Trace:
 [<ffffffff8103ae08>] warn_slowpath_common+0x80/0x98
 [<ffffffff8103aeb4>] warn_slowpath_fmt+0x41/0x43
 [<ffffffff811e1fa9>] ? nv_start_xmit+0x3df/0x3df
 [<ffffffff81238be2>] netpoll_send_skb_on_dev+0x15f/0x216
 [<ffffffff81238e84>] netpoll_send_udp+0x1eb/0x1fa
 [<ffffffff811e258a>] ? write_msg+0x34/0xd2
 [<ffffffff811e25e2>] write_msg+0x8c/0xd2
 [<ffffffff8103b215>] __call_console_drivers+0x72/0x84
 [<ffffffff8103b280>] _call_console_drivers+0x59/0x5e
 [<ffffffff8103babb>] console_unlock+0xf3/0x1ac
 [<ffffffff8103c30f>] register_console+0x228/0x2b3
 [<ffffffff816a71ec>] init_netconsole+0x15d/0x1e4
 [<ffffffff8116379b>] ? __pci_register_driver+0x9b/0xcd
 [<ffffffff816a708f>] ? option_setup+0x1f/0x1f
 [<ffffffff8100030f>] do_one_initcall+0x7a/0x137
 [<ffffffff81685be1>] kernel_init+0xb0/0x130
 [<ffffffff811553ce>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff81297d24>] kernel_thread_helper+0x4/0x10
 [<ffffffff812966d8>] ? retint_restore_args+0x13/0x13
 [<ffffffff81685b31>] ? start_kernel+0x379/0x379
 [<ffffffff81297d20>] ? gs_change+0x13/0x13
---[ end trace 2b8ff4190d73b338 ]---
console [netcon0] enabled
netconsole: network logging started


~~
laurent

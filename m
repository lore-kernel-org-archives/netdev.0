From: Daniel Petre <daniel.petre@rcs-rds.ro>
Subject: kernel panic on interface flap
Date: Tue, 21 May 2013 13:58:43 +0300
Message-ID: <519B5363.6080602@rcs-rds.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailproxy.rcs-rds.ro ([212.54.120.14]:35019 "EHLO
	mailproxy.rcs-rds.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722Ab3EULEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 07:04:44 -0400
Received: from [10.175.129.196] (unknown [10.175.129.196])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mailproxy.rcs-rds.ro (Postfix) with ESMTPSA id 8E631FD55
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 13:58:18 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
i was recommended by a nice #kernelnewbies user to post here so please
excuse me if i miss something.

We have a debian squeeze up-to-date box running kernel 3.8.13, intel
e1000e and tg3 broadcom interfaces, dual stack, quagga and few gre
tunnels on a interface.

lspci | grep ther
02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5722
Gigabit Ethernet PCI Express
03:01.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5703
Gigabit Ethernet (rev 10)
04:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
Controller (rev 06)
04:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
Controller (rev 06)

If we flap the interface (with gre tunnels and mtu 1524) the kernel will
panic..

grep eth /proc/interrupts
 43:   30350945   30366854   PCI-MSI-edge      eth2
 44:   28313912   28297869   PCI-MSI-edge      eth3
 45:      24375      24505   PCI-MSI-edge      eth0

cat /proc/irq/{43,44}/smp_affinity
3
3

[ 1877.880126] e1000e: eth3 NIC Link is Down
[ 1877.880169] e1000e 0000:04:00.1 eth3: Reset adapter
[ 1885.092326] Kernel panic - not syncing: stack-protector: Kernel stack
is corrupted in: ffffffff814d5fec

[ 1885.092390] Pid: 0, comm: swapper/1 Not tainted 3.8.13 #3
[ 1885.092414] Call Trace:
[ 1885.092437]  <IRQ>  [<ffffffff8154001f>] ? panic+0xbf/0x1c9
[ 1885.092470]  [<ffffffff814d5fec>] ? icmp_send+0x6bc/0x730
[ 1885.092495]  [<ffffffff81037f77>] ? __stack_chk_fail+0x17/0x30
[ 1885.092519]  [<ffffffff814d5fec>] ? icmp_send+0x6bc/0x730
[ 1885.092543]  [<ffffffff814e10f6>] ? fib_table_lookup+0x296/0x2f0
[ 1885.092569]  [<ffffffff8106b23c>] ? ktime_get+0x4c/0xe0
[ 1885.092592]  [<ffffffff814e10f6>] ? fib_table_lookup+0x296/0x2f0
[ 1885.092617]  [<ffffffff815428f9>] ? _raw_spin_lock_bh+0x9/0x30
[ 1885.092642]  [<ffffffff814a2598>] ? update_or_create_fnhe+0x28/0x160
[ 1885.092668]  [<ffffffff8146e032>] ? dev_hard_start_xmit+0x102/0x490
[ 1885.092694]  [<ffffffff81487d66>] ? sch_direct_xmit+0x106/0x1e0
[ 1885.092718]  [<ffffffff81487efd>] ? __qdisc_run+0xbd/0x150
[ 1885.092742]  [<ffffffff8146e5a7>] ? dev_queue_xmit+0x1e7/0x3a0
[ 1885.092766]  [<ffffffff814ab596>] ? ip_finish_output+0x2e6/0x3e0
[ 1885.092791]  [<ffffffff8146ed13>] ? __netif_receive_skb+0x5b3/0x7c0
[ 1885.092816]  [<ffffffff8146f114>] ? netif_receive_skb+0x24/0x80
[ 1885.092841]  [<ffffffff8146fc50>] ? napi_gro_receive+0x110/0x140
[ 1885.092866]  [<ffffffff813bc67b>] ? e1000_clean_rx_irq+0x29b/0x490
[ 1885.092891]  [<ffffffff813c3a20>] ? e1000e_poll+0x90/0x3a0
[ 1885.092915]  [<ffffffff8146f796>] ? net_rx_action+0xc6/0x1e0
[ 1885.092939]  [<ffffffff8103ebb9>] ? __do_softirq+0xa9/0x170
[ 1885.092963]  [<ffffffff8154444c>] ? call_softirq+0x1c/0x30
[ 1885.092987]  [<ffffffff810047dd>] ? do_softirq+0x4d/0x80
[ 1885.093011]  [<ffffffff8103e9cd>] ? irq_exit+0x7d/0x90
[ 1885.093033]  [<ffffffff81003f6c>] ? do_IRQ+0x5c/0xd0
[ 1885.093056]  [<ffffffff81542c2a>] ? common_interrupt+0x6a/0x6a
[ 1885.093079]  <EOI>  [<ffffffff8154194e>] ? __schedule+0x26e/0x5b0
[ 1885.093109]  [<ffffffff8100ad8f>] ? mwait_idle+0x5f/0x70
[ 1885.093132]  [<ffffffff8100b126>] ? cpu_idle+0xf6/0x110
[ 1885.093156]  [<ffffffff818ac92f>] ? start_secondary+0x1d7/0x1db


I managed to get the vmcore and here is some extra info:

crash> sys
      KERNEL: vmlinux
    DUMPFILE: vmcore.201305211445
        CPUS: 2
        DATE: Tue May 21 14:45:16 2013
      UPTIME: 00:31:25
LOAD AVERAGE: 0.00, 0.01, 0.05
       TASKS: 105
    NODENAME: SERVER
     RELEASE: 3.8.13
     VERSION: #3 SMP Mon May 20 13:09:05 EEST 2013
     MACHINE: x86_64  (3000 Mhz)
      MEMORY: 1 GB
       PANIC: "Kernel panic - not syncing: stack-protector: Kernel stack
is corrupted in: ffffffff814d5fec"

crash> bt
PID: 0      TASK: ffff88003e06b8e0  CPU: 1   COMMAND: "swapper/1"
 #0 [ffff88003fd03798] machine_kexec at ffffffff81027430
 #1 [ffff88003fd037e8] crash_kexec at ffffffff8107da80
 #2 [ffff88003fd038b8] panic at ffffffff81540026
 #3 [ffff88003fd03938] __stack_chk_fail at ffffffff81037f77
 #4 [ffff88003fd03948] icmp_send at ffffffff814d5fec
 #5 [ffff88003fd03b78] dev_hard_start_xmit at ffffffff8146e032
 #6 [ffff88003fd03bc8] sch_direct_xmit at ffffffff81487d66
 #7 [ffff88003fd03c08] __qdisc_run at ffffffff81487efd
 #8 [ffff88003fd03c48] dev_queue_xmit at ffffffff8146e5a7
 #9 [ffff88003fd03c88] ip_finish_output at ffffffff814ab596
#10 [ffff88003fd03ce8] __netif_receive_skb at ffffffff8146ed13
#11 [ffff88003fd03d88] napi_gro_receive at ffffffff8146fc50
#12 [ffff88003fd03da8] e1000_clean_rx_irq at ffffffff813bc67b
#13 [ffff88003fd03e48] e1000e_poll at ffffffff813c3a20
#14 [ffff88003fd03e98] net_rx_action at ffffffff8146f796
#15 [ffff88003fd03ee8] __do_softirq at ffffffff8103ebb9
#16 [ffff88003fd03f38] call_softirq at ffffffff8154444c
#17 [ffff88003fd03f50] do_softirq at ffffffff810047dd
#18 [ffff88003fd03f80] do_IRQ at ffffffff81003f6c
--- <IRQ stack> ---
#19 [ffff88003e097e58] ret_from_intr at ffffffff81542c2a
    [exception RIP: mwait_idle+95]
    RIP: ffffffff8100ad8f  RSP: ffff88003e097f00  RFLAGS: 00000246
    RAX: 0000000000000000  RBX: ffffffff8154194e  RCX: 0000000000000000
    RDX: 0000000000000000  RSI: ffff88003e097fd8  RDI: ffff88003fd0d840
    RBP: ffffffff8185be80   R8: 0000000000000000   R9: 0000000000000001
    R10: 0000000000000000  R11: 0000000000000000  R12: 0000000000000000
    R13: ffff88003e06b8e0  R14: ffff88003fd11000  R15: ffff88003e06b8e0
    ORIG_RAX: ffffffffffffff1e  CS: 0010  SS: 0018
#20 [ffff88003e097f00] cpu_idle at ffffffff8100b126

Any ideas please? we have trying using ipv6.disable=1 at boot and still
panics..

Thanks!

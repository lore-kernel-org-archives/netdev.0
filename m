From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: sky2: BUG_ON(sky2->hw->flags & SKY2_HW_NEW_LE) in sky2_rx_checksum
 triggers
Date: Wed, 6 Jun 2012 21:20:36 +0400
Message-ID: <20120606172036.GA11911@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:33006 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757507Ab2FFRaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 13:30:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello up there,

I was playing with `ethtool -K rx on|off` on today's net-next (cbfc6071)
and got BUG_ON in sky2_rx_checksum. Steps to reproduce:

# (cable connected to net)
$ ethtool -K eth0 rx off
$ ethtool -K eth0 rx on

then it bugs:


------------[ cut here ]------------
kernel BUG at drivers/net/ethernet/marvell/sky2.c:2684!
invalid opcode: 0000 [#1] PREEMPT SMP
Modules linked in: sky2

Pid: 0, comm: swapper/1 Not tainted 3.5.0-rc1-netmini+ #75 Hewlett-Packard HP Mini 5103/1608
EIP: 0060:[<efe7a18f>] EFLAGS: 00010202 CPU: 1
EIP is at sky2_poll+0x725/0x8cc [sky2]
EAX: ed52e540 EBX: edfd6800 ECX: 00040000 EDX: 00041004
ESI: 631e631e EDI: 000000e6 EBP: 00000400 ESP: edc7ff1c
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: a76110c4 CR3: 01545000 CR4: 000007d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process swapper/1 (pid: 0, ti=edc7e000 task=edc614a0 task.ti=edc74000)
Stack:
 edc02400 ed51c080 edc7ff7c b1340f90 8020001f ed51c700 8020001e edc7ff6c
 ed52e540 ed51de00 001e006c ed6cbd40 00000000 00000046 edfd6bc0 00000000
 ed52e548 000007ad 00000040 00000040 00000282 ed51c700 edc02400 b14b8200
Call Trace:
 [<b1340f90>] ? __slab_free.isra.49+0xac/0x157
 [<b10256b7>] ? rcu_read_unlock_sched_notrace+0x19/0x19
 [<b12e3add>] ? net_rx_action+0x8f/0x182
 [<b10256b7>] ? rcu_read_unlock_sched_notrace+0x19/0x19
 [<b1025747>] ? __do_softirq+0x90/0x165
 [<b10256b7>] ? rcu_read_unlock_sched_notrace+0x19/0x19
 <IRQ>
 [<b10259c3>] ? irq_exit+0x32/0x8a
 [<b10034f8>] ? do_IRQ+0x74/0x89
 [<b104d1e7>] ? tick_program_event+0x1f/0x22
 [<b1349ce9>] ? common_interrupt+0x29/0x30
 [<b102007b>] ? do_oops_enter_exit.part.3+0x8d/0xac
 [<b1184327>] ? intel_idle+0xc6/0xe9
 [<b12a8e7a>] ? cpuidle_enter+0xb/0xe
 [<b12a92d0>] ? cpuidle_idle_call+0xb5/0x167
 [<b10075fc>] ? cpu_idle+0x43/0x7b
Code: ff e9 19 01 00 00 0f b7 d5 8b 44 24 38 e8 f4 b7 ff ff f6 83 8f 00 00 00
20 0f 84 00 01 00 00 8b 83 c0 03 00 00 f6 40 44 20 74 02 <0f> 0b 89 f2 c1 ea 10
66 39 f2 75 29 0f b7 83 5c 04 00 00 c1 e0
EIP: [<efe7a18f>] sky2_poll+0x725/0x8cc [sky2] SS:ESP 0068:edc7ff1c
Kernel panic - not syncing: Fatal exception in interrupt
panic occured, switching back to text console

---- 8< ----
(not sure I've ocr'ed it correctly. If in doubt, there is this bug
 screenshot here:
 https://github.com/navytux/navytux.github.com/raw/master/~kirr/misc/sky2_rx_checksum_BUGON_hwflags.jpg)


My hardware is

    02:00.0 0200: 11ab:4381 (rev 11)

i.e.

    02:00.0 Ethernet controller: Marvell Technology Group Ltd. Yukon
        Optima 88E8059 [PCIe Gigabit Ethernet Controller with AVB] (rev 11)


and dmesg when sky2 driver loads:

[    8.090421] sky2: driver version 1.30
[    8.094079] sky2 0000:02:00.0: Yukon-2 Optima chip revision 1
[    8.098148] sky2 0000:02:00.0: irq 43 for MSI/MSI-X
[    8.099524] sky2 0000:02:00.0: eth0: addr 1c:c1:de:ae:73:8a
[   18.134971] sky2 0000:02:00.0: eth0: enabling interface
[   75.544140] sky2 0000:02:00.0: eth0: Link is up at 1000 Mbps, full duplex, flow control rx


Thanks beforehand,
Kirill

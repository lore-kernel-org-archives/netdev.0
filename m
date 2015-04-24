From: Toan Pham <tpham3783@gmail.com>
Subject: [Problem] broadcom tg3 network driver disconnects under high load
Date: Fri, 24 Apr 2015 12:33:33 -0400
Message-ID: <CAGNmLEMbyR6-1WSyPRZQhLanH_UB7xb5cVVQ9N625bvdhbA6MA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35777 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966532AbbDXQde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 12:33:34 -0400
Received: by igbyr2 with SMTP id yr2so19380831igb.0
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 09:33:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Summary:  Broadcom 5762 NIC locks up under heavy load.


Description:

The tg3 Broadcom network driver that binds with chipset 5762 locks up
when under heavy network load. When this happens, a reboot is
necessary to recover network. Sometimes, bringing the interface
offline and online (via ifconfig) would recover networking. I've also
tested with the latest tg3 driver 3.137h (dec 2014 version) and
networking is still problematic. I have also disabled TSO, GSO etc...
with ethtool, but the bug still surfaces. This bug may be related to
the integrated Firmware because at the time of the crash, the memory
dump of the bcm5762 chip is completely cleared out with 0xFFs.

Here is the procedure to replicate the issue because it is hard to
replicate it under moderate network load.

1. Bootup a machine with a broadcom 5762 NIC (ie. HP DeskElite 705)
using a Ubuntu/Kubunu Live CD 14.04-15.04, or a build with the latest
mainline kernel.
2. From another machine: start 5 sessions, repetitively copy (scp with
public key authentication) a 70 MB file back and forth to the tg3
machine in each session. (not sure if this is necessary)
3. Create a 1GB file on the tg3 machine, with something like dd
if=/dev/urandom of=/my_test_file bs=1024 count=$((1024*1000))
4. From another machine: repetitively secure copy that 1GB file from
the tg3 machine. This can be done with something like:

while [ 0 ]; do
   scp -i /my/scp/private.key user@ip.of.tg3:/my_test_file /tmp
done;

Networking will lockup in about 10-30 minutes, in some rare cases up
to 4 hours of run time.  Having multiple instances of the 1GB file
transfer will significantly reduce the occurrence time.


Keywords: networking, tg3

kernel version: Linux version 4.0.0-gbf70def.  I have also tested with
the following kernel versions:  3.17, 3.16, 2.6.39.

Kernel log message (Oops):  (see full ref:
https://launchpadlibrarian.net/204185480/dmesg)

WARNING: CPU: 0 PID: 1830 at net/sched/sch_generic.c:303
dev_watchdog+0xfc/0x185()
NETDEV WATCHDOG: eth0 (tg3): transmit queue 0 timed out
Modules linked in:
CPU: 0 PID: 1830 Comm: cat Not tainted 4.0.0-gbf70def #4
Hardware name: Hewlett-Packard HP EliteDesk 705 G1 MT/2215, BIOS L06
v02.15 10/22/2014
 00000000 00000000 f581df18 c06e5045 c0a7ec29 f581df30 c01319e9 c0668e77
 f4c30000 00000000 0005da10 f581df48 c0131a73 00000009 f581df40 c0a7ec29
 f581df5c f581df78 c0668e77 c0a7ec62 0000012f c0a7ec29 f4c30000 c0a60eba
Call Trace:
 [<c06e5045>] dump_stack+0x41/0x52
 [<c01319e9>] warn_slowpath_common+0x83/0x9a
 [<c0668e77>] ? dev_watchdog+0xfc/0x185
 [<c0131a73>] warn_slowpath_fmt+0x2b/0x2f
 [<c0668e77>] dev_watchdog+0xfc/0x185
 [<c0668d7b>] ? pfifo_fast_dequeue+0xaf/0xaf
 [<c0165221>] call_timer_fn+0x47/0xcd
 [<c01655d9>] run_timer_softirq+0x165/0x1c4
 [<c0668d7b>] ? pfifo_fast_dequeue+0xaf/0xaf
 [<c0133d84>] __do_softirq+0xbe/0x1ef
 [<c0133cc6>] ? _local_bh_enable+0x40/0x40
 [<c0103551>] do_softirq_own_stack+0x22/0x28
 <IRQ>  [<c0134003>] irq_exit+0x39/0x47
 [<c0121b41>] smp_apic_timer_interrupt+0x38/0x42
 [<c06f1959>] apic_timer_interrupt+0x2d/0x34
 [<c06f0c20>] ? _raw_spin_unlock_irqrestore+0xd/0xf
 [<c0389fb5>] extract_buf+0x83/0xc7
 [<c038b68e>] extract_entropy_user+0xc2/0x11a
 [<c038b74e>] urandom_read+0x68/0xbf
 [<c038b6e6>] ? extract_entropy_user+0x11a/0x11a
 [<c01d4594>] __vfs_read+0x1b/0x47
 [<c01d462b>] vfs_read+0x6b/0xd3
 [<c01d46d7>] SyS_read+0x44/0x84
 [<c06f11c2>] syscall_call+0x7/0x7


System info and detailed description:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1447664


I can help test proposed patches fairly quickly.  So please let me
know if you need anything.  Thank you.

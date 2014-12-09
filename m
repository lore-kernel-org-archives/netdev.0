From: "Peter Schmitt" <p.schmitt.82@gmx.net>
Subject: PROBLEM: bonding status file in /proc not removed when using
 bond-device as a slave
Date: Tue, 9 Dec 2014 13:04:53 +0100
Message-ID: <trinity-cf79e6bc-94ab-403a-9ac6-92f47e5325d2-1418126693738@3capp-gmx-bs71>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:52772 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756791AbaLIME4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 07:04:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I want to create a master-backup bond that has two LACP bonds as slaves=
=2E Both
LACP slaves should be connected to different switches so that I have
connectivity even if one switch fails.
While experimenting with this setup on the recent LTS kernel 3.14.26 I =
have found the following behaviour:
When I add a bond device (by default an LACP bond, mode 4) to a master-=
backup
bond (mode 1) and then remove it, the corresponding status file for the=
 bond remains in
/proc/net/bonding/ and when I do a cat on this file, the machine crashe=
s or I get a
general protection fault.

The following snippet creates such a scenario:

#!/bin/bash
echo +bond1 > /sys/class/net/bonding_masters
echo 1 > /sys/class/net/bond1/bonding/mode
echo +bond2 > /sys/class/net/bonding_masters
echo +bond2 > /sys/class/net/bond1/bonding/slaves
echo -bond2 > /sys/class/net/bond1/bonding/slaves
echo -bond2 > /sys/class/net/bonding_masters

After this is executed, the file /proc/net/bonding/bond2 still exists
while /sys/class/net/bonding_masters only shows bond1:

> ls -lah /proc/net/bonding/bond*
r--r--r-- 1 root root 0 Dec  8 16:53 /proc/net/bonding/bond1
r--r--r-- 1 root root 0 Dec  8 16:53 /proc/net/bonding/bond2

> cat /sys/class/net/bonding_masters
bond1

When I now make a "cat" on the file in /proc, I get a general protectio=
n fault
or even worse, the machine just crashes and is unresponsive and it can =
only be
fixed with a power-cycle.

> uname -a
Linux bondingtest 3.14.26-x86 #1 SMP Sun Dec 7 11:29:36 CET 2014 i686 G=
NU/Linux

The bonding module is loaded with the following options:
modprobe bonding miimon=3D100 max_bonds=3D0 mode=3D4 lacp_rate=3D1 xmit=
_hash_policy=3Dlayer2+3


> cat /proc/net/bonding/bond2
general protection fault: 0000 [#1] SMP=C2=B7
Modules linked in: w83627hf hwmon_vid coretemp hwmon ip_set iptable_nat=
 nf_nat_ipv4 ipt_REJECT nf_nat_irc nf_conntrack_irc nf_nat_ftp nf_nat n=
f_conntrack_ftp msr ipmi_devintf ipmi_msghandler ip_gre gre bonding pcs=
pkr i3200_edac edac_core uhci_hcd ehci_pci ehci_hcd lpc_ich mfd_core pa=
ta_acpi ata_generic shpchp e1000e ptp pps_core [last unloaded: cpuid]
CPU: 0 PID: 31747 Comm: cat Not tainted 3.14.26-x86_64 #1
Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./To be fill=
ed by O.E.M., BIOS 080015  06/29/2009
task: ffff8800d61d77b0 ti: ffff8800d6068000 task.ti: ffff8800d6068000
RIP: 0010:[<ffffffffc00f7ef0>]  [<ffffffffc00f7ef0>] bond_info_seq_show=
+0x2d0/0x5e0 [bonding]
RSP: 0018:ffff8800d6069e08  EFLAGS: 00010212
RAX: 5f7367705f656c62 RBX: ffff880198570380 RCX: 0000000000000001
RDX: ffffffffc00f9547 RSI: ffffffffc00f954f RDI: ffff880198570380
RBP: ffff8800d6069e48 R08: ffffffff9413ed60 R09: ffff8800dba15cd4
R10: 0000000000000001 R11: 0000000000000000 R12: ffff8800d60917c0
R13: 656b636f6c6e756d R14: ffff880197d469c0 R15: ffff8800d6069e90
=46S:  0000000000000000(0000) GS:ffff88019fc00000(0063) knlGS:00000000f=
761c8d0
CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
CR2: 000000000804ce10 CR3: 00000000db8cd000 CR4: 00000000000407f0
Stack:
ffff8800d6069e48 ffffffffc00f8318 ffff8801986ba9f0 ffff880197d469c0
ffff880198570380 0000000000000001 ffff880197d469c0 ffff8800d6069e90
ffff8800d6069ec8 ffffffff9413eed1 ffff880198289a58 0000000008213000
Call Trace:
[<ffffffffc00f8318>] ? bond_info_seq_start+0x28/0xa8 [bonding]
[<ffffffff9413eed1>] seq_read+0x171/0x3f0
[<ffffffff94175a7e>] proc_reg_read+0x3e/0x70
[<ffffffff9411e0e1>] vfs_read+0xa1/0x160
[<ffffffff9411e281>] SyS_read+0x51/0xc0
[<ffffffff94039c9c>] ? do_page_fault+0xc/0x10
[<ffffffff94516cdf>] sysenter_dispatch+0x7/0x1e
Code: 04 49 8b 55 00 48 c7 c6 2a 95 0f c0 48 89 df 31 c0 e8 d5 6c 04 d4=
 49 8b 04 24 48 c7 c2 47 95 0f c0 48 c7 c6 4f 95 0f c0 48 89 df <48> 8b=
 40 48 a8 04 48 c7 c0 4c 95 0f c0 48 0f 44 d0 31 c0 e8 a8=C2=B7
RIP  [<ffffffffc00f7ef0>] bond_info_seq_show+0x2d0/0x5e0 [bonding]
RSP <ffff8800d6069e08>
---[ end trace 96fae3d9de6068c7 ]---
Segmentation fault

ver_linux:
Linux bondingtest 3.14.26-x86 #1 SMP Sun Dec 7 11:29:36 CET 2014 i686 G=
NU/Linux

Gnu C                  4.4.3
Gnu make              3.81
binutils              2.20.1
util-linux            2.17.2
mount                  support
module-init-tools      found
e2fsprogs              1.42.11
PPP                    2.4.5
Linux C Library        2.11.1
Dynamic linker (ldd)  2.11.1
Procps                3.2.8
Net-tools              1.60
Kbd                    1.15
Sh-utils              found
Modules Loaded        xt_TPROXY xt_set xt_socket nf_defrag_ipv6 xt_REDI=
RECT ip_set_hash_ip hwmon_vid hwmon bridge ip_set iptable_nat nf_nat_ip=
v4 ipt_REJECT nf_nat_irc nf_conntrack_irc nf_nat_ftp nf_nat nf_conntrac=
k_ftp msr ipmi_devintf ipmi_msghandler ip_gre gre bonding pcspkr shpchp=
 uhci_hcd ehci_pci ehci_hcd lpc_ich mfd_core pata_acpi ata_generic

If you have any questions or need more information or tests, I will gla=
dly help you with that.

Thank you in advance.

Best regards,
Peter Schmitt

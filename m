From: "Peter Schmitt" <p.schmitt.82@gmx.net>
Subject: Re: PROBLEM: bonding status file in /proc not removed when using
 bond-device as a slave
Date: Wed, 10 Dec 2014 12:49:08 +0100
Message-ID: <trinity-2ae31da3-b293-4f08-8f3e-45e129b72217-1418212148011@3capp-gmx-bs44>
References: <trinity-cf79e6bc-94ab-403a-9ac6-92f47e5325d2-1418126693738@3capp-gmx-bs71>,
 <20141209135812.GI797@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Andy Gospodarek" <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:54458 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357AbaLJLtK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 06:49:10 -0500
In-Reply-To: <20141209135812.GI797@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy and everyone else!

> > Hi everyone,
> >=20
> > I want to create a master-backup bond that has two LACP bonds as sl=
aves. Both
>=20
> There is no reason to do this.  The bonding code you are running
> supports the ability to connect a single 802.3ad bond to different
> switches and should do exactly what you need.
>=20
> When you put all ports in the same bond you will notice that ports th=
at
> go to one switch will be listed with a particular aggregator ID and a=
ll
> ports going to another switch will have a different aggregator ID.  Y=
ou
> will also see that the bond will list only one active aggregator.  Th=
is
> should give you the behaviour you desire.
>=20
> Additionally look at 'ad_select' option in the bonding documentation =
to
> help tune when you switch from one link to another.

Thank you very much for your answer. I did not know about this behaviou=
r.=20
The ad_select feature is nice, but you can't explicitly control which s=
witch
(which aggregator id) should be used. So I need some links between thos=
e two
switches to handle situations where one machine uses the first switch a=
nd the
other uses the second. The Active-Backup mode let's me configure exactl=
y this:
Which bond should be active. With uplinks between the switches, the LAC=
P feature
is indeed very handy.

I wonder what the purpose of the Active-Backup mode is then? Is this th=
e low-budget
solution to the failover problem? Is the setup with Active-Backup and L=
ACP bonds
as slaves supported? This seems to work quite well in my testsetup.

However, the described problem remains. One can create a setup where su=
ch a file is left
in the proc-fs and a cat on this file crashes the machine.

Thank you very much for your help.

Best regards,
Peter

> > LACP slaves should be connected to different switches so that I hav=
e
> > connectivity even if one switch fails.
> > While experimenting with this setup on the recent LTS kernel 3.14.2=
6 I have found the following behaviour:
> > When I add a bond device (by default an LACP bond, mode 4) to a mas=
ter-backup
> > bond (mode 1) and then remove it, the corresponding status file for=
 the bond remains in
> > /proc/net/bonding/ and when I do a cat on this file, the machine cr=
ashes or I get a
> > general protection fault.
> >=20
> > The following snippet creates such a scenario:
> >=20
> > #!/bin/bash
> > echo +bond1 > /sys/class/net/bonding_masters
> > echo 1 > /sys/class/net/bond1/bonding/mode
> > echo +bond2 > /sys/class/net/bonding_masters
> > echo +bond2 > /sys/class/net/bond1/bonding/slaves
> > echo -bond2 > /sys/class/net/bond1/bonding/slaves
> > echo -bond2 > /sys/class/net/bonding_masters
> >=20
> > After this is executed, the file /proc/net/bonding/bond2 still exis=
ts
> > while /sys/class/net/bonding_masters only shows bond1:
> >=20
> > > ls -lah /proc/net/bonding/bond*
> > r--r--r-- 1 root root 0 Dec  8 16:53 /proc/net/bonding/bond1
> > r--r--r-- 1 root root 0 Dec  8 16:53 /proc/net/bonding/bond2
> >=20
> > > cat /sys/class/net/bonding_masters
> > bond1
> >=20
> > When I now make a "cat" on the file in /proc, I get a general prote=
ction fault
> > or even worse, the machine just crashes and is unresponsive and it =
can only be
> > fixed with a power-cycle.
> >=20
> > > uname -a
> > Linux bondingtest 3.14.26-x86 #1 SMP Sun Dec 7 11:29:36 CET 2014 i6=
86 GNU/Linux
> >=20
> > The bonding module is loaded with the following options:
> > modprobe bonding miimon=3D100 max_bonds=3D0 mode=3D4 lacp_rate=3D1 =
xmit_hash_policy=3Dlayer2+3
> >=20
> >=20
> > > cat /proc/net/bonding/bond2
> > general protection fault: 0000 [#1] SMP=C2=B7
> > Modules linked in: w83627hf hwmon_vid coretemp hwmon ip_set iptable=
_nat nf_nat_ipv4 ipt_REJECT nf_nat_irc nf_conntrack_irc nf_nat_ftp nf_n=
at nf_conntrack_ftp msr ipmi_devintf ipmi_msghandler ip_gre gre bonding=
 pcspkr i3200_edac edac_core uhci_hcd ehci_pci ehci_hcd lpc_ich mfd_cor=
e pata_acpi ata_generic shpchp e1000e ptp pps_core [last unloaded: cpui=
d]
> > CPU: 0 PID: 31747 Comm: cat Not tainted 3.14.26-x86_64 #1
> > Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./To be =
filled by O.E.M., BIOS 080015  06/29/2009
> > task: ffff8800d61d77b0 ti: ffff8800d6068000 task.ti: ffff8800d60680=
00
> > RIP: 0010:[<ffffffffc00f7ef0>]  [<ffffffffc00f7ef0>] bond_info_seq_=
show+0x2d0/0x5e0 [bonding]
> > RSP: 0018:ffff8800d6069e08  EFLAGS: 00010212
> > RAX: 5f7367705f656c62 RBX: ffff880198570380 RCX: 0000000000000001
> > RDX: ffffffffc00f9547 RSI: ffffffffc00f954f RDI: ffff880198570380
> > RBP: ffff8800d6069e48 R08: ffffffff9413ed60 R09: ffff8800dba15cd4
> > R10: 0000000000000001 R11: 0000000000000000 R12: ffff8800d60917c0
> > R13: 656b636f6c6e756d R14: ffff880197d469c0 R15: ffff8800d6069e90
> > FS:  0000000000000000(0000) GS:ffff88019fc00000(0063) knlGS:0000000=
0f761c8d0
> > CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
> > CR2: 000000000804ce10 CR3: 00000000db8cd000 CR4: 00000000000407f0
> > Stack:
> > ffff8800d6069e48 ffffffffc00f8318 ffff8801986ba9f0 ffff880197d469c0
> > ffff880198570380 0000000000000001 ffff880197d469c0 ffff8800d6069e90
> > ffff8800d6069ec8 ffffffff9413eed1 ffff880198289a58 0000000008213000
> > Call Trace:
> > [<ffffffffc00f8318>] ? bond_info_seq_start+0x28/0xa8 [bonding]
> > [<ffffffff9413eed1>] seq_read+0x171/0x3f0
> > [<ffffffff94175a7e>] proc_reg_read+0x3e/0x70
> > [<ffffffff9411e0e1>] vfs_read+0xa1/0x160
> > [<ffffffff9411e281>] SyS_read+0x51/0xc0
> > [<ffffffff94039c9c>] ? do_page_fault+0xc/0x10
> > [<ffffffff94516cdf>] sysenter_dispatch+0x7/0x1e
> > Code: 04 49 8b 55 00 48 c7 c6 2a 95 0f c0 48 89 df 31 c0 e8 d5 6c 0=
4 d4 49 8b 04 24 48 c7 c2 47 95 0f c0 48 c7 c6 4f 95 0f c0 48 89 df <48=
> 8b 40 48 a8 04 48 c7 c0 4c 95 0f c0 48 0f 44 d0 31 c0 e8 a8=C2=B7
> > RIP  [<ffffffffc00f7ef0>] bond_info_seq_show+0x2d0/0x5e0 [bonding]
> > RSP <ffff8800d6069e08>
> > ---[ end trace 96fae3d9de6068c7 ]---
> > Segmentation fault
> >=20
> > ver_linux:
> > Linux bondingtest 3.14.26-x86 #1 SMP Sun Dec 7 11:29:36 CET 2014 i6=
86 GNU/Linux
> >=20
> > Gnu C                  4.4.3
> > Gnu make              3.81
> > binutils              2.20.1
> > util-linux            2.17.2
> > mount                  support
> > module-init-tools      found
> > e2fsprogs              1.42.11
> > PPP                    2.4.5
> > Linux C Library        2.11.1
> > Dynamic linker (ldd)  2.11.1
> > Procps                3.2.8
> > Net-tools              1.60
> > Kbd                    1.15
> > Sh-utils              found
> > Modules Loaded        xt_TPROXY xt_set xt_socket nf_defrag_ipv6 xt_=
REDIRECT ip_set_hash_ip hwmon_vid hwmon bridge ip_set iptable_nat nf_na=
t_ipv4 ipt_REJECT nf_nat_irc nf_conntrack_irc nf_nat_ftp nf_nat nf_conn=
track_ftp msr ipmi_devintf ipmi_msghandler ip_gre gre bonding pcspkr sh=
pchp uhci_hcd ehci_pci ehci_hcd lpc_ich mfd_core pata_acpi ata_generic
> >=20
> > If you have any questions or need more information or tests, I will=
 gladly help you with that.
> >=20
> > Thank you in advance.
> >=20
> > Best regards,
> > Peter Schmitt
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

From: RuanZhijie <ruanzhijie@hotmail.com>
Subject: Kernel Oops
Date: Sat, 7 Jul 2012 20:54:33 +0800
Message-ID: <COL118-W53DF90DC4EB796E1D71866DAED0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <skinsbursky@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from col0-omc4-s1.col0.hotmail.com ([65.55.34.203]:17200 "EHLO
	col0-omc4-s1.col0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750918Ab2GGMye convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jul 2012 08:54:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, all.

Mr. Stanislav Kinsbursky suggests me send you a report about an oops I =
encountered in the past few days.

A few days ago, I tested some VMs with NAT enabled under KVM and libvir=
t, but kernel crashed when I shut down these VMs, though this issue did=
 not occur every time. I did some search and found a webpage(http://www=
=2Espinics.net/lists/netdev/msg193846.html) in which Simon reported a s=
imilar issue.

The operating system I use is gentoo-amd64 with no-multilib profile, ke=
rnel version is 3.4.0, libvirt-0.9.13 with USE flag "qemu virt-network"=
 enabled and qemu-kvm-1.0.1-r1. Here are the steps to reproduce:

1. Let's define that starting a VM with NAT enabled under KVM and libvi=
rt and then shut it down immediately as one operation.
2. Repeat the operation for several times.

I also did 3 tests:

Test 1:=20
The host machine is with a regular linux 3.4.0 kernel, and the VM had N=
AT enabled. Kernel crashed after 2, 7 and 13 operations.

Test 2:
The host machine is with a regular linux 3.4.0 kernel, and the VM had n=
o network access. No crash occured after 100 operations.

Test 3:
The host machine is with a linux 3.4.0 kernel, but drivers/net/tun.c wa=
s reverted back to just before commit 1ab5ecb90cb6a3df1476e052f76a6e8f6=
511cb3d (https://github.com/torvalds/linux/commit/1ab5ecb90cb6a3df1476e=
052f76a6e8f6511cb3d#drivers/net/tun.c), (or you can use a tun.c from a =
3.2.0 kernel, according to Simon's report), and the VM had NAT enabled.=
 No crash occured after 100 operations.

Moreover, I observe that a virtual interface is created to handle netwo=
rk access when a VM with NAT enabled starts, and the virtual interface =
is removed when the VM is shut down. Crashes usually occur at the time =
the virtual interface is removed.

=46inally, 3 types of kernel crash traces were observed; and thanks to =
rsyslog, they are all recorded:

Type 1:
2012-07-06T11:44:31.513203+08:00 timemars NetworkManager[1761]: <warn> =
/sys/devices/virtual/net/vnet0: couldn't determine device driver; ignor=
ing...
2012-07-06T11:44:31.523305+08:00 timemars kernel: device vnet0 entered =
promiscuous mode
2012-07-06T11:44:31.532555+08:00 timemars kernel: virbr0: topology chan=
ge detected, propagating
2012-07-06T11:44:31.532591+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered forwarding state
2012-07-06T11:44:31.532599+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered forwarding state
2012-07-06T11:44:33.019292+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered disabled state
2012-07-06T11:44:33.021282+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered disabled state
2012-07-06T11:44:33.021305+08:00 timemars kernel: device vnet0 left pro=
miscuous mode
2012-07-06T11:44:33.021308+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered disabled state
2012-07-06T11:44:33.352293+08:00 timemars kernel: BUG: unable to handle=
 kernel paging request at 00001fff813e1b10
2012-07-06T11:44:33.352452+08:00 timemars kernel: IP: [<ffffffff810bcae=
d>] __pfn_to_section+0x9/0x28
2012-07-06T11:44:33.352509+08:00 timemars kernel: PGD 0=20
2012-07-06T11:44:33.352562+08:00 timemars kernel: Oops: 0000 [#1] SMP=20
2012-07-06T11:44:33.352613+08:00 timemars kernel: CPU 1=20
2012-07-06T11:44:33.352665+08:00 timemars kernel: Modules linked in:
2012-07-06T11:44:33.352716+08:00 timemars kernel:=20
2012-07-06T11:44:33.352770+08:00 timemars kernel: Pid: 2076, comm: libv=
irtd Not tainted 3.4.0 #1 Dell Inc. Inspiron 1440=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /0K138P
2012-07-06T11:44:33.352826+08:00 timemars kernel: RIP: 0010:[<ffffffff8=
10bcaed>]=A0 [<ffffffff810bcaed>] __pfn_to_section+0x9/0x28
2012-07-06T11:44:33.352878+08:00 timemars kernel: RSP: 0018:ffff8800aac=
c5d40=A0 EFLAGS: 00010246
2012-07-06T11:44:33.352931+08:00 timemars kernel: RAX: 0000000000000000=
 RBX: ffffe780281e6600 RCX: fffffe780281e660
2012-07-06T11:44:33.352983+08:00 timemars kernel: RDX: 0000000000003434=
 RSI: 0000000000000207 RDI: 000003fffff9e00a
2012-07-06T11:44:33.353035+08:00 timemars kernel: RBP: ffff8800a0799820=
 R08: dead000000100100 R09: dead000000200200
2012-07-06T11:44:33.353053+08:00 timemars kernel: R10: ffff88011fd10b40=
 R11: ffff88011fd10b40 R12: ffff8800a0799800
2012-07-06T11:44:33.353061+08:00 timemars kernel: R13: ffff8800948ef800=
 R14: 0000000000000000 R15: ffff8800948ef000
2012-07-06T11:44:33.353094+08:00 timemars kernel: FS:=A0 00007ff98fdf17=
00(0000) GS:ffff88011fd00000(0000) knlGS:0000000000000000
2012-07-06T11:44:33.353103+08:00 timemars kernel: CS:=A0 0010 DS: 0000 =
ES: 0000 CR0: 000000008005003b
2012-07-06T11:44:33.353110+08:00 timemars kernel: CR2: 00001fff813e1b10=
 CR3: 00000000aaceb000 CR4: 00000000000407e0
2012-07-06T11:44:33.353117+08:00 timemars kernel: DR0: 0000000000000000=
 DR1: 0000000000000000 DR2: 0000000000000000
2012-07-06T11:44:33.353143+08:00 timemars kernel: DR3: 0000000000000000=
 DR6: 00000000ffff0ff0 DR7: 0000000000000400
2012-07-06T11:44:33.353153+08:00 timemars kernel: Process libvirtd (pid=
: 2076, threadinfo ffff8800aacc4000, task ffff8800aeaff200)
2012-07-06T11:44:33.353160+08:00 timemars kernel: Stack:
2012-07-06T11:44:33.353169+08:00 timemars kernel: ffffffff810bcb2b ffff=
8800a0799820 ffffffff810bc004 ffff880118cfc920
2012-07-06T11:44:33.353176+08:00 timemars kernel: ffff8800a2368f00 0000=
000200005058 0000000000000002 ffff880104aa8618
2012-07-06T11:44:33.353183+08:00 timemars kernel: ffffffff81608dc0 0000=
000000000000 0000000000000000 0000000200000005
2012-07-06T11:44:33.353190+08:00 timemars kernel: Call Trace:
2012-07-06T11:44:33.353198+08:00 timemars kernel: [<ffffffff810bcb2b>] =
? lookup_page_cgroup+0x1f/0x28
2012-07-06T11:44:33.353206+08:00 timemars kernel: [<ffffffff810bc004>] =
? mem_cgroup_force_empty+0x1c1/0x496
2012-07-06T11:44:33.353213+08:00 timemars kernel: [<ffffffff810d318d>] =
? mntput_no_expire+0x1f/0xf4
2012-07-06T11:44:33.353222+08:00 timemars kernel: [<ffffffff8105f2ef>] =
? should_resched+0x5/0x23
2012-07-06T11:44:33.353230+08:00 timemars kernel: [<ffffffff81079d92>] =
? cgroup_rmdir+0x9d/0x39c
2012-07-06T11:44:33.353237+08:00 timemars kernel: [<ffffffff8105a4e8>] =
? add_wait_queue+0x3c/0x3c
2012-07-06T11:44:33.353244+08:00 timemars kernel: [<ffffffff8105f2ef>] =
? should_resched+0x5/0x23
2012-07-06T11:44:33.353250+08:00 timemars kernel: [<ffffffff810c859e>] =
? vfs_rmdir+0x67/0xab
2012-07-06T11:44:33.353275+08:00 timemars kernel: [<ffffffff810c8f4b>] =
? do_rmdir+0xad/0x101
2012-07-06T11:44:33.353285+08:00 timemars kernel: [<ffffffff810d318d>] =
? mntput_no_expire+0x1f/0xf4
2012-07-06T11:44:33.353293+08:00 timemars kernel: [<ffffffff810bd095>] =
? filp_close+0x57/0x5f
2012-07-06T11:44:33.353321+08:00 timemars kernel: [<ffffffff813eaf62>] =
? system_call_fastpath+0x16/0x1b
2012-07-06T11:44:33.353333+08:00 timemars kernel: Code: 8b bd 28 01 00 =
00 e8 fc c8 ff ff eb 03 45 31 ff 48 83 c4 68 4c 89 f8 5b 5d 41 5c 41 5d=
 41 5e 41 5f c3 48 89 f9 48 c1 ef 16 31 c0 <48> 8b 14 fd c0 1a 6f 81 48=
 c1 e9 0f 48 85 d2 74 0d 48 89 c8 83=20
2012-07-06T11:44:33.353341+08:00 timemars kernel: RIP=A0 [<ffffffff810b=
caed>] __pfn_to_section+0x9/0x28
2012-07-06T11:44:33.353366+08:00 timemars kernel: RSP <ffff8800aacc5d40=
>
2012-07-06T11:44:33.353374+08:00 timemars kernel: CR2: 00001fff813e1b10
2012-07-06T11:44:33.353398+08:00 timemars kernel: ---[ end trace 239af6=
a79d1fdbe3 ]---

Type 2:
2012-07-06T12:46:13.772228+08:00 timemars NetworkManager[1684]: <warn> =
/sys/devices/virtual/net/vnet0: couldn't determine device driver; ignor=
ing...
2012-07-06T12:46:13.782523+08:00 timemars kernel: device vnet0 entered =
promiscuous mode
2012-07-06T12:46:13.792507+08:00 timemars kernel: virbr0: topology chan=
ge detected, propagating
2012-07-06T12:46:13.792539+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered forwarding state
2012-07-06T12:46:13.792543+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered forwarding state
2012-07-06T12:46:15.097601+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered disabled state
2012-07-06T12:46:15.097628+08:00 timemars kernel: device vnet0 left pro=
miscuous mode
2012-07-06T12:46:15.097632+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered disabled state
2012-07-06T12:46:15.112429+08:00 timemars kernel: BUG: unable to handle=
 kernel paging request at ffffff816d9f715f
2012-07-06T12:46:15.112456+08:00 timemars kernel: IP: [<ffffffff810a9bc=
6>] filp_close+0x30/0x5f
2012-07-06T12:46:15.112459+08:00 timemars kernel: PGD 15a1067 PUD 0=20
2012-07-06T12:46:15.112477+08:00 timemars kernel: Oops: 0000 [#1] SMP=20
2012-07-06T12:46:15.112480+08:00 timemars kernel: CPU 0=20
2012-07-06T12:46:15.112483+08:00 timemars kernel: Modules linked in:
2012-07-06T12:46:15.112486+08:00 timemars kernel:=20
2012-07-06T12:46:15.112489+08:00 timemars kernel: Pid: 2868, comm: qemu=
-system-x86 Not tainted 3.4.0 #1 Dell Inc. Inspiron 1440=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /0K138P
2012-07-06T12:46:15.112494+08:00 timemars kernel: RIP: 0010:[<ffffffff8=
10a9bc6>]=A0 [<ffffffff810a9bc6>] filp_close+0x30/0x5f
2012-07-06T12:46:15.112497+08:00 timemars kernel: RSP: 0018:ffff8800a67=
6bcc8=A0 EFLAGS: 00010286
2012-07-06T12:46:15.112500+08:00 timemars kernel: RAX: ffffff816d9f70ff=
 RBX: ffff8800a53bafff RCX: 000000000000000f
2012-07-06T12:46:15.112503+08:00 timemars kernel: RDX: 0000000000000000=
 RSI: ffff88011b26d080 RDI: ffff8800a53bafff
2012-07-06T12:46:15.112506+08:00 timemars kernel: RBP: ffff88011b26d080=
 R08: ffff8800a40de000 R09: ffff88009bd0f800
2012-07-06T12:46:15.112510+08:00 timemars kernel: R10: ffffffff81130d8d=
 R11: ffffffff812f0aa6 R12: 0000000000000000
2012-07-06T12:46:15.112513+08:00 timemars kernel: R13: 0000000000000001=
 R14: ffff88009bcc3c80 R15: 0000000000000004
2012-07-06T12:46:15.112516+08:00 timemars kernel: FS:=A0 00007fa1d26547=
00(0000) GS:ffff88011fc00000(0000) knlGS:0000000000000000
2012-07-06T12:46:15.112519+08:00 timemars kernel: CS:=A0 0010 DS: 002b =
ES: 002b CR0: 000000008005003b
2012-07-06T12:46:15.112522+08:00 timemars kernel: CR2: ffffff816d9f715f=
 CR3: 000000000159f000 CR4: 00000000000427e0
2012-07-06T12:46:15.112525+08:00 timemars kernel: DR0: 0000000000000000=
 DR1: 0000000000000000 DR2: 0000000000000000
2012-07-06T12:46:15.112528+08:00 timemars kernel: DR3: 0000000000000000=
 DR6: 00000000ffff0ff0 DR7: 0000000000000400
2012-07-06T12:46:15.112532+08:00 timemars kernel: Process qemu-system-x=
86 (pid: 2868, threadinfo ffff8800a676a000, task ffff88009bc9cec0)
2012-07-06T12:46:15.112542+08:00 timemars kernel: Stack:
2012-07-06T12:46:15.112546+08:00 timemars kernel: ffff88011b26d080 0000=
000000000000 00000000000fdfbf ffffffff81048e0d
2012-07-06T12:46:15.112548+08:00 timemars kernel: ffffffff81130d8d ffff=
88009bc9cec0 0000000000000000 00007ffffffff000
2012-07-06T12:46:15.112551+08:00 timemars kernel: ffff88009bc9cec0 ffff=
88009bc9cec0 0000000000000001 ffffffff810490e7
2012-07-06T12:46:15.112554+08:00 timemars kernel: Call Trace:
2012-07-06T12:46:15.112557+08:00 timemars kernel: [<ffffffff81048e0d>] =
? put_files_struct+0x60/0xb9
2012-07-06T12:46:15.112575+08:00 timemars kernel: [<ffffffff81130d8d>] =
? exit_sem+0x1e8/0x1f7
2012-07-06T12:46:15.112579+08:00 timemars kernel: [<ffffffff810490e7>] =
? do_exit+0x204/0x6df
2012-07-06T12:46:15.112582+08:00 timemars kernel: [<ffffffff8104983e>] =
? do_group_exit+0x70/0x9a
2012-07-06T12:46:15.112585+08:00 timemars kernel: [<ffffffff810516ff>] =
? get_signal_to_deliver+0x40d/0x42f
2012-07-06T12:46:15.112588+08:00 timemars kernel: [<ffffffff81027796>] =
? do_signal+0x38/0x431
2012-07-06T12:46:15.112591+08:00 timemars kernel: [<ffffffff81051a9f>] =
? copy_siginfo_to_user+0x5c/0x1bb
2012-07-06T12:46:15.112594+08:00 timemars kernel: [<ffffffff810715a5>] =
? sys_futex+0x138/0x147
2012-07-06T12:46:15.112597+08:00 timemars kernel: [<ffffffff81027bc5>] =
? do_notify_resume+0x25/0x50
2012-07-06T12:46:15.112600+08:00 timemars kernel: [<ffffffff8105f152>] =
? should_resched+0x5/0x23
2012-07-06T12:46:15.112603+08:00 timemars kernel: [<ffffffff813d511b>] =
? _cond_resched+0x6/0x1a
2012-07-06T12:46:15.112606+08:00 timemars kernel: [<ffffffff813d6628>] =
? int_signal+0x12/0x17
2012-07-06T12:46:15.112610+08:00 timemars kernel: Code: f5 53 48 89 fb =
48 8b 47 30 48 85 c0 75 11 48 c7 c7 ec 6d 50 81 45 31 e4 e8 1f 67 32 00=
 eb 33 48 8b 47 20 45 31 e4 48 85 c0 74 0e <48> 8b 40 60 48 85 c0 74 05=
 ff d0 41 89 c4 f6 43 3d 40 75 0b 48=20
2012-07-06T12:46:15.112613+08:00 timemars kernel: RIP=A0 [<ffffffff810a=
9bc6>] filp_close+0x30/0x5f
2012-07-06T12:46:15.112616+08:00 timemars kernel: RSP <ffff8800a676bcc8=
>
2012-07-06T12:46:15.112624+08:00 timemars kernel: CR2: ffffff816d9f715f
2012-07-06T12:46:15.179496+08:00 timemars kernel: ---[ end trace deec13=
5ba51c758d ]---
2012-07-06T12:46:15.179516+08:00 timemars kernel: Fixing recursive faul=
t but reboot is needed!

Type 3:
2012-07-07T19:51:52.532199+08:00 timemars NetworkManager[1778]: <warn> =
/sys/devices/virtual/net/vnet0: couldn't determine device driver; ignor=
ing...
2012-07-07T19:51:52.539805+08:00 timemars kernel: device vnet0 entered =
promiscuous mode
2012-07-07T19:51:52.550668+08:00 timemars kernel: virbr0: topology chan=
ge detected, propagating
2012-07-07T19:51:52.550704+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered forwarding state
2012-07-07T19:51:52.550713+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered forwarding state
2012-07-07T19:51:54.245653+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered disabled state
2012-07-07T19:51:54.245680+08:00 timemars kernel: device vnet0 left pro=
miscuous mode
2012-07-07T19:51:54.245684+08:00 timemars kernel: virbr0: port 1(vnet0)=
 entered disabled state
2012-07-07T19:51:54.252041+08:00 timemars kernel: BUG: unable to handle=
 kernel NULL pointer dereference at 0000000000000030
2012-07-07T19:51:54.252071+08:00 timemars kernel: IP: [<ffffffff810d04f=
2>] iput+0x3e/0x191
2012-07-07T19:51:54.252074+08:00 timemars kernel: PGD 0=20
2012-07-07T19:51:54.252078+08:00 timemars kernel: Oops: 0000 [#1] SMP=20
2012-07-07T19:51:54.252080+08:00 timemars kernel: CPU 1=20
2012-07-07T19:51:54.252085+08:00 timemars kernel: Modules linked in:
2012-07-07T19:51:54.252088+08:00 timemars kernel:=20
2012-07-07T19:51:54.252091+08:00 timemars kernel: Pid: 2608, comm: qemu=
-system-x86 Not tainted 3.4.0 #1 Dell Inc. Inspiron 1440=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /0K138P
2012-07-07T19:51:54.252095+08:00 timemars kernel: RIP: 0010:[<ffffffff8=
10d04f2>]=A0 [<ffffffff810d04f2>] iput+0x3e/0x191
2012-07-07T19:51:54.252099+08:00 timemars kernel: RSP: 0018:ffff880102f=
ede58=A0 EFLAGS: 00010246
2012-07-07T19:51:54.252102+08:00 timemars kernel: RAX: 0000000000000001=
 RBX: ffff8800ac78ef20 RCX: ffff88011fd00000
2012-07-07T19:51:54.252105+08:00 timemars kernel: RDX: ffff88011fd00000=
 RSI: ffff8800ac78ef88 RDI: ffff8800ac78ef88
2012-07-07T19:51:54.252108+08:00 timemars kernel: RBP: 0000000000000000=
 R08: 0000000000000000 R09: ffffffff8160c4a0
2012-07-07T19:51:54.252111+08:00 timemars kernel: R10: dead000000200200=
 R11: ffff880118eb3400 R12: 00000000fffcfaf8
2012-07-07T19:51:54.252115+08:00 timemars kernel: R13: 0000000000000000=
 R14: ffff880102fede88 R15: 00000000fffcfaf8
2012-07-07T19:51:54.252118+08:00 timemars kernel: FS:=A0 00007f51766358=
c0(0000) GS:ffff88011fd00000(0000) knlGS:0000000000000000
2012-07-07T19:51:54.252121+08:00 timemars kernel: CS:=A0 0010 DS: 0000 =
ES: 0000 CR0: 000000008005003b
2012-07-07T19:51:54.252124+08:00 timemars kernel: CR2: 0000000000000030=
 CR3: 0000000118d41000 CR4: 00000000000427f0
2012-07-07T19:51:54.252139+08:00 timemars kernel: DR0: 0000000000000000=
 DR1: 0000000000000000 DR2: 0000000000000000
2012-07-07T19:51:54.252142+08:00 timemars kernel: DR3: 0000000000000000=
 DR6: 00000000ffff0ff0 DR7: 0000000000000400
2012-07-07T19:51:54.252145+08:00 timemars kernel: Process qemu-system-x=
86 (pid: 2608, threadinfo ffff880102fec000, task ffff8800a5f3da00)
2012-07-07T19:51:54.252148+08:00 timemars kernel: Stack:
2012-07-07T19:51:54.252151+08:00 timemars kernel: ffff880118eb3400 ffff=
8800ac78e800 00000000fffcfaf8 ffffffff81307563
2012-07-07T19:51:54.252163+08:00 timemars kernel: ffff8800ac78ec00 ffff=
ffff813169ef ffff880102fede88 ffff880102fede88
2012-07-07T19:51:54.252166+08:00 timemars kernel: dead000000100100 ffff=
8801174bc2a0 ffff8800ac78e800 ffff8800ac78ee80
2012-07-07T19:51:54.252169+08:00 timemars kernel: Call Trace:
2012-07-07T19:51:54.252172+08:00 timemars kernel: [<ffffffff81307563>] =
? sk_release_kernel+0x28/0x47
2012-07-07T19:51:54.252175+08:00 timemars kernel: [<ffffffff813169ef>] =
? netdev_run_todo+0x1c9/0x1f3
2012-07-07T19:51:54.252178+08:00 timemars kernel: [<ffffffff81244bb3>] =
? tun_chr_close+0x4c/0x99
2012-07-07T19:51:54.252180+08:00 timemars kernel: [<ffffffff810bf948>] =
? fput+0xf9/0x1ea
2012-07-07T19:51:54.252192+08:00 timemars kernel: [<ffffffff810bd095>] =
? filp_close+0x57/0x5f
2012-07-07T19:51:54.252195+08:00 timemars kernel: [<ffffffff810bd111>] =
? sys_close+0x74/0xb1
2012-07-07T19:51:54.252198+08:00 timemars kernel: [<ffffffff813eaf62>] =
? system_call_fastpath+0x16/0x1b
2012-07-07T19:51:54.252210+08:00 timemars kernel: Code: 00 00 00 40 74 =
02 0f 0b 48 8d 77 68 48 8d bf 00 01 00 00 e8 29 ef 08 00 85 c0 0f 84 59=
 01 00 00 48 8b 6b 18 f6 83 80 00 00 00 08 <4c> 8b 65 30 74 11 be 61 05=
 00 00 48 c7 c7 45 27 52 81 e8 da 5a=20
2012-07-07T19:51:54.252214+08:00 timemars kernel: RIP=A0 [<ffffffff810d=
04f2>] iput+0x3e/0x191
2012-07-07T19:51:54.252217+08:00 timemars kernel: RSP <ffff880102fede58=
>
2012-07-07T19:51:54.252219+08:00 timemars kernel: CR2: 0000000000000030
2012-07-07T19:51:54.298648+08:00 timemars kernel: ---[ end trace 23837b=
1c67685f78 ]---

Best wishes,

Zhijie 		 	   		  
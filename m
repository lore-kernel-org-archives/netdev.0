From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Another oops + repost
Date: Thu, 22 Jul 2010 14:24:39 +0200
Message-ID: <AANLkTin_KDKEejs1ld-qv5jOyuALysjZ8NLC2-786htJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>, 577640@bugs.debian.org,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>,
	Daniel Lezcano <daniel.lezcano@free.fr>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:49982 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755210Ab0GVMYo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 08:24:44 -0400
Received: by ewy23 with SMTP id 23so2836304ewy.19
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 05:24:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

=46irst of all, I would like to know if anybody was able to fix this
problem  that got kinda lost in the thread:

On Thu, Apr 22, 2010 at 16:05, Mart=EDn Ferrari <martin.ferrari@gmail.c=
om> wrote:

> I have just downloaded and compiled 2.6.32-2 and 2.6.34-rc5 from
> kernel.org using the .config from the debian package, and the oops is
> reproducible in both.
>
> This small C file reproduces the error every time:
>
> $ cat netnsoops.c
> #include <stdio.h>
> #include <stdlib.h>
> #define _GNU_SOURCE
> #include <sched.h>
>
> int main(int argc, char *argv[])
> {
> =A0 =A0 =A0 =A0int c;
> =A0 =A0 =A0 =A0unsigned long flags =3D CLONE_NEWNET;
>
> =A0 =A0 =A0 =A0if(unshare(flags) =3D=3D -1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("unshare");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0system("ip link add name FOO type veth peer name BAR")=
;
> =A0 =A0 =A0 =A0system("ip link set FOO netns 1");
> =A0 =A0 =A0 =A0system("ip link show");
> =A0 =A0 =A0 =A0return 0;
> }

Secondly, I discovered another related bug, just more subtle.

I'm creating a dummy device, moving it into a name space and then
taking it back to netns 1. Later, when I delete the dummy, I get an
oops:

[  610.540091] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000028
[  610.541512] IP: [<ffffffff81138f71>] sysfs_find_dirent+0x9/0x2f
[  610.542369] PGD 3799d067 PUD 37bb3067 PMD 0
[  610.543370] Oops: 0000 [#1] SMP
[  610.544018] last sysfs file: /sys/devices/virtual/net/lo/operstate
[  610.544018] CPU 0
[  610.544018] Modules linked in: dummy loop parport_pc parport
snd_pcm snd_timer tpm_tis tpm tpm_bios snd soundcore snd_page_alloc
pcspkr psmouse serio_raw i2c_piix4 evdev i2c_core button processor
ext3 jbd mbcache ide_cd_mod cdrom ide_gd_mod ata_generic ata_piix
8139too libata scsi_mod floppy piix 8139cp mii thermal thermal_sys
ide_core [last unloaded: scsi_wait_scan]
[  610.544018]
[  610.544018] Pid: 1359, comm: ip Tainted: G        W  2.6.34-rc5 #1 /
[  610.544018] RIP: 0010:[<ffffffff81138f71>]  [<ffffffff81138f71>]
sysfs_find_dirent+0x9/0x2f
[  610.544018] RSP: 0018:ffff88003789f988  EFLAGS: 00010296
[  610.544018] RAX: ffff88003789e000 RBX: 0000000000000000 RCX: ffff880=
07d3d2cd8
[  610.544018] RDX: 0000000000000003 RSI: ffffffff814a6352 RDI: 0000000=
000000000
[  610.544018] RBP: ffffffff814a6352 R08: 000000037f80e800 R09: ffff880=
07d3d2ce8
[  610.544018] R10: ffff88007d3d2800 R11: 0000000000000006 R12: fffffff=
f814a6352
[  610.544018] R13: ffff88007d3d2c48 R14: 0000000000000000 R15: ffff880=
03789fbb8
[  610.544018] FS:  00007f22855f7700(0000) GS:ffff880001a00000(0000)
knlGS:0000000000000000
[  610.544018] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  610.544018] CR2: 0000000000000028 CR3: 000000007d4df000 CR4: 0000000=
0000006f0
[  610.544018] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[  610.544018] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[  610.544018] Process ip (pid: 1359, threadinfo ffff88003789e000,
task ffff88007d2b69f0)
[  610.544018] Stack:
[  610.544018]  000000037f80e800 0000000000000000 0000000000000000
ffffffff81138fbb
[  610.544018] <0> 0000000000000296 ffff88007d3d2c38 ffffffff816698d0
ffffffff8113a980
[  610.544018] <0> ffff88007d3d2c38 ffff88007d3d2c38 ffff88007d3d2800
0000000000000000
[  610.544018] Call Trace:
[  610.544018]  [<ffffffff81138fbb>] ? sysfs_get_dirent+0x24/0x43
[  610.544018]  [<ffffffff8113a980>] ? sysfs_remove_group+0x24/0xcf
[  610.544018]  [<ffffffff8120f776>] ? device_del+0x3b/0x1a0
[  610.544018]  [<ffffffff81244139>] ? rollback_registered_many+0x15d/0=
x1c8
[  610.544018]  [<ffffffff8124d81e>] ? rtnetlink_rcv_msg+0x0/0x1f5
[  610.544018]  [<ffffffff81244273>] ? unregister_netdevice_queue+0x78/=
0xa9
[  610.544018]  [<ffffffff8124c22b>] ? rtnl_dellink+0xb7/0xdb
[  610.544018]  [<ffffffff8125e887>] ? netlink_rcv_skb+0x34/0x7c
[  610.544018]  [<ffffffff8124d818>] ? rtnetlink_rcv+0x1f/0x25
[  610.544018]  [<ffffffff8125e67b>] ? netlink_unicast+0xe2/0x148
[  610.544018]  [<ffffffff8125edaf>] ? netlink_sendmsg+0x23f/0x252
[  610.544018]  [<ffffffff8123388d>] ? sock_sendmsg+0x83/0x9b
[  610.544018]  [<ffffffff810b3e0d>] ? __alloc_pages_nodemask+0x10f/0x5=
e2
[  610.544018]  [<ffffffff8123c76f>] ? copy_from_user+0x13/0x25
[  610.544018]  [<ffffffff8123cb25>] ? verify_iovec+0x49/0x84
[  610.544018]  [<ffffffff81233b62>] ? sys_sendmsg+0x225/0x2af
[  610.544018]  [<ffffffff81234e17>] ? sys_recvmsg+0x48/0x56
[  610.544018]  [<ffffffff81008ac2>] ? system_call_fastpath+0x16/0x1b
[  610.544018] Code: fb 74 1a 8b 07 85 c0 75 11 be 9d 00 00 00 48 c7
c7 da 56 4b 81 e8 2b cf f0 ff f0 ff 03 48 89 d8 5b c3 55 48 89 f5 53
48 83 ec 08 <48> 8b 5f 28 eb 14 48 8b 7b 18 48 89 ee e8 46 a4 04 00 85
c0 74
[  610.544018] RIP  [<ffffffff81138f71>] sysfs_find_dirent+0x9/0x2f
[  610.544018]  RSP <ffff88003789f988>
[  610.544018] CR2: 0000000000000028
[  610.597008] ---[ end trace f92104e98ea87a47 ]---


To reproduce:

$ cat netnsoops2.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#define _GNU_SOURCE
#include <sched.h>

int main(int argc, char *argv[])
{
       int pipefd[2];
       pid_t pid;
       unsigned long flags =3D CLONE_NEWNET;

       if(system("ip link add name FOO type dummy"))
	       return 1;
       if(pipe(pipefd) =3D=3D -1) {
               perror("pipe");
               return 1;
       }
       pid =3D fork();
       if(pid =3D=3D -1) {
               perror("fork");
               return 1;
       }
       if(pid) {
	       char buf[256];
	       read(pipefd[0], buf, 1);
	       snprintf(buf, sizeof(buf), "ip link set FOO netns %d", pid);
	       system(buf);
       } else {
	       if(unshare(flags) =3D=3D -1) {
		       perror("unshare");
		       return 1;
	       }
	       write(pipefd[1], "a", 1);
	       system("ip link set FOO netns 1");
	       return 0;
       }
       waitpid(pid, NULL, 0);
       system("ip link show");
       system("ip link del FOO");
       return 0;
}


--=20
Mart=EDn Ferrari

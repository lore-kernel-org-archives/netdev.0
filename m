From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 2.6.27.9: splice_to_pipe() hung (blocked for more than 120 seconds)
Date: Fri, 16 Jan 2009 21:48:54 +0100
Message-ID: <4970F2B6.1060508@cosmosbay.com>
References: <19f34abd0901161055l2edd9274n4b2d8c93e7760488@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:41606 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755265AbZAPUtA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 15:49:00 -0500
In-Reply-To: <19f34abd0901161055l2edd9274n4b2d8c93e7760488@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CCed to netdev

Vegard Nossum a =E9crit :
> Hi,
>=20
> Seeing some recent splice() discussions, I decided to explore this
> system call. I have written a program which might look, well, not ver=
y
> useful, but the fact is that it creates an unkillable zombie process.
> Another funny side effect is that system load continually rises, even
> though the system seems to stay fully interactive and functional.
>=20
> After a while, I also get some messages like this:
>=20
> Jan 15 20:11:37 localhost kernel: INFO: task a.out:7149 blocked for
> more than 120 seconds.
> Jan 15 20:11:37 localhost kernel: "echo 0 >
> /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> Jan 15 20:11:37 localhost kernel: a.out         D ec6e2610     0  714=
9      1
> Jan 15 20:11:37 localhost kernel:       ec5aad44 00000082 c042451f
> ec6e2610 00989680 c07da67c c07ddb80 c07ddb80
> Jan 15 20:11:37 localhost kernel:       c07ddb80 ec6e4c20 ec6e4e7c
> c201db80 00000001 c201db80 470fed45 0000036b
> Jan 15 20:11:37 localhost kernel:       ec5aad38 c0421027 ec6e263c
> ec6e4e7c ec6e3fa8 85c129f4 ec6e4c20 ec6e4c20
> Jan 15 20:11:37 localhost kernel: Call Trace:
> Jan 15 20:11:37 localhost kernel: [<c064420f>] __mutex_lock_common+0x=
8a/0xd9
> Jan 15 20:11:37 localhost kernel: [<c0644302>] __mutex_lock_slowpath+=
0x12/0x15
> Jan 15 20:11:37 localhost kernel: [<c0644181>] mutex_lock+0x29/0x2d
> Jan 15 20:11:37 localhost kernel: [<c04aa8f1>] splice_to_pipe+0x23/0x=
1f5
> Jan 15 20:11:37 localhost kernel: [<c04ab290>]
> __generic_file_splice_read+0x3ff/0x413
> Jan 15 20:11:37 localhost kernel: [<c04ab324>]
> generic_file_splice_read+0x80/0x9a
> Jan 15 20:11:37 localhost kernel: [<c04a9e95>] do_splice_to+0x4e/0x5f
> Jan 15 20:11:37 localhost kernel: [<c04aa010>] sys_splice+0x16a/0x1c8
> Jan 15 20:11:37 localhost kernel: [<c0403cca>] syscall_call+0x7/0xb
> Jan 15 20:11:37 localhost kernel: =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> (but this was from such a system with 6 zombies and ~80 load. See
> attachments for SysRq report with processes in blocked state, it has
> similar info but for just one zombie.)
>=20
> This happens with 2.6.27.9-73.fc9.i686 kernel. Maybe it was fixed
> recently? (In any case, I don't think it is a regression.)
>=20
> It seems to be not 100% reproducible. Sometimes it works, sometimes
> not. Start the program, then after a while hit Ctrl-C. If it doesn't
> exit, zombie count will rise and system state will be as described.
> Compile with -lpthread.
>=20

I tried your program on latest git tree and could not reproduce any pro=
blem.

(changed to 9 threads since I have 8 cpus)

Problem might be that your threads all fight on the same pipe, with
a mutex protecting its inode.


So mutex_lock() could possibly starve for more than 120 second ?

Maybe you can reproduce the problem using standard read()/write() sysca=
lls...


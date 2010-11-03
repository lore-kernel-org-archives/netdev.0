From: Dave Chinner <david@fromorbit.com>
Subject: Re: [regression, 2.6.37-rc1] 'ip link tap0 up' stuck in do_exit()
Date: Wed, 3 Nov 2010 21:34:48 +1100
Message-ID: <20101103103448.GA9169@dastard>
References: <20101103062609.GB31163@dastard>
 <1288768402.2467.665.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bld-mail12.adl6.internode.on.net ([150.101.137.97]:39554 "EHLO
	mail.internode.on.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753914Ab0KCKew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 06:34:52 -0400
Content-Disposition: inline
In-Reply-To: <1288768402.2467.665.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 03, 2010 at 08:13:22AM +0100, Eric Dumazet wrote:
> Le mercredi 03 novembre 2010 =E0 17:26 +1100, Dave Chinner a =E9crit =
:
> > Folks,
> >=20
> > Starting up KVM on a current mainline kernel using the tap
> > device for the networking is resulting in the ip process tryin gto
> > up the tap interface hanging. KVM is started with this networking
> > config:
> >=20
> > ....
> >         -net nic,vlan=3D0,macaddr=3D00:e4:b6:63:63:6d,model=3Dvirti=
o \
> >         -net tap,vlan=3D0,script=3D/vm-images/qemu-ifup,downscript=3D=
no \
> > ....
> >=20
> > And the script is effectively:
> >=20
> > switch=3Dbr0
> > if [ -n "$1" ];then
> >         /usr/bin/sudo /sbin/ip link set $1 up
> >         sleep 0.5s
> >         /usr/bin/sudo /usr/sbin/brctl addif $switch $1
> > 	exit 0
> > fi
> > exit 1
> >=20
> > This is resulting in the command 'ip link set tap0 up' hanging as a=
 zombie:
> >=20
> > root      3005     1  0 16:53 pts/3    00:00:00 /bin/sh /vm-images/=
qemu-ifup tap0
> > root      3011  3005  0 16:53 pts/3    00:00:00 /usr/bin/sudo /sbin=
/ip link set tap0 up
> > root      3012  3011  0 16:53 pts/3    00:00:00 [ip] <defunct>
> >=20
> > In do_exit() with this trace:
> >=20
> > [ 1630.782255] ip            x ffff88063fcb3600     0  3012   3011 =
0x00000000
> > [ 1630.789121]  ffff880631328000 0000000000000046 0000000000000000 =
ffff880633104380
> > [ 1630.796524]  0000000000013600 ffff88062f031fd8 0000000000013600 =
0000000000013600
> > [ 1630.803925]  ffff8806313282d8 ffff8806313282e0 ffff880631328000 =
0000000000013600
> > [ 1630.811324] Call Trace:
> > [ 1630.813760]  [<ffffffff8104a90d>] ? do_exit+0x716/0x724
> > [ 1630.818964]  [<ffffffff8104a995>] ? do_group_exit+0x7a/0xa4
> > [ 1630.824512]  [<ffffffff8104a9d1>] ? sys_exit_group+0x12/0x16
> > [ 1630.830149]  [<ffffffff81009a82>] ? system_call_fastpath+0x16/0x=
1b
> >=20
> > The address comes down to the schedule() call:
> >=20
> > (gdb) l *(do_exit+0x716)
> > 0xffffffff8104a90d is in do_exit (kernel/exit.c:1034).
> > 1029            preempt_disable();
> > 1030            exit_rcu();
> > 1031            /* causes final put_task_struct in finish_task_swit=
ch(). */
> > 1032            tsk->state =3D TASK_DEAD;
> > 1033            schedule();
> > 1034            BUG();
> > 1035            /* Avoid "noreturn function does return".  */
> > 1036            for (;;)
> > 1037                    cpu_relax();    /* For when BUG is null */
> > 1038    }
> >=20
> > Needless to say, KVM is not starting up. This works just fine on
> > 2.6.35.1 and so is a regression. I can't do a lot of testing on thi=
s as
> > the host is the machine that hosts all my build and test environmen=
ts....
> >=20
> > Cheers,
> >=20
> > Dave.
>=20
> Could it be the same problem than=20
>=20
> http://kerneltrap.com/mailarchive/linux-netdev/2010/10/23/6288128
>=20
> Try to revert bee31369ce16fc3898ec9a54161248c9eddb06bc ?

It's working fine on 2.6.36 right now, so it's something that came in
with the .37 merge cycle...

Cheers,

Dave.
--=20
Dave Chinner
david@fromorbit.com

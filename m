From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [regression, 2.6.37-rc1] 'ip link tap0 up' stuck in do_exit()
Date: Thu, 4 Nov 2010 13:47:18 +0800
Message-ID: <20101104054718.GC5210@cr0.nay.redhat.com>
References: <20101103062609.GB31163@dastard>
 <1288768402.2467.665.camel@edumazet-laptop>
 <20101103103448.GA9169@dastard>
 <20101103112936.GB9169@dastard>
 <20101104002140.GA13830@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Dave Chinner <david@fromorbit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61998 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187Ab0KDFmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 01:42:35 -0400
Content-Disposition: inline
In-Reply-To: <20101104002140.GA13830@dastard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 04, 2010 at 11:21:40AM +1100, Dave Chinner wrote:
>On Wed, Nov 03, 2010 at 10:29:36PM +1100, Dave Chinner wrote:
>> On Wed, Nov 03, 2010 at 09:34:48PM +1100, Dave Chinner wrote:
>> > On Wed, Nov 03, 2010 at 08:13:22AM +0100, Eric Dumazet wrote:
>> > > Le mercredi 03 novembre 2010 =C3=A0 17:26 +1100, Dave Chinner a =
=C3=A9crit :
>> > > > Folks,
>> > > >=20
>> > > > Starting up KVM on a current mainline kernel using the tap
>> > > > device for the networking is resulting in the ip process tryin=
 gto
>> > > > up the tap interface hanging. KVM is started with this network=
ing
>> > > > config:
>> > > >=20
>> > > > ....
>> > > >         -net nic,vlan=3D0,macaddr=3D00:e4:b6:63:63:6d,model=3D=
virtio \
>> > > >         -net tap,vlan=3D0,script=3D/vm-images/qemu-ifup,downsc=
ript=3Dno \
>> > > > ....
>> > > >=20
>> > > > And the script is effectively:
>> > > >=20
>> > > > switch=3Dbr0
>> > > > if [ -n "$1" ];then
>> > > >         /usr/bin/sudo /sbin/ip link set $1 up
>> > > >         sleep 0.5s
>> > > >         /usr/bin/sudo /usr/sbin/brctl addif $switch $1
>> > > > 	exit 0
>> > > > fi
>> > > > exit 1
>> > > >=20
>> > > > This is resulting in the command 'ip link set tap0 up' hanging=
 as a zombie:
>> > > >=20
>> > > > root      3005     1  0 16:53 pts/3    00:00:00 /bin/sh /vm-im=
ages/qemu-ifup tap0
>> > > > root      3011  3005  0 16:53 pts/3    00:00:00 /usr/bin/sudo =
/sbin/ip link set tap0 up
>> > > > root      3012  3011  0 16:53 pts/3    00:00:00 [ip] <defunct>
>> > > >=20
>> > > > In do_exit() with this trace:
>> > > >=20
>> > > > [ 1630.782255] ip            x ffff88063fcb3600     0  3012   =
3011 0x00000000
>> > > > [ 1630.789121]  ffff880631328000 0000000000000046 000000000000=
0000 ffff880633104380
>> > > > [ 1630.796524]  0000000000013600 ffff88062f031fd8 000000000001=
3600 0000000000013600
>> > > > [ 1630.803925]  ffff8806313282d8 ffff8806313282e0 ffff88063132=
8000 0000000000013600
>> > > > [ 1630.811324] Call Trace:
>> > > > [ 1630.813760]  [<ffffffff8104a90d>] ? do_exit+0x716/0x724
>> > > > [ 1630.818964]  [<ffffffff8104a995>] ? do_group_exit+0x7a/0xa4
>> > > > [ 1630.824512]  [<ffffffff8104a9d1>] ? sys_exit_group+0x12/0x1=
6
>> > > > [ 1630.830149]  [<ffffffff81009a82>] ? system_call_fastpath+0x=
16/0x1b
>> > > >=20
>> > > > The address comes down to the schedule() call:
>> > > >=20
>> > > > (gdb) l *(do_exit+0x716)
>> > > > 0xffffffff8104a90d is in do_exit (kernel/exit.c:1034).
>> > > > 1029            preempt_disable();
>> > > > 1030            exit_rcu();
>> > > > 1031            /* causes final put_task_struct in finish_task=
_switch(). */
>> > > > 1032            tsk->state =3D TASK_DEAD;
>> > > > 1033            schedule();
>> > > > 1034            BUG();
>> > > > 1035            /* Avoid "noreturn function does return".  */
>> > > > 1036            for (;;)
>> > > > 1037                    cpu_relax();    /* For when BUG is nul=
l */
>> > > > 1038    }
>> > > >=20
>> > > > Needless to say, KVM is not starting up. This works just fine =
on
>> > > > 2.6.35.1 and so is a regression. I can't do a lot of testing o=
n this as
>> > > > the host is the machine that hosts all my build and test envir=
onments....
>> > > >=20
>> > > > Cheers,
>> > > >=20
>> > > > Dave.
>> > >=20
>> > > Could it be the same problem than=20
>> > >=20
>> > > http://kerneltrap.com/mailarchive/linux-netdev/2010/10/23/628812=
8
>> > >=20
>> > > Try to revert bee31369ce16fc3898ec9a54161248c9eddb06bc ?
>> >=20
>> > It's working fine on 2.6.36 right now, so it's something that came=
 in
>> > with the .37 merge cycle...
>>=20
>> Actually, the machine isn't running a 2.6.36 kernel (it had booted
>> to the working .35 kernel and I didn't notice). So i've just tested
>> a 2.6.36 kernel, and the problem _is present_ in 2.6.36. I've
>> reverted the above commit but that does not fix the problem.
>
>Ok, so further investigation has shown I can reproduce this on
>2.6.32 and 2.6.35. It's not a new bug, nor do I think that it is
>a networking bug as it is not specific to the ip command.
>
>The trigger for the problem is actually an upgrade of the sudo
>package in debian unstable which changed the behaviour of sudo (has
>some per-login/pty restriction on it now). Basically, the startup
>script I'm running does:
>
>sudo kvm .....
>
>which then executes the qemu-ifup bash script which does:
>
>	sudo ip ....
>	sudo brctl ...
>
>because at one point KVM did not create the tap device automatically
>and so kvm could be run as a user with only the ifup script
>requiring privileges to create the tap device and mark it up. When
>KVM started creating the tap device, I added the sudo to the KVM
>script, an everything worked again.
>
>Now if I take the 'sudo' out of the ifup script, the hang goes away.
>I first removed it from the ip command, and then the brctl command
>hung in the same way the ip command was hanging. Hence my thoughts
>that it is not directly related to networking utilities.
>Unfortunately, it is not trivial to reproduce as I could only
>trigger it through this kvm method, not on the command line. e.g:
>
>$ sudo bash -c "sudo ip link set tap1 up"
>
>does not hang.
>
>This sudo package upgrade coincided with kernel upgrades, and so
>that lead to my confusion about where it occurred and what triggered
>it.  Still, it appears to be a bug that has been around for some
>time.....
>

Interesting, the scheduler failed to put the dead task out of
run queue, so to me this is likely to be a scheduler bug.
I have no idea how sudo can change the behaviour here.

Another guess is we need a smp_wmb() before schedule() above.

We need to Cc Oleg and Ingo.

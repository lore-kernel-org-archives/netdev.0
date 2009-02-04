From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Wed, 04 Feb 2009 19:11:36 +0100
Message-ID: <4989DA58.3060203@cosmosbay.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain> <498723D9.5020509@athenacr.com> <20090203115502.GB28117@hmsreliant.think-freely.org> <498860AD.5010702@athenacr.com> <20090204011541.GB3650@localhost.localdomain> <4989BD31.306@athenacr.com> <EA667848-C7EA-4409-B64D-9752C8ACECB6@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Kenny Chang <kchang@athenacr.com>
To: Wesley Chow <wchow@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35825 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbZBDSLq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 13:11:46 -0500
In-Reply-To: <EA667848-C7EA-4409-B64D-9752C8ACECB6@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wesley Chow a =E9crit :
>>>>>>
>>>>>>
>>>>> Are these quad core systems?  Or dual core w/ hyperthreading?  I
>>>>> ask because in
>>>>> your working setup you have 1/2 the number of cpus' and was not
>>>>> sure if you
>>>>> removed an entire package of if you just disabled hyperthreading.
>>>>>
>>>>>
>>>>> Neil
>>>>>
>>>>>
>>>> Yeah, these are quad core systems.  The 8 cpu system is a
>>>> dual-processor  quad-core.  The other is my desktop, single cpu qu=
ad
>>>> core.
>>>>
>>>>
>=20
>=20
> Just to be clear: on the 2 x quad core system, we can run with a 2.6.=
15
> kernel and see no packet drops. In fact, we can run with 2.6.19, 2.6.=
20,
> and 2.6.21 just fine. 2.6.22 is the first kernel that shows problems.
>=20
> Kenny posted results from a working setup on a different machine.
>=20
> What I would really like to know is if whatever changed between 2.6.2=
1
> and 2.6.22 that broke things is confined just to bnx2. To make this a
> rigorous test, we would need to use the same machine with a different
> nic, which we don't have quite yet. An Intel Pro 1000 ethernet card i=
s
> in the mail as I type this.
>=20
> I also tried forward porting the bnx2 driver in 2.6.21 to 2.6.22
> (unsuccessfully), and building the most recent driver from the Broadc=
om
> site to Ubuntu Hardy's 2.6.24. The most recent driver with hardy 2.6.=
24
> showed similar packet dropping problems. Hm, perhaps I'll try to buil=
d
> the most recent broadcom driver against 2.6.21.
>=20

Try oprofile session, you shall see a scheduler effect (dont want to ca=
ll
this a regression, no need for another flame war).

also give us "vmstat 1" results  (number of context switches per second=
)

On recent kernels, scheduler might be faster than before: You get more =
wakeups per
second and more work to do by softirq handler (it does more calls to sc=
heduler,
thus less cpu cycles available for draining NIC RX queue in time)

opcontrol --vmlinux=3D/path/vmlinux --start
<run benchmark>
opreport -l /path/vmlinux | head -n 50

Recent schedulers tend to be optimum for lower latencies (and thus, on
a high level of wakeups, you get less bandwidth because of sofirq using
a whole CPU)

=46or example, if you have one tread receiving data on 4 or 8 sockets, =
you'll
probably notice better throughput (because it will sleep less often)

Multicast receiving on N sockets, with one thread waiting on each socke=
t
is basically a way to trigger a scheduler storm. (N wakeups per packet)=
=2E
So its more a benchmark to stress scheduler than stressing network stac=
k...


Maybe its time to change user side, and not try to find an appropriate =
kernel :)

If you know you have to receive N frames per 20us units, then its bette=
r to :
Use non blocking sockets, and doing such loop :

{
usleep(20); // or try to compensate if this thread is slowed too much b=
y following code
for (i =3D 0 ; i < N ; i++) {
	while (revfrom(socket[N], ....) !=3D -1)
		receive_frame(...);
	}
}

That way, you are pretty sure network softirq handler wont have to spen=
d time trying
to wakeup 400.000 time per second one thread. All cpu cycles can be spe=
nt in NIC driver
and network stack.

Your thread will do 50.000 calls to nanosleep() per second, that is not=
 really expensive,
then N recvfrom() per iteration. It should work on all past , current a=
nd future kernels.



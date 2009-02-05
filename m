From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Multicast packet loss
Date: Thu, 5 Feb 2009 08:33:41 -0500
Message-ID: <20090205133341.GC15621@hmsreliant.think-freely.org>
References: <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain> <498723D9.5020509@athenacr.com> <20090203115502.GB28117@hmsreliant.think-freely.org> <498860AD.5010702@athenacr.com> <20090204011541.GB3650@localhost.localdomain> <4989BD31.306@athenacr.com> <EA667848-C7EA-4409-B64D-9752C8ACECB6@athenacr.com> <4989DA58.3060203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wesley Chow <wchow@athenacr.com>, netdev@vger.kernel.org,
	Kenny Chang <kchang@athenacr.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50628 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996AbZBENdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 08:33:52 -0500
Content-Disposition: inline
In-Reply-To: <4989DA58.3060203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2009 at 07:11:36PM +0100, Eric Dumazet wrote:
> Wesley Chow a =E9crit :
> >>>>>>
> >>>>>>
> >>>>> Are these quad core systems?  Or dual core w/ hyperthreading?  =
I
> >>>>> ask because in
> >>>>> your working setup you have 1/2 the number of cpus' and was not
> >>>>> sure if you
> >>>>> removed an entire package of if you just disabled hyperthreadin=
g.
> >>>>>
> >>>>>
> >>>>> Neil
> >>>>>
> >>>>>
> >>>> Yeah, these are quad core systems.  The 8 cpu system is a
> >>>> dual-processor  quad-core.  The other is my desktop, single cpu =
quad
> >>>> core.
> >>>>
> >>>>
> >=20
> >=20
> > Just to be clear: on the 2 x quad core system, we can run with a 2.=
6.15
> > kernel and see no packet drops. In fact, we can run with 2.6.19, 2.=
6.20,
> > and 2.6.21 just fine. 2.6.22 is the first kernel that shows problem=
s.
> >=20
> > Kenny posted results from a working setup on a different machine.
> >=20
> > What I would really like to know is if whatever changed between 2.6=
=2E21
> > and 2.6.22 that broke things is confined just to bnx2. To make this=
 a
> > rigorous test, we would need to use the same machine with a differe=
nt
> > nic, which we don't have quite yet. An Intel Pro 1000 ethernet card=
 is
> > in the mail as I type this.
> >=20
> > I also tried forward porting the bnx2 driver in 2.6.21 to 2.6.22
> > (unsuccessfully), and building the most recent driver from the Broa=
dcom
> > site to Ubuntu Hardy's 2.6.24. The most recent driver with hardy 2.=
6.24
> > showed similar packet dropping problems. Hm, perhaps I'll try to bu=
ild
> > the most recent broadcom driver against 2.6.21.
> >=20
>=20
> Try oprofile session, you shall see a scheduler effect (dont want to =
call
> this a regression, no need for another flame war).
>=20
> also give us "vmstat 1" results  (number of context switches per seco=
nd)
>=20
> On recent kernels, scheduler might be faster than before: You get mor=
e wakeups per
> second and more work to do by softirq handler (it does more calls to =
scheduler,
> thus less cpu cycles available for draining NIC RX queue in time)
>=20
> opcontrol --vmlinux=3D/path/vmlinux --start
> <run benchmark>
> opreport -l /path/vmlinux | head -n 50
>=20
> Recent schedulers tend to be optimum for lower latencies (and thus, o=
n
> a high level of wakeups, you get less bandwidth because of sofirq usi=
ng
> a whole CPU)
>=20
> For example, if you have one tread receiving data on 4 or 8 sockets, =
you'll
> probably notice better throughput (because it will sleep less often)
>=20
> Multicast receiving on N sockets, with one thread waiting on each soc=
ket
> is basically a way to trigger a scheduler storm. (N wakeups per packe=
t).
> So its more a benchmark to stress scheduler than stressing network st=
ack...
>=20
>=20
> Maybe its time to change user side, and not try to find an appropriat=
e kernel :)
>=20
> If you know you have to receive N frames per 20us units, then its bet=
ter to :
> Use non blocking sockets, and doing such loop :
>=20
> {
> usleep(20); // or try to compensate if this thread is slowed too much=
 by following code
> for (i =3D 0 ; i < N ; i++) {
> 	while (revfrom(socket[N], ....) !=3D -1)
> 		receive_frame(...);
> 	}
> }
>=20
> That way, you are pretty sure network softirq handler wont have to sp=
end time trying
> to wakeup 400.000 time per second one thread. All cpu cycles can be s=
pent in NIC driver
> and network stack.
>=20
> Your thread will do 50.000 calls to nanosleep() per second, that is n=
ot really expensive,
> then N recvfrom() per iteration. It should work on all past , current=
 and future kernels.
>=20
+1 to this idea.  Since the last oprofile traces showed significant var=
iance in
the time spent in schedule(), it might be worthwhile to investigate the=
 affects
of the application behavior on this.  I might also be worth adding a sy=
stemtap
probe to sys_recvmsg, to count how many times we receive frames on a wo=
rking and
non-working system.  If the app is behaving differently on different ke=
rnels,
and its affecting the number of times you go to get a frame out of the =
stack,
that would affect your drop rates, and it would show up in sys_recvmsg

Neil


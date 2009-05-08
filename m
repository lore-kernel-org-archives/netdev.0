From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v4 somewhat-expedited "big hammer" RCU grace
	periods
Date: Fri, 8 May 2009 11:05:25 -0700
Message-ID: <20090508180525.GK6788@linux.vnet.ibm.com>
References: <20090508170815.GA9708@linux.vnet.ibm.com> <4A046BBF.9070400@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755081AbZEHSFo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A046BBF.9070400@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 08, 2009 at 07:28:31PM +0200, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
> > Fourth cut of "big hammer" expedited RCU grace periods.  This uses
> > a kthread that schedules itself on all online CPUs in turn, thus
> > forcing a grace period.  The synchronize_sched(), synchronize_rcu()=
,
> > and synchronize_bh() primitives wake this kthread up and then wait =
for
> > it to force the grace period.
> >=20
> > As before, this does nothing to expedite callbacks already register=
ed
> > with call_rcu() or call_rcu_bh(), but there is no need to.  Just ma=
ps
> > to synchronize_rcu() and a new synchronize_rcu_bh() on preemptable =
RCU,
> > which has more complex grace-period detection -- this can be fixed =
later.
> >=20
> > Passes light rcutorture testing.  Grace periods take around 200
> > microseconds on an 8-CPU Power machine.  This is a good order of ma=
gnitude
> > better than v3, but an order of magnitude slower than v2.  Furtherm=
ore,
> > it will get slower the more CPUs you have, and eight CPUs is not al=
l
> > that many these days.  So this implementation still does not cut it=
=2E
> >=20
> > Once again, I am posting this on the off-chance that I made some st=
upid
> > mistake that someone might spot.  Absent that, I am taking yet anot=
her
> > different approach, namely setting up per-CPU threads that are awak=
ened
> > via smp_call_function(), permitting the quiescent states to be wait=
ed
> > for in parallel.
> >=20
>=20
> I dont know, dont we have possibility one cpu is dedicated for the us=
e
> of a cpu hungry real time thread ?
>=20
> krcu_sched_expedited() would dead lock or something ?

Good point!!!

One approach would be to use a prio-99 RT per-CPU thread that sleeps
unless/until an expedited grace period is required.

Aggressive real-time workloads would need to avoid doing things (like
changing networking configuration) that require expedited grace periods=
=2E

Seem reasonable?

							Thanx, Paul

> > Shortcomings:
> >=20
> > o	Too slow!!!  Thinking in terms of using per-CPU kthreads.
> >=20
> > o	The wait_event() calls result in 120-second warnings, need
> > 	to use something like wait_event_interruptible().  There are
> > 	probably other corner cases that need attention.
> >=20
> > o	Does not address preemptable RCU.
> >=20
> > Changes since v3:
> >=20
> > o	Use a kthread that schedules itself on each CPU in turn to
> > 	force a grace period.  The synchronize_rcu() primitive
> > 	wakes up the kthread in order to avoid messing with affinity
> > 	masks on user tasks.
> >=20
> > o	Tried a number of additional variations on the v3 approach, none
> > 	of which helped much.
> >=20
> > Changes since v2:
> >=20
> > o	Use reschedule IPIs rather than a softirq.
> >=20
> > Changes since v1:
> >=20
> > o	Added rcutorture support, and added exports required by
> > 	rcutorture.
> >=20
> > o	Added comment stating that smp_call_function() implies a
> > 	memory barrier, suggested by Mathieu.
> >=20
> > o	Added #include for delay.h.
> >=20
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > ---
> >=20
> >  include/linux/rcuclassic.h |   16 +++
> >  include/linux/rcupdate.h   |   24 ++---
> >  include/linux/rcupreempt.h |   10 ++
> >  include/linux/rcutree.h    |   13 ++
> >  kernel/rcupdate.c          |  103 +++++++++++++++++++++++
> >  kernel/rcupreempt.c        |    1=20
> >  kernel/rcutorture.c        |  200 ++++++++++++++++++++++++--------=
-------------
> >  7 files changed, 261 insertions(+), 106 deletions(-)
> >=20
>=20
> > +/*
> > + * Kernel thread that processes synchronize_sched_expedited() requ=
ests.
> > + * This is implemented as a separate kernel thread to avoid the ne=
ed
> > + * to mess with other tasks' cpumasks.
> > + */
> > +static int krcu_sched_expedited(void *arg)
> > +{
> > +	int cpu;
> > +
> > +	do {
> > +		wait_event(need_sched_expedited_wq, need_sched_expedited);
> > +		need_sched_expedited =3D 0;
> > +		get_online_cpus();
> > +		for_each_online_cpu(cpu) {
> > +			sched_setaffinity(0, &cpumask_of_cpu(cpu));
> > +			schedule();
>=20
> <<no return>>
>=20
> > +		}
> > +		put_online_cpus();
> > +		sched_expedited_done =3D 1;
> > +		wake_up(&sched_expedited_done_wq);
> > +	} while (!kthread_should_stop());
> > +	return 0;
> > +}
>=20
>=20

From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH RFC] v4 somewhat-expedited "big hammer" RCU grace periods
Date: Fri, 08 May 2009 19:28:31 +0200
Message-ID: <4A046BBF.9070400@cosmosbay.com>
References: <20090508170815.GA9708@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42980 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755259AbZEHRae convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 13:30:34 -0400
In-Reply-To: <20090508170815.GA9708@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> Fourth cut of "big hammer" expedited RCU grace periods.  This uses
> a kthread that schedules itself on all online CPUs in turn, thus
> forcing a grace period.  The synchronize_sched(), synchronize_rcu(),
> and synchronize_bh() primitives wake this kthread up and then wait fo=
r
> it to force the grace period.
>=20
> As before, this does nothing to expedite callbacks already registered
> with call_rcu() or call_rcu_bh(), but there is no need to.  Just maps
> to synchronize_rcu() and a new synchronize_rcu_bh() on preemptable RC=
U,
> which has more complex grace-period detection -- this can be fixed la=
ter.
>=20
> Passes light rcutorture testing.  Grace periods take around 200
> microseconds on an 8-CPU Power machine.  This is a good order of magn=
itude
> better than v3, but an order of magnitude slower than v2.  Furthermor=
e,
> it will get slower the more CPUs you have, and eight CPUs is not all
> that many these days.  So this implementation still does not cut it.
>=20
> Once again, I am posting this on the off-chance that I made some stup=
id
> mistake that someone might spot.  Absent that, I am taking yet anothe=
r
> different approach, namely setting up per-CPU threads that are awaken=
ed
> via smp_call_function(), permitting the quiescent states to be waited
> for in parallel.
>=20

I dont know, dont we have possibility one cpu is dedicated for the use
of a cpu hungry real time thread ?

krcu_sched_expedited() would dead lock or something ?

> Shortcomings:
>=20
> o	Too slow!!!  Thinking in terms of using per-CPU kthreads.
>=20
> o	The wait_event() calls result in 120-second warnings, need
> 	to use something like wait_event_interruptible().  There are
> 	probably other corner cases that need attention.
>=20
> o	Does not address preemptable RCU.
>=20
> Changes since v3:
>=20
> o	Use a kthread that schedules itself on each CPU in turn to
> 	force a grace period.  The synchronize_rcu() primitive
> 	wakes up the kthread in order to avoid messing with affinity
> 	masks on user tasks.
>=20
> o	Tried a number of additional variations on the v3 approach, none
> 	of which helped much.
>=20
> Changes since v2:
>=20
> o	Use reschedule IPIs rather than a softirq.
>=20
> Changes since v1:
>=20
> o	Added rcutorture support, and added exports required by
> 	rcutorture.
>=20
> o	Added comment stating that smp_call_function() implies a
> 	memory barrier, suggested by Mathieu.
>=20
> o	Added #include for delay.h.
>=20
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
>=20
>  include/linux/rcuclassic.h |   16 +++
>  include/linux/rcupdate.h   |   24 ++---
>  include/linux/rcupreempt.h |   10 ++
>  include/linux/rcutree.h    |   13 ++
>  kernel/rcupdate.c          |  103 +++++++++++++++++++++++
>  kernel/rcupreempt.c        |    1=20
>  kernel/rcutorture.c        |  200 ++++++++++++++++++++++++----------=
-----------
>  7 files changed, 261 insertions(+), 106 deletions(-)
>=20

> +/*
> + * Kernel thread that processes synchronize_sched_expedited() reques=
ts.
> + * This is implemented as a separate kernel thread to avoid the need
> + * to mess with other tasks' cpumasks.
> + */
> +static int krcu_sched_expedited(void *arg)
> +{
> +	int cpu;
> +
> +	do {
> +		wait_event(need_sched_expedited_wq, need_sched_expedited);
> +		need_sched_expedited =3D 0;
> +		get_online_cpus();
> +		for_each_online_cpu(cpu) {
> +			sched_setaffinity(0, &cpumask_of_cpu(cpu));
> +			schedule();

<<no return>>

> +		}
> +		put_online_cpus();
> +		sched_expedited_done =3D 1;
> +		wake_up(&sched_expedited_done_wq);
> +	} while (!kthread_should_stop());
> +	return 0;
> +}



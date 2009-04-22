From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Wed, 22 Apr 2009 09:35:24 +0200
Message-ID: <20090422073524.GA31835@elte.hu>
References: <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam> <20090421191007.GA15485@elte.hu> <49EE2293.4090201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49EE2293.4090201@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> Ingo Molnar a =E9crit :
> >=20
> > Why not use the obvious solution: a _single_ wrlock for global=20
> > access and read_can_lock() plus per cpu locks in the fastpath?
>=20
> Obvious is not the qualifier I would use :)
>=20
> Brilliant yes :)

thanks :)

> > That way there's no global cacheline bouncing (just the=20
> > _reading_ of a global cacheline - which will be nicely localized=20
> > - on NUMA too) - and we will hold at most 1-2 locks at once!
> >=20
> > Something like:
> >=20
> > 	__cacheline_aligned DEFINE_RWLOCK(global_wrlock);
> >=20
> > 	DEFINE_PER_CPU(rwlock_t local_lock);
> >=20
> >=20
> > 	void local_read_lock(void)
> > 	{
> > 	again:
> > 		read_lock(&per_cpu(local_lock, this_cpu));
>=20
> Hmm... here we can see global_wrlock locked by on writer, while=20
> this cpu already called local_read_lock(), and calls again this=20
> function -> Deadlock, because we hold our local_lock locked.

Yeah, indeed.

I wasnt really concentrating on the nested case, i was concentrating=20
on the scalability and lock nesting angle. I think the code=20
submitted here looks rather incestous in that regard.

Allowing nested locking _on the same CPU_ is asking for trouble. Use=20
short critical sections and if there's any exclusion needed, use an=20
irq-safe lock or a softirq-safe lock. Problem solved.

> Very interesting and could be changed to use spinlock + depth per=20
> cpu.
>=20
> -> we can detect recursion and avoid the deadlock, and we only use=20
> one atomic operation per lock/unlock pair in fastpath (this was=20
> the reason we tried hard to use a percpu spinlock during this=20
> thread)
>=20
>=20
> __cacheline_aligned DEFINE_RWLOCK(global_wrlock);
>=20
> struct ingo_local_lock {
> 	spinlock_t lock;
> 	int depth;
> };
> DEFINE_PER_CPU(struct ingo_local_lock local_lock);
>=20
>=20
> void local_read_lock(void)
> {
> 	struct ingo_local_lock *lck;
>=20
> 	local_bh_and_preempt_disable();
> 	lck =3D &get_cpu_var(local_lock);
> 	if (++lck->depth > 0) /* already locked */
> 		return;
> again:
> 	spin_lock(&lck->lock);
>=20
> 	if (unlikely(!read_can_lock(&global_wrlock))) {
> 		spin_unlock(&lck->lock);
> 		/*
> 		 * Just wait for any global write activity:
> 		 */
> 		read_unlock_wait(&global_wrlock);
> 		goto again;
> 	}
> }
>=20
> void global_write_lock(void)
> {
> 	write_lock(&global_wrlock);
>=20
> 	for_each_possible_cpu(i)
> 		spin_unlock_wait(&per_cpu(local_lock, i));
> }
>=20
> Hmm ?

Yeah, this looks IRQ-nesting safe. But i really have to ask: why=20
does this code try so hard to allow same-CPU nesting?

Nesting on the same CPU is _bad_ for several reasons:

1) Performance: it rips apart critical sections cache-wise. Instead=20
   of a nice:

       C1 ... C2 ... C3 ... C4

   serial sequence of critical sections, we get:
=20
       C1A ... ( C2 ) ... C1B ... C3 ... C4

   Note that C1 got "ripped apart" into C1A and C1B with C2 injected=20
   - reducing cache locality between C1A and C1B. We have to execute
   C1B no matter what, so we didnt actually win anything in terms of=20
   total work to do, by processing C2 out of order.

   [ Preemption of work (which this kind of nesting is really about)
     is _the anti-thesis of performance_, and we try to delay it as
     much as possible and we try to batch up as much as possible.=20
     For example the CPU scheduler will try _real_ hard to not=20
     preempt a typical workload, as long as external latency=20
     boundaries allow that. ]

2) Locking complexity and robustness. Nested locking is rank #1 in
   terms of introducing regressions into the kernel.

3) Instrumentation/checking complexity. Checking locking=20
   dependencies is good and catches a boatload of bugs before they=20
   hit upstream, and nested locks are supported but cause an=20
   exponential explosion in terms of dependencies to check.

   Also, whenever instrumentation explodes is typically the sign of=20
   some true, physical complexity that has been introduced into the=20
   code. So it often is a canary for a misdesign at a fundamental=20
   level, not a failure in the instrumentation framework.

In the past i saw lock nesting often used as a wrong solution when=20
the critical sections were too long (causing too long latencies for=20
critical work - e.g. delaying hardirq completion processing=20
unreasonably), or just plain out of confusion about the items above.

I dont know whether that's the case here - it could be one of the=20
rare exceptions calling for a new locking primitive (which should=20
then be introduced at the core kernel level IMHO) - i dont know the=20
code that well.

	Ingo
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

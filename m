From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 21:46:27 +0200
Message-ID: <49EE2293.4090201@cosmosbay.com>
References: <20090418094001.GA2369@ioremap.net> <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam> <20090421191007.GA15485@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090421191007.GA15485@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar a =E9crit :
>=20
> Why not use the obvious solution: a _single_ wrlock for global=20
> access and read_can_lock() plus per cpu locks in the fastpath?

Obvious is not the qualifier I would use :)

Brilliant yes :)

>=20
> That way there's no global cacheline bouncing (just the _reading_ of=20
> a global cacheline - which will be nicely localized - on NUMA too) -=20
> and we will hold at most 1-2 locks at once!
>=20
> Something like:
>=20
> 	__cacheline_aligned DEFINE_RWLOCK(global_wrlock);
>=20
> 	DEFINE_PER_CPU(rwlock_t local_lock);
>=20
>=20
> 	void local_read_lock(void)
> 	{
> 	again:
> 		read_lock(&per_cpu(local_lock, this_cpu));

Hmm... here we can see global_wrlock locked by on writer, while
this cpu already called local_read_lock(), and calls again this
function -> Deadlock, because we hold our local_lock locked.

>=20
> 		if (unlikely(!read_can_lock(&global_wrlock))) {
> 			read_unlock(&per_cpu(local_lock, this_cpu));
> 			/*
> 			 * Just wait for any global write activity:
> 			 */
> 			read_unlock_wait(&global_wrlock);
> 			goto again;
> 		}
> 	}
>=20
> 	void global_write_lock(void)
> 	{
> 		write_lock(&global_wrlock);
>=20
> 		for_each_possible_cpu(i)
> 			write_unlock_wait(&per_cpu(local_lock, i));
> 	}
>=20
> Note how nesting friendly this construct is: we dont actually _hold_=20
> NR_CPUS locks all at once, we simply cycle through all CPUs and make=20
> sure they have our attention.
>=20
> No preempt overflow. No lockdep explosion. A very fast and scalable=20
> read path.
>=20
> Okay - we need to implement read_unlock_wait() and=20
> write_unlock_wait() which is similar to spin_unlock_wait(). The=20
> trivial first-approximation is:
>=20
> 	read_unlock_wait(x)
> 	{
> 		read_lock(x);
> 		read_unlock(x);
> 	}
>=20
> 	write_unlock_wait(x)
> 	{
> 		write_lock(x);
> 		write_unlock(x);
> 	}
>=20

Very interesting and could be changed to use spinlock + depth per cpu.

-> we can detect recursion and avoid the deadlock, and we only use one
atomic operation per lock/unlock pair in fastpath (this was the reason =
we
tried hard to use a percpu spinlock during this thread)


__cacheline_aligned DEFINE_RWLOCK(global_wrlock);

struct ingo_local_lock {
	spinlock_t lock;
	int depth;
};
DEFINE_PER_CPU(struct ingo_local_lock local_lock);


void local_read_lock(void)
{
	struct ingo_local_lock *lck;

	local_bh_and_preempt_disable();
	lck =3D &get_cpu_var(local_lock);
	if (++lck->depth > 0) /* already locked */
		return;
again:
	spin_lock(&lck->lock);

	if (unlikely(!read_can_lock(&global_wrlock))) {
		spin_unlock(&lck->lock);
		/*
		 * Just wait for any global write activity:
		 */
		read_unlock_wait(&global_wrlock);
		goto again;
	}
}

void global_write_lock(void)
{
	write_lock(&global_wrlock);

	for_each_possible_cpu(i)
		spin_unlock_wait(&per_cpu(local_lock, i));
}



Hmm ?

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

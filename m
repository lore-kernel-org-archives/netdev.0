From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 08:58:05 +0200
Message-ID: <49F6A8FD.3010804@cosmosbay.com>
References: <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal> <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam> <20090427185423.GC23862@elte.hu> <20090427120658.35a858bb@nehalam> <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain> <20090427203616.GB3836@ioremap.net> <alpine.LFD.2.00.0904271340400.22156@localhost.localdomain> <20090427144054.1fb9b7a6@nehalam> <alpine.LFD.2.00.0904271506530.22156@localhost.localdomain> <alpine.LFD.2.00.0904271525120.22156@localhost.localdomain> <alpine.LFD.2.00.0904271602390.22156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904271602390.22156@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds a =E9crit :
>=20
> On Mon, 27 Apr 2009, Linus Torvalds wrote:
>> BTW: THIS IS TOTALLY UNTESTED.
>=20
> Gaah. I should have read through it one more time before sending.
>=20
>> static inline void xt_info_rdunlock_bh(void)
>> {
>> 	struct xt_info_lock *lock;
>>
>> 	lock =3D &__get_cpu_var(xt_info_locks);
>> 	if (!--lock->readers)
>> 		spin_unlock(&lock->lock);
>> }
>=20
> This one was missing the "local_bh_enable()" at the end.
>=20
> There may be other bugs, but that's the one I noticed immediately whe=
n=20
> reading what I sent out. Oops.

I am not sure my day job will permit me to polish a patch mixing all
the bits and comments. But I am glad we eventually got back spinlocks
which are probably better than rwlocks for implementing this stuff.

Instead of submitting a full patch again, we could first submit a new
 include file containg all comments and inline functions ?

This include file could be local to netfilter, with a big stick on
it to forbids its use on other areas (No changes in Documentation/ )

Then, as soon as we can go back to pure RCU solution, we can safely
delete this controversial-locking-nesting-per-cpu-thing ?


Instead of local/global name that Paul suggested, that was about
'global' locking all locks at the same time. Not any more the good
name IMHO

Maybe something like local/remote or owner/foreigner ?

xt_info_owner_lock_bh(), xt_info_owner_unlock_bh()
xt_info_foreigner_lock(), xt_info_foreigner_unlock()

One comment about this comment you wrote :

/*
 * The "writer" side needs to get exclusive access to the lock,
 * regardless of readers.  This must be called with bottom half
 * processing (and thus also preemption) disabled.=20
 */
static inline void xt_info_wrlock(unsigned int cpu)
{
	spin_lock(&per_cpu(xt_info_locks, cpu).lock);
}

static inline void xt_info_wrunlock(unsigned int cpu)
{
	spin_unlock(&per_cpu(xt_info_locks, cpu).lock);
}

Its true that BH should be disabled if caller runs
on the cpu it wants to lock.=20
=46or other ones (true foreigners), there is
no requirement about BH (current cpu could be interrupted
by a softirq and packets could fly)

We could use following construct and not require disabling BH
more than a short period of time.
(But preemption disabled for the whole duration)

preempt_disable(); // could be cpu_migration_disable();

int curcpu =3D smp_processor_id();
/*
 * Gather stats for current cpu : must disable BH
 * before trying to lock.
 */
local_bh_disable();
xt_info_wrlock(curcpu);
// copy stats of this cpu on my private data (not shown here)
xt_info_wrunlock(curcpu);
local_bh_enable();

for_each_possible_cpu(cpu) {
	if (cpu =3D=3D curcpu)
		continue;
	xt_info_wrlock(cpu);
	// fold stats of "cpu" on my private data (not shown here)
	xt_info_wrunlock((cpu);
}
preempt_enable(); // could be cpu_migration_enable();


So your initial comment could be changed to :

/*
 * The "writer" side needs to get exclusive access to the lock,
 * regardless of readers. If caller is about to lock its own lock,
 * he must have disabled BH before. For other cpus, no special
 * care but preemption disabled to guarantee no cpu migration.
 */

Back to work now :)

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

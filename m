From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v10)
Date: Mon, 20 Apr 2009 20:25:14 +0200
Message-ID: <49ECBE0A.7010303@cosmosbay.com>
References: <20090415170111.6e1ca264@nehalam>	<alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>	<49E72E83.50702@trash.net>	<20090416.153354.170676392.davem@davemloft.net>	<20090416234955.GL6924@linux.vnet.ibm.com>	<20090417012812.GA25534@linux.vnet.ibm.com>	<20090418094001.GA2369@ioremap.net>	<20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090420103414.1b4c490f@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> This version of x_tables (ip/ip6/arp) locking uses a per-cpu
> recursive lock that can be nested. It is sort of like existing kernel=
_lock,
> rwlock_t and even old 2.4 brlock.
>=20
> "Reader" is ip/arp/ip6 tables rule processing which runs per-cpu.
> It needs to ensure that the rules are not being changed while packet
> is being processed.
>=20
> "Writer" is used in two cases: first is replacing rules in which case
> all packets in flight have to be processed before rules are swapped,
> then counters are read from the old (stale) info. Second case is wher=
e
> counters need to be read on the fly, in this case all CPU's are block=
ed
> from further rule processing until values are aggregated.
>=20
> The idea for this came from an earlier version done by Eric Dumazet.
> Locking is done per-cpu, the fast path locks on the current cpu
> and updates counters.  This reduces the contention of a
> single reader lock (in 2.6.29) without the delay of synchronize_net()
> (in 2.6.30-rc2).=20
>=20
> The mutex that was added for 2.6.30 in xt_table is unnecessary since
> there already is a mutex for xt[af].mutex that is held.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com
>=20
> ---
> Changes from earlier patches.
>   - function name changes
>   - disable bottom half in info_rdlock

OK, but we still have a problem on machines with >=3D 250 cpus,
because calling 250 times spin_lock() is going to overflow preempt_coun=
t,
as each spin_lock() increases preempt_count by one.

PREEMPT_MASK: 0x000000ff

add_preempt_count() should warn us about this overflow if CONFIG_DEBUG_=
PREEMPT is set

#ifdef CONFIG_DEBUG_PREEMPT
        /*
         * Spinlock count overflowing soon?
         */
        DEBUG_LOCKS_WARN_ON((preempt_count() & PREEMPT_MASK) >=3D
                                PREEMPT_MASK - 10);
#endif


My suggestion (in a previous mail) was to call preempt_disable() after =
each spin_lock(),
and of course doing the reverse on unlock path.


> +/**
> + * xt_info_wrlock_bh - lock xt table info for update
> + *
> + * Locks out all readers, and blocks bottom half
> + */
> +void xt_info_wrlock_bh(void)
> +{
> +	int i;
> +
> +	local_bh_disable();
=20
/* at this point , preemption is disabled... */


> +	for_each_possible_cpu(i) {
> +		struct xt_info_lock *lock =3D &per_cpu(xt_info_locks, i);
> +		spin_lock(&lock->lock);
=09
		preempt_enable(); /* avoid preempt count overflow */
	=09
> +		BUG_ON(lock->depth !=3D -1);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(xt_info_wrlock_bh);
> +
> +/**
> + * xt_info_wrunlock_bh - lock xt table info for update
> + *
> + * Unlocks all readers, and unblocks bottom half
> + */
> +void xt_info_wrunlock_bh(void) __releases(&lock->lock)
> +{
> +	int i;
> +
> +	for_each_possible_cpu(i) {
> +		struct xt_info_lock *lock =3D &per_cpu(xt_info_locks, i);
> +		BUG_ON(lock->depth !=3D -1);

		preempt_disable() /* restore preempt count lowered in xt_info_wrlock_=
bh */

> +		spin_unlock(&lock->lock);
> +	}
> +	local_bh_enable();
> +}
> +EXPORT_SYMBOL_GPL(xt_info_wrunlock_bh);

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

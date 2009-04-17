From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: per-cpu spin-lock with recursion (v0.8)
Date: Fri, 17 Apr 2009 08:14:59 +0200
Message-ID: <49E81E63.2090909@cosmosbay.com>
References: <20090415170111.6e1ca264@nehalam>	<alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>	<49E72E83.50702@trash.net>	<20090416.153354.170676392.davem@davemloft.net>	<20090416234955.GL6924@linux.vnet.ibm.com> <20090416165233.5d8bbfb5@nehalam> <49E81B9D.3030807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	kaber@trash.net, torvalds@linux-foundation.org,
	jeff.chua.linux@gmail.com, paulus@samba.org, mingo@elte.hu,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E81B9D.3030807@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Stephen Hemminger a =E9crit :
>> This version of x_tables (ip/ip6/arp) locking uses a per-cpu
>> recursive lock that can be nested. It is sort of like existing kerne=
l_lock,
>> rwlock_t and even old 2.4 brlock.
>>
>> "Reader" is ip/arp/ip6 tables rule processing which runs per-cpu.
>> It needs to ensure that the rules are not being changed while packet
>> is being processed.
>>
>> "Writer" is used in two cases: first is replacing rules in which cas=
e
>> all packets in flight have to be processed before rules are swapped,
>> then counters are read from the old (stale) info. Second case is whe=
re
>> counters need to be read on the fly, in this case all CPU's are bloc=
ked
>> from further rule processing until values are aggregated.
>>
>> The idea for this came from an earlier version done by Eric Dumazet.
>> Locking is done per-cpu, the fast path locks on the current cpu
>> and updates counters.  This reduces the contention of a
>> single reader lock (in 2.6.29) without the delay of synchronize_net(=
)
>> (in 2.6.30-rc2).=20
>>
>>
>> The mutex that was added for 2.6.30 in xt_table is unnecessary since
>> there already is a mutex for xt[af].mutex that is held.
>>
>> Future optimizations possible:
>>   - Lockdep doesn't really handle this well
>>   - hot plug CPU case, if kernel is built with large # of CPU's, ski=
p
>>     the inactive ones; migrate values when CPU is removed.
>>   - reading counters could be incremental by CPU.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com
>>
>=20
> I like this version 8 of the patch, as it mixes all ideas we had,
> but have two questions.
>=20
> Previous netfilter code (and 2.6.30-rc2 one too) disable BH, not only=
 preemption.
>=20
> I see xt_table_info_lock_all(void) does block BH, so this one is safe=
=2E
>=20
> I let Patrick or other tell us if its safe to run ipt_do_table()
> with preemption disabled but BH enabled, I really dont know.
>=20
> Also, please dont call this a 'recursive lock', since it is not a gen=
eral
> recursive lock, as pointed by Linus and Paul.
>=20
> Second question is about MAX_LOCK_DEPTH

I meant here the ~256 limit we have on preempt_count, not related to LO=
CKDEP

>=20
> Why dont use this kind of construct to get rid of this limit ?
>=20
> +void xt_table_info_lock_all(void)
>> +{
>> +	int i;
>> +
>> +	local_bh_disable();
>> +	for_each_possible_cpu(i) {
>> +		struct xt_lock *lock =3D &per_cpu(xt_info_locks, i);
>> +		spin_lock(&lock->lock);
>> +		preempt_enable_no_resched();
>> +	}
>> +}
>> +EXPORT_SYMBOL_GPL(xt_table_info_lock_all);


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

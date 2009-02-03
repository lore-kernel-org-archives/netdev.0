From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] iptables: lock free counters (alternate version)
Date: Tue, 03 Feb 2009 20:19:27 +0100
Message-ID: <498898BF.7060906@cosmosbay.com>
References: <20090130215700.965611970@vyatta.com>	<20090130215729.416851870@vyatta.com>	<498594B6.6000905@cosmosbay.com> <20090202153357.3ac6edfa@extreme> <49889440.60702@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47137 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755594AbZBCTTb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 14:19:31 -0500
In-Reply-To: <49889440.60702@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Stephen Hemminger a =E9crit :
>> This is an alternative to earlier RCU/seqcount_t version of counters=
=2E
>> The counters operate as usual without locking, but when counters are=
 rotated
>> around the CPU's entries.  RCU is used in two ways, first to handle =
the
>> counter rotation, second for replace.
>>
>=20
> Is it a working patch or just a prototype ?
>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> ---
>>  include/linux/netfilter/x_tables.h |   10 +++-
>>  net/ipv4/netfilter/arp_tables.c    |   73 +++++++++++++++++++++++++=
++---------
>>  net/ipv4/netfilter/ip_tables.c     |   68 ++++++++++++++++++++++++-=
--------
>>  net/ipv6/netfilter/ip6_tables.c    |   75 +++++++++++++++++++++++++=
+-----------
>>  net/netfilter/x_tables.c           |   43 +++++++++++++++------
>>  5 files changed, 197 insertions(+), 72 deletions(-)
>>
>> --- a/include/linux/netfilter/x_tables.h	2009-02-02 15:06:39.8937518=
45 -0800
>> +++ b/include/linux/netfilter/x_tables.h	2009-02-02 15:28:10.0225740=
05 -0800
>> @@ -353,7 +353,7 @@ struct xt_table
>>  	unsigned int valid_hooks;
>> =20
>>  	/* Lock for the curtain */
>> -	rwlock_t lock;
>> +	struct mutex lock;
>> =20
>>  	/* Man behind the curtain... */
>>  	struct xt_table_info *private;
>> @@ -383,9 +383,15 @@ struct xt_table_info
>>  	unsigned int hook_entry[NF_INET_NUMHOOKS];
>>  	unsigned int underflow[NF_INET_NUMHOOKS];
>> =20
>> +	/* For the dustman... */
>> +	union {
>> +		struct rcu_head rcu;
>> +		struct work_struct work;
>> +	};
>> +
>>  	/* ipt_entry tables: one per CPU */
>>  	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
>> -	char *entries[1];
>> +	void *entries[1];
>>  };
>> =20
>>  #define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
>> --- a/net/ipv4/netfilter/ip_tables.c	2009-02-02 15:06:29.684249364 -=
0800
>> +++ b/net/ipv4/netfilter/ip_tables.c	2009-02-02 15:14:13.256499021 -=
0800
>> @@ -347,10 +347,12 @@ ipt_do_table(struct sk_buff *skb,
>>  	mtpar.family  =3D tgpar.family =3D NFPROTO_IPV4;
>>  	tgpar.hooknum =3D hook;
>> =20
>> -	read_lock_bh(&table->lock);
>>  	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
>> -	private =3D table->private;
>> -	table_base =3D (void *)private->entries[smp_processor_id()];
>> +
>> +	rcu_read_lock_bh();
>> +	private =3D rcu_dereference(table->private);
>> +	table_base =3D rcu_dereference(private->entries[smp_processor_id()=
]);
>> +
>>  	e =3D get_entry(table_base, private->hook_entry[hook]);
>> =20
>>  	/* For return from builtin chain */
>> @@ -445,7 +447,7 @@ ipt_do_table(struct sk_buff *skb,
>>  		}
>>  	} while (!hotdrop);
>> =20
>> -	read_unlock_bh(&table->lock);
>> +	rcu_read_unlock_bh();
>> =20
>>  #ifdef DEBUG_ALLOW_ALL
>>  	return NF_ACCEPT;
>> @@ -892,45 +894,73 @@ set_entry_to_counter(const struct ipt_en
>>  	return 0;
>>  }
>> =20
>> +static inline int
>> +set_counter_to_entry(struct ipt_entry *e,
>> +		     const struct ipt_counters total[],
>> +		     unsigned int *i)
>> +{
>> +	SET_COUNTER(e->counters, total[*i].bcnt, total[*i].pcnt);
>> +
>> +	(*i)++;
>> +	return 0;
>> +}
>> +
>> +
>>  static void
>> -get_counters(const struct xt_table_info *t,
>> +get_counters(struct xt_table_info *t,
>>  	     struct xt_counters counters[])
>>  {
>>  	unsigned int cpu;
>>  	unsigned int i;
>>  	unsigned int curcpu;
>> +	struct ipt_entry *e;
>> =20
>> -	/* Instead of clearing (by a previous call to memset())
>> -	 * the counters and using adds, we set the counters
>> -	 * with data used by 'current' CPU
>> -	 * We dont care about preemption here.
>> -	 */
>> +	preempt_disable();
>>  	curcpu =3D raw_smp_processor_id();
>> -
>> +	e =3D t->entries[curcpu];
>>  	i =3D 0;
>> -	IPT_ENTRY_ITERATE(t->entries[curcpu],
>> +	IPT_ENTRY_ITERATE(e,
>>  			  t->size,
>>  			  set_entry_to_counter,
>=20
> Hum, current cpu might be interrupted by NIC, since you only disabled=
 preemption.
> set_entry_to_counter() might get garbage.
> I suppose I already mentioned it :)
>=20
>>  			  counters,
>>  			  &i);
>> =20
>>  	for_each_possible_cpu(cpu) {
>> +		void *p;
>> +
>>  		if (cpu =3D=3D curcpu)
>>  			continue;
>> +
>> +		/* Swizzle the values and wait */
>> +		e->counters =3D ((struct xt_counters) { 0, 0 });
>=20
> I dont see what you want to do here...
>=20
> e->counters is the counter associated with rule #0
>=20
>> +		p =3D t->entries[cpu];
>> +		rcu_assign_pointer(t->entries[cpu], e);
>> +		synchronize_net();
>=20
>=20
> Oh well, not this synchronize_net() :)
>=20
> This wont provide atomic sampling of counters for whole CPUS, and int=
roduce large delays
> on big machines (NR_CPUS >=3D 64)
>=20
> What problem do we want to solve here ?
>=20
>=20
> Current iptables is able to do an atomic snapshot because of the rwlo=
ck.
>=20
> If we really want to keep this feature (but get rid of rwlock), we mi=
ght do the reverse
> with two seqlocks + RCU
>=20
> One seqlock (seqlock_counters) to protect counter updates
> One seqlock (seqlock_rules) to protect rules changes
>=20
> Ie :
>=20
> ipt_do_table() doing :
> {
> rcu_read_lock=20
> read_seqbegin(&table->seqlock_rules);
> rcu fetch priv table pointer and work on it
>  do {
>  for all counters updates, use=20
>  do {
>    seq =3D read_seqbegin(table->seqlock_counters);

Hum... reading my mail, this one can be done once only, at the beginnin=
g

Why then I suggested two different seqlocks, I am wondering :)

I need to think a litle bit more, we might do something to allow severa=
l "iptables -L" in //

maybe an atomic_t to protect counters would be ok :


Ie :

One atomic_t (counters_readers) to protect counter updates
One seqlock (seqlock_rules) to protect rules changes



ipt_do_table() doing :
{
begin:
read_seqbegin(&table->seqlock_rules); // it could loop but with BH enab=
led
rcu_read_lock_bh();
while (atomic_read(&table->counters_readers) > 0) {
   cpu_relax();
   rcu_read_unlock_bh();
   goto begin;
}
private =3D rcu_dereference(table->private);
=2E..
 do {
 for all counters updates, use=20
 do {
   update counters
   }
 } while (!hotdrop);
rcu_read_unlock_bh()
}


for get_counter() (iptables -L)
atomic_inc(&table->counters_readers);
waiting one RCU grace period,=20
{
get / sum all counters (no updates of counters are allowed)
}
atomic_dec(&table->counters_readers)



for iptables_update/replace (iptables -A|I|D|R|Z|F...)
writer doing a write_seqlock(&table->seqlock_rules), waiting one RCU gr=
ace period,=20
{
change rules/counters
}
write_sequnlock();






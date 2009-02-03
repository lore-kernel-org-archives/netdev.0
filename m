From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] iptables: lock free counters (alternate version)
Date: Tue, 3 Feb 2009 15:11:24 -0800
Message-ID: <20090203231124.GL6607@linux.vnet.ibm.com>
References: <20090130215700.965611970@vyatta.com> <20090130215729.416851870@vyatta.com> <498594B6.6000905@cosmosbay.com> <20090202153357.3ac6edfa@extreme> <49889440.60702@cosmosbay.com> <20090203193214.GH6607@linux.vnet.ibm.com> <4988A6F4.6000902@cosmosbay.com> <20090203211000.GI6607@linux.vnet.ibm.com> <20090203132220.21a16ea1@extreme>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:50055 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010AbZBCXLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 18:11:25 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n13N9PTM022764
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 18:09:25 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n13NBO6B170302
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 18:11:24 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n13NBNHP004551
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 18:11:23 -0500
Content-Disposition: inline
In-Reply-To: <20090203132220.21a16ea1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 01:22:20PM -0800, Stephen Hemminger wrote:
> On Tue, 3 Feb 2009 13:10:00 -0800
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
>=20
> > On Tue, Feb 03, 2009 at 09:20:04PM +0100, Eric Dumazet wrote:
> > > Paul E. McKenney a =E9crit :
> > > > On Tue, Feb 03, 2009 at 08:00:16PM +0100, Eric Dumazet wrote:
> > > >> Stephen Hemminger a =E9crit :
> > > >>> This is an alternative to earlier RCU/seqcount_t version of c=
ounters.
> > > >>> The counters operate as usual without locking, but when count=
ers are rotated
> > > >>> around the CPU's entries.  RCU is used in two ways, first to =
handle the
> > > >>> counter rotation, second for replace.
> > > >> Is it a working patch or just a prototype ?
> > > >>
> > > >>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > > >>>
> > > >>> ---
> > > >>>  include/linux/netfilter/x_tables.h |   10 +++-
> > > >>>  net/ipv4/netfilter/arp_tables.c    |   73 ++++++++++++++++++=
+++++++++---------
> > > >>>  net/ipv4/netfilter/ip_tables.c     |   68 ++++++++++++++++++=
++++++---------
> > > >>>  net/ipv6/netfilter/ip6_tables.c    |   75 ++++++++++++++++++=
++++++++-----------
> > > >>>  net/netfilter/x_tables.c           |   43 +++++++++++++++---=
---
> > > >>>  5 files changed, 197 insertions(+), 72 deletions(-)
> > > >>>
> > > >>> --- a/include/linux/netfilter/x_tables.h	2009-02-02 15:06:39.=
893751845 -0800
> > > >>> +++ b/include/linux/netfilter/x_tables.h	2009-02-02 15:28:10.=
022574005 -0800
> > > >>> @@ -353,7 +353,7 @@ struct xt_table
> > > >>>  	unsigned int valid_hooks;
> > > >>> =20
> > > >>>  	/* Lock for the curtain */
> > > >>> -	rwlock_t lock;
> > > >>> +	struct mutex lock;
> > > >>> =20
> > > >>>  	/* Man behind the curtain... */
> > > >>>  	struct xt_table_info *private;
> > > >>> @@ -383,9 +383,15 @@ struct xt_table_info
> > > >>>  	unsigned int hook_entry[NF_INET_NUMHOOKS];
> > > >>>  	unsigned int underflow[NF_INET_NUMHOOKS];
> > > >>> =20
> > > >>> +	/* For the dustman... */
> > > >>> +	union {
> > > >>> +		struct rcu_head rcu;
> > > >>> +		struct work_struct work;
> > > >>> +	};
> > > >>> +
> > > >>>  	/* ipt_entry tables: one per CPU */
> > > >>>  	/* Note : this field MUST be the last one, see XT_TABLE_INF=
O_SZ */
> > > >>> -	char *entries[1];
> > > >>> +	void *entries[1];
> > > >>>  };
> > > >>> =20
> > > >>>  #define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, ent=
ries) \
> > > >>> --- a/net/ipv4/netfilter/ip_tables.c	2009-02-02 15:06:29.6842=
49364 -0800
> > > >>> +++ b/net/ipv4/netfilter/ip_tables.c	2009-02-02 15:14:13.2564=
99021 -0800
> > > >>> @@ -347,10 +347,12 @@ ipt_do_table(struct sk_buff *skb,
> > > >>>  	mtpar.family  =3D tgpar.family =3D NFPROTO_IPV4;
> > > >>>  	tgpar.hooknum =3D hook;
> > > >>> =20
> > > >>> -	read_lock_bh(&table->lock);
> > > >>>  	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
> > > >>> -	private =3D table->private;
> > > >>> -	table_base =3D (void *)private->entries[smp_processor_id()]=
;
> > > >>> +
> > > >>> +	rcu_read_lock_bh();
> > > >>> +	private =3D rcu_dereference(table->private);
> > > >>> +	table_base =3D rcu_dereference(private->entries[smp_process=
or_id()]);
> > > >>> +
> > > >>>  	e =3D get_entry(table_base, private->hook_entry[hook]);
> > > >>> =20
> > > >>>  	/* For return from builtin chain */
> > > >>> @@ -445,7 +447,7 @@ ipt_do_table(struct sk_buff *skb,
> > > >>>  		}
> > > >>>  	} while (!hotdrop);
> > > >>> =20
> > > >>> -	read_unlock_bh(&table->lock);
> > > >>> +	rcu_read_unlock_bh();
> > > >>> =20
> > > >>>  #ifdef DEBUG_ALLOW_ALL
> > > >>>  	return NF_ACCEPT;
> > > >>> @@ -892,45 +894,73 @@ set_entry_to_counter(const struct ipt_e=
n
> > > >>>  	return 0;
> > > >>>  }
> > > >>> =20
> > > >>> +static inline int
> > > >>> +set_counter_to_entry(struct ipt_entry *e,
> > > >>> +		     const struct ipt_counters total[],
> > > >>> +		     unsigned int *i)
> > > >>> +{
> > > >>> +	SET_COUNTER(e->counters, total[*i].bcnt, total[*i].pcnt);
> > > >>> +
> > > >>> +	(*i)++;
> > > >>> +	return 0;
> > > >>> +}
> > > >>> +
> > > >>> +
> > > >>>  static void
> > > >>> -get_counters(const struct xt_table_info *t,
> > > >>> +get_counters(struct xt_table_info *t,
> > > >>>  	     struct xt_counters counters[])
> > > >>>  {
> > > >>>  	unsigned int cpu;
> > > >>>  	unsigned int i;
> > > >>>  	unsigned int curcpu;
> > > >>> +	struct ipt_entry *e;
> > > >>> =20
> > > >>> -	/* Instead of clearing (by a previous call to memset())
> > > >>> -	 * the counters and using adds, we set the counters
> > > >>> -	 * with data used by 'current' CPU
> > > >>> -	 * We dont care about preemption here.
> > > >>> -	 */
> > > >>> +	preempt_disable();
> > > >>>  	curcpu =3D raw_smp_processor_id();
> > > >>> -
> > > >>> +	e =3D t->entries[curcpu];
> > > >>>  	i =3D 0;
> > > >>> -	IPT_ENTRY_ITERATE(t->entries[curcpu],
> > > >>> +	IPT_ENTRY_ITERATE(e,
> > > >>>  			  t->size,
> > > >>>  			  set_entry_to_counter,
> > > >> Hum, current cpu might be interrupted by NIC, since you only d=
isabled preemption.
> > > >> set_entry_to_counter() might get garbage.
> > > >> I suppose I already mentioned it :)
> > > >>
> > > >>>  			  counters,
> > > >>>  			  &i);
> > > >>> =20
> > > >>>  	for_each_possible_cpu(cpu) {
> > > >>> +		void *p;
> > > >>> +
> > > >>>  		if (cpu =3D=3D curcpu)
> > > >>>  			continue;
> > > >>> +
> > > >>> +		/* Swizzle the values and wait */
> > > >>> +		e->counters =3D ((struct xt_counters) { 0, 0 });
> > > >> I dont see what you want to do here...
> > > >>
> > > >> e->counters is the counter associated with rule #0
> > > >>
> > > >>> +		p =3D t->entries[cpu];
> > > >>> +		rcu_assign_pointer(t->entries[cpu], e);
> > > >>> +		synchronize_net();
> > > >>
> > > >> Oh well, not this synchronize_net() :)
> > > >>
> > > >> This wont provide atomic sampling of counters for whole CPUS, =
and introduce large delays
> > > >> on big machines (NR_CPUS >=3D 64)
> > > >=20
> > > > Why would this not provide the moral equivalent of atomic sampl=
ing?
> > > > The code above switches to another counter set, and waits for a=
 grace
> > > > period.  Shouldn't this mean that all CPUs that were incrementi=
ng the
> > > > old set of counters have finished doing so, so that the aggrega=
te count
> > > > covers all CPUs that started their increments before the pointe=
r switch?
> > > > Same as acquiring a write lock, which would wait for all CPUs t=
hat
> > > > started their increments before starting the write-lock acquisi=
tion.
> > > > CPUs that started their increments after starting the write acq=
uisition
> > > > would not be accounted for in the total, same as the RCU approa=
ch.
> > > >=20
> > > > Steve's approach does delay reading out the counters, but it av=
oids
> > > > delaying any CPU trying to increment the counters.
> > >=20
> > > I see your point, but this is not what Stephen implemented.
> > >=20
> > > So.. CPU will increments which counters, if not delayed ?
> >=20
> > The new set installed by the rcu_assign_pointer().
> >=20
> > > How counters will be synced again after our 'iptables -L' finishe=
d ?
> >=20
> > The usual approach would be to have three sets of counters, one cur=
rently
> > being incremented, one just removed from service, and the last one =
holding
> > the cumulative value.  After a synchronize_net() following removing
> > a set from service, you add in the values in the previous set remov=
ed
> > from service.  Then you keep the new set for the next 'iptables -L'=
=2E
> >=20
> > > "iptable -L" is not supposed to miss some counters updates (only =
some packets
> > >  might be droped at NIC level because we spend time in the collec=
tion).
> > > If packets matches some rules, we really want up2date counters.
> >=20
> > No counter updates would be lost using the above method.
> >=20
> > > Maybe we need for this collection an extra "cpu", to collect=20
> > > all increments that were done when CPUs where directed to a=20
> > > "secondary table/counters"
> >=20
> > It should be easier to maintain a third set of counters that hold t=
he
> > accumulated counts from the earlier instances of 'iptables -L'.
> >=20
> > > > So what am I missing here?
> > >=20
> > > Well, I saw one synchronize_net() inside the for_each_possible_cp=
u(cpu) loop.
> > > Say we have NR_CPUS=3D4096, how long will it takes to perform "ip=
tables -L" ?
> >=20
> > Good point, the for_each_possible_cpu() was cut out -- I should hav=
e
> > gone back and looked at the original patch.
> >=20
> > Seems like it should be possible to do a single synchronize_net()
> > after swizzling all the counters...
> >=20
> > > General/intuitive idea would be :
> > >=20
> > > switch pointers to a newly allocated table (and zeroed counters)
> > > wait one RCU grace period
> > > collect/sum all counters of "old" table + (all cpus) into user pr=
ovided table
> > > restore previous table
> > > wait one RCU grace period
> > > disable_bh()
> > > collect/sum all counters of "new and temporary" table (all cpus) =
and
> > > reinject them into local cpu table (this cpu should not be interr=
upted)
> > > enable_bh()
> > >=20
> > > This way, "iptables -L" is not too expensive and doesnt block pac=
ket processing at all.
> >=20
> > My thought would be:
> >=20
> > o	acquire some sort of mutex.
> >=20
> > o	switch counters to newly allocated (and zeroed) table (T1).
> > 	The old table being switched out is T2.
> >=20
> > o	wait one RCU grace period.
> >=20
> > o	Sum T2 into a single global counter (G).
> >=20
> > o	Free T2.
> >=20
> > o	Copy G to a local variable.
> >=20
> > o	release the mutex.
> >=20
> > o	Return the value of the local variable.
> >=20
> > Then you can repeat, allocating a new table again and using the new
> > value of G.
> >=20
> > Which may well be what you are saying above,
> >=20
>=20
> I was using the current CPU counter as the global counter G.

Sounds good, then!  ;-)

						Thanx, Paul

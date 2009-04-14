From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU
Date: Tue, 14 Apr 2009 07:45:54 -0700
Message-ID: <20090414074554.7fa73e2f@nehalam>
References: <20090411174801.GG6822@linux.vnet.ibm.com>
	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>
	<20090412173108.GO6822@linux.vnet.ibm.com>
	<20090412.181330.23529546.davem@davemloft.net>
	<20090413040413.GQ6822@linux.vnet.ibm.com>
	<20090413095309.631cf395@nehalam>
	<49E48136.5060700@trash.net>
	<49E49C65.8060808@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, paulmck@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, paulus@samba.org,
	mingo@elte.hu, torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jeff.chua.linux@gmail.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47692 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754970AbZDNOqE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 10:46:04 -0400
In-Reply-To: <49E49C65.8060808@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Apr 2009 16:23:33 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Patrick McHardy a =C3=A9crit :
> > Stephen Hemminger wrote:
> >> This is an alternative version of ip/ip6/arp tables locking using
> >> per-cpu locks.  This avoids the overhead of synchronize_net() duri=
ng
> >> update but still removes the expensive rwlock in earlier versions.
> >>
> >> The idea for this came from an earlier version done by Eric Duzame=
t.
> >> Locking is done per-cpu, the fast path locks on the current cpu
> >> and updates counters.  The slow case involves acquiring the locks =
on
> >> all cpu's.
> >>
> >> The mutex that was added for 2.6.30 in xt_table is unnecessary sin=
ce
> >> there already is a mutex for xt[af].mutex that is held.
> >>
> >> Tested basic functionality (add/remove/list), but don't have test =
cases
> >> for stress, ip6tables or arptables.
> >=20
> > Thanks Stephen, I'll do some testing with ip6tables.
>=20
> Here is the patch I cooked on top of Stephen one to get proper lockin=
g.

I see no demonstrated problem with locking in my version.
The reader/writer race is already handled. On replace the race of

CPU 0                          CPU 1
                           lock (iptables(1))
                           refer to oldinfo
swap in new info
foreach CPU
   lock iptables(i)
   (spin)                  unlock(iptables(1))
   read oldinfo
   unlock
=2E..

The point is my locking works, you just seem to feel more comfortable w=
ith
a global "stop all CPU's" solution.

> In the "iptables -L" case, we freeze updates on all cpus to get previ=
ous
> RCU behavior (not sure it is mandatory, but anyway...)

No, it isn't. Because the code in get_counters will fetch all CPU's.

> And xt_replace_table() uses same logic to make sure a cpu wont try to=
 parse rules
> and update counters while a writer is replacing tables (and thus call=
ing
> vfree() and unmapping in-use pages)

With RCU type semantics this isn't an issue. A CPU always sees consiste=
nt
state, and it counters never get lost.

> Feel free to merge this patch to Stephen one before upstream submissi=
on
>=20
> Thank you
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  include/linux/netfilter/x_tables.h |    5 ++
>  net/ipv4/netfilter/arp_tables.c    |   20 +++------
>  net/ipv4/netfilter/ip_tables.c     |   24 ++++-------
>  net/ipv6/netfilter/ip6_tables.c    |   24 ++++-------
>  net/netfilter/x_tables.c           |   55 ++++++++++++++++++++++++++=
-
>  5 files changed, 84 insertions(+), 44 deletions(-)
> diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfi=
lter/x_tables.h
> index 1ff1a76..a5840a4 100644
> --- a/include/linux/netfilter/x_tables.h
> +++ b/include/linux/netfilter/x_tables.h
> @@ -426,6 +426,11 @@ extern struct xt_table *xt_find_table_lock(struc=
t net *net, u_int8_t af,
>  					   const char *name);
>  extern void xt_table_unlock(struct xt_table *t);
> =20
> +extern void xt_tlock_lockall(void);
> +extern void xt_tlock_unlockall(void);
> +extern void xt_tlock_lock(void);
> +extern void xt_tlock_unlock(void);
> +
>  extern int xt_proto_init(struct net *net, u_int8_t af);
>  extern void xt_proto_fini(struct net *net, u_int8_t af);
> =20
> diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp=
_tables.c
> index c60cc11..b561e1e 100644
> --- a/net/ipv4/netfilter/arp_tables.c
> +++ b/net/ipv4/netfilter/arp_tables.c
> @@ -231,8 +231,6 @@ static inline struct arpt_entry *get_entry(void *=
base, unsigned int offset)
>  	return (struct arpt_entry *)(base + offset);
>  }
> =20
> -static DEFINE_PER_CPU(spinlock_t, arp_tables_lock);
> -
>  unsigned int arpt_do_table(struct sk_buff *skb,
>  			   unsigned int hook,
>  			   const struct net_device *in,
> @@ -256,7 +254,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
>  	outdev =3D out ? out->name : nulldevname;
> =20
>  	local_bh_disable();
> -	spin_lock(&__get_cpu_var(arp_tables_lock));
> +	xt_tlock_lock();
>  	private =3D table->private;
>  	table_base =3D private->entries[smp_processor_id()];
> =20
> @@ -331,7 +329,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
>  			e =3D (void *)e + e->next_offset;
>  		}
>  	} while (!hotdrop);
> -	spin_unlock(&__get_cpu_var(arp_tables_lock));
> +	xt_tlock_unlock();
>  	local_bh_enable();
> =20
>  	if (hotdrop)
> @@ -709,33 +707,31 @@ static void get_counters(const struct xt_table_=
info *t,
>  {
>  	unsigned int cpu;
>  	unsigned int i =3D 0;
> -	unsigned int curcpu =3D raw_smp_processor_id();
> +	unsigned int curcpu;
> =20
> +	xt_tlock_lockall();
>  	/* Instead of clearing (by a previous call to memset())
>  	 * the counters and using adds, we set the counters
>  	 * with data used by 'current' CPU
> -	 * We dont care about preemption here.
>  	 */
> -	spin_lock_bh(&per_cpu(arp_tables_lock, curcpu));
> +	curcpu =3D smp_processor_id();
>  	ARPT_ENTRY_ITERATE(t->entries[curcpu],
>  			   t->size,
>  			   set_entry_to_counter,
>  			   counters,
>  			   &i);
> -	spin_unlock_bh(&per_cpu(arp_tables_lock, curcpu));
> =20
>  	for_each_possible_cpu(cpu) {
>  		if (cpu =3D=3D curcpu)
>  			continue;
>  		i =3D 0;
> -		spin_lock_bh(&per_cpu(arp_tables_lock, cpu));
>  		ARPT_ENTRY_ITERATE(t->entries[cpu],
>  				   t->size,
>  				   add_entry_to_counter,
>  				   counters,
>  				   &i);
> -		spin_unlock_bh(&per_cpu(arp_tables_lock, cpu));
>  	}
> +	xt_tlock_unlockall();
>  }
> =20
>  static struct xt_counters *alloc_counters(struct xt_table *table)
> @@ -1181,14 +1177,14 @@ static int do_add_counters(struct net *net, v=
oid __user *user, unsigned int len,
>  	/* Choose the copy that is on our node */
>  	local_bh_disable();
>  	curcpu =3D smp_processor_id();
> -	spin_lock(&__get_cpu_var(arp_tables_lock));
> +	xt_tlock_lock();
>  	loc_cpu_entry =3D private->entries[curcpu];
>  	ARPT_ENTRY_ITERATE(loc_cpu_entry,
>  			   private->size,
>  			   add_counter_to_entry,
>  			   paddc,
>  			   &i);
> -	spin_unlock(&__get_cpu_var(arp_tables_lock));
> +	xt_tlock_unlock();
>  	local_bh_enable();
>   unlock_up_free:
> =20
> diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_t=
ables.c
> index cb3b779..81d173e 100644
> --- a/net/ipv4/netfilter/ip_tables.c
> +++ b/net/ipv4/netfilter/ip_tables.c
> @@ -297,7 +297,6 @@ static void trace_packet(struct sk_buff *skb,
>  }
>  #endif
> =20
> -static DEFINE_PER_CPU(spinlock_t, ip_tables_lock);
> =20
>  /* Returns one of the generic firewall policies, like NF_ACCEPT. */
>  unsigned int
> @@ -342,7 +341,7 @@ ipt_do_table(struct sk_buff *skb,
>  	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
> =20
>  	local_bh_disable();
> -	spin_lock(&__get_cpu_var(ip_tables_lock));
> +	xt_tlock_lock();
>  	private =3D table->private;
>  	table_base =3D private->entries[smp_processor_id()];
> =20
> @@ -439,7 +438,7 @@ ipt_do_table(struct sk_buff *skb,
>  			e =3D (void *)e + e->next_offset;
>  		}
>  	} while (!hotdrop);
> -	spin_unlock(&__get_cpu_var(ip_tables_lock));
> +	xt_tlock_unlock();
>  	local_bh_enable();
> =20
>  #ifdef DEBUG_ALLOW_ALL
> @@ -895,34 +894,32 @@ get_counters(const struct xt_table_info *t,
>  {
>  	unsigned int cpu;
>  	unsigned int i =3D 0;
> -	unsigned int curcpu =3D raw_smp_processor_id();
> +	unsigned int curcpu;
> =20
> +	xt_tlock_lockall();
>  	/* Instead of clearing (by a previous call to memset())
>  	 * the counters and using adds, we set the counters
>  	 * with data used by 'current' CPU
> -	 * We dont care about preemption here.
>  	 */
> -	spin_lock_bh(&per_cpu(ip_tables_lock, curcpu));
> +	curcpu =3D smp_processor_id();
>  	IPT_ENTRY_ITERATE(t->entries[curcpu],
>  			  t->size,
>  			  set_entry_to_counter,
>  			  counters,
>  			  &i);
> -	spin_unlock_bh(&per_cpu(ip_tables_lock, curcpu));
> =20
>  	for_each_possible_cpu(cpu) {
>  		if (cpu =3D=3D curcpu)
>  			continue;
> =20
>  		i =3D 0;
> -		spin_lock_bh(&per_cpu(ip_tables_lock, cpu));
>  		IPT_ENTRY_ITERATE(t->entries[cpu],
>  				  t->size,
>  				  add_entry_to_counter,
>  				  counters,
>  				  &i);
> -		spin_unlock_bh(&per_cpu(ip_tables_lock, cpu));
>  	}
> +	xt_tlock_unlockall();
>  }
> =20
>  static struct xt_counters * alloc_counters(struct xt_table *table)
> @@ -1393,14 +1390,14 @@ do_add_counters(struct net *net, void __user =
*user, unsigned int len, int compat
>  	local_bh_disable();
>  	/* Choose the copy that is on our node */
>  	curcpu =3D smp_processor_id();
> -	spin_lock(&__get_cpu_var(ip_tables_lock));
> +	xt_tlock_lock();
>  	loc_cpu_entry =3D private->entries[curcpu];
>  	IPT_ENTRY_ITERATE(loc_cpu_entry,
>  			  private->size,
>  			  add_counter_to_entry,
>  			  paddc,
>  			  &i);
> -	spin_unlock(&__get_cpu_var(ip_tables_lock));
> +	xt_tlock_unlock();
>  	local_bh_enable();
> =20
>   unlock_up_free:
> @@ -2220,10 +2217,7 @@ static struct pernet_operations ip_tables_net_=
ops =3D {
> =20
>  static int __init ip_tables_init(void)
>  {
> -	int cpu, ret;
> -
> -	for_each_possible_cpu(cpu)
> -		spin_lock_init(&per_cpu(ip_tables_lock, cpu));
> +	int ret;
> =20
>  	ret =3D register_pernet_subsys(&ip_tables_net_ops);
>  	if (ret < 0)
> diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6=
_tables.c
> index ac46ca4..d6ba69e 100644
> --- a/net/ipv6/netfilter/ip6_tables.c
> +++ b/net/ipv6/netfilter/ip6_tables.c
> @@ -329,7 +329,6 @@ static void trace_packet(struct sk_buff *skb,
>  }
>  #endif
> =20
> -static DEFINE_PER_CPU(spinlock_t, ip6_tables_lock);
> =20
>  /* Returns one of the generic firewall policies, like NF_ACCEPT. */
>  unsigned int
> @@ -368,7 +367,7 @@ ip6t_do_table(struct sk_buff *skb,
>  	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
> =20
>  	local_bh_disable();
> -	spin_lock(&__get_cpu_var(ip6_tables_lock));
> +	xt_tlock_lock();
>  	private =3D table->private;
>  	table_base =3D private->entries[smp_processor_id()];
> =20
> @@ -469,7 +468,7 @@ ip6t_do_table(struct sk_buff *skb,
>  #ifdef CONFIG_NETFILTER_DEBUG
>  	((struct ip6t_entry *)table_base)->comefrom =3D NETFILTER_LINK_POIS=
ON;
>  #endif
> -	spin_unlock(&__get_cpu_var(ip6_tables_lock));
> +	xt_tlock_unlock();
>  	local_bh_enable();
> =20
>  #ifdef DEBUG_ALLOW_ALL
> @@ -925,33 +924,31 @@ get_counters(const struct xt_table_info *t,
>  {
>  	unsigned int cpu;
>  	unsigned int i =3D 0;
> -	unsigned int curcpu =3D raw_smp_processor_id();
> +	unsigned int curcpu;
> =20
> +	xt_tlock_lockall();
>  	/* Instead of clearing (by a previous call to memset())
>  	 * the counters and using adds, we set the counters
>  	 * with data used by 'current' CPU
> -	 * We dont care about preemption here.
>  	 */
> -	spin_lock_bh(&per_cpu(ip6_tables_lock, curcpu));
> +	curcpu =3D smp_processor_id();
>  	IP6T_ENTRY_ITERATE(t->entries[curcpu],
>  			   t->size,
>  			   set_entry_to_counter,
>  			   counters,
>  			   &i);
> -	spin_unlock_bh(&per_cpu(ip6_tables_lock, curcpu));
> =20
>  	for_each_possible_cpu(cpu) {
>  		if (cpu =3D=3D curcpu)
>  			continue;
>  		i =3D 0;
> -		spin_lock_bh(&per_cpu(ip6_tables_lock, cpu));
>  		IP6T_ENTRY_ITERATE(t->entries[cpu],
>  				  t->size,
>  				  add_entry_to_counter,
>  				  counters,
>  				  &i);
> -		spin_unlock_bh(&per_cpu(ip6_tables_lock, cpu));
>  	}
> +	xt_tlock_unlockall();
>  }
> =20
>  static struct xt_counters *alloc_counters(struct xt_table *table)
> @@ -1423,14 +1420,14 @@ do_add_counters(struct net *net, void __user =
*user, unsigned int len,
>  	local_bh_disable();
>  	/* Choose the copy that is on our node */
>  	curcpu =3D smp_processor_id();
> -	spin_lock(&__get_cpu_var(ip6_tables_lock));
> +	xt_tlock_lock();
>  	loc_cpu_entry =3D private->entries[curcpu];
>  	IP6T_ENTRY_ITERATE(loc_cpu_entry,
>  			  private->size,
>  			  add_counter_to_entry,
>  			  paddc,
>  			  &i);
> -	spin_unlock(&__get_cpu_var(ip6_tables_lock));
> +	xt_tlock_unlock();
>  	local_bh_enable();
> =20
>   unlock_up_free:
> @@ -2248,10 +2245,7 @@ static struct pernet_operations ip6_tables_net=
_ops =3D {
> =20
>  static int __init ip6_tables_init(void)
>  {
> -	int cpu, ret;
> -
> -	for_each_possible_cpu(cpu)
> -		spin_lock_init(&per_cpu(ip6_tables_lock, cpu));
> +	int ret;
> =20
>  	ret =3D register_pernet_subsys(&ip6_tables_net_ops);
>  	if (ret < 0)
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index 0d94020..f2ad79f 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -670,19 +670,21 @@ xt_replace_table(struct xt_table *table,
>  {
>  	struct xt_table_info *oldinfo, *private;
> =20
> +	xt_tlock_lockall();
>  	/* Do the substitution. */
>  	private =3D table->private;
>  	/* Check inside lock: is the old number correct? */
>  	if (num_counters !=3D private->number) {
>  		duprintf("num_counters !=3D table->private->number (%u/%u)\n",
>  			 num_counters, private->number);
> +		xt_tlock_unlockall();
>  		*error =3D -EAGAIN;
>  		return NULL;
>  	}
>  	oldinfo =3D private;
>  	table->private =3D newinfo;
>  	newinfo->initial_entries =3D oldinfo->initial_entries;
> -
> +	xt_tlock_unlockall();
>  	return oldinfo;
>  }
>  EXPORT_SYMBOL_GPL(xt_replace_table);
> @@ -1126,9 +1128,58 @@ static struct pernet_operations xt_net_ops =3D=
 {
>  	.init =3D xt_net_init,
>  };
> =20
> +static DEFINE_PER_CPU(spinlock_t, xt_tables_lock);
> +
> +void xt_tlock_lockall(void)
> +{
> +	int cpu;
> +
> +	local_bh_disable();
> +	preempt_disable();
> +	for_each_possible_cpu(cpu) {
> +		spin_lock(&per_cpu(xt_tables_lock, cpu));
> +		/*
> +		 * avoid preempt counter overflow
> +		 */
> +		preempt_enable_no_resched();
> +	}
> +}
> +EXPORT_SYMBOL(xt_tlock_lockall);
> +
> +void xt_tlock_unlockall(void)
> +{
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		preempt_disable();
> +		spin_unlock(&per_cpu(xt_tables_lock, cpu));
> +	}
> +	preempt_enable();
> +	local_bh_enable();
> +}
> +EXPORT_SYMBOL(xt_tlock_unlockall);
> +
> +/*
> + * preemption should be disabled by caller
> + */
> +void xt_tlock_lock(void)
> +{
> +	spin_lock(&__get_cpu_var(xt_tables_lock));
> +}
> +EXPORT_SYMBOL(xt_tlock_lock);
> +
> +void xt_tlock_unlock(void)
> +{
> +	spin_unlock(&__get_cpu_var(xt_tables_lock));
> +}
> +EXPORT_SYMBOL(xt_tlock_unlock);
> +
>  static int __init xt_init(void)
>  {
> -	int i, rv;
> +	int i, rv, cpu;
> +
> +	for_each_possible_cpu(cpu)
> +		spin_lock_init(&per_cpu(xt_tables_lock, cpu));
> =20
>  	xt =3D kmalloc(sizeof(struct xt_af) * NFPROTO_NUMPROTO, GFP_KERNEL)=
;
>  	if (!xt)
>=20
>=20

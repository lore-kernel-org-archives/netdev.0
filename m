From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFT 3/3] iptables: lock free counters
Date: Wed, 04 Feb 2009 04:10:22 +0100
Message-ID: <4989071E.5000803@cosmosbay.com>
References: <20090204001202.724266235@vyatta.com> <20090204001755.808036408@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rick Jones <rick.jones2@hp.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090204001755.808036408@vyatta.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> Make netfilter tables that use x_tables (iptables, ip6tables, arptabl=
es)
> operatate without locking on the receive path.
> Replace existing reader/writer lock with Read-Copy-Update to
> elminate the overhead of a read lock on each incoming packet.
> This should reduce the overhead of iptables especially on SMP
> systems.
>=20
> The previous code used a reader-writer lock for two purposes.
> The first was to ensure that the xt_table_info reference was not in
> process of being changed. Since xt_table_info is only freed via one
> routine, it was a direct conversion to RCU.
>=20
> The other use of the reader-writer lock was to to block changes
> to counters while they were being read. This is handled by swapping i=
n
> a new set of counter values and then summing the old ones. The sum
> is then restored back on a single cpu.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
>  include/linux/netfilter/x_tables.h |   13 ++++
>  net/ipv4/netfilter/arp_tables.c    |   92 ++++++++++++++++++++++++--=
---------
>  net/ipv4/netfilter/ip_tables.c     |   97 ++++++++++++++++++++++++--=
-----------
>  net/ipv6/netfilter/ip6_tables.c    |   97 +++++++++++++++++++++++---=
-----------
>  net/netfilter/x_tables.c           |   67 +++++++++++++++++++++----
>  5 files changed, 258 insertions(+), 108 deletions(-)
>=20
> --- a/include/linux/netfilter/x_tables.h	2009-02-02 15:06:39.89375184=
5 -0800
> +++ b/include/linux/netfilter/x_tables.h	2009-02-03 15:44:21.74366321=
6 -0800
> @@ -353,7 +353,7 @@ struct xt_table
>  	unsigned int valid_hooks;
> =20
>  	/* Lock for the curtain */
> -	rwlock_t lock;
> +	struct mutex lock;
> =20
>  	/* Man behind the curtain... */
>  	struct xt_table_info *private;
> @@ -383,9 +383,15 @@ struct xt_table_info
>  	unsigned int hook_entry[NF_INET_NUMHOOKS];
>  	unsigned int underflow[NF_INET_NUMHOOKS];
> =20
> +	/* For the dustman... */
> +	union {
> +		struct rcu_head rcu;
> +		struct work_struct work;
> +	};
> +
>  	/* ipt_entry tables: one per CPU */
>  	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
> -	char *entries[1];
> +	void *entries[1];
>  };
> =20
>  #define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
> @@ -432,6 +438,9 @@ extern void xt_proto_fini(struct net *ne
> =20
>  extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
>  extern void xt_free_table_info(struct xt_table_info *info);
> +extern void xt_zero_table_entries(struct xt_table_info *info);
> +extern void xt_swap_table_entries(struct xt_table_info *old,
> +				  struct xt_table_info *new);
> =20
>  #ifdef CONFIG_COMPAT
>  #include <net/compat.h>
> --- a/net/ipv4/netfilter/ip_tables.c	2009-02-02 15:06:29.684249364 -0=
800
> +++ b/net/ipv4/netfilter/ip_tables.c	2009-02-03 15:52:32.047583686 -0=
800
> @@ -347,10 +347,12 @@ ipt_do_table(struct sk_buff *skb,
>  	mtpar.family  =3D tgpar.family =3D NFPROTO_IPV4;
>  	tgpar.hooknum =3D hook;
> =20
> -	read_lock_bh(&table->lock);
>  	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
> -	private =3D table->private;
> -	table_base =3D (void *)private->entries[smp_processor_id()];
> +
> +	rcu_read_lock_bh();
> +	private =3D rcu_dereference(table->private);
> +	table_base =3D rcu_dereference(private->entries[smp_processor_id()]=
);
> +
>  	e =3D get_entry(table_base, private->hook_entry[hook]);
> =20
>  	/* For return from builtin chain */
> @@ -445,7 +447,7 @@ ipt_do_table(struct sk_buff *skb,
>  		}
>  	} while (!hotdrop);
> =20
> -	read_unlock_bh(&table->lock);
> +	rcu_read_unlock_bh();
> =20
>  #ifdef DEBUG_ALLOW_ALL
>  	return NF_ACCEPT;
> @@ -924,13 +926,45 @@ get_counters(const struct xt_table_info=20
>  				  counters,
>  				  &i);
>  	}
> +
> +}
> +
> +/* We're lazy, and add to the first CPU; overflow works its fey magi=
c
> + * and everything is OK. */
> +static int
> +add_counter_to_entry(struct ipt_entry *e,
> +		     const struct xt_counters addme[],
> +		     unsigned int *i)
> +{
> +	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
> +
> +	(*i)++;
> +	return 0;
> +}
> +
> +/* Take values from counters and add them back onto the current cpu =
*/
> +static void put_counters(struct xt_table_info *t,
> +			 const struct xt_counters counters[])
> +{
> +	unsigned int i, cpu;
> +
> +	local_bh_disable();
> +	cpu =3D smp_processor_id();
> +	i =3D 0;
> +	IPT_ENTRY_ITERATE(t->entries[cpu],
> +			  t->size,
> +			  add_counter_to_entry,
> +			  counters,
> +			  &i);
> +	local_bh_enable();
>  }
> =20
>  static struct xt_counters * alloc_counters(struct xt_table *table)
>  {
>  	unsigned int countersize;
>  	struct xt_counters *counters;
> -	const struct xt_table_info *private =3D table->private;
> +	struct xt_table_info *private =3D table->private;
> +	struct xt_table_info *tmp;
> =20
>  	/* We need atomic snapshot of counters: rest doesn't change
>  	   (other than comefrom, which userspace doesn't care
> @@ -939,14 +973,30 @@ static struct xt_counters * alloc_counte
>  	counters =3D vmalloc_node(countersize, numa_node_id());
> =20
>  	if (counters =3D=3D NULL)
> -		return ERR_PTR(-ENOMEM);
> +		goto nomem;
> +
> +	tmp =3D xt_alloc_table_info(private->size);
> +	if (!tmp)
> +		goto free_counters;
> +

> +	xt_zero_table_entries(tmp);
This is not correct. We must copy rules and zero counters on the copied=
 stuff.

> +
> +	mutex_lock(&table->lock);
> +	xt_swap_table_entries(private, tmp);
> +	synchronize_net();	/* Wait until smoke has cleared */
> =20
> -	/* First, sum counters... */
> -	write_lock_bh(&table->lock);
> -	get_counters(private, counters);
> -	write_unlock_bh(&table->lock);
> +	get_counters(tmp, counters);

Yes, tmp now hold previous pointers

> +	put_counters(private, counters);
> +	mutex_unlock(&table->lock);
> +
> +	xt_free_table_info(tmp);
> =20
>  	return counters;
> +
> + free_counters:
> +	vfree(counters);
> + nomem:
> +	return ERR_PTR(-ENOMEM);
>  }
> =20
>  static int
> @@ -1312,27 +1362,6 @@ do_replace(struct net *net, void __user=20
>  	return ret;
>  }
> =20
> -/* We're lazy, and add to the first CPU; overflow works its fey magi=
c
> - * and everything is OK. */
> -static int
> -add_counter_to_entry(struct ipt_entry *e,
> -		     const struct xt_counters addme[],
> -		     unsigned int *i)
> -{
> -#if 0
> -	duprintf("add_counter: Entry %u %lu/%lu + %lu/%lu\n",
> -		 *i,
> -		 (long unsigned int)e->counters.pcnt,
> -		 (long unsigned int)e->counters.bcnt,
> -		 (long unsigned int)addme[*i].pcnt,
> -		 (long unsigned int)addme[*i].bcnt);
> -#endif
> -
> -	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
> -
> -	(*i)++;
> -	return 0;
> -}
> =20
>  static int
>  do_add_counters(struct net *net, void __user *user, unsigned int len=
, int compat)
> @@ -1393,13 +1422,14 @@ do_add_counters(struct net *net, void __
>  		goto free;
>  	}
> =20
> -	write_lock_bh(&t->lock);
> +	mutex_lock(&t->lock);
>  	private =3D t->private;
>  	if (private->number !=3D num_counters) {
>  		ret =3D -EINVAL;
>  		goto unlock_up_free;
>  	}
> =20
> +	preempt_disable();
>  	i =3D 0;
>  	/* Choose the copy that is on our node */
>  	loc_cpu_entry =3D private->entries[raw_smp_processor_id()];
> @@ -1408,8 +1438,9 @@ do_add_counters(struct net *net, void __
>  			  add_counter_to_entry,
>  			  paddc,
>  			  &i);
> +	preempt_enable();
>   unlock_up_free:
> -	write_unlock_bh(&t->lock);
> +	mutex_unlock(&t->lock);
>  	xt_table_unlock(t);
>  	module_put(t->me);
>   free:
> --- a/net/netfilter/x_tables.c	2009-02-02 15:06:29.708249745 -0800
> +++ b/net/netfilter/x_tables.c	2009-02-03 15:44:21.743663216 -0800
> @@ -611,18 +611,61 @@ struct xt_table_info *xt_alloc_table_inf
>  }
>  EXPORT_SYMBOL(xt_alloc_table_info);
> =20
> -void xt_free_table_info(struct xt_table_info *info)
> +/* Zero out entries */
> +void xt_zero_table_entries(struct xt_table_info *info)
>  {
> -	int cpu;
> +	unsigned int cpu;
> +
> +	for_each_possible_cpu(cpu)
> +		memset(info->entries[cpu], 0, info->size);
> +}
> +EXPORT_SYMBOL_GPL(xt_zero_table_entries);

Hum, you forgot entries[cpu] points to quite complex data set,
with iptables rules, countaining counters...

Only counters must be zeroed, one by one.

You thus need an ITERATE invocation...

I wont be able to make the incremental patch (too busy @work at this mo=
ment),
I am sorry :(

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

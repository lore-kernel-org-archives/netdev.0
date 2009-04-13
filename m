From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU
Date: Mon, 13 Apr 2009 15:24:37 -0700
Message-ID: <20090413152437.c48723f6.akpm@linux-foundation.org>
References: <20090411174801.GG6822@linux.vnet.ibm.com>
	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>
	<20090412173108.GO6822@linux.vnet.ibm.com>
	<20090412.181330.23529546.davem@davemloft.net>
	<20090413040413.GQ6822@linux.vnet.ibm.com>
	<20090413095309.631cf395@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, davem@davemloft.net, paulus@samba.org,
	mingo@elte.hu, torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090413095309.631cf395@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Apr 2009 09:53:09 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> This is an alternative version of ip/ip6/arp tables locking using
> per-cpu locks.  This avoids the overhead of synchronize_net() during
> update but still removes the expensive rwlock in earlier versions.
> 
> The idea for this came from an earlier version done by Eric Duzamet.
> Locking is done per-cpu, the fast path locks on the current cpu
> and updates counters.  The slow case involves acquiring the locks on
> all cpu's.
> 
> The mutex that was added for 2.6.30 in xt_table is unnecessary since
> there already is a mutex for xt[af].mutex that is held.
> 
> Tested basic functionality (add/remove/list), but don't have test cases
> for stress, ip6tables or arptables.
> 
>  unsigned int
>  ipt_do_table(struct sk_buff *skb,
> @@ -339,9 +341,10 @@ ipt_do_table(struct sk_buff *skb,
>  
>  	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
>  
> -	rcu_read_lock_bh();
> -	private = rcu_dereference(table->private);
> -	table_base = rcu_dereference(private->entries[smp_processor_id()]);
> +	local_bh_disable();
> +	spin_lock(&__get_cpu_var(ip_tables_lock));

spin_lock_bh()?

> +	private = table->private;
> +	table_base = private->entries[smp_processor_id()];
>  
>  	e = get_entry(table_base, private->hook_entry[hook]);
>  
> @@ -436,8 +439,8 @@ ipt_do_table(struct sk_buff *skb,
>  			e = (void *)e + e->next_offset;
>  		}
>  	} while (!hotdrop);
> -
> -	rcu_read_unlock_bh();
> +	spin_unlock(&__get_cpu_var(ip_tables_lock));
> +	local_bh_enable();
>  
>  #ifdef DEBUG_ALLOW_ALL
>  	return NF_ACCEPT;
> @@ -891,86 +894,34 @@ get_counters(const struct xt_table_info 
>  	     struct xt_counters counters[])
>  {
>  	unsigned int cpu;
> -	unsigned int i;
> -	unsigned int curcpu;
> +	unsigned int i = 0;
> +	unsigned int curcpu = raw_smp_processor_id();
>  
>  	/* Instead of clearing (by a previous call to memset())
>  	 * the counters and using adds, we set the counters
>  	 * with data used by 'current' CPU
>  	 * We dont care about preemption here.
>  	 */
> -	curcpu = raw_smp_processor_id();
> -
> -	i = 0;
> +	spin_lock_bh(&per_cpu(ip_tables_lock, curcpu));
>  	IPT_ENTRY_ITERATE(t->entries[curcpu],
>  			  t->size,
>  			  set_entry_to_counter,
>  			  counters,
>  			  &i);
> +	spin_unlock_bh(&per_cpu(ip_tables_lock, curcpu));
>  
>  	for_each_possible_cpu(cpu) {
>  		if (cpu == curcpu)
>  			continue;
> +
>  		i = 0;
> +		spin_lock_bh(&per_cpu(ip_tables_lock, cpu));
>  		IPT_ENTRY_ITERATE(t->entries[cpu],
>  				  t->size,
>  				  add_entry_to_counter,
>  				  counters,
>  				  &i);
> -	}

This would be racy against cpu hotplug if this code was hotplug-aware.

And it should be hotplug aware, really.  num_possible_cpus() can exceed
num_online_cpus().  The extent by which possible>online is
controversial, but one can conceive of situations where it is "lots".

Is lib/percpu_counter.c no good for this application?  Unfixably no
good?  That code automagically handles cpu hotplug.



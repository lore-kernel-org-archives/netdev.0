From: "Kevin W. Rudd" <ruddk@us.ibm.com>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Thu, 18 Dec 2003 15:17:38 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312181515210.6088-100000@w-kevinr.svc.beaverton.ibm.com>
References: <Pine.LNX.4.44.0312130121360.7978-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <niv@us.ibm.com>, <ak@suse.de>,
        <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
        <chester.f.johnson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312130121360.7978-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sat, 13 Dec 2003, Julian Anastasov wrote:

> Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
> 
> 	OK, here is a change that compiles. No fib changes yet (it
> is the next step). I'm not sure what var names are better.
> 

The changes look good from an operational point of view.  Both the
default pmtu_mode approach and setting ignore_tos resolved the problem
on my test system.

> 	What about ip_rt_redirect? May be we need the same TOS
> matching behavior if TOS is changed somewhere after routing?

I would think that redirects would suffer from the same problem, but I
haven't directly tested that scenario myself.  I think it would be
prudent to take the same approach in this area (at least have ignore_tos
honored).

Other than my normal daily interrupts, one of the reasons it took
me so long to play with your proposed patch was that I had to get a
2.6 kernel up and running on my test system.  The original customer
complaint we were following up on (and all of my prior testing)
was against a 2.4 kernel.  We would like to see these same changes
rolled into the 2.4 train also if at all possible.

Thanks,
       -Kevin

> 
> diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
> --- a/include/linux/sysctl.h	Sat Dec 13 01:16:15 2003
> +++ b/include/linux/sysctl.h	Sat Dec 13 01:16:15 2003
> @@ -329,6 +329,8 @@
>  	NET_IPV4_ROUTE_MIN_PMTU=16,
>  	NET_IPV4_ROUTE_MIN_ADVMSS=17,
>  	NET_IPV4_ROUTE_SECRET_INTERVAL=18,
> +	NET_IPV4_ROUTE_IGNORE_TOS=19,
> +	NET_IPV4_ROUTE_PMTU_MODE=20,
>  };
>  
>  enum
> diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
> --- a/net/ipv4/route.c	Sat Dec 13 01:16:15 2003
> +++ b/net/ipv4/route.c	Sat Dec 13 01:16:15 2003
> @@ -124,6 +124,14 @@
>  int ip_rt_min_advmss		= 256;
>  int ip_rt_secret_interval	= 10 * 60 * HZ;
>  static unsigned long rt_deadline;
> +#ifdef CONFIG_IP_ROUTE_TOS
> +static u8 iptos_rt_mask		= IPTOS_RT_MASK;
> +int ip_rt_ignore_tos;
> +#else
> +static u8 iptos_rt_mask;
> +int ip_rt_ignore_tos		= 1;
> +#endif
> +int ip_rt_pmtu_mode;		/* 1=match by iph->tos, 0=ignore TOS for PMTU */
>  
>  #define RTprint(a...)	printk(KERN_DEBUG a)
>  
> @@ -967,13 +975,12 @@
>  void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
>  		    u32 saddr, u8 tos, struct net_device *dev)
>  {
> -	int i, k;
> +	int i;
>  	struct in_device *in_dev = in_dev_get(dev);
>  	struct rtable *rth, **rthp;
>  	u32  skeys[2] = { saddr, 0 };
> -	int  ikeys[2] = { dev->ifindex, 0 };
>  
> -	tos &= IPTOS_RT_MASK;
> +	tos &= iptos_rt_mask;
>  
>  	if (!in_dev)
>  		return;
> @@ -993,10 +1000,7 @@
>  	}
>  
>  	for (i = 0; i < 2; i++) {
> -		for (k = 0; k < 2; k++) {
> -			unsigned hash = rt_hash_code(daddr,
> -						     skeys[i] ^ (ikeys[k] << 5),
> -						     tos);
> +			unsigned hash = rt_hash_code(daddr, skeys[i], tos);
>  
>  			rthp=&rt_hash_table[hash].chain;
>  
> @@ -1008,7 +1012,9 @@
>  				if (rth->fl.fl4_dst != daddr ||
>  				    rth->fl.fl4_src != skeys[i] ||
>  				    rth->fl.fl4_tos != tos ||
> -				    rth->fl.oif != ikeys[k] ||
> +				    (rth->fl.oif &&
> +				     rth->fl.oif != dev->ifindex) ||
> +				    rth->rt_dst == rth->rt_gateway ||
>  				    rth->fl.iif != 0) {
>  					rthp = &rth->u.rt_next;
>  					continue;
> @@ -1075,7 +1081,6 @@
>  			rcu_read_unlock();
>  		do_next:
>  			;
> -		}
>  	}
>  	in_dev_put(in_dev);
>  	return;
> @@ -1105,8 +1110,7 @@
>  		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
>  			   rt->u.dst.expires) {
>  			unsigned hash = rt_hash_code(rt->fl.fl4_dst,
> -						     rt->fl.fl4_src ^
> -							(rt->fl.oif << 5),
> +						     rt->fl.fl4_src,
>  						     rt->fl.fl4_tos);
>  #if RT_CACHE_DEBUG >= 1
>  			printk(KERN_DEBUG "ip_rt_advice: redirect to "
> @@ -1237,21 +1241,33 @@
>  	return 68;
>  }
>  
> +/* See IPTOS_RT_MASK */
> +static u8 all_tos_values[8] = { 0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18, 0x1C };
> +
>  unsigned short ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu)
>  {
> -	int i;
> +	int i, j, ntos;
>  	unsigned short old_mtu = ntohs(iph->tot_len);
>  	struct rtable *rth;
>  	u32  skeys[2] = { iph->saddr, 0, };
>  	u32  daddr = iph->daddr;
> -	u8   tos = iph->tos & IPTOS_RT_MASK;
> +	u8   *tos_values, tos = iph->tos & iptos_rt_mask;
>  	unsigned short est_mtu = 0;
>  
>  	if (ipv4_config.no_pmtu_disc)
>  		return 0;
>  
> +	if (ip_rt_pmtu_mode || !iptos_rt_mask) {
> +		tos_values = &tos;
> +		ntos = 1;
> +	} else {
> +		tos_values = all_tos_values;
> +		ntos = ARRAY_SIZE(all_tos_values);
> +	}
> +
> +	for (j = 0; j < ntos; j++)
>  	for (i = 0; i < 2; i++) {
> -		unsigned hash = rt_hash_code(daddr, skeys[i], tos);
> +		unsigned hash = rt_hash_code(daddr, skeys[i], tos_values[j]);
>  
>  		rcu_read_lock();
>  		for (rth = rt_hash_table[hash].chain; rth;
> @@ -1259,9 +1275,9 @@
>  			smp_read_barrier_depends();
>  			if (rth->fl.fl4_dst == daddr &&
>  			    rth->fl.fl4_src == skeys[i] &&
> +			    rth->fl.fl4_tos == tos_values[j] &&
>  			    rth->rt_dst  == daddr &&
>  			    rth->rt_src  == iph->saddr &&
> -			    rth->fl.fl4_tos == tos &&
>  			    rth->fl.iif == 0 &&
>  			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {
>  				unsigned short mtu = new_mtu;
> @@ -1503,7 +1519,7 @@
>  	RT_CACHE_STAT_INC(in_slow_mc);
>  
>  	in_dev_put(in_dev);
> -	hash = rt_hash_code(daddr, saddr ^ (dev->ifindex << 5), tos);
> +	hash = rt_hash_code(daddr, saddr, tos);
>  	return rt_intern_hash(hash, rth, (struct rtable**) &skb->dst);
>  
>  e_nobufs:
> @@ -1554,7 +1570,7 @@
>  	if (!in_dev)
>  		goto out;
>  
> -	hash = rt_hash_code(daddr, saddr ^ (fl.iif << 5), tos);
> +	hash = rt_hash_code(daddr, saddr, tos);
>  
>  	/* Check for the most weird martians, which can be not detected
>  	   by fib_lookup.
> @@ -1846,8 +1862,8 @@
>  	unsigned	hash;
>  	int iif = dev->ifindex;
>  
> -	tos &= IPTOS_RT_MASK;
> -	hash = rt_hash_code(daddr, saddr ^ (iif << 5), tos);
> +	tos &= iptos_rt_mask;
> +	hash = rt_hash_code(daddr, saddr, tos);
>  
>  	rcu_read_lock();
>  	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
> @@ -1912,11 +1928,11 @@
>  
>  int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
>  {
> -	u32 tos	= oldflp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK);
> +	u32 tos	= oldflp->fl4_tos & (iptos_rt_mask | RTO_ONLINK);
>  	struct flowi fl = { .nl_u = { .ip4_u =
>  				      { .daddr = oldflp->fl4_dst,
>  					.saddr = oldflp->fl4_src,
> -					.tos = tos & IPTOS_RT_MASK,
> +					.tos = tos & iptos_rt_mask,
>  					.scope = ((tos & RTO_ONLINK) ?
>  						  RT_SCOPE_LINK :
>  						  RT_SCOPE_UNIVERSE),
> @@ -2190,7 +2206,7 @@
>  
>  	rth->rt_flags = flags;
>  
> -	hash = rt_hash_code(oldflp->fl4_dst, oldflp->fl4_src ^ (oldflp->oif << 5), tos);
> +	hash = rt_hash_code(oldflp->fl4_dst, oldflp->fl4_src, tos);
>  	err = rt_intern_hash(hash, rth, rp);
>  done:
>  	if (free_res)
> @@ -2213,8 +2229,9 @@
>  {
>  	unsigned hash;
>  	struct rtable *rth;
> +	u8 tos = flp->fl4_tos & (iptos_rt_mask | RTO_ONLINK);
>  
> -	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src ^ (flp->oif << 5), flp->fl4_tos);
> +	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src, tos);
>  
>  	rcu_read_lock();
>  	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
> @@ -2226,8 +2243,7 @@
>  #ifdef CONFIG_IP_ROUTE_FWMARK
>  		    rth->fl.fl4_fwmark == flp->fl4_fwmark &&
>  #endif
> -		    !((rth->fl.fl4_tos ^ flp->fl4_tos) &
> -			    (IPTOS_RT_MASK | RTO_ONLINK))) {
> +		    rth->fl.fl4_tos == tos) {
>  			rth->u.dst.lastuse = jiffies;
>  			dst_hold(&rth->u.dst);
>  			rth->u.dst.__use++;
> @@ -2479,6 +2495,26 @@
>  }
>  
>  #ifdef CONFIG_SYSCTL
> +
> +static int ipv4_sysctl_doint_strategy(ctl_table *table, int *name,
> +					int nlen, void *oldval,
> +					size_t *oldlenp, void *newval,
> +					size_t newlen, void **context)
> +{
> +	int val;
> +
> +	if (!newval || !newlen)
> +		return 0;
> +	if (newlen != sizeof(int))
> +		return -EINVAL;
> +	if (get_user(val, (int *)newval))
> +		return -EFAULT;
> +	if (val == *(int *) table->data)
> +		return 0;
> +	*(int *) table->data = val;
> +	return 1;
> +}
> +
>  static int flush_delay;
>  
>  static int ipv4_sysctl_rtcache_flush(ctl_table *ctl, int write,
> @@ -2508,6 +2544,53 @@
>  	return 0;
>  }
>  
> +#ifdef CONFIG_IP_ROUTE_TOS
> +
> +static void do_ignore_tos(void)
> +{
> +	iptos_rt_mask = ip_rt_ignore_tos? 0 : IPTOS_RT_MASK;
> +	rt_cache_flush(0); 
> +}
> +
> +#endif
> +
> +static int ip_rt_ignore_tos_handler(ctl_table *ctl, int write,
> +					struct file *filp, void *buffer,
> +					size_t *lenp)
> +{
> +	if (write) {
> +#ifdef CONFIG_IP_ROUTE_TOS
> +		int old = ip_rt_ignore_tos;
> +		int ret = proc_dointvec(ctl, write, filp, buffer, lenp);
> +
> +		if (ret)
> +			return ret;
> +		if (old != ip_rt_ignore_tos) do_ignore_tos();
> +		return 0;
> +#else
> +		return -EINVAL;
> +#endif
> +	} 
> +	return proc_dointvec(ctl, write, filp, buffer, lenp);
> +}
> +static int ipv4_sysctl_ignore_tos_strategy(ctl_table *table, int *name,
> +						int nlen, void *oldval,
> +						size_t *oldlenp, void *newval,
> +						size_t newlen, void **context)
> +{
> +#ifdef CONFIG_IP_ROUTE_TOS
> +	int ret = ipv4_sysctl_doint_strategy(table, name, nlen, oldval, oldlenp,
> +						newval, newlen, context);
> +
> +	if (1 != ret)
> +		return ret;
> +	do_ignore_tos();
> +	return 0;
> +#else
> +	return (newval || newlen) ? -EINVAL : 0;
> +#endif
> +}
> +
>  ctl_table ipv4_route_table[] = {
>          {
>  		.ctl_name 	= NET_IPV4_ROUTE_FLUSH,
> @@ -2660,6 +2743,23 @@
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_jiffies,
>  		.strategy	= &sysctl_jiffies,
> +	},
> +	{
> +		.ctl_name	= NET_IPV4_ROUTE_IGNORE_TOS,
> +		.procname	= "ignore_tos",
> +		.data		= &ip_rt_ignore_tos,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &ip_rt_ignore_tos_handler,
> +		.strategy	= &ipv4_sysctl_ignore_tos_strategy,
> +	},
> +	{
> +		.ctl_name	= NET_IPV4_ROUTE_PMTU_MODE,
> +		.procname	= "pmtu_mode",
> +		.data		= &ip_rt_pmtu_mode,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec,
>  	},
>  	{ .ctl_name = 0 }
>  };
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 

--
 Kevin W. Rudd
 Linux Change Team
 IBM Global Services
 1-800-426-7378,  T/L 775-4161

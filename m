From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when	gc_elasticity
 is exceeded
Date: Fri, 17 Oct 2008 06:53:54 +0200
Message-ID: <48F81A62.5080507@cosmosbay.com>
References: <20081006225210.GA29794@hmsreliant.think-freely.org> <48EAEFF9.1000606@cosmosbay.com> <20081013182655.GA9505@hmsreliant.think-freely.org> <20081015.235556.61915120.davem@davemloft.net> <20081016114155.GA15877@hmsreliant.think-freely.org> <48F732CB.8030704@cosmosbay.com> <20081016163644.GA2933@localhost.localdomain> <20081016233517.GA21243@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.18]:34409 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbYJQEyJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 00:54:09 -0400
In-Reply-To: <20081016233517.GA21243@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> On Thu, Oct 16, 2008 at 12:36:44PM -0400, Neil Horman wrote:
>> On Thu, Oct 16, 2008 at 02:25:47PM +0200, Eric Dumazet wrote:
>>> Neil Horman a =E9crit :
>> Yeah, that was quite stupid of me.  I rescind this, and I'll post a =
patch with the=20
>> missing chunk later tonight after I spin/test it.
>>
>=20
>=20
> Ok, heres a new patch, same as before, but added in proper initalizat=
ion for
> stack variables, as well as the missing chunk that actually computed =
the
> standard deviation and maximum chain length.  Built/tested by me succ=
essfully.
> Sorry for the prior noise.  Please review/ack.
>=20
> Regards
> Neil

OK

=46irst, please include the description, everytime you submit a patch.
An extensive description is probably the most important part of a patch=
=2E
Many people will only read description.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20
>=20
>  include/linux/sysctl.h     |    1=20
>  include/net/netns/ipv4.h   |    2=20
>  kernel/sysctl_check.c      |    1=20
>  net/ipv4/route.c           |  130 ++++++++++++++++++++++++++++++++++=
++++++++++-
>  net/ipv4/sysctl_net_ipv4.c |   12 ++++
>  5 files changed, 144 insertions(+), 2 deletions(-)
>=20
>=20
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index d0437f3..481aa44 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -435,6 +435,7 @@ enum
>  	NET_TCP_ALLOWED_CONG_CONTROL=3D123,
>  	NET_TCP_MAX_SSTHRESH=3D124,
>  	NET_TCP_FRTO_RESPONSE=3D125,
> +	NET_IPV4_RT_CACHE_REBUILD_COUNT=3D126,
>  };
> =20
>  enum {
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index a6ed838..4fef762 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
> @@ -46,6 +46,8 @@ struct netns_ipv4 {
>  	int sysctl_icmp_ratelimit;
>  	int sysctl_icmp_ratemask;
>  	int sysctl_icmp_errors_use_inbound_ifaddr;
> +	int sysctl_rt_cache_rebuild_count;
> +	int current_rt_cache_rebuild_count;
> =20
>  	struct timer_list rt_secret_timer;
>  	atomic_t rt_genid;
> diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
> index c35da23..eb9fb57 100644
> --- a/kernel/sysctl_check.c
> +++ b/kernel/sysctl_check.c
> @@ -389,6 +389,7 @@ static const struct trans_ctl_table trans_net_ipv=
4_table[] =3D {
>  	{ NET_TCP_ALLOWED_CONG_CONTROL,		"tcp_allowed_congestion_control" }=
,
>  	{ NET_TCP_MAX_SSTHRESH,			"tcp_max_ssthresh" },
>  	{ NET_TCP_FRTO_RESPONSE,		"tcp_frto_response" },
> +	{ NET_IPV4_RT_CACHE_REBUILD_COUNT,	"rt_cache_rebuild_count" },
>  	{ 2088 /* NET_IPQ_QMAX */,		"ip_queue_maxlen" },
>  	{}
>  };
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6ee5354..0ff28c4 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -129,6 +129,7 @@ static int ip_rt_mtu_expires __read_mostly	=3D 10=
 * 60 * HZ;
>  static int ip_rt_min_pmtu __read_mostly		=3D 512 + 20 + 20;
>  static int ip_rt_min_advmss __read_mostly	=3D 256;
>  static int ip_rt_secret_interval __read_mostly	=3D 10 * 60 * HZ;
> +static int rt_chain_length_max __read_mostly	=3D 8;

Some machine come to life on hostile environments and receive lots of U=
DP messages
from many hosts and may hit this limit before rt_check_expire() has sta=
rted its first
run. Please consider default route cache settings, that allow 16 elemen=
ts per chain
in average. And because of the formula avg+4*sd, a default of 20 would =
be better.

> =20
>  static void rt_worker_func(struct work_struct *work);
>  static DECLARE_DELAYED_WORK(expires_work, rt_worker_func);
> @@ -145,6 +146,7 @@ static struct dst_entry *ipv4_negative_advice(str=
uct dst_entry *dst);
>  static void		 ipv4_link_failure(struct sk_buff *skb);
>  static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
>  static int rt_garbage_collect(struct dst_ops *ops);
> +static void rt_emergency_hash_rebuild(struct net *net);
> =20
> =20
>  static struct dst_ops ipv4_dst_ops =3D {
> @@ -201,6 +203,7 @@ const __u8 ip_tos2prio[16] =3D {
>  struct rt_hash_bucket {
>  	struct rtable	*chain;
>  };
> +
>  #if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK) || \
>  	defined(CONFIG_PROVE_LOCKING)
>  /*
> @@ -669,6 +672,19 @@ static inline u32 rt_score(struct rtable *rt)
>  	return score;
>  }
> =20
> +static inline int rt_caching(struct net *net)
> +{
> +	return net->ipv4.current_rt_cache_rebuild_count <=3D
> +		net->ipv4.sysctl_rt_cache_rebuild_count;
> +}
> +
> +static inline int compare_hash_inputs(struct flowi *fl1, struct flow=
i *fl2)
> +{
> +	return (__force u32)(((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.dadd=
r) |
> +		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr) |
> +		(fl1->iif ^ fl2->iif)) =3D=3D 0);
> +}
> +
>  static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
>  {
>  	return ((__force u32)((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.dadd=
r) |
> @@ -748,11 +764,24 @@ static void rt_do_flush(int process_context)
>  	}
>  }
> =20
> +/*
> + * While freeing expired entries, we compute average chain length
> + * and standard deviation, using fixed-point arithmetic.
> + * This to have an estimation of rt_chain_length_max
> + *  rt_chain_length_max =3D max(elasticity, AVG + 4*SD)
> + * We use 3 bits for frational part, and 29 (or 61) for magnitude.
> + */
> +
> +#define FRACT_BITS 3
> +#define ONE (1UL << FRACT_BITS)
> +
>  static void rt_check_expire(void)
>  {
>  	static unsigned int rover;
>  	unsigned int i =3D rover, goal;
>  	struct rtable *rth, **rthp;
> +	unsigned long length =3D 0, samples =3D 0;
> +	unsigned long sum =3D 0, sum2 =3D 0;
>  	u64 mult;
> =20
>  	mult =3D ((u64)ip_rt_gc_interval) << rt_hash_log;
> @@ -761,6 +790,7 @@ static void rt_check_expire(void)
>  	goal =3D (unsigned int)mult;
>  	if (goal > rt_hash_mask)
>  		goal =3D rt_hash_mask + 1;
> +	length =3D 0;
>  	for (; goal > 0; goal--) {
>  		unsigned long tmo =3D ip_rt_gc_timeout;
> =20
> @@ -770,6 +800,8 @@ static void rt_check_expire(void)
>  		if (need_resched())
>  			cond_resched();
> =20
> +		samples++;
> +
>  		if (*rthp =3D=3D NULL)
>  			continue;
>  		spin_lock_bh(rt_hash_lock_addr(i));
> @@ -784,11 +816,29 @@ static void rt_check_expire(void)
>  				if (time_before_eq(jiffies, rth->u.dst.expires)) {
>  					tmo >>=3D 1;
>  					rthp =3D &rth->u.dst.rt_next;
> +					/*
> +					 * Only bump our length if the hash
> +					 * inputs on entries n and n+1 are not
> +					 * the same, we only count entries on
> +					 * a chain with equal hash inputs once
> +					 * so that entries for different QOS
> +					 * levels, and other non-hash input
> +					 * attributes don't unfairly skew
> +					 * the length computation
> +					 */
> +					if (*rthp &&
> +					    !compare_hash_inputs(&(*rthp)->fl,
> +								 &rth->fl))
> +						length +=3D ONE;

Here you ignore chains with one elements. This introduce a bias in the =
average and sd computation.
A correct test would be :
if ((*rthp =3D=3D NULL) ||
	!compare_hash_inputs(&(*rthp)->fl,&rth->fl))
	length +=3D ONE;

>  					continue;
>  				}
>  			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
>  				tmo >>=3D 1;
>  				rthp =3D &rth->u.dst.rt_next;
> +				if (*rthp &&
> +				    !compare_hash_inputs(&(*rthp)->fl,
> +							 &rth->fl))
> +					length +=3D ONE;

same remark here

>  				continue;
>  			}
> =20
> @@ -797,6 +847,15 @@ static void rt_check_expire(void)
>  			rt_free(rth);
>  		}
>  		spin_unlock_bh(rt_hash_lock_addr(i));
> +		sum +=3D length;
> +		sum2 +=3D length*length;
> +	}
> +	if (samples) {
> +		unsigned long avg =3D sum / samples;
> +		unsigned long sd =3D int_sqrt(sum2 / samples - avg*avg);
> +		rt_chain_length_max =3D max_t(unsigned long,
> +					ip_rt_gc_elasticity,
> +					(avg + 4*sd) >> FRACT_BITS);
>  	}
>  	rover =3D i;
>  }
> @@ -846,6 +905,26 @@ static void rt_secret_rebuild(unsigned long __ne=
t)
>  	mod_timer(&net->ipv4.rt_secret_timer, jiffies + ip_rt_secret_interv=
al);
>  }
> =20
> +static void rt_secret_rebuild_oneshot(struct net *net)
> +{
> +	del_timer_sync(&net->ipv4.rt_secret_timer);
> +	rt_cache_invalidate(net);
> +	if (ip_rt_secret_interval) {
> +		net->ipv4.rt_secret_timer.expires +=3D ip_rt_secret_interval;
> +		add_timer(&net->ipv4.rt_secret_timer);
> +	}
> +}
> +
> +static void rt_emergency_hash_rebuild(struct net *net)
> +{
> +	if (net_ratelimit()) {
> +		printk(KERN_WARNING "Route hash chain too long!\n");
> +		printk(KERN_WARNING "Adjust your secret_interval!\n");
> +	}
> +
> +	rt_secret_rebuild_oneshot(net);
> +}
> +
>  /*
>     Short description of GC goals.
> =20
> @@ -984,6 +1063,7 @@ out:	return 0;
>  static int rt_intern_hash(unsigned hash, struct rtable *rt, struct r=
table **rp)
>  {
>  	struct rtable	*rth, **rthp;
> +	struct rtable	*rthi;
>  	unsigned long	now;
>  	struct rtable *cand, **candp;
>  	u32 		min_score;
> @@ -997,7 +1077,13 @@ restart:
>  	candp =3D NULL;
>  	now =3D jiffies;
> =20
> +	if (!rt_caching(dev_net(rt->u.dst.dev))) {
> +		rt_drop(rt);

Would be nice to add a new counter that one can check in /proc/net/stat=
/rt_cache
RT_CACHE_STAT_INC(notcached)
> +		return 0;
> +	}
> +
>  	rthp =3D &rt_hash_table[hash].chain;
> +	rthi =3D NULL;
> =20
>  	spin_lock_bh(rt_hash_lock_addr(hash));
>  	while ((rth =3D *rthp) !=3D NULL) {
> @@ -1043,6 +1129,17 @@ restart:
>  		chain_length++;
> =20
>  		rthp =3D &rth->u.dst.rt_next;
> +
> +		/*
> +		 * check to see if the next entry in the chain
> +		 * contains the same hash input values as rt.  If it does
> +		 * This is where we will insert into the list, instead of
> +		 * at the head.  This groups entries that differ by aspects not
> +		 * relvant to the hash function together, which we use to adjust
> +		 * our chain length
> +		 */
> +		if (*rthp && compare_hash_inputs(&(*rthp)->fl, &rt->fl))
> +			rthi =3D rth;
>  	}
> =20
>  	if (cand) {
> @@ -1056,6 +1153,16 @@ restart:
>  			*candp =3D cand->u.dst.rt_next;
>  			rt_free(cand);
>  		}
> +	} else {
> +		if (chain_length > rt_chain_length_max) {
> +			struct net *net =3D dev_net(rt->u.dst.dev);
> +			int num =3D ++net->ipv4.current_rt_cache_rebuild_count;
> +			if (!rt_caching(dev_net(rt->u.dst.dev))) {
> +				printk(KERN_WARNING "%s: %d rebuilds is over limit, route cachin=
g disabled\n",
> +					rt->u.dst.dev->name, num);
> +			}
> +			rt_emergency_hash_rebuild(dev_net(rt->u.dst.dev));
> +		}
>  	}
> =20
>  	/* Try to bind route to arp only if it is output
> @@ -1093,7 +1200,11 @@ restart:
>  		}
>  	}
> =20
> -	rt->u.dst.rt_next =3D rt_hash_table[hash].chain;
> +	if (rthi)
> +		rt->u.dst.rt_next =3D rthi->u.dst.rt_next;
> +	else
> +		rt->u.dst.rt_next =3D rt_hash_table[hash].chain;
> +
>  #if RT_CACHE_DEBUG >=3D 2
>  	if (rt->u.dst.rt_next) {
>  		struct rtable *trt;
> @@ -1104,7 +1215,10 @@ restart:
>  		printk("\n");
>  	}
>  #endif
> -	rt_hash_table[hash].chain =3D rt;

Please respin your patch to last tree, this misses my last patch about
memory barrier...

Ah, maybe David did not committed it yet...


> +	if (rthi)
> +		rthi->u.dst.rt_next =3D rt;
> +	else
> +		rt_hash_table[hash].chain =3D rt;
>  	spin_unlock_bh(rt_hash_lock_addr(hash));
>  	*rp =3D rt;
>  	return 0;
> @@ -1207,6 +1321,9 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr=
, __be32 new_gw,
>  	    || ipv4_is_zeronet(new_gw))
>  		goto reject_redirect;
> =20
> +	if (!rt_caching(net))
> +		goto reject_redirect;
> +
>  	if (!IN_DEV_SHARED_MEDIA(in_dev)) {
>  		if (!inet_addr_onlink(in_dev, new_gw, old_gw))
>  			goto reject_redirect;
> @@ -2120,6 +2237,10 @@ int ip_route_input(struct sk_buff *skb, __be32=
 daddr, __be32 saddr,
>  	struct net *net;
> =20
>  	net =3D dev_net(dev);
> +
> +	if (!rt_caching(net))
> +		goto skip_cache;
> +
>  	tos &=3D IPTOS_RT_MASK;
>  	hash =3D rt_hash(daddr, saddr, iif, rt_genid(net));
> =20
> @@ -2144,6 +2265,7 @@ int ip_route_input(struct sk_buff *skb, __be32 =
daddr, __be32 saddr,
>  	}
>  	rcu_read_unlock();
> =20
> +skip_cache:
>  	/* Multicast recognition logic is moved from route cache to here.
>  	   The problem was that too many Ethernet cards have broken/missing
>  	   hardware multicast filters :-( As result the host on multicastin=
g
> @@ -2523,6 +2645,9 @@ int __ip_route_output_key(struct net *net, stru=
ct rtable **rp,
>  	unsigned hash;
>  	struct rtable *rth;
> =20
> +	if (!rt_caching(net))
> +		goto slow_output;
> +
>  	hash =3D rt_hash(flp->fl4_dst, flp->fl4_src, flp->oif, rt_genid(net=
));
> =20
>  	rcu_read_lock_bh();
> @@ -2547,6 +2672,7 @@ int __ip_route_output_key(struct net *net, stru=
ct rtable **rp,
>  	}
>  	rcu_read_unlock_bh();
> =20
> +slow_output:
>  	return ip_route_output_slow(net, rp, flp);
>  }
> =20
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index e0689fd..6d9ab73 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -798,6 +798,14 @@ static struct ctl_table ipv4_net_table[] =3D {
>  		.mode		=3D 0644,
>  		.proc_handler	=3D &proc_dointvec
>  	},
> +	{
> +		.ctl_name	=3D NET_IPV4_RT_CACHE_REBUILD_COUNT,
> +		.procname	=3D "rt_cache_rebuild_count",
> +		.data		=3D &init_net.ipv4.sysctl_rt_cache_rebuild_count,
> +		.maxlen		=3D sizeof(int),
> +		.mode		=3D 0644,
> +		.proc_handler	=3D &proc_dointvec
> +	},

You should describe this in Documentation/networking/ip-sysctl.txt

>  	{ }
>  };
> =20
> @@ -830,8 +838,12 @@ static __net_init int ipv4_sysctl_init_net(struc=
t net *net)
>  			&net->ipv4.sysctl_icmp_ratelimit;
>  		table[5].data =3D
>  			&net->ipv4.sysctl_icmp_ratemask;
> +		table[6].data =3D
> +			&net->ipv4.sysctl_rt_cache_rebuild_count;
>  	}
> =20
> +	net->ipv4.sysctl_rt_cache_rebuild_count =3D 4;
> +
>  	net->ipv4.ipv4_hdr =3D register_net_sysctl_table(net,
>  			net_ipv4_ctl_path, table);
>  	if (net->ipv4.ipv4_hdr =3D=3D NULL)
>=20
>=20

Thank you




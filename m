From: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
Subject: Re: [PATCH v3 net-next 1/2] ipv4: L3 hash-based multipath
Date: Wed, 16 Sep 2015 00:32:01 +0200
Message-ID: <20150916003201.4ad5d6af@tyr>
References: <1442348993-3023-1-git-send-email-pch@ordbogen.com>
	<1442348993-3023-2-git-send-email-pch@ordbogen.com>
	<55F89060.6010707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:59297 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277AbbIOWcF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 18:32:05 -0400
In-Reply-To: <55F89060.6010707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Sep 2015 14:40:48 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On 09/15/2015 01:29 PM, Peter N=C3=B8rlund wrote:
> > Replaces the per-packet multipath with a hash-based multipath using
> > source and destination address.
> >
> > Signed-off-by: Peter N=C3=B8rlund <pch@ordbogen.com>
> > ---
> >   include/net/ip_fib.h     |  11 ++--
> >   net/ipv4/fib_semantics.c | 137
> > +++++++++++++++++++++++++----------------------
> > net/ipv4/route.c         |  23 +++++++- 3 files changed, 102
> > insertions(+), 69 deletions(-)
> >
> > diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> > index a37d043..c335dd4 100644
> > --- a/include/net/ip_fib.h
> > +++ b/include/net/ip_fib.h
> > @@ -79,7 +79,7 @@ struct fib_nh {
> >   	unsigned char		nh_scope;
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> >   	int			nh_weight;
> > -	int			nh_power;
> > +	atomic_t		nh_upper_bound;
> >   #endif
> >   #ifdef CONFIG_IP_ROUTE_CLASSID
> >   	__u32			nh_tclassid;
> > @@ -118,7 +118,7 @@ struct fib_info {
> >   #define fib_advmss fib_metrics[RTAX_ADVMSS-1]
> >   	int			fib_nhs;
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> > -	int			fib_power;
> > +	int			fib_weight;
> >   #endif
> >   	struct rcu_head		rcu;
> >   	struct fib_nh		fib_nh[0];
> > @@ -312,7 +312,12 @@ int ip_fib_check_default(__be32 gw, struct
> > net_device *dev); int fib_sync_down_dev(struct net_device *dev,
> > unsigned long event); int fib_sync_down_addr(struct net *net,
> > __be32 local); int fib_sync_up(struct net_device *dev, unsigned int
> > nh_flags); -void fib_select_multipath(struct fib_result *res);
> > +
> > +extern u32 fib_multipath_secret __read_mostly;
> > +
> > +typedef int (*multipath_hash_func_t)(void *ctx);
> > +void fib_select_multipath(struct fib_result *res,
> > +			  multipath_hash_func_t hash_func, void
> > *ctx);
> >
> >   /* Exported by fib_trie.c */
> >   void fib_trie_init(void);
> > diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> > index 064bd3c..64d3e0e 100644
> > --- a/net/ipv4/fib_semantics.c
> > +++ b/net/ipv4/fib_semantics.c
> > @@ -57,8 +57,7 @@ static unsigned int fib_info_cnt;
> >   static struct hlist_head fib_info_devhash[DEVINDEX_HASHSIZE];
> >
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> > -
> > -static DEFINE_SPINLOCK(fib_multipath_lock);
> > +u32 fib_multipath_secret __read_mostly;
> >
> >   #define for_nexthops(fi)
> > {						\ int nhsel; const
> > struct fib_nh *nh;				\ @@ -468,6
> > +467,55 @@ static int fib_count_nexthops(struct rtnexthop *rtnh,
> > int remaining) return remaining > 0 ? 0 : nhs; }
> >
> > +static void fib_rebalance(struct fib_info *fi)
> > +{
> > +	int total;
> > +	int w;
> > +	struct in_device *in_dev;
> > +
> > +	if (fi->fib_nhs < 2)
> > +		return;
> > +
> > +	total =3D 0;
> > +	for_nexthops(fi) {
> > +		if (nh->nh_flags & RTNH_F_DEAD)
> > +			continue;
> > +
> > +		in_dev =3D __in_dev_get_rcu(nh->nh_dev);
> > +
> > +		if (in_dev &&
> > +		    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
> > +		    nh->nh_flags & RTNH_F_LINKDOWN)
> > +			continue;
> > +
> > +		total +=3D nh->nh_weight;
> > +	} endfor_nexthops(fi);
> > +
> > +	w =3D 0;
> > +	change_nexthops(fi) {
> > +		int upper_bound;
> > +
> > +		in_dev =3D __in_dev_get_rcu(nexthop_nh->nh_dev);
> > +
> > +		if (nexthop_nh->nh_flags & RTNH_F_DEAD) {
> > +			upper_bound =3D -1;
> > +		} else if (in_dev &&
> > +
> > IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
> > +			   nexthop_nh->nh_flags & RTNH_F_LINKDOWN)
> > {
> > +			upper_bound =3D -1;
> > +		} else {
> > +			w +=3D nexthop_nh->nh_weight;
> > +			upper_bound =3D
> > DIV_ROUND_CLOSEST(2147483648LL * w,
> > +							total) - 1;
> > +		}
> > +
> > +		atomic_set(&nexthop_nh->nh_upper_bound,
> > upper_bound);
> > +	} endfor_nexthops(fi);
> > +
> > +	net_get_random_once(&fib_multipath_secret,
> > +			    sizeof(fib_multipath_secret));
> > +}
> > +
> >   static int fib_get_nhs(struct fib_info *fi, struct rtnexthop
> > *rtnh, int remaining, struct fib_config *cfg)
> >   {
> > @@ -1094,8 +1142,15 @@ struct fib_info *fib_create_info(struct
> > fib_config *cfg)
> >
> >   	change_nexthops(fi) {
> >   		fib_info_update_nh_saddr(net, nexthop_nh);
> > +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > +		fi->fib_weight +=3D nexthop_nh->nh_weight;
> > +#endif
> >   	} endfor_nexthops(fi)
> >
> > +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > +	fib_rebalance(fi);
> > +#endif
> > +
> >   link_it:
> >   	ofi =3D fib_find_info(fi);
> >   	if (ofi) {
> > @@ -1317,12 +1372,6 @@ int fib_sync_down_dev(struct net_device
> > *dev, unsigned long event) nexthop_nh->nh_flags |=3D RTNH_F_LINKDOW=
N;
> >   					break;
> >   				}
> > -#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > -				spin_lock_bh(&fib_multipath_lock);
> > -				fi->fib_power -=3D
> > nexthop_nh->nh_power;
> > -				nexthop_nh->nh_power =3D 0;
> > -
> > spin_unlock_bh(&fib_multipath_lock); -#endif
> >   				dead++;
> >   			}
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> > @@ -1345,6 +1394,10 @@ int fib_sync_down_dev(struct net_device
> > *dev, unsigned long event) }
> >   			ret++;
> >   		}
> > +
> > +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > +		fib_rebalance(fi);
> > +#endif
> >   	}
> >
> >   	return ret;
> > @@ -1467,20 +1520,17 @@ int fib_sync_up(struct net_device *dev,
> > unsigned int nh_flags) !__in_dev_get_rtnl(dev))
> >   				continue;
> >   			alive++;
> > -#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > -			spin_lock_bh(&fib_multipath_lock);
> > -			nexthop_nh->nh_power =3D 0;
> >   			nexthop_nh->nh_flags &=3D ~nh_flags;
> > -			spin_unlock_bh(&fib_multipath_lock);
> > -#else
> > -			nexthop_nh->nh_flags &=3D ~nh_flags;
> > -#endif
> >   		} endfor_nexthops(fi)
> >
> >   		if (alive > 0) {
> >   			fi->fib_flags &=3D ~nh_flags;
> >   			ret++;
> >   		}
> > +
> > +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > +		fib_rebalance(fi);
> > +#endif
> >   	}
> >
> >   	return ret;
> > @@ -1488,62 +1538,21 @@ int fib_sync_up(struct net_device *dev,
> > unsigned int nh_flags)
> >
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> >
> > -/*
> > - * The algorithm is suboptimal, but it provides really
> > - * fair weighted route distribution.
> > - */
> > -void fib_select_multipath(struct fib_result *res)
> > +void fib_select_multipath(struct fib_result *res,
> > +			  multipath_hash_func_t hash_func, void
> > *ctx) {
> >   	struct fib_info *fi =3D res->fi;
> > -	struct in_device *in_dev;
> > -	int w;
> > -
> > -	spin_lock_bh(&fib_multipath_lock);
> > -	if (fi->fib_power <=3D 0) {
> > -		int power =3D 0;
> > -		change_nexthops(fi) {
> > -			in_dev =3D
> > __in_dev_get_rcu(nexthop_nh->nh_dev);
> > -			if (nexthop_nh->nh_flags & RTNH_F_DEAD)
> > -				continue;
> > -			if (in_dev &&
> > -
> > IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
> > -			    nexthop_nh->nh_flags & RTNH_F_LINKDOWN)
> > -				continue;
> > -			power +=3D nexthop_nh->nh_weight;
> > -			nexthop_nh->nh_power =3D
> > nexthop_nh->nh_weight;
> > -		} endfor_nexthops(fi);
> > -		fi->fib_power =3D power;
> > -		if (power <=3D 0) {
> > -			spin_unlock_bh(&fib_multipath_lock);
> > -			/* Race condition: route has just become
> > dead. */
> > -			res->nh_sel =3D 0;
> > -			return;
> > -		}
> > -	}
> > -
> > +	int h =3D hash_func(ctx) & 0x7FFFFFFF;
> >
>=20
> So if I understand this correctly you use the ctx and hash function
> at the very start of the fib_select_multipath function call, do I
> have that right?

Correct

>=20
> > -	/* w should be random number [0..fi->fib_power-1],
> > -	 * it is pretty bad approximation.
> > -	 */
> > -
> > -	w =3D jiffies % fi->fib_power;
> > +	for_nexthops(fi) {
> > +		if (h > atomic_read(&nh->nh_upper_bound))
> > +			continue;
> >
> > -	change_nexthops(fi) {
> > -		if (!(nexthop_nh->nh_flags & RTNH_F_DEAD) &&
> > -		    nexthop_nh->nh_power) {
> > -			w -=3D nexthop_nh->nh_power;
> > -			if (w <=3D 0) {
> > -				nexthop_nh->nh_power--;
> > -				fi->fib_power--;
> > -				res->nh_sel =3D nhsel;
> > -
> > spin_unlock_bh(&fib_multipath_lock);
> > -				return;
> > -			}
> > -		}
> > +		res->nh_sel =3D nhsel;
> > +		return;
> >   	} endfor_nexthops(fi);
> >
> >   	/* Race condition: route has just become dead. */
> >   	res->nh_sel =3D 0;
> > -	spin_unlock_bh(&fib_multipath_lock);
> >   }
> >   #endif
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 5f4a556..41d977c 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -1646,6 +1646,25 @@ out:
> >   	return err;
> >   }
> >
> > +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > +
> > +static int ip_multipath_hash_skb(void *ctx)
> > +{
> > +	const struct sk_buff *skb =3D (struct sk_buff *)ctx;
> > +	const struct iphdr *iph =3D ip_hdr(skb);
> > +
> > +	return jhash_2words(iph->saddr, iph->daddr,
> > fib_multipath_secret); +}
> > +
> > +static int ip_multipath_hash_fl4(void *ctx)
> > +{
> > +	const struct flowi4 *fl4 =3D (const struct flowi4 *)ctx;
> > +
> > +	return jhash_2words(fl4->saddr, fl4->daddr,
> > fib_multipath_secret); +}
> > +
> > +#endif /* CONFIG_IP_ROUTE_MULTIPATH */
> > +
> >   static int ip_mkroute_input(struct sk_buff *skb,
> >   			    struct fib_result *res,
> >   			    const struct flowi4 *fl4,
> > @@ -1654,7 +1673,7 @@ static int ip_mkroute_input(struct sk_buff
> > *skb, {
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> >   	if (res->fi && res->fi->fib_nhs > 1)
> > -		fib_select_multipath(res);
> > +		fib_select_multipath(res, ip_multipath_hash_skb,
> > skb); #endif
> >
> >   	/* create a routing cache entry */
> > @@ -2200,7 +2219,7 @@ struct rtable *__ip_route_output_key(struct
> > net *net, struct flowi4 *fl4)
> >
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> >   	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0)
> > -		fib_select_multipath(&res);
> > +		fib_select_multipath(&res, ip_multipath_hash_fl4,
> > fl4); else
> >   #endif
> >   	if (!res.prefixlen &&
> >
>=20
> If you are using the hash right at the start of the function anyway
> why not just call jhash_2words first, then pass the resultant hash to=
=20
> fib_select_multipath instead of passing the function pointer and the=20
> void pointer.  You can probably save yourself quite a few cycles this
> way.

Good point! A quick proof-of-concept showed I saved 17 cycles (from 97
to 80 cycles/packet).

Thanks

>=20
> - Alex
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

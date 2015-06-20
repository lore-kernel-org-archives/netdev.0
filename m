From: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] ipv4: Lock-less per-packet multipath
Date: Sat, 20 Jun 2015 20:42:57 +0200
Message-ID: <20150620204257.52552865@tyr>
References: <1434571686-5149-1-git-send-email-pch@ordbogen.com>
 <1434571686-5149-2-git-send-email-pch@ordbogen.com>
 <55831F0D.3040703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55831F0D.3040703-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Jun 2015 12:42:05 -0700
Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On 06/17/2015 01:08 PM, Peter N=C3=B8rlund wrote:
> > The current multipath attempted to be quasi random, but in most
> > cases it behaved just like a round robin balancing. This patch
> > refactors the algorithm to be exactly that and in doing so, avoids
> > the spin lock.
> >
> > The new design paves the way for hash-based multipath, replacing th=
e
> > modulo with thresholds, minimizing disruption in case of failing
> > paths or route replacements.
> >
> > Signed-off-by: Peter N=C3=B8rlund <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
> > ---
> >   include/net/ip_fib.h     |   6 +--
> >   net/ipv4/Kconfig         |   1 +
> >   net/ipv4/fib_semantics.c | 116
> > ++++++++++++++++++++++++++--------------------- 3 files changed, 68
> > insertions(+), 55 deletions(-)
> >
> > diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> > index 54271ed..4be4f25 100644
> > --- a/include/net/ip_fib.h
> > +++ b/include/net/ip_fib.h
> > @@ -76,8 +76,8 @@ struct fib_nh {
> >   	unsigned int		nh_flags;
> >   	unsigned char		nh_scope;
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> > -	int			nh_weight;
> > -	int			nh_power;
> > +	int			nh_mp_weight;
> > +	atomic_t		nh_mp_upper_bound;
> >   #endif
> >   #ifdef CONFIG_IP_ROUTE_CLASSID
> >   	__u32			nh_tclassid;
> > @@ -115,7 +115,7 @@ struct fib_info {
> >   #define fib_advmss fib_metrics[RTAX_ADVMSS-1]
> >   	int			fib_nhs;
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> > -	int			fib_power;
> > +	int			fib_mp_weight;
> >   #endif
> >   	struct rcu_head		rcu;
> >   	struct fib_nh		fib_nh[0];
>=20
> I could do without some of this renaming.  For example you could=20
> probably not bother with adding the _mp piece to the name.  That way
> we don't have to track all the nh_weight -> nh_mp_weight changes.
> Also you could probably just use the name fib_weight since not
> including the _mp was already the convention for the multipath
> portions of the structure anyway.
>=20
> This isn't really improving readability at all so I would say don't=20
> bother renaming it.
>=20

Good point. I'll skip the renaming.

> > diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> > index d83071d..cb91f67 100644
> > --- a/net/ipv4/Kconfig
> > +++ b/net/ipv4/Kconfig
> > @@ -81,6 +81,7 @@ config IP_MULTIPLE_TABLES
> >   config IP_ROUTE_MULTIPATH
> >   	bool "IP: equal cost multipath"
> >   	depends on IP_ADVANCED_ROUTER
> > +	select BITREVERSE
> >   	help
> >   	  Normally, the routing tables specify a single action to
> > be taken in a deterministic manner for a given packet. If you say Y
> > here diff --git a/net/ipv4/fib_semantics.c
> > b/net/ipv4/fib_semantics.c index 28ec3c1..8c8df80 100644
> > --- a/net/ipv4/fib_semantics.c
> > +++ b/net/ipv4/fib_semantics.c
> > @@ -15,6 +15,7 @@
> >
> >   #include <asm/uaccess.h>
> >   #include <linux/bitops.h>
> > +#include <linux/bitrev.h>
> >   #include <linux/types.h>
> >   #include <linux/kernel.h>
> >   #include <linux/jiffies.h>
> > @@ -57,7 +58,7 @@ static struct hlist_head
> > fib_info_devhash[DEVINDEX_HASHSIZE];
> >
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> >
> > -static DEFINE_SPINLOCK(fib_multipath_lock);
> > +static DEFINE_PER_CPU(u8, fib_mp_rr_counter);
> >
> >   #define for_nexthops(fi)
> > {						\ int nhsel; const
> > struct fib_nh *nh;				\ @@ -261,7
> > +262,7 @@ static inline int nh_comp(const struct fib_info *fi,
> > const struct fib_info *ofi) nh->nh_gw  !=3D onh->nh_gw ||
> > nh->nh_scope !=3D onh->nh_scope || #ifdef CONFIG_IP_ROUTE_MULTIPATH
> > -		    nh->nh_weight !=3D onh->nh_weight ||
> > +		    nh->nh_mp_weight !=3D onh->nh_mp_weight ||
> >   #endif
> >   #ifdef CONFIG_IP_ROUTE_CLASSID
> >   		    nh->nh_tclassid !=3D onh->nh_tclassid ||
> > @@ -449,6 +450,43 @@ static int fib_count_nexthops(struct rtnexthop
> > *rtnh, int remaining) return remaining > 0 ? 0 : nhs;
> >   }
> >
>=20
> This is a good example.  If we don't do the rename we don't have to=20
> review changes like the one above which just add extra overhead to
> the patch.
>=20

Right.

> > +static void fib_rebalance(struct fib_info *fi)
> > +{
> > +	int factor;
> > +	int total;
> > +	int w;
> > +
> > +	if (fi->fib_nhs < 2)
> > +		return;
> > +
> > +	total =3D 0;
> > +	for_nexthops(fi) {
> > +		if (!(nh->nh_flags & RTNH_F_DEAD))
> > +			total +=3D nh->nh_mp_weight;
> > +	} endfor_nexthops(fi);
> > +
> > +	if (likely(total !=3D 0)) {
> > +		factor =3D DIV_ROUND_UP(total, 8388608);
> > +		total /=3D factor;
> > +	} else {
> > +		factor =3D 1;
> > +	}
> > +
>=20
> So where does the 8388608 value come from?  Is it just here to help=20
> restrict the upper_bound to a u8 value?
>=20

Yes. Although I think it is rare for the weight to be that large, the
API supports it, so I'd better make sure nothing weird happens. Or is
it too hypothetical? Today, if one were to add two paths, each with a
weight above 2^30, the total weight would overflow and become negative.
fib_select_multipath would then think the route is dead and always
select the first path.

> > +	w =3D 0;
> > +	change_nexthops(fi) {
> > +		int upper_bound;
> > +
> > +		if (nexthop_nh->nh_flags & RTNH_F_DEAD) {
> > +			upper_bound =3D -1;
> > +		} else {
> > +			w +=3D nexthop_nh->nh_mp_weight / factor;
> > +			upper_bound =3D DIV_ROUND_CLOSEST(256 * w,
> > total);
> > +		}
>=20
> This is doing some confusing stuff.  I assume the whole point is to
> get the value to convert the upper_bound into a u8 value based on the
> weight where you end with 256 as the last value, do I have that right=
?
>=20

Yes - and -1 is used to ensure that dead paths are never selected.

> I'm not really sure that is the best way to go from a code standpoint=
=20
> since fib_nhs is an int which technically means we could support more=
=20
> than 256 next hops for a given route.
>=20

It is true that fib_nhs is an int, but nh_sel is an unsigned char. So
although you could technically have more than 256 paths, fib_result
would have to be modified to actually support more paths.

> Also I assume that it is safe to divide by total because the
> assumption is that if one or more routes are not dead then total has
> a non-zero value, do I have that right?  If so what is the point of
> setting the factor to 1 above, unless you are just hacking around a
> divide by 0 error.
>=20

You are right, it is superfluous. If all paths are dead, we never
actually use the factor for anything.

> Maybe what you should do above is simply return if total =3D=3D 0 sin=
ce
> it doesn't look like you can safely update anything otherwise.
>=20
> > +
> > +		atomic_set(&nexthop_nh->nh_mp_upper_bound,
> > upper_bound);
> > +	} endfor_nexthops(fi);
> > +}
> > +
> >   static int fib_get_nhs(struct fib_info *fi, struct rtnexthop
> > *rtnh, int remaining, struct fib_config *cfg)
> >   {
> > @@ -461,7 +499,7 @@ static int fib_get_nhs(struct fib_info *fi,
> > struct rtnexthop *rtnh, nexthop_nh->nh_flags =3D
> >   			(cfg->fc_flags & ~0xFF) |
> > rtnh->rtnh_flags; nexthop_nh->nh_oif =3D rtnh->rtnh_ifindex;
> > -		nexthop_nh->nh_weight =3D rtnh->rtnh_hops + 1;
> > +		nexthop_nh->nh_mp_weight =3D rtnh->rtnh_hops + 1;
> >
> >   		attrlen =3D rtnh_attrlen(rtnh);
> >   		if (attrlen > 0) {
> > @@ -884,7 +922,7 @@ struct fib_info *fib_create_info(struct
> > fib_config *cfg) fi->fib_net->ipv4.fib_num_tclassid_users++;
> >   #endif
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> > -		nh->nh_weight =3D 1;
> > +		nh->nh_mp_weight =3D 1;
> >   #endif
> >   	}
> >
>=20
> More unnecessary rename noise.

Got it.

>=20
> > @@ -936,8 +974,15 @@ struct fib_info *fib_create_info(struct
> > fib_config *cfg)
> >
> >   	change_nexthops(fi) {
> >   		fib_info_update_nh_saddr(net, nexthop_nh);
> > +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > +		fi->fib_mp_weight +=3D nexthop_nh->nh_mp_weight;
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
> > @@ -1050,7 +1095,7 @@ int fib_dump_info(struct sk_buff *skb, u32
> > portid, u32 seq, int event, goto nla_put_failure;
> >
> >   			rtnh->rtnh_flags =3D nh->nh_flags & 0xFF;
> > -			rtnh->rtnh_hops =3D nh->nh_weight - 1;
> > +			rtnh->rtnh_hops =3D nh->nh_mp_weight - 1;
> >   			rtnh->rtnh_ifindex =3D nh->nh_oif;
> >
> >   			if (nh->nh_gw &&
> > @@ -1130,12 +1175,6 @@ int fib_sync_down_dev(struct net_device
> > *dev, int force) else if (nexthop_nh->nh_dev =3D=3D dev &&
> >   				 nexthop_nh->nh_scope !=3D scope) {
> >   				nexthop_nh->nh_flags |=3D
> > RTNH_F_DEAD; -#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > -				spin_lock_bh(&fib_multipath_lock);
> > -				fi->fib_power -=3D
> > nexthop_nh->nh_power;
> > -				nexthop_nh->nh_power =3D 0;
> > -
> > spin_unlock_bh(&fib_multipath_lock); -#endif
> >   				dead++;
> >   			}
> >   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> > @@ -1149,6 +1188,10 @@ int fib_sync_down_dev(struct net_device
> > *dev, int force) fi->fib_flags |=3D RTNH_F_DEAD;
> >   			ret++;
> >   		}
> > +
> > +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > +		fib_rebalance(fi);
> > +#endif
> >   	}
> >
> >   	return ret;
> > @@ -1254,16 +1297,15 @@ int fib_sync_up(struct net_device *dev)
> >   			    !__in_dev_get_rtnl(dev))
> >   				continue;
> >   			alive++;
> > -			spin_lock_bh(&fib_multipath_lock);
> > -			nexthop_nh->nh_power =3D 0;
> >   			nexthop_nh->nh_flags &=3D ~RTNH_F_DEAD;
> > -			spin_unlock_bh(&fib_multipath_lock);
> >   		} endfor_nexthops(fi)
> >
> >   		if (alive > 0) {
> >   			fi->fib_flags &=3D ~RTNH_F_DEAD;
> >   			ret++;
> >   		}
> > +
> > +		fib_rebalance(fi);
> >   	}
> >
> >   	return ret;
> > @@ -1276,49 +1318,19 @@ int fib_sync_up(struct net_device *dev)
> >   void fib_select_multipath(struct fib_result *res)
> >   {
> >   	struct fib_info *fi =3D res->fi;
> > -	int w;
> > -
> > -	spin_lock_bh(&fib_multipath_lock);
> > -	if (fi->fib_power <=3D 0) {
> > -		int power =3D 0;
> > -		change_nexthops(fi) {
> > -			if (!(nexthop_nh->nh_flags & RTNH_F_DEAD))
> > {
> > -				power +=3D nexthop_nh->nh_weight;
> > -				nexthop_nh->nh_power =3D
> > nexthop_nh->nh_weight;
> > -			}
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
> > +	u8 w;
> >
> > +	w =3D bitrev8(this_cpu_inc_return(fib_mp_rr_counter));
> >
> > -	/* w should be random number [0..fi->fib_power-1],
> > -	 * it is pretty bad approximation.
> > -	 */
> > -
> > -	w =3D jiffies % fi->fib_power;
> > +	for_nexthops(fi) {
> > +		if (w >=3D atomic_read(&nh->nh_mp_upper_bound))
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
> > -	/* Race condition: route has just become dead. */
> > +	/* Race condition: route has just become dead */
> >   	res->nh_sel =3D 0;
> > -	spin_unlock_bh(&fib_multipath_lock);
> >   }
> >   #endif
> >
>=20
> Instead of doing bitrev8 why not just hash jiffies since that is=20
> essentially what you are doing with this counter anyway.  You could=20
> probably even look at converting from a u8 to something like a u32
> which would give you a more pseudo random distribution.

The old algorithm tried to be kinda random by using jiffies, but since
jiffies has a relatively low resolution (at best 1kHz), at lot of
packets in a row would get the same jiffies value. The code did try to
adhere to the weight ratios and as a consequence it really worked like
round robin (except at every tick when the jiffies variable would
increment and offset the round robin slightly).

Considering that, I thought I'd avoid any false pretenses and just do
round robin. But since the new algorithm relies on thresholds and not
modulo, the most significant bits are the ones that need to flip at
every packet. So by reversing the bit order, I get exactly that. At a
slow packet rate this is somewhat costly as the bitrev8 lookup table
must be fetched from L3 cache or even memory, but as the packet rate
increase, the likelihood of it being in L2 or L1 cache increases and
cost go down.

Regarding moving from u8 to larger integers, I chose 8-bit resolution
since hashing L3 and L4 headers with XOR into a single byte actually
produced fairly good results with 8 bits, while switching to 16 bits
was terrible. Considering the purpose of the round robin counter here,
the primary advantage of switching to higher resolution would be to
better support a total weight above 255.

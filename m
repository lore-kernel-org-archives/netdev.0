From: YOSHIFUJI Hideaki <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Subject: Re: [RFC 08/12] ipv6: introduce neighbour discovery ops
Date: Wed, 25 May 2016 14:33:09 +0900
Message-ID: <57453915.6040903@miraclelinux.com>
References: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
 <1464031328-17524-9-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org,
	mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464031328-17524-9-git-send-email-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Alexander Aring wrote:
> This patch introduces neighbour discovery ops callback structure. The
> idea is to separate the handling for 6LoWPAN into the 6lowpan module.
> 
> These callback offers 6lowpan different handling, such as 802.15.4 short
> address handling or RFC6775 (Neighbor Discovery Optimization for IPv6
> over 6LoWPANs).
> 
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
> Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
>  include/linux/netdevice.h |   5 ++
>  include/net/ndisc.h       | 176 +++++++++++++++++++++++++++++++++++++++++++++-
>  net/ipv6/addrconf.c       |   9 ++-
>  net/ipv6/ndisc.c          | 119 +++++++++++++++++++++----------
>  net/ipv6/route.c          |  14 ++--
>  5 files changed, 275 insertions(+), 48 deletions(-)
> 

> @@ -205,6 +376,9 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target);
>  int ndisc_mc_map(const struct in6_addr *addr, char *buf, struct net_device *dev,
>  		 int dir);
>  
> +void ndisc_neigh_update(const struct net_device *dev, struct neighbour *neigh,
> +			const u8 *lladdr, u8 new, u32 flags, u8 icmp6_type,
> +			struct ndisc_options *ndopts);
>  

I prefer ndisc_update().


>  /*
>   *	IGMP
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 393cdbf..4506cac 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2531,7 +2531,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>  
>  	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
>  		struct in6_addr addr;
> -		bool tokenized = false;
> +		bool tokenized = false, dev_addr_generated = false;
>  
>  		if (pinfo->prefix_len == 64) {
>  			memcpy(&addr, &pinfo->prefix, 8);
> @@ -2551,6 +2551,8 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>  				   ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
>  				in6_dev_put(in6_dev);
>  				return;
> +			} else {
> +				dev_addr_generated = true;
>  			}
>  			goto ok;
>  		}
> @@ -2564,6 +2566,11 @@ ok:
>  					     addr_type, addr_flags, sllao,
>  					     tokenized, valid_lft,
>  					     prefered_lft);
> +		ndisc_ops_prefix_rcv_add_addr(net, dev, pinfo, in6_dev, &addr,
> +					      addr_type, addr_flags, sllao,
> +					      tokenized, valid_lft,
> +					      prefered_lft,
> +					      dev_addr_generated);
>  	}
>  	inet6_prefix_notify(RTM_NEWPREFIX, in6_dev, pinfo);
>  	in6_dev_put(in6_dev);
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index d794d64..99fd53c 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -191,24 +191,28 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
>  	return cur <= end && cur->nd_opt_type == type ? cur : NULL;
>  }
>  
> -static inline int ndisc_is_useropt(struct nd_opt_hdr *opt)
> +static inline int ndisc_is_useropt(const struct net_device *dev,
> +				   struct nd_opt_hdr *opt)
>  {
>  	return opt->nd_opt_type == ND_OPT_RDNSS ||
> -		opt->nd_opt_type == ND_OPT_DNSSL;
> +		opt->nd_opt_type == ND_OPT_DNSSL ||
> +		ndisc_ops_is_useropt(dev, opt->nd_opt_type);
>  }
>  
> -static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
> +static struct nd_opt_hdr *ndisc_next_useropt(const struct net_device *dev,
> +					     struct nd_opt_hdr *cur,
>  					     struct nd_opt_hdr *end)
>  {
>  	if (!cur || !end || cur >= end)
>  		return NULL;
>  	do {
>  		cur = ((void *)cur) + (cur->nd_opt_len << 3);
> -	} while (cur < end && !ndisc_is_useropt(cur));
> -	return cur <= end && ndisc_is_useropt(cur) ? cur : NULL;
> +	} while (cur < end && !ndisc_is_useropt(dev, cur));
> +	return cur <= end && ndisc_is_useropt(dev, cur) ? cur : NULL;
>  }
>  
> -struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
> +struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
> +					  u8 *opt, int opt_len,
>  					  struct ndisc_options *ndopts)
>  {
>  	struct nd_opt_hdr *nd_opt = (struct nd_opt_hdr *)opt;
> @@ -223,6 +227,8 @@ struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
>  		l = nd_opt->nd_opt_len << 3;
>  		if (opt_len < l || l == 0)
>  			return NULL;
> +		if (ndisc_ops_parse_opts(dev, nd_opt, ndopts))
> +			goto next_opt;
>  		switch (nd_opt->nd_opt_type) {
>  		case ND_OPT_SOURCE_LL_ADDR:
>  		case ND_OPT_TARGET_LL_ADDR:
> @@ -249,7 +255,7 @@ struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
>  			break;
>  #endif
>  		default:
> -			if (ndisc_is_useropt(nd_opt)) {
> +			if (ndisc_is_useropt(dev, nd_opt)) {
>  				ndopts->nd_useropts_end = nd_opt;
>  				if (!ndopts->nd_useropts)
>  					ndopts->nd_useropts = nd_opt;
> @@ -266,6 +272,7 @@ struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
>  					  nd_opt->nd_opt_len);
>  			}
>  		}
> +next_opt:
>  		opt_len -= l;
>  		nd_opt = ((void *)nd_opt) + l;
>  	}
> @@ -514,8 +521,11 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
>  
>  	if (!dev->addr_len)
>  		inc_opt = 0;
> -	if (inc_opt)
> +	if (inc_opt) {
>  		optlen += ndisc_dev_opt_addr_space(dev);
> +		optlen += ndisc_ops_opt_space(dev,
> +					      NDISC_NEIGHBOUR_ADVERTISEMENT);
> +	}
>  

I think we could call per-device space handler inside
ndisc_dev_opt_addr_space(dev) (or ndisc_opt_addr_space,
in my opinion as I mentioned in 04/12) here by having
extra arugment for it.


>  	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
>  	if (!skb)
> @@ -532,8 +542,10 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
>  		.target = *solicited_addr,
>  	};
>  
> -	if (inc_opt)
> +	if (inc_opt) {
>  		ndisc_dev_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR, dev);
> +		ndisc_ops_fill_opts(dev, skb, NDISC_NEIGHBOUR_ADVERTISEMENT);
> +	}
>  

likewise.  And ndisc_ops_fill_addr_option, maybe?

>  
>  	ndisc_send_skb(skb, daddr, src_addr);
> @@ -578,8 +590,11 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
>  
>  	if (ipv6_addr_any(saddr))
>  		inc_opt = false;
> -	if (inc_opt)
> +	if (inc_opt) {
>  		optlen += ndisc_dev_opt_addr_space(dev);
> +		optlen += ndisc_ops_opt_space(dev,
> +					      NDISC_NEIGHBOUR_SOLICITATION);
> +	}
>  
>  	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
>  	if (!skb)
> @@ -593,8 +608,10 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
>  		.target = *solicit,
>  	};
>  
> -	if (inc_opt)
> +	if (inc_opt) {
>  		ndisc_dev_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR, dev);
> +		ndisc_ops_fill_opts(dev, skb, NDISC_NEIGHBOUR_SOLICITATION);
> +	}
>  
>  	ndisc_send_skb(skb, daddr, saddr);
>  }
> @@ -629,8 +646,10 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
>  		}
>  	}
>  #endif
> -	if (send_sllao)
> +	if (send_sllao) {
>  		optlen += ndisc_dev_opt_addr_space(dev);
> +		optlen += ndisc_ops_opt_space(dev, NDISC_ROUTER_SOLICITATION);
> +	}
>  
>  	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
>  	if (!skb)
> @@ -643,8 +662,10 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
>  		},
>  	};
>  
> -	if (send_sllao)
> +	if (send_sllao) {
>  		ndisc_dev_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR, dev);
> +		ndisc_ops_fill_opts(dev, skb, NDISC_ROUTER_SOLICITATION);
> +	}
>  
>  	ndisc_send_skb(skb, daddr, saddr);
>  }
> @@ -705,6 +726,15 @@ static int pndisc_is_router(const void *pkey,
>  	return ret;
>  }
>  
> +void ndisc_neigh_update(const struct net_device *dev, struct neighbour *neigh,
> +			const u8 *lladdr, u8 new, u32 flags, u8 icmp6_type,
> +			struct ndisc_options *ndopts)
> +{
> +	neigh_update(neigh, lladdr, new, flags);
> +	/* report ndisc ops about neighbour update */
> +	ndisc_ops_neigh_update(dev, neigh, flags, icmp6_type, ndopts);
> +}
> +
>  static void ndisc_recv_ns(struct sk_buff *skb)
>  {
>  	struct nd_msg *msg = (struct nd_msg *)skb_transport_header(skb);
> @@ -741,7 +771,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  		return;
>  	}
>  
> -	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
> +	if (!ndisc_parse_options(dev, msg->opt, ndoptlen, &ndopts)) {
>  		ND_PRINTK(2, warn, "NS: invalid ND options\n");
>  		return;
>  	}
> @@ -860,9 +890,10 @@ have_ifp:
>  	neigh = __neigh_lookup(&nd_tbl, saddr, dev,
>  			       !inc || lladdr || !dev->addr_len);
>  	if (neigh)
> -		neigh_update(neigh, lladdr, NUD_STALE,
> -			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
> -			     NEIGH_UPDATE_F_OVERRIDE);
> +		ndisc_neigh_update(dev, neigh, lladdr, NUD_STALE,
> +				   NEIGH_UPDATE_F_WEAK_OVERRIDE|
> +				   NEIGH_UPDATE_F_OVERRIDE,
> +				   NDISC_NEIGHBOUR_SOLICITATION, &ndopts);
>  	if (neigh || !dev->header_ops) {
>  		ndisc_send_na(dev, saddr, &msg->target, !!is_router,
>  			      true, (ifp != NULL && inc), inc);
> @@ -915,7 +946,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  	    idev->cnf.drop_unsolicited_na)
>  		return;
>  
> -	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
> +	if (!ndisc_parse_options(dev, msg->opt, ndoptlen, &ndopts)) {
>  		ND_PRINTK(2, warn, "NS: invalid ND option\n");
>  		return;
>  	}
> @@ -972,12 +1003,13 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  			goto out;
>  		}
>  
> -		neigh_update(neigh, lladdr,
> -			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
> -			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
> -			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0)|
> -			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
> -			     (msg->icmph.icmp6_router ? NEIGH_UPDATE_F_ISROUTER : 0));
> +		ndisc_neigh_update(dev, neigh, lladdr,
> +				   msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
> +				   NEIGH_UPDATE_F_WEAK_OVERRIDE|
> +				   (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0)|
> +				   NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
> +				   (msg->icmph.icmp6_router ? NEIGH_UPDATE_F_ISROUTER : 0),
> +				   NDISC_NEIGHBOUR_ADVERTISEMENT, &ndopts);
>  
>  		if ((old_flags & ~neigh->flags) & NTF_ROUTER) {
>  			/*
> @@ -1022,7 +1054,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
>  		goto out;
>  
>  	/* Parse ND options */
> -	if (!ndisc_parse_options(rs_msg->opt, ndoptlen, &ndopts)) {
> +	if (!ndisc_parse_options(skb->dev, rs_msg->opt, ndoptlen, &ndopts)) {
>  		ND_PRINTK(2, notice, "NS: invalid ND option, ignored\n");
>  		goto out;
>  	}
> @@ -1036,10 +1068,11 @@ static void ndisc_recv_rs(struct sk_buff *skb)
>  
>  	neigh = __neigh_lookup(&nd_tbl, saddr, skb->dev, 1);
>  	if (neigh) {
> -		neigh_update(neigh, lladdr, NUD_STALE,
> -			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
> -			     NEIGH_UPDATE_F_OVERRIDE|
> -			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER);
> +		ndisc_neigh_update(skb->dev, neigh, lladdr, NUD_STALE,
> +				   NEIGH_UPDATE_F_WEAK_OVERRIDE|
> +				   NEIGH_UPDATE_F_OVERRIDE|
> +				   NEIGH_UPDATE_F_OVERRIDE_ISROUTER,
> +				   NDISC_ROUTER_SOLICITATION, &ndopts);
>  		neigh_release(neigh);
>  	}
>  out:
> @@ -1140,7 +1173,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>  		return;
>  	}
>  
> -	if (!ndisc_parse_options(opt, optlen, &ndopts)) {
> +	if (!ndisc_parse_options(skb->dev, opt, optlen, &ndopts)) {
>  		ND_PRINTK(2, warn, "RA: invalid ND options\n");
>  		return;
>  	}
> @@ -1334,11 +1367,12 @@ skip_linkparms:
>  				goto out;
>  			}
>  		}
> -		neigh_update(neigh, lladdr, NUD_STALE,
> -			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
> -			     NEIGH_UPDATE_F_OVERRIDE|
> -			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
> -			     NEIGH_UPDATE_F_ISROUTER);
> +		ndisc_neigh_update(skb->dev, neigh, lladdr, NUD_STALE,
> +				   NEIGH_UPDATE_F_WEAK_OVERRIDE|
> +				   NEIGH_UPDATE_F_OVERRIDE|
> +				   NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
> +				   NEIGH_UPDATE_F_ISROUTER,
> +				   NDISC_ROUTER_ADVERTISEMENT, &ndopts);
>  	}
>  
>  	if (!ipv6_accept_ra(in6_dev)) {
> @@ -1426,7 +1460,8 @@ skip_routeinfo:
>  		struct nd_opt_hdr *p;
>  		for (p = ndopts.nd_useropts;
>  		     p;
> -		     p = ndisc_next_useropt(p, ndopts.nd_useropts_end)) {
> +		     p = ndisc_next_useropt(skb->dev, p,
> +					    ndopts.nd_useropts_end)) {
>  			ndisc_ra_useropt(skb, p);
>  		}
>  	}
> @@ -1464,7 +1499,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
>  		return;
>  	}
>  
> -	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts))
> +	if (!ndisc_parse_options(skb->dev, msg->opt, ndoptlen, &ndopts))
>  		return;
>  
>  	if (!ndopts.nd_opts_rh) {
> @@ -1509,7 +1544,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
>  	struct dst_entry *dst;
>  	struct flowi6 fl6;
>  	int rd_len;
> -	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
> +	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL,
> +	   ops_data_buf[NDISC_OPS_REDIRECT_DATA_SPACE], *ops_data = NULL;
>  	int oif = l3mdev_fib_oif(dev);
>  	bool ret;
>  
> @@ -1569,6 +1605,9 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
>  			read_unlock_bh(&neigh->lock);
>  			ha = ha_buf;
>  			optlen += ndisc_dev_opt_addr_space(dev);
> +			optlen += ndisc_ops_redirect_opt_space(dev, neigh,
> +							       ops_data_buf,
> +							       &ops_data);
>  		} else
>  			read_unlock_bh(&neigh->lock);
>  
> @@ -1598,10 +1637,12 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
>  	 *	include target_address option
>  	 */
>  
> -	if (ha)
> +	if (ha) {
>  		ndisc_fill_addr_option(buff, ND_OPT_TARGET_LL_ADDR, ha,
>  				       dev->addr_len,
>  				       ndisc_addr_option_pad(dev->type));
> +		ndisc_ops_redirect_fill_addr_option(dev, buff, ops_data);
> +	}
>  
>  	/*
>  	 *	build redirect option and copy skb over to the new packet.
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index d662cd8..0800a776 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2200,7 +2200,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
>  	 *	first-hop router for the specified ICMP Destination Address.
>  	 */
>  
> -	if (!ndisc_parse_options(msg->opt, optlen, &ndopts)) {
> +	if (!ndisc_parse_options(skb->dev, msg->opt, optlen, &ndopts)) {
>  		net_dbg_ratelimited("rt6_redirect: invalid ND options\n");
>  		return;
>  	}
> @@ -2235,12 +2235,12 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
>  	 *	We have finally decided to accept it.
>  	 */
>  
> -	neigh_update(neigh, lladdr, NUD_STALE,
> -		     NEIGH_UPDATE_F_WEAK_OVERRIDE|
> -		     NEIGH_UPDATE_F_OVERRIDE|
> -		     (on_link ? 0 : (NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
> -				     NEIGH_UPDATE_F_ISROUTER))
> -		     );
> +	ndisc_neigh_update(skb->dev, neigh, lladdr, NUD_STALE,
> +			   NEIGH_UPDATE_F_WEAK_OVERRIDE|
> +			   NEIGH_UPDATE_F_OVERRIDE|
> +			   (on_link ? 0 : (NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
> +					   NEIGH_UPDATE_F_ISROUTER)),
> +			   NDISC_REDIRECT, &ndopts);
>  
>  	nrt = ip6_rt_cache_alloc(rt, &msg->dest, NULL);
>  	if (!nrt)
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Technical Division, MIRACLE LINUX CORPORATION

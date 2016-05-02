From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv2 bluetooth-next 07/10] ipv6: introduce neighbour
 discovery ops
Date: Mon, 2 May 2016 21:36:13 +0200
Message-ID: <fbd4c25c-2673-2848-c636-a5d21a6890d7@stressinduktion.org>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-8-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:38358 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754654AbcEBTgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 15:36:20 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id C55A42080A
	for <netdev@vger.kernel.org>; Mon,  2 May 2016 15:36:19 -0400 (EDT)
In-Reply-To: <1461140382-4784-8-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.04.2016 10:19, Alexander Aring wrote:
> This patch introduces neighbour discovery ops callback structure. The
> structure contains at first receive and transmit handling for NS/NA and
> userspace option field functionality.
> 
> These callback offers 6lowpan different handling, such as 802.15.4 short
> address handling or RFC6775 (Neighbor Discovery Optimization for IPv6 over
> 6LoWPANs).
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>
> ---
>  include/linux/netdevice.h |  3 ++
>  include/net/ndisc.h       | 96 +++++++++++++++++++++++++++++++++++++++++++----
>  net/ipv6/addrconf.c       |  1 +
>  net/ipv6/ndisc.c          | 71 ++++++++++++++++++++++++-----------
>  net/ipv6/route.c          |  2 +-
>  5 files changed, 144 insertions(+), 29 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0052c42..bc60033 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1677,6 +1677,9 @@ struct net_device {
>  #ifdef CONFIG_NET_L3_MASTER_DEV
>  	const struct l3mdev_ops	*l3mdev_ops;
>  #endif
> +#if IS_ENABLED(CONFIG_IPV6)
> +	const struct ndisc_ops *ndisc_ops;
> +#endif
>  
>  	const struct header_ops *header_ops;
>  
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index aac868e..14ed016 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -110,7 +110,8 @@ struct ndisc_options {
>  
>  #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
>  
> -struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
> +struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
> +					  u8 *opt, int opt_len,
>  					  struct ndisc_options *ndopts);
>  
>  /*
> @@ -173,6 +174,93 @@ static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, cons
>  	return n;
>  }
>  
> +static inline int __ip6_ndisc_is_useropt(struct nd_opt_hdr *opt)
> +{
> +	return opt->nd_opt_type == ND_OPT_RDNSS ||
> +		opt->nd_opt_type == ND_OPT_DNSSL;
> +}
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +struct ndisc_ops {
> +	int	(*is_useropt)(struct nd_opt_hdr *opt);
> +	void	(*send_na)(struct net_device *dev,
> +			   const struct in6_addr *daddr,
> +			   const struct in6_addr *solicited_addr,
> +			   bool router, bool solicited,
> +			   bool override, bool inc_opt);
> +	void	(*recv_na)(struct sk_buff *skb);
> +	void	(*send_ns)(struct net_device *dev,
> +			   const struct in6_addr *solicit,
> +			   const struct in6_addr *daddr,
> +			   const struct in6_addr *saddr);
> +	void	(*recv_ns)(struct sk_buff *skb);
> +};
> +
> +static inline int ndisc_is_useropt(const struct net_device *dev,
> +				   struct nd_opt_hdr *opt)
> +{
> +	if (likely(dev->ndisc_ops->is_useropt))
> +		return dev->ndisc_ops->is_useropt(opt);
> +	else
> +		return 0;
> +}
> +
> +static inline void ndisc_send_na(struct net_device *dev,
> +				 const struct in6_addr *daddr,
> +				 const struct in6_addr *solicited_addr,
> +				 bool router, bool solicited, bool override,
> +				 bool inc_opt)
> +{
> +	if (likely(dev->ndisc_ops->send_na))
> +		dev->ndisc_ops->send_na(dev, daddr, solicited_addr, router,
> +					solicited, override, inc_opt);
> +}
> +
> +static inline void ndisc_recv_na(struct sk_buff *skb)
> +{
> +	if (likely(skb->dev->ndisc_ops->recv_na))
> +		skb->dev->ndisc_ops->recv_na(skb);
> +}
> +
> +static inline void ndisc_send_ns(struct net_device *dev,
> +				 const struct in6_addr *solicit,
> +				 const struct in6_addr *daddr,
> +				 const struct in6_addr *saddr)
> +{
> +	if (likely(dev->ndisc_ops->send_ns))
> +		dev->ndisc_ops->send_ns(dev, solicit, daddr, saddr);
> +}
> +
> +static inline void ndisc_recv_ns(struct sk_buff *skb)
> +{
> +	if (likely(skb->dev->ndisc_ops->recv_ns))
> +		skb->dev->ndisc_ops->recv_ns(skb);
> +}
> +#else
> +static inline int ndisc_is_useropt(const struct net_device *dev,
> +				   struct nd_opt_hdr *opt)
> +{
> +	return 0;
> +}
> +
> +static inline void ndisc_send_na(struct net_device *dev,
> +				 const struct in6_addr *daddr,
> +				 const struct in6_addr *solicited_addr,
> +				 bool router, bool solicited, bool override,
> +				 bool inc_opt) { }
> +
> +static inline void ndisc_recv_na(struct sk_buff *skb) { }
> +
> +static inline void ndisc_send_ns(struct net_device *dev,
> +				 const struct in6_addr *solicit,
> +				 const struct in6_addr *daddr,
> +				 const struct in6_addr *saddr) { }
> +
> +static inline void ndisc_recv_ns(struct sk_buff *skb) { }
> +#endif

Do those empty functions actually make sense? I wonder a bit because
6lowpan strictly depends on ipv6 and they should never be called without
IPv6, no?

> +
> +void ip6_register_ndisc_ops(struct net_device *dev);
> +
>  int ndisc_init(void);
>  int ndisc_late_init(void);
>  
> @@ -181,14 +269,8 @@ void ndisc_cleanup(void);
>  
>  int ndisc_rcv(struct sk_buff *skb);
>  
> -void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
> -		   const struct in6_addr *daddr, const struct in6_addr *saddr);
> -
>  void ndisc_send_rs(struct net_device *dev,
>  		   const struct in6_addr *saddr, const struct in6_addr *daddr);
> -void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
> -		   const struct in6_addr *solicited_addr,
> -		   bool router, bool solicited, bool override, bool inc_opt);
>  
>  void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target);
>  
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 54e18c2..a2ef04b 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3266,6 +3266,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>  			idev = ipv6_add_dev(dev);
>  			if (IS_ERR(idev))
>  				return notifier_from_errno(PTR_ERR(idev));
> +			ip6_register_ndisc_ops(dev);

Is it possible to register the ndisc options before we make the device
visible to the stack? Maybe even as a pointer to ipv6_add_dev.

>  		}
>  		break;
>  
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 176c7c4..297080a 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -185,24 +185,25 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
>  	return cur <= end && cur->nd_opt_type == type ? cur : NULL;
>  }
>  
> -static inline int ndisc_is_useropt(struct nd_opt_hdr *opt)
> +static inline int ip6_ndisc_is_useropt(struct nd_opt_hdr *opt)
>  {
> -	return opt->nd_opt_type == ND_OPT_RDNSS ||
> -		opt->nd_opt_type == ND_OPT_DNSSL;
> +	return __ip6_ndisc_is_useropt(opt);
>  }

inline in C functions are not necessary.

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
> @@ -243,7 +244,7 @@ struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
>  			break;
>  #endif
>  		default:
> -			if (ndisc_is_useropt(nd_opt)) {
> +			if (ndisc_is_useropt(dev, nd_opt)) {
>  				ndopts->nd_useropts_end = nd_opt;
>  				if (!ndopts->nd_useropts)
>  					ndopts->nd_useropts = nd_opt;
> @@ -479,9 +480,11 @@ static void ndisc_send_skb(struct sk_buff *skb,
>  	rcu_read_unlock();
>  }
>  
> -void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
> -		   const struct in6_addr *solicited_addr,
> -		   bool router, bool solicited, bool override, bool inc_opt)
> +static void ip6_ndisc_send_na(struct net_device *dev,
> +			      const struct in6_addr *daddr,
> +			      const struct in6_addr *solicited_addr,
> +			      bool router, bool solicited, bool override,
> +			      bool inc_opt)
>  {
>  	struct sk_buff *skb;
>  	struct in6_addr tmpaddr;
> @@ -555,8 +558,10 @@ static void ndisc_send_unsol_na(struct net_device *dev)
>  	in6_dev_put(idev);
>  }
>  
> -void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
> -		   const struct in6_addr *daddr, const struct in6_addr *saddr)
> +static void ip6_ndisc_send_ns(struct net_device *dev,
> +			      const struct in6_addr *solicit,
> +			      const struct in6_addr *daddr,
> +			      const struct in6_addr *saddr)
>  {
>  	struct sk_buff *skb;
>  	struct in6_addr addr_buf;
> @@ -702,7 +707,7 @@ static int pndisc_is_router(const void *pkey,
>  	return ret;
>  }
>  
> -static void ndisc_recv_ns(struct sk_buff *skb)
> +static void ip6_ndisc_recv_ns(struct sk_buff *skb)
>  {
>  	struct nd_msg *msg = (struct nd_msg *)skb_transport_header(skb);
>  	const struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
> @@ -738,7 +743,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  		return;
>  	}
>  
> -	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
> +	if (!ndisc_parse_options(dev, msg->opt, ndoptlen, &ndopts)) {
>  		ND_PRINTK(2, warn, "NS: invalid ND options\n");
>  		return;
>  	}
> @@ -874,7 +879,7 @@ out:
>  		in6_dev_put(idev);
>  }
>  
> -static void ndisc_recv_na(struct sk_buff *skb)
> +static void ip6_ndisc_recv_na(struct sk_buff *skb)
>  {
>  	struct nd_msg *msg = (struct nd_msg *)skb_transport_header(skb);
>  	struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
> @@ -912,7 +917,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  	    idev->cnf.drop_unsolicited_na)
>  		return;
>  
> -	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
> +	if (!ndisc_parse_options(dev, msg->opt, ndoptlen, &ndopts)) {
>  		ND_PRINTK(2, warn, "NS: invalid ND option\n");
>  		return;
>  	}
> @@ -1019,7 +1024,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
>  		goto out;
>  
>  	/* Parse ND options */
> -	if (!ndisc_parse_options(rs_msg->opt, ndoptlen, &ndopts)) {
> +	if (!ndisc_parse_options(skb->dev, rs_msg->opt, ndoptlen, &ndopts)) {
>  		ND_PRINTK(2, notice, "NS: invalid ND option, ignored\n");
>  		goto out;
>  	}
> @@ -1137,7 +1142,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>  		return;
>  	}
>  
> -	if (!ndisc_parse_options(opt, optlen, &ndopts)) {
> +	if (!ndisc_parse_options(skb->dev, opt, optlen, &ndopts)) {
>  		ND_PRINTK(2, warn, "RA: invalid ND options\n");
>  		return;
>  	}
> @@ -1424,7 +1429,8 @@ skip_routeinfo:
>  		struct nd_opt_hdr *p;
>  		for (p = ndopts.nd_useropts;
>  		     p;
> -		     p = ndisc_next_useropt(p, ndopts.nd_useropts_end)) {
> +		     p = ndisc_next_useropt(skb->dev, p,
> +					    ndopts.nd_useropts_end)) {
>  			ndisc_ra_useropt(skb, p);
>  		}
>  	}
> @@ -1462,7 +1468,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
>  		return;
>  	}
>  
> -	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts))
> +	if (!ndisc_parse_options(skb->dev, msg->opt, ndoptlen, &ndopts))
>  		return;
>  
>  	if (!ndopts.nd_opts_rh) {
> @@ -1783,6 +1789,29 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
>  
>  #endif
>  
> +static const struct ndisc_ops ip6_ndisc_ops = {
> +	.is_useropt = ip6_ndisc_is_useropt,
> +	.send_na = ip6_ndisc_send_na,
> +	.recv_na = ip6_ndisc_recv_na,
> +	.send_ns = ip6_ndisc_send_ns,
> +	.recv_ns = ip6_ndisc_recv_ns,
> +};
> +
> +void ip6_register_ndisc_ops(struct net_device *dev)
> +{
> +	switch (dev->type) {
> +	default:
> +		if (dev->ndisc_ops) {
> +			ND_PRINTK(2, warn,
> +				  "%s: ndisc_ops already defined for interface type=%d\n",
> +				  __func__, dev->type);
> +		} else {
> +			dev->ndisc_ops = &ip6_ndisc_ops;
> +		}
> +		break;

I would be more stricht with validation:

if (!WARN_ON(dev->ndisc_ops))
	dev->ndisc_ops = &ip6_ndisc_ops;

> +	}
> +}
> +
>  static int __net_init ndisc_net_init(struct net *net)
>  {
>  	struct ipv6_pinfo *np;
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index cc180b3..5fa276d 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2149,7 +2149,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
>  	 *	first-hop router for the specified ICMP Destination Address.
>  	 */
>  
> -	if (!ndisc_parse_options(msg->opt, optlen, &ndopts)) {
> +	if (!ndisc_parse_options(skb->dev, msg->opt, optlen, &ndopts)) {
>  		net_dbg_ratelimited("rt6_redirect: invalid ND options\n");
>  		return;
>  	}
> 

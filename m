From: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [PATCHv2 bluetooth-next 09/10] 6lowpan: introduce 6lowpan-nd
Date: Wed, 4 May 2016 14:23:33 +0200
Message-ID: <5729E9C5.7070107@osg.samsung.com>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-10-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461140382-4784-10-git-send-email-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 20/04/16 10:19, Alexander Aring wrote:
> This patch introduce different 6lowpan handling for receive and transmit
> NS/NA messages for the ipv6 neighbour discovery. The first use-case is
> for supporting 802.15.4 short addresses inside the option fields and
> handling for RFC6775 6CO option field as userspace option.
>
> Future handling:
> Also add RS/RA(processing) for 802.15.4 short addresses and handle
> RFC6775, which requires more 6lowpan specific handling for ipv6 neighbour
> discovery implementation.
>
> Cc: David S. Miller<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Alexey Kuznetsov<kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
> Cc: James Morris<jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> Cc: Hideaki YOSHIFUJI<yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Cc: Patrick McHardy<kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Signed-off-by: Alexander Aring<aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
>   include/net/ndisc.h     |   1 +
>   net/6lowpan/6lowpan_i.h |   2 +
>   net/6lowpan/Makefile    |   2 +-
>   net/6lowpan/core.c      |   2 +
>   net/6lowpan/ndisc.c     | 633 ++++++++++++++++++++++++++++++++++++++++++++++++
>   net/ipv6/ndisc.c        |   3 +
>   6 files changed, 642 insertions(+), 1 deletion(-)
>   create mode 100644 net/6lowpan/ndisc.c
>
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 35a4396..e2ee83d 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -35,6 +35,7 @@ enum {
>   	ND_OPT_ROUTE_INFO = 24,		/* RFC4191 */
>   	ND_OPT_RDNSS = 25,		/* RFC5006 */
>   	ND_OPT_DNSSL = 31,		/* RFC6106 */
> +	ND_OPT_6CO = 34,		/* RFC6775 */
>   	__ND_OPT_MAX
>   };
>   
> diff --git a/net/6lowpan/6lowpan_i.h b/net/6lowpan/6lowpan_i.h
> index 97ecc27..8b01774 100644
> --- a/net/6lowpan/6lowpan_i.h
> +++ b/net/6lowpan/6lowpan_i.h
> @@ -12,6 +12,8 @@ static inline bool lowpan_is_ll(const struct net_device *dev,
>   	return lowpan_dev(dev)->lltype == lltype;
>   }
>   
> +void lowpan_register_ndisc_ops(struct net_device *dev);
> +
>   #ifdef CONFIG_6LOWPAN_DEBUGFS
>   int lowpan_dev_debugfs_init(struct net_device *dev);
>   void lowpan_dev_debugfs_exit(struct net_device *dev);
> diff --git a/net/6lowpan/Makefile b/net/6lowpan/Makefile
> index e44f3bf..12d131a 100644
> --- a/net/6lowpan/Makefile
> +++ b/net/6lowpan/Makefile
> @@ -1,6 +1,6 @@
>   obj-$(CONFIG_6LOWPAN) += 6lowpan.o
>   
> -6lowpan-y := core.o iphc.o nhc.o
> +6lowpan-y := core.o iphc.o nhc.o ndisc.o
>   6lowpan-$(CONFIG_6LOWPAN_DEBUGFS) += debugfs.o
>   
>   #rfc6282 nhcs
> diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
> index 824d1bc..e7a370e 100644
> --- a/net/6lowpan/core.c
> +++ b/net/6lowpan/core.c
> @@ -34,6 +34,8 @@ int lowpan_register_netdevice(struct net_device *dev,
>   	for (i = 0; i < LOWPAN_IPHC_CTX_TABLE_SIZE; i++)
>   		lowpan_dev(dev)->ctx.table[i].id = i;
>   
> +	lowpan_register_ndisc_ops(dev);
> +
>   	ret = register_netdevice(dev);
>   	if (ret < 0)
>   		return ret;
> diff --git a/net/6lowpan/ndisc.c b/net/6lowpan/ndisc.c
> new file mode 100644
> index 0000000..d088295
> --- /dev/null
> +++ b/net/6lowpan/ndisc.c
> @@ -0,0 +1,633 @@
> +/* This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +

Maybe add yourself as author for copyright and authorship here?

> +#include <net/6lowpan.h>
> +#include <net/addrconf.h>
> +#include <net/ip6_route.h>
> +#include <net/ndisc.h>
> +
> +#include "6lowpan_i.h"
> +
> +struct lowpan_ndisc_options {
> +	struct nd_opt_hdr *nd_opt_array[ND_OPT_TARGET_LL_ADDR + 1];
> +#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
> +	struct nd_opt_hdr *nd_802154_opt_array[ND_OPT_TARGET_LL_ADDR + 1];
> +#endif
> +};
> +

The additional one for 15.4 here is to support short and extended 
addresses at the same time?


> +#define nd_802154_opts_src_lladdr	nd_802154_opt_array[ND_OPT_SOURCE_LL_ADDR]
> +#define nd_802154_opts_tgt_lladdr	nd_802154_opt_array[ND_OPT_TARGET_LL_ADDR]
> +
> +#define NDISC_802154_EXTENDED_ADDR_LENGTH	2
> +#define NDISC_802154_SHORT_ADDR_LENGTH		1
> +
> +#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
> +static void lowpan_ndisc_802154_neigh_update(struct neighbour *n, void *priv,
> +					     bool override)
> +{
> +	struct lowpan_802154_neigh *neigh = lowpan_802154_neigh(neighbour_priv(n));
> +
> +	if (!override)
> +		return;
> +
> +	write_lock_bh(&n->lock);
> +	if (priv)
> +		ieee802154_be16_to_le16(&neigh->short_addr, priv);
> +	else
> +		neigh->short_addr = cpu_to_le16(IEEE802154_ADDR_SHORT_UNSPEC);
> +	write_unlock_bh(&n->lock);
> +}
> +
> +static inline int lowpan_ndisc_802154_short_addr_space(struct net_device *dev)
> +{
> +	struct wpan_dev *wpan_dev;
> +	int addr_space = 0;
> +
> +	if (lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154)) {
> +		wpan_dev = lowpan_802154_dev(dev)->wdev->ieee802154_ptr;
> +
> +		if (ieee802154_is_valid_src_short_addr(wpan_dev->short_addr))
> +			addr_space = ndisc_opt_addr_space(dev, IEEE802154_SHORT_ADDR_LEN);
> +	}
> +
> +	return addr_space;
> +}
> +
> +static inline void
> +lowpan_ndisc_802154_short_addr_option(struct net_device *dev,
> +				      struct sk_buff *skb, int type)
> +{
> +	struct wpan_dev *wpan_dev;
> +	__be16 short_addr;
> +
> +	if (lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154)) {
> +		wpan_dev = lowpan_802154_dev(dev)->wdev->ieee802154_ptr;
> +
> +		if (ieee802154_is_valid_src_short_addr(wpan_dev->short_addr)) {
> +			ieee802154_le16_to_be16(&short_addr,
> +						&wpan_dev->short_addr);
> +			ndisc_fill_addr_option(skb, type, &short_addr,
> +					       IEEE802154_SHORT_ADDR_LEN);
> +		}
> +	}
> +}
> +#else
> +static void
> +lowpan_ndisc_802154_neigh_update(struct neighbour *n, void *priv,
> +				 bool override) { }
> +
> +static inline void
> +lowpan_ndisc_802154_short_addr_option(struct net_device *dev,
> +				      struct sk_buff *skb,
> +				      int type) { }
> +
> +static inline int lowpan_ndisc_802154_short_addr_space(struct net_device *dev)
> +{
> +	return 0;
> +}
> +#endif
> +
> +static void lowpan_ndisc_parse_addr_options(const struct net_device *dev,
> +					    struct lowpan_ndisc_options *ndopts,
> +					    struct nd_opt_hdr *nd_opt)
> +{
> +	switch (nd_opt->nd_opt_len) {
> +	case NDISC_802154_EXTENDED_ADDR_LENGTH:
> +		if (ndopts->nd_opt_array[nd_opt->nd_opt_type])
> +			ND_PRINTK(2, warn,
> +				  "%s: duplicated extended addr ND6 option found: type=%d\n",
> +				  __func__, nd_opt->nd_opt_type);
> +		else
> +			ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
> +		break;
> +#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
> +	case NDISC_802154_SHORT_ADDR_LENGTH:
> +		/* only valid on 802.15.4 */
> +		if (!lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154)) {
> +			ND_PRINTK(2, warn,
> +				  "%s: invalid length detected: type=%d\n",
> +				  __func__, nd_opt->nd_opt_type);
> +			break;
> +		}
> +
> +		if (ndopts->nd_802154_opt_array[nd_opt->nd_opt_type])
> +			ND_PRINTK(2, warn,
> +				  "%s: duplicated short addr ND6 option found: type=%d\n",
> +				  __func__, nd_opt->nd_opt_type);
> +		else
> +			ndopts->nd_802154_opt_array[nd_opt->nd_opt_type] = nd_opt;
> +		break;
> +#endif
> +	default:
> +		ND_PRINTK(2, warn,
> +			  "%s: invalid length detected: type=%d\n",
> +			  __func__, nd_opt->nd_opt_type);
> +		break;
> +	}
> +}
> +
> +static struct lowpan_ndisc_options *
> +lowpan_ndisc_parse_options(const struct net_device *dev, u8 *opt, int opt_len,
> +			   struct lowpan_ndisc_options *ndopts)
> +{
> +	struct nd_opt_hdr *nd_opt = (struct nd_opt_hdr *)opt;
> +
> +	if (!nd_opt || opt_len < 0 || !ndopts)
> +		return NULL;
> +
> +	memset(ndopts, 0, sizeof(*ndopts));
> +
> +	while (opt_len) {
> +		int l;
> +
> +		if (opt_len < sizeof(struct nd_opt_hdr))
> +			return NULL;
> +
> +		l = nd_opt->nd_opt_len << 3;
> +		if (opt_len < l || l == 0)
> +			return NULL;
> +
> +		switch (nd_opt->nd_opt_type) {
> +		case ND_OPT_SOURCE_LL_ADDR:
> +		case ND_OPT_TARGET_LL_ADDR:
> +			lowpan_ndisc_parse_addr_options(dev, ndopts, nd_opt);
> +			break;
> +		default:
> +			/* Unknown options must be silently ignored,
> +			 * to accommodate future extension to the
> +			 * protocol.
> +			 */
> +			ND_PRINTK(2, notice,
> +				  "%s: ignored unsupported option; type=%d, len=%d\n",
> +				  __func__,
> +				  nd_opt->nd_opt_type,
> +				  nd_opt->nd_opt_len);
> +		}
> +
> +		opt_len -= l;
> +		nd_opt = ((void *)nd_opt) + l;
> +	}
> +
> +	return ndopts;
> +}
> +
> +static void lowpan_ndisc_send_na(struct net_device *dev,
> +				 const struct in6_addr *daddr,
> +				 const struct in6_addr *solicited_addr,
> +				 bool router, bool solicited, bool override,
> +				 bool inc_opt)
> +{
> +	struct sk_buff *skb;
> +	struct in6_addr tmpaddr;
> +	struct inet6_ifaddr *ifp;
> +	const struct in6_addr *src_addr;
> +	struct nd_msg *msg;
> +	int optlen = 0;
> +
> +	/* for anycast or proxy, solicited_addr != src_addr */
> +	ifp = ipv6_get_ifaddr(dev_net(dev), solicited_addr, dev, 1);
> +	if (ifp) {
> +		src_addr = solicited_addr;
> +		if (ifp->flags & IFA_F_OPTIMISTIC)
> +			override = false;
> +		inc_opt |= ifp->idev->cnf.force_tllao;
> +		in6_ifa_put(ifp);
> +	} else {
> +		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
> +				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->srcprefs,
> +				       &tmpaddr))
> +			return;
> +		src_addr = &tmpaddr;
> +	}
> +
> +	if (!dev->addr_len)
> +		inc_opt = 0;
> +	if (inc_opt) {
> +		optlen += ndisc_opt_addr_space(dev, dev->addr_len);
> +		optlen += lowpan_ndisc_802154_short_addr_space(dev);
> +	}
> +
> +	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
> +	if (!skb)
> +		return;
> +
> +	msg = (struct nd_msg *)skb_put(skb, sizeof(*msg));
> +	*msg = (struct nd_msg) {
> +		.icmph = {
> +			.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
> +			.icmp6_router = router,
> +			.icmp6_solicited = solicited,
> +			.icmp6_override = override,
> +		},
> +		.target = *solicited_addr,
> +	};
> +
> +	if (inc_opt) {
> +		ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR,
> +				       dev->dev_addr, dev->addr_len);
> +		lowpan_ndisc_802154_short_addr_option(dev, skb,
> +						      ND_OPT_TARGET_LL_ADDR);
> +	}
> +
> +	ndisc_send_skb(skb, daddr, src_addr);
> +}
> +
> +static void lowpan_ndisc_recv_na(struct sk_buff *skb)
> +{
> +	struct nd_msg *msg = (struct nd_msg *)skb_transport_header(skb);
> +	struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
> +	const struct in6_addr *daddr = &ipv6_hdr(skb)->daddr;
> +	u8 *lladdr = NULL;
> +	u32 ndoptlen = skb_tail_pointer(skb) - (skb_transport_header(skb) +
> +				    offsetof(struct nd_msg, opt));
> +	struct lowpan_ndisc_options ndopts;
> +	struct net_device *dev = skb->dev;
> +	struct inet6_dev *idev = __in6_dev_get(dev);
> +	struct inet6_ifaddr *ifp;
> +	struct neighbour *neigh;
> +	u8 *lladdr_short = NULL;
> +
> +	if (skb->len < sizeof(struct nd_msg)) {
> +		ND_PRINTK(2, warn, "NA: packet too short\n");
> +		return;
> +	}
> +
> +	if (ipv6_addr_is_multicast(&msg->target)) {
> +		ND_PRINTK(2, warn, "NA: target address is multicast\n");
> +		return;
> +	}
> +
> +	if (ipv6_addr_is_multicast(daddr) &&
> +	    msg->icmph.icmp6_solicited) {
> +		ND_PRINTK(2, warn, "NA: solicited NA is multicasted\n");
> +		return;
> +	}
> +
> +	/* For some 802.11 wireless deployments (and possibly other networks),
> +	 * there will be a NA proxy and unsolicitd packets are attacks
> +	 * and thus should not be accepted.
> +	 */
> +	if (!msg->icmph.icmp6_solicited && idev &&
> +	    idev->cnf.drop_unsolicited_na)
> +		return;
> +
> +	if (!lowpan_ndisc_parse_options(dev, msg->opt, ndoptlen, &ndopts)) {
> +		ND_PRINTK(2, warn, "NS: invalid ND option\n");
> +		return;
> +	}
> +	if (ndopts.nd_opts_tgt_lladdr) {
> +		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr, dev,
> +					     dev->addr_len);
> +		if (!lladdr) {
> +			ND_PRINTK(2, warn,
> +				  "NA: invalid link-layer address length\n");
> +			return;
> +		}
> +	}
> +#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
> +	if (lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154) &&
> +	    ndopts.nd_802154_opts_tgt_lladdr) {
> +		lladdr_short = ndisc_opt_addr_data(ndopts.nd_802154_opts_tgt_lladdr,
> +						   dev, IEEE802154_SHORT_ADDR_LEN);
> +		if (!lladdr_short) {
> +			ND_PRINTK(2, warn,
> +				  "NA: invalid short link-layer address length\n");
> +			return;
> +		}
> +	}
> +#endif
> +	ifp = ipv6_get_ifaddr(dev_net(dev), &msg->target, dev, 1);
> +	if (ifp) {
> +		if (skb->pkt_type != PACKET_LOOPBACK &&
> +		    (ifp->flags & IFA_F_TENTATIVE)) {
> +			addrconf_dad_failure(ifp);
> +			return;
> +		}
> +		/* What should we make now? The advertisement
> +		 * is invalid, but ndisc specs say nothing
> +		 * about it. It could be misconfiguration, or
> +		 * an smart proxy agent tries to help us :-)
> +		 *
> +		 * We should not print the error if NA has been
> +		 * received from loopback - it is just our own
> +		 * unsolicited advertisement.
> +		 */
> +		if (skb->pkt_type != PACKET_LOOPBACK)
> +			ND_PRINTK(1, warn,
> +				  "NA: someone advertises our address %pI6 on %s!\n",
> +				  &ifp->addr, ifp->idev->dev->name);
> +		in6_ifa_put(ifp);
> +		return;
> +	}
> +	neigh = neigh_lookup(&nd_tbl, &msg->target, dev);
> +
> +	if (neigh) {
> +		u8 old_flags = neigh->flags;
> +		struct net *net = dev_net(dev);
> +
> +		if (neigh->nud_state & NUD_FAILED)
> +			goto out;
> +
> +		/* Don't update the neighbor cache entry on a proxy NA from
> +		 * ourselves because either the proxied node is off link or it
> +		 * has already sent a NA to us.
> +		 */
> +		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
> +		    net->ipv6.devconf_all->forwarding &&
> +		    net->ipv6.devconf_all->proxy_ndp &&
> +		    pneigh_lookup(&nd_tbl, net, &msg->target, dev, 0)) {
> +			/* XXX: idev->cnf.proxy_ndp */

What is this XXX for here? Either a real comment about something that 
need to be fixed in the future or just remove it.

> +			goto out;
> +		}
> +
> +		neigh_update(neigh, lladdr,
> +			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
> +			     NEIGH_UPDATE_F_WEAK_OVERRIDE |
> +			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0) |
> +			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER |
> +			     (msg->icmph.icmp6_router ? NEIGH_UPDATE_F_ISROUTER : 0));
> +
> +		if (lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154))
> +			lowpan_ndisc_802154_neigh_update(neigh, lladdr_short,
> +							 msg->icmph.icmp6_override);
> +
> +		if ((old_flags & ~neigh->flags) & NTF_ROUTER) {
> +			/* Change: router to host */
> +			rt6_clean_tohost(dev_net(dev),  saddr);
> +		}
> +
> +out:
> +		neigh_release(neigh);
> +	}
> +}
> +
> +static void lowpan_ndisc_send_ns(struct net_device *dev,
> +				 const struct in6_addr *solicit,
> +				 const struct in6_addr *daddr,
> +				 const struct in6_addr *saddr)
> +{
> +	struct sk_buff *skb;
> +	struct in6_addr addr_buf;
> +	int inc_opt = dev->addr_len;
> +	int optlen = 0;
> +	struct nd_msg *msg;
> +
> +	if (!saddr) {
> +		if (ipv6_get_lladdr(dev, &addr_buf,
> +				    (IFA_F_TENTATIVE | IFA_F_OPTIMISTIC)))
> +			return;
> +		saddr = &addr_buf;
> +	}
> +
> +	if (ipv6_addr_any(saddr))
> +		inc_opt = false;
> +	if (inc_opt) {
> +		optlen += ndisc_opt_addr_space(dev, dev->addr_len);
> +		optlen += lowpan_ndisc_802154_short_addr_space(dev);
> +	}
> +
> +	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
> +	if (!skb)
> +		return;
> +
> +	msg = (struct nd_msg *)skb_put(skb, sizeof(*msg));
> +	*msg = (struct nd_msg) {
> +		.icmph = {
> +			.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
> +		},
> +		.target = *solicit,
> +	};
> +
> +	if (inc_opt) {
> +		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
> +				       dev->dev_addr, dev->addr_len);
> +		lowpan_ndisc_802154_short_addr_option(dev, skb,
> +						      ND_OPT_SOURCE_LL_ADDR);
> +	}
> +
> +	ndisc_send_skb(skb, daddr, saddr);
> +}
> +
> +static void lowpan_ndisc_recv_ns(struct sk_buff *skb)
> +{
> +	struct nd_msg *msg = (struct nd_msg *)skb_transport_header(skb);
> +	const struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
> +	const struct in6_addr *daddr = &ipv6_hdr(skb)->daddr;
> +	u8 *lladdr = NULL;
> +	u32 ndoptlen = skb_tail_pointer(skb) - (skb_transport_header(skb) +
> +				    offsetof(struct nd_msg, opt));
> +	struct lowpan_ndisc_options ndopts;
> +	struct net_device *dev = skb->dev;
> +	struct inet6_ifaddr *ifp;
> +	struct inet6_dev *idev = NULL;
> +	struct neighbour *neigh;
> +	int dad = ipv6_addr_any(saddr);
> +	bool inc;
> +	int is_router = -1;
> +	u8 *lladdr_short = NULL;
> +
> +	if (skb->len < sizeof(struct nd_msg)) {
> +		ND_PRINTK(2, warn, "NS: packet too short\n");
> +		return;
> +	}
> +
> +	if (ipv6_addr_is_multicast(&msg->target)) {
> +		ND_PRINTK(2, warn, "NS: multicast target address\n");
> +		return;
> +	}
> +
> +	/* RFC2461 7.1.1:
> +	 * DAD has to be destined for solicited node multicast address.
> +	 */
> +	if (dad && !ipv6_addr_is_solict_mult(daddr)) {
> +		ND_PRINTK(2, warn, "NS: bad DAD packet (wrong destination)\n");
> +		return;
> +	}
> +
> +	if (!lowpan_ndisc_parse_options(dev, msg->opt, ndoptlen, &ndopts)) {
> +		ND_PRINTK(2, warn, "NS: invalid ND options\n");
> +		return;
> +	}
> +
> +	if (ndopts.nd_opts_src_lladdr) {
> +		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr, dev,
> +					     dev->addr_len);
> +		if (!lladdr) {
> +			ND_PRINTK(2, warn,
> +				  "NS: invalid link-layer address length\n");
> +			return;
> +		}
> +
> +		/* RFC2461 7.1.1:
> +		 *	If the IP source address is the unspecified address,
> +		 *	there MUST NOT be source link-layer address option
> +		 *	in the message.
> +		 */
> +		if (dad) {
> +			ND_PRINTK(2, warn,
> +				  "NS: bad DAD packet (link-layer address option)\n");
> +			return;
> +		}
> +	}
> +
> +#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
> +	if (lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154) &&
> +	    ndopts.nd_802154_opts_src_lladdr) {
> +		lladdr_short = ndisc_opt_addr_data(ndopts.nd_802154_opts_src_lladdr,
> +						   dev, IEEE802154_SHORT_ADDR_LEN);
> +		if (!lladdr_short) {
> +			ND_PRINTK(2, warn,
> +				  "NS: invalid short link-layer address length\n");
> +			return;
> +		}
> +
> +		/* RFC2461 7.1.1:
> +		 *	If the IP source address is the unspecified address,
> +		 *	there MUST NOT be source link-layer address option
> +		 *	in the message.
> +		 */
> +		if (dad) {
> +			ND_PRINTK(2, warn,
> +				  "NS: bad DAD packet (short link-layer address option)\n");
> +			return;
> +		}
> +	}
> +#endif
> +
> +	inc = ipv6_addr_is_multicast(daddr);
> +
> +	ifp = ipv6_get_ifaddr(dev_net(dev), &msg->target, dev, 1);
> +	if (ifp) {
> +have_ifp:
> +		if (ifp->flags & (IFA_F_TENTATIVE | IFA_F_OPTIMISTIC)) {
> +			if (dad) {
> +				/* We are colliding with another node
> +				 * who is doing DAD
> +				 * so fail our DAD process
> +				 */
> +				addrconf_dad_failure(ifp);
> +				return;
> +			}
> +
> +			/* This is not a dad solicitation.
> +			 * If we are an optimistic node,
> +			 * we should respond.
> +			 * Otherwise, we should ignore it.
> +			 */
> +			if (!(ifp->flags & IFA_F_OPTIMISTIC))
> +				goto out;
> +		}
> +
> +		idev = ifp->idev;
> +	} else {
> +		struct net *net = dev_net(dev);
> +
> +		/* perhaps an address on the master device */
> +		if (netif_is_l3_slave(dev)) {
> +			struct net_device *mdev;
> +
> +			mdev = netdev_master_upper_dev_get_rcu(dev);
> +			if (mdev) {
> +				ifp = ipv6_get_ifaddr(net, &msg->target, mdev, 1);
> +				if (ifp)
> +					goto have_ifp;
> +			}
> +		}
> +
> +		idev = in6_dev_get(dev);
> +		if (!idev) {
> +			/* XXX: count this drop? */
> +			return;
> +		}
> +
> +		if (ipv6_chk_acast_addr(net, dev, &msg->target) ||
> +		    (idev->cnf.forwarding &&
> +		     (net->ipv6.devconf_all->proxy_ndp || idev->cnf.proxy_ndp) &&
> +		     (is_router = pndisc_is_router(&msg->target, dev)) >= 0)) {
> +			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
> +			    skb->pkt_type != PACKET_HOST &&
> +			    inc &&
> +			    NEIGH_VAR(idev->nd_parms, PROXY_DELAY) != 0) {
> +				/* for anycast or proxy,
> +				 * sender should delay its response
> +				 * by a random time between 0 and
> +				 * MAX_ANYCAST_DELAY_TIME seconds.
> +				 * (RFC2461) -- yoshfuji
> +				 */
> +				struct sk_buff *n = skb_clone(skb, GFP_ATOMIC);
> +
> +				if (n)
> +					pneigh_enqueue(&nd_tbl, idev->nd_parms,
> +						       n);
> +				goto out;
> +			}
> +		} else {
> +			goto out;
> +		}
> +	}
> +
> +	if (is_router < 0)
> +		is_router = idev->cnf.forwarding;
> +
> +	if (dad) {
> +		ndisc_send_na(dev, &in6addr_linklocal_allnodes, &msg->target,
> +			      !!is_router, false, (ifp != NULL), true);
> +		goto out;
> +	}
> +
> +	if (inc)
> +		NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_mcast);
> +	else
> +		NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_ucast);
> +
> +	/* update / create cache entry
> +	 * for the source address
> +	 */
> +	neigh = __neigh_lookup(&nd_tbl, saddr, dev,
> +			       !inc || lladdr || !dev->addr_len);
> +	if (neigh) {
> +		neigh_update(neigh, lladdr, NUD_STALE,
> +			     NEIGH_UPDATE_F_WEAK_OVERRIDE |
> +			     NEIGH_UPDATE_F_OVERRIDE);
> +		if (lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154))
> +			lowpan_ndisc_802154_neigh_update(neigh, lladdr_short,
> +							 true);
> +	}
> +	if (neigh || !dev->header_ops) {
> +		ndisc_send_na(dev, saddr, &msg->target, !!is_router,
> +			      true, (ifp != NULL && inc), inc);
> +		if (neigh)
> +			neigh_release(neigh);
> +	}
> +
> +out:
> +	if (ifp)
> +		in6_ifa_put(ifp);
> +	else
> +		in6_dev_put(idev);
> +}
> +
> +static inline int lowpan_ndisc_is_useropt(struct nd_opt_hdr *opt)
> +{
> +	return __ip6_ndisc_is_useropt(opt) || opt->nd_opt_type == ND_OPT_6CO;
> +}
> +
> +static const struct ndisc_ops lowpan_ndisc_ops = {
> +	.is_useropt = lowpan_ndisc_is_useropt,
> +	.send_na = lowpan_ndisc_send_na,
> +	.recv_na = lowpan_ndisc_recv_na,
> +	.send_ns = lowpan_ndisc_send_ns,
> +	.recv_ns = lowpan_ndisc_recv_ns,
> +};
> +
> +void lowpan_register_ndisc_ops(struct net_device *dev)
> +{
> +	dev->ndisc_ops = &lowpan_ndisc_ops;
> +}
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index dc8bfec..9d7f228 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1792,6 +1792,9 @@ static const struct ndisc_ops ip6_ndisc_ops = {
>   void ip6_register_ndisc_ops(struct net_device *dev)
>   {
>   	switch (dev->type) {
> +	case ARPHRD_6LOWPAN:
> +		/* will be assigned while lowpan interface register */
> +		break;
>   	default:
>   		if (dev->ndisc_ops) {
>   			ND_PRINTK(2, warn,

Reviewed-by: Stefan Schmidt<stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>

regards
Stefan Schmidt

From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 13 Feb 2017 10:25:19 +0100 (CET)
Message-ID: <1107124975.65949.1486977919253.JavaMail.zimbra@tpip.net>
References: <20170203091231.10142-1-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: laforge <laforge@gnumonks.org>, pablo <pablo@netfilter.org>,
        netdev <netdev@vger.kernel.org>
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:44485 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751666AbdBMJZX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 04:25:23 -0500
In-Reply-To: <20170203091231.10142-1-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm a bit late to comment, but maybe you can consider an additional
change for v2...

----- On Feb 3, 2017, at 10:12 AM, Jonas Bonn jonas@southpole.se wrote:

> The GTP-tunnel driver is explicitly GGSN-side as it searches for PDP
> contexts based on the incoming packets _destination_ address.  If we
> want to write an SGSN, then we want to be idenityfing PDP contexts
> based on _source_ address.
> 
> This patch adds a "flags" argument at GTP-link creation time to specify
> whether we are on the GGSN or SGSN side of the tunnel; this flag is then
> used to determine which part of the IP packet to use in determining
> the PDP context.
> 
> Signed-off-by: Jonas Bonn <jonas@southpole.se>
> ---
> 
> drivers/net/gtp.c            | 43 ++++++++++++++++++++++++++++++++-----------
> include/uapi/linux/gtp.h     |  2 +-
> include/uapi/linux/if_link.h |  5 +++++
> 3 files changed, 38 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
> index 50349a9..1bbac69 100644
> --- a/drivers/net/gtp.c
> +++ b/drivers/net/gtp.c
> @@ -72,6 +72,7 @@ struct gtp_dev {
> 	struct net		*net;
> 	struct net_device	*dev;
> 
> +	unsigned int		flags;

This should IMHO not go into the gtp_dev, the right place
is the PDP context.

In the current design the netdevice might seem like the logical
place, but the relation between tunnels and netdevices is actually
wrong. This leaves the PDP context the only correct place.

I currently have an ongoing discussion with Pablo about this. Harald
seems already convinced (http://marc.info/?l=linux-netdev&m=148638992010344&w=2).

> 	unsigned int		hash_size;
> 	struct hlist_head	*tid_hash;
> 	struct hlist_head	*addr_hash;
> @@ -150,8 +151,8 @@ static struct pdp_ctx *ipv4_pdp_find(struct gtp_dev *gtp,
> __be32 ms_addr)
> 	return NULL;
> }
> 
> -static bool gtp_check_src_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
> -				  unsigned int hdrlen)
> +static bool gtp_check_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
> +				  unsigned int hdrlen, unsigned int flags)
> {
> 	struct iphdr *iph;
> 
> @@ -160,18 +161,22 @@ static bool gtp_check_src_ms_ipv4(struct sk_buff *skb,
> struct pdp_ctx *pctx,
> 
> 	iph = (struct iphdr *)(skb->data + hdrlen);
> 
> -	return iph->saddr == pctx->ms_addr_ip4.s_addr;
> +	if (flags & GTP_FLAGS_SGSN) {
> +		return iph->daddr == pctx->ms_addr_ip4.s_addr;
> +	} else {
> +		return iph->saddr == pctx->ms_addr_ip4.s_addr;
> +	}
> }
> 
> -/* Check if the inner IP source address in this packet is assigned to any
> +/* Check if the inner IP address in this packet is assigned to any
>  * existing mobile subscriber.
>  */
> -static bool gtp_check_src_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
> -			     unsigned int hdrlen)
> +static bool gtp_check_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
> +			     unsigned int hdrlen, unsigned int flags)
> {
> 	switch (ntohs(skb->protocol)) {
> 	case ETH_P_IP:
> -		return gtp_check_src_ms_ipv4(skb, pctx, hdrlen);
> +		return gtp_check_ms_ipv4(skb, pctx, hdrlen, flags);
> 	}
> 	return false;
> }
> @@ -205,7 +210,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct
> sk_buff *skb,
> 		goto out_rcu;
> 	}
> 
> -	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
> +	if (!gtp_check_ms(skb, pctx, hdrlen, gtp->flags)) {
> 		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
> 		ret = -1;
> 		goto out_rcu;
> @@ -248,7 +253,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct
> sk_buff *skb,
> 	if (gtp1->flags & GTP1_F_MASK)
> 		hdrlen += 4;
> 
> -	/* Make sure the header is larger enough, including extensions. */
> +	/* Make sure the header is large enough, including extensions. */
> 	if (!pskb_may_pull(skb, hdrlen))
> 		return -1;
> 
> @@ -262,7 +267,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct
> sk_buff *skb,
> 		goto out_rcu;
> 	}
> 
> -	if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
> +	if (!gtp_check_ms(skb, pctx, hdrlen, gtp->flags)) {
> 		netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
> 		ret = -1;
> 		goto out_rcu;
> @@ -491,7 +496,11 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct
> net_device *dev,
> 	 * Prepend PDP header with TEI/TID from PDP ctx.
> 	 */
> 	iph = ip_hdr(skb);
> -	pctx = ipv4_pdp_find(gtp, iph->daddr);
> +	if (gtp->flags & GTP_FLAGS_SGSN) {
> +		pctx = ipv4_pdp_find(gtp, iph->saddr);
> +	} else {
> +		pctx = ipv4_pdp_find(gtp, iph->daddr);
> +	}
> 	if (!pctx) {
> 		netdev_dbg(dev, "no PDP ctx found for %pI4, skip\n",
> 			   &iph->daddr);
> @@ -666,12 +675,23 @@ static int gtp_newlink(struct net *src_net, struct
> net_device *dev,
> 	int hashsize, err, fd0, fd1;
> 	struct gtp_dev *gtp;
> 	struct gtp_net *gn;
> +	unsigned int flags;
> +
> +	if (data[IFLA_GTP_FLAGS]) {
> +		flags = nla_get_u32(data[IFLA_GTP_FLAGS]);
> +		if (flags & ~GTP_FLAGS_MASK)
> +			return -EINVAL;
> +	} else {
> +		flags = 0;
> +	}
> 
> 	if (!data[IFLA_GTP_FD0] || !data[IFLA_GTP_FD1])
> 		return -EINVAL;
> 
> 	gtp = netdev_priv(dev);
> 
> +	gtp->flags = flags;
> +
> 	fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
> 	fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
> 
> @@ -723,6 +743,7 @@ static const struct nla_policy gtp_policy[IFLA_GTP_MAX + 1]
> = {
> 	[IFLA_GTP_FD0]			= { .type = NLA_U32 },
> 	[IFLA_GTP_FD1]			= { .type = NLA_U32 },
> 	[IFLA_GTP_PDP_HASHSIZE]		= { .type = NLA_U32 },
> +	[IFLA_GTP_FLAGS]		= { .type = NLA_U32 },
> };
> 
> static int gtp_validate(struct nlattr *tb[], struct nlattr *data[])
> diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
> index 72a04a0..79037cc 100644
> --- a/include/uapi/linux/gtp.h
> +++ b/include/uapi/linux/gtp.h
> @@ -19,7 +19,7 @@ enum gtp_attrs {
> 	GTPA_LINK,
> 	GTPA_VERSION,
> 	GTPA_TID,	/* for GTPv0 only */
> -	GTPA_SGSN_ADDRESS,
> +	GTPA_SGSN_ADDRESS, /* Remote GSN, either SGSN or GGSN */
> 	GTPA_MS_ADDRESS,
> 	GTPA_FLOW,
> 	GTPA_NET_NS_FD,
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index ccde456..a446e7b 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -533,11 +533,16 @@ enum {
> #define IFLA_PPP_MAX (__IFLA_PPP_MAX - 1)
> 
> /* GTP section */
> +
> +#define GTP_FLAGS_SGSN		(1U << 0)
> +#define GTP_FLAGS_MASK		(GTP_FLAGS_SGSN)
> +
> enum {
> 	IFLA_GTP_UNSPEC,
> 	IFLA_GTP_FD0,
> 	IFLA_GTP_FD1,
> 	IFLA_GTP_PDP_HASHSIZE,
> +	IFLA_GTP_FLAGS,
> 	__IFLA_GTP_MAX,
> };
> #define IFLA_GTP_MAX (__IFLA_GTP_MAX - 1)
> --
> 2.9.3

Andreas

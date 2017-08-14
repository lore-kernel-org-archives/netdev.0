From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] gre: introduce native tunnel support for
 ERSPAN
Date: Sun, 13 Aug 2017 19:53:47 -0700 (PDT)
Message-ID: <20170813.195347.1798002797313374893.davem@davemloft.net>
References: <1502311986-36324-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mvohra@vmware.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50146 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752111AbdHNCxs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 22:53:48 -0400
In-Reply-To: <1502311986-36324-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Wed,  9 Aug 2017 13:53:05 -0700

> The patch adds ERSPAN type II tunnel support.  The implementation
> is based on the draft at [1].  One of the purposes is for Linux
> box to be able to receive ERSPAN monitoring traffic sent from
> the Cisco switch, by creating a ERSPAN tunnel device.
> In addition, the patch also adds ERSPAN TX, so traffic can
> also be encapsulated into ERSPAN and sent out.
> 
> The implementation reuses the key as ERSPAN session ID, and
> field 'erspan' as ERSPAN Index fields:
> ./ip link add dev ers11 type erspan seq key 100 erspan 123 \
> 			local 172.16.1.200 remote 172.16.1.100
> 
> [1] https://tools.ietf.org/html/draft-foschiano-erspan-01
> [2] iproute patch: http://marc.info/?l=linux-netdev&m=150231090207544&w=2
> 
> Signed-off-by: William Tu <u9012063@gmail.com>
> Signed-off-by: Meenakshi Vohra <mvohra@vmware.com>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> ---
> v1->v2: 
>  Add missing erspan.h header
> 
> ---
>  include/net/erspan.h           |  62 +++++++++++
>  include/net/ip_tunnels.h       |   3 +
>  include/uapi/linux/if_ether.h  |   1 +
>  include/uapi/linux/if_tunnel.h |   1 +
>  net/ipv4/ip_gre.c              | 248 +++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 315 insertions(+)
>  create mode 100644 include/net/erspan.h
> 
> diff --git a/include/net/erspan.h b/include/net/erspan.h
> new file mode 100644
> index 000000000000..cafe387a2cae
> --- /dev/null
> +++ b/include/net/erspan.h
> @@ -0,0 +1,62 @@
> +#ifndef __LINUX_ERSPAN_H
> +#define __LINUX_ERSPAN_H
> +
> +/*
> + * GRE header for ERSPAN encapsulation (8 octets [34:41]) -- 8 bytes
> + *       0                   1                   2                   3
> + *      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
> + *     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *     |0|0|0|1|0|00000|000000000|00000|    Protocol Type for ERSPAN   |
> + *     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *     |      Sequence Number (increments per packet per session)      |
> + *     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *
> + *  Note that in the above GRE header [RFC1701] out of the C, R, K, S,
> + *  s, Recur, Flags, Version fields only S (bit 03) is set to 1. The
> + *  other fields are set to zero, so only a sequence number follows.
> + *
> + *  ERSPAN Type II header (8 octets [42:49])
> + *  0                   1                   2                   3
> + *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * |  Ver  |          VLAN         | COS | En|T|    Session ID     |
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * |      Reserved         |                  Index                |
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *
> +  * GRE proto ERSPAN type II = 0x88BE, type III = 0x22EB
> + */
> +
> +#define ERSPAN_VERSION	0x1
> +
> +#define VER_MASK	0xf000
> +#define VLAN_MASK	0x0fff
> +#define COS_MASK	0xe000
> +#define EN_MASK		0x1800
> +#define BOS_MASK	0x1800 //?
> +#define T_MASK		0x0400
> +#define ID_MASK		0x03ff
> +#define INDEX_MASK	0xfffff
> +
> +enum erspan_encap_type {
> +	ERSPAN_ENCAP_NOVLAN = 0x0,	/* originally without VLAN tag */
> +	ERSPAN_ENCAP_ISL = 0x1,		/* originally ISL encapsulated */
> +	ERSPAN_ENCAP_8021Q = 0x2,	/* originally 802.1Q encapsulated */
> +	ERSPAN_ENCAP_INFRAME = 0x3,	/* VLAN tag perserved in frame */
> +};
> +
> +struct erspan_metadata {
> +	__be32 index;   /* type II */
> +};
> +
> +struct erspanhdr {
> +       __be16 ver_vlan;
> +#define VER_OFFSET  12
> +       __be16 session_id;
> +#define COS_OFFSET  13
> +#define EN_OFFSET   11
> +#define T_OFFSET    10
> +       struct erspan_metadata md;
> +};
> +
> +#endif
> diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
> index 520809912f03..625c29329372 100644
> --- a/include/net/ip_tunnels.h
> +++ b/include/net/ip_tunnels.h
> @@ -115,6 +115,9 @@ struct ip_tunnel {
>  	u32		o_seqno;	/* The last output seqno */
>  	int		tun_hlen;	/* Precalculated header length */
>  
> +	/* This field used only by ERSPAN */
> +	u32		index;		/* ERSPAN type II index */
> +
>  	struct dst_cache dst_cache;
>  
>  	struct ip_tunnel_parm parms;
> diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
> index 5bc9bfd816b7..efeb1190c2ca 100644
> --- a/include/uapi/linux/if_ether.h
> +++ b/include/uapi/linux/if_ether.h
> @@ -66,6 +66,7 @@
>  #define ETH_P_ATALK	0x809B		/* Appletalk DDP		*/
>  #define ETH_P_AARP	0x80F3		/* Appletalk AARP		*/
>  #define ETH_P_8021Q	0x8100          /* 802.1Q VLAN Extended Header  */
> +#define ETH_P_ERSPAN	0x88BE		/* ERSPAN type II		*/
>  #define ETH_P_IPX	0x8137		/* IPX over DIX			*/
>  #define ETH_P_IPV6	0x86DD		/* IPv6 over bluebook		*/
>  #define ETH_P_PAUSE	0x8808		/* IEEE Pause frames. See 802.3 31B */
> diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
> index 6792d1967d31..2e520883c054 100644
> --- a/include/uapi/linux/if_tunnel.h
> +++ b/include/uapi/linux/if_tunnel.h
> @@ -134,6 +134,7 @@ enum {
>  	IFLA_GRE_COLLECT_METADATA,
>  	IFLA_GRE_IGNORE_DF,
>  	IFLA_GRE_FWMARK,
> +	IFLA_GRE_ERSPAN_INDEX,
>  	__IFLA_GRE_MAX,
>  };
>  
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 7a7829e839c2..e15d5f01cdb5 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -48,6 +48,7 @@
>  #include <net/rtnetlink.h>
>  #include <net/gre.h>
>  #include <net/dst_metadata.h>
> +#include <net/erspan.h>
>  
>  /*
>     Problems & solutions
> @@ -115,6 +116,7 @@ static int ipgre_tunnel_init(struct net_device *dev);
>  
>  static unsigned int ipgre_net_id __read_mostly;
>  static unsigned int gre_tap_net_id __read_mostly;
> +static unsigned int erspan_net_id __read_mostly;
>  
>  static void ipgre_err(struct sk_buff *skb, u32 info,
>  		      const struct tnl_ptk_info *tpi)
> @@ -246,6 +248,48 @@ static void gre_err(struct sk_buff *skb, u32 info)
>  	ipgre_err(skb, info, &tpi);
>  }
>  
> +static int erspan_rcv(struct sk_buff *skb, struct tnl_ptk_info *tpi,
> +		      int gre_hdr_len)
> +{
> +	struct net *net = dev_net(skb->dev);
> +	struct ip_tunnel_net *itn;
> +	struct ip_tunnel *tunnel;
> +	struct metadata_dst *tun_dst = NULL;
> +	const struct iphdr *iph;
> +	struct erspanhdr *ershdr;
> +	__be32 index;
> +	__be32 session_id;
> +
> +	itn = net_generic(net, erspan_net_id);
> +	iph = ip_hdr(skb);
> +	ershdr = (struct erspanhdr *)(skb->data + gre_hdr_len);

You're not guaranteed the this ershdr area is pulled linearly in the
SKB.  Only the GRE header and it's options have that guarantee.

So you'll need to add appropriate pskb_may_pull() checks here then
reaload all of the packet pointers (including 'iph') afterwards.

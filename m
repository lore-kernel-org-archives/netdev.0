From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] GRE: Add segmentation offload for GRE TAP device.
Date: Thu, 10 Jan 2013 11:47:24 -0800
Message-ID: <1357847244.27446.2496.camel@edumazet-glaptop>
References: <1357612296-1715-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:51157 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755734Ab3AJTr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 14:47:27 -0500
Received: by mail-pb0-f47.google.com with SMTP id un1so489323pbc.20
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 11:47:26 -0800 (PST)
In-Reply-To: <1357612296-1715-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 18:31 -0800, Pravin B Shelar wrote:
> From: Pravin Shelar <pshelar@nicira.com>

Do you have some perf numbers to share ?

> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  include/linux/skbuff.h |   12 ++++++
>  include/net/gre.h      |    6 +++
>  net/ipv4/af_inet.c     |    1 +
>  net/ipv4/gre.c         |  101 ++++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv4/tcp.c         |    1 +
>  net/ipv4/udp.c         |    3 +-
>  net/ipv6/ip6_offload.c |    1 +
>  net/ipv6/udp_offload.c |    3 +-
>  8 files changed, 126 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 320e976..43033f0 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -307,6 +307,8 @@ enum {
>  	SKB_GSO_TCPV6 = 1 << 4,
>  
>  	SKB_GSO_FCOE = 1 << 5,
> +
> +	SKB_GSO_GRE = 1 << 6,
>  };
>  
>  #if BITS_PER_LONG > 32
> @@ -797,6 +799,16 @@ static inline int skb_cloned(const struct sk_buff *skb)
>  	       (atomic_read(&skb_shinfo(skb)->dataref) & SKB_DATAREF_MASK) != 1;
>  }
>  
> +static inline int skb_unclone(struct sk_buff *skb, gfp_t pri)
> +{
> +	might_sleep_if(pri & __GFP_WAIT);
> +
> +	if (skb_cloned(skb))
> +		return pskb_expand_head(skb, 0, 0, pri);
> +
> +	return 0;
> +}

Should be a commit on its own, and use a "bool"

We have some places in network stack that could use this helper.
(net/ipv6/ah6.c, net/ipv6/reassembly.c,
net/ipv6/xfrm6_mode_tunnel.c, ...)

> +
>  /**
>   *	skb_header_cloned - is the header a clone
>   *	@skb: buffer to check
> diff --git a/include/net/gre.h b/include/net/gre.h
> index 8266547..f7d5bfb 100644
> --- a/include/net/gre.h
> +++ b/include/net/gre.h
> @@ -15,4 +15,10 @@ struct gre_protocol {
>  int gre_add_protocol(const struct gre_protocol *proto, u8 version);
>  int gre_del_protocol(const struct gre_protocol *proto, u8 version);
>  
> +struct gre_base_hdr {
> +	__be16 flags;
> +	__be16 protocol;
> +};
> +#define GRE_HEADER_SECTION 4
> +
>  #endif
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 24b384b..9a3d5d2 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1306,6 +1306,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>  		       SKB_GSO_UDP |
>  		       SKB_GSO_DODGY |
>  		       SKB_GSO_TCP_ECN |
> +		       SKB_GSO_GRE |
>  		       0)))
>  		goto out;
>  
> diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
> index 42a4910..0eaaf44 100644
> --- a/net/ipv4/gre.c
> +++ b/net/ipv4/gre.c
> @@ -19,6 +19,7 @@
>  #include <linux/in.h>
>  #include <linux/ip.h>
>  #include <linux/netdevice.h>
> +#include <linux/if_tunnel.h>
>  #include <linux/spinlock.h>
>  #include <net/protocol.h>
>  #include <net/gre.h>
> @@ -112,12 +113,105 @@ static void gre_err(struct sk_buff *skb, u32 info)
>  	rcu_read_unlock();
>  }
>  
> +static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
> +				       netdev_features_t features)
> +{
> +	struct sk_buff *segs = ERR_PTR(-EINVAL);
> +	struct gre_base_hdr *greh;
> +	unsigned char *mac = skb_mac_header(skb);

    You should not init mac here, but after the pskb_may_pull()

> +	int net_hlen = skb_network_header_len(skb);
> +	int ghl = GRE_HEADER_SECTION;
> +	int mac_len;
> +	int doffset;
> +
> +	if (unlikely(skb_shinfo(skb)->gso_type &
> +				~(SKB_GSO_TCPV4 |
> +					SKB_GSO_UDP |
> +					SKB_GSO_DODGY |
> +					SKB_GSO_TCP_ECN |
> +					SKB_GSO_GRE |
> +					0)))
> +		goto out;
> +
> +	if (unlikely(!pskb_may_pull(skb, sizeof(*greh))))
> +		goto out;



> +
> +	greh = (struct gre_base_hdr *)skb_transport_header(skb);
> +
> +	if (greh->flags & GRE_KEY)
> +		ghl += GRE_HEADER_SECTION;
> +	if (greh->flags & GRE_CSUM)
> +		ghl += GRE_HEADER_SECTION;
> +
> +	if (unlikely(!pskb_may_pull(skb, ghl)))
> +		goto out;
> +

mac can now point to freed memory. You should move its init here :


mac = skb_mac_header(skb);

same for greh

greh = (struct gre_base_hdr *)skb_transport_header(skb);

> +	__skb_pull(skb, ghl);
> +	skb_reset_mac_header(skb);
> +	skb_set_network_header(skb, skb->mac_len);
> +	doffset = skb_mac_header(skb) - mac;
> +	/* segment inner packet. */
> +	segs = skb_gso_segment(skb, 0);
> +	if (!segs || IS_ERR(segs))
> +		goto out;
> +
> +	mac_len = skb_inner_network_header(skb) - ((unsigned char *)greh + ghl);
> +	skb = segs;
> +	do {
> +		unsigned char *smac;
> +
> +		skb_push(skb, doffset);
> +
> +		skb_reset_mac_header(skb);
> +		skb_set_network_header(skb, mac_len);
> +		skb_set_transport_header(skb,
> +					 skb_network_offset(skb) + net_hlen);
> +		smac = skb_mac_header(skb);
> +		skb->mac_len = mac_len;
> +		/* Copy entire outer header from original skb. */
> +		memcpy(smac, mac, doffset);
> +
> +		greh = (struct gre_base_hdr *)skb_transport_header(skb);
> +		if (greh->flags & GRE_CSUM) {
> +			__be32 *gre_csum = (__be32 *)(greh + 1);
> +			*gre_csum = 0;
> +			*(__sum16 *)gre_csum = csum_fold(skb_checksum(skb,
> +						skb_transport_offset(skb),
> +						skb->len - skb_transport_offset(skb),
> +						0));
> +		}
> +	} while ((skb = skb->next));
> +
> +out:
> +	return segs;
> +}
> +

From: "Rajahalme, Jarno (NSN - FI/Espoo)" <jarno.rajahalme-OYasijW0DpE@public.gmane.org>
Subject: Re: [PATCH] MPLS: Add limited GSO support
Date: Wed, 3 Apr 2013 06:36:29 +0000
Message-ID: <74B6572A-FB96-41FA-83E8-5206FFABD1D5@nsn.com>
References: <1364966697-20131-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "<dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: ext Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1364966697-20131-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Content-Language: en-US
Content-ID: <EE6983C7F68F2F418006285EDA9197E3-z7JfP6tgrtWhxUC7wdWhuQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org


On Apr 3, 2013, at 8:24 , ext Simon Horman wrote:

> In the case where a non-MPLS packet is recieved and an MPLS stack is
> added it may well be the case that the original skb is GSO but the
> NIC used for transmit does not support GSO of MPLS packets.
> 
...
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> index d6ee2d0..e7bffa8 100644
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -43,6 +43,7 @@ enum {
> 	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
> 	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
> 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
> +	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
> 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
> 		NETIF_F_GSO_UDP_TUNNEL_BIT,
> 

NETIF_F_GSO_LAST needs an update here?

...
> 
> diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> new file mode 100644
> index 0000000..583de9e
> --- /dev/null
> +++ b/net/mpls/mpls_gso.c
> @@ -0,0 +1,125 @@
> +/*
> + *	MPLS GSO Support
> + *
> + *	Authors: Simon Horman (horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org)
> + *
> + *	This program is free software; you can redistribute it and/or
> + *	modify it under the terms of the GNU General Public License
> + *	as published by the Free Software Foundation; either version
> + *	2 of the License, or (at your option) any later version.
> + *
> + *	Based on: GSO portions of net/ipv4/gre.c
> + */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/err.h>
> +#include <linux/module.h>
> +#include <linux/netdev_features.h>
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +
> +#define MPLS_BOS_MASK	0x00000100	/* Bottom of Stack bit */
> +#define MPLS_HLEN	(sizeof(__be32))
> +
> +static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
> +				       netdev_features_t features)
> +{
> +	struct sk_buff *segs = ERR_PTR(-EINVAL);
> +	netdev_features_t enc_features;
> +	int stack_len = 0;
> +	int mac_len = skb->mac_len;
> +
> +	if (unlikely(skb_shinfo(skb)->gso_type &
> +				~(SKB_GSO_TCPV4 |
> +				  SKB_GSO_TCPV6 |
> +				  SKB_GSO_UDP |
> +				  SKB_GSO_DODGY |
> +				  SKB_GSO_TCP_ECN |
> +				  SKB_GSO_GRE |
> +				  SKB_GSO_MPLS)))
> +		goto out;
> +
> +	while (1) {
> +		__be32 lse = *(__be32 *)(skb_network_header(skb) + stack_len);
> +
> +		stack_len += MPLS_HLEN;
> +		if (unlikely(!pskb_may_pull(skb, MPLS_HLEN)))
> +			goto out;
> +		__skb_pull(skb, MPLS_HLEN);
> +
> +		if (lse & htonl(MPLS_BOS_MASK))
> +			break;
> +	}
> +
> +	/* setup inner skb. */
> +	skb_reset_mac_header(skb);
> +	skb_reset_network_header(skb);
> +	skb->mac_len = 0;
> +	skb->protocol = SKB_GSO_CB(skb)->encap_eth_type;
> +	skb->encapsulation = 0;
> +
> +	/* segment inner packet. */
> +	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb) &
> +		~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);

Add spaces around "|" to make this more readable.

> +	segs = skb_mac_gso_segment(skb, enc_features);
> +	if (IS_ERR_OR_NULL(segs))
> +		goto out;
> +
> +	skb = segs;
> +	do {
> +		__skb_push(skb,  stack_len + mac_len);
> +		skb_reset_mac_header(skb);
> +		skb_set_network_header(skb, mac_len);
> +		skb->mac_len = mac_len;
> +	} while ((skb = skb->next));
> +out:
> +	return segs;
> +}
> +
> +static int mpls_gso_send_check(struct sk_buff *skb)
> +{
> +	if (!skb->encapsulation)
> +		return -EINVAL;
> +	return 0;
> +}
> +
> +static struct packet_offload mpls_mc_offload = {
> +	.type = cpu_to_be16(ETH_P_MPLS_UC),

Should have ETH_P_MPLS_MC here?

> +	.callbacks = {
> +		.gso_send_check =	mpls_gso_send_check,
> +		.gso_segment    =	mpls_gso_segment,
> +	},
> +};
> +
> +static struct packet_offload mpls_uc_offload = {
> +	.type = cpu_to_be16(ETH_P_MPLS_UC),
> +	.callbacks = {
> +		.gso_send_check =	mpls_gso_send_check,
> +		.gso_segment    =	mpls_gso_segment,
> +	},
> +};
> +
> +static int __init mpls_gso_init(void)
> +{
> +	pr_info("MPLS GSO support\n");
> +
> +	dev_add_offload(&mpls_uc_offload);
> +	dev_add_offload(&mpls_mc_offload);
> +
> +	return 0;
> +}
> +
> +static void __exit mpls_gso_exit(void)
> +{
> +	dev_remove_offload(&mpls_uc_offload);
> +	dev_remove_offload(&mpls_mc_offload);
> +}
> +
> +module_init(mpls_gso_init);
> +module_exit(mpls_gso_exit);
> +
> +MODULE_DESCRIPTION("MPLS GSO support");
> +MODULE_AUTHOR("Simon Horman (horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org)");
> +MODULE_LICENSE("GPL");
> +
> -- 
> 1.7.10.4
> 
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> http://openvswitch.org/mailman/listinfo/dev

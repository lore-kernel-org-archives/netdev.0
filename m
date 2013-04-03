From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] [PATCH] MPLS: Add limited GSO support
Date: Wed, 3 Apr 2013 16:32:07 +0900
Message-ID: <20130403073204.GA29100@verge.net.au>
References: <1364966697-20131-1-git-send-email-horms@verge.net.au>
 <74B6572A-FB96-41FA-83E8-5206FFABD1D5@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "<dev@openvswitch.org>" <dev@openvswitch.org>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>
To: "Rajahalme, Jarno (NSN - FI/Espoo)" <jarno.rajahalme@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:52292 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761641Ab3DCHcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 03:32:10 -0400
Content-Disposition: inline
In-Reply-To: <74B6572A-FB96-41FA-83E8-5206FFABD1D5@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 03, 2013 at 06:36:29AM +0000, Rajahalme, Jarno (NSN - FI/Espoo) wrote:
> 
> On Apr 3, 2013, at 8:24 , ext Simon Horman wrote:
> 
> > In the case where a non-MPLS packet is recieved and an MPLS stack is
> > added it may well be the case that the original skb is GSO but the
> > NIC used for transmit does not support GSO of MPLS packets.
> > 
> ...
> > diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> > index d6ee2d0..e7bffa8 100644
> > --- a/include/linux/netdev_features.h
> > +++ b/include/linux/netdev_features.h
> > @@ -43,6 +43,7 @@ enum {
> > 	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
> > 	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
> > 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
> > +	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
> > 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
> > 		NETIF_F_GSO_UDP_TUNNEL_BIT,
> > 
> 
> NETIF_F_GSO_LAST needs an update here?

Thanks, I will fix that in v2.

> ...
> > 
> > diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> > new file mode 100644
> > index 0000000..583de9e
> > --- /dev/null
> > +++ b/net/mpls/mpls_gso.c
> > @@ -0,0 +1,125 @@
> > +/*
> > + *	MPLS GSO Support
> > + *
> > + *	Authors: Simon Horman (horms@verge.net.au)
> > + *
> > + *	This program is free software; you can redistribute it and/or
> > + *	modify it under the terms of the GNU General Public License
> > + *	as published by the Free Software Foundation; either version
> > + *	2 of the License, or (at your option) any later version.
> > + *
> > + *	Based on: GSO portions of net/ipv4/gre.c
> > + */
> > +
> > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > +
> > +#include <linux/err.h>
> > +#include <linux/module.h>
> > +#include <linux/netdev_features.h>
> > +#include <linux/netdevice.h>
> > +#include <linux/skbuff.h>
> > +
> > +#define MPLS_BOS_MASK	0x00000100	/* Bottom of Stack bit */
> > +#define MPLS_HLEN	(sizeof(__be32))
> > +
> > +static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
> > +				       netdev_features_t features)
> > +{
> > +	struct sk_buff *segs = ERR_PTR(-EINVAL);
> > +	netdev_features_t enc_features;
> > +	int stack_len = 0;
> > +	int mac_len = skb->mac_len;
> > +
> > +	if (unlikely(skb_shinfo(skb)->gso_type &
> > +				~(SKB_GSO_TCPV4 |
> > +				  SKB_GSO_TCPV6 |
> > +				  SKB_GSO_UDP |
> > +				  SKB_GSO_DODGY |
> > +				  SKB_GSO_TCP_ECN |
> > +				  SKB_GSO_GRE |
> > +				  SKB_GSO_MPLS)))
> > +		goto out;
> > +
> > +	while (1) {
> > +		__be32 lse = *(__be32 *)(skb_network_header(skb) + stack_len);
> > +
> > +		stack_len += MPLS_HLEN;
> > +		if (unlikely(!pskb_may_pull(skb, MPLS_HLEN)))
> > +			goto out;
> > +		__skb_pull(skb, MPLS_HLEN);
> > +
> > +		if (lse & htonl(MPLS_BOS_MASK))
> > +			break;
> > +	}
> > +
> > +	/* setup inner skb. */
> > +	skb_reset_mac_header(skb);
> > +	skb_reset_network_header(skb);
> > +	skb->mac_len = 0;
> > +	skb->protocol = SKB_GSO_CB(skb)->encap_eth_type;
> > +	skb->encapsulation = 0;
> > +
> > +	/* segment inner packet. */
> > +	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb) &
> > +		~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
> 
> Add spaces around "|" to make this more readable.

I'm not sure how that crept through.
I believe it should actually be just:

	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);

> > +	segs = skb_mac_gso_segment(skb, enc_features);
> > +	if (IS_ERR_OR_NULL(segs))
> > +		goto out;
> > +
> > +	skb = segs;
> > +	do {
> > +		__skb_push(skb,  stack_len + mac_len);
> > +		skb_reset_mac_header(skb);
> > +		skb_set_network_header(skb, mac_len);
> > +		skb->mac_len = mac_len;
> > +	} while ((skb = skb->next));
> > +out:
> > +	return segs;
> > +}
> > +
> > +static int mpls_gso_send_check(struct sk_buff *skb)
> > +{
> > +	if (!skb->encapsulation)
> > +		return -EINVAL;
> > +	return 0;
> > +}
> > +
> > +static struct packet_offload mpls_mc_offload = {
> > +	.type = cpu_to_be16(ETH_P_MPLS_UC),
> 
> Should have ETH_P_MPLS_MC here?

Yes, thanks. I'll fix that in v2.

> > +	.callbacks = {
> > +		.gso_send_check =	mpls_gso_send_check,
> > +		.gso_segment    =	mpls_gso_segment,
> > +	},
> > +};
> > +
> > +static struct packet_offload mpls_uc_offload = {
> > +	.type = cpu_to_be16(ETH_P_MPLS_UC),
> > +	.callbacks = {
> > +		.gso_send_check =	mpls_gso_send_check,
> > +		.gso_segment    =	mpls_gso_segment,
> > +	},
> > +};
> > +
> > +static int __init mpls_gso_init(void)
> > +{
> > +	pr_info("MPLS GSO support\n");
> > +
> > +	dev_add_offload(&mpls_uc_offload);
> > +	dev_add_offload(&mpls_mc_offload);
> > +
> > +	return 0;
> > +}
> > +
> > +static void __exit mpls_gso_exit(void)
> > +{
> > +	dev_remove_offload(&mpls_uc_offload);
> > +	dev_remove_offload(&mpls_mc_offload);
> > +}
> > +
> > +module_init(mpls_gso_init);
> > +module_exit(mpls_gso_exit);
> > +
> > +MODULE_DESCRIPTION("MPLS GSO support");
> > +MODULE_AUTHOR("Simon Horman (horms@verge.net.au)");
> > +MODULE_LICENSE("GPL");
> > +

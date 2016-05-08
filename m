From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] ifb: support more features
Date: Sat, 07 May 2016 22:41:12 -0700
Message-ID: <1462686072.23934.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462578076.13075.63.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462583999.13075.67.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34797 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbcEHFlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 01:41:15 -0400
Received: by mail-pa0-f54.google.com with SMTP id r5so62711261pag.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 22:41:14 -0700 (PDT)
In-Reply-To: <1462583999.13075.67.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-05-06 at 18:19 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> When using ifb+netem on ingress on SIT/IPIP/GRE traffic,
> GRO packets are not properly processed.
> 
> Segmentation should not be forced, since ifb is already adding
> quite a performance hit.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ifb.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index cc56fac3c3f8..66c0eeafcb5d 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -196,6 +196,7 @@ static const struct net_device_ops ifb_netdev_ops = {
>  
>  #define IFB_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST	| \
>  		      NETIF_F_TSO_ECN | NETIF_F_TSO | NETIF_F_TSO6	| \
> +		      NETIF_F_GSO_ENCAP_ALL 				| \
>  		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_CTAG_TX		| \
>  		      NETIF_F_HW_VLAN_STAG_TX)
>  
> @@ -224,6 +225,8 @@ static void ifb_setup(struct net_device *dev)
>  	dev->tx_queue_len = TX_Q_LIMIT;
>  
>  	dev->features |= IFB_FEATURES;
> +	dev->hw_features |= dev->features;
> +	dev->hw_enc_features |= dev->features;
>  	dev->vlan_features |= IFB_FEATURES & ~(NETIF_F_HW_VLAN_CTAG_TX |
>  					       NETIF_F_HW_VLAN_STAG_TX);
>  
> 


BTW, encapsulated GRO traffic going through mirred+ifb is dropped
because segments get an incorrect skb->mac_len 

(If TSO/GSO is disabled on ifb, as before the above patch)

SIT traffic for example : segments get mac_len set to 34 instead of 14

What do you think of :

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e561f9f07d6d..bec5c32b2fe9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3176,7 +3176,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 		__copy_skb_header(nskb, head_skb);
 
 		skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);
-		skb_reset_mac_len(nskb);
+		nskb->mac_len = head_skb->mac_len;
 
 		skb_copy_from_linear_data_offset(head_skb, -tnl_hlen,
 						 nskb->data - tnl_hlen,

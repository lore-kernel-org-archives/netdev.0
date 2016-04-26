From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next PATCH 6/8] mlx4: Add support for inner IPv6 checksum
 offloads and TSO
Date: Tue, 26 Apr 2016 17:37:08 +0300
Message-ID: <571F7D14.7090504@dev.mellanox.co.il>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
 <20160425183133.11331.54774.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <aduyck@mirantis.com>, talal@mellanox.com,
	netdev@vger.kernel.org, davem@davemloft.net, galp@mellanox.com,
	ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33699 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcDZOhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:37:14 -0400
Received: by mail-wm0-f68.google.com with SMTP id r12so4980807wme.0
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 07:37:13 -0700 (PDT)
In-Reply-To: <20160425183133.11331.54774.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 4/25/2016 9:31 PM, Alexander Duyck wrote:
> >From what I can tell the ConnectX-3 will support an inner IPv6 checksum and
> segmentation offload, however it cannot support outer IPv6 headers.  For
> this reason I am adding the feature to the hw_enc_features and adding an
> extra check to the features_check call that will disable GSO and checksum
> offload in the case that the encapsulated frame has an outer IP version of
> that is not 4.

Hi Alex,

Can you share the testing commands of running vxlan over IPv6 and what 
exactly didn't work for you ?
we would like to test this in house and understand what went wrong, 
theoretically there shouldn't be a difference between IPv6/IPv4 outer
checksum offloading in ConnectX-3.

Anyway, I suspect it might be related to a driver bug most likely in 
get_real_size function @en_tx.c
specifically in : *lso_header_size = (skb_inner_transport_header(skb) - 
skb->data) + inner_tcp_hdrlen(skb);

will check this and get back to you.

for the mlx5 patches I will also go through them later today.

> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   25 +++++++++++++++++++-----
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   15 ++++++++++++--
>   2 files changed, 33 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index bce37cbfde24..6f28ac58251c 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2357,8 +2357,10 @@ out:
>   	}
>   
>   	/* set offloads */
> -	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
> -				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
> +	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +				      NETIF_F_RXCSUM |
> +				      NETIF_F_TSO | NETIF_F_TSO6 |
> +				      NETIF_F_GSO_UDP_TUNNEL |
>   				      NETIF_F_GSO_UDP_TUNNEL_CSUM |
>   				      NETIF_F_GSO_PARTIAL;
>   }
> @@ -2369,8 +2371,10 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
>   	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
>   						 vxlan_del_task);
>   	/* unset offloads */
> -	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
> -					NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
> +	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +					NETIF_F_RXCSUM |
> +					NETIF_F_TSO | NETIF_F_TSO6 |
> +					NETIF_F_GSO_UDP_TUNNEL |
>   					NETIF_F_GSO_UDP_TUNNEL_CSUM |
>   					NETIF_F_GSO_PARTIAL);
>   
> @@ -2431,7 +2435,18 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
>   						netdev_features_t features)
>   {
>   	features = vlan_features_check(skb, features);
> -	return vxlan_features_check(skb, features);
> +	features = vxlan_features_check(skb, features);
> +
> +	/* The ConnectX-3 doesn't support outer IPv6 checksums but it does
> +	 * support inner IPv6 checksums and segmentation so  we need to
> +	 * strip that feature if this is an IPv6 encapsulated frame.
> +	 */
> +	if (skb->encapsulation &&
> +	    (skb->ip_summed == CHECKSUM_PARTIAL) &&
> +	    (ip_hdr(skb)->version != 4))
> +		features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
Dejavu, didn't you fix this already in harmonize_features, in
i.e, it is enough to do here:

if (skb->encapsulation && (skb->ip_summed == CHECKSUM_PARTIAL))
             features &= ~NETIF_F_IPV6_CSUM;


> +
> +	return features;
>   }
>   #endif
>   
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index c0d7b7296236..c9f5388ea22a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -41,6 +41,7 @@
>   #include <linux/vmalloc.h>
>   #include <linux/tcp.h>
>   #include <linux/ip.h>
> +#include <linux/ipv6.h>
>   #include <linux/moduleparam.h>
>   
>   #include "mlx4_en.h"
> @@ -918,8 +919,18 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>   				 tx_ind, fragptr);
>   
>   	if (skb->encapsulation) {
> -		struct iphdr *ipv4 = (struct iphdr *)skb_inner_network_header(skb);
> -		if (ipv4->protocol == IPPROTO_TCP || ipv4->protocol == IPPROTO_UDP)
> +		union {
> +			struct iphdr *v4;
> +			struct ipv6hdr *v6;
> +			unsigned char *hdr;
> +		} ip;
> +		u8 proto;
> +
> +		ip.hdr = skb_inner_network_header(skb);
> +		proto = (ip.v4->version == 4) ? ip.v4->protocol :
> +						ip.v6->nexthdr;
> +
> +		if (proto == IPPROTO_TCP || proto == IPPROTO_UDP)
>   			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP | MLX4_WQE_CTRL_ILP);
>   		else
>   			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP);

basically this is a bug fix, I don't know why the original author 
assumed it will be ipv4 !

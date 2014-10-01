From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: fix bcmgenet_put_tx_csum()
Date: Wed, 01 Oct 2014 11:39:31 -0700
Message-ID: <542C4A63.5000803@gmail.com>
References: <20141001183001.C7D68100A08@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:60132 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbaJASj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 14:39:56 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so659195pdb.21
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 11:39:56 -0700 (PDT)
In-Reply-To: <20141001183001.C7D68100A08@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2014 11:30 AM, Petri Gynther wrote:
> bcmgenet_put_tx_csum() needs to return skb pointer back to the caller
> because it reallocates a new one in case of lack of skb headroom.

Good catch! I guess I never really saw a reallocation thanks to the
needed_headroom provisioned. The bcmsysport driver suffers from the same
problem, I will take care of that one. Thanks!

> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 77cb755..d51729c 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1054,7 +1054,8 @@ static int bcmgenet_xmit_frag(struct net_device *dev,
>  /* Reallocate the SKB to put enough headroom in front of it and insert
>   * the transmit checksum offsets in the descriptors
>   */
> -static int bcmgenet_put_tx_csum(struct net_device *dev, struct sk_buff *skb)
> +static struct sk_buff *bcmgenet_put_tx_csum(struct net_device *dev,
> +					    struct sk_buff *skb)
>  {
>  	struct status_64 *status = NULL;
>  	struct sk_buff *new_skb;
> @@ -1072,7 +1073,7 @@ static int bcmgenet_put_tx_csum(struct net_device *dev, struct sk_buff *skb)
>  		if (!new_skb) {
>  			dev->stats.tx_errors++;
>  			dev->stats.tx_dropped++;
> -			return -ENOMEM;
> +			return NULL;
>  		}
>  		skb = new_skb;
>  	}
> @@ -1090,7 +1091,7 @@ static int bcmgenet_put_tx_csum(struct net_device *dev, struct sk_buff *skb)
>  			ip_proto = ipv6_hdr(skb)->nexthdr;
>  			break;
>  		default:
> -			return 0;
> +			return skb;
>  		}
>  
>  		offset = skb_checksum_start_offset(skb) - sizeof(*status);
> @@ -1111,7 +1112,7 @@ static int bcmgenet_put_tx_csum(struct net_device *dev, struct sk_buff *skb)
>  		status->tx_csum_info = tx_csum_info;
>  	}
>  
> -	return 0;
> +	return skb;
>  }
>  
>  static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
> @@ -1158,8 +1159,8 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	/* set the SKB transmit checksum */
>  	if (priv->desc_64b_en) {
> -		ret = bcmgenet_put_tx_csum(dev, skb);
> -		if (ret) {
> +		skb = bcmgenet_put_tx_csum(dev, skb);
> +		if (!skb) {
>  			ret = NETDEV_TX_OK;
>  			goto out;
>  		}
> 

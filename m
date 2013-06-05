From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next 05/10] vxlan: make vxlan_xmit_one void
Date: Wed, 5 Jun 2013 08:54:04 -0400
Message-ID: <OFD4CE80FE.0925E8B1-ON85257B81.0046B66B-85257B81.0046DDDB@us.ibm.com>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org> <1370406254-6341-5-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:33782 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754042Ab3FEMyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 08:54:11 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 5 Jun 2013 06:54:10 -0600
In-Reply-To: <1370406254-6341-5-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: David L Stevens <dlstevens@us.ibm.com>

netdev-owner@vger.kernel.org wrote on 06/05/2013 12:24:09 AM:

> From: Stephen Hemminger <stephen@networkplumber.org>

> 
> The function vxlan_xmit_one always returns NETDEV_TX_OK, so there
> is no point in keeping track of return values etc.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> ---
>  drivers/net/vxlan.c |   26 +++++++++-----------------
>  1 file changed, 9 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 25d3e9e..f0b7605 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -996,8 +996,8 @@ static void vxlan_encap_bypass(struct sk_buff 
> *skb, struct vxlan_dev *src_vxlan,
>     }
>  }
> 
> -static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct 
> net_device *dev,
> -              struct vxlan_rdst *rdst, bool did_rsc)
> +static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
> +            struct vxlan_rdst *rdst, bool did_rsc)
>  {
>     struct vxlan_dev *vxlan = netdev_priv(dev);
>     struct rtable *rt;
> @@ -1020,7 +1020,7 @@ static netdev_tx_t vxlan_xmit_one(struct 
> sk_buff *skb, struct net_device *dev,
>        if (did_rsc) {
>           /* short-circuited back to local bridge */
>           vxlan_encap_bypass(skb, vxlan, vxlan);
> -         return NETDEV_TX_OK;
> +         return;
>        }
>        goto drop;
>     }
> @@ -1076,7 +1076,7 @@ static netdev_tx_t vxlan_xmit_one(struct 
> sk_buff *skb, struct net_device *dev,
>        if (!dst_vxlan)
>           goto tx_error;
>        vxlan_encap_bypass(skb, vxlan, dst_vxlan);
> -      return NETDEV_TX_OK;
> +      return;
>     }
> 
>     memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> @@ -1120,7 +1120,7 @@ static netdev_tx_t vxlan_xmit_one(struct 
> sk_buff *skb, struct net_device *dev,
>        goto drop;
> 
>     iptunnel_xmit(skb, dev);
> -   return NETDEV_TX_OK;
> +   return;
> 
>  drop:
>     dev->stats.tx_dropped++;
> @@ -1130,7 +1130,6 @@ tx_error:
>     dev->stats.tx_errors++;
>  tx_free:
>     dev_kfree_skb(skb);
> -   return NETDEV_TX_OK;
>  }
> 
>  /* Transmit local packets over Vxlan
> @@ -1146,7 +1145,6 @@ static netdev_tx_t vxlan_xmit(struct sk_buff 
> *skb, struct net_device *dev)
>     bool did_rsc = false;
>     struct vxlan_rdst *rdst0, *rdst;
>     struct vxlan_fdb *f;
> -   int rc1, rc;
> 
>     skb_reset_mac_header(skb);
>     eth = eth_hdr(skb);
> @@ -1174,24 +1172,18 @@ static netdev_tx_t vxlan_xmit(struct sk_buff
> *skb, struct net_device *dev)
>     } else
>        rdst0 = &f->remote;
> 
> -   rc = NETDEV_TX_OK;
> 
>     /* if there are multiple destinations, send copies */
>     for (rdst = rdst0->remote_next; rdst; rdst = rdst->remote_next) {
>        struct sk_buff *skb1;
> 
>        skb1 = skb_clone(skb, GFP_ATOMIC);
> -      if (skb1) {
> -         rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> -         if (rc == NETDEV_TX_OK)
> -            rc = rc1;
> -      }
> +      if (skb1)
> +         vxlan_xmit_one(skb1, dev, rdst, did_rsc);
>     }
> 
> -   rc1 = vxlan_xmit_one(skb, dev, rdst0, did_rsc);
> -   if (rc == NETDEV_TX_OK)
> -      rc = rc1;
> -   return rc;
> +   vxlan_xmit_one(skb, dev, rdst0, did_rsc);
> +   return NETDEV_TX_OK;
>  }
> 
>  /* Walk the forwarding table and purge stale entries */
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

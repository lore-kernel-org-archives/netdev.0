From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/9] IB/ipoib: Add support for acting as VIF
Date: Tue, 10 Jul 2012 14:26:20 +0200
Message-ID: <1341923180.3265.5005.camel@edumazet-glaptop>
References: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
	 <1341922569-4118-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org,
	ali@mellanox.com, sean.hefty@intel.com,
	Erez Shitrit <erezsh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47454 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755382Ab2GJM00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 08:26:26 -0400
Received: by eaak11 with SMTP id k11so4664342eaa.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 05:26:24 -0700 (PDT)
In-Reply-To: <1341922569-4118-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 15:16 +0300, Or Gerlitz wrote:
> From: Erez Shitrit <erezsh@mellanox.co.il>
> 
> When IPoIB interface acts as a VIF for an eIPoIB interface, it uses
> the skb cb storage area on the RX flow, to place information which
> can be of use to the upper layer device.
> 
> One such usage example, is when an eIPoIB inteface needs to generate
> a source mac for incoming Ethernet frames.
> 
> The IPoIB code checks the VIF private flag on the RX path, and accoriding
> to the value of the flag prepares the skb CB data, etc.
> 

...

> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> index 5c1bc99..da28799 100644
> --- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> @@ -300,7 +300,13 @@ static void ipoib_ib_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
>  			likely(wc->wc_flags & IB_WC_IP_CSUM_OK))
>  		skb->ip_summed = CHECKSUM_UNNECESSARY;
>  
> -	napi_gro_receive(&priv->napi, skb);
> +	/* if handler is registered on top of ipoib, set skb oob data */
> +	if (dev->priv_flags & IFF_EIPOIB_VIF) {
> +		set_skb_oob_cb_data(skb, wc, &priv->napi);
> +		/* the registered handler will take care of the skb */
> +		netif_receive_skb(skb);
> +	} else
> +		napi_gro_receive(&priv->napi, skb);

skb->cb[] can be destroyed in netif_receive_skb() /
__netif_receive_skb()

#ifdef CONFIG_NET_CLS_ACT
	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
	...
#endif

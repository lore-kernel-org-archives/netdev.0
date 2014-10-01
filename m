From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] sunvnet: Process Rx data packets in a BH
 handler
Date: Wed, 01 Oct 2014 12:09:19 -0700
Message-ID: <1412190559.16704.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001185615.GH17706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:49610 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaJATJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:09:08 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so806404pad.1
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 12:09:08 -0700 (PDT)
In-Reply-To: <20141001185615.GH17706@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-01 at 14:56 -0400, Sowmini Varadhan wrote:
> Move VIO DATA processing out of interrupt context,
> and into a bottom-half handler (vnet_event_bh())
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>
> 
> ---
>  drivers/net/ethernet/sun/sunvnet.c | 126 ++++++++++++++++++++++++-------------
>  drivers/net/ethernet/sun/sunvnet.h |  10 ++-
>  2 files changed, 91 insertions(+), 45 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
> index 1262697..e2aacf5 100644
> --- a/drivers/net/ethernet/sun/sunvnet.c
> +++ b/drivers/net/ethernet/sun/sunvnet.c
> @@ -274,6 +274,7 @@ static struct sk_buff *alloc_and_align_skb(struct net_device *dev,
>  	return skb;
>  }
>  
> +/* reads in exactly one sk_buff */
>  static int vnet_rx_one(struct vnet_port *port, unsigned int len,
>  		       struct ldc_trans_cookie *cookies, int ncookies)
>  {
> @@ -311,9 +312,8 @@ static int vnet_rx_one(struct vnet_port *port, unsigned int len,
>  
>  	dev->stats.rx_packets++;
>  	dev->stats.rx_bytes += len;
> -
> -	netif_rx(skb);
> -
> +	/* BH context cannot call netif_receive_skb */
> +	netif_rx_ni(skb);

Really ? What about the standard and less expensive netif_receive_skb ?



>  	u64			rmtu;
> +
> +	struct mutex            vnet_rx_mutex; /* serializes rx_workq */
> +	struct work_struct      rx_work;
> +	struct workqueue_struct *rx_workq;
> +
>  };
>  

Could you describe in the changelog why all this is needed ?

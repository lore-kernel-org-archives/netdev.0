From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 2/5] net/cpsw: don't continue if we miss to allocate rx
 skbs
Date: Thu, 18 Apr 2013 17:20:06 +0530
Message-ID: <516FDDEE.6030906@ti.com>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-3-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:33811 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967170Ab3DRLuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 07:50:14 -0400
In-Reply-To: <1366235536-15744-3-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/2013 3:22 AM, Sebastian Andrzej Siewior wrote:
> if during "ifconfig up" we run out of mem we continue regardless how
> many skbs we got. In worst case we have zero RX skbs and can't ever
> receive further packets since the RX skbs are never reallocated. If
> cpdma_chan_submit() fails we even leak the skb.
> This patch changes the behavior here:
> If we fail to allocate an skb during bring up we don't continue and
> report that error. Same goes for errors from cpdma_chan_submit().
> While here I changed to __netdev_alloc_skb_ip_align() so GFP_KERNEL can
> be used.
>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   16 +++++++++++-----
>   1 file changed, 11 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index e2ba702..3b22a36 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -912,14 +912,16 @@ static int cpsw_ndo_open(struct net_device *ndev)
>   			struct sk_buff *skb;
>   
>   			ret = -ENOMEM;
> -			skb = netdev_alloc_skb_ip_align(priv->ndev,
> -							priv->rx_packet_max);
> +			skb = __netdev_alloc_skb_ip_align(priv->ndev,
> +					priv->rx_packet_max, GFP_KERNEL);
>   			if (!skb)
> -				break;
> +				goto err_cleanup;
>   			ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
>   					skb_tailroom(skb), 0, GFP_KERNEL);
> -			if (WARN_ON(ret < 0))
> -				break;
> +			if (ret < 0) {
> +				kfree_skb(skb);
> +				goto err_cleanup;
Why you need to close the device even you have some skb allocated and
submitted successfully. Can allow the device to continue with lower
performance
> +			}
>   		}
>   		/* continue even if we didn't manage to submit all
>   		 * receive descs
> @@ -944,6 +946,10 @@ static int cpsw_ndo_open(struct net_device *ndev)
>   	if (priv->data.dual_emac)
>   		priv->slaves[priv->emac_port].open_stat = true;
>   	return 0;
> +
> +err_cleanup:
> +	cpdma_ctlr_stop(priv->dma);
> +	return ret;
>   }
only cpdma is halted and allocated skb are released, need to have other
calls like pm_runtime_put_sync, close host and slave ports

Regards
Mugunthan V N

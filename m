From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/5] net: sh_eth: use NAPI
Date: Tue, 12 Jun 2012 07:48:35 +0200
Message-ID: <1339480115.22704.20.camel@edumazet-glaptop>
References: <4FD6D154.1000000@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47290 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338Ab2FLFsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 01:48:41 -0400
In-Reply-To: <4FD6D154.1000000@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-12 at 14:19 +0900, Shimoda, Yoshihiro wrote:
> This patch modifies the driver to use NAPI.
> 

...

> +static int sh_eth_poll(struct napi_struct *napi, int budget)
> +{
> +	struct sh_eth_private *mdp = container_of(napi, struct sh_eth_private,
> +						  napi);
> +	struct net_device *ndev = mdp->ndev;
> +	struct sh_eth_cpu_data *cd = mdp->cd;
> +	int work_done = 0, txfree_num;
> +	u32 intr_status = sh_eth_read(ndev, EESR);
> +
> +	/* Clear interrupt flags */
> +	sh_eth_write(ndev, intr_status, EESR);
> +
> +	/* check txdesc */
> +	txfree_num = sh_eth_txfree(ndev);
> +	if (txfree_num) {
> +		netif_tx_lock(ndev);
> +		if (netif_queue_stopped(ndev))
> +			netif_wake_queue(ndev);
> +		netif_tx_unlock(ndev);
>  	}

...

> @@ -1678,19 +1707,6 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	struct sh_eth_private *mdp = netdev_priv(ndev);
>  	struct sh_eth_txdesc *txdesc;
>  	u32 entry;
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&mdp->lock, flags);
> -	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
> -		if (!sh_eth_txfree(ndev)) {
> -			if (netif_msg_tx_queued(mdp))
> -				dev_warn(&ndev->dev, "TxFD exhausted.\n");
> -			netif_stop_queue(ndev);
> -			spin_unlock_irqrestore(&mdp->lock, flags);
> -			return NETDEV_TX_BUSY;
> -		}
> -	}
> -	spin_unlock_irqrestore(&mdp->lock, flags);
> 
>  	entry = mdp->cur_tx % mdp->num_tx_ring;
>  	mdp->tx_skbuff[entry] = skb;
> @@ -1716,6 +1732,13 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	if (!(sh_eth_read(ndev, EDTRR) & sh_eth_get_edtrr_trns(mdp)))
>  		sh_eth_write(ndev, sh_eth_get_edtrr_trns(mdp), EDTRR);
> 
> +	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
> +		if (netif_msg_tx_queued(mdp)) {
> +			dev_warn(&ndev->dev, "TxFD exhausted.\n");
> +			netif_stop_queue(ndev);
> +		}
> +	}
> +
>  	return NETDEV_TX_OK;
>  }


I have no idea why you call netif_stop_queue() only if
netif_msg_tx_queued(mdp)

You should test your driver under heavy TX load.

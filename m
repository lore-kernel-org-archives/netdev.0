From: Michael Niewoehner <linux@mniewoehner.de>
Subject: Re: [PATCH RESEND] ethernet:arc: Move arc_emac_tx_clean() into arc_emac_tx() and disable tx interrut
Date: Fri, 19 Feb 2016 12:13:56 +0100
Message-ID: <85B47C95-B524-4A25-90C7-95AE614AB3A2@mniewoehner.de>
References: <BLU436-SMTP169C63F9B677DE7B0A77CF38FA00@phx.gbl>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: caesar.upstream@gmail.com, heiko@sntech.de, davem@davemloft.net,
	zhengxing@rock-chips.com, netdev@vger.kernel.org,
	linux-rockchip@lists.infradead.org
To: Shuyu Wei <sy.w@outlook.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender163-mail.zoho.com ([74.201.84.163]:25504 "EHLO
	sender163-mail.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425751AbcBSLOJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 06:14:09 -0500
In-Reply-To: <BLU436-SMTP169C63F9B677DE7B0A77CF38FA00@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 19.02.2016 um 07:59 schrieb Shuyu Wei <sy.w@outlook.com>:

> Doing tx_clean() inside poll() may scramble the tx ring buffer if 
> tx() is running. This will cause tx to stop working, which can be
> reproduced by simultaneously downloading two large files at high speed.
> 
> Moving tx_clean() into tx() will prevent this. And tx interrupt is no
> longer needed now.
> 
> Signed-off-by: Shuyu Wei <sy.w@outlook.com>

Tested-by: Michael Niewoehner <linux@mniewoehner.de>

> ---
> 
> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> index abe1eab..34531b3 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -311,12 +311,10 @@ static int arc_emac_poll(struct napi_struct *napi, int budget)
> 	struct arc_emac_priv *priv = netdev_priv(ndev);
> 	unsigned int work_done;
> 
> -	arc_emac_tx_clean(ndev);
> -
> 	work_done = arc_emac_rx(ndev, budget);
> 	if (work_done < budget) {
> 		napi_complete(napi);
> -		arc_reg_or(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
> +		arc_reg_or(priv, R_ENABLE, RXINT_MASK);
> 	}
> 
> 	return work_done;
> @@ -345,9 +343,9 @@ static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
> 	/* Reset all flags except "MDIO complete" */
> 	arc_reg_set(priv, R_STATUS, status);
> 
> -	if (status & (RXINT_MASK | TXINT_MASK)) {
> +	if (status & RXINT_MASK) {
> 		if (likely(napi_schedule_prep(&priv->napi))) {
> -			arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
> +			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
> 			__napi_schedule(&priv->napi);
> 		}
> 	}
> @@ -458,7 +456,7 @@ static int arc_emac_open(struct net_device *ndev)
> 	arc_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
> 
> 	/* Enable interrupts */
> -	arc_reg_set(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
> +	arc_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
> 
> 	/* Set CONTROL */
> 	arc_reg_set(priv, R_CTRL,
> @@ -529,7 +527,7 @@ static int arc_emac_stop(struct net_device *ndev)
> 	netif_stop_queue(ndev);
> 
> 	/* Disable interrupts */
> -	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
> +	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
> 
> 	/* Disable EMAC */
> 	arc_reg_clr(priv, R_CTRL, EN_MASK);
> @@ -587,6 +585,8 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
> 	__le32 *info = &priv->txbd[*txbd_curr].info;
> 	dma_addr_t addr;
> 
> +	arc_emac_tx_clean(ndev);
> +
> 	if (skb_padto(skb, ETH_ZLEN))
> 		return NETDEV_TX_OK;
> 
> 
> _______________________________________________
> Linux-rockchip mailing list
> Linux-rockchip@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-rockchip

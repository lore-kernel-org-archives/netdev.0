From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v4 6/6] net: sh_eth: use NAPI
Date: Thu, 17 May 2012 12:33:08 +0200
Message-ID: <20120517103308.GA15830@electric-eye.fr.zoreil.com>
References: <4FB32D17.30404@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52080 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751591Ab2EQKkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 06:40:20 -0400
Content-Disposition: inline
In-Reply-To: <4FB32D17.30404@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shimoda, Yoshihiro <yoshihiro.shimoda.uh@renesas.com> :
[...]
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index c64a31c..edc7dfe 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
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

[...]
> @@ -1678,19 +1710,15 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	struct sh_eth_private *mdp = netdev_priv(ndev);
>  	struct sh_eth_txdesc *txdesc;
>  	u32 entry;
> -	unsigned long flags;
> 
> -	spin_lock_irqsave(&mdp->lock, flags);
>  	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
>  		if (!sh_eth_txfree(ndev)) {

There are now two racing sh_eth_txfree and there is no [PATCH v4 7/6].

If I may suggest a slightly different approach, I would apply the patch
below before anything NAPI related:

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index d63e09b..6d77462 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1495,18 +1495,6 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	u32 entry;
 	unsigned long flags;
 
-	spin_lock_irqsave(&mdp->lock, flags);
-	if ((mdp->cur_tx - mdp->dirty_tx) >= (TX_RING_SIZE - 4)) {
-		if (!sh_eth_txfree(ndev)) {
-			if (netif_msg_tx_queued(mdp))
-				dev_warn(&ndev->dev, "TxFD exhausted.\n");
-			netif_stop_queue(ndev);
-			spin_unlock_irqrestore(&mdp->lock, flags);
-			return NETDEV_TX_BUSY;
-		}
-	}
-	spin_unlock_irqrestore(&mdp->lock, flags);
-
 	entry = mdp->cur_tx % TX_RING_SIZE;
 	mdp->tx_skbuff[entry] = skb;
 	txdesc = &mdp->tx_ring[entry];
@@ -1531,6 +1519,15 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (!(sh_eth_read(ndev, EDTRR) & sh_eth_get_edtrr_trns(mdp)))
 		sh_eth_write(ndev, sh_eth_get_edtrr_trns(mdp), EDTRR);
 
+	spin_lock_irqsave(&mdp->lock, flags);
+	if ((mdp->cur_tx - mdp->dirty_tx) >= (TX_RING_SIZE - 4)) {
+		if (netif_msg_tx_queued(mdp)) {
+			dev_warn(&ndev->dev, "TxFD exhausted.\n");
+			netif_stop_queue(ndev);
+		}
+	}
+	spin_unlock_irqrestore(&mdp->lock, flags);
+
 	return NETDEV_TX_OK;
 }
 

Rationale: the driver does not need to return NETDEV_TX_BUSY when it
should signal that it will not handle more packets after the current
one. You may add an extra assertion at the start of sh_eth_start_xmit()
and return NETDEV_TX_BUSY but it should be understood as a debug / bug
helper only.

Then you can convert to a {start/stop} queue race free NAPI with adequate
barriers.

-- 
Ueimor

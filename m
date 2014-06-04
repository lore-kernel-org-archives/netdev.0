From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 1/6] net: fec: Factorize the .xmit transmit function
Date: Wed, 4 Jun 2014 09:24:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17256FA7@AcuExch.aculab.com>
References: <1401867571-11684-1-git-send-email-b38611@freescale.com>
 <1401867571-11684-2-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"R49496@freescale.com" <R49496@freescale.com>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"b20596@freescale.com" <b20596@freescale.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: 'Fugang Duan' <b38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53075 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751873AbaFDJZL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 05:25:11 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32439-04 for <netdev@vger.kernel.org>;
 Wed,  4 Jun 2014 10:25:00 +0100 (BST)
In-Reply-To: <1401867571-11684-2-git-send-email-b38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan 
> Make the code more readable and easy to support other features like
> SG, TSO, moving the common transmit function to one api.
>
> And the patch also factorize the getting BD index to it own function.

Except that you seem to have added additional conditional clauses
into the common code paths.

	David

> Signed-off-by: Fugang Duan <B38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |   87 ++++++++++++++++++-----------
>  1 files changed, 54 insertions(+), 33 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 802be17..32c2276 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -287,6 +287,25 @@ struct bufdesc *fec_enet_get_prevdesc(struct bufdesc *bdp, struct fec_enet_priva
>  		return (new_bd < base) ? (new_bd + ring_size) : new_bd;
>  }
> 
> +static inline
> +int fec_enet_get_bd_index(struct bufdesc *bdp, struct fec_enet_private *fep)
> +{
> +	struct bufdesc *base;
> +	int index;
> +
> +	if (bdp >= fep->tx_bd_base)
> +		base = fep->tx_bd_base;
> +	else
> +		base = fep->rx_bd_base;
> +
> +	if (fep->bufdesc_ex)
> +		index = (struct bufdesc_ex *)bdp - (struct bufdesc_ex *)base;
> +	else
> +		index = bdp - base;
> +
> +	return index;
> +}
> +
>  static void *swap_buffer(void *bufaddr, int len)
>  {
>  	int i;
> @@ -313,8 +332,7 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
>  	return 0;
>  }
> 
> -static netdev_tx_t
> -fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +static int txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
>  {
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	const struct platform_device_id *id_entry =
> @@ -329,14 +347,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> 
>  	status = bdp->cbd_sc;
> 
> -	if (status & BD_ENET_TX_READY) {
> -		/* Ooops.  All transmit buffers are full.  Bail out.
> -		 * This should not happen, since ndev->tbusy should be set.
> -		 */
> -		netdev_err(ndev, "tx queue full!\n");
> -		return NETDEV_TX_BUSY;
> -	}
> -
>  	/* Protocol checksum off-load for TCP and UDP. */
>  	if (fec_enet_clear_csum(skb, ndev)) {
>  		dev_kfree_skb_any(skb);
> @@ -350,16 +360,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	bufaddr = skb->data;
>  	bdp->cbd_datlen = skb->len;
> 
> -	/*
> -	 * On some FEC implementations data must be aligned on
> -	 * 4-byte boundaries. Use bounce buffers to copy data
> -	 * and get it aligned. Ugh.
> -	 */
> -	if (fep->bufdesc_ex)
> -		index = (struct bufdesc_ex *)bdp -
> -			(struct bufdesc_ex *)fep->tx_bd_base;
> -	else
> -		index = bdp - fep->tx_bd_base;
> +	index = fec_enet_get_bd_index(bdp, fep);
> 
>  	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
>  		memcpy(fep->tx_bounce[index], skb->data, skb->len);
> @@ -433,15 +434,43 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> 
>  	fep->cur_tx = bdp;
> 
> -	if (fep->cur_tx == fep->dirty_tx)
> -		netif_stop_queue(ndev);
> -
>  	/* Trigger transmission start */
>  	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
> 
>  	return NETDEV_TX_OK;
>  }
> 
> +static netdev_tx_t
> +fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +	struct bufdesc *bdp;
> +	unsigned short	status;
> +	int ret;
> +
> +	/* Fill in a Tx ring entry */
> +	bdp = fep->cur_tx;
> +
> +	status = bdp->cbd_sc;
> +
> +	if (status & BD_ENET_TX_READY) {
> +		/* Ooops.  All transmit buffers are full.  Bail out.
> +		 * This should not happen, since ndev->tbusy should be set.
> +		 */
> +		netdev_err(ndev, "tx queue full!\n");
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	ret = txq_submit_skb(skb, ndev);
> +	if (ret == -EBUSY)
> +		return NETDEV_TX_BUSY;
> +
> +	if (fep->cur_tx == fep->dirty_tx)
> +		netif_stop_queue(ndev);
> +
> +	return NETDEV_TX_OK;
> +}
> +
>  /* Init RX & TX buffer descriptors
>   */
>  static void fec_enet_bd_init(struct net_device *dev)
> @@ -770,11 +799,7 @@ fec_enet_tx(struct net_device *ndev)
>  		if (bdp == fep->cur_tx)
>  			break;
> 
> -		if (fep->bufdesc_ex)
> -			index = (struct bufdesc_ex *)bdp -
> -				(struct bufdesc_ex *)fep->tx_bd_base;
> -		else
> -			index = bdp - fep->tx_bd_base;
> +		index = fec_enet_get_bd_index(bdp, fep);
> 
>  		skb = fep->tx_skbuff[index];
>  		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr, skb->len,
> @@ -921,11 +946,7 @@ fec_enet_rx(struct net_device *ndev, int budget)
>  		pkt_len = bdp->cbd_datlen;
>  		ndev->stats.rx_bytes += pkt_len;
> 
> -		if (fep->bufdesc_ex)
> -			index = (struct bufdesc_ex *)bdp -
> -				(struct bufdesc_ex *)fep->rx_bd_base;
> -		else
> -			index = bdp - fep->rx_bd_base;
> +		index = fec_enet_get_bd_index(bdp, fep);
>  		data = fep->rx_skbuff[index]->data;
>  		dma_sync_single_for_cpu(&fep->pdev->dev, bdp->cbd_bufaddr,
>  					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
> --
> 1.7.8

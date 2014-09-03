From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [Patch net-next 03/11] net:fec: use multiqueue interface to allocate
 Ethernet device
Date: Wed, 03 Sep 2014 14:20:14 -0700
Message-ID: <5407860E.1030709@gmail.com>
References: <1409776697-1536-1-git-send-email-Frank.Li@freescale.com> <1409776697-1536-4-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org
To: Frank Li <Frank.Li@freescale.com>, b38611@freescale.com,
	davem@davemloft.net, netdev@vger.kernel.org, lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:50354 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756518AbaICVUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 17:20:54 -0400
In-Reply-To: <1409776697-1536-4-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2014 01:38 PM, Frank Li wrote:
> From: Fugang Duan <B38611@freescale.com>
> 
> Since i.MX6SX enet-AVB IP support multi queues, so use multi queues
> interface to allocate and set up an Ethernet device.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec.h      |  9 ++++++
>  drivers/net/ethernet/freescale/fec_main.c | 49 ++++++++++++++++++++++++++++++-
>  2 files changed, 57 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
> index 635772b..f77ed6f 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -233,6 +233,13 @@ struct bufdesc_ex {
>  /* This device has up to three irqs on some platforms */
>  #define FEC_IRQ_NUM		3
>  
> +/* Maximum number of queues supported
> + * ENET with AVB IP can support up to 3 independent tx queues and rx queues.
> + * User can point the queue number that is less than or equal to 3.
> + */
> +#define FEC_ENET_MAX_TX_QS	3
> +#define FEC_ENET_MAX_RX_QS	3
> +
>  /* The number of Tx and Rx buffers.  These are allocated from the page
>   * pool.  The code may assume these are power of two, so it it best
>   * to keep them that size.
> @@ -278,6 +285,8 @@ struct fec_enet_private {
>  
>  	bool ptp_clk_on;
>  	struct mutex ptp_clk_mutex;
> +	int num_tx_queues;
> +	int num_rx_queues;

unsigned int.

>  
>  	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
>  	unsigned char *tx_bounce[TX_RING_SIZE];
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index ee9f04f..00fcadd 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -2573,6 +2573,39 @@ static void fec_reset_phy(struct platform_device *pdev)
>  #endif /* CONFIG_OF */
>  
>  static int
> +fec_enet_get_queue_num(struct platform_device *pdev, int *num_tx, int *num_rx)
> +{
> +	struct device_node *np = pdev->dev.of_node;
> +	int err;
> +
> +	if (!np || !of_device_is_available(np))
> +		return -ENODEV;

This effectively breaks non-DT platform probing, is that intentional?
How about assining *num_tx and *num_rx to 1, and if you find the
property, use it?

> +
> +	/* parse the num of tx and rx queues */
> +	err = of_property_read_u32(np, "fsl,num_tx_queues", num_tx);
> +	err |= of_property_read_u32(np, "fsl,num_rx_queues", num_rx);
> +	if (err) {
> +		*num_tx = 1;
> +		*num_rx = 1;
> +		return 0;
> +	}
> +
> +	if (*num_tx < 1 || *num_tx > FEC_ENET_MAX_TX_QS) {
> +		dev_err(&pdev->dev, "num_tx(=%d) greater than MAX_TX_QS(=%d)\n",
> +			*num_tx, FEC_ENET_MAX_TX_QS);
> +		return -EINVAL;
> +	}

You are dealing with two error conditions here, *num_tx == 0 and *num_tx
> FEC_ENET_MAX_TX_QS, so the message should not be "greater than"

> +
> +	if (*num_rx < 1 || *num_rx > FEC_ENET_MAX_RX_QS) {
> +		dev_err(&pdev->dev, "num_rx(=%d) greater than MAX_RX_QS(=%d)\n",
> +			*num_rx, FEC_ENET_MAX_RX_QS);
> +		return -EINVAL;
> +	}

Same here.

> +
> +	return 0;
> +}
> +
> +static int
>  fec_probe(struct platform_device *pdev)
>  {
>  	struct fec_enet_private *fep;
> @@ -2583,13 +2616,23 @@ fec_probe(struct platform_device *pdev)
>  	const struct of_device_id *of_id;
>  	static int dev_id;
>  	struct device_node *np = pdev->dev.of_node, *phy_node;
> +	int num_tx_qs = 1;
> +	int num_rx_qs = 1;
>  
>  	of_id = of_match_device(fec_dt_ids, &pdev->dev);
>  	if (of_id)
>  		pdev->id_entry = of_id->data;
>  
> +	if (pdev->id_entry &&
> +	    (pdev->id_entry->driver_data & FEC_QUIRK_HAS_AVB)) {
> +		ret = fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
> +		if (ret)
> +			return ret;
> +	}

This should be made a void function in order no to break non-DT probing
as mentioned before.

> +
>  	/* Init network device */
> -	ndev = alloc_etherdev(sizeof(struct fec_enet_private));
> +	ndev = alloc_etherdev_mqs(sizeof(struct fec_enet_private),
> +				  num_tx_qs, num_rx_qs);
>  	if (!ndev)
>  		return -ENOMEM;
>  
> @@ -2598,6 +2641,10 @@ fec_probe(struct platform_device *pdev)
>  	/* setup board info structure */
>  	fep = netdev_priv(ndev);
>  
> +	fep->num_rx_queues = num_rx_qs;
> +	fep->num_tx_queues = num_tx_qs;
> +	netif_set_real_num_rx_queues(ndev, num_rx_qs);

How about netif_set_real_num_tx_queues? This is probably useless anyway
because you already allocated this network device with the correct
(supposedly) number of TX and RX queues coming from the platform
configuration data.

> +
>  #if !defined(CONFIG_M5272)
>  	/* default enable pause frame auto negotiation */
>  	if (pdev->id_entry &&
> 

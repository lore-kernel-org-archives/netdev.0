From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC net-next] ravb: Add dma_unmap_single in ravb_ring_free
Date: Wed, 9 Nov 2016 21:00:25 +0300
Message-ID: <7e499a0f-3c98-420e-de8a-b29bd54a989d@cogentembedded.com>
References: <1478532451-7296-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:35849 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbcKISA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:00:29 -0500
Received: by mail-lf0-f48.google.com with SMTP id t196so171037123lff.3
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 10:00:28 -0800 (PST)
In-Reply-To: <1478532451-7296-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/07/2016 06:27 PM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> The kernel panic occurs with "swiotlb buffer is full" message
> after repeating suspend and resume, because dma_map_single of
> ravb_ring_format and ravb_start_xmit is not released.

    The same issue must occur after several ifconfig up/down I think...
this is quite embarrassing actually, and I think this bug was inherited from 
sh_eth. Perhaps it was made more visible with adding PM support. :-/

> This patch adds dma_unmap_single in ravb_ring_free, and fixes
> its problem.

    Well, actually ravb_ring_free() was meant to undo what ravb_ring_init() 
does...

> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> ---
> Sergei, this is a patch from the Gen3 3.3.2 BSP.

    I suspect the ravb driver there is greatly different from the upstream one...

> Please consider if it is appropriate for mainline.
> ---
>  drivers/net/ethernet/renesas/ravb_main.c | 23 +++++++++++++++++++++++
>  1 file changed, 23 insertions(+)
>
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 27cfec3154c8..e44629b75c83 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -185,6 +185,9 @@ static void ravb_ring_free(struct net_device *ndev, int q)
>  	struct ravb_private *priv = netdev_priv(ndev);
>  	int ring_size;
>  	int i;
> +	struct ravb_ex_rx_desc *rx_desc;
> +	struct ravb_tx_desc *tx_desc;
> +	u32 size;

    DaveM prefers the local declarations in the reverse Xmas tree order; me 
too. :-)

[...]
> @@ -207,6 +210,16 @@ static void ravb_ring_free(struct net_device *ndev, int q)
>  	priv->tx_align[q] = NULL;
>
>  	if (priv->rx_ring[q]) {
> +		for (i = 0; i < priv->num_rx_ring[q]; i++) {
> +			rx_desc = &priv->rx_ring[q][i];
> +			if (rx_desc->dptr != 0) {

    This seems wrong. This driver uses RX descriptors with zero data size to 
indicate the failed DMA mapping. And anyway, I think you should have used 
dma_mapping_error() instead of a zero check... and '!= 0' was unnecessary.

> +				dma_unmap_single(ndev->dev.parent,
> +						 le32_to_cpu(rx_desc->dptr),
> +						 PKT_BUF_SZ,
> +						 DMA_FROM_DEVICE);
> +				rx_desc->dptr = 0;

    Hence I'd prefer:

				rx_desc->ds_cc = cpu_to_le16(0);

[...]
> @@ -215,6 +228,16 @@ static void ravb_ring_free(struct net_device *ndev, int q)
>  	}
>
>  	if (priv->tx_ring[q]) {
> +		for (i = 0; i < priv->num_tx_ring[q]; i++) {

    I'm afraid this is wrong. TX ring contains NUM_TX_DESC (2) descriptors per 
skb, so this loop only cleans the 1st half of the TX ring.

> +			tx_desc = &priv->tx_ring[q][i];
> +			size = le16_to_cpu(tx_desc->ds_tagl) & TX_DS;
> +			if (tx_desc->dptr != 0) {
> +				dma_unmap_single(ndev->dev.parent,
> +						 le32_to_cpu(tx_desc->dptr),
> +						 size, DMA_TO_DEVICE);
> +				tx_desc->dptr = 0;

    Again, I'm not fond of this... are you sure 0 is incorrect DMA address?

> +			}
> +		}

    BTW, can't we use ravb_tx_free() instead of this loop?

MBR, Sergei

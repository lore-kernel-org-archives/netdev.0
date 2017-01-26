From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 net] ravb: unmap descriptors when freeing rings
Date: Thu, 26 Jan 2017 15:58:45 +0300
Message-ID: <d6a3fdea-1934-3983-6897-0b203dea51df@cogentembedded.com>
References: <1485428699-2598-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
To: Simon Horman <horms+renesas@verge.net.au>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34532 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdAZM6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 07:58:49 -0500
Received: by mail-lf0-f50.google.com with SMTP id v186so145045690lfa.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 04:58:48 -0800 (PST)
In-Reply-To: <1485428699-2598-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2017 02:04 PM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> "swiotlb buffer is full" errors occur after repeated initialisation of a
> device - f.e. suspend/resume or ip link set up/down. This is because memory
> mapped using dma_map_single() in ravb_ring_format() and ravb_start_xmit()
> is not released.  Resolve this problem by unmapping descriptors when
> freeing rings.
>
> Fixes: a780893c89f6 ("ravb: unmap descriptors when freeing rings")

    No such SHA1 hash known and the summary is from this patch.

> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> [simon: reworked]
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> --
>
> On inspection it appears that a similar problem is also present in
> the SH-Ethernet driver.
>
> v4 [Simon Horman]
> * As suggested by Sergei Shtylyov
>   - Use bool as type for new parameter to ravb_tx_free()
>   - Clean up comment style
>   - Only increment tx_bytes for transmitted skbs
>
> v3 [Simon Horman]
> * As suggested by Sergei Shtylyov
>   - consistently use le32_to_cpu(desc->dptr)
>   - Do not clear desc->ds_cc as it is not used
> * Paramatise ravb_tx_free() to allow it to free non-transmitted buffers
>
> v2 [Simon Horman]
> * As suggested by Sergei Shtylyov
>   - Use dma_mapping_error() and rx_desc->ds_cc when unmapping RX descriptors;
>     this is consistent with the way that they are mapped
>   - Use ravb_tx_free() to clear TX descriptors
> * Reduce scope of new local variable
>
> v1 [Kazuya Mizuguchi]
> ---
>  drivers/net/ethernet/renesas/ravb_main.c | 111 ++++++++++++++++++-------------
>  1 file changed, 63 insertions(+), 48 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 89ac1e3f6175..5d66ac721335 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -179,6 +179,48 @@ static struct mdiobb_ops bb_ops = {
>  	.get_mdio_data = ravb_get_mdio_data,
>  };
>
> +/* Free TX skb function for AVB-IP */
> +static int ravb_tx_free(struct net_device *ndev, int q, bool free_txed_only)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &priv->stats[q];
> +	struct ravb_tx_desc *desc;
> +	int free_num = 0;
> +	int entry;
> +	u32 size;
> +
> +	for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
> +		bool txed;
> +
> +		entry = priv->dirty_tx[q] % (priv->num_tx_ring[q] *
> +					     NUM_TX_DESC);
> +		desc = &priv->tx_ring[q][entry];
> +		txed = desc->die_dt == DT_FEMPTY;
> +		if (free_txed_only && !txed)
> +			break;
> +		/* Descriptor type must be checked before all other reads */
> +		dma_rmb();
> +		size = le16_to_cpu(desc->ds_tagl) & TX_DS;
> +		/* Free the original skb. */
> +		if (priv->tx_skb[q][entry / NUM_TX_DESC]) {
> +			dma_unmap_single(ndev->dev.parent, le32_to_cpu(desc->dptr),
> +					 size, DMA_TO_DEVICE);
> +			/* Last packet descriptor? */
> +			if (entry % NUM_TX_DESC == NUM_TX_DESC - 1) {
> +				entry /= NUM_TX_DESC;
> +				dev_kfree_skb_any(priv->tx_skb[q][entry]);
> +				priv->tx_skb[q][entry] = NULL;
> +				stats->tx_packets++;

    We're still incrementing the packet # even when the packet hasn't been sent...

> +			}
> +			free_num++;
> +		}
> +		if (!txed)

    Your logic is reversed! :-(

> +			stats->tx_bytes += size;
> +		desc->die_dt = DT_EEMPTY;
> +	}
> +	return free_num;
> +}
> +
>  /* Free skb's and DMA buffers for Ethernet AVB */
>  static void ravb_ring_free(struct net_device *ndev, int q)
>  {
> @@ -194,19 +236,21 @@ static void ravb_ring_free(struct net_device *ndev, int q)
[...]
>
>  	if (priv->rx_ring[q]) {
> +		for (i = 0; i < priv->num_rx_ring[q]; i++) {
> +			struct ravb_ex_rx_desc *desc = &priv->rx_ring[q][i];
> +
> +			if (!dma_mapping_error(ndev->dev.parent,
> +					       le32_to_cpu(desc->dptr)))

    I'd check for zero buffer length (that marks unmapped RX buffers) but this 
should be good too... it's just that the length check is shorter. :-)

> +				dma_unmap_single(ndev->dev.parent,
> +						 le32_to_cpu(desc->dptr),
> +						 PKT_BUF_SZ,
> +						 DMA_FROM_DEVICE);
> +		}
>  		ring_size = sizeof(struct ravb_ex_rx_desc) *
>  			    (priv->num_rx_ring[q] + 1);
>  		dma_free_coherent(ndev->dev.parent, ring_size, priv->rx_ring[q],
[...]

MBR, Sergei

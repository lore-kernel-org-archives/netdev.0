From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v3 net] ravb: unmap descriptors when freeing rings
Date: Wed, 25 Jan 2017 19:05:08 +0300
Message-ID: <db2a9c3a-6b99-769d-4fa2-2d52af631966@cogentembedded.com>
References: <1485282073-16662-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34547 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbdAYQFN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 11:05:13 -0500
Received: by mail-lf0-f54.google.com with SMTP id v186so131412198lfa.1
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 08:05:12 -0800 (PST)
In-Reply-To: <1485282073-16662-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/24/2017 09:21 PM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> "swiotlb buffer is full" errors occur after repeated initialisation of a
> device - f.e. suspend/resume or ip link set up/down. This is because memory
> mapped using dma_map_single() in ravb_ring_format() and ravb_start_xmit()
> is not released.  Resolve this problem by unmapping descriptors when
> freeing rings.
>
> Note, ravb_tx_free() is moved but not otherwise modified by this patch.
>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> [simon: reworked]
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> --
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
>  drivers/net/ethernet/renesas/ravb_main.c | 113 ++++++++++++++++++-------------
>  1 file changed, 65 insertions(+), 48 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 89ac1e3f6175..57fe1411bb9d 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -179,6 +179,51 @@ static struct mdiobb_ops bb_ops = {
>  	.get_mdio_data = ravb_get_mdio_data,
>  };
>
> +enum ravb_tx_free_mode {
> +	ravb_tx_free_all,
> +	ravb_tx_free_txed_only,
> +};
> +
> +/* Free TX skb function for AVB-IP */
> +static int ravb_tx_free(struct net_device *ndev, int q,
> +			enum ravb_tx_free_mode free_mode)

    Hmm... Sorry but this looks over-engineered. A *bool* parameter (named e.g 
'all) would suffice IMHO.

> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &priv->stats[q];
> +	struct ravb_tx_desc *desc;
> +	int free_num = 0;
> +	int entry;
> +	u32 size;
> +
> +	for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
> +		entry = priv->dirty_tx[q] % (priv->num_tx_ring[q] *
> +					     NUM_TX_DESC);
> +		desc = &priv->tx_ring[q][entry];
> +		if (free_mode == ravb_tx_free_txed_only &&
> +		    desc->die_dt != DT_FEMPTY)
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
> +			}
> +			free_num++;
> +		}
> +		stats->tx_bytes += size;

    Hmmm... we shouldn't count the discarded unsent packets/bytes as sent, right?

[...]
> @@ -215,12 +262,19 @@ static void ravb_ring_free(struct net_device *ndev, int q)
>  	}
>
>  	if (priv->tx_ring[q]) {
> +		ravb_tx_free(ndev, q, ravb_tx_free_all);
> +
>  		ring_size = sizeof(struct ravb_tx_desc) *
>  			    (priv->num_tx_ring[q] * NUM_TX_DESC + 1);
>  		dma_free_coherent(ndev->dev.parent, ring_size, priv->tx_ring[q],
>  				  priv->tx_desc_dma[q]);
>  		priv->tx_ring[q] = NULL;
>  	}
> +
> +	/* Free TX skb ringbuffer.
> +	 * SKBs are freed by ravb_tx_free() call above. */

    This is not a recommended comment format:

/* bla
  * bla
  */

[...]

MBR, Sergei

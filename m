From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/3] sh_eth: Fix dma mapping issue
Date: Fri, 14 Nov 2014 02:05:44 +0300
Message-ID: <54653948.5070606@cogentembedded.com>
References: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com> <1415862301-28032-4-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1415862301-28032-4-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2014 10:05 AM, Yoshihiro Kaneko wrote:

> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>

> When CONFIG_DMA_API_DEBUG=y, many DMA error messages reports.
> In order to use DMA debug, This patch fix following issues.

> Issue 1:
> If dma_mapping_error function is not called appropriately after
> DMA mapping, DMA debug will report error message when DMA unmap
> function is called.

> Issue 2:
> If skb_reserve function is called after DMA mapping, the relationship
> between mapping addr and mapping size will be broken.
> In this case, DMA debug will report error messages when DMA sync
> function and DMA unmap function are called.

> Issue 3:
> If the size of frame data is less than ETH_ZLEN, the size is resized
> to ETH_ZLEN after DMA map function is called.
> In the TX skb freeing function, dma unmap function is called with that
> resized value. So, unmap size error will reported.

> Issue 4:
> In the rx function, DMA map function is called without DMA unmap function
> is called for RX skb reallocating.
> It will case the DMA debug error that number of debug entry is full and
> DMA debug logic is stopped.

    The rule of thumb is "fix one issue per patch". Please split accordingly.

> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

    Thanks for beating me to it. Fixing these issues has been on my agenda for 
a long time... :-)

> ---
>   drivers/net/ethernet/renesas/sh_eth.c | 26 +++++++++++++++++++++++---
>   1 file changed, 23 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 0e4a407..23318cf 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1136,6 +1136,11 @@ static void sh_eth_ring_format(struct net_device *ndev)
>   		dma_map_single(&ndev->dev, skb->data, rxdesc->buffer_length,
>   			       DMA_FROM_DEVICE);
>   		rxdesc->addr = virt_to_phys(skb->data);

    Can't we get rid of these bogus virt_to_phys() calls, while at it? 
dma_map_single() returns a DMA address, no?

> +		if (dma_mapping_error(&ndev->dev, rxdesc->addr)) {
> +			dev_kfree_skb(mdp->rx_skbuff[i]);
> +			mdp->rx_skbuff[i] = NULL;
> +			break;
> +		}
>   		rxdesc->status = cpu_to_edmac(mdp, RD_RACT | RD_RFP);
>
>   		/* Rx descriptor address set */
> @@ -1364,7 +1369,7 @@ static int sh_eth_txfree(struct net_device *ndev)
>   		if (mdp->tx_skbuff[entry]) {
>   			dma_unmap_single(&ndev->dev, txdesc->addr,
>   					 txdesc->buffer_length, DMA_TO_DEVICE);
> -			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
> +			dev_kfree_skb_any(mdp->tx_skbuff[entry]);

    Hm, I'm not sure where is this described in the changelog...

>   			mdp->tx_skbuff[entry] = NULL;
>   			free_num++;
>   		}
> @@ -1466,11 +1471,19 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
>   			if (skb == NULL)
>   				break;	/* Better luck next round. */
>   			sh_eth_set_receive_align(skb);
> +			dma_unmap_single(&ndev->dev, rxdesc->addr,
> +					 rxdesc->buffer_length,
> +					 DMA_FROM_DEVICE);
>   			dma_map_single(&ndev->dev, skb->data,
>   				       rxdesc->buffer_length, DMA_FROM_DEVICE);
>
>   			skb_checksum_none_assert(skb);
>   			rxdesc->addr = virt_to_phys(skb->data);

    Likewise, can we get rid of this bogu?

> +			if (dma_mapping_error(&ndev->dev, rxdesc->addr)) {
> +				dev_kfree_skb_any(mdp->rx_skbuff[entry]);
> +				mdp->rx_skbuff[entry] = NULL;
> +				break;
> +			}
>   		}
>   		if (entry >= mdp->num_rx_ring - 1)
>   			rxdesc->status |=
> @@ -2104,12 +2117,18 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>   	if (!mdp->cd->hw_swap)
>   		sh_eth_soft_swap(phys_to_virt(ALIGN(txdesc->addr, 4)),
>   				 skb->len + 2);
> -	txdesc->addr = dma_map_single(&ndev->dev, skb->data, skb->len,
> -				      DMA_TO_DEVICE);
>   	if (skb->len < ETH_ZLEN)
>   		txdesc->buffer_length = ETH_ZLEN;
>   	else
>   		txdesc->buffer_length = skb->len;
> +	txdesc->addr = dma_map_single(&ndev->dev, skb->data,
> +				      txdesc->buffer_length,
> +				      DMA_TO_DEVICE);
> +	if (dma_mapping_error(&ndev->dev, txdesc->addr)) {
> +		dev_kfree_skb_any(mdp->tx_skbuff[entry]);
> +		mdp->tx_skbuff[entry] = NULL;
> +		goto out;

    Why not just *return*?!

[...]

WBR, Sergei


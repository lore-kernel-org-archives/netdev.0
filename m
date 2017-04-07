From: Nicolas Ferre <nicolas.ferre@microchip.com>
Subject: Re: [PATCH net-next 05/14] net: macb: Use net_device_stats from
 struct net_device
Date: Fri, 7 Apr 2017 10:29:34 +0200
Message-ID: <06673f1b-60d3-9749-c3cb-f35d9579a98f@microchip.com>
References: <20170407081739.5243-1-tklauser@distanz.ch>
 <20170407081739.5243-6-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
To: Tobias Klauser <tklauser@distanz.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:54530 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754291AbdDGI3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 04:29:24 -0400
In-Reply-To: <20170407081739.5243-6-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/04/2017 à 10:17, Tobias Klauser a écrit :
> Instead of using a private copy of struct net_device_stats in struct
> macb, use stats from struct net_device.

I agree with the initiative but I read this in the documentation of this
struct member...

@stats:         Statistics struct, which was left as a legacy, use
                rtnl_link_stats64 instead

Is it still permitted to use it? Would it be to directly move to the
most up-to-date code?

Regards,


> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/cadence/macb.c | 40 ++++++++++++++++++-------------------
>  drivers/net/ethernet/cadence/macb.h |  1 -
>  2 files changed, 20 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 30606b11b128..5cbd1e7a926a 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -684,8 +684,8 @@ static void macb_tx_error_task(struct work_struct *work)
>  				netdev_vdbg(bp->dev, "txerr skb %u (data %p) TX complete\n",
>  					    macb_tx_ring_wrap(bp, tail),
>  					    skb->data);
> -				bp->stats.tx_packets++;
> -				bp->stats.tx_bytes += skb->len;
> +				bp->dev->stats.tx_packets++;
> +				bp->dev->stats.tx_bytes += skb->len;
>  			}
>  		} else {
>  			/* "Buffers exhausted mid-frame" errors may only happen
> @@ -778,8 +778,8 @@ static void macb_tx_interrupt(struct macb_queue *queue)
>  				netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
>  					    macb_tx_ring_wrap(bp, tail),
>  					    skb->data);
> -				bp->stats.tx_packets++;
> -				bp->stats.tx_bytes += skb->len;
> +				bp->dev->stats.tx_packets++;
> +				bp->dev->stats.tx_bytes += skb->len;
>  			}
>  
>  			/* Now we can safely release resources */
> @@ -911,14 +911,14 @@ static int gem_rx(struct macb *bp, int budget)
>  		if (!(ctrl & MACB_BIT(RX_SOF) && ctrl & MACB_BIT(RX_EOF))) {
>  			netdev_err(bp->dev,
>  				   "not whole frame pointed by descriptor\n");
> -			bp->stats.rx_dropped++;
> +			bp->dev->stats.rx_dropped++;
>  			break;
>  		}
>  		skb = bp->rx_skbuff[entry];
>  		if (unlikely(!skb)) {
>  			netdev_err(bp->dev,
>  				   "inconsistent Rx descriptor chain\n");
> -			bp->stats.rx_dropped++;
> +			bp->dev->stats.rx_dropped++;
>  			break;
>  		}
>  		/* now everything is ready for receiving packet */
> @@ -938,8 +938,8 @@ static int gem_rx(struct macb *bp, int budget)
>  		    GEM_BFEXT(RX_CSUM, ctrl) & GEM_RX_CSUM_CHECKED_MASK)
>  			skb->ip_summed = CHECKSUM_UNNECESSARY;
>  
> -		bp->stats.rx_packets++;
> -		bp->stats.rx_bytes += skb->len;
> +		bp->dev->stats.rx_packets++;
> +		bp->dev->stats.rx_bytes += skb->len;
>  
>  #if defined(DEBUG) && defined(VERBOSE_DEBUG)
>  		netdev_vdbg(bp->dev, "received skb of length %u, csum: %08x\n",
> @@ -984,7 +984,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
>  	 */
>  	skb = netdev_alloc_skb(bp->dev, len + NET_IP_ALIGN);
>  	if (!skb) {
> -		bp->stats.rx_dropped++;
> +		bp->dev->stats.rx_dropped++;
>  		for (frag = first_frag; ; frag++) {
>  			desc = macb_rx_desc(bp, frag);
>  			desc->addr &= ~MACB_BIT(RX_USED);
> @@ -1030,8 +1030,8 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
>  	__skb_pull(skb, NET_IP_ALIGN);
>  	skb->protocol = eth_type_trans(skb, bp->dev);
>  
> -	bp->stats.rx_packets++;
> -	bp->stats.rx_bytes += skb->len;
> +	bp->dev->stats.rx_packets++;
> +	bp->dev->stats.rx_bytes += skb->len;
>  	netdev_vdbg(bp->dev, "received skb of length %u, csum: %08x\n",
>  		    skb->len, skb->csum);
>  	netif_receive_skb(skb);
> @@ -2210,7 +2210,7 @@ static void gem_update_stats(struct macb *bp)
>  static struct net_device_stats *gem_get_stats(struct macb *bp)
>  {
>  	struct gem_stats *hwstat = &bp->hw_stats.gem;
> -	struct net_device_stats *nstat = &bp->stats;
> +	struct net_device_stats *nstat = &bp->dev->stats;
>  
>  	gem_update_stats(bp);
>  
> @@ -2281,7 +2281,7 @@ static void gem_get_ethtool_strings(struct net_device *dev, u32 sset, u8 *p)
>  static struct net_device_stats *macb_get_stats(struct net_device *dev)
>  {
>  	struct macb *bp = netdev_priv(dev);
> -	struct net_device_stats *nstat = &bp->stats;
> +	struct net_device_stats *nstat = &bp->dev->stats;
>  	struct macb_stats *hwstat = &bp->hw_stats.macb;
>  
>  	if (macb_is_gem(bp))
> @@ -2993,15 +2993,15 @@ static void at91ether_rx(struct net_device *dev)
>  			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
>  
>  			skb->protocol = eth_type_trans(skb, dev);
> -			lp->stats.rx_packets++;
> -			lp->stats.rx_bytes += pktlen;
> +			dev->stats.rx_packets++;
> +			dev->stats.rx_bytes += pktlen;
>  			netif_rx(skb);
>  		} else {
> -			lp->stats.rx_dropped++;
> +			dev->stats.rx_dropped++;
>  		}
>  
>  		if (desc->ctrl & MACB_BIT(RX_MHASH_MATCH))
> -			lp->stats.multicast++;
> +			dev->stats.multicast++;
>  
>  		/* reset ownership bit */
>  		desc->addr &= ~MACB_BIT(RX_USED);
> @@ -3036,15 +3036,15 @@ static irqreturn_t at91ether_interrupt(int irq, void *dev_id)
>  	if (intstatus & MACB_BIT(TCOMP)) {
>  		/* The TCOM bit is set even if the transmission failed */
>  		if (intstatus & (MACB_BIT(ISR_TUND) | MACB_BIT(ISR_RLE)))
> -			lp->stats.tx_errors++;
> +			dev->stats.tx_errors++;
>  
>  		if (lp->skb) {
>  			dev_kfree_skb_irq(lp->skb);
>  			lp->skb = NULL;
>  			dma_unmap_single(NULL, lp->skb_physaddr,
>  					 lp->skb_length, DMA_TO_DEVICE);
> -			lp->stats.tx_packets++;
> -			lp->stats.tx_bytes += lp->skb_length;
> +			dev->stats.tx_packets++;
> +			dev->stats.tx_bytes += lp->skb_length;
>  		}
>  		netif_wake_queue(dev);
>  	}
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 234a49eaccfd..ec037b0fa2a4 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -919,7 +919,6 @@ struct macb {
>  	struct clk		*rx_clk;
>  	struct net_device	*dev;
>  	struct napi_struct	napi;
> -	struct net_device_stats	stats;
>  	union {
>  		struct macb_stats	macb;
>  		struct gem_stats	gem;
> 


-- 
Nicolas Ferre

From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Thu, 19 May 2016 00:55:29 +0200
Message-ID: <20160518225529.GA18671@electric-eye.fr.zoreil.com>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com>
 <573CD09D.1060307@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <573CD09D.1060307-Mmb7MZpHnFY@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org> :
[...]
> what about the (only compile tested) code below?

I may have misunderstood some parts but it nonetheless seems broken.

> The smp_wmb() in tx function combined with the smp_rmb() in tx_clean ensures
> that the CPU running tx_clean sees consistent values for info, data and skb 
> (thus no need to check for validity of all three values any more).
> The mb() fulfills several tasks:
> 1. makes sure that DMA writes to descriptor are completed before the HW is
>     informed.

"DMA writes" == "CPU writes" ?

> 2. On multi processor systems: ensures that txbd_curr is updated (this is paired
>     with the smp_mb() at the end of tx_clean).

Smells like using barrier side-effects to control smp coherency. It isn't
the recommended style.

> 3. Ensure we see the most recent value for tx_dirty. With this we do not have to
>     recheck after we stopped the tx queue.
> 
> 
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -162,8 +162,13 @@ static void arc_emac_tx_clean(struct net_device *ndev)
>  		struct sk_buff *skb = tx_buff->skb;
>  		unsigned int info = le32_to_cpu(txbd->info);
>  
> -		if ((info & FOR_EMAC) || !txbd->data || !skb)
> +		if (info & FOR_EMAC) {
> +			/* Make sure we see consistent values for info, skb
> +			 * and data.
> +			 */
> +			smp_rmb();
>  			break;
> +		}

?

smp_rmb should appear before the variables you want coherency for.

>  
>  		if (unlikely(info & (DROP | DEFR | LTCL | UFLO))) {
>  			stats->tx_errors++;
> @@ -679,36 +684,33 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
>  	dma_unmap_addr_set(&priv->tx_buff[*txbd_curr], addr, addr);
>  	dma_unmap_len_set(&priv->tx_buff[*txbd_curr], len, len);
>  
> -	priv->txbd[*txbd_curr].data = cpu_to_le32(addr);
>  
> -	/* Make sure pointer to data buffer is set */
> -	wmb();
> +	priv->txbd[*txbd_curr].data = cpu_to_le32(addr);
> +	priv->tx_buff[*txbd_curr].skb = skb;
>  
> -	skb_tx_timestamp(skb);
> +	/* Make sure info is set after data and skb with respect to
> +	 * other tx_clean().
> +	 */
> +	smp_wmb();
>  
>  	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);

Afaik smp_wmb() does not imply wmb(). So priv->txbd[*txbd_curr].data and
*info (aka priv->txbd[*txbd_curr].info) are not necessarily written in
an orderly manner.

>  
> -	/* Make sure info word is set */
> -	wmb();
> -
> -	priv->tx_buff[*txbd_curr].skb = skb;
> -
>  	/* Increment index to point to the next BD */
>  	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;

With this change it's possible that tx_clean() reads new value for
tx_curr and old value (0) for *info.

>  
> -	/* Ensure that tx_clean() sees the new txbd_curr before
> +	/* 1.Ensure that tx_clean() sees the new txbd_curr before
>  	 * checking the queue status. This prevents an unneeded wake
>  	 * of the queue in tx_clean().
> +	 * 2.Ensure that all values are written to RAM and to DMA
> +	 * before hardware is informed.

(I am not sure what "DMA" is supposed to mean here.)

> +	 * 3.Ensure we see the most recent value for tx_dirty.
>  	 */
> -	smp_mb();
> +	mb();
>  
> -	if (!arc_emac_tx_avail(priv)) {
> +	if (!arc_emac_tx_avail(priv))
>  		netif_stop_queue(ndev);
> -		/* Refresh tx_dirty */
> -		smp_mb();
> -		if (arc_emac_tx_avail(priv))
> -			netif_start_queue(ndev);
> -	}

Xmit thread                        | Clean thread

mb();

arc_emac_tx_avail() test with old
tx_dirty - tx_clean has not issued
any mb yet - and new tx_curr

                                     smp_mb();

                                     if (netif_queue_stopped(ndev) && ...
                                             netif_wake_queue(ndev);

netif_stop_queue()

-> queue stopped.

You can't remove the revalidation step.

arc_emac_tx_avail() is essentially pessimistic. Even if arc_emac_tx_avail()
was "right", there would be a tx_clean window between arc_emac_tx_avail()
and netif_stop_queue().

> +
> +	skb_tx_timestamp(skb);

You don't want to issue skb_tx_timestamp after releasing control of the
descriptor (*info = ...): skb may be long gone.

-- 
Ueimor

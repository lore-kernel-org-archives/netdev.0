From: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Wed, 18 May 2016 22:29:17 +0200
Message-ID: <573CD09D.1060307@gmx.de>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160518000153.GA21757-lmTtMILVy1jWQcoT9B9Ug5SCg42XY1Uw0E9HWUfgJXw@public.gmane.org>
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

On 18.05.2016 02:01, Francois Romieu wrote:

> The smp_wmb() and wmb() could be made side-by-side once *info is
> updated but I don't see the adequate idiom to improve the smp_wmb + wmb
> combo. :o/
> 
>> And the wmb() looks like it should be a dma_wmb().
> 
> I see two points against it:
> - it could be too late for skb_tx_timestamp().
> - arc_emac_tx_clean must not see an index update before the device
>   got a chance to acquire the descriptor. arc_emac_tx_clean can't
>   tell the difference between an about-to-be-released descriptor
>   and a returned-from-device one.
> 

Hi,

what about the (only compile tested) code below?

The smp_wmb() in tx function combined with the smp_rmb() in tx_clean ensures
that the CPU running tx_clean sees consistent values for info, data and skb 
(thus no need to check for validity of all three values any more).

The mb() fulfills several tasks:
1. makes sure that DMA writes to descriptor are completed before the HW is
    informed.
2. On multi processor systems: ensures that txbd_curr is updated (this is paired
    with the smp_mb() at the end of tx_clean).
3. Ensure we see the most recent value for tx_dirty. With this we do not have to
    recheck after we stopped the tx queue.


--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -162,8 +162,13 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		struct sk_buff *skb = tx_buff->skb;
 		unsigned int info = le32_to_cpu(txbd->info);
 
-		if ((info & FOR_EMAC) || !txbd->data || !skb)
+		if (info & FOR_EMAC) {
+			/* Make sure we see consistent values for info, skb
+			 * and data.
+			 */
+			smp_rmb();
 			break;
+		}
 
 		if (unlikely(info & (DROP | DEFR | LTCL | UFLO))) {
 			stats->tx_errors++;
@@ -679,36 +684,33 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	dma_unmap_addr_set(&priv->tx_buff[*txbd_curr], addr, addr);
 	dma_unmap_len_set(&priv->tx_buff[*txbd_curr], len, len);
 
-	priv->txbd[*txbd_curr].data = cpu_to_le32(addr);
 
-	/* Make sure pointer to data buffer is set */
-	wmb();
+	priv->txbd[*txbd_curr].data = cpu_to_le32(addr);
+	priv->tx_buff[*txbd_curr].skb = skb;
 
-	skb_tx_timestamp(skb);
+	/* Make sure info is set after data and skb with respect to
+	 * other tx_clean().
+	 */
+	smp_wmb();
 
 	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
 
-	/* Make sure info word is set */
-	wmb();
-
-	priv->tx_buff[*txbd_curr].skb = skb;
-
 	/* Increment index to point to the next BD */
 	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
 
-	/* Ensure that tx_clean() sees the new txbd_curr before
+	/* 1.Ensure that tx_clean() sees the new txbd_curr before
 	 * checking the queue status. This prevents an unneeded wake
 	 * of the queue in tx_clean().
+	 * 2.Ensure that all values are written to RAM and to DMA
+	 * before hardware is informed.
+	 * 3.Ensure we see the most recent value for tx_dirty.
 	 */
-	smp_mb();
+	mb();
 
-	if (!arc_emac_tx_avail(priv)) {
+	if (!arc_emac_tx_avail(priv))
 		netif_stop_queue(ndev);
-		/* Refresh tx_dirty */
-		smp_mb();
-		if (arc_emac_tx_avail(priv))
-			netif_start_queue(ndev);
-	}
+
+	skb_tx_timestamp(skb);
 
 	arc_reg_set(priv, R_STATUS, TXPL_MASK);
 
-- 
2.7.0

Regards,
Lino

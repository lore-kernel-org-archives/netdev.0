From: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 22 May 2016 13:30:27 +0200
Message-ID: <57419853.9050701@gmx.de>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com> <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com> <573E2D0C.604@gmx.de>
 <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm> <5740E82F.8040903@gmx.de>
 <20160522091742.GA8681@debian-dorm>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, al.kochet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160522091742.GA8681@debian-dorm>
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

On 22.05.2016 11:17, Shuyu Wei wrote:

> Hi Lino,
> 
> I tested this patch, it still got panic under stress.
> Just wget 2 large files simultaneously and it failed.
> 
> Looks like the problem comes from the if statement in tx_clean().
> I changed your patch to use 
> 
> -               if (info & FOR_EMAC)
> +               if ((info & FOR_EMAC) || !txbd->data || !skb)
> 
> and it worked. 

Thanks for testing. However that extra check for skb not being NULL should not be
necessary if the code were correct. The changes I suggested were all about having
skb and info consistent with txbd_curr.
But I just realized that there is still a big flaw in the last changes. While
tx() looks correct now (we first set up the descriptor and assign the skb and _then_
advance txbd_curr) tx_clean still is not:

We _first_ have to read tx_curr and _then_ read the corresponding descriptor and its skb.
(The last patch implemented just the reverse - and thus wrong - order, first get skb and 
descriptor and then read tx_curr).

So the patch below hopefully handles also tx_clean correctly. Could you please do once more a test
with this one?


> 
> After further test, my patch to barrier timestamp() didn't work.
> Just like the original code in the tree, the emac still got stuck under
> high load, even if I changed the smp_wmb() to dma_wmb(). So the original
> code do have race somewhere.

So to make this clear: with the current code in net-next you still see a problem (lockup), right?

> 
> I'm new to kernel development, and still trying to understand how memory
> barrier works

Its an interresting topic and thats what I am trying to understand, too :)


> ... and why Francois' fix worked. Please be patient with me :-).

So which fix(es) exactly work for you and solve your lockup issue?


--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -159,12 +159,22 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		unsigned int *txbd_dirty = &priv->txbd_dirty;
 		struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
 		struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
-		struct sk_buff *skb = tx_buff->skb;
 		unsigned int info = le32_to_cpu(txbd->info);
+		struct sk_buff *skb;
 
-		if ((info & FOR_EMAC) || !txbd->data || !skb)
+		if (*txbd_dirty == priv->txbd_curr)
 			break;
 
+		/* Make sure curr pointer is consistent with info */
+		rmb();
+
+		info = le32_to_cpu(txbd->info);
+
+		if (info & FOR_EMAC)
+			break;
+
+		skb = tx_buff->skb;
+
 		if (unlikely(info & (DROP | DEFR | LTCL | UFLO))) {
 			stats->tx_errors++;
 			stats->tx_dropped++;
@@ -195,8 +205,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
 	}
 
-	/* Ensure that txbd_dirty is visible to tx() before checking
-	 * for queue stopped.
+	/* Ensure that txbd_dirty is visible to tx() and we see the most recent
+	 * value for txbd_curr.
 	 */
 	smp_mb();
 
@@ -680,35 +690,29 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	dma_unmap_len_set(&priv->tx_buff[*txbd_curr], len, len);
 
 	priv->txbd[*txbd_curr].data = cpu_to_le32(addr);
-
-	/* Make sure pointer to data buffer is set */
-	wmb();
+	priv->tx_buff[*txbd_curr].skb = skb;
 
 	skb_tx_timestamp(skb);
 
 	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
 
-	/* Make sure info word is set */
+	/* 1. Make sure that with respect to tx_clean everything is set up
+	 * properly before we advance txbd_curr.
+	 * 2. Make sure writes to DMA descriptors are completed before we inform
+	 * the hardware.
+	 */
 	wmb();
 
-	priv->tx_buff[*txbd_curr].skb = skb;
-
 	/* Increment index to point to the next BD */
 	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
 
-	/* Ensure that tx_clean() sees the new txbd_curr before
-	 * checking the queue status. This prevents an unneeded wake
-	 * of the queue in tx_clean().
+	/* Ensure we see the most recent value of txbd_dirty and tx_clean() sees
+	 * the updated value of txbd_curr.
 	 */
 	smp_mb();
 
-	if (!arc_emac_tx_avail(priv)) {
+	if (!arc_emac_tx_avail(priv))
 		netif_stop_queue(ndev);
-		/* Refresh tx_dirty */
-		smp_mb();
-		if (arc_emac_tx_avail(priv))
-			netif_start_queue(ndev);
-	}
 
 	arc_reg_set(priv, R_STATUS, TXPL_MASK);
 
-- 
1.9.1

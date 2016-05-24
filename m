From: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Wed, 25 May 2016 01:56:20 +0200
Message-ID: <5744EA24.7060806@gmx.de>
References: <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com> <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com> <573E2D0C.604@gmx.de>
 <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm> <5740E82F.8040903@gmx.de>
 <20160522091742.GA8681@debian-dorm> <57419853.9050701@gmx.de>
 <20160522223659.GB5086@electric-eye.fr.zoreil.com> <5743A9DD.8010202@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, al.kochet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <5743A9DD.8010202-Mmb7MZpHnFY@public.gmane.org>
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

Francois, Shuyu,

this is the patch with the discussed changes.

Shuyu it would be great if you could test this one. If it passes
and there are no further objections I will resend it as a regular patch
(including commit message, etc.) to the mailing list.


diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index a3a9392..ec656b3 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -153,18 +153,29 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &ndev->stats;
+	unsigned int curr = priv->txbd_curr;
 	unsigned int i;
 
+	/* Make sure buffers and txbd_curr are consistent */
+	smp_rmb();
+
 	for (i = 0; i < TX_BD_NUM; i++) {
 		unsigned int *txbd_dirty = &priv->txbd_dirty;
 		struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
 		struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
-		struct sk_buff *skb = tx_buff->skb;
-		unsigned int info = le32_to_cpu(txbd->info);
+		unsigned int info;
+		struct sk_buff *skb;
 
-		if ((info & FOR_EMAC) || !txbd->data || !skb)
+		if (*txbd_dirty == curr)
 			break;
 
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
@@ -195,8 +206,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
 	}
 
-	/* Ensure that txbd_dirty is visible to tx() before checking
-	 * for queue stopped.
+	/* Ensure that txbd_dirty is visible to tx() and we see the most recent
+	 * value for txbd_curr.
 	 */
 	smp_mb();
 
@@ -680,27 +691,24 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
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
-	 */
-	smp_mb();
+	/* Ensure tx_clean() sees the updated value of txbd_curr */
+	smp_wmb();
 
 	if (!arc_emac_tx_avail(priv)) {
 		netif_stop_queue(ndev);
-- 
1.9.1

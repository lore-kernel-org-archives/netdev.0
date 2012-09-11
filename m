From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 3/8 (V2)] stmmac: add the initial tx coalesce schema
Date: Tue, 11 Sep 2012 08:55:09 +0200
Message-ID: <1347346514-23411-4-git-send-email-peppe.cavallaro@st.com>
References: <1347346514-23411-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:38886 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab2IKGzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 02:55:40 -0400
In-Reply-To: <1347346514-23411-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new schema used for mitigating the
number of transmit interrupts.
It is based on a sw timer and a threshold value.
The timer is used to periodically call the stmmac_tx
function that can be invoked by the ISR but only for
the descriptors where the interrupt on completion
field has been set. This is tuned by a threshold.

Next step is to add the ability to tune these coalesce
values by ethtool.

Till now I have put a default that showed a real gain
on all the platforms ARM/SH4 where I performed benchmarks.

V2: review the logic to manage the IC bit in the TDESC
that was bugged because it didn't take care about the
fragments. Also fix the tx_count_frames that has not to be
limited to TX DMA ring. Thanks to Ben Hutchings.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    8 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    4 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    9 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   92 ++++++++++++--------
 4 files changed, 69 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index bd32fe6..1d6bd3e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -95,11 +95,13 @@ struct stmmac_extra_stats {
 	unsigned long threshold;
 	unsigned long tx_pkt_n;
 	unsigned long rx_pkt_n;
-	unsigned long rx_napi_poll;
+	unsigned long normal_irq_n;
 	unsigned long rx_normal_irq_n;
+	unsigned long rx_napi_poll;
 	unsigned long tx_normal_irq_n;
-	unsigned long sched_timer_n;
-	unsigned long normal_irq_n;
+	unsigned long txtimer;
+	unsigned long tx_clean;
+	unsigned long tx_reset_ic_bit;
 	unsigned long mmc_tx_irq_n;
 	unsigned long mmc_rx_irq_n;
 	unsigned long mmc_rx_csum_offload_irq_n;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 9f35769..0f5ab28 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -88,6 +88,10 @@ struct stmmac_priv {
 	int eee_enabled;
 	int eee_active;
 	int tx_lpi_timer;
+	struct timer_list txtimer;
+	u32 tx_count_frames;
+	u32 tx_coal_frames;
+	u32 tx_coal_timer;
 };
 
 extern int phyaddr;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 505fe71..48ad0bc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -90,12 +90,13 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(threshold),
 	STMMAC_STAT(tx_pkt_n),
 	STMMAC_STAT(rx_pkt_n),
-	STMMAC_STAT(rx_napi_poll),
+	STMMAC_STAT(normal_irq_n),
 	STMMAC_STAT(rx_normal_irq_n),
+	STMMAC_STAT(rx_napi_poll),
 	STMMAC_STAT(tx_normal_irq_n),
-	STMMAC_STAT(sched_timer_n),
-	STMMAC_STAT(normal_irq_n),
-	STMMAC_STAT(normal_irq_n),
+	STMMAC_STAT(txtimer),
+	STMMAC_STAT(tx_clean),
+	STMMAC_STAT(tx_reset_ic_bit),
 	STMMAC_STAT(mmc_tx_irq_n),
 	STMMAC_STAT(mmc_rx_irq_n),
 	STMMAC_STAT(mmc_rx_csum_offload_irq_n),
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8e1e53e..3df3c3b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -77,6 +77,8 @@
 
 #define STMMAC_ALIGN(x)	L1_CACHE_ALIGN(x)
 #define JUMBO_LEN	9000
+#define	STMMAC_TX_TM	40000
+#define STMMAC_TX_MAX_FRAMES	32	/* Max coalesced frame */
 
 /* Module parameters */
 #define TX_TIMEO 5000 /* default 5 seconds */
@@ -695,8 +697,11 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 static void stmmac_tx(struct stmmac_priv *priv)
 {
 	unsigned int txsize = priv->dma_tx_size;
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->tx_lock, flags);
 
-	spin_lock(&priv->tx_lock);
+	priv->xstats.tx_clean++;
 
 	while (priv->dirty_tx != priv->cur_tx) {
 		int last;
@@ -741,7 +746,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 				skb_recycle_check(skb, priv->dma_buf_sz))
 				__skb_queue_head(&priv->rx_recycle, skb);
 			else
-				dev_kfree_skb(skb);
+				dev_kfree_skb_any(skb);
 
 			priv->tx_skbuff[entry] = NULL;
 		}
@@ -765,7 +770,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 		stmmac_enable_eee_mode(priv);
 		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_TIMER(eee_timer));
 	}
-	spin_unlock(&priv->tx_lock);
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
 }
 
 static inline void stmmac_enable_irq(struct stmmac_priv *priv)
@@ -778,29 +783,12 @@ static inline void stmmac_disable_irq(struct stmmac_priv *priv)
 	priv->hw->dma->disable_dma_irq(priv->ioaddr);
 }
 
-static int stmmac_has_work(struct stmmac_priv *priv)
+static void stmmac_txtimer(unsigned long data)
 {
-	unsigned int has_work = 0;
-	int rxret, tx_work = 0;
-
-	rxret = priv->hw->desc->get_rx_owner(priv->dma_rx +
-		(priv->cur_rx % priv->dma_rx_size));
-
-	if (priv->dirty_tx != priv->cur_tx)
-		tx_work = 1;
-
-	if (likely(!rxret || tx_work))
-		has_work = 1;
+	struct stmmac_priv *priv = (struct stmmac_priv *)data;
 
-	return has_work;
-}
-
-static inline void _stmmac_schedule(struct stmmac_priv *priv)
-{
-	if (likely(stmmac_has_work(priv))) {
-		stmmac_disable_irq(priv);
-		napi_schedule(&priv->napi);
-	}
+	priv->xstats.txtimer++;
+	stmmac_tx(priv);
 }
 
 /**
@@ -824,7 +812,7 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	netif_wake_queue(priv->dev);
 }
 
-static inline void stmmac_rx_schedule(struct stmmac_priv *priv)
+static void stmmac_rx_schedule(struct stmmac_priv *priv)
 {
 	if (likely(napi_schedule_prep(&priv->napi))) {
 		stmmac_disable_irq(priv);
@@ -1001,6 +989,18 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 				   priv->dma_rx_phy);
 }
 
+static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
+{
+	/* Set Tx coalesce parameters and timers */
+	priv->tx_coal_frames = STMMAC_TX_MAX_FRAMES;
+	priv->tx_coal_timer = jiffies + usecs_to_jiffies(STMMAC_TX_TM);
+	init_timer(&priv->txtimer);
+	priv->txtimer.expires = priv->tx_coal_timer;
+	priv->txtimer.data = (unsigned long)priv;
+	priv->txtimer.function = stmmac_txtimer;
+	add_timer(&priv->txtimer);
+}
+
 /**
  *  stmmac_open - open entry point of the driver
  *  @dev : pointer to the device structure.
@@ -1113,6 +1113,8 @@ static int stmmac_open(struct net_device *dev)
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS_TIMER;
 	priv->eee_enabled = stmmac_eee_init(priv);
 
+	stmmac_init_tx_coalesce(priv);
+
 	napi_enable(&priv->napi);
 	skb_queue_head_init(&priv->rx_recycle);
 	netif_start_queue(dev);
@@ -1160,6 +1162,8 @@ static int stmmac_release(struct net_device *dev)
 	napi_disable(&priv->napi);
 	skb_queue_purge(&priv->rx_recycle);
 
+	del_timer_sync(&priv->txtimer);
+
 	/* Free the IRQ lines */
 	free_irq(dev->irq, dev);
 	if (priv->wol_irq != dev->irq)
@@ -1202,6 +1206,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	struct dma_desc *desc, *first;
 	unsigned int nopaged_len = skb_headlen(skb);
+	unsigned long flags;
 
 	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
 		if (!netif_queue_stopped(dev)) {
@@ -1213,7 +1218,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	spin_lock(&priv->tx_lock);
+	spin_lock_irqsave(&priv->tx_lock, flags);
 
 	if (priv->tx_path_in_lpi_mode)
 		stmmac_disable_eee_mode(priv);
@@ -1222,11 +1227,13 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 #ifdef STMMAC_XMIT_DEBUG
 	if ((skb->len > ETH_FRAME_LEN) || nfrags)
-		pr_info("stmmac xmit:\n"
-		       "\tskb addr %p - len: %d - nopaged_len: %d\n"
-		       "\tn_frags: %d - ip_summed: %d - %s gso\n",
-		       skb, skb->len, nopaged_len, nfrags, skb->ip_summed,
-		       !skb_is_gso(skb) ? "isn't" : "is");
+		pr_debug("stmmac xmit: [entry %d]\n"
+			 "\tskb addr %p - len: %d - nopaged_len: %d\n"
+			 "\tn_frags: %d - ip_summed: %d - %s gso\n"
+			 "\ttx_count_frames %d\n", entry,
+			 skb, skb->len, nopaged_len, nfrags, skb->ip_summed,
+			 !skb_is_gso(skb) ? "isn't" : "is",
+			 priv->tx_count_frames);
 #endif
 
 	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
@@ -1236,9 +1243,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 #ifdef STMMAC_XMIT_DEBUG
 	if ((nfrags > 0) || (skb->len > ETH_FRAME_LEN))
-		pr_debug("stmmac xmit: skb len: %d, nopaged_len: %d,\n"
-		       "\t\tn_frags: %d, ip_summed: %d\n",
-		       skb->len, nopaged_len, nfrags, skb->ip_summed);
+		pr_debug("\tskb len: %d, nopaged_len: %d,\n"
+			 "\t\tn_frags: %d, ip_summed: %d\n",
+			 skb->len, nopaged_len, nfrags, skb->ip_summed);
 #endif
 	priv->tx_skbuff[entry] = skb;
 
@@ -1269,10 +1276,22 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		wmb();
 	}
 
-	/* Interrupt on completition only for the latest segment */
+	/* Finalize the latest segment. */
 	priv->hw->desc->close_tx_desc(desc);
 
 	wmb();
+	/* According to the coalesce parameter the IC bit for the latest
+	 * segment could be reset and the timer re-started to invoke the
+	 * stmmac_tx function. This approach takes care about the fragments. */
+	priv->tx_count_frames += nfrags + 1;
+	if (priv->tx_coal_frames > priv->tx_count_frames) {
+		priv->hw->desc->clear_tx_ic(desc);
+		priv->xstats.tx_reset_ic_bit++;
+		TX_DBG("\t[entry %d]: tx_count_frames %d\n", entry,
+		       priv->tx_count_frames);
+		mod_timer(&priv->txtimer, priv->tx_coal_timer);
+	} else
+		priv->tx_count_frames = 0;
 
 	/* To avoid raise condition */
 	priv->hw->desc->set_tx_owner(first);
@@ -1302,7 +1321,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
 
-	spin_unlock(&priv->tx_lock);
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
 
 	return NETDEV_TX_OK;
 }
@@ -1447,7 +1466,6 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
  *	      all interfaces.
  *  Description :
  *   This function implements the the reception process.
- *   Also it runs the TX completion thread
  */
 static int stmmac_poll(struct napi_struct *napi, int budget)
 {
-- 
1.7.4.4

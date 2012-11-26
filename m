From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 2/6 (V3)] stmmac: add the initial tx coalesce schema
Date: Mon, 26 Nov 2012 10:10:42 +0100
Message-ID: <1353921046-5121-3-git-send-email-peppe.cavallaro@st.com>
References: <1353921046-5121-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:45878 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753979Ab2KZJLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 04:11:36 -0500
In-Reply-To: <1353921046-5121-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new schema used for mitigating the
number of transmit interrupts.
It is based on a SW timer and a threshold value.
The timer is used to periodically call the stmmac_tx_clean
function; the threshold is used for setting the IC (Interrupt
on Completion bit). The ISR will then invoke the poll method.
Also the patch improves some ethtool stat fields.

V2: review the logic to manage the IC bit in the TDESC
that was bugged because it didn't take care about the
fragments. Also fix the tx_count_frames that has not to be
limited to TX DMA ring. Thanks to Ben Hutchings.

V3: removed the spin_lock irqsave/restore as D. Miller suggested.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   22 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |    7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    4 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    8 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  132 ++++++++++++--------
 5 files changed, 111 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 719be39..d17eeef 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -95,9 +95,12 @@ struct stmmac_extra_stats {
 	unsigned long threshold;
 	unsigned long tx_pkt_n;
 	unsigned long rx_pkt_n;
-	unsigned long poll_n;
-	unsigned long sched_timer_n;
 	unsigned long normal_irq_n;
+	unsigned long rx_normal_irq_n;
+	unsigned long napi_poll;
+	unsigned long tx_normal_irq_n;
+	unsigned long tx_clean;
+	unsigned long tx_reset_ic_bit;
 	unsigned long mmc_tx_irq_n;
 	unsigned long mmc_rx_irq_n;
 	unsigned long mmc_rx_csum_offload_irq_n;
@@ -162,6 +165,12 @@ struct stmmac_extra_stats {
 #define DMA_HW_FEAT_ACTPHYIF	0x70000000 /* Active/selected PHY interface */
 #define DEFAULT_DMA_PBL		8
 
+/* Tx coalesce parameters */
+#define STMMAC_COAL_TX_TIMER	40000
+#define STMMAC_MAX_COAL_TX_TICK	100000
+#define STMMAC_TX_MAX_FRAMES	256
+#define STMMAC_TX_FRAMES	64
+
 enum rx_frame_status { /* IPC status */
 	good_frame = 0,
 	discard_frame = 1,
@@ -169,10 +178,11 @@ enum rx_frame_status { /* IPC status */
 	llc_snap = 4,
 };
 
-enum tx_dma_irq_status {
-	tx_hard_error = 1,
-	tx_hard_error_bump_tc = 2,
-	handle_tx_rx = 3,
+enum dma_irq_status {
+	tx_hard_error = 0x1,
+	tx_hard_error_bump_tc = 0x2,
+	handle_rx = 0x4,
+	handle_tx = 0x8,
 };
 
 enum core_specific_irq_mask {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 4e0e18a..73766e6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -206,9 +206,10 @@ int dwmac_dma_interrupt(void __iomem *ioaddr,
 	/* TX/RX NORMAL interrupts */
 	if (intr_status & DMA_STATUS_NIS) {
 		x->normal_irq_n++;
-		if (likely((intr_status & DMA_STATUS_RI) ||
-			 (intr_status & (DMA_STATUS_TI))))
-				ret = handle_tx_rx;
+		if (likely(intr_status & DMA_STATUS_RI))
+			ret |= handle_rx;
+		if (intr_status & (DMA_STATUS_TI))
+			ret |= handle_tx;
 	}
 	/* Optional hardware blocks, interrupts should be disabled */
 	if (unlikely(intr_status &
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 5f89415..01b3451 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -87,6 +87,10 @@ struct stmmac_priv {
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
index 76fd61a..de2210c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -90,10 +90,12 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(threshold),
 	STMMAC_STAT(tx_pkt_n),
 	STMMAC_STAT(rx_pkt_n),
-	STMMAC_STAT(poll_n),
-	STMMAC_STAT(sched_timer_n),
-	STMMAC_STAT(normal_irq_n),
 	STMMAC_STAT(normal_irq_n),
+	STMMAC_STAT(rx_normal_irq_n),
+	STMMAC_STAT(napi_poll),
+	STMMAC_STAT(tx_normal_irq_n),
+	STMMAC_STAT(tx_clean),
+	STMMAC_STAT(tx_reset_ic_bit),
 	STMMAC_STAT(mmc_tx_irq_n),
 	STMMAC_STAT(mmc_rx_irq_n),
 	STMMAC_STAT(mmc_rx_csum_offload_irq_n),
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 777234c..d40cf9e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -137,6 +137,8 @@ static int stmmac_init_fs(struct net_device *dev);
 static void stmmac_exit_fs(void);
 #endif
 
+#define STMMAC_COAL_TIMER(x) (jiffies + usecs_to_jiffies(x))
+
 /**
  * stmmac_verify_args - verify the driver parameters.
  * Description: it verifies if some wrong parameter is passed to the driver.
@@ -688,16 +690,18 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 }
 
 /**
- * stmmac_tx:
- * @priv: private driver structure
+ * stmmac_tx_clean:
+ * @priv: private data pointer
  * Description: it reclaims resources after transmission completes.
  */
-static void stmmac_tx(struct stmmac_priv *priv)
+static void stmmac_tx_clean(struct stmmac_priv *priv)
 {
 	unsigned int txsize = priv->dma_tx_size;
 
 	spin_lock(&priv->tx_lock);
 
+	priv->xstats.tx_clean++;
+
 	while (priv->dirty_tx != priv->cur_tx) {
 		int last;
 		unsigned int entry = priv->dirty_tx % txsize;
@@ -757,40 +761,16 @@ static void stmmac_tx(struct stmmac_priv *priv)
 	spin_unlock(&priv->tx_lock);
 }
 
-static inline void stmmac_enable_irq(struct stmmac_priv *priv)
+static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv)
 {
 	priv->hw->dma->enable_dma_irq(priv->ioaddr);
 }
 
-static inline void stmmac_disable_irq(struct stmmac_priv *priv)
+static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv)
 {
 	priv->hw->dma->disable_dma_irq(priv->ioaddr);
 }
 
-static int stmmac_has_work(struct stmmac_priv *priv)
-{
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
-
-	return has_work;
-}
-
-static inline void _stmmac_schedule(struct stmmac_priv *priv)
-{
-	if (likely(stmmac_has_work(priv))) {
-		stmmac_disable_irq(priv);
-		napi_schedule(&priv->napi);
-	}
-}
 
 /**
  * stmmac_tx_err:
@@ -813,16 +793,18 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	netif_wake_queue(priv->dev);
 }
 
-
 static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 {
 	int status;
 
 	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
-	if (likely(status == handle_tx_rx))
-		_stmmac_schedule(priv);
-
-	else if (unlikely(status == tx_hard_error_bump_tc)) {
+	if (likely((status & handle_rx)) || (status & handle_tx)) {
+		if (likely(napi_schedule_prep(&priv->napi))) {
+			stmmac_disable_dma_irq(priv);
+			__napi_schedule(&priv->napi);
+		}
+	}
+	if (unlikely(status & tx_hard_error_bump_tc)) {
 		/* Try to bump up the dma threshold on this failure */
 		if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
 			tc += 64;
@@ -938,7 +920,6 @@ static int stmmac_get_hw_features(struct stmmac_priv *priv)
 		/* Alternate (enhanced) DESC mode*/
 		priv->dma_cap.enh_desc =
 			(hw_cap & DMA_HW_FEAT_ENHDESSEL) >> 24;
-
 	}
 
 	return hw_cap;
@@ -980,6 +961,38 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 }
 
 /**
+ * stmmac_tx_timer:
+ * @data: data pointer
+ * Description:
+ * This is the timer handler to directly invoke the stmmac_tx_clean.
+ */
+static void stmmac_tx_timer(unsigned long data)
+{
+	struct stmmac_priv *priv = (struct stmmac_priv *)data;
+
+	stmmac_tx_clean(priv);
+}
+
+/**
+ * stmmac_tx_timer:
+ * @priv: private data structure
+ * Description:
+ * This inits the transmit coalesce parameters: i.e. timer rate,
+ * timer handler and default threshold used for enabling the
+ * interrupt on completion bit.
+ */
+static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
+{
+	priv->tx_coal_frames = STMMAC_TX_FRAMES;
+	priv->tx_coal_timer = STMMAC_COAL_TX_TIMER;
+	init_timer(&priv->txtimer);
+	priv->txtimer.expires = STMMAC_COAL_TIMER(priv->tx_coal_timer);
+	priv->txtimer.data = (unsigned long)priv;
+	priv->txtimer.function = stmmac_tx_timer;
+	add_timer(&priv->txtimer);
+}
+
+/**
  *  stmmac_open - open entry point of the driver
  *  @dev : pointer to the device structure.
  *  Description:
@@ -1091,6 +1104,8 @@ static int stmmac_open(struct net_device *dev)
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS_TIMER;
 	priv->eee_enabled = stmmac_eee_init(priv);
 
+	stmmac_init_tx_coalesce(priv);
+
 	napi_enable(&priv->napi);
 	netif_start_queue(dev);
 
@@ -1136,6 +1151,8 @@ static int stmmac_release(struct net_device *dev)
 
 	napi_disable(&priv->napi);
 
+	del_timer_sync(&priv->txtimer);
+
 	/* Free the IRQ lines */
 	free_irq(dev->irq, dev);
 	if (priv->wol_irq != dev->irq)
@@ -1198,11 +1215,13 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
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
@@ -1212,9 +1231,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
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
 
@@ -1245,10 +1264,24 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		wmb();
 	}
 
-	/* Interrupt on completition only for the latest segment */
+	/* Finalize the latest segment. */
 	priv->hw->desc->close_tx_desc(desc);
 
 	wmb();
+	/* According to the coalesce parameter the IC bit for the latest
+	 * segment could be reset and the timer re-started to invoke the
+	 * stmmac_tx function. This approach takes care about the fragments.
+	 */
+	priv->tx_count_frames += nfrags + 1;
+	if (priv->tx_coal_frames > priv->tx_count_frames) {
+		priv->hw->desc->clear_tx_ic(desc);
+		priv->xstats.tx_reset_ic_bit++;
+		TX_DBG("\t[entry %d]: tx_count_frames %d\n", entry,
+		       priv->tx_count_frames);
+		mod_timer(&priv->txtimer,
+			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
+	} else
+		priv->tx_count_frames = 0;
 
 	/* To avoid raise condition */
 	priv->hw->desc->set_tx_owner(first);
@@ -1419,21 +1452,20 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
  *  @budget : maximum number of packets that the current CPU can receive from
  *	      all interfaces.
  *  Description :
- *   This function implements the the reception process.
- *   Also it runs the TX completion thread
+ *  To look at the incoming frames and clear the tx resources.
  */
 static int stmmac_poll(struct napi_struct *napi, int budget)
 {
 	struct stmmac_priv *priv = container_of(napi, struct stmmac_priv, napi);
 	int work_done = 0;
 
-	priv->xstats.poll_n++;
-	stmmac_tx(priv);
-	work_done = stmmac_rx(priv, budget);
+	priv->xstats.napi_poll++;
+	stmmac_tx_clean(priv);
 
+	work_done = stmmac_rx(priv, budget);
 	if (work_done < budget) {
 		napi_complete(napi);
-		stmmac_enable_irq(priv);
+		stmmac_enable_dma_irq(priv);
 	}
 	return work_done;
 }
-- 
1.7.4.4

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 5/7] stmmac: get/set coalesce parameters via ethtool
Date: Wed,  5 Sep 2012 17:03:50 +0200
Message-ID: <1346857432-24657-6-git-send-email-peppe.cavallaro@st.com>
References: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:48988 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757574Ab2IEPEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 11:04:23 -0400
In-Reply-To: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to get/set the tx/rx coalesce parameters
via ethtool interface.

Tests have been done on several platform with
different GMAC chips w/o w/ RX watchdog feature.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    8 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    1 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   74 ++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   56 +++++----------
 4 files changed, 100 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 63d4bad..ee9cd8f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -169,7 +169,13 @@ struct stmmac_extra_stats {
 #define DMA_HW_FEAT_SAVLANINS	0x08000000 /* Source Addr or VLAN Insertion */
 #define DMA_HW_FEAT_ACTPHYIF	0x70000000 /* Active/selected PHY interface */
 #define DEFAULT_DMA_PBL		8
-#define DEFAULT_DMA_RIWT	0xff	/* Max RI Watchdog Timer count */
+
+/* Coalesce defines */
+#define MAX_DMA_RIWT		0xff	/* Max RI Watchdog Timer count */
+#define MIN_DMA_RIWT		0x20
+#define STMMAC_COAL_TX_TIMER	40000
+#define STMMAC_MAX_COAL_TX_TICK	100000
+#define STMMAC_TX_MAX_FRAMES(x)	(x/4)
 
 enum rx_frame_status { /* IPC status */
 	good_frame = 0,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index c113f28..577dc13 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -93,6 +93,7 @@ struct stmmac_priv {
 	u32 tx_count_frames;
 	u32 tx_coal_frames;
 	u32 tx_coal_timer;
+	u32 rx_riwt;
 };
 
 extern int phyaddr;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 48ad0bc..1428489 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -522,6 +522,78 @@ static int stmmac_ethtool_op_set_eee(struct net_device *dev,
 	return phy_ethtool_set_eee(priv->phydev, edata);
 }
 
+static u32 stmmac_usec2riwt(u32 usec, struct stmmac_priv *priv)
+{
+	unsigned long clk = clk_get_rate(priv->stmmac_clk);
+
+	if (!clk)
+		return 0;
+
+	return (usec * (clk / 1000000)) / 256;
+}
+
+static u32 stmmac_riwt2usec(u32 riwt, struct stmmac_priv *priv)
+{
+	unsigned long clk = clk_get_rate(priv->stmmac_clk);
+
+	if (!clk)
+		return 0;
+
+	return (riwt * 256) / (clk / 1000000);
+}
+
+static int stmmac_get_coalesce(struct net_device *dev,
+			       struct ethtool_coalesce *ec)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	ec->tx_coalesce_usecs = priv->tx_coal_timer;
+	ec->tx_max_coalesced_frames = priv->tx_coal_frames;
+
+	if (!priv->napi_mode)
+		ec->rx_coalesce_usecs = stmmac_riwt2usec(priv->rx_riwt, priv);
+
+	return 0;
+}
+
+static int stmmac_set_coalesce(struct net_device *dev,
+			       struct ethtool_coalesce *ec)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+	unsigned int max_tx_coal_frames;
+	unsigned int rx_riwt;
+
+	/* No rx interrupts will be generated if both are zero */
+	if (ec->rx_coalesce_usecs == 0)
+		return -EINVAL;
+
+	/* No tx interrupts will be generated if both are zero */
+	if ((ec->tx_coalesce_usecs == 0) &&
+	    (ec->tx_max_coalesced_frames == 0))
+		return -EINVAL;
+
+	max_tx_coal_frames = STMMAC_TX_MAX_FRAMES(priv->dma_tx_size);
+
+	if ((ec->tx_coalesce_usecs > STMMAC_COAL_TX_TIMER) ||
+	    (ec->tx_max_coalesced_frames > max_tx_coal_frames))
+		return -EINVAL;
+
+	rx_riwt = stmmac_usec2riwt(ec->rx_coalesce_usecs, priv);
+
+	if ((rx_riwt > MAX_DMA_RIWT) || (rx_riwt < MIN_DMA_RIWT))
+		return -EINVAL;
+	else if (priv->napi_mode)
+		return -EOPNOTSUPP;
+
+	/* Only copy relevant parameters, ignore all others. */
+	priv->tx_coal_frames = ec->tx_max_coalesced_frames;
+	priv->tx_coal_timer = ec->tx_coalesce_usecs;
+	priv->rx_riwt = rx_riwt;
+	priv->hw->dma->rx_watchdog(priv->ioaddr, priv->rx_riwt);
+
+	return 0;
+}
+
 static const struct ethtool_ops stmmac_ethtool_ops = {
 	.begin = stmmac_check_if_running,
 	.get_drvinfo = stmmac_ethtool_getdrvinfo,
@@ -542,6 +614,8 @@ static const struct ethtool_ops stmmac_ethtool_ops = {
 	.set_eee = stmmac_ethtool_op_set_eee,
 	.get_sset_count	= stmmac_get_sset_count,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_coalesce = stmmac_get_coalesce,
+	.set_coalesce = stmmac_set_coalesce,
 };
 
 void stmmac_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 55bb3c9..cea4196 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -77,8 +77,6 @@
 
 #define STMMAC_ALIGN(x)	L1_CACHE_ALIGN(x)
 #define JUMBO_LEN	9000
-#define	STMMAC_TX_TM	40000
-#define STMMAC_TX_MAX_FRAMES	64	/* Max coalesced frame */
 
 /* Module parameters */
 #define TX_TIMEO 5000 /* default 5 seconds */
@@ -140,6 +138,8 @@ static int stmmac_init_fs(struct net_device *dev);
 static void stmmac_exit_fs(void);
 #endif
 
+#define STMMAC_COAL_TIMER(x) (jiffies + usecs_to_jiffies(x))
+
 /**
  * stmmac_verify_args - verify the driver parameters.
  * Description: it verifies if some wrong parameter is passed to the driver.
@@ -999,34 +999,16 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 				   priv->dma_rx_phy);
 }
 
-static int stmmac_check_coal(int size, int max_coal_frames)
-{
-	int ret = 0;
-
-	if (max_coal_frames >= size)
-		return ret;
-
-	return max_coal_frames;
-}
-
-static int stmmac_init_tx_coalesce(struct stmmac_priv *priv)
+static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
 {
-	int ret = -EOPNOTSUPP;
-
-	priv->tx_coal_frames = stmmac_check_coal(priv->dma_tx_size,
-						 STMMAC_TX_MAX_FRAMES);
-	if (priv->tx_coal_frames) {
-		/* Set Tx coalesce parameters and timers */
-		priv->tx_coal_timer = jiffies + usecs_to_jiffies(STMMAC_TX_TM);
-		init_timer(&priv->txtimer);
-		priv->txtimer.expires = priv->tx_coal_timer;
-		priv->txtimer.data = (unsigned long)priv;
-		priv->txtimer.function = stmmac_txtimer;
-
-		ret = 0;
-	}
-
-	return ret;
+	/* Set Tx coalesce parameters and timers */
+	priv->tx_coal_frames = STMMAC_TX_MAX_FRAMES(priv->dma_tx_size);
+	priv->tx_coal_timer = STMMAC_COAL_TX_TIMER;
+	init_timer(&priv->txtimer);
+	priv->txtimer.expires = STMMAC_COAL_TIMER(priv->tx_coal_timer);
+	priv->txtimer.data = (unsigned long)priv;
+	priv->txtimer.function = stmmac_txtimer;
+	add_timer(&priv->txtimer);
 }
 
 /**
@@ -1141,20 +1123,17 @@ static int stmmac_open(struct net_device *dev)
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS_TIMER;
 	priv->eee_enabled = stmmac_eee_init(priv);
 
-	ret = stmmac_init_tx_coalesce(priv);
-	if (!ret)
-		add_timer(&priv->txtimer);
+	stmmac_init_tx_coalesce(priv);
 
 	/* Enable NAPI on chip older than the 3.50 where the Rx watchdog
 	 * is not supported.
 	 */
 	if (priv->napi_mode)
 		napi_enable(&priv->napi);
-	else if (priv->hw->dma->rx_watchdog)
-		/* Program RX Watchdog register to the default values
-		 * FIXME: provide user value for RIWT
-		 */
-		priv->hw->dma->rx_watchdog(priv->ioaddr, DEFAULT_DMA_RIWT);
+	else if (priv->hw->dma->rx_watchdog) {
+		priv->rx_riwt = MAX_DMA_RIWT;
+		priv->hw->dma->rx_watchdog(priv->ioaddr, MAX_DMA_RIWT);
+	}
 
 	skb_queue_head_init(&priv->rx_recycle);
 	netif_start_queue(dev);
@@ -1318,7 +1297,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (priv->tx_coal_frames > priv->tx_count_frames) {
 		priv->hw->desc->clear_tx_ic(desc);
 		priv->xstats.tx_reset_ic_bit++;
-		mod_timer(&priv->txtimer, priv->tx_coal_timer);
+		mod_timer(&priv->txtimer,
+			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
 	} else
 		priv->tx_count_frames = 0;
 
-- 
1.7.4.4

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 4/8 (V3)] stmmac: add Rx watchdog support to mitigate the DMA irqs
Date: Mon, 10 Sep 2012 09:38:05 +0200
Message-ID: <1347262689-21251-5-git-send-email-peppe.cavallaro@st.com>
References: <1347262689-21251-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:46590 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751597Ab2IJHiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 03:38:50 -0400
In-Reply-To: <1347262689-21251-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GMAC devices newer than databook 3.40 has an embedded timer
that can be used for mitigating the number of interrupts.
So this patch adds this optimizations.
At any rate, the Rx watchdog can be disable (on bugged HW) by
passing from the platform the riwt_off field.

In this implementation the rx timer stored in the Reg9 is fixed
to the max value. Next step will be to tune it via ethtool.

V2: added a platform parameter to force to disable the rx-watchdog
for example on new core where it is bugged.

V3: do not disable NAPI when Rx watchdog is used.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    7 ++++
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    3 --
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    6 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   36 +++++++++++++++----
 include/linux/stmmac.h                             |    1 +
 7 files changed, 45 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 1d6bd3e..63d4bad 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -48,6 +48,10 @@
 #define CHIP_DBG(fmt, args...)  do { } while (0)
 #endif
 
+/* Synopsys Core versions */
+#define	DWMAC_CORE_3_40	0x34
+#define	DWMAC_CORE_3_50	0x35
+
 #undef FRAME_FILTER_DEBUG
 /* #define FRAME_FILTER_DEBUG */
 
@@ -165,6 +169,7 @@ struct stmmac_extra_stats {
 #define DMA_HW_FEAT_SAVLANINS	0x08000000 /* Source Addr or VLAN Insertion */
 #define DMA_HW_FEAT_ACTPHYIF	0x70000000 /* Active/selected PHY interface */
 #define DEFAULT_DMA_PBL		8
+#define DEFAULT_DMA_RIWT	0xff	/* Max RI Watchdog Timer count */
 
 enum rx_frame_status { /* IPC status */
 	good_frame = 0,
@@ -301,6 +306,8 @@ struct stmmac_dma_ops {
 			      struct stmmac_extra_stats *x);
 	/* If supported then get the optional core features */
 	unsigned int (*get_hw_feature) (void __iomem *ioaddr);
+	/* Program the HW RX Watchdog */
+	void (*rx_watchdog) (void __iomem *ioaddr, u32 riwt);
 };
 
 struct stmmac_ops {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 0e4cace..7ad56af 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -230,8 +230,5 @@ enum rtc_control {
 #define GMAC_MMC_TX_INTR   0x108
 #define GMAC_MMC_RX_CSUM_OFFLOAD   0x208
 
-/* Synopsys Core versions */
-#define	DWMAC_CORE_3_40	0x34
-
 extern const struct stmmac_dma_ops dwmac1000_dma_ops;
 #endif /* __DWMAC1000_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 0335000..e2c9431 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -174,6 +174,11 @@ static unsigned int dwmac1000_get_hw_feature(void __iomem *ioaddr)
 	return readl(ioaddr + DMA_HW_FEATURE);
 }
 
+static void dwmac1000_rx_watchdog(void __iomem *ioaddr, u32 riwt)
+{
+	writel(riwt, ioaddr + DMA_RX_WATCHDOG);
+}
+
 const struct stmmac_dma_ops dwmac1000_dma_ops = {
 	.init = dwmac1000_dma_init,
 	.dump_regs = dwmac1000_dump_dma_regs,
@@ -187,4 +192,5 @@ const struct stmmac_dma_ops dwmac1000_dma_ops = {
 	.stop_rx = dwmac_dma_stop_rx,
 	.dma_interrupt = dwmac_dma_interrupt,
 	.get_hw_feature = dwmac1000_get_hw_feature,
+	.rx_watchdog = dwmac1000_rx_watchdog,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index e49c9a0..4eeff5d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -35,7 +35,8 @@
 #define DMA_CONTROL		0x00001018	/* Ctrl (Operational Mode) */
 #define DMA_INTR_ENA		0x0000101c	/* Interrupt Enable */
 #define DMA_MISSED_FRAME_CTR	0x00001020	/* Missed Frame Counter */
-#define DMA_AXI_BUS_MODE       0x00001028      /* AXI Bus Mode */
+#define DMA_RX_WATCHDOG		0x00001024	/* Receive Int Watchdog Timer */
+#define DMA_AXI_BUS_MODE	0x00001028      /* AXI Bus Mode */
 #define DMA_CUR_TX_BUF_ADDR	0x00001050	/* Current Host Tx Buffer */
 #define DMA_CUR_RX_BUF_ADDR	0x00001054	/* Current Host Rx Buffer */
 #define DMA_HW_FEATURE		0x00001058	/* HW Feature Register */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 0f5ab28..6901e3c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -89,6 +89,7 @@ struct stmmac_priv {
 	int eee_active;
 	int tx_lpi_timer;
 	struct timer_list txtimer;
+	int use_riwt;
 	u32 tx_count_frames;
 	u32 tx_coal_frames;
 	u32 tx_coal_timer;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3df3c3b..8e610a1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -133,6 +133,7 @@ MODULE_PARM_DESC(eee_timer, "LPI tx expiration time in msec");
 #define STMMAC_LPI_TIMER(x) (jiffies + msecs_to_jiffies(x))
 
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id);
+static int stmmac_rx(struct stmmac_priv *priv, int limit);
 
 #ifdef CONFIG_STMMAC_DEBUG_FS
 static int stmmac_init_fs(struct net_device *dev);
@@ -603,6 +604,8 @@ static void init_dma_desc_rings(struct net_device *dev)
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 
+	if (priv->use_riwt)
+		dis_ic = 1;
 	/* Clear the Rx/Tx descriptors */
 	priv->hw->desc->init_rx_desc(priv->dma_rx, rxsize, dis_ic);
 	priv->hw->desc->init_tx_desc(priv->dma_tx, txsize);
@@ -812,7 +815,7 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	netif_wake_queue(priv->dev);
 }
 
-static void stmmac_rx_schedule(struct stmmac_priv *priv)
+static void stmmac_rx_work(struct stmmac_priv *priv)
 {
 	if (likely(napi_schedule_prep(&priv->napi))) {
 		stmmac_disable_irq(priv);
@@ -827,7 +830,7 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
 	if (likely(status & handle_rx)) {
 		priv->xstats.rx_normal_irq_n++;
-		stmmac_rx_schedule(priv);
+		stmmac_rx_work(priv);
 	}
 	if (likely(status & handle_tx)) {
 		priv->xstats.tx_normal_irq_n++;
@@ -1115,7 +1118,14 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_init_tx_coalesce(priv);
 
+	if ((priv->use_riwt) && (priv->hw->dma->rx_watchdog))
+		/* Program RX Watchdog register to the default values
+		 * FIXME: provide user value for RIWT
+		 */
+		priv->hw->dma->rx_watchdog(priv->ioaddr, DEFAULT_DMA_RIWT);
+
 	napi_enable(&priv->napi);
+
 	skb_queue_head_init(&priv->rx_recycle);
 	netif_start_queue(dev);
 
@@ -1436,14 +1446,12 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 #endif
 			skb->protocol = eth_type_trans(skb, priv->dev);
 
-			if (unlikely(!priv->plat->rx_coe)) {
-				/* No RX COE for old mac10/100 devices */
+			if (unlikely(!priv->plat->rx_coe))
 				skb_checksum_none_assert(skb);
-				netif_receive_skb(skb);
-			} else {
+			else
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				napi_gro_receive(&priv->napi, skb);
-			}
+
+			napi_gro_receive(&priv->napi, skb);
 
 			priv->dev->stats.rx_packets++;
 			priv->dev->stats.rx_bytes += frame_len;
@@ -2013,6 +2021,15 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	if (flow_ctrl)
 		priv->flow_ctrl = FLOW_AUTO;	/* RX/TX pause on */
 
+	/* Rx Watchdog is available in the COREs newer than the 3.40.
+	 * In some case, for example on bugged HW this feature
+	 * has to be disable and this can be done by passing the
+	 * riwt_off field from the platform. */
+	if ((priv->synopsys_id >= DWMAC_CORE_3_50) && (!priv->plat->riwt_off)) {
+		priv->use_riwt = 1;
+		pr_info(" Enable RX Mitigation via HW Watchdog Timer\n");
+	}
+
 	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
 
 	spin_lock_init(&priv->lock);
@@ -2104,6 +2121,9 @@ int stmmac_suspend(struct net_device *ndev)
 	netif_device_detach(ndev);
 	netif_stop_queue(ndev);
 
+	if (priv->use_riwt)
+		dis_ic = 1;
+
 	napi_disable(&priv->napi);
 
 	/* Stop TX/RX DMA */
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index a1547ea..de5b2f8 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -104,6 +104,7 @@ struct plat_stmmacenet_data {
 	int bugged_jumbo;
 	int pmt;
 	int force_sf_dma_mode;
+	int riwt_off;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
 	int (*init)(struct platform_device *pdev);
-- 
1.7.4.4

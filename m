From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 4/7] stmmac: add Rx watchdog optimization to mitigate the DMA irqs
Date: Wed,  5 Sep 2012 17:03:49 +0200
Message-ID: <1346857432-24657-5-git-send-email-peppe.cavallaro@st.com>
References: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:47586 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752249Ab2IEPEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 11:04:21 -0400
In-Reply-To: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GMAC devices newer than databook 3.50 has an embedded timer
that can be used for mitigating the number of interrupts.
So this patch adds this optimizations.
Old MAC will continue to use NAPI.
At any rate, the Rx watchdog can be disable (on bugged HW) by
passing from the platform the riwt_off field.

In this implementation the rx timer stored in the Reg9 is fixed
to the max value.

V2: added a platform parameter to force to disable the rx-watchdog
for example on new core where it is bugged.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    7 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    3 -
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    6 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   72 ++++++++++++++------
 include/linux/stmmac.h                             |    1 +
 7 files changed, 68 insertions(+), 25 deletions(-)

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
+	/* Manage HW RX Watchdog*/
+	void (*rx_watchdog) (void __iomem *ioaddr, u8 timer);
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
 
+static void dwmac1000_rx_watchdog(void __iomem *ioaddr, u8 timer)
+{
+	writel(timer, ioaddr + DMA_RX_WATCHDOG);
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
index 0f5ab28..c113f28 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -89,6 +89,7 @@ struct stmmac_priv {
 	int eee_active;
 	int tx_lpi_timer;
 	struct timer_list txtimer;
+	int napi_mode;
 	u32 tx_count_frames;
 	u32 tx_coal_frames;
 	u32 tx_coal_timer;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d7f5482..55bb3c9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -133,6 +133,7 @@ MODULE_PARM_DESC(eee_timer, "LPI tx expiration time in msec");
 #define STMMAC_LPI_TIMER(x) (jiffies + msecs_to_jiffies(x))
 
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id);
+static int stmmac_rx(struct stmmac_priv *priv, int limit);
 
 #ifdef CONFIG_STMMAC_DEBUG_FS
 static int stmmac_init_fs(struct net_device *dev);
@@ -516,7 +517,7 @@ static void init_dma_desc_rings(struct net_device *dev)
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int rxsize = priv->dma_rx_size;
 	unsigned int bfsize;
-	int dis_ic = 0;
+	int dis_ic = 1;
 	int des3_as_data_buf = 0;
 
 	/* Set the max buffer size according to the DESC mode
@@ -603,6 +604,8 @@ static void init_dma_desc_rings(struct net_device *dev)
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 
+	if (priv->napi_mode)
+		dis_ic = 0;
 	/* Clear the Rx/Tx descriptors */
 	priv->hw->desc->init_rx_desc(priv->dma_rx, rxsize, dis_ic);
 	priv->hw->desc->init_tx_desc(priv->dma_tx, txsize);
@@ -746,7 +749,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 				skb_recycle_check(skb, priv->dma_buf_sz))
 				__skb_queue_head(&priv->rx_recycle, skb);
 			else
-				dev_kfree_skb(skb);
+				dev_kfree_skb_any(skb);
 
 			priv->tx_skbuff[entry] = NULL;
 		}
@@ -816,12 +819,15 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	netif_wake_queue(priv->dev);
 }
 
-static void stmmac_rx_schedule(struct stmmac_priv *priv)
+static void stmmac_rx_work(struct stmmac_priv *priv)
 {
-	if (likely(napi_schedule_prep(&priv->napi))) {
-		stmmac_disable_irq(priv);
-		__napi_schedule(&priv->napi);
-	}
+	if (priv->napi_mode) {
+		if (likely(napi_schedule_prep(&priv->napi))) {
+			stmmac_disable_irq(priv);
+			__napi_schedule(&priv->napi);
+		}
+	} else
+		stmmac_rx(priv, priv->dma_rx_size);
 }
 
 static void stmmac_dma_interrupt(struct stmmac_priv *priv)
@@ -831,7 +837,7 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
 	if (likely(status == handle_rx)) {
 		priv->xstats.rx_normal_irq_n++;
-		stmmac_rx_schedule(priv);
+		stmmac_rx_work(priv);
 	}
 	if (likely(status == handle_tx)) {
 		priv->xstats.tx_normal_irq_n++;
@@ -1139,7 +1145,17 @@ static int stmmac_open(struct net_device *dev)
 	if (!ret)
 		add_timer(&priv->txtimer);
 
-	napi_enable(&priv->napi);
+	/* Enable NAPI on chip older than the 3.50 where the Rx watchdog
+	 * is not supported.
+	 */
+	if (priv->napi_mode)
+		napi_enable(&priv->napi);
+	else if (priv->hw->dma->rx_watchdog)
+		/* Program RX Watchdog register to the default values
+		 * FIXME: provide user value for RIWT
+		 */
+		priv->hw->dma->rx_watchdog(priv->ioaddr, DEFAULT_DMA_RIWT);
+
 	skb_queue_head_init(&priv->rx_recycle);
 	netif_start_queue(dev);
 
@@ -1183,7 +1199,8 @@ static int stmmac_release(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-	napi_disable(&priv->napi);
+	if (priv->napi_mode)
+		napi_disable(&priv->napi);
 	skb_queue_purge(&priv->rx_recycle);
 
 	/* Free the IRQ lines */
@@ -1448,14 +1465,15 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
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
+
+			if (priv->napi_mode)
 				napi_gro_receive(&priv->napi, skb);
-			}
+			else
+				netif_rx(skb);
 
 			priv->dev->stats.rx_packets++;
 			priv->dev->stats.rx_bytes += frame_len;
@@ -2025,7 +2043,15 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	if (flow_ctrl)
 		priv->flow_ctrl = FLOW_AUTO;	/* RX/TX pause on */
 
-	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
+	/* Rx Watchdog is available in MAC newer than the 3.40.
+	 * In some case, for example on bugged HW, this feature
+	 * has to be disable and this can be done by passing the
+	 * riwt_off field from the platform. In this case we will use NAPI. */
+	if ((priv->synopsys_id < DWMAC_CORE_3_50) || (priv->plat->riwt_off)) {
+		priv->napi_mode = 1;
+		netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
+	} else
+		pr_info(" Enable RX mitigation via HW Watchdog Timer\n");
 
 	spin_lock_init(&priv->lock);
 	spin_lock_init(&priv->tx_lock);
@@ -2068,7 +2094,8 @@ error_mdio_register:
 error_clk_get:
 	unregister_netdev(ndev);
 error_netdev_register:
-	netif_napi_del(&priv->napi);
+	if (priv->napi_mode)
+		netif_napi_del(&priv->napi);
 	free_netdev(ndev);
 
 	return NULL;
@@ -2102,7 +2129,7 @@ int stmmac_dvr_remove(struct net_device *ndev)
 int stmmac_suspend(struct net_device *ndev)
 {
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	int dis_ic = 0;
+	int dis_ic = 1;
 	unsigned long flags;
 
 	if (!ndev || !netif_running(ndev))
@@ -2116,8 +2143,10 @@ int stmmac_suspend(struct net_device *ndev)
 	netif_device_detach(ndev);
 	netif_stop_queue(ndev);
 
-	napi_disable(&priv->napi);
-
+	if (priv->napi_mode) {
+		dis_ic = 0;
+		napi_disable(&priv->napi);
+	}
 	/* Stop TX/RX DMA */
 	priv->hw->dma->stop_tx(priv->ioaddr);
 	priv->hw->dma->stop_rx(priv->ioaddr);
@@ -2166,7 +2195,8 @@ int stmmac_resume(struct net_device *ndev)
 	priv->hw->dma->start_tx(priv->ioaddr);
 	priv->hw->dma->start_rx(priv->ioaddr);
 
-	napi_enable(&priv->napi);
+	if (priv->napi_mode)
+		napi_enable(&priv->napi);
 
 	netif_start_queue(ndev);
 
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

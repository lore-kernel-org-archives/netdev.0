From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/1 net-next] NET: FEC: dynamtic check DMA desc buff type
Date: Thu, 27 Dec 2012 17:10:47 +0800
Message-ID: <1356599447-5698-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <shawn.guo@linaro.org>,
	<netdev@vger.kernel.org>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <davem@davemloft.net>, <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:25736
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751243Ab2L0Jur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 04:50:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MX6 and mx28 support enhanced DMA descript buff to support 1588
ptp. But MX25, MX3x, MX5x can't support enhanced DMA descript buff.
Check fec type and choose correct DAM descript buff type.

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/Kconfig |    2 +-
 drivers/net/ethernet/freescale/fec.c   |  155 ++++++++++++++++++++++++--------
 drivers/net/ethernet/freescale/fec.h   |    8 ++-
 3 files changed, 126 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index ec490d7..d1edb2e 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -94,7 +94,7 @@ config GIANFAR
 
 config FEC_PTP
 	bool "PTP Hardware Clock (PHC)"
-	depends on FEC && ARCH_MXC && !SOC_IMX25 && !SOC_IMX27 && !SOC_IMX35 && !SOC_IMX5
+	depends on FEC && ARCH_MXC
 	select PTP_1588_CLOCK
 	--help---
 	  Say Y here if you want to use PTP Hardware Clock (PHC) in the
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 0704bca..21f385d 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -76,6 +76,8 @@
 #define FEC_QUIRK_USE_GASKET		(1 << 2)
 /* Controller has GBIT support */
 #define FEC_QUIRK_HAS_GBIT		(1 << 3)
+/* Controller has extend desc buffer */
+#define FEC_QUICK_HAS_BUFDESC_EX	(1 << 4)
 
 static struct platform_device_id fec_devtype[] = {
 	{
@@ -93,7 +95,8 @@ static struct platform_device_id fec_devtype[] = {
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME,
 	}, {
 		.name = "imx6q-fec",
-		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT,
+		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
+				FEC_QUICK_HAS_BUFDESC_EX,
 	}, {
 		/* sentinel */
 	}
@@ -117,7 +120,9 @@ static const struct of_device_id fec_dt_ids[] = {
 MODULE_DEVICE_TABLE(of, fec_dt_ids);
 
 static unsigned char macaddr[ETH_ALEN];
+static int fec_ptp_enable = 1;
 module_param_array(macaddr, byte, NULL, 0);
+module_param(fec_ptp_enable, int, 1);
 MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 
 #if defined(CONFIG_M5272)
@@ -144,6 +149,12 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #error "FEC: descriptor ring size constants too large"
 #endif
 
+#ifdef CONFIG_FEC_PTP
+#if (((RX_RING_SIZE + TX_RING_SIZE) * 32) > PAGE_SIZE)
+#error "FEC: descriptor ring size constants too large"
+#endif
+#endif
+
 /* Interrupt events/masks. */
 #define FEC_ENET_HBERR	((uint)0x80000000)	/* Heartbeat error */
 #define FEC_ENET_BABR	((uint)0x40000000)	/* Babbling receiver */
@@ -192,6 +203,36 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 
 static int mii_cnt;
 
+#ifdef CONFIG_FEC_PTP
+static struct bufdesc * get_nextdesc(struct bufdesc * bdp, int is_ex)
+{
+	struct bufdesc_ex *ex = (struct bufdesc_ex *)bdp;
+	if (is_ex)
+		return (struct bufdesc*)(ex++);
+	else
+		return bdp++;
+}
+
+static struct bufdesc * get_prevdesc(struct bufdesc * bdp, int is_ex)
+{
+	struct bufdesc_ex *ex = (struct bufdesc_ex *)bdp;
+	if (is_ex)
+		return (struct bufdesc*)(ex--);
+	else
+		return bdp--;
+}
+#else
+static inline struct bufdesc * get_nextdesc(struct bufdesc * bdp, int is_ex)
+{
+	return bdp++;
+}
+static inline struct bufdesc * get_prevdesc(struct bufdesc * bdp, int is_ex)
+{
+	return bdp--;
+}
+
+#endif
+
 static void *swap_buffer(void *bufaddr, int len)
 {
 	int i;
@@ -248,7 +289,15 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	 */
 	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
 		unsigned int index;
+#ifdef CONFIG_FEC_PTP
+		if (fep->bufdesc_ex)
+			index = (struct bufdesc_ex*)bdp -
+				(struct bufdesc_ex*)fep->tx_bd_base;
+		else
+			index = bdp - fep->tx_bd_base;
+#else
 		index = bdp - fep->tx_bd_base;
+#endif
 		memcpy(fep->tx_bounce[index], skb->data, skb->len);
 		bufaddr = fep->tx_bounce[index];
 	}
@@ -281,14 +330,18 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	bdp->cbd_sc = status;
 
 #ifdef CONFIG_FEC_PTP
-	bdp->cbd_bdu = 0;
-	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
+	if (fep->bufdesc_ex)
+	{
+		struct bufdesc_ex * ebdp = (struct bufdesc_ex *)bdp;
+		ebdp->cbd_bdu = 0;
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
 			fep->hwts_tx_en)) {
-			bdp->cbd_esc = (BD_ENET_TX_TS | BD_ENET_TX_INT);
+			ebdp->cbd_esc = (BD_ENET_TX_TS | BD_ENET_TX_INT);
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-	} else {
+		} else {
 
-		bdp->cbd_esc = BD_ENET_TX_INT;
+			ebdp->cbd_esc = BD_ENET_TX_INT;
+		}
 	}
 #endif
 	/* Trigger transmission start */
@@ -298,7 +351,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (status & BD_ENET_TX_WRAP)
 		bdp = fep->tx_bd_base;
 	else
-		bdp++;
+		bdp = get_nextdesc(bdp, fep->bufdesc_ex);
 
 	if (bdp == fep->dirty_tx) {
 		fep->tx_full = 1;
@@ -359,8 +412,12 @@ fec_restart(struct net_device *ndev, int duplex)
 
 	/* Set receive and transmit descriptor base. */
 	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
-	writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc) * RX_RING_SIZE,
-			fep->hwp + FEC_X_DES_START);
+	if (fep->bufdesc_ex)
+		writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc_ex)
+			* RX_RING_SIZE, fep->hwp + FEC_X_DES_START);
+	else
+		writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc)
+			* RX_RING_SIZE,	fep->hwp + FEC_X_DES_START);
 
 	fep->dirty_tx = fep->cur_tx = fep->tx_bd_base;
 	fep->cur_rx = fep->rx_bd_base;
@@ -449,7 +506,8 @@ fec_restart(struct net_device *ndev, int duplex)
 	}
 
 #ifdef CONFIG_FEC_PTP
-	ecntl |= (1 << 4);
+	if (fep->bufdesc_ex)
+		ecntl |= (1 << 4);
 #endif
 
 	/* And last, enable the transmit and receive processing */
@@ -457,7 +515,8 @@ fec_restart(struct net_device *ndev, int duplex)
 	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
 
 #ifdef CONFIG_FEC_PTP
-	fec_ptp_start_cyclecounter(ndev);
+	if (fep->bufdesc_ex)
+		fec_ptp_start_cyclecounter(ndev);
 #endif
 	/* Enable interrupts we wish to service */
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
@@ -545,14 +604,16 @@ fec_enet_tx(struct net_device *ndev)
 		}
 
 #ifdef CONFIG_FEC_PTP
-		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS) &&
+			fep->bufdesc_ex) {
 			struct skb_shared_hwtstamps shhwtstamps;
 			unsigned long flags;
+			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
 
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
 			spin_lock_irqsave(&fep->tmreg_lock, flags);
 			shhwtstamps.hwtstamp = ns_to_ktime(
-				timecounter_cyc2time(&fep->tc, bdp->ts));
+				timecounter_cyc2time(&fep->tc, ebdp->ts));
 			spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 			skb_tstamp_tx(skb, &shhwtstamps);
 		}
@@ -575,7 +636,7 @@ fec_enet_tx(struct net_device *ndev)
 		if (status & BD_ENET_TX_WRAP)
 			bdp = fep->tx_bd_base;
 		else
-			bdp++;
+			bdp = get_nextdesc(bdp, fep->bufdesc_ex);
 
 		/* Since we have freed up a buffer, the ring is no longer full
 		 */
@@ -685,16 +746,18 @@ fec_enet_rx(struct net_device *ndev)
 			skb->protocol = eth_type_trans(skb, ndev);
 #ifdef CONFIG_FEC_PTP
 			/* Get receive timestamp from the skb */
-			if (fep->hwts_rx_en) {
+			if (fep->hwts_rx_en && fep->bufdesc_ex) {
 				struct skb_shared_hwtstamps *shhwtstamps =
 							    skb_hwtstamps(skb);
 				unsigned long flags;
+				struct bufdesc_ex *ebdp =
+					(struct bufdesc_ex *)bdp;
 
 				memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 
 				spin_lock_irqsave(&fep->tmreg_lock, flags);
 				shhwtstamps->hwtstamp = ns_to_ktime(
-				    timecounter_cyc2time(&fep->tc, bdp->ts));
+				    timecounter_cyc2time(&fep->tc, ebdp->ts));
 				spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 			}
 #endif
@@ -713,16 +776,20 @@ rx_processing_done:
 		bdp->cbd_sc = status;
 
 #ifdef CONFIG_FEC_PTP
-		bdp->cbd_esc = BD_ENET_RX_INT;
-		bdp->cbd_prot = 0;
-		bdp->cbd_bdu = 0;
+		if (fep->bufdesc_ex) {
+			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
+
+			ebdp->cbd_esc = BD_ENET_RX_INT;
+			ebdp->cbd_prot = 0;
+			ebdp->cbd_bdu = 0;
+		}
 #endif
 
 		/* Update BD pointer to next entry */
 		if (status & BD_ENET_RX_WRAP)
 			bdp = fep->rx_bd_base;
 		else
-			bdp++;
+			bdp = get_nextdesc(bdp, fep->bufdesc_ex);
 		/* Doing this here will keep the FEC running while we process
 		 * incoming frames.  On a heavily loaded network, we should be
 		 * able to keep up at the expense of system resources.
@@ -1158,7 +1225,7 @@ static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 		return -ENODEV;
 
 #ifdef CONFIG_FEC_PTP
-	if (cmd == SIOCSHWTSTAMP)
+	if (cmd == SIOCSHWTSTAMP && fep->bufdesc_ex)
 		return fec_ptp_ioctl(ndev, rq, cmd);
 #endif
 	return phy_mii_ioctl(phydev, rq, cmd);
@@ -1180,7 +1247,7 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
 		if (skb)
 			dev_kfree_skb(skb);
-		bdp++;
+		bdp = get_nextdesc(bdp, fep->bufdesc_ex);
 	}
 
 	bdp = fep->tx_bd_base;
@@ -1208,13 +1275,16 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
 		bdp->cbd_sc = BD_ENET_RX_EMPTY;
 #ifdef CONFIG_FEC_PTP
-		bdp->cbd_esc = BD_ENET_RX_INT;
+		if (fep->bufdesc_ex) {
+			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
+			ebdp->cbd_esc = BD_ENET_RX_INT;
+		}
 #endif
-		bdp++;
+		bdp = get_nextdesc(bdp, fep->bufdesc_ex);
 	}
 
 	/* Set the last buffer to wrap. */
-	bdp--;
+	bdp = get_prevdesc(bdp, fep->bufdesc_ex);
 	bdp->cbd_sc |= BD_SC_WRAP;
 
 	bdp = fep->tx_bd_base;
@@ -1225,13 +1295,16 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 		bdp->cbd_bufaddr = 0;
 
 #ifdef CONFIG_FEC_PTP
-		bdp->cbd_esc = BD_ENET_RX_INT;
+		if (fep->bufdesc_ex) {
+			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
+			ebdp->cbd_esc = BD_ENET_RX_INT;
+		}
 #endif
-		bdp++;
+		bdp = get_nextdesc(bdp, fep->bufdesc_ex);
 	}
 
 	/* Set the last buffer to wrap. */
-	bdp--;
+	bdp = get_prevdesc(bdp, fep->bufdesc_ex);
 	bdp->cbd_sc |= BD_SC_WRAP;
 
 	return 0;
@@ -1444,7 +1517,11 @@ static int fec_enet_init(struct net_device *ndev)
 
 	/* Set receive and transmit descriptor base. */
 	fep->rx_bd_base = cbd_base;
-	fep->tx_bd_base = cbd_base + RX_RING_SIZE;
+	if (fep->bufdesc_ex)
+		fep->tx_bd_base = (struct bufdesc*)
+			(((struct bufdesc_ex*)cbd_base + RX_RING_SIZE));
+	else
+		fep->tx_bd_base = cbd_base + RX_RING_SIZE;
 
 	/* The FEC Ethernet specific entries in the device structure */
 	ndev->watchdog_timeo = TX_TIMEOUT;
@@ -1457,11 +1534,11 @@ static int fec_enet_init(struct net_device *ndev)
 
 		/* Initialize the BD for every fragment in the page. */
 		bdp->cbd_sc = 0;
-		bdp++;
+		bdp = get_nextdesc(bdp, fep->bufdesc_ex);
 	}
 
 	/* Set the last buffer to wrap */
-	bdp--;
+	bdp = get_prevdesc(bdp, fep->bufdesc_ex);
 	bdp->cbd_sc |= BD_SC_WRAP;
 
 	/* ...and the same for transmit */
@@ -1471,11 +1548,11 @@ static int fec_enet_init(struct net_device *ndev)
 		/* Initialize the BD for every fragment in the page. */
 		bdp->cbd_sc = 0;
 		bdp->cbd_bufaddr = 0;
-		bdp++;
+		bdp = get_nextdesc(bdp, fep->bufdesc_ex);
 	}
 
 	/* Set the last buffer to wrap */
-	bdp--;
+	bdp = get_prevdesc(bdp, fep->bufdesc_ex);
 	bdp->cbd_sc |= BD_SC_WRAP;
 
 	fec_restart(ndev, 0);
@@ -1574,6 +1651,8 @@ fec_probe(struct platform_device *pdev)
 	fep->pdev = pdev;
 	fep->dev_id = dev_id++;
 
+	fep->bufdesc_ex = 0;
+
 	if (!fep->hwp) {
 		ret = -ENOMEM;
 		goto failed_ioremap;
@@ -1630,16 +1709,19 @@ fec_probe(struct platform_device *pdev)
 
 #ifdef CONFIG_FEC_PTP
 	fep->clk_ptp = devm_clk_get(&pdev->dev, "ptp");
+	fep->bufdesc_ex = fec_ptp_enable ?
+		pdev->id_entry->driver_data & FEC_QUICK_HAS_BUFDESC_EX : 0;
 	if (IS_ERR(fep->clk_ptp)) {
 		ret = PTR_ERR(fep->clk_ptp);
-		goto failed_clk;
+		fep->bufdesc_ex = 0;
 	}
 #endif
 
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
 #ifdef CONFIG_FEC_PTP
-	clk_prepare_enable(fep->clk_ptp);
+	if (!IS_ERR(fep->clk_ptp))
+		clk_prepare_enable(fep->clk_ptp);
 #endif
 	reg_phy = devm_regulator_get(&pdev->dev, "phy");
 	if (!IS_ERR(reg_phy)) {
@@ -1669,7 +1751,8 @@ fec_probe(struct platform_device *pdev)
 		goto failed_register;
 
 #ifdef CONFIG_FEC_PTP
-	fec_ptp_init(ndev, pdev);
+	if (fep->bufdesc_ex)
+		fec_ptp_init(ndev, pdev);
 #endif
 
 	return 0;
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index c5a3bc1..53f19d3 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -94,14 +94,17 @@ struct bufdesc {
 	unsigned short cbd_datlen;	/* Data length */
 	unsigned short cbd_sc;	/* Control and status info */
 	unsigned long cbd_bufaddr;	/* Buffer address */
-#ifdef CONFIG_FEC_PTP
+};
+
+struct bufdesc_ex {
+	struct bufdesc desc;
 	unsigned long cbd_esc;
 	unsigned long cbd_prot;
 	unsigned long cbd_bdu;
 	unsigned long ts;
 	unsigned short res0[4];
-#endif
 };
+
 #else
 struct bufdesc {
 	unsigned short	cbd_sc;			/* Control and status info */
@@ -243,6 +246,7 @@ struct fec_enet_private {
 	int	full_duplex;
 	struct	completion mdio_done;
 	int	irq[FEC_IRQ_NUM];
+	int	bufdesc_ex;
 
 #ifdef CONFIG_FEC_PTP
 	struct ptp_clock *ptp_clock;
-- 
1.7.1

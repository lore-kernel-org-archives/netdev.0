From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v2 1/1 net-next] net: fec: add napi support to improve proformance
Date: Thu, 24 Jan 2013 15:58:29 +0800
Message-ID: <1359014309-8636-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <s.hauer@pengutronix.de>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:17008
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750717Ab3AXIgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 03:36:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add napi support

Before this patch

 iperf -s -i 1
 ------------------------------------------------------------
 Server listening on TCP port 5001
 TCP window size: 85.3 KByte (default)
 ------------------------------------------------------------
 [  4] local 10.192.242.153 port 5001 connected with 10.192.242.138 port 50004
 [ ID] Interval       Transfer     Bandwidth
 [  4]  0.0- 1.0 sec  41.2 MBytes   345 Mbits/sec
 [  4]  1.0- 2.0 sec  43.7 MBytes   367 Mbits/sec
 [  4]  2.0- 3.0 sec  42.8 MBytes   359 Mbits/sec
 [  4]  3.0- 4.0 sec  43.7 MBytes   367 Mbits/sec
 [  4]  4.0- 5.0 sec  42.7 MBytes   359 Mbits/sec
 [  4]  5.0- 6.0 sec  43.8 MBytes   367 Mbits/sec
 [  4]  6.0- 7.0 sec  43.0 MBytes   361 Mbits/sec

After this patch
 [  4]  2.0- 3.0 sec  51.6 MBytes   433 Mbits/sec
 [  4]  3.0- 4.0 sec  51.8 MBytes   435 Mbits/sec
 [  4]  4.0- 5.0 sec  52.2 MBytes   438 Mbits/sec
 [  4]  5.0- 6.0 sec  52.1 MBytes   437 Mbits/sec
 [  4]  6.0- 7.0 sec  52.1 MBytes   437 Mbits/sec
 [  4]  7.0- 8.0 sec  52.3 MBytes   439 Mbits/sec

Signed-off-by: Frank Li <Frank.Li@freescale.com>
Signed-off-by: Fugang Duan <B38611@freescale.com>
---
Change from v1 to v2
 * Remove use_napi and napi_weight config. Support NAPI only.
 * using napi_gro_receive replace netif_rx

 drivers/net/ethernet/freescale/fec.c |   56 +++++++++++++++++++++++++++++-----
 drivers/net/ethernet/freescale/fec.h |    2 +
 2 files changed, 50 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index f52ba33..39be2ab 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -67,6 +67,7 @@
 #endif
 
 #define DRIVER_NAME	"fec"
+#define FEC_NAPI_WEIGHT	64
 
 /* Pause frame feild and FIFO threshold */
 #define FEC_ENET_FCE	(1 << 5)
@@ -565,6 +566,20 @@ fec_timeout(struct net_device *ndev)
 }
 
 static void
+fec_enet_rx_int_is_enabled(struct net_device *ndev, bool enabled)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	uint    int_events;
+
+	int_events = readl(fep->hwp + FEC_IMASK);
+	if (enabled)
+		int_events |= FEC_ENET_RXF;
+	else
+		int_events &= ~FEC_ENET_RXF;
+	writel(int_events, fep->hwp + FEC_IMASK);
+}
+
+static void
 fec_enet_tx(struct net_device *ndev)
 {
 	struct	fec_enet_private *fep;
@@ -656,8 +671,8 @@ fec_enet_tx(struct net_device *ndev)
  * not been given to the system, we just set the empty indicator,
  * effectively tossing the packet.
  */
-static void
-fec_enet_rx(struct net_device *ndev)
+static int
+fec_enet_rx(struct net_device *ndev, int budget)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	const struct platform_device_id *id_entry =
@@ -667,13 +682,12 @@ fec_enet_rx(struct net_device *ndev)
 	struct	sk_buff	*skb;
 	ushort	pkt_len;
 	__u8 *data;
+	int	pkt_received = 0;
 
 #ifdef CONFIG_M532x
 	flush_cache_all();
 #endif
 
-	spin_lock(&fep->hw_lock);
-
 	/* First, grab all of the stats for the incoming packet.
 	 * These get messed up if we get called due to a busy condition.
 	 */
@@ -681,6 +695,10 @@ fec_enet_rx(struct net_device *ndev)
 
 	while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 
+		if (pkt_received >= budget)
+			break;
+		pkt_received++;
+
 		/* Since we have allocated space to hold a complete frame,
 		 * the last indicator should be set.
 		 */
@@ -762,7 +780,7 @@ fec_enet_rx(struct net_device *ndev)
 			}
 
 			if (!skb_defer_rx_timestamp(skb))
-				netif_rx(skb);
+				napi_gro_receive(&fep->napi, skb);
 		}
 
 		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, data,
@@ -796,7 +814,7 @@ rx_processing_done:
 	}
 	fep->cur_rx = bdp;
 
-	spin_unlock(&fep->hw_lock);
+	return pkt_received;
 }
 
 static irqreturn_t
@@ -805,6 +823,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 	struct net_device *ndev = dev_id;
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	uint int_events;
+	ulong flags;
 	irqreturn_t ret = IRQ_NONE;
 
 	do {
@@ -813,7 +832,14 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 		if (int_events & FEC_ENET_RXF) {
 			ret = IRQ_HANDLED;
-			fec_enet_rx(ndev);
+
+			spin_lock_irqsave(&fep->hw_lock, flags);
+			/* Disable the RX interrupt */
+			if (napi_schedule_prep(&fep->napi)) {
+				fec_enet_rx_int_is_enabled(ndev, false);
+				__napi_schedule(&fep->napi);
+			}
+			spin_unlock_irqrestore(&fep->hw_lock, flags);
 		}
 
 		/* Transmit OK, or non-fatal error. Update the buffer
@@ -834,7 +860,16 @@ fec_enet_interrupt(int irq, void *dev_id)
 	return ret;
 }
 
-
+static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
+{
+	struct net_device *ndev = napi->dev;
+	int pkgs = fec_enet_rx(ndev, budget);
+	if (pkgs < budget) {
+		napi_complete(napi);
+		fec_enet_rx_int_is_enabled(ndev, true);
+	}
+	return pkgs;
+}
 
 /* ------------------------------------------------------------------------- */
 static void fec_get_mac(struct net_device *ndev)
@@ -1392,6 +1427,8 @@ fec_enet_open(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int ret;
 
+	napi_enable(&fep->napi);
+
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
 	 */
@@ -1604,6 +1641,9 @@ static int fec_enet_init(struct net_device *ndev)
 	ndev->netdev_ops = &fec_netdev_ops;
 	ndev->ethtool_ops = &fec_enet_ethtool_ops;
 
+	fec_enet_rx_int_is_enabled(ndev, false);
+	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
+
 	/* Initialize the receive buffer descriptors. */
 	bdp = fep->rx_bd_base;
 	for (i = 0; i < RX_RING_SIZE; i++) {
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 2ebedaf..01579b8 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -249,6 +249,8 @@ struct fec_enet_private {
 	int	bufdesc_ex;
 	int	pause_flag;
 
+	struct	napi_struct napi;
+
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_caps;
 	unsigned long last_overflow_check;
-- 
1.7.1

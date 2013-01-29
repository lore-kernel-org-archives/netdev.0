From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v4 1/1 net-next] net: fec: add napi support to improve proformance
Date: Tue, 29 Jan 2013 12:31:42 +0800
Message-ID: <1359433903-15605-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <s.hauer@pengutronix.de>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:37380 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751200Ab3A2FL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 00:11:26 -0500
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
Change from v3 to v4
 * remove lock to enable\disable rx irq. write expected reg value directly,
   avoid read and write back. 
 
Change from v2 to v3
 * replace fec_enet_rx_int_is_enabled with fec_enet_rx_int_enable
 * replace spin_lock_saveirq with spin_lock in irq handle

Change from v1 to v2
 * Remove use_napi and napi_weight config. Support NAPI only.
 * using napi_gro_receive replace netif_rx

 drivers/net/ethernet/freescale/fec.c |   41 ++++++++++++++++++++++++++++-----
 drivers/net/ethernet/freescale/fec.h |    2 +
 2 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index f52ba33..0287675 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -67,6 +67,7 @@
 #endif
 
 #define DRIVER_NAME	"fec"
+#define FEC_NAPI_WEIGHT	64
 
 /* Pause frame feild and FIFO threshold */
 #define FEC_ENET_FCE	(1 << 5)
@@ -168,6 +169,7 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #define FEC_ENET_EBERR	((uint)0x00400000)	/* SDMA bus error */
 
 #define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII)
+#define FEC_RX_DISABLED_IMASK (FEC_DEFAULT_IMASK & (~FEC_ENET_RXF))
 
 /* The FEC stores dest/src/type, data, and checksum for receive packets.
  */
@@ -656,8 +658,8 @@ fec_enet_tx(struct net_device *ndev)
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
@@ -667,13 +669,12 @@ fec_enet_rx(struct net_device *ndev)
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
@@ -681,6 +682,10 @@ fec_enet_rx(struct net_device *ndev)
 
 	while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 
+		if (pkt_received >= budget)
+			break;
+		pkt_received++;
+
 		/* Since we have allocated space to hold a complete frame,
 		 * the last indicator should be set.
 		 */
@@ -762,7 +767,7 @@ fec_enet_rx(struct net_device *ndev)
 			}
 
 			if (!skb_defer_rx_timestamp(skb))
-				netif_rx(skb);
+				napi_gro_receive(&fep->napi, skb);
 		}
 
 		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, data,
@@ -796,7 +801,7 @@ rx_processing_done:
 	}
 	fep->cur_rx = bdp;
 
-	spin_unlock(&fep->hw_lock);
+	return pkt_received;
 }
 
 static irqreturn_t
@@ -813,7 +818,13 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 		if (int_events & FEC_ENET_RXF) {
 			ret = IRQ_HANDLED;
-			fec_enet_rx(ndev);
+
+			/* Disable the RX interrupt */
+			if (napi_schedule_prep(&fep->napi)) {
+				writel(FEC_RX_DISABLED_IMASK,
+					fep->hwp + FEC_IMASK);
+				__napi_schedule(&fep->napi);
+			}
 		}
 
 		/* Transmit OK, or non-fatal error. Update the buffer
@@ -834,7 +845,18 @@ fec_enet_interrupt(int irq, void *dev_id)
 	return ret;
 }
 
+static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
+{
+	struct net_device *ndev = napi->dev;
+	int pkts = fec_enet_rx(ndev, budget);
+	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	if (pkts < budget) {
+		napi_complete(napi);
+		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+	}
+	return pkts;
+}
 
 /* ------------------------------------------------------------------------- */
 static void fec_get_mac(struct net_device *ndev)
@@ -1392,6 +1414,8 @@ fec_enet_open(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int ret;
 
+	napi_enable(&fep->napi);
+
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
 	 */
@@ -1604,6 +1628,9 @@ static int fec_enet_init(struct net_device *ndev)
 	ndev->netdev_ops = &fec_netdev_ops;
 	ndev->ethtool_ops = &fec_enet_ethtool_ops;
 
+	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
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

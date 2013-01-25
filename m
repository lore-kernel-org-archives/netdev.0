From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v3 1/1 net-next] net: fec: add napi support to improve
 proformance
Date: Fri, 25 Jan 2013 09:29:03 +0800
Message-ID: <1359077343-8271-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
 <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
 <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

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
Change from v2 to v3
 * replace fec_enet_rx_int_is_enabled with fec_enet_rx_int_enable
 * replace spin_lock_saveirq with spin_lock in irq handle

Change from v1 to v2
 * Remove use_napi and napi_weight config. Support NAPI only.
 * using napi_gro_receive replace netif_rx

 drivers/net/ethernet/freescale/fec.c |   55 +++++++++++++++++++++++++++++-----
 drivers/net/ethernet/freescale/fec.h |    2 +
 2 files changed, 49 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index f52ba33..1d9e019 100644
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
+fec_enet_rx_int_enable(struct net_device *ndev, bool enabled)
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
@@ -813,7 +831,14 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 		if (int_events & FEC_ENET_RXF) {
 			ret = IRQ_HANDLED;
-			fec_enet_rx(ndev);
+
+			spin_lock(&fep->hw_lock);
+			/* Disable the RX interrupt */
+			if (napi_schedule_prep(&fep->napi)) {
+				fec_enet_rx_int_enable(ndev, false);
+				__napi_schedule(&fep->napi);
+			}
+			spin_unlock(&fep->hw_lock);
 		}
 
 		/* Transmit OK, or non-fatal error. Update the buffer
@@ -834,7 +859,16 @@ fec_enet_interrupt(int irq, void *dev_id)
 	return ret;
 }
 
-
+static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
+{
+	struct net_device *ndev = napi->dev;
+	int pkgs = fec_enet_rx(ndev, budget);
+	if (pkgs < budget) {
+		napi_complete(napi);
+		fec_enet_rx_int_enable(ndev, true);
+	}
+	return pkgs;
+}
 
 /* ------------------------------------------------------------------------- */
 static void fec_get_mac(struct net_device *ndev)
@@ -1392,6 +1426,8 @@ fec_enet_open(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int ret;
 
+	napi_enable(&fep->napi);
+
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
 	 */
@@ -1604,6 +1640,9 @@ static int fec_enet_init(struct net_device *ndev)
 	ndev->netdev_ops = &fec_netdev_ops;
 	ndev->ethtool_ops = &fec_enet_ethtool_ops;
 
+	fec_enet_rx_int_enable(ndev, false);
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

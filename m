From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH 3/3] Revert "net: fec: add napi support to improve proformance"
Date: Fri, 19 Apr 2013 16:36:04 +0200
Message-ID: <1366382164-10968-4-git-send-email-l.stach@pengutronix.de>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Fabio Estevam <festevam@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60804 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030614Ab3DSOhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 10:37:10 -0400
In-Reply-To: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit dc975382d2ef36be7e78fac3717927de1a5abcd8.

Conflicts:
	drivers/net/ethernet/freescale/fec.c

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec.c | 41 ++++++------------------------------
 drivers/net/ethernet/freescale/fec.h |  2 --
 2 files changed, 7 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index d2f7983..b01c612 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -68,7 +68,6 @@
 #endif
 
 #define DRIVER_NAME	"fec"
-#define FEC_NAPI_WEIGHT	64
 
 /* Pause frame feild and FIFO threshold */
 #define FEC_ENET_FCE	(1 << 5)
@@ -170,7 +169,6 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #define FEC_ENET_EBERR	((uint)0x00400000)	/* SDMA bus error */
 
 #define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII)
-#define FEC_RX_DISABLED_IMASK (FEC_DEFAULT_IMASK & (~FEC_ENET_RXF))
 
 /* The FEC stores dest/src/type, data, and checksum for receive packets.
  */
@@ -704,8 +702,8 @@ fec_enet_tx(struct net_device *ndev)
  * not been given to the system, we just set the empty indicator,
  * effectively tossing the packet.
  */
-static int
-fec_enet_rx(struct net_device *ndev, int budget)
+static void
+fec_enet_rx(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	const struct platform_device_id *id_entry =
@@ -715,12 +713,13 @@ fec_enet_rx(struct net_device *ndev, int budget)
 	struct	sk_buff	*skb;
 	ushort	pkt_len;
 	__u8 *data;
-	int	pkt_received = 0;
 
 #ifdef CONFIG_M532x
 	flush_cache_all();
 #endif
 
+	spin_lock(&fep->hw_lock);
+
 	/* First, grab all of the stats for the incoming packet.
 	 * These get messed up if we get called due to a busy condition.
 	 */
@@ -728,10 +727,6 @@ fec_enet_rx(struct net_device *ndev, int budget)
 
 	while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 
-		if (pkt_received >= budget)
-			break;
-		pkt_received++;
-
 		/* Since we have allocated space to hold a complete frame,
 		 * the last indicator should be set.
 		 */
@@ -813,7 +808,7 @@ fec_enet_rx(struct net_device *ndev, int budget)
 			}
 
 			if (!skb_defer_rx_timestamp(skb))
-				napi_gro_receive(&fep->napi, skb);
+				netif_rx(skb);
 		}
 
 		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, data,
@@ -847,7 +842,7 @@ rx_processing_done:
 	}
 	fep->cur_rx = bdp;
 
-	return pkt_received;
+	spin_unlock(&fep->hw_lock);
 }
 
 static irqreturn_t
@@ -864,13 +859,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 		if (int_events & FEC_ENET_RXF) {
 			ret = IRQ_HANDLED;
-
-			/* Disable the RX interrupt */
-			if (napi_schedule_prep(&fep->napi)) {
-				writel(FEC_RX_DISABLED_IMASK,
-					fep->hwp + FEC_IMASK);
-				__napi_schedule(&fep->napi);
-			}
+			fec_enet_rx(ndev);
 		}
 
 		/* Transmit OK, or non-fatal error. Update the buffer
@@ -891,18 +880,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 	return ret;
 }
 
-static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
-{
-	struct net_device *ndev = napi->dev;
-	int pkts = fec_enet_rx(ndev, budget);
-	struct fec_enet_private *fep = netdev_priv(ndev);
 
-	if (pkts < budget) {
-		napi_complete(napi);
-		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
-	}
-	return pkts;
-}
 
 /* ------------------------------------------------------------------------- */
 static void fec_get_mac(struct net_device *ndev)
@@ -1487,8 +1465,6 @@ fec_enet_open(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int ret;
 
-	napi_enable(&fep->napi);
-
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
 	 */
@@ -1700,9 +1676,6 @@ static int fec_enet_init(struct net_device *ndev)
 	ndev->netdev_ops = &fec_netdev_ops;
 	ndev->ethtool_ops = &fec_enet_ethtool_ops;
 
-	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
-	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
-
 	fec_restart(ndev, 0);
 
 	return 0;
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index ca20331..4195842 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -250,8 +250,6 @@ struct fec_enet_private {
 	int	bufdesc_ex;
 	int	pause_flag;
 
-	struct	napi_struct napi;
-
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_caps;
 	unsigned long last_overflow_check;
-- 
1.8.2.rc2

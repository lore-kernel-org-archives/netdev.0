From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v8 02/20] CAN : Divide poll function
Date: Tue, 07 Dec 2010 20:03:15 +0900
Message-ID: <4CFE1473.2020107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To easy to read/understand, divide poll function into two sub-functions.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   71 ++++++++++++++++++++++-----------------------
 1 files changed, 35 insertions(+), 36 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index f0f1404..0b6d4f4 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -819,72 +819,71 @@ RX_NEXT:
 
 	return rcv_pkts;
 }
-static int pch_can_rx_poll(struct napi_struct *napi, int quota)
+
+static void pch_can_tx_complete(struct net_device *ndev, u32 int_stat)
 {
-	struct net_device *ndev = napi->dev;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &(priv->ndev->stats);
 	u32 dlc;
+
+	can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_END - 1);
+	iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
+		  &priv->regs->ifregs[1].cmask);
+	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, int_stat);
+	dlc = get_can_dlc(ioread32(&priv->regs->ifregs[1].mcont) &
+			  PCH_IF_MCONT_DLC);
+	stats->tx_bytes += dlc;
+	stats->tx_packets++;
+	if (int_stat == PCH_TX_OBJ_END)
+		netif_wake_queue(ndev);
+}
+
+static int pch_can_rx_poll(struct napi_struct *napi, int quota)
+{
+	struct net_device *ndev = napi->dev;
+	struct pch_can_priv *priv = netdev_priv(ndev);
 	u32 int_stat;
 	int rcv_pkts = 0;
 	u32 reg_stat;
 
 	int_stat = pch_can_int_pending(priv);
 	if (!int_stat)
-		return 0;
+		goto end;
 
-INT_STAT:
-	if (int_stat == PCH_STATUS_INT) {
+	if ((int_stat == PCH_STATUS_INT) && (quota > 0)) {
 		reg_stat = ioread32(&priv->regs->stat);
 		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
-			if ((reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL)
+			if (reg_stat & PCH_BUS_OFF ||
+			   (reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL) {
 				pch_can_error(ndev, reg_stat);
+				quota--;
+			}
 		}
 
-		if (reg_stat & PCH_TX_OK) {
-			iowrite32(PCH_CMASK_RX_TX_GET,
-				  &priv->regs->ifregs[1].cmask);
-			pch_can_check_if_busy(&priv->regs->ifregs[1].creq,
-					       ioread32(&priv->regs->intr));
+		if (reg_stat & PCH_TX_OK)
 			pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
-		}
 
 		if (reg_stat & PCH_RX_OK)
 			pch_can_bit_clear(&priv->regs->stat, PCH_RX_OK);
 
 		int_stat = pch_can_int_pending(priv);
-		if (int_stat == PCH_STATUS_INT)
-			goto INT_STAT;
 	}
 
-MSG_OBJ:
+	if (quota == 0)
+		goto end;
+
 	if ((int_stat >= PCH_RX_OBJ_START) && (int_stat <= PCH_RX_OBJ_END)) {
-		rcv_pkts = pch_can_rx_normal(ndev, int_stat);
-		if (rcv_pkts < 0)
-			return 0;
+		rcv_pkts += pch_can_rx_normal(ndev, int_stat);
+		quota -= rcv_pkts;
+		if (quota < 0)
+			goto end;
 	} else if ((int_stat >= PCH_TX_OBJ_START) &&
 		   (int_stat <= PCH_TX_OBJ_END)) {
 		/* Handle transmission interrupt */
-		can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_END - 1);
-		iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
-			  &priv->regs->ifregs[1].cmask);
-		dlc = ioread32(&priv->regs->ifregs[1].mcont) &
-			       PCH_IF_MCONT_DLC;
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, int_stat);
-		if (dlc > 8)
-			dlc = 8;
-		stats->tx_bytes += dlc;
-		stats->tx_packets++;
-		if (int_stat == PCH_TX_OBJ_END)
-			netif_wake_queue(ndev);
+		pch_can_tx_complete(ndev, int_stat);
 	}
 
-	int_stat = pch_can_int_pending(priv);
-	if (int_stat == PCH_STATUS_INT)
-		goto INT_STAT;
-	else if (int_stat >= 1 && int_stat <= 32)
-		goto MSG_OBJ;
-
+end:
 	napi_complete(napi);
 	pch_can_set_int_enables(priv, PCH_CAN_ALL);
 
-- 
1.6.0.6

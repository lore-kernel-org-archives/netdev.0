From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 16/17] can: EG20T PCH: Fix incorrect return processing
Date: Fri, 19 Nov 2010 14:51:08 +0900
Message-ID: <4CE6104C.3090401__5938.6019748219$1290145926$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:15215 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751998Ab0KSFv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 00:51:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix incorrect return processing

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index c612a99..48f4a2e 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -589,10 +589,12 @@ static irqreturn_t pch_can_interrupt(int irq, void *dev_id)
 	struct net_device *ndev = (struct net_device *)dev_id;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 
-	pch_can_set_int_enables(priv, PCH_CAN_NONE);
-	napi_schedule(&priv->napi);
-
-	return IRQ_HANDLED;
+	if ((pch_can_int_pending(priv) > 0) && (dev_id != NULL)) {
+		pch_can_set_int_enables(priv, PCH_CAN_NONE);
+		napi_schedule(&priv->napi);
+		return IRQ_HANDLED;
+	}
+	return IRQ_NONE;
 }
 
 static void pch_fifo_thresh(struct pch_can_priv *priv, int obj_id)
@@ -674,7 +676,7 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int quota)
 		if (reg & PCH_IF_MCONT_MSGLOST) {
 			rtn = pch_can_rx_msg_lost(ndev, obj_num);
 			if (!rtn)
-				return rtn;
+				return rcv_pkts;
 			rcv_pkts++;
 			quota--;
 			obj_num++;
@@ -777,10 +779,12 @@ static int pch_can_poll(struct napi_struct *napi, int quota)
 		goto end;
 
 	if ((int_stat >= PCH_RX_OBJ_START) && (int_stat <= PCH_RX_OBJ_END)) {
-		rcv_pkts += pch_can_rx_normal(ndev, int_stat, quota);
-		quota -= rcv_pkts;
-		if (quota < 0)
+		rcv_pkts = pch_can_rx_normal(ndev, int_stat, quota);
+		if (rcv_pkts < 0) {
+			rcv_pkts = 0;
 			goto end;
+		}
+		quota -= rcv_pkts;
 	} else if ((int_stat >= PCH_TX_OBJ_START) &&
 		   (int_stat <= PCH_TX_OBJ_END)) {
 		/* Handle transmission interrupt */
-- 
1.6.0.6


From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 16/17 v2] can: EG20T PCH: Fix incorrect return
 processing
Date: Wed, 24 Nov 2010 16:39:04 +0900
Message-ID: <4CECC118.9070301__2086.78834974325$1290584421$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:32107 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752203Ab0KXHja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 02:39:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix incorrect return processing

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index c612a99..ecb1a8c 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -589,9 +589,11 @@ static irqreturn_t pch_can_interrupt(int irq, void
*dev_id)
 	struct net_device *ndev = (struct net_device *)dev_id;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 +	if (!pch_can_int_pending(priv))
+		return IRQ_NONE;
+
 	pch_can_set_int_enables(priv, PCH_CAN_NONE);
 	napi_schedule(&priv->napi);
-
 	return IRQ_HANDLED;
 }
 @@ -674,7 +676,7 @@ static int pch_can_rx_normal(struct net_device
*ndev, u32 obj_num, int quota)
 		if (reg & PCH_IF_MCONT_MSGLOST) {
 			rtn = pch_can_rx_msg_lost(ndev, obj_num);
 			if (!rtn)
-				return rtn;
+				return rcv_pkts;
 			rcv_pkts++;
 			quota--;
 			obj_num++;
@@ -685,8 +687,10 @@ static int pch_can_rx_normal(struct net_device
*ndev, u32 obj_num, int quota)
 		}
  		skb = alloc_can_skb(priv->ndev, &cf);
-		if (!skb)
-			return -ENOMEM;
+		if (!skb) {
+			netdev_err(ndev, "alloc_can_skb Failed\n");
+			return rcv_pkts;
+		}
  		/* Get Received data */
 		id2 = ioread32(&priv->regs->ifregs[0].id2);
@@ -747,8 +751,8 @@ static int pch_can_poll(struct napi_struct *napi,
int quota)
 	struct net_device *ndev = napi->dev;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	u32 int_stat;
-	int rcv_pkts = 0;
 	u32 reg_stat;
+	int quota_save = quota;
  	int_stat = pch_can_int_pending(priv);
 	if (!int_stat)
@@ -777,10 +781,7 @@ static int pch_can_poll(struct napi_struct *napi,
int quota)
 		goto end;
  	if ((int_stat >= PCH_RX_OBJ_START) && (int_stat <= PCH_RX_OBJ_END)) {
-		rcv_pkts += pch_can_rx_normal(ndev, int_stat, quota);
-		quota -= rcv_pkts;
-		if (quota < 0)
-			goto end;
+		quota -= pch_can_rx_normal(ndev, int_stat, quota);
 	} else if ((int_stat >= PCH_TX_OBJ_START) &&
 		   (int_stat <= PCH_TX_OBJ_END)) {
 		/* Handle transmission interrupt */
@@ -791,7 +792,7 @@ end:
 	napi_complete(napi);
 	pch_can_set_int_enables(priv, PCH_CAN_ALL);
 -	return rcv_pkts;
+	return (quota_save - quota);
 }
  static int pch_set_bittiming(struct net_device *ndev)
-- 
1.6.0.6


From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v6 03/20] can: EG20T PCH: Enumerate LEC macros
Date: Tue, 30 Nov 2010 13:16:15 +0900
Message-ID: <4CF47A8F.4090605__35689.8126927719$1291090639$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:17020 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751974Ab0K3EQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 23:16:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For easy to readable, LEC #define macros are replaced to enums.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   77 ++++++++++++++++++++++++---------------------
 1 files changed, 41 insertions(+), 36 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 982ff2d..2d4ab0f 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -71,21 +71,12 @@
 #define PCH_REC			0x00007f00
 #define PCH_TEC			0x000000ff
 
+
 #define PCH_TX_OK		BIT(3)
 #define PCH_RX_OK		BIT(4)
 #define PCH_EPASSIV		BIT(5)
 #define PCH_EWARN		BIT(6)
 #define PCH_BUS_OFF		BIT(7)
-#define PCH_LEC0		BIT(0)
-#define PCH_LEC1		BIT(1)
-#define PCH_LEC2		BIT(2)
-#define PCH_LEC_ALL		(PCH_LEC0 | PCH_LEC1 | PCH_LEC2)
-#define PCH_STUF_ERR		PCH_LEC0
-#define PCH_FORM_ERR		PCH_LEC1
-#define PCH_ACK_ERR		(PCH_LEC0 | PCH_LEC1)
-#define PCH_BIT1_ERR		PCH_LEC2
-#define PCH_BIT0_ERR		(PCH_LEC0 | PCH_LEC2)
-#define PCH_CRC_ERR		(PCH_LEC1 | PCH_LEC2)
 
 /* bit position of certain controller bits. */
 #define PCH_BIT_BRP		0
@@ -117,6 +108,16 @@ enum pch_ifreg {
 	PCH_TX_IFREG,
 };
 
+enum pch_can_err {
+	PCH_STUF_ERR = 1,
+	PCH_FORM_ERR,
+	PCH_ACK_ERR,
+	PCH_BIT1_ERR,
+	PCH_BIT0_ERR,
+	PCH_CRC_ERR,
+	PCH_LEC_ALL,
+};
+
 enum pch_can_mode {
 	PCH_CAN_ENABLE,
 	PCH_CAN_DISABLE,
@@ -620,7 +621,7 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 	struct sk_buff *skb;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct can_frame *cf;
-	u32 errc;
+	u32 errc, lec;
 	struct net_device_stats *stats = &(priv->ndev->stats);
 	enum can_state state = priv->can.state;
 
@@ -665,33 +666,37 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 			"%s -> CAN controller is ERROR PASSIVE .\n", __func__);
 	}
 
-	if (status & PCH_LEC_ALL) {
+	lec = status & PCH_LEC_ALL;
+	switch (lec) {
+	case PCH_STUF_ERR:
+		cf->data[2] |= CAN_ERR_PROT_STUFF;
 		priv->can.can_stats.bus_error++;
 		stats->rx_errors++;
-		switch (status & PCH_LEC_ALL) {
-		case PCH_STUF_ERR:
-			cf->data[2] |= CAN_ERR_PROT_STUFF;
-			break;
-		case PCH_FORM_ERR:
-			cf->data[2] |= CAN_ERR_PROT_FORM;
-			break;
-		case PCH_ACK_ERR:
-			cf->data[2] |= CAN_ERR_PROT_LOC_ACK |
-				       CAN_ERR_PROT_LOC_ACK_DEL;
-			break;
-		case PCH_BIT1_ERR:
-		case PCH_BIT0_ERR:
-			cf->data[2] |= CAN_ERR_PROT_BIT;
-			break;
-		case PCH_CRC_ERR:
-			cf->data[2] |= CAN_ERR_PROT_LOC_CRC_SEQ |
-				       CAN_ERR_PROT_LOC_CRC_DEL;
-			break;
-		default:
-			iowrite32(status | PCH_LEC_ALL, &priv->regs->stat);
-			break;
-		}
-
+		break;
+	case PCH_FORM_ERR:
+		cf->data[2] |= CAN_ERR_PROT_FORM;
+		priv->can.can_stats.bus_error++;
+		stats->rx_errors++;
+		break;
+	case PCH_ACK_ERR:
+		cf->can_id |= CAN_ERR_ACK;
+		priv->can.can_stats.bus_error++;
+		stats->rx_errors++;
+		break;
+	case PCH_BIT1_ERR:
+	case PCH_BIT0_ERR:
+		cf->data[2] |= CAN_ERR_PROT_BIT;
+		priv->can.can_stats.bus_error++;
+		stats->rx_errors++;
+		break;
+	case PCH_CRC_ERR:
+		cf->data[2] |= CAN_ERR_PROT_LOC_CRC_SEQ |
+			       CAN_ERR_PROT_LOC_CRC_DEL;
+		priv->can.can_stats.bus_error++;
+		stats->rx_errors++;
+		break;
+	case PCH_LEC_ALL: /* Written by CPU. No error status */
+		break;
 	}
 
 	priv->can.state = state;
-- 
1.6.0.6

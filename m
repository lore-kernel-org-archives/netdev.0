From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 3/17 v2] can: EG20T PCH: Enumerate some macros
Date: Wed, 24 Nov 2010 16:35:24 +0900
Message-ID: <4CECC03C.1030104__33669.0809148878$1290584187$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:11230 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750969Ab0KXHfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 02:35:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For easy to readable, LEC and interface register number macros are
replaced to enums.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   90
+++++++++++++++++++++++++--------------------
 1 files changed, 50 insertions(+), 40 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index b028ae4..5c21f5c 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -69,21 +69,12 @@
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
@@ -96,9 +87,6 @@
 #define PCH_MSK_CTRL_IE_SIE_EIE	0x07
 #define PCH_COUNTER_LIMIT	10
 -#define PCH_RX_IFREG			0
-#define PCH_TX_IFREG			1
-
 #define PCH_CAN_CLK		50000000	/* 50MHz */
  /* Define the number of message object.
@@ -113,6 +101,21 @@
  #define PCH_FIFO_THRESH		16
 +enum pch_ifreg {
+	PCH_RX_IFREG,
+	PCH_TX_IFREG,
+};
+
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
@@ -302,7 +305,7 @@ static void pch_can_check_if_busy(u32 __iomem
*creq_addr, u32 num)
 }
  static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
-				  int set, u32 dir)
+			     int set, enum pch_ifreg dir)
 {
 	unsigned long flags;
 	u32 ie;
@@ -616,7 +619,7 @@ static void pch_can_error(struct net_device *ndev,
u32 status)
 	struct sk_buff *skb;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct can_frame *cf;
-	u32 errc;
+	u32 errc, lec;
 	struct net_device_stats *stats = &(priv->ndev->stats);
 	enum can_state state = priv->can.state;
 @@ -661,35 +664,42 @@ static void pch_can_error(struct net_device
*ndev, u32 status)
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
 +	cf->data[6] = errc & PCH_TEC;
+	cf->data[7] = (errc & PCH_REC) >> 8;
+
 	priv->can.state = state;
 	netif_rx(skb);
 -- 1.6.0.6


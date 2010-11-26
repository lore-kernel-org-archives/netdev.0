From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 02/19 v5] can: EG20T PCH: Change Message Object
 Index
Date: Fri, 26 Nov 2010 11:04:21 +0900
Message-ID: <4CEF15A5.7070309__6355.01447036422$1290737123$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:30213 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752941Ab0KZCEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 21:04:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Message Object index macro name.
 For easy to readable, add Message Object index like below.
 PCH_RX_OBJ_START
 PCH_RX_OBJ_END
 PCH_TX_OBJ_START
 PCH_TX_OBJ_END

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |  263 ++++++++++++++++++++-------------------------
 1 files changed, 116 insertions(+), 147 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index dae8ed1..982ff2d 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -32,10 +32,6 @@
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
-#define PCH_MAX_MSG_OBJ		32
-#define PCH_MSG_OBJ_RX		0 /* The receive message object flag. */
-#define PCH_MSG_OBJ_TX		1 /* The transmit message object flag. */
-
 #define PCH_ENABLE		1 /* The enable flag */
 #define PCH_DISABLE		0 /* The disable flag */
 #define PCH_CTRL_INIT		BIT(0) /* The INIT bit of CANCONT register. */
@@ -107,9 +103,12 @@
 /* Define the number of message object.
  * PCH CAN communications are done via Message RAM.
  * The Message RAM consists of 32 message objects. */
-#define PCH_RX_OBJ_NUM		26  /* 1~ PCH_RX_OBJ_NUM is Rx*/
-#define PCH_TX_OBJ_NUM		6  /* PCH_RX_OBJ_NUM is RX ~ Tx*/
-#define PCH_OBJ_NUM		(PCH_TX_OBJ_NUM + PCH_RX_OBJ_NUM)
+#define PCH_RX_OBJ_NUM		26
+#define PCH_TX_OBJ_NUM		6
+#define PCH_RX_OBJ_START	1
+#define PCH_RX_OBJ_END		PCH_RX_OBJ_NUM
+#define PCH_TX_OBJ_START	(PCH_RX_OBJ_END + 1)
+#define PCH_TX_OBJ_END		(PCH_RX_OBJ_NUM + PCH_TX_OBJ_NUM)
 
 #define PCH_FIFO_THRESH		16
 
@@ -172,14 +171,14 @@ struct pch_can_priv {
 	struct can_priv can;
 	unsigned int can_num;
 	struct pci_dev *dev;
-	unsigned int tx_enable[PCH_MAX_MSG_OBJ];
-	unsigned int rx_enable[PCH_MAX_MSG_OBJ];
-	unsigned int rx_link[PCH_MAX_MSG_OBJ];
+	int tx_enable[PCH_TX_OBJ_END];
+	int rx_enable[PCH_TX_OBJ_END];
+	int rx_link[PCH_TX_OBJ_END];
 	unsigned int int_enables;
 	unsigned int int_stat;
 	struct net_device *ndev;
 	spinlock_t msgif_reg_lock; /* Message Interface Registers Access Lock*/
-	unsigned int msg_obj[PCH_MAX_MSG_OBJ];
+	unsigned int msg_obj[PCH_TX_OBJ_END];
 	struct pch_can_regs __iomem *regs;
 	struct napi_struct napi;
 	unsigned int tx_obj;	/* Point next Tx Obj index */
@@ -347,10 +346,8 @@ static void pch_can_set_rx_all(struct pch_can_priv *priv, u32 set)
 	int i;
 
 	/* Traversing to obtain the object configured as receivers. */
-	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX)
-			pch_can_set_rxtx(priv, i + 1, set, PCH_RX_IFREG);
-	}
+	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++)
+		pch_can_set_rxtx(priv, i, set, PCH_RX_IFREG);
 }
 
 static void pch_can_set_tx_all(struct pch_can_priv *priv, u32 set)
@@ -358,10 +355,8 @@ static void pch_can_set_tx_all(struct pch_can_priv *priv, u32 set)
 	int i;
 
 	/* Traversing to obtain the object configured as transmit object. */
-	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX)
-			pch_can_set_rxtx(priv, i + 1, set, PCH_TX_IFREG);
-	}
+	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++)
+		pch_can_set_rxtx(priv, i, set, PCH_TX_IFREG);
 }
 
 static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num,
@@ -381,9 +376,9 @@ static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num,
 
 	if (((ioread32(&priv->regs->ifregs[dir].id2)) & PCH_ID_MSGVAL) &&
 			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie)) {
-		enable = PCH_ENABLE;
+		enable = 1;
 	} else {
-		enable = PCH_DISABLE;
+		enable = 0;
 	}
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 	return enable;
@@ -434,7 +429,7 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 {
 	int i;
 
-	for (i = 0; i < PCH_RX_OBJ_NUM; i++) {
+	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
 		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[0].cmask);
 		iowrite32(0xffff, &priv->regs->ifregs[0].mask1);
 		iowrite32(0xffff, &priv->regs->ifregs[0].mask2);
@@ -448,10 +443,10 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->ifregs[0].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i+1);
+		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i);
 	}
 
-	for (i = i;  i < PCH_OBJ_NUM; i++) {
+	for (i = PCH_TX_OBJ_START;  i <= PCH_TX_OBJ_END; i++) {
 		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[1].cmask);
 		iowrite32(0xffff, &priv->regs->ifregs[1].mask1);
 		iowrite32(0xffff, &priv->regs->ifregs[1].mask2);
@@ -465,7 +460,7 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->ifregs[1].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i+1);
+		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
 	}
 }
 
@@ -476,64 +471,62 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 
-	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX) {
-			iowrite32(PCH_CMASK_RX_TX_GET,
-				&priv->regs->ifregs[0].cmask);
-			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i+1);
+	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
+		iowrite32(PCH_CMASK_RX_TX_GET,
+			&priv->regs->ifregs[0].cmask);
+		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i);
 
-			iowrite32(0x0, &priv->regs->ifregs[0].id1);
-			iowrite32(0x0, &priv->regs->ifregs[0].id2);
+		iowrite32(0x0, &priv->regs->ifregs[0].id1);
+		iowrite32(0x0, &priv->regs->ifregs[0].id2);
 
-			pch_can_bit_set(&priv->regs->ifregs[0].mcont,
-					PCH_IF_MCONT_UMASK);
+		pch_can_bit_set(&priv->regs->ifregs[0].mcont,
+				PCH_IF_MCONT_UMASK);
 
-			/* Set FIFO mode set to 0 except last Rx Obj*/
-			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
+		/* Set FIFO mode set to 0 except last Rx Obj*/
+		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
+				  PCH_IF_MCONT_EOB);
+		/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
+		if (i == PCH_RX_OBJ_END)
+			pch_can_bit_set(&priv->regs->ifregs[0].mcont,
 					  PCH_IF_MCONT_EOB);
-			/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
-			if (i == (PCH_RX_OBJ_NUM - 1))
-				pch_can_bit_set(&priv->regs->ifregs[0].mcont,
-						  PCH_IF_MCONT_EOB);
-
-			iowrite32(0, &priv->regs->ifregs[0].mask1);
-			pch_can_bit_clear(&priv->regs->ifregs[0].mask2,
-					  0x1fff | PCH_MASK2_MDIR_MXTD);
-
-			/* Setting CMASK for writing */
-			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
-				  PCH_CMASK_ARB | PCH_CMASK_CTRL,
-				  &priv->regs->ifregs[0].cmask);
 
-			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i+1);
-		} else if (priv->msg_obj[i] == PCH_MSG_OBJ_TX) {
-			iowrite32(PCH_CMASK_RX_TX_GET,
-				&priv->regs->ifregs[1].cmask);
-			pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i+1);
+		iowrite32(0, &priv->regs->ifregs[0].mask1);
+		pch_can_bit_clear(&priv->regs->ifregs[0].mask2,
+				  0x1fff | PCH_MASK2_MDIR_MXTD);
 
-			/* Resetting DIR bit for reception */
-			iowrite32(0x0, &priv->regs->ifregs[1].id1);
-			iowrite32(0x0, &priv->regs->ifregs[1].id2);
-			pch_can_bit_set(&priv->regs->ifregs[1].id2,
-					PCH_ID2_DIR);
+		/* Setting CMASK for writing */
+		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
+			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
+			  &priv->regs->ifregs[0].cmask);
 
-			/* Setting EOB bit for transmitter */
-			iowrite32(PCH_IF_MCONT_EOB,
-				  &priv->regs->ifregs[1].mcont);
+		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i);
+	}
 
-			pch_can_bit_set(&priv->regs->ifregs[1].mcont,
-					PCH_IF_MCONT_UMASK);
+	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++) {
+		iowrite32(PCH_CMASK_RX_TX_GET,
+			&priv->regs->ifregs[1].cmask);
+		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
 
-			iowrite32(0, &priv->regs->ifregs[1].mask1);
-			pch_can_bit_clear(&priv->regs->ifregs[1].mask2, 0x1fff);
+		/* Resetting DIR bit for reception */
+		iowrite32(0x0, &priv->regs->ifregs[1].id1);
+		iowrite32(0x0, &priv->regs->ifregs[1].id2);
+		pch_can_bit_set(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);
 
-			/* Setting CMASK for writing */
-			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
-				  PCH_CMASK_ARB | PCH_CMASK_CTRL,
-				  &priv->regs->ifregs[1].cmask);
+		/* Setting EOB bit for transmitter */
+		iowrite32(PCH_IF_MCONT_EOB, &priv->regs->ifregs[1].mcont);
 
-			pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i+1);
-		}
+		pch_can_bit_set(&priv->regs->ifregs[1].mcont,
+				PCH_IF_MCONT_UMASK);
+
+		iowrite32(0, &priv->regs->ifregs[1].mask1);
+		pch_can_bit_clear(&priv->regs->ifregs[1].mask2, 0x1fff);
+
+		/* Setting CMASK for writing */
+		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
+			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
+			  &priv->regs->ifregs[1].cmask);
+
+		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
 	}
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }
@@ -577,7 +570,20 @@ static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 	}
 
 	/* Clear interrupt for transmit object */
-	if (priv->msg_obj[mask - 1] == PCH_MSG_OBJ_TX) {
+	if ((mask >= PCH_RX_OBJ_START) && (mask <= PCH_RX_OBJ_END)) {
+		/* Setting CMASK for clearing the reception interrupts. */
+		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
+			  &priv->regs->ifregs[0].cmask);
+
+		/* Clearing the Dir bit. */
+		pch_can_bit_clear(&priv->regs->ifregs[0].id2, PCH_ID2_DIR);
+
+		/* Clearing NewDat & IntPnd */
+		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
+				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND);
+
+		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, mask);
+	} else if ((mask >= PCH_TX_OBJ_START) && (mask <= PCH_TX_OBJ_END)) {
 		/* Setting CMASK for clearing interrupts for
 					 frame transmission. */
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
@@ -593,19 +599,6 @@ static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
 				  PCH_IF_MCONT_TXRQXT);
 		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, mask);
-	} else if (priv->msg_obj[mask - 1] == PCH_MSG_OBJ_RX) {
-		/* Setting CMASK for clearing the reception interrupts. */
-		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
-			  &priv->regs->ifregs[0].cmask);
-
-		/* Clearing the Dir bit. */
-		pch_can_bit_clear(&priv->regs->ifregs[0].id2, PCH_ID2_DIR);
-
-		/* Clearing NewDat & IntPnd */
-		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
-				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND);
-
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, mask);
 	}
 }
 
@@ -793,8 +786,8 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 			cf->can_dlc = 0;
 			cf->can_id |= CAN_RTR_FLAG;
 		} else {
-			cf->can_dlc = ((ioread32(&priv->regs->ifregs[0].mcont))
-						 & 0x0f);
+			cf->can_dlc =
+			      ((ioread32(&priv->regs->ifregs[0].mcont)) & 0x0f);
 		}
 
 		for (i = 0, j = 0; i < cf->can_dlc; j++) {
@@ -832,7 +825,7 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 RX_NEXT:
 		/* Reading the messsage object from the Message RAM */
 		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k + 1);
+		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);
 		reg = ioread32(&priv->regs->ifregs[0].mcont);
 	}
 
@@ -880,29 +873,27 @@ INT_STAT:
 	}
 
 MSG_OBJ:
-	if ((int_stat >= 1) && (int_stat <= PCH_RX_OBJ_NUM)) {
+	if ((int_stat >= PCH_RX_OBJ_START) && (int_stat <= PCH_RX_OBJ_END)) {
 		spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 		rcv_pkts = pch_can_rx_normal(ndev, int_stat);
 		spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 		if (rcv_pkts < 0)
 			return 0;
-	} else if ((int_stat > PCH_RX_OBJ_NUM) && (int_stat <= PCH_OBJ_NUM)) {
-		if (priv->msg_obj[int_stat - 1] == PCH_MSG_OBJ_TX) {
-			/* Handle transmission interrupt */
-			can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_NUM - 1);
-			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-			iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
-				  &priv->regs->ifregs[1].cmask);
-			dlc = ioread32(&priv->regs->ifregs[1].mcont) &
-				       PCH_IF_MCONT_DLC;
-			pch_can_check_if_busy(&priv->regs->ifregs[1].creq,
-					      int_stat);
-			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
-			if (dlc > 8)
-				dlc = 8;
-			stats->tx_bytes += dlc;
-			stats->tx_packets++;
-		}
+	} else if ((int_stat >= PCH_TX_OBJ_START) &&
+		   (int_stat <= PCH_TX_OBJ_END)) {
+		/* Handle transmission interrupt */
+		can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_END - 1);
+		spin_lock_irqsave(&priv->msgif_reg_lock, flags);
+		iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
+			  &priv->regs->ifregs[1].cmask);
+		dlc = ioread32(&priv->regs->ifregs[1].mcont) &
+			       PCH_IF_MCONT_DLC;
+		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, int_stat);
+		spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
+		if (dlc > 8)
+			dlc = 8;
+		stats->tx_bytes += dlc;
+		stats->tx_packets++;
 	}
 
 	int_stat = pch_can_int_pending(priv);
@@ -1064,12 +1055,12 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (can_dropped_invalid_skb(ndev, skb))
 		return NETDEV_TX_OK;
 
-	if (priv->tx_obj == (PCH_OBJ_NUM + 1)) { /* Point tail Obj */
+	if (priv->tx_obj == PCH_TX_OBJ_END) { /* Point tail Obj */
 		while (pch_get_msg_obj_sts(ndev, (((1 << PCH_TX_OBJ_NUM)-1) <<
 					   PCH_RX_OBJ_NUM)))
 			udelay(500);
 
-		priv->tx_obj = PCH_RX_OBJ_NUM + 1; /* Point head of Tx Obj ID */
+		priv->tx_obj = PCH_TX_OBJ_START; /* Point head of Tx Obj ID */
 		tx_buffer_avail = priv->tx_obj; /* Point Tail of Tx Obj */
 	} else {
 		tx_buffer_avail = priv->tx_obj;
@@ -1113,7 +1104,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 			 (&priv->regs->ifregs[1].dataa1) + j*4);
 	}
 
-	can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_NUM - 1);
+	can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_END - 1);
 
 	/* Updating the size of the data. */
 	pch_can_bit_clear(&priv->regs->ifregs[1].mcont, 0x0f);
@@ -1188,23 +1179,16 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 	pch_can_set_int_enables(priv, PCH_CAN_DISABLE);
 
 	/* Save Tx buffer enable state */
-	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX)
-			priv->tx_enable[i] = pch_can_get_rxtx_ir(priv, i + 1,
-								 PCH_TX_IFREG);
-	}
+	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++)
+		priv->tx_enable[i] = pch_can_get_rxtx_ir(priv, i, PCH_TX_IFREG);
 
 	/* Disable all Transmit buffers */
 	pch_can_set_tx_all(priv, 0);
 
 	/* Save Rx buffer enable state */
-	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX) {
-			priv->rx_enable[i] = pch_can_get_rxtx_ir(priv, i + 1,
-						PCH_RX_IFREG);
-			pch_can_get_rx_buffer_link(priv, i + 1,
-						&(priv->rx_link[i]));
-		}
+	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
+		priv->rx_enable[i] = pch_can_get_rxtx_ir(priv, i, PCH_RX_IFREG);
+		pch_can_get_rx_buffer_link(priv, i, &priv->rx_link[i]);
 	}
 
 	/* Disable all Receive buffers */
@@ -1256,24 +1240,16 @@ static int pch_can_resume(struct pci_dev *pdev)
 	pch_can_set_optmode(priv);
 
 	/* Enabling the transmit buffer. */
-	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX)
-			pch_can_set_rxtx(priv, i, priv->tx_enable[i],
-					 PCH_TX_IFREG);
-	}
+	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++)
+		pch_can_set_rxtx(priv, i, priv->tx_enable[i], PCH_TX_IFREG);
 
 	/* Configuring the receive buffer and enabling them. */
-	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX) {
-			/* Restore buffer link */
-			pch_can_set_rx_buffer_link(priv, i + 1,
-						   priv->rx_link[i]);
+	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
+		/* Restore buffer link */
+		pch_can_set_rx_buffer_link(priv, i, priv->rx_link[i]);
 
-			/* Restore buffer enables */
-			pch_can_set_rxtx(priv, i, priv->rx_enable[i],
-					 PCH_RX_IFREG);
-
-		}
+		/* Restore buffer enables */
+		pch_can_set_rxtx(priv, i, priv->rx_enable[i], PCH_RX_IFREG);
 	}
 
 	/* Enable CAN Interrupts */
@@ -1306,7 +1282,6 @@ static int __devinit pch_can_probe(struct pci_dev *pdev,
 	struct net_device *ndev;
 	struct pch_can_priv *priv;
 	int rc;
-	int index;
 	void __iomem *addr;
 
 	rc = pci_enable_device(pdev);
@@ -1328,7 +1303,7 @@ static int __devinit pch_can_probe(struct pci_dev *pdev,
 		goto probe_exit_ipmap;
 	}
 
-	ndev = alloc_candev(sizeof(struct pch_can_priv), PCH_TX_OBJ_NUM);
+	ndev = alloc_candev(sizeof(struct pch_can_priv), PCH_TX_OBJ_END);
 	if (!ndev) {
 		rc = -ENOMEM;
 		dev_err(&pdev->dev, "Failed alloc_candev\n");
@@ -1344,7 +1319,7 @@ static int __devinit pch_can_probe(struct pci_dev *pdev,
 	priv->can.do_get_berr_counter = pch_can_get_berr_counter;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_LISTENONLY |
 				       CAN_CTRLMODE_LOOPBACK;
-	priv->tx_obj = PCH_RX_OBJ_NUM + 1; /* Point head of Tx Obj */
+	priv->tx_obj = PCH_TX_OBJ_START; /* Point head of Tx Obj */
 
 	ndev->irq = pdev->irq;
 	ndev->flags |= IFF_ECHO;
@@ -1352,15 +1327,9 @@ static int __devinit pch_can_probe(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	ndev->netdev_ops = &pch_can_netdev_ops;
-
 	priv->can.clock.freq = PCH_CAN_CLK; /* Hz */
-	for (index = 0; index < PCH_RX_OBJ_NUM;)
-		priv->msg_obj[index++] = PCH_MSG_OBJ_RX;
-
-	for (index = index;  index < PCH_OBJ_NUM;)
-		priv->msg_obj[index++] = PCH_MSG_OBJ_TX;
 
-	netif_napi_add(ndev, &priv->napi, pch_can_rx_poll, PCH_RX_OBJ_NUM);
+	netif_napi_add(ndev, &priv->napi, pch_can_rx_poll, PCH_RX_OBJ_END);
 
 	rc = register_candev(ndev);
 	if (rc) {
-- 
1.6.0.6

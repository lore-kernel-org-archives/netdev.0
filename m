From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 7/17] can: EG20T PCH: Rename function/macro name
Date: Fri, 19 Nov 2010 14:47:08 +0900
Message-ID: <4CE60F5C.9090203__25010.9353023165$1290145693$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:30575 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751444Ab0KSFr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 00:47:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For easy to read/understand, Rename function/macro name.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |  305 ++++++++++++++++++++------------------------
 1 files changed, 139 insertions(+), 166 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index fa47707..8985e16 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -69,7 +69,6 @@
 #define PCH_REC			0x00007f00
 #define PCH_TEC			0x000000ff
 
-
 #define PCH_TX_OK		BIT(3)
 #define PCH_RX_OK		BIT(4)
 #define PCH_EPASSIV		BIT(5)
@@ -77,11 +76,12 @@
 #define PCH_BUS_OFF		BIT(7)
 
 /* bit position of certain controller bits. */
-#define PCH_BIT_BRP		0
-#define PCH_BIT_SJW		6
-#define PCH_BIT_TSEG1		8
-#define PCH_BIT_TSEG2		12
-#define PCH_BIT_BRPE_BRPE	6
+#define PCH_BIT_BRP_SHIFT	0
+#define PCH_BIT_SJW_SHIFT	6
+#define PCH_BIT_TSEG1_SHIFT	8
+#define PCH_BIT_TSEG2_SHIFT	12
+#define PCH_BIT_BRPE_BRPE_SHIFT	6
+
 #define PCH_MSK_BITT_BRP	0x3f
 #define PCH_MSK_BRPE_BRPE	0x3c0
 #define PCH_MSK_CTRL_IE_SIE_EIE	0x07
@@ -101,6 +101,10 @@
 
 #define PCH_FIFO_THRESH		16
 
+/* TxRqst2 show status of MsgObjNo.17~32 */
+#define PCH_TREQ2_TX_MASK	(((1 << PCH_TX_OBJ_NUM) - 1) <<\
+							(PCH_RX_OBJ_END - 16))
+
 enum pch_ifreg {
 	PCH_RX_IFREG,
 	PCH_TX_IFREG,
@@ -240,31 +244,27 @@ static void pch_can_set_optmode(struct pch_can_priv *priv)
 	iowrite32(reg_val, &priv->regs->opt);
 }
 
-static void pch_can_set_int_custom(struct pch_can_priv *priv)
+static void pch_can_rw_msg_obj(u32 __iomem *creq_addr, u32 num)
 {
-	/* Clearing the IE, SIE and EIE bits of Can control register. */
-	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
-
-	/* Appropriately setting them. */
-	pch_can_bit_set(&priv->regs->cont,
-			((priv->int_enables & PCH_MSK_CTRL_IE_SIE_EIE) << 1));
-}
+	u32 counter = PCH_COUNTER_LIMIT;
+	u32 ifx_creq;
 
-/* This function retrieves interrupt enabled for the CAN device. */
-static void pch_can_get_int_enables(struct pch_can_priv *priv, u32 *enables)
-{
-	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
-	*enables = ((ioread32(&priv->regs->cont) & PCH_CTRL_IE_SIE_EIE) >> 1);
+	iowrite32(num, creq_addr);
+	while (counter) {
+		ifx_creq = ioread32(creq_addr) & PCH_IF_CREQ_BUSY;
+		if (!ifx_creq)
+			break;
+		counter--;
+		udelay(1);
+	}
+	if (!counter)
+		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
 }
 
 static void pch_can_set_int_enables(struct pch_can_priv *priv,
 				    enum pch_can_mode interrupt_no)
 {
 	switch (interrupt_no) {
-	case PCH_CAN_ENABLE:
-		pch_can_bit_set(&priv->regs->cont, PCH_CTRL_IE);
-		break;
-
 	case PCH_CAN_DISABLE:
 		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE);
 		break;
@@ -283,23 +283,6 @@ static void pch_can_set_int_enables(struct pch_can_priv *priv,
 	}
 }
 
-static void pch_can_check_if_busy(u32 __iomem *creq_addr, u32 num)
-{
-	u32 counter = PCH_COUNTER_LIMIT;
-	u32 ifx_creq;
-
-	iowrite32(num, creq_addr);
-	while (counter) {
-		ifx_creq = ioread32(creq_addr) & PCH_IF_CREQ_BUSY;
-		if (!ifx_creq)
-			break;
-		counter--;
-		udelay(1);
-	}
-	if (!counter)
-		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
-}
-
 static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 			     int set, enum pch_ifreg dir)
 {
@@ -312,7 +295,7 @@ static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 
 	/* Reading the receive buffer data from RAM to Interface1 registers */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
 
 	/* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
 	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
@@ -329,7 +312,7 @@ static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 		pch_can_bit_clear(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
 	}
 
-	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
 }
 
 
@@ -351,67 +334,16 @@ static void pch_can_set_tx_all(struct pch_can_priv *priv, int set)
 		pch_can_set_rxtx(priv, i, set, 1);
 }
 
-static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num, u32 dir)
-{
-	u32 ie, enable;
-
-	if (dir)
-		ie = PCH_IF_MCONT_RXIE;
-	else
-		ie = PCH_IF_MCONT_TXIE;
-
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
-
-	if (((ioread32(&priv->regs->ifregs[dir].id2)) & PCH_ID_MSGVAL) &&
-			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie)) {
-		enable = 1;
-	} else {
-		enable = 0;
-	}
-	return enable;
-}
-
 static int pch_can_int_pending(struct pch_can_priv *priv)
 {
 	return ioread32(&priv->regs->intr) & 0xffff;
 }
 
-static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
-				       u32 buffer_num, int set)
-{
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
-	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
-		  &priv->regs->ifregs[0].cmask);
-	if (set)
-		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
-				  PCH_IF_MCONT_EOB);
-	else
-		pch_can_bit_set(&priv->regs->ifregs[0].mcont, PCH_IF_MCONT_EOB);
-
-	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
-}
-
-static u32 pch_can_get_rx_buffer_link(struct pch_can_priv *priv, u32 buffer_num)
+static void pch_can_clear_if_buffers(struct pch_can_priv *priv)
 {
-	u32 link;
-
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
+	int i; /* Msg Obj ID (1~32) */
 
-	if (ioread32(&priv->regs->ifregs[0].mcont) & PCH_IF_MCONT_EOB)
-		link = 0;
-	else
-		link = 1;
-	return link;
-}
-
-static void pch_can_clear_buffers(struct pch_can_priv *priv)
-{
-	int i;
-
-	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
+	for (i = PCH_RX_OBJ_START; i <= PCH_TX_OBJ_END; i++) {
 		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[0].cmask);
 		iowrite32(0xffff, &priv->regs->ifregs[0].mask1);
 		iowrite32(0xffff, &priv->regs->ifregs[0].mask2);
@@ -425,24 +357,7 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->ifregs[0].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i);
-	}
-
-	for (i = PCH_TX_OBJ_START;  i <= PCH_TX_OBJ_END; i++) {
-		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[1].cmask);
-		iowrite32(0xffff, &priv->regs->ifregs[1].mask1);
-		iowrite32(0xffff, &priv->regs->ifregs[1].mask2);
-		iowrite32(0x0, &priv->regs->ifregs[1].id1);
-		iowrite32(0x0, &priv->regs->ifregs[1].id2);
-		iowrite32(0x0, &priv->regs->ifregs[1].mcont);
-		iowrite32(0x0, &priv->regs->ifregs[1].data[0]);
-		iowrite32(0x0, &priv->regs->ifregs[1].data[1]);
-		iowrite32(0x0, &priv->regs->ifregs[1].data[2]);
-		iowrite32(0x0, &priv->regs->ifregs[1].data[3]);
-		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
-			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
-			  &priv->regs->ifregs[1].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
 	}
 }
 
@@ -453,7 +368,7 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
 		iowrite32(PCH_CMASK_RX_TX_GET,
 			&priv->regs->ifregs[0].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
 
 		iowrite32(0x0, &priv->regs->ifregs[0].id1);
 		iowrite32(0x0, &priv->regs->ifregs[0].id2);
@@ -461,12 +376,12 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 		pch_can_bit_set(&priv->regs->ifregs[0].mcont,
 				PCH_IF_MCONT_UMASK);
 
-		/* Set FIFO mode set to 0 except last Rx Obj*/
-		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
-				  PCH_IF_MCONT_EOB);
 		/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
 		if (i == PCH_RX_OBJ_END)
 			pch_can_bit_set(&priv->regs->ifregs[0].mcont,
+					PCH_IF_MCONT_EOB);
+		else
+			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 					  PCH_IF_MCONT_EOB);
 
 		iowrite32(0, &priv->regs->ifregs[0].mask1);
@@ -478,24 +393,21 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->ifregs[0].cmask);
 
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
 	}
 
 	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++) {
 		iowrite32(PCH_CMASK_RX_TX_GET,
 			&priv->regs->ifregs[1].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, i);
 
 		/* Resetting DIR bit for reception */
 		iowrite32(0x0, &priv->regs->ifregs[1].id1);
-		iowrite32(0x0, &priv->regs->ifregs[1].id2);
-		pch_can_bit_set(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);
+		iowrite32(PCH_ID2_DIR, &priv->regs->ifregs[1].id2);
 
 		/* Setting EOB bit for transmitter */
-		iowrite32(PCH_IF_MCONT_EOB, &priv->regs->ifregs[1].mcont);
-
-		pch_can_bit_set(&priv->regs->ifregs[1].mcont,
-				PCH_IF_MCONT_UMASK);
+		iowrite32(PCH_IF_MCONT_EOB | PCH_IF_MCONT_UMASK,
+			  &priv->regs->ifregs[1].mcont);
 
 		iowrite32(0, &priv->regs->ifregs[1].mask1);
 		pch_can_bit_clear(&priv->regs->ifregs[1].mask2, 0x1fff);
@@ -505,7 +417,7 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->ifregs[1].cmask);
 
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, i);
 	}
 }
 
@@ -515,7 +427,7 @@ static void pch_can_init(struct pch_can_priv *priv)
 	pch_can_set_run_mode(priv, PCH_CAN_STOP);
 
 	/* Clearing all the message object buffers. */
-	pch_can_clear_buffers(priv);
+	pch_can_clear_if_buffers(priv);
 
 	/* Configuring the respective message object as either rx/tx object. */
 	pch_can_config_rx_tx_buffers(priv);
@@ -560,7 +472,7 @@ static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND);
 
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, mask);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, mask);
 	} else if ((mask >= PCH_TX_OBJ_START) && (mask <= PCH_TX_OBJ_END)) {
 		/* Setting CMASK for clearing interrupts for
 					 frame transmission. */
@@ -576,7 +488,7 @@ static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 		pch_can_bit_clear(&priv->regs->ifregs[1].mcont,
 				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
 				  PCH_IF_MCONT_TXRQXT);
-		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, mask);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, mask);
 	}
 }
 
@@ -616,12 +528,12 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		dev_err(&ndev->dev, "%s -> Bus Off occurres.\n", __func__);
 	}
 
+	errc = ioread32(&priv->regs->errc);
 	/* Warning interrupt. */
 	if (status & PCH_EWARN) {
 		state = CAN_STATE_ERROR_WARNING;
 		priv->can.can_stats.error_warning++;
 		cf->can_id |= CAN_ERR_CRTL;
-		errc = ioread32(&priv->regs->errc);
 		if (((errc & PCH_REC) >> 8) > 96)
 			cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
 		if ((errc & PCH_TEC) > 96)
@@ -634,7 +546,6 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		priv->can.can_stats.error_passive++;
 		state = CAN_STATE_ERROR_PASSIVE;
 		cf->can_id |= CAN_ERR_CRTL;
-		errc = ioread32(&priv->regs->errc);
 		if (((errc & PCH_REC) >> 8) > 127)
 			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
 		if ((errc & PCH_TEC) > 127)
@@ -710,7 +621,7 @@ static void pch_fifo_thresh(struct pch_can_priv *priv, int obj_id)
 		/* Clearing NewDat & IntPnd */
 		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 				  PCH_IF_MCONT_INTPND);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_id);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, obj_id);
 	} else if (obj_id > PCH_FIFO_THRESH) {
 		pch_can_int_clr(priv, obj_id);
 	} else if (obj_id == PCH_FIFO_THRESH) {
@@ -732,7 +643,7 @@ static int pch_can_rx_msg_lost(struct net_device *ndev, int obj_id)
 			  PCH_IF_MCONT_MSGLOST);
 	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
 		  &priv->regs->ifregs[0].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_id);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, obj_id);
 
 	skb = alloc_can_err_skb(ndev, &cf);
 	if (!skb)
@@ -766,7 +677,7 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int quota)
 	do {
 		/* Reading the messsage object from the Message RAM */
 		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
-		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_num);
+		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, obj_num);
 
 		/* Reading the MCONT register. */
 		reg = ioread32(&priv->regs->ifregs[0].mcont);
@@ -841,7 +752,7 @@ static void pch_can_tx_complete(struct net_device *ndev, u32 int_stat)
 		  &priv->regs->ifregs[1].cmask);
 	dlc = get_can_dlc(ioread32(&priv->regs->ifregs[1].mcont) &
 			  PCH_IF_MCONT_DLC);
-	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, int_stat);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, int_stat);
 	stats->tx_bytes += dlc;
 	stats->tx_packets++;
 	if (int_stat == PCH_TX_OBJ_END)
@@ -913,10 +824,10 @@ static int pch_set_bittiming(struct net_device *ndev)
 
 	brp = (bt->tq) / (1000000000/PCH_CAN_CLK) - 1;
 	canbit = brp & PCH_MSK_BITT_BRP;
-	canbit |= (bt->sjw - 1) << PCH_BIT_SJW;
-	canbit |= (bt->phase_seg1 + bt->prop_seg - 1) << PCH_BIT_TSEG1;
-	canbit |= (bt->phase_seg2 - 1) << PCH_BIT_TSEG2;
-	bepe = (brp & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE;
+	canbit |= (bt->sjw - 1) << PCH_BIT_SJW_SHIFT;
+	canbit |= (bt->phase_seg1 + bt->prop_seg - 1) << PCH_BIT_TSEG1_SHIFT;
+	canbit |= (bt->phase_seg2 - 1) << PCH_BIT_TSEG2_SHIFT;
+	bepe = (brp & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE_SHIFT;
 	iowrite32(canbit, &priv->regs->bitt);
 	iowrite32(bepe, &priv->regs->brpe);
 	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_CCE);
@@ -1030,12 +941,13 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	int tx_obj_no = 0;
 	int i;
+	u32 id2;
 
 	if (can_dropped_invalid_skb(ndev, skb))
 		return NETDEV_TX_OK;
 
 	if (priv->tx_obj == PCH_TX_OBJ_END) {
-		if (ioread32(&priv->regs->treq2) & 0xfc00)
+		if (ioread32(&priv->regs->treq2) & PCH_TREQ2_TX_MASK)
 			netif_stop_queue(ndev);
 
 		tx_obj_no = priv->tx_obj;
@@ -1047,28 +959,29 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	/* Reading the Msg Obj from the Msg RAM to the Interface register. */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_obj_no);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, tx_obj_no);
 
 	/* Setting the CMASK register. */
 	pch_can_bit_set(&priv->regs->ifregs[1].cmask, PCH_CMASK_ALL);
 
 	/* If ID extended is set. */
-	pch_can_bit_clear(&priv->regs->ifregs[1].id1, 0xffff);
-	pch_can_bit_clear(&priv->regs->ifregs[1].id2, 0x1fff | PCH_ID2_XTD);
 	if (cf->can_id & CAN_EFF_FLAG) {
-		pch_can_bit_set(&priv->regs->ifregs[1].id1,
-				cf->can_id & 0xffff);
-		pch_can_bit_set(&priv->regs->ifregs[1].id2,
-				((cf->can_id >> 16) & 0x1fff) | PCH_ID2_XTD);
+		iowrite32(cf->can_id & 0xffff, &priv->regs->ifregs[1].id1);
+		id2 = ((cf->can_id >> 16) & 0x1fff) | PCH_ID2_XTD;
 	} else {
-		pch_can_bit_set(&priv->regs->ifregs[1].id1, 0);
-		pch_can_bit_set(&priv->regs->ifregs[1].id2,
-				(cf->can_id & CAN_SFF_MASK) << 2);
+		iowrite32(0, &priv->regs->ifregs[1].id1);
+		id2 = (cf->can_id & CAN_SFF_MASK) << 2;
 	}
 
+	id2 |= PCH_ID_MSGVAL;
+
 	/* If remote frame has to be transmitted.. */
 	if (cf->can_id & CAN_RTR_FLAG)
-		pch_can_bit_clear(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);
+		id2 &= ~PCH_ID2_DIR;
+	else
+		id2 |= PCH_ID2_DIR;
+
+	iowrite32(id2, &priv->regs->ifregs[1].id2);
 
 	/* Copy data to register */
 	for (i = 0; i < cf->can_dlc; i += 2) {
@@ -1079,19 +992,10 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	can_put_echo_skb(skb, ndev, tx_obj_no - PCH_RX_OBJ_END - 1);
 
 	/* Updating the size of the data. */
-	pch_can_bit_clear(&priv->regs->ifregs[1].mcont, 0x0f);
-	pch_can_bit_set(&priv->regs->ifregs[1].mcont, cf->can_dlc);
+	iowrite32(cf->can_dlc | PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT |
+		  PCH_IF_MCONT_TXIE, &priv->regs->ifregs[1].mcont);
 
-	/* Clearing IntPend, NewDat & TxRqst */
-	pch_can_bit_clear(&priv->regs->ifregs[1].mcont,
-			  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
-			  PCH_IF_MCONT_TXRQXT);
-
-	/* Setting NewDat, TxRqst bits */
-	pch_can_bit_set(&priv->regs->ifregs[1].mcont,
-			PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT);
-
-	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_obj_no);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, tx_obj_no);
 
 	return NETDEV_TX_OK;
 }
@@ -1117,6 +1021,74 @@ static void __devexit pch_can_remove(struct pci_dev *pdev)
 }
 
 #ifdef CONFIG_PM
+static void pch_can_set_int_custom(struct pch_can_priv *priv)
+{
+	/* Clearing the IE, SIE and EIE bits of Can control register. */
+	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
+
+	/* Appropriately setting them. */
+	pch_can_bit_set(&priv->regs->cont,
+			((priv->int_enables & PCH_MSK_CTRL_IE_SIE_EIE) << 1));
+}
+
+/* This function retrieves interrupt enabled for the CAN device. */
+static void pch_can_get_int_enables(struct pch_can_priv *priv, u32 *enables)
+{
+	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
+	*enables = ((ioread32(&priv->regs->cont) & PCH_CTRL_IE_SIE_EIE) >> 1);
+}
+
+static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num, u32 dir)
+{
+	u32 ie, enable;
+
+	if (dir)
+		ie = PCH_IF_MCONT_RXIE;
+	else
+		ie = PCH_IF_MCONT_TXIE;
+
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
+
+	if (((ioread32(&priv->regs->ifregs[dir].id2)) & PCH_ID_MSGVAL) &&
+			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie)) {
+		enable = 1;
+	} else {
+		enable = 0;
+	}
+	return enable;
+}
+
+static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
+				       u32 buffer_num, int set)
+{
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
+	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
+		  &priv->regs->ifregs[0].cmask);
+	if (set)
+		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
+				  PCH_IF_MCONT_EOB);
+	else
+		pch_can_bit_set(&priv->regs->ifregs[0].mcont, PCH_IF_MCONT_EOB);
+
+	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
+}
+
+static u32 pch_can_get_rx_buffer_link(struct pch_can_priv *priv, u32 buffer_num)
+{
+	u32 link;
+
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
+	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
+
+	if (ioread32(&priv->regs->ifregs[0].mcont) & PCH_IF_MCONT_EOB)
+		link = 0;
+	else
+		link = 1;
+	return link;
+}
+
 static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	int i;			/* Counter variable. */
@@ -1239,9 +1211,10 @@ static int pch_can_get_berr_counter(const struct net_device *dev,
 				    struct can_berr_counter *bec)
 {
 	struct pch_can_priv *priv = netdev_priv(dev);
+	u32 errc = ioread32(&priv->regs->errc);
 
-	bec->txerr = ioread32(&priv->regs->errc) & PCH_TEC;
-	bec->rxerr = (ioread32(&priv->regs->errc) & PCH_REC) >> 8;
+	bec->txerr = errc & PCH_TEC;
+	bec->rxerr = (errc & PCH_REC) >> 8;
 
 	return 0;
 }
-- 
1.6.0.6


From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 1/19 v4] can: EG20T PCH: Separate Interface Register(IF1/IF2)
Date: Fri, 26 Nov 2010 09:29:38 +0900
Message-ID: <4CEEFF72.3080806__16738.5154789828$1290731444$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:48783 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752242Ab0KZAaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 19:30:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate interface register from whole of register structure.
 CAN register of Intel PCH EG20T has 2 sets of interface register.
 To reduce whole of code size, separate interface register.
 As a result, the number of function also can be reduced.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |  445
++++++++++++++++++++-------------------------
 1 files changed, 201 insertions(+), 244 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 238622a..dae8ed1 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -113,6 +113,11 @@

 #define PCH_FIFO_THRESH		16

+enum pch_ifreg {
+	PCH_RX_IFREG,
+	PCH_TX_IFREG,
+};
+
 enum pch_can_mode {
 	PCH_CAN_ENABLE,
 	PCH_CAN_DISABLE,
@@ -122,6 +127,21 @@ enum pch_can_mode {
 	PCH_CAN_RUN
 };

+struct pch_can_if_regs {
+	u32 creq;
+	u32 cmask;
+	u32 mask1;
+	u32 mask2;
+	u32 id1;
+	u32 id2;
+	u32 mcont;
+	u32 dataa1;
+	u32 dataa2;
+	u32 datab1;
+	u32 datab2;
+	u32 rsv[13];
+};
+
 struct pch_can_regs {
 	u32 cont;
 	u32 stat;
@@ -130,38 +150,21 @@ struct pch_can_regs {
 	u32 intr;
 	u32 opt;
 	u32 brpe;
-	u32 reserve1;
-	u32 if1_creq;
-	u32 if1_cmask;
-	u32 if1_mask1;
-	u32 if1_mask2;
-	u32 if1_id1;
-	u32 if1_id2;
-	u32 if1_mcont;
-	u32 if1_dataa1;
-	u32 if1_dataa2;
-	u32 if1_datab1;
-	u32 if1_datab2;
-	u32 reserve2;
-	u32 reserve3[12];
-	u32 if2_creq;
-	u32 if2_cmask;
-	u32 if2_mask1;
-	u32 if2_mask2;
-	u32 if2_id1;
-	u32 if2_id2;
-	u32 if2_mcont;
-	u32 if2_dataa1;
-	u32 if2_dataa2;
-	u32 if2_datab1;
-	u32 if2_datab2;
-	u32 reserve4;
-	u32 reserve5[20];
+	u32 reserve;
+	struct pch_can_if_regs ifregs[2]; /* [0]=if1  [1]=if2 */
+	u32 reserve1[8];
 	u32 treq1;
 	u32 treq2;
-	u32 reserve6[2];
-	u32 reserve7[56];
-	u32 reserve8[3];
+	u32 reserve2[6];
+	u32 data1;
+	u32 data2;
+	u32 reserve3[6];
+	u32 canipend1;
+	u32 canipend2;
+	u32 reserve4[6];
+	u32 canmval1;
+	u32 canmval2;
+	u32 reserve5[37];
 	u32 srst;
 };

@@ -303,143 +306,87 @@ static void pch_can_check_if_busy(u32 __iomem
*creq_addr, u32 num)
 		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
 }

-static void pch_can_set_rx_enable(struct pch_can_priv *priv, u32 buff_num,
-				  u32 set)
+static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
+			     u32 set, enum pch_ifreg dir)
 {
 	unsigned long flags;
+	u32 ie;
+
+	if (dir)
+		ie = PCH_IF_MCONT_TXIE;
+	else
+		ie = PCH_IF_MCONT_RXIE;

 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	/* Reading the receive buffer data from RAM to Interface1 registers */
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
-	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
+	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);

 	/* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
 	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
-		  &priv->regs->if1_cmask);
+		  &priv->regs->ifregs[dir].cmask);

 	if (set == PCH_ENABLE) {
 		/* Setting the MsgVal and RxIE bits */
-		pch_can_bit_set(&priv->regs->if1_mcont, PCH_IF_MCONT_RXIE);
-		pch_can_bit_set(&priv->regs->if1_id2, PCH_ID_MSGVAL);
+		pch_can_bit_set(&priv->regs->ifregs[dir].mcont, ie);
+		pch_can_bit_set(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);

 	} else if (set == PCH_DISABLE) {
 		/* Resetting the MsgVal and RxIE bits */
-		pch_can_bit_clear(&priv->regs->if1_mcont, PCH_IF_MCONT_RXIE);
-		pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID_MSGVAL);
+		pch_can_bit_clear(&priv->regs->ifregs[dir].mcont, ie);
+		pch_can_bit_clear(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
 	}

-	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
+	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }

-static void pch_can_rx_enable_all(struct pch_can_priv *priv)
-{
-	int i;
-
-	/* Traversing to obtain the object configured as receivers. */
-	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX)
-			pch_can_set_rx_enable(priv, i + 1, PCH_ENABLE);
-	}
-}

-static void pch_can_rx_disable_all(struct pch_can_priv *priv)
+static void pch_can_set_rx_all(struct pch_can_priv *priv, u32 set)
 {
 	int i;

 	/* Traversing to obtain the object configured as receivers. */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
 		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX)
-			pch_can_set_rx_enable(priv, i + 1, PCH_DISABLE);
-	}
-}
-
-static void pch_can_set_tx_enable(struct pch_can_priv *priv, u32 buff_num,
-				 u32 set)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	/* Reading the Msg buffer from Message RAM to Interface2 registers. */
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
-	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
-
-	/* Setting the IF2CMASK register for accessing the
-		MsgVal and TxIE bits */
-	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
-		 &priv->regs->if2_cmask);
-
-	if (set == PCH_ENABLE) {
-		/* Setting the MsgVal and TxIE bits */
-		pch_can_bit_set(&priv->regs->if2_mcont, PCH_IF_MCONT_TXIE);
-		pch_can_bit_set(&priv->regs->if2_id2, PCH_ID_MSGVAL);
-	} else if (set == PCH_DISABLE) {
-		/* Resetting the MsgVal and TxIE bits. */
-		pch_can_bit_clear(&priv->regs->if2_mcont, PCH_IF_MCONT_TXIE);
-		pch_can_bit_clear(&priv->regs->if2_id2, PCH_ID_MSGVAL);
-	}
-
-	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
-}
-
-static void pch_can_tx_enable_all(struct pch_can_priv *priv)
-{
-	int i;
-
-	/* Traversing to obtain the object configured as transmit object. */
-	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX)
-			pch_can_set_tx_enable(priv, i + 1, PCH_ENABLE);
+			pch_can_set_rxtx(priv, i + 1, set, PCH_RX_IFREG);
 	}
 }

-static void pch_can_tx_disable_all(struct pch_can_priv *priv)
+static void pch_can_set_tx_all(struct pch_can_priv *priv, u32 set)
 {
 	int i;

 	/* Traversing to obtain the object configured as transmit object. */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
 		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX)
-			pch_can_set_tx_enable(priv, i + 1, PCH_DISABLE);
+			pch_can_set_rxtx(priv, i + 1, set, PCH_TX_IFREG);
 	}
 }

-static void pch_can_get_rx_enable(struct pch_can_priv *priv, u32 buff_num,
-				 u32 *enable)
+static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num,
+			       enum pch_ifreg dir)
 {
 	unsigned long flags;
+	u32 ie, enable;

-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
-	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
-
-	if (((ioread32(&priv->regs->if1_id2)) & PCH_ID_MSGVAL) &&
-			((ioread32(&priv->regs->if1_mcont)) &
-			PCH_IF_MCONT_RXIE))
-		*enable = PCH_ENABLE;
+	if (dir)
+		ie = PCH_IF_MCONT_RXIE;
 	else
-		*enable = PCH_DISABLE;
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
-}
-
-static void pch_can_get_tx_enable(struct pch_can_priv *priv, u32 buff_num,
-				 u32 *enable)
-{
-	unsigned long flags;
+		ie = PCH_IF_MCONT_TXIE;

 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
-	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
+	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);

-	if (((ioread32(&priv->regs->if2_id2)) & PCH_ID_MSGVAL) &&
-			((ioread32(&priv->regs->if2_mcont)) &
-			PCH_IF_MCONT_TXIE)) {
-		*enable = PCH_ENABLE;
+	if (((ioread32(&priv->regs->ifregs[dir].id2)) & PCH_ID_MSGVAL) &&
+			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie)) {
+		enable = PCH_ENABLE;
 	} else {
-		*enable = PCH_DISABLE;
+		enable = PCH_DISABLE;
 	}
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
+	return enable;
 }

 static int pch_can_int_pending(struct pch_can_priv *priv)
@@ -453,15 +400,17 @@ static void pch_can_set_rx_buffer_link(struct
pch_can_priv *priv,
 	unsigned long flags;

 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
-	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
-	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL, &priv->regs->if1_cmask);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
+	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
+	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
+		  &priv->regs->ifregs[0].cmask);
 	if (set == PCH_ENABLE)
-		pch_can_bit_clear(&priv->regs->if1_mcont, PCH_IF_MCONT_EOB);
+		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
+				  PCH_IF_MCONT_EOB);
 	else
-		pch_can_bit_set(&priv->regs->if1_mcont, PCH_IF_MCONT_EOB);
+		pch_can_bit_set(&priv->regs->ifregs[0].mcont, PCH_IF_MCONT_EOB);

-	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
+	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }

@@ -471,10 +420,10 @@ static void pch_can_get_rx_buffer_link(struct
pch_can_priv *priv,
 	unsigned long flags;

 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
-	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
+	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);

-	if (ioread32(&priv->regs->if1_mcont) & PCH_IF_MCONT_EOB)
+	if (ioread32(&priv->regs->ifregs[0].mcont) & PCH_IF_MCONT_EOB)
 		*link = PCH_DISABLE;
 	else
 		*link = PCH_ENABLE;
@@ -486,37 +435,37 @@ static void pch_can_clear_buffers(struct
pch_can_priv *priv)
 	int i;

 	for (i = 0; i < PCH_RX_OBJ_NUM; i++) {
-		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->if1_cmask);
-		iowrite32(0xffff, &priv->regs->if1_mask1);
-		iowrite32(0xffff, &priv->regs->if1_mask2);
-		iowrite32(0x0, &priv->regs->if1_id1);
-		iowrite32(0x0, &priv->regs->if1_id2);
-		iowrite32(0x0, &priv->regs->if1_mcont);
-		iowrite32(0x0, &priv->regs->if1_dataa1);
-		iowrite32(0x0, &priv->regs->if1_dataa2);
-		iowrite32(0x0, &priv->regs->if1_datab1);
-		iowrite32(0x0, &priv->regs->if1_datab2);
+		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[0].cmask);
+		iowrite32(0xffff, &priv->regs->ifregs[0].mask1);
+		iowrite32(0xffff, &priv->regs->ifregs[0].mask2);
+		iowrite32(0x0, &priv->regs->ifregs[0].id1);
+		iowrite32(0x0, &priv->regs->ifregs[0].id2);
+		iowrite32(0x0, &priv->regs->ifregs[0].mcont);
+		iowrite32(0x0, &priv->regs->ifregs[0].dataa1);
+		iowrite32(0x0, &priv->regs->ifregs[0].dataa2);
+		iowrite32(0x0, &priv->regs->ifregs[0].datab1);
+		iowrite32(0x0, &priv->regs->ifregs[0].datab2);
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
-			  &priv->regs->if1_cmask);
-		pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
+			  &priv->regs->ifregs[0].cmask);
+		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i+1);
 	}

 	for (i = i;  i < PCH_OBJ_NUM; i++) {
-		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->if2_cmask);
-		iowrite32(0xffff, &priv->regs->if2_mask1);
-		iowrite32(0xffff, &priv->regs->if2_mask2);
-		iowrite32(0x0, &priv->regs->if2_id1);
-		iowrite32(0x0, &priv->regs->if2_id2);
-		iowrite32(0x0, &priv->regs->if2_mcont);
-		iowrite32(0x0, &priv->regs->if2_dataa1);
-		iowrite32(0x0, &priv->regs->if2_dataa2);
-		iowrite32(0x0, &priv->regs->if2_datab1);
-		iowrite32(0x0, &priv->regs->if2_datab2);
+		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[1].cmask);
+		iowrite32(0xffff, &priv->regs->ifregs[1].mask1);
+		iowrite32(0xffff, &priv->regs->ifregs[1].mask2);
+		iowrite32(0x0, &priv->regs->ifregs[1].id1);
+		iowrite32(0x0, &priv->regs->ifregs[1].id2);
+		iowrite32(0x0, &priv->regs->ifregs[1].mcont);
+		iowrite32(0x0, &priv->regs->ifregs[1].dataa1);
+		iowrite32(0x0, &priv->regs->ifregs[1].dataa2);
+		iowrite32(0x0, &priv->regs->ifregs[1].datab1);
+		iowrite32(0x0, &priv->regs->ifregs[1].datab2);
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
 			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
-			  &priv->regs->if2_cmask);
-		pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
+			  &priv->regs->ifregs[1].cmask);
+		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i+1);
 	}
 }

@@ -530,58 +479,60 @@ static void pch_can_config_rx_tx_buffers(struct
pch_can_priv *priv)
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
 		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX) {
 			iowrite32(PCH_CMASK_RX_TX_GET,
-				&priv->regs->if1_cmask);
-			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
+				&priv->regs->ifregs[0].cmask);
+			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i+1);

-			iowrite32(0x0, &priv->regs->if1_id1);
-			iowrite32(0x0, &priv->regs->if1_id2);
+			iowrite32(0x0, &priv->regs->ifregs[0].id1);
+			iowrite32(0x0, &priv->regs->ifregs[0].id2);

-			pch_can_bit_set(&priv->regs->if1_mcont,
+			pch_can_bit_set(&priv->regs->ifregs[0].mcont,
 					PCH_IF_MCONT_UMASK);

 			/* Set FIFO mode set to 0 except last Rx Obj*/
-			pch_can_bit_clear(&priv->regs->if1_mcont,
+			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 					  PCH_IF_MCONT_EOB);
 			/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
 			if (i == (PCH_RX_OBJ_NUM - 1))
-				pch_can_bit_set(&priv->regs->if1_mcont,
+				pch_can_bit_set(&priv->regs->ifregs[0].mcont,
 						  PCH_IF_MCONT_EOB);

-			iowrite32(0, &priv->regs->if1_mask1);
-			pch_can_bit_clear(&priv->regs->if1_mask2,
+			iowrite32(0, &priv->regs->ifregs[0].mask1);
+			pch_can_bit_clear(&priv->regs->ifregs[0].mask2,
 					  0x1fff | PCH_MASK2_MDIR_MXTD);

 			/* Setting CMASK for writing */
 			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
 				  PCH_CMASK_ARB | PCH_CMASK_CTRL,
-				  &priv->regs->if1_cmask);
+				  &priv->regs->ifregs[0].cmask);

-			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
+			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i+1);
 		} else if (priv->msg_obj[i] == PCH_MSG_OBJ_TX) {
 			iowrite32(PCH_CMASK_RX_TX_GET,
-				&priv->regs->if2_cmask);
-			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
+				&priv->regs->ifregs[1].cmask);
+			pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i+1);

 			/* Resetting DIR bit for reception */
-			iowrite32(0x0, &priv->regs->if2_id1);
-			iowrite32(0x0, &priv->regs->if2_id2);
-			pch_can_bit_set(&priv->regs->if2_id2, PCH_ID2_DIR);
+			iowrite32(0x0, &priv->regs->ifregs[1].id1);
+			iowrite32(0x0, &priv->regs->ifregs[1].id2);
+			pch_can_bit_set(&priv->regs->ifregs[1].id2,
+					PCH_ID2_DIR);

 			/* Setting EOB bit for transmitter */
-			iowrite32(PCH_IF_MCONT_EOB, &priv->regs->if2_mcont);
+			iowrite32(PCH_IF_MCONT_EOB,
+				  &priv->regs->ifregs[1].mcont);

-			pch_can_bit_set(&priv->regs->if2_mcont,
+			pch_can_bit_set(&priv->regs->ifregs[1].mcont,
 					PCH_IF_MCONT_UMASK);

-			iowrite32(0, &priv->regs->if2_mask1);
-			pch_can_bit_clear(&priv->regs->if2_mask2, 0x1fff);
+			iowrite32(0, &priv->regs->ifregs[1].mask1);
+			pch_can_bit_clear(&priv->regs->ifregs[1].mask2, 0x1fff);

 			/* Setting CMASK for writing */
 			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
 				  PCH_CMASK_ARB | PCH_CMASK_CTRL,
-				  &priv->regs->if2_cmask);
+				  &priv->regs->ifregs[1].cmask);

-			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
+			pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i+1);
 		}
 	}
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
@@ -611,10 +562,10 @@ static void pch_can_release(struct pch_can_priv *priv)
 	pch_can_set_int_enables(priv, PCH_CAN_NONE);

 	/* Disabling all the receive object. */
-	pch_can_rx_disable_all(priv);
+	pch_can_set_rx_all(priv, 0);

 	/* Disabling all the transmit object. */
-	pch_can_tx_disable_all(priv);
+	pch_can_set_tx_all(priv, 0);
 }

 /* This function clears interrupt(s) from the CAN device. */
@@ -630,31 +581,31 @@ static void pch_can_int_clr(struct pch_can_priv
*priv, u32 mask)
 		/* Setting CMASK for clearing interrupts for
 					 frame transmission. */
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
-			  &priv->regs->if2_cmask);
+			  &priv->regs->ifregs[1].cmask);

 		/* Resetting the ID registers. */
-		pch_can_bit_set(&priv->regs->if2_id2,
+		pch_can_bit_set(&priv->regs->ifregs[1].id2,
 			       PCH_ID2_DIR | (0x7ff << 2));
-		iowrite32(0x0, &priv->regs->if2_id1);
+		iowrite32(0x0, &priv->regs->ifregs[1].id1);

 		/* Claring NewDat, TxRqst & IntPnd */
-		pch_can_bit_clear(&priv->regs->if2_mcont,
+		pch_can_bit_clear(&priv->regs->ifregs[1].mcont,
 				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
 				  PCH_IF_MCONT_TXRQXT);
-		pch_can_check_if_busy(&priv->regs->if2_creq, mask);
+		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, mask);
 	} else if (priv->msg_obj[mask - 1] == PCH_MSG_OBJ_RX) {
 		/* Setting CMASK for clearing the reception interrupts. */
 		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
-			  &priv->regs->if1_cmask);
+			  &priv->regs->ifregs[0].cmask);

 		/* Clearing the Dir bit. */
-		pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID2_DIR);
+		pch_can_bit_clear(&priv->regs->ifregs[0].id2, PCH_ID2_DIR);

 		/* Clearing NewDat & IntPnd */
-		pch_can_bit_clear(&priv->regs->if1_mcont,
+		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND);

-		pch_can_check_if_busy(&priv->regs->if1_creq, mask);
+		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, mask);
 	}
 }

@@ -685,8 +636,8 @@ static void pch_can_error(struct net_device *ndev,
u32 status)
 		return;

 	if (status & PCH_BUS_OFF) {
-		pch_can_tx_disable_all(priv);
-		pch_can_rx_disable_all(priv);
+		pch_can_set_tx_all(priv, 0);
+		pch_can_set_rx_all(priv, 0);
 		state = CAN_STATE_BUS_OFF;
 		cf->can_id |= CAN_ERR_BUSOFF;
 		can_bus_off(ndev);
@@ -783,22 +734,22 @@ static int pch_can_rx_normal(struct net_device
*ndev, u32 int_stat)
 	struct net_device_stats *stats = &(priv->ndev->stats);

 	/* Reading the messsage object from the Message RAM */
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
-	pch_can_check_if_busy(&priv->regs->if1_creq, int_stat);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
+	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, int_stat);

 	/* Reading the MCONT register. */
-	reg = ioread32(&priv->regs->if1_mcont);
+	reg = ioread32(&priv->regs->ifregs[0].mcont);
 	reg &= 0xffff;

 	for (k = int_stat; !(reg & PCH_IF_MCONT_EOB); k++) {
 		/* If MsgLost bit set. */
 		if (reg & PCH_IF_MCONT_MSGLOST) {
 			dev_err(&priv->ndev->dev, "Msg Obj is overwritten.\n");
-			pch_can_bit_clear(&priv->regs->if1_mcont,
+			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 					  PCH_IF_MCONT_MSGLOST);
 			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
-				  &priv->regs->if1_cmask);
-			pch_can_check_if_busy(&priv->regs->if1_creq, k);
+				  &priv->regs->ifregs[0].cmask);
+			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);

 			skb = alloc_can_err_skb(ndev, &cf);
 			if (!skb)
@@ -824,29 +775,30 @@ static int pch_can_rx_normal(struct net_device
*ndev, u32 int_stat)
 			return -ENOMEM;

 		/* Get Received data */
-		ide = ((ioread32(&priv->regs->if1_id2)) & PCH_ID2_XTD) >> 14;
+		ide = ((ioread32(&priv->regs->ifregs[0].id2)) & PCH_ID2_XTD) >>
+									     14;
 		if (ide) {
-			id = (ioread32(&priv->regs->if1_id1) & 0xffff);
-			id |= (((ioread32(&priv->regs->if1_id2)) &
+			id = (ioread32(&priv->regs->ifregs[0].id1) & 0xffff);
+			id |= (((ioread32(&priv->regs->ifregs[0].id2)) &
 					    0x1fff) << 16);
 			cf->can_id = (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
 		} else {
-			id = (((ioread32(&priv->regs->if1_id2)) &
-					  (CAN_SFF_MASK << 2)) >> 2);
+			id = (((ioread32(&priv->regs->ifregs[0].id2)) &
+						     (CAN_SFF_MASK << 2)) >> 2);
 			cf->can_id = (id & CAN_SFF_MASK);
 		}

-		rtr = (ioread32(&priv->regs->if1_id2) &  PCH_ID2_DIR);
+		rtr = (ioread32(&priv->regs->ifregs[0].id2) &  PCH_ID2_DIR);
 		if (rtr) {
 			cf->can_dlc = 0;
 			cf->can_id |= CAN_RTR_FLAG;
 		} else {
-			cf->can_dlc = ((ioread32(&priv->regs->if1_mcont)) &
-						   0x0f);
+			cf->can_dlc = ((ioread32(&priv->regs->ifregs[0].mcont))
+						 & 0x0f);
 		}

 		for (i = 0, j = 0; i < cf->can_dlc; j++) {
-			reg = ioread32(&priv->regs->if1_dataa1 + j*4);
+			reg = ioread32(&priv->regs->ifregs[0].dataa1 + j*4);
 			cf->data[i++] = cpu_to_le32(reg & 0xff);
 			if (i == cf->can_dlc)
 				break;
@@ -860,15 +812,16 @@ static int pch_can_rx_normal(struct net_device
*ndev, u32 int_stat)

 		if (k < PCH_FIFO_THRESH) {
 			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL |
-				  PCH_CMASK_ARB, &priv->regs->if1_cmask);
+				  PCH_CMASK_ARB, &priv->regs->ifregs[0].cmask);

 			/* Clearing the Dir bit. */
-			pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID2_DIR);
+			pch_can_bit_clear(&priv->regs->ifregs[0].id2,
+					  PCH_ID2_DIR);

 			/* Clearing NewDat & IntPnd */
-			pch_can_bit_clear(&priv->regs->if1_mcont,
+			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
 					  PCH_IF_MCONT_INTPND);
-			pch_can_check_if_busy(&priv->regs->if1_creq, k);
+			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);
 		} else if (k > PCH_FIFO_THRESH) {
 			pch_can_int_clr(priv, k);
 		} else if (k == PCH_FIFO_THRESH) {
@@ -878,9 +831,9 @@ static int pch_can_rx_normal(struct net_device
*ndev, u32 int_stat)
 		}
 RX_NEXT:
 		/* Reading the messsage object from the Message RAM */
-		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
-		pch_can_check_if_busy(&priv->regs->if1_creq, k + 1);
-		reg = ioread32(&priv->regs->if1_mcont);
+		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
+		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k + 1);
+		reg = ioread32(&priv->regs->ifregs[0].mcont);
 	}

 	return rcv_pkts;
@@ -910,8 +863,9 @@ INT_STAT:

 		if (reg_stat & PCH_TX_OK) {
 			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-			iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
-			pch_can_check_if_busy(&priv->regs->if2_creq,
+			iowrite32(PCH_CMASK_RX_TX_GET,
+				  &priv->regs->ifregs[1].cmask);
+			pch_can_check_if_busy(&priv->regs->ifregs[1].creq,
 					       ioread32(&priv->regs->intr));
 			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 			pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
@@ -938,10 +892,11 @@ MSG_OBJ:
 			can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_NUM - 1);
 			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 			iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
-				  &priv->regs->if2_cmask);
-			dlc = ioread32(&priv->regs->if2_mcont) &
+				  &priv->regs->ifregs[1].cmask);
+			dlc = ioread32(&priv->regs->ifregs[1].mcont) &
 				       PCH_IF_MCONT_DLC;
-			pch_can_check_if_busy(&priv->regs->if2_creq, int_stat);
+			pch_can_check_if_busy(&priv->regs->ifregs[1].creq,
+					      int_stat);
 			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 			if (dlc > 8)
 				dlc = 8;
@@ -996,8 +951,8 @@ static void pch_can_start(struct net_device *ndev)
 	pch_set_bittiming(ndev);
 	pch_can_set_optmode(priv);

-	pch_can_tx_enable_all(priv);
-	pch_can_rx_enable_all(priv);
+	pch_can_set_tx_all(priv, 1);
+	pch_can_set_rx_all(priv, 1);

 	/* Setting the CAN to run mode. */
 	pch_can_set_run_mode(priv, PCH_CAN_RUN);
@@ -1125,54 +1080,55 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb,
struct net_device *ndev)
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);

 	/* Reading the Msg Obj from the Msg RAM to the Interface register. */
-	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
-	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
+	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_buffer_avail);

 	/* Setting the CMASK register. */
-	pch_can_bit_set(&priv->regs->if2_cmask, PCH_CMASK_ALL);
+	pch_can_bit_set(&priv->regs->ifregs[1].cmask, PCH_CMASK_ALL);

 	/* If ID extended is set. */
-	pch_can_bit_clear(&priv->regs->if2_id1, 0xffff);
-	pch_can_bit_clear(&priv->regs->if2_id2, 0x1fff | PCH_ID2_XTD);
+	pch_can_bit_clear(&priv->regs->ifregs[1].id1, 0xffff);
+	pch_can_bit_clear(&priv->regs->ifregs[1].id2, 0x1fff | PCH_ID2_XTD);
 	if (cf->can_id & CAN_EFF_FLAG) {
-		pch_can_bit_set(&priv->regs->if2_id1, cf->can_id & 0xffff);
-		pch_can_bit_set(&priv->regs->if2_id2,
+		pch_can_bit_set(&priv->regs->ifregs[1].id1,
+				cf->can_id & 0xffff);
+		pch_can_bit_set(&priv->regs->ifregs[1].id2,
 				((cf->can_id >> 16) & 0x1fff) | PCH_ID2_XTD);
 	} else {
-		pch_can_bit_set(&priv->regs->if2_id1, 0);
-		pch_can_bit_set(&priv->regs->if2_id2,
+		pch_can_bit_set(&priv->regs->ifregs[1].id1, 0);
+		pch_can_bit_set(&priv->regs->ifregs[1].id2,
 				(cf->can_id & CAN_SFF_MASK) << 2);
 	}

 	/* If remote frame has to be transmitted.. */
 	if (cf->can_id & CAN_RTR_FLAG)
-		pch_can_bit_clear(&priv->regs->if2_id2, PCH_ID2_DIR);
+		pch_can_bit_clear(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);

 	for (i = 0, j = 0; i < cf->can_dlc; j++) {
 		iowrite32(le32_to_cpu(cf->data[i++]),
-			 (&priv->regs->if2_dataa1) + j*4);
+			 (&priv->regs->ifregs[1].dataa1) + j*4);
 		if (i == cf->can_dlc)
 			break;
 		iowrite32(le32_to_cpu(cf->data[i++] << 8),
-			 (&priv->regs->if2_dataa1) + j*4);
+			 (&priv->regs->ifregs[1].dataa1) + j*4);
 	}

 	can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_NUM - 1);

 	/* Updating the size of the data. */
-	pch_can_bit_clear(&priv->regs->if2_mcont, 0x0f);
-	pch_can_bit_set(&priv->regs->if2_mcont, cf->can_dlc);
+	pch_can_bit_clear(&priv->regs->ifregs[1].mcont, 0x0f);
+	pch_can_bit_set(&priv->regs->ifregs[1].mcont, cf->can_dlc);

 	/* Clearing IntPend, NewDat & TxRqst */
-	pch_can_bit_clear(&priv->regs->if2_mcont,
+	pch_can_bit_clear(&priv->regs->ifregs[1].mcont,
 			  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
 			  PCH_IF_MCONT_TXRQXT);

 	/* Setting NewDat, TxRqst bits */
-	pch_can_bit_set(&priv->regs->if2_mcont,
+	pch_can_bit_set(&priv->regs->ifregs[1].mcont,
 			PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT);

-	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
+	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_buffer_avail);

 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);

@@ -1234,25 +1190,25 @@ static int pch_can_suspend(struct pci_dev *pdev,
pm_message_t state)
 	/* Save Tx buffer enable state */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
 		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX)
-			pch_can_get_tx_enable(priv, i + 1,
-					      &(priv->tx_enable[i]));
+			priv->tx_enable[i] = pch_can_get_rxtx_ir(priv, i + 1,
+								 PCH_TX_IFREG);
 	}

 	/* Disable all Transmit buffers */
-	pch_can_tx_disable_all(priv);
+	pch_can_set_tx_all(priv, 0);

 	/* Save Rx buffer enable state */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
 		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX) {
-			pch_can_get_rx_enable(priv, i + 1,
-						&(priv->rx_enable[i]));
+			priv->rx_enable[i] = pch_can_get_rxtx_ir(priv, i + 1,
+						PCH_RX_IFREG);
 			pch_can_get_rx_buffer_link(priv, i + 1,
 						&(priv->rx_link[i]));
 		}
 	}

 	/* Disable all Receive buffers */
-	pch_can_rx_disable_all(priv);
+	pch_can_set_rx_all(priv, 0);
 	retval = pci_save_state(pdev);
 	if (retval) {
 		dev_err(&pdev->dev, "pci_save_state failed.\n");
@@ -1301,10 +1257,9 @@ static int pch_can_resume(struct pci_dev *pdev)

 	/* Enabling the transmit buffer. */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX) {
-			pch_can_set_tx_enable(priv, i + 1,
-					      priv->tx_enable[i]);
-		}
+		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX)
+			pch_can_set_rxtx(priv, i, priv->tx_enable[i],
+					 PCH_TX_IFREG);
 	}

 	/* Configuring the receive buffer and enabling them. */
@@ -1315,7 +1270,9 @@ static int pch_can_resume(struct pci_dev *pdev)
 						   priv->rx_link[i]);

 			/* Restore buffer enables */
-			pch_can_set_rx_enable(priv, i + 1, priv->rx_enable[i]);
+			pch_can_set_rxtx(priv, i, priv->rx_enable[i],
+					 PCH_RX_IFREG);
+
 		}
 	}

-- 
1.6.0.6

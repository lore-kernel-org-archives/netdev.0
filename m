From: Tomoya <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
 warnings
Date: Mon, 25 Oct 2010 11:32:24 +0900
Message-ID: <4CC4EC38.2040208@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, morinaga526@dsn.okisemi.com,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@g
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:6823 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751479Ab0JYCcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 22:32:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
 - Fix build warnings when PM_CONFIG is disabled.
 - Modify Copyright "Co" to "CO".

Reported-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |  208
++++++++++++++++++++++----------------------
 1 files changed, 104 insertions(+), 104 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 55ec324..2889e11 100755
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 1999 - 2010 Intel Corporation.
- * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -255,21 +255,21 @@ static void pch_can_set_optmode(struct
pch_can_priv *priv)
 	iowrite32(reg_val, &priv->regs->opt);
 }

-static void pch_can_set_int_custom(struct pch_can_priv *priv)
+static void pch_can_check_if_busy(u32 __iomem *creq_addr, u32 num)
 {
-	/* Clearing the IE, SIE and EIE bits of Can control register. */
-	pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
-
-	/* Appropriately setting them. */
-	pch_can_bit_set(&priv->regs->cont,
-			((priv->int_enables & MSK_CTRL_IE_SIE_EIE) << 1));
-}
+	u32 counter = COUNTER_LIMIT;
+	u32 ifx_creq;

-/* This function retrieves interrupt enabled for the CAN device. */
-static void pch_can_get_int_enables(struct pch_can_priv *priv, u32
*enables)
-{
-	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
-	*enables = ((ioread32(&priv->regs->cont) & CAN_CTRL_IE_SIE_EIE) >> 1);
+	iowrite32(num, creq_addr);
+	while (counter) {
+		ifx_creq = ioread32(creq_addr) & CAN_IF_CREQ_BUSY;
+		if (!ifx_creq)
+			break;
+		counter--;
+		udelay(1);
+	}
+	if (!counter)
+		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
 }

 static void pch_can_set_int_enables(struct pch_can_priv *priv,
@@ -298,23 +298,6 @@ static void pch_can_set_int_enables(struct
pch_can_priv *priv,
 	}
 }

-static void pch_can_check_if_busy(u32 __iomem *creq_addr, u32 num)
-{
-	u32 counter = COUNTER_LIMIT;
-	u32 ifx_creq;
-
-	iowrite32(num, creq_addr);
-	while (counter) {
-		ifx_creq = ioread32(creq_addr) & CAN_IF_CREQ_BUSY;
-		if (!ifx_creq)
-			break;
-		counter--;
-		udelay(1);
-	}
-	if (!counter)
-		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
-}
-
 static void pch_can_set_rx_enable(struct pch_can_priv *priv, u32 buff_num,
 				  u32 set)
 {
@@ -417,82 +400,11 @@ static void pch_can_tx_disable_all(struct
pch_can_priv *priv)
 	}
 }

-static void pch_can_get_rx_enable(struct pch_can_priv *priv, u32 buff_num,
-				 u32 *enable)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
-	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
-
-	if (((ioread32(&priv->regs->if1_id2)) & CAN_ID_MSGVAL) &&
-			((ioread32(&priv->regs->if1_mcont)) &
-			CAN_IF_MCONT_RXIE))
-		*enable = ENABLE;
-	else
-		*enable = DISABLE;
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
-}
-
-static void pch_can_get_tx_enable(struct pch_can_priv *priv, u32 buff_num,
-				 u32 *enable)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
-	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
-
-	if (((ioread32(&priv->regs->if2_id2)) & CAN_ID_MSGVAL) &&
-			((ioread32(&priv->regs->if2_mcont)) &
-			CAN_IF_MCONT_TXIE)) {
-		*enable = ENABLE;
-	} else {
-		*enable = DISABLE;
-	}
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
-}
-
 static int pch_can_int_pending(struct pch_can_priv *priv)
 {
 	return ioread32(&priv->regs->intr) & 0xffff;
 }

-static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
-				       u32 buffer_num, u32 set)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
-	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
-	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL, &priv->regs->if1_cmask);
-	if (set == ENABLE)
-		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
-	else
-		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
-
-	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
-}
-
-static void pch_can_get_rx_buffer_link(struct pch_can_priv *priv,
-				       u32 buffer_num, u32 *link)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
-	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
-
-	if (ioread32(&priv->regs->if1_mcont) & CAN_IF_MCONT_EOB)
-		*link = DISABLE;
-	else
-		*link = ENABLE;
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
-}
-
 static void pch_can_clear_buffers(struct pch_can_priv *priv)
 {
 	int i;
@@ -1121,13 +1033,13 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb,
struct net_device *ndev)
 	if (can_dropped_invalid_skb(ndev, skb))
 		return NETDEV_TX_OK;

-	if (priv->tx_obj == (PCH_OBJ_NUM + 1)) { /* Point tail Obj */
+	if (priv->tx_obj == (PCH_OBJ_NUM + 1)) { /* Point tail Obj + 1 */
 		while (pch_get_msg_obj_sts(ndev, (((1 << PCH_TX_OBJ_NUM)-1) <<
 					   PCH_RX_OBJ_NUM)))
 			udelay(500);

 		priv->tx_obj = PCH_RX_OBJ_NUM + 1; /* Point head of Tx Obj ID */
-		tx_buffer_avail = priv->tx_obj; /* Point Tail of Tx Obj */
+		tx_buffer_avail = priv->tx_obj;
 	} else {
 		tx_buffer_avail = priv->tx_obj;
 	}
@@ -1212,6 +1124,94 @@ static void __devexit pch_can_remove(struct
pci_dev *pdev)
 }

 #ifdef CONFIG_PM
+static void pch_can_set_int_custom(struct pch_can_priv *priv)
+{
+	/* Clearing the IE, SIE and EIE bits of Can control register. */
+	pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
+
+	/* Appropriately setting them. */
+	pch_can_bit_set(&priv->regs->cont,
+			((priv->int_enables & MSK_CTRL_IE_SIE_EIE) << 1));
+}
+
+/* This function retrieves interrupt enabled for the CAN device. */
+static void pch_can_get_int_enables(struct pch_can_priv *priv, u32
*enables)
+{
+	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
+	*enables = ((ioread32(&priv->regs->cont) & CAN_CTRL_IE_SIE_EIE) >> 1);
+}
+
+static void pch_can_get_rx_enable(struct pch_can_priv *priv, u32 buff_num,
+				 u32 *enable)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
+	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
+	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
+
+	if (((ioread32(&priv->regs->if1_id2)) & CAN_ID_MSGVAL) &&
+			((ioread32(&priv->regs->if1_mcont)) &
+			CAN_IF_MCONT_RXIE))
+		*enable = ENABLE;
+	else
+		*enable = DISABLE;
+	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
+}
+
+static void pch_can_get_tx_enable(struct pch_can_priv *priv, u32 buff_num,
+				 u32 *enable)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
+	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
+	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
+
+	if (((ioread32(&priv->regs->if2_id2)) & CAN_ID_MSGVAL) &&
+			((ioread32(&priv->regs->if2_mcont)) &
+			CAN_IF_MCONT_TXIE)) {
+		*enable = ENABLE;
+	} else {
+		*enable = DISABLE;
+	}
+	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
+}
+
+static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
+				       u32 buffer_num, u32 set)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
+	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
+	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
+	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL, &priv->regs->if1_cmask);
+	if (set == ENABLE)
+		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
+	else
+		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
+
+	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
+	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
+}
+
+static void pch_can_get_rx_buffer_link(struct pch_can_priv *priv,
+				       u32 buffer_num, u32 *link)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
+	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
+	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
+
+	if (ioread32(&priv->regs->if1_mcont) & CAN_IF_MCONT_EOB)
+		*link = DISABLE;
+	else
+		*link = ENABLE;
+	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
+}
+
 static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	int i;			/* Counter variable. */
-- 
1.6.0.6


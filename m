From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 5/17] can: EG20T PCH: Delete unnecessary spin_lock
Date: Fri, 19 Nov 2010 14:45:51 +0900
Message-ID: <4CE60F0F.3020306__22189.3396381804$1290145608$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:30456 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751264Ab0KSFqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 00:46:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete unnecessary spin_lock for accessing Message Object.
Since all message objects are divided into tx/rx area completely,
spin_lock processing is unnecessary.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   31 -------------------------------
 1 files changed, 0 insertions(+), 31 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 7c182b8..843bbce 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -176,7 +176,6 @@ struct pch_can_priv {
 	unsigned int int_enables;
 	unsigned int int_stat;
 	struct net_device *ndev;
-	spinlock_t msgif_reg_lock; /* Message Interface Registers Access Lock*/
 	unsigned int msg_obj[PCH_TX_OBJ_END];
 	struct pch_can_regs __iomem *regs;
 	struct napi_struct napi;
@@ -307,7 +306,6 @@ static void pch_can_check_if_busy(u32 __iomem *creq_addr, u32 num)
 static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 			     int set, enum pch_ifreg dir)
 {
-	unsigned long flags;
 	u32 ie;
 
 	if (dir)
@@ -315,7 +313,6 @@ static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 	else
 		ie = PCH_IF_MCONT_RXIE;
 
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	/* Reading the receive buffer data from RAM to Interface1 registers */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
 	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
@@ -336,7 +333,6 @@ static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 	}
 
 	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }
 
 
@@ -360,7 +356,6 @@ static void pch_can_set_tx_all(struct pch_can_priv *priv, int set)
 
 static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num, u32 dir)
 {
-	unsigned long flags;
 	u32 ie, enable;
 
 	if (dir)
@@ -368,7 +363,6 @@ static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num, u32 dir)
 	else
 		ie = PCH_IF_MCONT_TXIE;
 
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
 	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
 
@@ -378,7 +372,6 @@ static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num, u32 dir)
 	} else {
 		enable = 0;
 	}
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 	return enable;
 }
 
@@ -390,9 +383,6 @@ static int pch_can_int_pending(struct pch_can_priv *priv)
 static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
 				       u32 buffer_num, int set)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
 	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
 	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
@@ -404,15 +394,12 @@ static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
 		pch_can_bit_set(&priv->regs->ifregs[0].mcont, PCH_IF_MCONT_EOB);
 
 	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }
 
 static u32 pch_can_get_rx_buffer_link(struct pch_can_priv *priv, u32 buffer_num)
 {
-	unsigned long flags;
 	u32 link;
 
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
 	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
 
@@ -420,7 +407,6 @@ static u32 pch_can_get_rx_buffer_link(struct pch_can_priv *priv, u32 buffer_num)
 		link = 0;
 	else
 		link = 1;
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 	return link;
 }
 
@@ -466,9 +452,6 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 {
 	int i;
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 
 	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
 		iowrite32(PCH_CMASK_RX_TX_GET,
@@ -527,7 +510,6 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 
 		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
 	}
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }
 
 static void pch_can_init(struct pch_can_priv *priv)
@@ -846,7 +828,6 @@ static int pch_can_rx_poll(struct napi_struct *napi, int quota)
 	u32 int_stat;
 	int rcv_pkts = 0;
 	u32 reg_stat;
-	unsigned long flags;
 
 	int_stat = pch_can_int_pending(priv);
 	if (!int_stat)
@@ -861,12 +842,10 @@ INT_STAT:
 		}
 
 		if (reg_stat & PCH_TX_OK) {
-			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 			iowrite32(PCH_CMASK_RX_TX_GET,
 				  &priv->regs->ifregs[1].cmask);
 			pch_can_check_if_busy(&priv->regs->ifregs[1].creq,
 					       ioread32(&priv->regs->intr));
-			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 			pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
 		}
 
@@ -880,22 +859,18 @@ INT_STAT:
 
 MSG_OBJ:
 	if ((int_stat >= PCH_RX_OBJ_START) && (int_stat <= PCH_RX_OBJ_END)) {
-		spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 		rcv_pkts = pch_can_rx_normal(ndev, int_stat);
-		spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 		if (rcv_pkts < 0)
 			return 0;
 	} else if ((int_stat >= PCH_TX_OBJ_START) &&
 		   (int_stat <= PCH_TX_OBJ_END)) {
 		/* Handle transmission interrupt */
 		can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_END - 1);
-		spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 		iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
 			  &priv->regs->ifregs[1].cmask);
 		dlc = ioread32(&priv->regs->ifregs[1].mcont) &
 			       PCH_IF_MCONT_DLC;
 		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, int_stat);
-		spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 		if (dlc > 8)
 			dlc = 8;
 		stats->tx_bytes += dlc;
@@ -1043,7 +1018,6 @@ static int pch_close(struct net_device *ndev)
 static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	int i, j;
-	unsigned long flags;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	int tx_obj_no = 0;
@@ -1062,9 +1036,6 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 		priv->tx_obj++;
 	}
 
-	/* Attaining the lock. */
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-
 	/* Reading the Msg Obj from the Msg RAM to the Interface register. */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
 	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_obj_no);
@@ -1116,8 +1087,6 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_obj_no);
 
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
-
 	return NETDEV_TX_OK;
 }
 
-- 
1.6.0.6


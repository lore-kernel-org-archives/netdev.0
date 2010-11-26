From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 5/19 v4] can: EG20T PCH: Delete unnecessary spin_lock
Date: Fri, 26 Nov 2010 09:36:54 +0900
Message-ID: <4CEF0126.8070305__1539.00194350189$1290731873$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:11221 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752815Ab0KZAhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 19:37:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete unnecessary spin_lock
 Delete unnecessary spin_lock for accessing Message Object.
 Since all message objects are divided into tx/rx area completely,
 spin_lock processing is unnecessary.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/pch_can.c |   34 ----------------------------------
 1 files changed, 0 insertions(+), 34 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 8686d93..6437e60 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -71,7 +71,6 @@
 #define PCH_REC			0x00007f00
 #define PCH_TEC			0x000000ff

-
 #define PCH_TX_OK		BIT(3)
 #define PCH_RX_OK		BIT(4)
 #define PCH_EPASSIV		BIT(5)
@@ -178,7 +177,6 @@ struct pch_can_priv {
 	unsigned int int_enables;
 	unsigned int int_stat;
 	struct net_device *ndev;
-	spinlock_t msgif_reg_lock; /* Message Interface Registers Access Lock*/
 	unsigned int msg_obj[PCH_TX_OBJ_END];
 	struct pch_can_regs __iomem *regs;
 	struct napi_struct napi;
@@ -309,7 +307,6 @@ static void pch_can_check_if_busy(u32 __iomem
*creq_addr, u32 num)
 static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
 			     u32 set, enum pch_ifreg dir)
 {
-	unsigned long flags;
 	u32 ie;

 	if (dir)
@@ -317,7 +314,6 @@ static void pch_can_set_rxtx(struct pch_can_priv
*priv, u32 buff_num,
 	else
 		ie = PCH_IF_MCONT_RXIE;

-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	/* Reading the receive buffer data from RAM to Interface1 registers */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
 	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
@@ -338,10 +334,8 @@ static void pch_can_set_rxtx(struct pch_can_priv
*priv, u32 buff_num,
 	}

 	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }

-
 static void pch_can_set_rx_all(struct pch_can_priv *priv, u32 set)
 {
 	int i;
@@ -363,7 +357,6 @@ static void pch_can_set_tx_all(struct pch_can_priv
*priv, u32 set)
 static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num,
 			       enum pch_ifreg dir)
 {
-	unsigned long flags;
 	u32 ie, enable;

 	if (dir)
@@ -371,7 +364,6 @@ static u32 pch_can_get_rxtx_ir(struct pch_can_priv
*priv, u32 buff_num,
 	else
 		ie = PCH_IF_MCONT_TXIE;

-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
 	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);

@@ -381,7 +373,6 @@ static u32 pch_can_get_rxtx_ir(struct pch_can_priv
*priv, u32 buff_num,
 	} else {
 		enable = 0;
 	}
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 	return enable;
 }

@@ -393,9 +384,6 @@ static int pch_can_int_pending(struct pch_can_priv
*priv)
 static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
 				       u32 buffer_num, u32 set)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
 	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
 	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
@@ -407,15 +395,11 @@ static void pch_can_set_rx_buffer_link(struct
pch_can_priv *priv,
 		pch_can_bit_set(&priv->regs->ifregs[0].mcont, PCH_IF_MCONT_EOB);

 	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }

 static void pch_can_get_rx_buffer_link(struct pch_can_priv *priv,
 				       u32 buffer_num, u32 *link)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
 	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);

@@ -423,7 +407,6 @@ static void pch_can_get_rx_buffer_link(struct
pch_can_priv *priv,
 		*link = PCH_DISABLE;
 	else
 		*link = PCH_ENABLE;
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }

 static void pch_can_clear_buffers(struct pch_can_priv *priv)
@@ -468,9 +451,6 @@ static void pch_can_clear_buffers(struct
pch_can_priv *priv)
 static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 {
 	int i;
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);

 	for (i = PCH_RX_OBJ_START; i <= PCH_RX_OBJ_END; i++) {
 		iowrite32(PCH_CMASK_RX_TX_GET,
@@ -529,7 +509,6 @@ static void pch_can_config_rx_tx_buffers(struct
pch_can_priv *priv)

 		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i);
 	}
-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }

 static void pch_can_init(struct pch_can_priv *priv)
@@ -845,7 +824,6 @@ static int pch_can_rx_poll(struct napi_struct *napi,
int quota)
 	u32 int_stat;
 	int rcv_pkts = 0;
 	u32 reg_stat;
-	unsigned long flags;

 	int_stat = pch_can_int_pending(priv);
 	if (!int_stat)
@@ -860,12 +838,10 @@ INT_STAT:
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

@@ -879,22 +855,18 @@ INT_STAT:

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
@@ -1042,7 +1014,6 @@ static int pch_close(struct net_device *ndev)
 static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	int i, j;
-	unsigned long flags;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	int tx_buffer_avail = 0;
@@ -1061,9 +1032,6 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb,
struct net_device *ndev)
 		priv->tx_obj++;
 	}

-	/* Attaining the lock. */
-	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-
 	/* Reading the Msg Obj from the Msg RAM to the Interface register. */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
 	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_buffer_avail);
@@ -1115,8 +1083,6 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb,
struct net_device *ndev)

 	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_buffer_avail);

-	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
-
 	return NETDEV_TX_OK;
 }

-- 
1.6.0.6

From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (16/25) sk98: don't redefine DEV_KFREE and IRQ
Date: Mon, 15 Nov 2004 15:44:53 -0800
Message-ID: <20041115154453.0eabbcf6@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don't redefine DEV_KFREE and irq return types.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 13:49:08 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 13:49:08 -08:00
@@ -166,22 +166,12 @@
 // #define CON_TYPE 	{"Auto", }
 // #define RLMT_MODE	{"CheckLinkState", }
 
-#define DEV_KFREE_SKB(skb) dev_kfree_skb(skb)
-#define DEV_KFREE_SKB_IRQ(skb) dev_kfree_skb_irq(skb)
-#define DEV_KFREE_SKB_ANY(skb) dev_kfree_skb_any(skb)
-
-
 /* Set blink mode*/
 #define OEM_CONFIG_VALUE (	SK_ACT_LED_BLINK | \
 				SK_DUP_LED_NORMAL | \
 				SK_LED_LINK100_ON)
 
 
-/* Isr return value */
-#define SkIsrRetVar	irqreturn_t
-#define SkIsrRetNone	IRQ_NONE
-#define SkIsrRetHandled	IRQ_HANDLED
-
 
 /*******************************************************************************
  *
@@ -195,8 +185,8 @@
 static void	BoardFreeMem(SK_AC *pAC);
 static void	BoardInitMem(SK_AC *pAC);
 static void	SetupRing(SK_AC*, void*, u64, RXD**, RXD**, RXD**, int*, SK_BOOL);
-static SkIsrRetVar	SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs);
-static SkIsrRetVar	SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs);
+static irqreturn_t SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs);
+static irqreturn_t SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs);
 static int	SkGeOpen(struct net_device *dev);
 static int	SkGeClose(struct net_device *dev);
 static int	SkGeSetMacAddr(struct net_device *dev, void *p);
@@ -839,7 +829,7 @@
  * Returns: N/A
  *
  */
-static SkIsrRetVar SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs)
+static irqreturn_t SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs)
 {
 struct net_device *dev = (struct net_device *)dev_id;
 DEV_NET		*pNet;
@@ -853,8 +843,8 @@
 	 * Check and process if its our interrupt
 	 */
 	SK_IN32(pAC->IoBase, B0_SP_ISRC, &IntSrc);
-	if (IntSrc == 0) {
-		return SkIsrRetNone;
+	if (IntSrc == 0 || IntSrc == ~0) {
+		return IRQ_NONE;
 	}
 
 	while (((IntSrc & IRQ_MASK) & ~SPECIAL_IRQS) != 0) {
@@ -971,7 +961,7 @@
 	/* IRQ is processed - Enable IRQs again*/
 	SK_OUT32(pAC->IoBase, B0_IMSK, pAC->GIni.GIValIrqMask);
 
-		return SkIsrRetHandled;
+	return IRQ_HANDLED;
 } /* SkGeIsr */
 
 
@@ -988,7 +978,7 @@
  * Returns: N/A
  *
  */
-static SkIsrRetVar SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs)
+static irqreturn_t SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs)
 {
 struct net_device *dev = (struct net_device *)dev_id;
 DEV_NET		*pNet;
@@ -1002,8 +992,8 @@
 	 * Check and process if its our interrupt
 	 */
 	SK_IN32(pAC->IoBase, B0_SP_ISRC, &IntSrc);
-	if (IntSrc == 0) {
-		return SkIsrRetNone;
+	if (IntSrc == 0 || IntSrc == ~0) {
+		return IRQ_NONE;
 	}
 	
 	while (((IntSrc & IRQ_MASK) & ~SPECIAL_IRQS) != 0) {
@@ -1077,12 +1067,12 @@
 	 *           guarded now
 	 *
 	ReceiveIrq(pAC, &pAC->RxPort[0], SK_TRUE);
-	 */
+	*/
 
 	/* IRQ is processed - Enable IRQs again*/
 	SK_OUT32(pAC->IoBase, B0_IMSK, pAC->GIni.GIValIrqMask);
 
-		return SkIsrRetHandled;
+	return IRQ_HANDLED;
 } /* SkGeIsrOnePort */
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1777,7 +1767,7 @@
 				 PCI_DMA_TODEVICE);
 
 		if (Control & BMU_EOF)
-			DEV_KFREE_SKB_ANY(pTxd->pMBuf);	/* free message */
+			dev_kfree_skb_any(pTxd->pMBuf);	/* free message */
 
 		pTxPort->TxdRingFree++;
 		pTxd->TBControl &= ~BMU_SW;
@@ -2207,7 +2197,7 @@
 				SK_DBG_MSG(NULL, SK_DBGMOD_DRV,
 					SK_DBGCAT_DRV_RX_PROGRESS,
 					("D"));
-				DEV_KFREE_SKB(pMsg);
+				dev_kfree_skb(pMsg);
 			}
 			
 		} /* if not for rlmt */
@@ -2256,7 +2246,7 @@
 				pAC->dev[pRxPort->PortIndex]->last_rx = jiffies;
 			}
 			else {
-				DEV_KFREE_SKB(pMsg);
+				dev_kfree_skb(pMsg);
 			}
 
 		} /* if packet for rlmt */
@@ -2283,7 +2273,7 @@
 			 PhysAddr,
 			 pAC->RxBufSize - 2,
 			 PCI_DMA_FROMDEVICE);
-	DEV_KFREE_SKB_IRQ(pRxd->pMBuf);
+	dev_kfree_skb_irq(pRxd->pMBuf);
 	pRxd->pMBuf = NULL;
 	pRxPort->RxdRingFree++;
 	pRxPort->pRxdRingHead = pRxd->pNextRxd;
@@ -2366,7 +2356,7 @@
 					 PhysAddr,
 					 pAC->RxBufSize - 2,
 					 PCI_DMA_FROMDEVICE);
-			DEV_KFREE_SKB(pRxd->pMBuf);
+			dev_kfree_skb(pRxd->pMBuf);
 			pRxd->pMBuf = NULL;
 		}
 		pRxd->RBControl &= BMU_OWN;
@@ -3866,7 +3856,7 @@
 	pFreeMbuf = pMbuf;
 	do {
 		pNextMbuf = pFreeMbuf->pNext;
-		DEV_KFREE_SKB_ANY(pFreeMbuf->pOs);
+		dev_kfree_skb_any(pFreeMbuf->pOs);
 		pFreeMbuf = pNextMbuf;
 	} while ( pFreeMbuf != NULL );
 } /* SkDrvFreeRlmtMbuf */
@@ -4337,7 +4327,7 @@
 		if (XmitFrame(pAC, &pAC->TxPort[pRlmtMbuf->PortIdx][TX_PRIO_LOW],
 			pMsg) < 0)
 
-			DEV_KFREE_SKB_ANY(pMsg);
+			dev_kfree_skb_any(pMsg);
 		break;
 	case SK_DRV_TIMER:
 		if (Param.Para32[0] == SK_DRV_MODERATION_TIMER) {

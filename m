From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (14/23) sk98: don't obfuscate irqreturn_t
Date: Thu, 11 Nov 2004 16:01:21 -0800
Message-ID: <20041111160121.7e3d20b6@zqx3.pdx.osdl.net>
References: <4192C60A.1050205@designassembly.de>
	<20041111154225.5cf85567@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner
 <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041111154225.5cf85567@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dont redefine irqreturn_t and dev_kfree anymore.
It probably was done for compatiablity with 2.4 but we
are past that point now.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-03 16:26:15 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-03 16:26:15 -08:00
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
 static void	SetupRing(SK_AC*, void*, uintptr_t, RXD**, RXD**, RXD**, int*, SK_BOOL);
-static SkIsrRetVar	SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs);
-static SkIsrRetVar	SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs);
+static irqreturn_t	SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs);
+static irqreturn_t	SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs);
 static int	SkGeOpen(struct net_device *dev);
 static int	SkGeClose(struct net_device *dev);
 static int	SkGeXmit(struct sk_buff *skb, struct net_device *dev);
@@ -895,7 +885,7 @@
  * Returns: N/A
  *
  */
-static SkIsrRetVar SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs)
+static irqreturn_t SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs)
 {
 struct net_device *dev = (struct net_device *)dev_id;
 DEV_NET		*pNet;
@@ -909,8 +899,8 @@
 	 * Check and process if its our interrupt
 	 */
 	SK_IN32(pAC->IoBase, B0_SP_ISRC, &IntSrc);
-	if (IntSrc == 0) {
-		return SkIsrRetNone;
+	if (IntSrc == 0 || IntSrc == ~0) {
+		return IRQ_NONE;
 	}
 
 	while (((IntSrc & IRQ_MASK) & ~SPECIAL_IRQS) != 0) {
@@ -1027,7 +1017,7 @@
 	/* IRQ is processed - Enable IRQs again*/
 	SK_OUT32(pAC->IoBase, B0_IMSK, pAC->GIni.GIValIrqMask);
 
-		return SkIsrRetHandled;
+	return IRQ_HANDLED;
 } /* SkGeIsr */
 
 
@@ -1044,12 +1034,12 @@
  * Returns: N/A
  *
  */
-static SkIsrRetVar SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs)
+static irqreturn_t SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs)
 {
-struct net_device *dev = (struct net_device *)dev_id;
-DEV_NET		*pNet;
-SK_AC		*pAC;
-SK_U32		IntSrc;		/* interrupts source register contents */	
+struct net_device *dev = (struct net_device *)dev_id;
+DEV_NET		*pNet;
+SK_AC		*pAC;
+SK_U32		IntSrc;		/* interrupts source register contents */	
 
 	pNet = netdev_priv(dev);
 	pAC = pNet->pAC;
@@ -1058,30 +1048,30 @@
 	 * Check and process if its our interrupt
 	 */
 	SK_IN32(pAC->IoBase, B0_SP_ISRC, &IntSrc);
-	if (IntSrc == 0) {
-		return SkIsrRetNone;
+	if (IntSrc == 0 || IntSrc == ~0) {
+		return IRQ_NONE;
 	}
 	
 	while (((IntSrc & IRQ_MASK) & ~SPECIAL_IRQS) != 0) {
 #if 0 /* software irq currently not used */
 		if (IntSrc & IS_IRQ_SW) {
 			SK_DBG_MSG(NULL, SK_DBGMOD_DRV,
-				SK_DBGCAT_DRV_INT_SRC,
-				("Software IRQ\n"));
+				SK_DBGCAT_DRV_INT_SRC,
+				("Software IRQ\n"));
 		}
 #endif
 		if (IntSrc & IS_R1_F) {
 			SK_DBG_MSG(NULL, SK_DBGMOD_DRV,
-				SK_DBGCAT_DRV_INT_SRC,
-				("EOF RX1 IRQ\n"));
+				SK_DBGCAT_DRV_INT_SRC,
+				("EOF RX1 IRQ\n"));
 			ReceiveIrq(pAC, &pAC->RxPort[0], SK_TRUE);
 			SK_PNMI_CNT_RX_INTR(pAC, 0);
 		}
 #ifdef USE_TX_COMPLETE /* only if tx complete interrupt used */
 		if (IntSrc & IS_XA1_F) {
 			SK_DBG_MSG(NULL, SK_DBGMOD_DRV,
-				SK_DBGCAT_DRV_INT_SRC,
-				("EOF AS TX1 IRQ\n"));
+				SK_DBGCAT_DRV_INT_SRC,
+				("EOF AS TX1 IRQ\n"));
 			SK_PNMI_CNT_TX_INTR(pAC, 0);
 			spin_lock(&pAC->TxPort[0][TX_PRIO_LOW].TxDesRingLock);
 			FreeTxDescriptors(pAC, &pAC->TxPort[0][TX_PRIO_LOW]);
@@ -1132,13 +1122,13 @@
 	 *           SkGeDrvEvent(), because it is timer
 	 *           guarded now
 	 *
-	ReceiveIrq(pAC, &pAC->RxPort[0], SK_TRUE);
-	 */
+	ReceiveIrq(pAC, &pAC->RxPort[0], SK_TRUE);
+	*/
 
 	/* IRQ is processed - Enable IRQs again*/
 	SK_OUT32(pAC->IoBase, B0_IMSK, pAC->GIni.GIValIrqMask);
 
-		return SkIsrRetHandled;
+	return IRQ_HANDLED;
 } /* SkGeIsrOnePort */
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1837,7 +1827,7 @@
 				 PCI_DMA_TODEVICE);
 
 		if (Control & BMU_EOF)
-			DEV_KFREE_SKB_ANY(pTxd->pMBuf);	/* free message */
+			dev_kfree_skb_any(pTxd->pMBuf);	/* free message */
 
 		pTxPort->TxdRingFree++;
 		pTxd->TBControl &= ~BMU_SW;
@@ -2267,7 +2257,7 @@
 				SK_DBG_MSG(NULL, SK_DBGMOD_DRV,
 					SK_DBGCAT_DRV_RX_PROGRESS,
 					("D"));
-				DEV_KFREE_SKB(pMsg);
+				dev_kfree_skb(pMsg);
 			}
 			
 		} /* if not for rlmt */
@@ -2316,7 +2306,7 @@
 				pAC->dev[pRxPort->PortIndex]->last_rx = jiffies;
 			}
 			else {
-				DEV_KFREE_SKB(pMsg);
+				dev_kfree_skb(pMsg);
 			}
 
 		} /* if packet for rlmt */
@@ -2343,7 +2333,7 @@
 			 PhysAddr,
 			 pAC->RxBufSize - 2,
 			 PCI_DMA_FROMDEVICE);
-	DEV_KFREE_SKB_IRQ(pRxd->pMBuf);
+	dev_kfree_skb_irq(pRxd->pMBuf);
 	pRxd->pMBuf = NULL;
 	pRxPort->RxdRingFree++;
 	pRxPort->pRxdRingHead = pRxd->pNextRxd;
@@ -2426,7 +2416,7 @@
 					 PhysAddr,
 					 pAC->RxBufSize - 2,
 					 PCI_DMA_FROMDEVICE);
-			DEV_KFREE_SKB(pRxd->pMBuf);
+			dev_kfree_skb(pRxd->pMBuf);
 			pRxd->pMBuf = NULL;
 		}
 		pRxd->RBControl &= BMU_OWN;
@@ -3935,7 +3925,7 @@
 	pFreeMbuf = pMbuf;
 	do {
 		pNextMbuf = pFreeMbuf->pNext;
-		DEV_KFREE_SKB_ANY(pFreeMbuf->pOs);
+		dev_kfree_skb_any(pFreeMbuf->pOs);
 		pFreeMbuf = pNextMbuf;
 	} while ( pFreeMbuf != NULL );
 } /* SkDrvFreeRlmtMbuf */
@@ -4406,7 +4396,7 @@
 		if (XmitFrame(pAC, &pAC->TxPort[pRlmtMbuf->PortIdx][TX_PRIO_LOW],
 			pMsg) < 0)
 
-			DEV_KFREE_SKB_ANY(pMsg);
+			dev_kfree_skb_any(pMsg);
 		break;
 	case SK_DRV_TIMER:
 		if (Param.Para32[0] == SK_DRV_MODERATION_TIMER) {

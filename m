From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (15/25) sk98: handle tranmit ring full
Date: Mon, 15 Nov 2004 15:44:45 -0800
Message-ID: <20041115154445.701240d7@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tommy Christensen <tommy.christensen@tpack.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Return correct value when ring is full, and stop queue when reaches
maximum. Need to check ring status under lock to avoid race with transmit
interrupt. Don't drop skb when returning busy!

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 13:46:45 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 13:46:45 -08:00
@@ -1354,67 +1354,47 @@
  * Description:
  *	The system calls this function to send frames onto the wire.
  *	It puts the frame in the tx descriptor ring. If the ring is
- *	full then, the 'tbusy' flag is set.
+ *	full then, the it returns busy and leaves skb alone.
  *
  * Returns:
- *	0, if everything is ok
- *	!=0, on error
- * WARNING: returning 1 in 'tbusy' case caused system crashes (double
- *	allocated skb's) !!!
+ *	0 (NETDEV_TX_OK) 	if everything is ok
+ *	1 (NETDEV_TX_BUSY) 	if ring is full
  */
 int SkGeXmit(struct sk_buff *skb, struct net_device *dev)
 {
-DEV_NET		*pNet;
-SK_AC		*pAC;
-int			Rc;	/* return code of XmitFrame */
-
-	pNet = netdev_priv(dev);
-	pAC = pNet->pAC;
+	DEV_NET	*pNet = netdev_priv(dev);
+	SK_AC	*pAC = pNet->pAC;
+	TX_PORT		*pTxPort;
+	int	rc;
+	unsigned long flags;
+ 
+	if (pAC->RlmtNets == 2)
+		pTxPort = &pAC->TxPort[pNet->PortNr][TX_PRIO_LOW];
+	else
+		pTxPort = &pAC->TxPort[pAC->ActivePort][TX_PRIO_LOW];
+ 
+	spin_lock_irqsave(&pTxPort->TxDesRingLock, flags);
 
 	if ((!skb_shinfo(skb)->nr_frags) ||
-		(pAC->GIni.GIChipId == CHIP_ID_GENESIS)) {
-		/* Don't activate scatter-gather and hardware checksum */
-
-		if (pAC->RlmtNets == 2)
-			Rc = XmitFrame(
-				pAC,
-				&pAC->TxPort[pNet->PortNr][TX_PRIO_LOW],
-				skb);
-		else
-			Rc = XmitFrame(
-				pAC,
-				&pAC->TxPort[pAC->ActivePort][TX_PRIO_LOW],
-				skb);
-	} else {
-		/* scatter-gather and hardware TCP checksumming anabled*/
-		if (pAC->RlmtNets == 2)
-			Rc = XmitFrameSG(
-				pAC,
-				&pAC->TxPort[pNet->PortNr][TX_PRIO_LOW],
-				skb);
-		else
-			Rc = XmitFrameSG(
-				pAC,
-				&pAC->TxPort[pAC->ActivePort][TX_PRIO_LOW],
-				skb);
-	}
-
-	/* Transmitter out of resources? */
-	if (Rc <= 0) {
+	    (pAC->GIni.GIChipId == CHIP_ID_GENESIS)) 
+		rc = XmitFrame(pAC, pTxPort, skb);
+	else 
+		rc = XmitFrameSG(pAC, pTxPort, skb);
+  
+	/* is space left for next transmit? */
+	if (rc <= 0) 
 		netif_stop_queue(dev);
-	}
+  
+	spin_unlock_irqrestore(&pTxPort->TxDesRingLock, flags);
+ 
+	/* Transmit failed, out of resources */
+	if (unlikely(rc < 0)) 
+		return NETDEV_TX_BUSY;
 
-	/* If not taken, give buffer ownership back to the
-	 * queueing layer.
-	 */
-	if (Rc < 0)
-		return (1);
-
-	dev->trans_start = jiffies;
-	return (0);
+	dev->trans_start = jiffies;		
+	return NETDEV_TX_OK;
 } /* SkGeXmit */
 
-
 /*****************************************************************************
  *
  * 	XmitFrame - fill one socket buffer into the transmit ring
@@ -1444,7 +1424,6 @@
 {
 	TXD		*pTxd;		/* the rxd to fill */
 	TXD		*pOldTxd;
-	unsigned long	 Flags;
 	SK_U64		 PhysAddr;
 	int	 	 Protocol;
 	int		 IpHeaderLength;
@@ -1452,7 +1431,6 @@
 
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_TX_PROGRESS, ("X"));
 
-	spin_lock_irqsave(&pTxPort->TxDesRingLock, Flags);
 #ifndef USE_TX_COMPLETE
 	FreeTxDescriptors(pAC, pTxPort);
 #endif
@@ -1463,7 +1441,6 @@
 		*/
 		FreeTxDescriptors(pAC, pTxPort);
 		if (pTxPort->TxdRingFree == 0) {
-			spin_unlock_irqrestore(&pTxPort->TxDesRingLock, Flags);
 			SK_PNMI_CNT_NO_TX_BUF(pAC, pTxPort->PortIndex);
 			SK_DBG_MSG(NULL, SK_DBGMOD_DRV,
 				SK_DBGCAT_DRV_TX_PROGRESS,
@@ -1486,7 +1463,6 @@
 	*/
 	if (BytesSend < C_LEN_ETHERNET_MINSIZE) {
 		if ((pMessage = skb_padto(pMessage, C_LEN_ETHERNET_MINSIZE)) == NULL) {
-			spin_unlock_irqrestore(&pTxPort->TxDesRingLock, Flags);
 			return 0;
 		}
 		pMessage->len = C_LEN_ETHERNET_MINSIZE;
@@ -1561,16 +1537,7 @@
 		SK_OUT8(pTxPort->HwAddr, Q_CSR, CSR_START);
 	}	
 
-	/* 
-	** after releasing the lock, the skb may immediately be free'd 
-	*/
-	spin_unlock_irqrestore(&pTxPort->TxDesRingLock, Flags);
-	if (pTxPort->TxdRingFree != 0) {
-		return (BytesSend);
-	} else {
-		return (0);
-	}
-
+	return (pTxPort->TxdRingFree != 0);
 } /* XmitFrame */
 
 /*****************************************************************************
@@ -1603,16 +1570,13 @@
 	int		 Protocol;
 	skb_frag_t	*sk_frag;
 	SK_U64		 PhysAddr;
-	unsigned long	 Flags;
 
-	spin_lock_irqsave(&pTxPort->TxDesRingLock, Flags);
 #ifndef USE_TX_COMPLETE
 	FreeTxDescriptors(pAC, pTxPort);
 #endif
 	if ((skb_shinfo(pMessage)->nr_frags +1) > pTxPort->TxdRingFree) {
 		FreeTxDescriptors(pAC, pTxPort);
 		if ((skb_shinfo(pMessage)->nr_frags + 1) > pTxPort->TxdRingFree) {
-			spin_unlock_irqrestore(&pTxPort->TxDesRingLock, Flags);
 			SK_PNMI_CNT_NO_TX_BUF(pAC, pTxPort->PortIndex);
 			SK_DBG_MSG(NULL, SK_DBGMOD_DRV,
 				SK_DBGCAT_DRV_TX_PROGRESS,
@@ -1744,13 +1708,7 @@
 	pTxPort->pTxdRingPrev = pTxdLst;
 	pTxPort->pTxdRingHead = pTxd;
 
-	spin_unlock_irqrestore(&pTxPort->TxDesRingLock, Flags);
-
-	if (pTxPort->TxdRingFree > 0) {
-		return (BytesSend);
-	} else {
-		return (0);
-	}
+	return (pTxPort->TxdRingFree > 0);
 }
 
 /*****************************************************************************

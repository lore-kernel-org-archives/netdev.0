From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (13/23) sk98: handle ring full correctly
Date: Thu, 11 Nov 2004 16:00:08 -0800
Message-ID: <20041111160008.005fbca5@zqx3.pdx.osdl.net>
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

This driver needs to manage it's transmit queue properly.
The hard_start_xmit needs to return OK if send successfully
and BUSY (1) if queue is full. In either case must free skb,
existing code would leak if tx ring filled!

Also, check if queue is send fills queue and stop transmit queue 
as needed. In order to test for ring full w/o race, pull locking 
up from XmitFrame to SkGeXmit

Signed-off-by: Stephen Hemminger<shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-03 15:56:39 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-03 15:56:39 -08:00
@@ -1396,59 +1396,43 @@
  * Returns:
  *	0, if everything is ok
  *	!=0, on error
- * WARNING: returning 1 in 'tbusy' case caused system crashes (double
- *	allocated skb's) !!!
  */
 static int SkGeXmit(struct sk_buff *skb, struct net_device *dev)
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
 
+	spin_lock_irqsave(&pTxPort->TxDesRingLock, flags);
 	if ((!skb_shinfo(skb)->nr_frags) ||
 		(pAC->GIni.GIChipId == CHIP_ID_GENESIS)) {
 		/* Don't activate scatter-gather and hardware checksum */
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
+		rc = XmitFrame( pAC, pTxPort, skb);
 	} else {
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
+		rc = XmitFrameSG(pAC, pTxPort, skb);
 	}
 
-	/* Transmitter out of resources? */
-	if (Rc <= 0) {
+	/* No space left for next transmit */
+	if (rc <= 0) 
 		netif_stop_queue(dev);
-	}
 
-	/* If not taken, give buffer ownership back to the
-	 * queueing layer.
-	 */
-	if (Rc < 0)
-		return (1);
+	spin_unlock_irqrestore(&pTxPort->TxDesRingLock, flags);
 
-	dev->trans_start = jiffies;
-	return (0);
+	/* Transmit failed, out of resources */
+	if (rc < 0) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_BUSY;
+	} else {
+		dev->trans_start = jiffies;		
+		return NETDEV_TX_OK;
+	}
 } /* SkGeXmit */
 
 
@@ -1481,7 +1465,6 @@
 {
 	TXD		*pTxd;		/* the rxd to fill */
 	TXD		*pOldTxd;
-	unsigned long	 Flags;
 	SK_U64		 PhysAddr;
 	int	 	 Protocol;
 	int		 IpHeaderLength;
@@ -1489,7 +1472,6 @@
 
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_TX_PROGRESS, ("X"));
 
-	spin_lock_irqsave(&pTxPort->TxDesRingLock, Flags);
 #ifndef USE_TX_COMPLETE
 	FreeTxDescriptors(pAC, pTxPort);
 #endif
@@ -1500,7 +1482,6 @@
 		*/
 		FreeTxDescriptors(pAC, pTxPort);
 		if (pTxPort->TxdRingFree == 0) {
-			spin_unlock_irqrestore(&pTxPort->TxDesRingLock, Flags);
 			SK_PNMI_CNT_NO_TX_BUF(pAC, pTxPort->PortIndex);
 			SK_DBG_MSG(NULL, SK_DBGMOD_DRV,
 				SK_DBGCAT_DRV_TX_PROGRESS,
@@ -1523,7 +1504,6 @@
 	*/
 	if (BytesSend < C_LEN_ETHERNET_MINSIZE) {
 		if ((pMessage = skb_padto(pMessage, C_LEN_ETHERNET_MINSIZE)) == NULL) {
-			spin_unlock_irqrestore(&pTxPort->TxDesRingLock, Flags);
 			return 0;
 		}
 		pMessage->len = C_LEN_ETHERNET_MINSIZE;
@@ -1598,16 +1578,7 @@
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
@@ -1640,16 +1611,13 @@
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
@@ -1781,13 +1749,7 @@
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

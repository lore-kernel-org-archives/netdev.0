From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (21/23) sk98: transmit ring barriers
Date: Thu, 11 Nov 2004 16:09:25 -0800
Message-ID: <20041111160925.69912766@zqx3.pdx.osdl.net>
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

Transmit descriptor control doesn't need to be volatile, it is
much better to use explicit memory barriers. This generates better
code and makes sure that ordering is maintained. When doing SG
figure out the bits once rather than for each frag.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-10 11:29:09 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-10 11:29:09 -08:00
@@ -227,7 +227,7 @@
 typedef struct s_TxD TXD; /* the transmit descriptor */
 
 struct s_TxD {
-	volatile SK_U32	TBControl;	/* Transmit Buffer Control */
+	SK_U32		TBControl;	/* Transmit Buffer Control */
 	SK_U32		VNextTxd;	/* Next transmit descriptor,low dword */
 	SK_U32		VDataLow;	/* Transmit Buffer Addr, low dword */
 	SK_U32		VDataHigh;	/* Transmit Buffer Addr, high dword */
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-10 11:29:09 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-10 11:29:09 -08:00
@@ -1760,9 +1760,6 @@
 	TXD		*pTxd;		/* the rxd to fill */
 	TXD		*pOldTxd;
 	SK_U64		 PhysAddr;
-	int	 	 Protocol;
-	int		 IpHeaderLength;
-	int		 BytesSend = pMessage->len;
 
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_TX_PROGRESS, ("X"));
 
@@ -1796,7 +1793,7 @@
 	** the original packet end and the new packet end of 60 with 0x00.
 	** This is to resolve faulty padding by the HW with 0xaa bytes.
 	*/
-	if (BytesSend < C_LEN_ETHERNET_MINSIZE) {
+	if (pMessage->len < C_LEN_ETHERNET_MINSIZE) {
 		if ((pMessage = skb_padto(pMessage, C_LEN_ETHERNET_MINSIZE)) == NULL) {
 			return 0;
 		}
@@ -1831,7 +1828,10 @@
 	pTxd->pMBuf     = pMessage;
 
 	if (pMessage->ip_summed == CHECKSUM_HW) {
-		Protocol = ((SK_U8)pMessage->data[C_OFFSET_IPPROTO] & 0xff);
+		SK_U8 Protocol = pMessage->data[C_OFFSET_IPPROTO];
+		int IpHeaderLength
+			= (pMessage->data[C_OFFSET_IPHEADER]&0xf) * 4;
+
 		if ((Protocol == C_PROTO_ID_UDP) && 
 			(pAC->GIni.GIChipRev == 0) &&
 			(pAC->GIni.GIChipId == CHIP_ID_YUKON)) {
@@ -1840,13 +1840,11 @@
 			pTxd->TBControl = BMU_UDP_CHECK;
 		}
 
-		IpHeaderLength  = (SK_U8)pMessage->data[C_OFFSET_IPHEADER];
-		IpHeaderLength  = (IpHeaderLength & 0xf) * 4;
 		pTxd->TcpSumOfs = 0; /* PH-Checksum already calculated */
-		pTxd->TcpSumSt  = C_LEN_ETHERMAC_HEADER + IpHeaderLength + 
-							(Protocol == C_PROTO_ID_UDP ?
-							C_OFFSET_UDPHEADER_UDPCS : 
-							C_OFFSET_TCPHEADER_TCPCS);
+		pTxd->TcpSumSt  = C_LEN_ETHERMAC_HEADER + IpHeaderLength
+			+ (Protocol == C_PROTO_ID_UDP ?
+			   C_OFFSET_UDPHEADER_UDPCS : 
+			   C_OFFSET_TCPHEADER_TCPCS);
 		pTxd->TcpSumWr  = C_LEN_ETHERMAC_HEADER + IpHeaderLength;
 
 		pTxd->TBControl |= BMU_OWN | BMU_STF | 
@@ -1863,6 +1861,7 @@
 #endif
 			pMessage->len;
 	}
+	wmb();
 
 	/* 
 	** If previous descriptor already done, give TX start cmd 
@@ -1901,9 +1900,8 @@
 	TXD		*pTxdLst;
 	int 	 	 CurrFrag;
 	int		 BytesSend;
-	int		 IpHeaderLength; 
-	int		 Protocol;
 	skb_frag_t	*sk_frag;
+	SK_U32		 CheckMsk;
 	SK_U64		 PhysAddr;
 
 #ifndef USE_TX_COMPLETE
@@ -1925,7 +1923,6 @@
 	pTxdFst   = pTxd;
 	pTxdLst   = pTxd;
 	BytesSend = 0;
-	Protocol  = 0;
 
 	/* 
 	** Map the first fragment (header) into the DMA-space
@@ -1943,32 +1940,32 @@
 	** Does the HW need to evaluate checksum for TCP or UDP packets? 
 	*/
 	if (pMessage->ip_summed == CHECKSUM_HW) {
-		pTxd->TBControl = BMU_STF | BMU_STFWD | skb_headlen(pMessage);
+		SK_U8 Protocol = pMessage->data[C_OFFSET_IPPROTO];
+		int IpHeaderLength
+			= (pMessage->data[C_OFFSET_IPHEADER]&0xf) * 4;
+
 		/* 
 		** We have to use the opcode for tcp here,  because the
 		** opcode for udp is not working in the hardware yet 
 		** (Revision 2.0)
 		*/
-		Protocol = ((SK_U8)pMessage->data[C_OFFSET_IPPROTO] & 0xff);
 		if ((Protocol == C_PROTO_ID_UDP) && 
 			(pAC->GIni.GIChipRev == 0) &&
-			(pAC->GIni.GIChipId == CHIP_ID_YUKON)) {
-			pTxd->TBControl |= BMU_TCP_CHECK;
-		} else {
-			pTxd->TBControl |= BMU_UDP_CHECK;
-		}
+			(pAC->GIni.GIChipId == CHIP_ID_YUKON))
+			CheckMsk = BMU_TCP_CHECK | BMU_STFWD;
+		else 
+			CheckMsk = BMU_UDP_CHECK;
 
-		IpHeaderLength  = ((SK_U8)pMessage->data[C_OFFSET_IPHEADER] & 0xf)*4;
 		pTxd->TcpSumOfs = 0; /* PH-Checksum already claculated */
-		pTxd->TcpSumSt  = C_LEN_ETHERMAC_HEADER + IpHeaderLength +
-						(Protocol == C_PROTO_ID_UDP ?
-						C_OFFSET_UDPHEADER_UDPCS :
-						C_OFFSET_TCPHEADER_TCPCS);
+		pTxd->TcpSumSt  = C_LEN_ETHERMAC_HEADER + IpHeaderLength
+			+ (Protocol == C_PROTO_ID_UDP ?
+			   C_OFFSET_UDPHEADER_UDPCS :
+			   C_OFFSET_TCPHEADER_TCPCS);
 		pTxd->TcpSumWr  = C_LEN_ETHERMAC_HEADER + IpHeaderLength;
-	} else {
-		pTxd->TBControl = BMU_CHECK | BMU_SW | BMU_STF |
-					skb_headlen(pMessage);
-	}
+	} else 
+		CheckMsk = BMU_CHECK;
+
+	pTxd->TBControl = CheckMsk | BMU_STF | skb_headlen(pMessage);
 
 	pTxd = pTxd->pNextTxd;
 	pTxPort->TxdRingFree--;
@@ -1992,41 +1989,21 @@
 		pTxd->VDataHigh = (SK_U32) (PhysAddr >> 32);
 		pTxd->pMBuf     = pMessage;
 		
-		/* 
-		** Does the HW need to evaluate checksum for TCP or UDP packets? 
-		*/
-		if (pMessage->ip_summed == CHECKSUM_HW) {
-			pTxd->TBControl = BMU_OWN | BMU_SW | BMU_STFWD;
-			/* 
-			** We have to use the opcode for tcp here because the 
-			** opcode for udp is not working in the hardware yet 
-			** (revision 2.0)
-			*/
-			if ((Protocol == C_PROTO_ID_UDP) && 
-				(pAC->GIni.GIChipRev == 0) &&
-				(pAC->GIni.GIChipId == CHIP_ID_YUKON)) {
-				pTxd->TBControl |= BMU_TCP_CHECK;
-			} else {
-				pTxd->TBControl |= BMU_UDP_CHECK;
-			}
-		} else {
-			pTxd->TBControl = BMU_CHECK | BMU_SW | BMU_OWN;
-		}
+		pTxd->TBControl = BMU_OWN | BMU_SW | CheckMsk | sk_frag->size;
 
 		/* 
 		** Do we have the last fragment? 
 		*/
 		if( (CurrFrag+1) == skb_shinfo(pMessage)->nr_frags )  {
 #ifdef USE_TX_COMPLETE
-			pTxd->TBControl |= BMU_EOF | BMU_IRQ_EOF | sk_frag->size;
+			pTxd->TBControl |= BMU_EOF | BMU_IRQ_EOF;
 #else
-			pTxd->TBControl |= BMU_EOF | sk_frag->size;
+			pTxd->TBControl |= BMU_EOF;
 #endif
+			wmb();
 			pTxdFst->TBControl |= BMU_OWN | BMU_SW;
 
-		} else {
-			pTxd->TBControl |= sk_frag->size;
-		}
+		} 
 		pTxdLst = pTxd;
 		pTxd    = pTxd->pNextTxd;
 		pTxPort->TxdRingFree--;
@@ -2036,13 +2013,12 @@
 	/* 
 	** If previous descriptor already done, give TX start cmd 
 	*/
-	if ((pTxPort->pTxdRingPrev->TBControl & BMU_OWN) == 0) {
+	pTxPort->pTxdRingHead = pTxd;
+	pTxd = xchg(&pTxPort->pTxdRingPrev, pTxdLst);
+	if ((pTxd->TBControl & BMU_OWN) == 0) {
 		SK_OUT8(pTxPort->HwAddr, Q_CSR, CSR_START);
 	}
 
-	pTxPort->pTxdRingPrev = pTxdLst;
-	pTxPort->pTxdRingHead = pTxd;
-
 	return (pTxPort->TxdRingFree > 0);
 }
 
@@ -2080,6 +2056,7 @@
 	** or BMU_OWN bit set in any frame
 	*/
 	while (1) {
+		rmb();
 		Control = pTxd->TBControl;
 		if ((Control & BMU_SW) == 0) {
 			/*
@@ -2116,6 +2093,7 @@
 
 		pTxPort->TxdRingFree++;
 		pTxd->TBControl &= ~BMU_SW;
+		wmb();
 		pTxd = pTxd->pNextTxd; /* point behind fragment with EOF */
 	} /* while(forever) */
 } /* FreeTxDescriptors */
@@ -2674,6 +2652,7 @@
 		pTxd->TBControl &= ~BMU_OWN;
 		pTxd = pTxd->pNextTxd;
 	}
+	wmb();
 	FreeTxDescriptors(pAC, pTxPort);
 	spin_unlock_irqrestore(&pTxPort->TxDesRingLock, Flags);
 } /* ClearTxRing */

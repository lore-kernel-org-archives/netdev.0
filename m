From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/25) sk98: remove Up and Mtu per-device structure
 elements
Date: Mon, 15 Nov 2004 15:25:36 -0800
Message-ID: <20041115152536.632b0226@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The per-port elements (Up and Mtu) can both be derived from the net_device
state.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 11:31:21 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 11:31:21 -08:00
@@ -282,8 +282,6 @@
 	SK_AC   	*pAC;
 	int             PortNr;
 	int             NetNr;
-	int             Mtu;
-	int             Up;
 	struct proc_dir_entry *proc;
 };  
 
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 11:31:21 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 11:31:21 -08:00
@@ -1247,8 +1247,6 @@
 	spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 
 	pAC->MaxPorts++;
-	pNet->Up = 1;
-
 
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeOpen suceeded\n"));
@@ -1377,7 +1375,6 @@
 			sizeof(SK_PNMI_STRUCT_DATA));
 
 	pAC->MaxPorts--;
-	pNet->Up = 0;
 
 	return (0);
 } /* SkGeClose */
@@ -2620,7 +2617,7 @@
 static int SkGeChangeMtu(struct net_device *dev, int NewMtu)
 {
 DEV_NET		*pNet;
-DEV_NET		*pOtherNet;
+struct net_device *otherdev; 
 SK_AC		*pAC;
 unsigned long	Flags;
 int		i;
@@ -2650,11 +2647,10 @@
 	}
 #endif
 
-	pNet->Mtu = NewMtu;
-	pOtherNet = netdev_priv(pAC->dev[1 - pNet->NetNr]);
-	if ((pOtherNet->Mtu>1500) && (NewMtu<=1500) && (pOtherNet->Up==1)) {
-		return(0);
-	}
+	otherdev = pAC->dev[1 - pNet->NetNr];
+	if (NewMtu <= 1500 && otherdev != dev 
+  	    && netif_running(otherdev) && otherdev->mtu > 1500) 
+		return 0;
 
 	pAC->RxBufSize = NewMtu + 32;
 	dev->mtu = NewMtu;
@@ -2816,7 +2812,8 @@
 		EvPara.Para32[1] = -1;
 		SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_START, EvPara);
 			
-		if (pOtherNet->Up) {
+		if (otherdev != dev && netif_running(otherdev)) {
+			DEV_NET *pOtherNet = netdev_priv(otherdev);
 			EvPara.Para32[0] = pOtherNet->PortNr;
 			SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_START, EvPara);
 		}
@@ -2890,7 +2887,7 @@
 	pAC->stats.rx_bytes = (SK_U32) pPnmiStruct->RxOctetsDeliveredCts;
 	pAC->stats.tx_bytes = (SK_U32) pPnmiStat->StatTxOctetsOkCts;
 	
-        if (pNet->Mtu <= 1500) {
+        if (dev->mtu <= 1500) {
                 pAC->stats.rx_errors = (SK_U32) pPnmiStruct->InErrorsCts & 0xFFFFFFFF;
         } else {
                 pAC->stats.rx_errors = (SK_U32) ((pPnmiStruct->InErrorsCts -
@@ -4549,7 +4546,7 @@
 
 	pAC->DiagModeActive = DIAG_ACTIVE;
 	if (pAC->BoardLevel > SK_INIT_DATA) {
-		if (pNet->Up) {
+		if (netif_running(pAC->dev[0])) {
 			pAC->WasIfUp[0] = SK_TRUE;
 			pAC->DiagFlowCtrl = SK_TRUE; /* for SkGeClose      */
 			DoPrintInterfaceChange = SK_FALSE;
@@ -4557,9 +4554,10 @@
 		} else {
 			pAC->WasIfUp[0] = SK_FALSE;
 		}
+		
 		if (pNet != netdev_priv(pAC->dev[1])) {
 			pNet = netdev_priv(pAC->dev[1]);
-			if (pNet->Up) {
+			if (netif_running(pAC->dev[1])) {
 				pAC->WasIfUp[1] = SK_TRUE;
 				pAC->DiagFlowCtrl = SK_TRUE; /* for SkGeClose */
 				DoPrintInterfaceChange = SK_FALSE;
@@ -4918,8 +4916,6 @@
 	sprintf(pAC->Name, "SysKonnect SK-98xx");
 	pAC->CheckQueue = SK_FALSE;
 
-	pNet->Mtu = 1500;
-	pNet->Up = 0;
 	dev->irq = pdev->irq;
 	error = SkGeInitPCI(pAC);
 	if (error) {
@@ -5002,8 +4998,6 @@
 		pNet->PortNr  = 1;
 		pNet->NetNr   = 1;
 		pNet->pAC     = pAC;
-		pNet->Mtu     = 1500;
-		pNet->Up      = 0;
 
 		dev->open               = &SkGeOpen;
 		dev->stop               = &SkGeClose;

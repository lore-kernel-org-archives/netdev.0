From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (22/23) sk98: diag code changes
Date: Thu, 11 Nov 2004 16:09:55 -0800
Message-ID: <20041111160955.4570b327@zqx3.pdx.osdl.net>
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

Cleanup DIAG support code.
  * Use type safe structure assignment rather than memcpy
  * PCI device number is available in pci_dev don't need to go
    string parsing to find it.
  * Compile correctly if SK_DIAG_SUPPORT not defined

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-11 14:17:16 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-11 14:17:16 -08:00
@@ -364,10 +364,8 @@
 	SK_TIMER        ModTimer; /* just some timer */
 };
 
-#ifdef SK_DIAG_SUPPORT
 #define	DIAG_ACTIVE		1
 #define	DIAG_NOTACTIVE		0
-#endif
 
 /****************************************************************************
  * Per board structure / Adapter Context structure:
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-11 14:17:16 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-11 14:17:16 -08:00
@@ -219,7 +219,6 @@
 static int	XmitFrameSG(SK_AC*, TX_PORT*, struct sk_buff*);
 
 #ifdef SK_DIAG_SUPPORT
-static SK_U32   ParseDeviceNbrFromSlotName(const char *SlotName);
 static int      SkDrvInitAdapter(SK_AC *pAC, int devNbr);
 static int      SkDrvDeInitAdapter(SK_AC *pAC, int devNbr);
 #endif
@@ -460,8 +459,9 @@
 	pAC->Pnmi.pDriverFileName    = DRIVER_FILE_NAME;
 	pAC->Pnmi.pDriverReleaseDate = DRIVER_REL_DATE;
 
-	memset(&pAC->PnmiBackup, 0, sizeof(SK_PNMI_STRUCT_DATA));
-	memcpy(&pAC->PnmiBackup, &pAC->PnmiStruct, sizeof(SK_PNMI_STRUCT_DATA));
+#ifdef SK_DIAG_SUPPORT
+	pAC->PnmiBackup = pAC->PnmiStruct;
+#endif
 
 #ifdef USE_SK_RX_CHECKSUM
 	pAC->RxPort[0].UseRxCsum = SK_TRUE;
@@ -1565,7 +1565,6 @@
 struct net_device	*dev)
 {
 	DEV_NET		*pNet = netdev_priv(dev);
-	DEV_NET		*newPtrNet;
 	SK_AC		*pAC = pNet->pAC;
 
 	unsigned long	Flags;		/* for spin lock */
@@ -1579,6 +1578,7 @@
 #ifdef SK_DIAG_SUPPORT
 	if (pAC->DiagModeActive == DIAG_ACTIVE) {
 		if (pAC->DiagFlowCtrl == SK_FALSE) {
+			DEV_NET		*newPtrNet;
 			/* 
 			** notify that the interface which has been closed
 			** by operator interaction must not be started up 
@@ -1662,10 +1662,9 @@
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeClose: done "));
 
-	SK_MEMSET(&(pAC->PnmiBackup), 0, sizeof(SK_PNMI_STRUCT_DATA));
-	SK_MEMCPY(&(pAC->PnmiBackup), &(pAC->PnmiStruct), 
-			sizeof(SK_PNMI_STRUCT_DATA));
-
+#ifdef SK_DIAG_SUPPORT
+	pAC->PnmiBackup = pAC->PnmiStruct;
+#endif
 	pAC->MaxPorts--;
 
 	return (0);
@@ -3103,7 +3102,6 @@
 DEV_NET		*pNet;
 SK_AC		*pAC;
 void		*pMemBuf;
-struct pci_dev  *pdev = NULL;
 SK_GE_IOCTL	Ioctl;
 unsigned int	Err = 0;
 int		Size = 0;
@@ -3185,7 +3183,6 @@
 			Err = -EFAULT;
 			goto fault_diag;
 		}
-		pdev = pAC->PciDev;
 		Length = 3 * sizeof(SK_U32);  /* Error, Bus and Device */
 		/* 
 		** While coding this new IOCTL interface, only a few lines of code
@@ -3194,8 +3191,8 @@
 		** should be used...
 		*/
 		* ((SK_U32 *)pMemBuf) = 0;
-		* ((SK_U32 *)pMemBuf + 1) = pdev->bus->number;
-		* ((SK_U32 *)pMemBuf + 2) = ParseDeviceNbrFromSlotName(pdev->slot_name);
+		* ((SK_U32 *)pMemBuf + 1) = pAC->PciDev->bus->number;
+		* ((SK_U32 *)pMemBuf + 2) = PCI_SLOT(pAC->PciDev->devfn);
 		if(copy_to_user(Ioctl.pData, pMemBuf, Length) ) {
 			Err = -EFAULT;
 			goto fault_diag;
@@ -4676,8 +4673,7 @@
 	DEV_NET *pNet = netdev_priv(pAc->dev[0]);
 	SK_AC   *pAC  = pNet->pAC;
 
-	SK_MEMCPY(&(pAc->PnmiBackup), &(pAc->PnmiStruct), 
-			sizeof(SK_PNMI_STRUCT_DATA));
+	pAc->PnmiBackup = pAC->PnmiStruct;
 
 	pAC->DiagModeActive = DIAG_ACTIVE;
 	if (pAC->BoardLevel > SK_INIT_DATA) {
@@ -4718,8 +4714,7 @@
 int SkDrvLeaveDiagMode(
 SK_AC   *pAc)   /* pointer to adapter control context */
 { 
-	SK_MEMCPY(&(pAc->PnmiStruct), &(pAc->PnmiBackup), 
-			sizeof(SK_PNMI_STRUCT_DATA));
+	pAc->PnmiStruct = pAc->PnmiBackup;
 	pAc->DiagModeActive    = DIAG_NOTACTIVE;
 	pAc->Pnmi.DiagAttached = SK_DIAG_IDLE;
         if (pAc->WasIfUp[0] == SK_TRUE) {
@@ -4735,61 +4730,6 @@
 	return(0);
 }
 
-/*****************************************************************************
- *
- *	ParseDeviceNbrFromSlotName - Evaluate PCI device number
- *
- * Description:
- * 	This function parses the PCI slot name information string and will
- *	retrieve the devcie number out of it. The slot_name maintianed by
- *	linux is in the form of '02:0a.0', whereas the first two characters 
- *	represent the bus number in hex (in the sample above this is 
- *	pci bus 0x02) and the next two characters the device number (0x0a).
- *
- * Returns:
- *	SK_U32: The device number from the PCI slot name
- */ 
-
-static SK_U32 ParseDeviceNbrFromSlotName(
-const char *SlotName)   /* pointer to pci slot name eg. '02:0a.0' */
-{
-	char	*CurrCharPos	= (char *) SlotName;
-	int	FirstNibble	= -1;
-	int	SecondNibble	= -1;
-	SK_U32	Result		=  0;
-
-	while (*CurrCharPos != '\0') {
-		if (*CurrCharPos == ':') { 
-			while (*CurrCharPos != '.') {
-				CurrCharPos++;  
-				if (	(*CurrCharPos >= '0') && 
-					(*CurrCharPos <= '9')) {
-					if (FirstNibble == -1) {
-						/* dec. value for '0' */
-						FirstNibble = *CurrCharPos - 48;
-					} else {
-						SecondNibble = *CurrCharPos - 48;
-					}  
-				} else if (	(*CurrCharPos >= 'a') && 
-						(*CurrCharPos <= 'f')  ) {
-					if (FirstNibble == -1) {
-						FirstNibble = *CurrCharPos - 87; 
-					} else {
-						SecondNibble = *CurrCharPos - 87; 
-					}
-				} else {
-					Result = 0;
-				}
-			}
-
-			Result = FirstNibble;
-			Result = Result << 4; /* first nibble is higher one */
-			Result = Result | SecondNibble;
-		}
-		CurrCharPos++;   /* next character */
-	}
-	return (Result);
-}
 
 /****************************************************************************
  *
diff -Nru a/drivers/net/sk98lin/skproc.c b/drivers/net/sk98lin/skproc.c
--- a/drivers/net/sk98lin/skproc.c	2004-11-11 14:17:16 -08:00
+++ b/drivers/net/sk98lin/skproc.c	2004-11-11 14:17:16 -08:00
@@ -76,7 +76,7 @@
 		Size = SK_PNMI_STRUCT_SIZE;
 #ifdef SK_DIAG_SUPPORT
 		if (pAC->BoardLevel == SK_INIT_DATA) {
-			SK_MEMCPY(&(pAC->PnmiStruct), &(pAC->PnmiBackup), sizeof(SK_PNMI_STRUCT_DATA));
+			pAC->PnmiStruct = pAC->PnmiBackup;
 			if (pAC->DiagModeActive == DIAG_NOTACTIVE) {
 				pAC->Pnmi.DiagAttached = SK_DIAG_IDLE;
 			}

From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (22/25) sk98: use PCI_SLOT macro
Date: Mon, 15 Nov 2004 15:55:54 -0800
Message-ID: <20041115155554.5f8b2dd0@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don't need to parse the PCI name (*yuck*) just to find the slot,
there is a macro already available to find it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 14:45:00 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 14:45:00 -08:00
@@ -212,7 +212,6 @@
 static int	XmitFrameSG(SK_AC*, TX_PORT*, struct sk_buff*);
 
 #ifdef SK_DIAG_SUPPORT
-static SK_U32   ParseDeviceNbrFromSlotName(const char *SlotName);
 static int      SkDrvInitAdapter(SK_AC *pAC, int devNbr);
 static int      SkDrvDeInitAdapter(SK_AC *pAC, int devNbr);
 #endif
@@ -2879,7 +2878,7 @@
 		*/
 		* ((SK_U32 *)pMemBuf) = 0;
 		* ((SK_U32 *)pMemBuf + 1) = pdev->bus->number;
-		* ((SK_U32 *)pMemBuf + 2) = ParseDeviceNbrFromSlotName(pdev->slot_name);
+		* ((SK_U32 *)pMemBuf + 2) = PCI_SLOT(pdev->devfn);
 		if(copy_to_user(Ioctl.pData, pMemBuf, Length) ) {
 			Err = -EFAULT;
 			goto fault_diag;
@@ -4413,62 +4412,6 @@
                 SkDrvInitAdapter(pAc, 1);    /* second device */
         }
 	return(0);
-}
-
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
 }
 
 /****************************************************************************

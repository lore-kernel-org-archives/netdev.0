From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/23) sk98: no explicit module ref counting needed
Date: Thu, 11 Nov 2004 16:11:37 -0800
Message-ID: <20041111161137.576e5f66@zqx3.pdx.osdl.net>
References: <4192C60A.1050205@designassembly.de>
	<20041111154016.6381189d@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner
 <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041111154016.6381189d@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Network driver's shouldn't be doing module reference counting
on 2.6.  This is a bad replication of 2.4 behaviour

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-03 14:07:09 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-03 14:07:09 -08:00
@@ -1166,10 +1166,6 @@
 	}
 #endif
 
-	if (!try_module_get(THIS_MODULE)) {
-		return (-1);	/* increase of usage count not possible */
-	}
-
 	/* Set blink mode */
 	if ((pAC->PciDev->vendor == 0x1186) || (pAC->PciDev->vendor == 0x11ab ))
 		pAC->GIni.GILedBlinkCtrl = OEM_CONFIG_VALUE;
@@ -1177,7 +1173,6 @@
 	if (pAC->BoardLevel == SK_INIT_DATA) {
 		/* level 1 init common modules here */
 		if (SkGeInit(pAC, pAC->IoBase, SK_INIT_IO) != 0) {
-			module_put(THIS_MODULE); /* decrease usage count */
 			printk("%s: HWInit (1) failed.\n", pAC->dev[pNet->PortNr]->name);
 			return (-1);
 		}
@@ -1193,7 +1188,6 @@
 	if (pAC->BoardLevel != SK_INIT_RUN) {
 		/* tschilling: Level 2 init modules here, check return value. */
 		if (SkGeInit(pAC, pAC->IoBase, SK_INIT_RUN) != 0) {
-			module_put(THIS_MODULE); /* decrease usage count */
 			printk("%s: HWInit (2) failed.\n", pAC->dev[pNet->PortNr]->name);
 			return (-1);
 		}
@@ -1285,7 +1279,6 @@
 #ifdef SK_DIAG_SUPPORT
 	if (pAC->DiagModeActive == DIAG_ACTIVE) {
 		if (pAC->DiagFlowCtrl == SK_FALSE) {
-			module_put(THIS_MODULE);
 			/* 
 			** notify that the interface which has been closed
 			** by operator interaction must not be started up 
@@ -1376,7 +1369,6 @@
 	pAC->MaxPorts--;
 	pNet->Up = 0;
 
-	module_put(THIS_MODULE);
 	return (0);
 } /* SkGeClose */
 
@@ -4681,20 +4673,11 @@
 
 	dev = pAC->dev[devNbr];
 
-	/*
-	** Function SkGeClose() uses MOD_DEC_USE_COUNT (2.2/2.4)
-	** or module_put() (2.6) to decrease the number of users for
-	** a device, but if a device is to be put under control of 
-	** the DIAG, that count is OK already and does not need to 
-	** be adapted! Hence the opposite MOD_INC_USE_COUNT or 
-	** try_module_get() needs to be used again to correct that.
+	/* On Linux 2.6 the network driver does NOT mess with reference
+	** counts.  The driver MUST be able to be unloaded at any time
+	** due to the possibility of hotplug.
 	*/
-	if (!try_module_get(THIS_MODULE)) {
-		return (-1);
-	}
-
 	if (SkGeClose(dev) != 0) {
-		module_put(THIS_MODULE);
 		return (-1);
 	}
 	return (0);
@@ -4723,17 +4706,6 @@
 
 	if (SkGeOpen(dev) != 0) {
 		return (-1);
-	} else {
-		/*
-		** Function SkGeOpen() uses MOD_INC_USE_COUNT (2.2/2.4) 
-		** or try_module_get() (2.6) to increase the number of 
-		** users for a device, but if a device was just under 
-		** control of the DIAG, that count is OK already and 
-		** does not need to be adapted! Hence the opposite 
-		** MOD_DEC_USE_COUNT or module_put() needs to be used 
-		** again to correct that.
-		*/
-		module_put(THIS_MODULE);
 	}
 
 	/*

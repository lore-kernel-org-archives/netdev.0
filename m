From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 5 2.6.7-bk6] pcnet32: Add HomePNA parameter for 79C978.
Date: Wed, 23 Jun 2004 11:16:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406231816.i5NIG5J16003@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: psimmons@flash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds a module parameter to select HomePNA mode of operation for
the 79C978 version of the pcnet32.  Tested ia32 and ppc64.

signed-off-by: Patrick Simmons <psimmons@flash.net>
signed-off-by: Don Fry <brazilnut@us.ibm.com>


--- linux-2.6.7-bk6/drivers/net/vmw.pcnet32.c	Wed Jun 23 09:00:01 2004
+++ linux-2.6.7-bk6/drivers/net/pcnet32.c	Wed Jun 23 09:00:05 2004
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.30f"
-#define DRV_RELDATE	"06.16.2004"
+#define DRV_VERSION	"1.30g"
+#define DRV_RELDATE	"06.22.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -137,6 +137,7 @@ static const char pcnet32_gstrings_test[
 #define MAX_UNITS 8	/* More are supported, limit only on options */
 static int options[MAX_UNITS];
 static int full_duplex[MAX_UNITS];
+static int homepna[MAX_UNITS];
 
 /*
  *				Theory of Operation
@@ -250,6 +251,8 @@ static int full_duplex[MAX_UNITS];
  * v1.30f  16 Jun 2004 Don Fry cleanup IRQ to allow 0 and 1 for PCI,
  * 	   expanding on suggestions from Ralf Baechle <ralf@linux-mips.org>,
  * 	   and Brian Murphy <brian@murphy.dk>.
+ * v1.30g  22 Jun 2004 Patrick Simmons <psimmons@flash.net> added option
+ *	   homepna for selecting HomePNA mode for PCNet/Home 79C978.
  */
 
 
@@ -1084,15 +1087,17 @@ pcnet32_probe1(unsigned long ioaddr, int
 	fdx = 1;
 	/*
 	 * This is based on specs published at www.amd.com.  This section
-	 * assumes that a card with a 79C978 wants to go into 1Mb HomePNA
-	 * mode.  The 79C978 can also go into standard ethernet, and there
-	 * probably should be some sort of module option to select the
-	 * mode by which the card should operate
+	 * assumes that a card with a 79C978 wants to go into standard
+	 * ethernet mode.  The 79C978 can also go into 1Mb HomePNA mode,
+	 * and the module option homepna=1 can select this instead.
 	 */
-	/* switch to home wiring mode */
 	media = a->read_bcr(ioaddr, 49);
+	media &= ~3;		/* default to 10Mb ethernet */
+	if (cards_found < MAX_UNITS && homepna[cards_found])
+	    media |= 1; 	/* switch to home wiring mode */
 	if (pcnet32_debug & NETIF_MSG_PROBE)
-	    printk(KERN_DEBUG PFX "media reset to %#x.\n",  media);
+	    printk(KERN_DEBUG PFX "media set to %sMbit mode.\n", 
+		    (media & 1) ? "1" : "10");
 	a->write_bcr(ioaddr, 49, media);
 	break;
     case 0x2627:
@@ -2262,6 +2267,9 @@ MODULE_PARM(options, "1-" __MODULE_STRIN
 MODULE_PARM_DESC(options, DRV_NAME " initial option setting(s) (0-15)");
 MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM_DESC(full_duplex, DRV_NAME " full duplex setting(s) (1)");
+/* Module Parameter for HomePNA cards added by Patrick Simmons, 2004 */
+MODULE_PARM(homepna,"1-" __MODULE_STRING(MAX_UNITS) "i");
+MODULE_PARM_DESC(homepna, DRV_NAME " mode for 79C978 cards (1 for HomePNA, 0 for Ethernet, default Ethernet");
 
 MODULE_AUTHOR("Thomas Bogendoerfer");
 MODULE_DESCRIPTION("Driver for PCnet32 and PCnetPCI based ethercards");

-- 
Don Fry
brazilnut@us.ibm.com

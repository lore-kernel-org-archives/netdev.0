From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 6 2.6.7-bk11] pcnet32:  correctly program bcr32.
Date: Mon, 28 Jun 2004 13:25:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406282025.i5SKPv211077@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The pcnet32 driver was not correctly enabling MII autonegotiation after
booting when ppc firmware forced the speed/duplex mode of the chip.
After several conversations with AMD this patch corrects the problem.

I have tested this on hardware I have available (ia32 and ppc64) but I
would like wider audience testing of this patch.

Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.7-bk11/drivers/net/home.pcnet32.c	Mon Jun 28 12:04:07 2004
+++ linux-2.6.7-bk11/drivers/net/pcnet32.c	Mon Jun 28 12:08:57 2004
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.30g"
-#define DRV_RELDATE	"06.22.2004"
+#define DRV_VERSION	"1.30h"
+#define DRV_RELDATE	"06.24.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -253,6 +253,7 @@ static int homepna[MAX_UNITS];
  * 	   and Brian Murphy <brian@murphy.dk>.
  * v1.30g  22 Jun 2004 Patrick Simmons <psimmons@flash.net> added option
  *	   homepna for selecting HomePNA mode for PCNet/Home 79C978.
+ * v1.30h  24 Jun 2004 Don Fry correctly select auto, speed, duplex in bcr32.
  */
 
 
@@ -1422,9 +1423,13 @@ pcnet32_open(struct net_device *dev)
 	val |= 0x10;
     lp->a.write_csr (ioaddr, 124, val);
 
+    /* 24 Jun 2004 according AMD, in order to change the PHY,
+     * DANAS (or DISPM for 79C976) must be set; then select the speed,
+     * duplex, and/or enable auto negotiation, and clear DANAS */
     if (lp->mii && !(lp->options & PCNET32_PORT_ASEL)) {
+	lp->a.write_bcr(ioaddr, 32, lp->a.read_bcr(ioaddr, 32) | 0x0080);
 	/* disable Auto Negotiation, set 10Mpbs, HD */
-	val = lp->a.read_bcr (ioaddr, 32) & ~0x38;
+	val = lp->a.read_bcr(ioaddr, 32) & ~0xb8;
 	if (lp->options & PCNET32_PORT_FD)
 	    val |= 0x10;
 	if (lp->options & PCNET32_PORT_100)
@@ -1432,6 +1437,7 @@ pcnet32_open(struct net_device *dev)
 	lp->a.write_bcr (ioaddr, 32, val);
     } else {
 	if (lp->options & PCNET32_PORT_ASEL) {
+	    lp->a.write_bcr(ioaddr, 32, lp->a.read_bcr(ioaddr, 32) | 0x0080);
 	    /* enable auto negotiate, setup, disable fd */
 	    val = lp->a.read_bcr(ioaddr, 32) & ~0x98;
 	    val |= 0x20;

-- 
Don Fry
brazilnut@us.ibm.com

From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 5 2.4.27] pcnet32: correctly program bcr32.
Date: Mon, 9 Aug 2004 16:18:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809231821.GF13717@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The pcnet32 driver was not correctly enabling MII autonegotiation after
booting when ppc firmware forced the speed/duplex mode of the chip.
After several conversations with AMD this patch corrects the problem.

Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.4.27/drivers/net/home.pcnet32.c	Mon Aug  9 15:42:04 2004
+++ linux-2.4.27/drivers/net/pcnet32.c	Mon Aug  9 15:42:09 2004
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
 
 
@@ -1421,9 +1422,13 @@ pcnet32_open(struct net_device *dev)
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
@@ -1431,6 +1436,7 @@ pcnet32_open(struct net_device *dev)
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

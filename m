From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.30] pcnet32: fix resource leak with loopback test
Date: Fri, 29 Apr 2005 14:49:56 -0700
Message-ID: <20050429214956.GA1074@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When running the loopback test, resources are not properly released on
completion.  This patch frees all transmit resources after running the
loopback test.  Tested on ia32.

Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.4.30/drivers/net/orig.pcnet32.c	2005-01-19 06:09:56.000000000 -0800
+++ linux-2.4.30/drivers/net/pcnet32.c	2005-04-29 14:14:28.000000000 -0700
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.30h"
-#define DRV_RELDATE	"06.24.2004"
+#define DRV_VERSION	"1.30j"
+#define DRV_RELDATE	"29.04.2005"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -254,6 +254,7 @@ static int homepna[MAX_UNITS];
  * v1.30g  22 Jun 2004 Patrick Simmons <psimmons@flash.net> added option
  *	   homepna for selecting HomePNA mode for PCNet/Home 79C978.
  * v1.30h  24 Jun 2004 Don Fry correctly select auto, speed, duplex in bcr32.
+ * v1.30j  29 Apr 2005 Don Fry fix skb/map leak with loopback test.
  */
 
 
@@ -393,6 +394,7 @@ static void pcnet32_led_blink_callback(s
 static int pcnet32_get_regs_len(struct net_device *dev);
 static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	void *ptr);
+static void pcnet32_purge_tx_ring(struct net_device *dev);
 
 enum pci_flags_bit {
     PCI_USES_IO=1, PCI_USES_MEM=2, PCI_USES_MASTER=4,
@@ -783,6 +785,7 @@ static int pcnet32_loopback_test(struct 
     }
 
 clean_up:
+    pcnet32_purge_tx_ring(dev);
     x = a->read_csr(ioaddr, 15) & 0xFFFF;
     a->write_csr(ioaddr, 15, (x & ~0x0044));	/* reset bits 6 and 2 */
 
-- 
Don Fry
brazilnut@us.ibm.com

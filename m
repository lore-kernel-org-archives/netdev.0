From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.12-rc3] pcnet32: fix resource leak with loopback test (with Signed-off-by)
Date: Fri, 29 Apr 2005 14:51:17 -0700
Message-ID: <20050429215117.GA1082@us.ibm.com>
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
loopback test.  Tested on ia32 and ppc64 hardware.

Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.12-rc3/drivers/net/orig.pcnet32.c	2005-03-01 23:37:52.000000000 -0800
+++ linux-2.6.12-rc3/drivers/net/pcnet32.c	2005-04-29 14:06:33.000000000 -0700
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.30i"
-#define DRV_RELDATE	"06.28.2004"
+#define DRV_VERSION	"1.30j"
+#define DRV_RELDATE	"29.04.2005"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -256,6 +256,7 @@
  *	   homepna for selecting HomePNA mode for PCNet/Home 79C978.
  * v1.30h  24 Jun 2004 Don Fry correctly select auto, speed, duplex in bcr32.
  * v1.30i  28 Jun 2004 Don Fry change to use module_param.
+ * v1.30j  29 Apr 2005 Don Fry fix skb/map leak with loopback test.
  */
 
 
@@ -395,6 +396,7 @@
 static int pcnet32_get_regs_len(struct net_device *dev);
 static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	void *ptr);
+static void pcnet32_purge_tx_ring(struct net_device *dev);
 
 enum pci_flags_bit {
     PCI_USES_IO=1, PCI_USES_MEM=2, PCI_USES_MASTER=4,
@@ -785,6 +787,7 @@
     }
 
 clean_up:
+    pcnet32_purge_tx_ring(dev);
     x = a->read_csr(ioaddr, 15) & 0xFFFF;
     a->write_csr(ioaddr, 15, (x & ~0x0044));	/* reset bits 6 and 2 */
 

-- 
Don Fry
brazilnut@us.ibm.com

From: Paul Gortmaker <p_gortmaker@yahoo.com>
Subject: [PATCH] ne2k-pci full duplex with RealTek
Date: Mon, 22 Sep 2003 21:22:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F6FA043.6010503@yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090600040809030300080702"
Cc: jgarzik@pobox.com, becker@scyld.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090600040809030300080702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

A while ago Mika Liljeberg dug through the RTL8029.doc and
sent me the sequence to enable full duplex for these after
testing it worked OK.  The current sequence is just a copy
of the Holtek sequence and apparently doesn't work.

While updateing the sequence, I separated out the FDX code from
ne2k_pci_open() for enhanced readability and so that it may
also be called from other code paths eventually (e.g. ethtool)

Patch is against 2.6.0-test5.

Thanks,
Paul.

--------------090600040809030300080702
Content-Type: text/plain;
 name="2.6-test5-ne2k-diff0"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2.6-test5-ne2k-diff0"

--- linux/drivers/net/ne2k-pci.c	Mon Sep  8 12:51:03 2003
+++ linux-net/drivers/net/ne2k-pci.c	Mon Sep 22 21:00:14 2003
@@ -26,8 +26,8 @@
 */
 
 #define DRV_NAME	"ne2k-pci"
-#define DRV_VERSION	"1.02"
-#define DRV_RELDATE	"10/19/2000"
+#define DRV_VERSION	"1.03"
+#define DRV_RELDATE	"9/22/2003"
 
 
 /* The user-configurable values.
@@ -380,21 +380,48 @@
 
 }
 
+/* 
+ * Magic incantation sequence for full duplex on the supported cards.
+ */
+static inline int set_realtek_fdx(struct net_device *dev)
+{
+	long ioaddr = dev->base_addr;
+
+	outb(0xC0 + E8390_NODMA, ioaddr + NE_CMD); /* Page 3 */
+	outb(0xC0, ioaddr + 0x01); /* Enable writes to CONFIG3 */
+	outb(0x40, ioaddr + 0x06); /* Enable full duplex */
+	outb(0x00, ioaddr + 0x01); /* Disable writes to CONFIG3 */
+	outb(E8390_PAGE0 + E8390_NODMA, ioaddr + NE_CMD); /* Page 0 */
+	return 0;
+}
+
+static inline int set_holtek_fdx(struct net_device *dev)
+{
+	long ioaddr = dev->base_addr;
+
+	outb(inb(ioaddr + 0x20) | 0x80, ioaddr + 0x20);
+	return 0;
+}
+
+static int ne2k_pci_set_fdx(struct net_device *dev)
+{
+	if (ei_status.ne2k_flags & REALTEK_FDX) 
+		return set_realtek_fdx(dev);
+	else if (ei_status.ne2k_flags & HOLTEK_FDX)
+		return set_holtek_fdx(dev);
+
+	return -EOPNOTSUPP;
+}
+
 static int ne2k_pci_open(struct net_device *dev)
 {
 	int ret = request_irq(dev->irq, ei_interrupt, SA_SHIRQ, dev->name, dev);
 	if (ret)
 		return ret;
 
-	/* Set full duplex for the chips that we know about. */
-	if (ei_status.ne2k_flags & FORCE_FDX) {
-		long ioaddr = dev->base_addr;
-		if (ei_status.ne2k_flags & REALTEK_FDX) {
-			outb(0xC0 + E8390_NODMA, ioaddr + NE_CMD); /* Page 3 */
-			outb(inb(ioaddr + 0x20) | 0x80, ioaddr + 0x20);
-		} else if (ei_status.ne2k_flags & HOLTEK_FDX)
-			outb(inb(ioaddr + 0x20) | 0x80, ioaddr + 0x20);
-	}
+	if (ei_status.ne2k_flags & FORCE_FDX)
+		ne2k_pci_set_fdx(dev);
+
 	ei_open(dev);
 	return 0;
 }

--------------090600040809030300080702--

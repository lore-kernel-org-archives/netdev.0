From: akpm@osdl.org
Subject: [patch 03/10] pcnet32: 79c976 with fiber optic fix
Date: Tue, 04 Jan 2005 21:59:28 -0800
Message-ID: <200501050559.j055xb614676@mail.osdl.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, akpm@osdl.org, agx@sigxcpu.org,
        lars@segv.dk
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Guido Guenther <agx@sigxcpu.org>,
      Lars Munch <lars@segv.dk>

Skip PHY selection on Allied Telesyn 2701FX, it looses the link otherwise. 
Fix up the AT 2701 as well.

Signed-Off-By: Guido Guenther <agx@sigxcpu.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/pcnet32.c   |   47 ++++++++++++++++++++++++----------------
 25-akpm/include/linux/pci_ids.h |    5 ++++
 2 files changed, 34 insertions(+), 18 deletions(-)

diff -puN drivers/net/pcnet32.c~pcnet32-79c976-with-fiber-optic drivers/net/pcnet32.c
--- 25/drivers/net/pcnet32.c~pcnet32-79c976-with-fiber-optic	2005-01-04 21:57:35.666712120 -0800
+++ 25-akpm/drivers/net/pcnet32.c	2005-01-04 21:57:35.673711056 -0800
@@ -1429,25 +1429,36 @@ pcnet32_open(struct net_device *dev)
 	val |= 0x10;
     lp->a.write_csr (ioaddr, 124, val);
 
-    /* 24 Jun 2004 according AMD, in order to change the PHY,
-     * DANAS (or DISPM for 79C976) must be set; then select the speed,
-     * duplex, and/or enable auto negotiation, and clear DANAS */
-    if (lp->mii && !(lp->options & PCNET32_PORT_ASEL)) {
-	lp->a.write_bcr(ioaddr, 32, lp->a.read_bcr(ioaddr, 32) | 0x0080);
-	/* disable Auto Negotiation, set 10Mpbs, HD */
-	val = lp->a.read_bcr(ioaddr, 32) & ~0xb8;
-	if (lp->options & PCNET32_PORT_FD)
-	    val |= 0x10;
-	if (lp->options & PCNET32_PORT_100)
-	    val |= 0x08;
-	lp->a.write_bcr (ioaddr, 32, val);
+    /* Allied Telesyn AT 2700/2701 FX looses the link, so skip that */
+    if (lp->pci_dev->subsystem_vendor == PCI_VENDOR_ID_AT &&
+        (lp->pci_dev->subsystem_device == PCI_SUBDEVICE_ID_AT_2700FX ||
+	 lp->pci_dev->subsystem_device == PCI_SUBDEVICE_ID_AT_2701FX)) {
+	printk(KERN_DEBUG "pcnet32: Skipping PHY selection.\n");
     } else {
-	if (lp->options & PCNET32_PORT_ASEL) {
-	    lp->a.write_bcr(ioaddr, 32, lp->a.read_bcr(ioaddr, 32) | 0x0080);
-	    /* enable auto negotiate, setup, disable fd */
-	    val = lp->a.read_bcr(ioaddr, 32) & ~0x98;
-	    val |= 0x20;
-	    lp->a.write_bcr(ioaddr, 32, val);
+	/*
+	 * 24 Jun 2004 according AMD, in order to change the PHY,
+	 * DANAS (or DISPM for 79C976) must be set; then select the speed,
+	 * duplex, and/or enable auto negotiation, and clear DANAS
+	 */
+	if (lp->mii && !(lp->options & PCNET32_PORT_ASEL)) {
+	    lp->a.write_bcr(ioaddr, 32,
+				lp->a.read_bcr(ioaddr, 32) | 0x0080);
+	    /* disable Auto Negotiation, set 10Mpbs, HD */
+	    val = lp->a.read_bcr(ioaddr, 32) & ~0xb8;
+	    if (lp->options & PCNET32_PORT_FD)
+		val |= 0x10;
+	    if (lp->options & PCNET32_PORT_100)
+		val |= 0x08;
+	    lp->a.write_bcr (ioaddr, 32, val);
+	} else {
+	    if (lp->options & PCNET32_PORT_ASEL) {
+		lp->a.write_bcr(ioaddr, 32,
+			lp->a.read_bcr(ioaddr, 32) | 0x0080);
+		/* enable auto negotiate, setup, disable fd */
+		val = lp->a.read_bcr(ioaddr, 32) & ~0x98;
+		val |= 0x20;
+		lp->a.write_bcr(ioaddr, 32, val);
+	    }
 	}
     }
 
diff -puN include/linux/pci_ids.h~pcnet32-79c976-with-fiber-optic include/linux/pci_ids.h
--- 25/include/linux/pci_ids.h~pcnet32-79c976-with-fiber-optic	2005-01-04 21:57:35.669711664 -0800
+++ 25-akpm/include/linux/pci_ids.h	2005-01-04 21:57:35.676710600 -0800
@@ -1644,6 +1644,11 @@
 #define PCI_DEVICE_ID_OPTIBASE_VPLEXCC	0x2120
 #define PCI_DEVICE_ID_OPTIBASE_VQUEST	0x2130
 
+/* Allied Telesyn */
+#define PCI_VENDOR_ID_AT    		0x1259
+#define PCI_SUBDEVICE_ID_AT_2700FX	0x2701
+#define PCI_SUBDEVICE_ID_AT_2701FX	0x2703
+
 #define PCI_VENDOR_ID_ESS		0x125d
 #define PCI_DEVICE_ID_ESS_ESS1968	0x1968
 #define PCI_DEVICE_ID_ESS_AUDIOPCI	0x1969
_

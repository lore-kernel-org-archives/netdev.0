From: Roger Luethi <rl@hellgate.ch>
Subject: [5/9][PATCH 2.6] Nuke all pci_flags
Date: Wed, 2 Jun 2004 13:58:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602115842.GA17533@k3.hellgate.ch>
References: <20040602115703.GA16079@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040602115703.GA16079@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All this code together can be replaced with a single #ifdef USE_MMIO.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -354,11 +354,6 @@
    second only the 1234 card.
 */
 
-enum pci_flags_bit {
-	PCI_USES_IO=1, PCI_USES_MEM=2, PCI_USES_MASTER=4,
-	PCI_ADDR0=0x10<<0, PCI_ADDR1=0x10<<1, PCI_ADDR2=0x10<<2, PCI_ADDR3=0x10<<3,
-};
-
 enum rhine_chips {
 	VT86C100A = 0,
 	VT6102,
@@ -368,7 +363,6 @@
 
 struct rhine_chip_info {
 	const char *name;
-	u16 pci_flags;
 	int io_size;
 	int drv_flags;
 };
@@ -379,24 +373,19 @@
 	ReqTxAlign=0x10, HasWOL=0x20,
 };
 
-#ifdef USE_MMIO
-#define RHINE_IOTYPE (PCI_USES_MEM | PCI_USES_MASTER | PCI_ADDR1)
-#else
-#define RHINE_IOTYPE (PCI_USES_IO  | PCI_USES_MASTER | PCI_ADDR0)
-#endif
 /* Beware of PCI posted writes */
 #define IOSYNC	do { readb(dev->base_addr + StationAddr); } while (0)
 
 /* directly indexed by enum rhine_chips, above */
 static struct rhine_chip_info rhine_chip_info[] __devinitdata =
 {
-	{ "VIA VT86C100A Rhine", RHINE_IOTYPE, 128,
+	{ "VIA VT86C100A Rhine", 128,
 	  ReqTxAlign | HasDavicomPhy },
-	{ "VIA VT6102 Rhine-II", RHINE_IOTYPE, 256,
+	{ "VIA VT6102 Rhine-II", 256,
 	  HasWOL },
-	{ "VIA VT6105 Rhine-III", RHINE_IOTYPE, 256,
+	{ "VIA VT6105 Rhine-III", 256,
 	  HasWOL },
-	{ "VIA VT6105M Rhine-III", RHINE_IOTYPE, 256,
+	{ "VIA VT6105M Rhine-III", 256,
 	  HasWOL },
 };
 
@@ -633,7 +622,6 @@
 	long ioaddr;
 	long memaddr;
 	int io_size;
-	int pci_flags;
 	int phy, phy_idx = 0;
 #ifdef USE_MMIO
 	long ioaddr0;
@@ -649,7 +637,6 @@
 	card_idx++;
 	option = card_idx < MAX_UNITS ? options[card_idx] : 0;
 	io_size = rhine_chip_info[chip_id].io_size;
-	pci_flags = rhine_chip_info[chip_id].pci_flags;
 
 	if (pci_enable_device(pdev))
 		goto err_out;
@@ -671,8 +658,7 @@
 	ioaddr = pci_resource_start(pdev, 0);
 	memaddr = pci_resource_start(pdev, 1);
 
-	if (pci_flags & PCI_USES_MASTER)
-		pci_set_master(pdev);
+	pci_set_master(pdev);
 
 	dev = alloc_etherdev(sizeof(*rp));
 	if (dev == NULL) {
@@ -821,7 +807,12 @@
 
 	printk(KERN_INFO "%s: %s at 0x%lx, ",
 	       dev->name, rhine_chip_info[chip_id].name,
-	       (pci_flags & PCI_USES_IO) ? ioaddr : memaddr);
+#ifdef USE_MMIO
+		memaddr
+#else
+		ioaddr
+#endif
+		 );
 
 	for (i = 0; i < 5; i++)
 		printk("%2.2x:", dev->dev_addr[i]);

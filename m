From: Roger Luethi <rl@hellgate.ch>
Subject: [8/9][PATCH 2.6] Small fixes and clean-up
Date: Tue, 15 Jun 2004 19:49:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615174956.GA11359@k3.hellgate.ch>
References: <20040615174732.GA10241@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040615174732.GA10241@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bump driver version to mark recent major changes in driver code.

Remove backoff parameter. The reason it was once introduced is gone.
Continue to go with EEPROM default for now, will hard-wire IEEE backoff
algorithm instead (later).

Rhine-I needs extra time to recuperate from chip reset before EEPROM
reload.

Add Rhine model identification.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -125,11 +125,16 @@
 	LK1.1.19 (Roger Luethi)
 	- Increase Tx threshold for unspecified errors
 
+	LK1.2.0-2.6 (Roger Luethi)
+	- Massive clean-up
+	- Rewrite PHY, media handling (remove options, full_duplex, backoff)
+	- Fix Tx engine race for good
+
 */
 
 #define DRV_NAME	"via-rhine"
-#define DRV_VERSION	"1.1.20-2.6"
-#define DRV_RELDATE	"May-23-2004"
+#define DRV_VERSION	"1.2.0-2.6"
+#define DRV_RELDATE	"June-10-2004"
 
 
 /* A few user-configurable values.
@@ -142,9 +147,6 @@
    Setting to > 1518 effectively disables this feature. */
 static int rx_copybreak;
 
-/* Select a backoff algorithm (Ethernet capture effect) */
-static int backoff;
-
 /*
  * In case you are looking for 'options[]' or 'full_duplex[]', they
  * are gone. Use ethtool(8) instead.
@@ -207,9 +209,6 @@
 static char version[] __devinitdata =
 KERN_INFO DRV_NAME ".c:v1.10-LK" DRV_VERSION " " DRV_RELDATE " Written by Donald Becker\n";
 
-static char shortname[] = DRV_NAME;
-
-
 /* This driver was written to use PCI memory space. Some early versions
    of the Rhine may only work correctly with I/O space accesses. */
 #ifdef CONFIG_VIA_RHINE_MMIO
@@ -236,11 +235,9 @@
 MODULE_PARM(max_interrupt_work, "i");
 MODULE_PARM(debug, "i");
 MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM(backoff, "i");
 MODULE_PARM_DESC(max_interrupt_work, "VIA Rhine maximum events handled per interrupt");
 MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
 MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy-only-tiny-frames");
-MODULE_PARM_DESC(backoff, "VIA Rhine: Bits 0-3: backoff algorithm");
 
 /*
 		Theory of Operation
@@ -343,17 +340,18 @@
 
 enum rhine_revs {
 	VT86C100A	= 0x00,
+	VTunknown0	= 0x20,
 	VT6102		= 0x40,
 	VT8231		= 0x50,	/* Integrated MAC */
 	VT8233		= 0x60,	/* Integrated MAC */
 	VT8235		= 0x74,	/* Integrated MAC */
 	VT8237		= 0x78,	/* Integrated MAC */
-	VTunknown0	= 0x7C,
+	VTunknown1	= 0x7C,
 	VT6105		= 0x80,
 	VT6105_B0	= 0x83,
 	VT6105L		= 0x8A,
 	VT6107		= 0x8C,
-	VTunknown1	= 0x8E,
+	VTunknown2	= 0x8E,
 	VT6105M		= 0x90,
 };
 
@@ -609,7 +607,7 @@
 
 /*
  * Loads bytes 0x00-0x05, 0x6E-0x6F, 0x78-0x7B from EEPROM
- * (plus 0x6C for Rhine I/II)
+ * (plus 0x6C for Rhine-I/II)
  */
 static void __devinit rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 {
@@ -645,9 +643,15 @@
 
 static void rhine_hw_init(struct net_device *dev, long pioaddr)
 {
+	struct rhine_private *rp = netdev_priv(dev);
+
 	/* Reset the chip to erase previous misconfiguration. */
 	rhine_chip_reset(dev);
 
+	/* Rhine-I needs extra time to recuperate before EEPROM reload */
+	if (rp->quirks & rqRhineI)
+		msleep(5);
+
 	/* Reload EEPROM controlled bytes cleared by soft reset */
 	rhine_reload_eeprom(pioaddr, dev);
 }
@@ -660,12 +664,11 @@
 	int i, rc;
 	u8 pci_rev;
 	u32 quirks;
-	static int card_idx = -1;
 	long pioaddr;
 	long memaddr;
 	long ioaddr;
 	int io_size, phy_id;
-	const char *name;
+	const char *name, *mname;
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -678,22 +681,43 @@
 
 	io_size = 256;
 	phy_id = 0;
-	if (pci_rev < VT6102) {
+	quirks = 0;
+	name = "Rhine";
+	mname = "unknown";
+	if (pci_rev < VTunknown0) {
 		quirks = rqRhineI;
 		io_size = 128;
-		name = "VT86C100A Rhine";
+		mname = "VT86C100A";
 	}
-	else {
+	else if (pci_rev >= VT6102) {
 		quirks = rqWOL | rqForceReset;
 		if (pci_rev < VT6105) {
 			name = "Rhine II";
 			quirks |= rqStatusWBRace;	/* Rhine-II exclusive */
+			if (pci_rev < VT8231)
+				mname = "VT6102";
+			else if (pci_rev < VT8233)
+				mname = "VT8231";
+			else if (pci_rev < VT8235)
+				mname = "VT8233";
+			else if (pci_rev < VT8237)
+				mname = "VT8235";
+			else if (pci_rev < VTunknown1)
+				mname = "VT8237";
 		}
 		else {
 			name = "Rhine III";
 			phy_id = 1;	/* Integrated PHY, phy_id fixed to 1 */
 			if (pci_rev >= VT6105_B0)
 				quirks |= rq6patterns;
+			if (pci_rev < VT6105L)
+				mname = "VT6105";
+			else if (pci_rev < VT6107)
+				mname = "VT6105L";
+			else if (pci_rev < VT6105M)
+				mname = "VT6107";
+			else if (pci_rev >= VT6105M)
+				mname = "Management Adapter VT6105M";
 		}
 	}
 
@@ -722,17 +746,16 @@
 
 	pci_set_master(pdev);
 
-	dev = alloc_etherdev(sizeof(*rp));
-	if (dev == NULL) {
+	dev = alloc_etherdev(sizeof(struct rhine_private));
+	if (!dev) {
 		rc = -ENOMEM;
-		printk(KERN_ERR "init_ethernet failed for card #%d\n",
-		       card_idx);
+		printk(KERN_ERR "alloc_etherdev failed\n");
 		goto err_out;
 	}
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	rc = pci_request_regions(pdev, shortname);
+	rc = pci_request_regions(pdev, DRV_NAME);
 	if (rc)
 		goto err_out_free_netdev;
 
@@ -768,9 +791,8 @@
 	rp = netdev_priv(dev);
 	rp->quirks = quirks;
 
+	/* Get chip registers into a sane state */
 	rhine_power_init(dev);
-
-	/* Reset the chip to erase previous misconfiguration. */
 	rhine_hw_init(dev, pioaddr);
 
 	for (i = 0; i < 6; i++)
@@ -778,16 +800,11 @@
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		rc = -EIO;
-		printk(KERN_ERR "Invalid MAC address for card #%d\n", card_idx);
+		printk(KERN_ERR "Invalid MAC address\n");
 		goto err_out_unmap;
 	}
 
-	/* Select backoff algorithm */
-	if (backoff)
-		writeb(readb(ioaddr + ConfigD) & (0xF0 | backoff),
-		       ioaddr + ConfigD);
-
-	/* For Rhine I/II, phy_id is loaded from EEPROM */
+	/* For Rhine-I/II, phy_id is loaded from EEPROM */
 	if (!phy_id)
 		phy_id = readb(ioaddr + 0x6C);
 
@@ -822,8 +839,8 @@
 	if (rc)
 		goto err_out_unmap;
 
-	printk(KERN_INFO "%s: VIA %s at 0x%lx, ",
-	       dev->name, name,
+	printk(KERN_INFO "%s: VIA %s (%s) at 0x%lx, ",
+	       dev->name, name, mname,
 #ifdef USE_MMIO
 		memaddr
 #else
@@ -1070,7 +1087,7 @@
 	       IntrPCIErr | IntrStatsMax | IntrLinkChange,
 	       ioaddr + IntrEnable);
 
-	writew(CmdStart|CmdTxOn|CmdRxOn|(Cmd1NoTxPoll << 8),
+	writew(CmdStart | CmdTxOn | CmdRxOn | (Cmd1NoTxPoll << 8),
 	       ioaddr + ChipCmd);
 	rhine_check_media(dev, 1);
 }
@@ -1142,7 +1159,7 @@
 	writeb(phy_id, ioaddr + MIIPhyAddr);
 	writeb(regnum, ioaddr + MIIRegAddr);
 	writew(value, ioaddr + MIIData);
-	writeb(0x20, ioaddr + MIICmd);		/* Trigger write. */
+	writeb(0x20, ioaddr + MIICmd);		/* Trigger write */
 	RHINE_WAIT_FOR(!(readb(ioaddr + MIICmd) & 0x20));
 
 	rhine_enable_linkmon(ioaddr);
@@ -1152,20 +1169,20 @@
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
-	int i;
+	int rc;
 
-	i = request_irq(rp->pdev->irq, &rhine_interrupt, SA_SHIRQ, dev->name,
+	rc = request_irq(rp->pdev->irq, &rhine_interrupt, SA_SHIRQ, dev->name,
 			dev);
-	if (i)
-		return i;
+	if (rc)
+		return rc;
 
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: rhine_open() irq %d.\n",
 		       dev->name, rp->pdev->irq);
 
-	i = alloc_ring(dev);
-	if (i)
-		return i;
+	rc = alloc_ring(dev);
+	if (rc)
+		return rc;
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
 	rhine_chip_reset(dev);
@@ -1482,10 +1499,6 @@
 							    rp->rx_buf_sz,
 							    PCI_DMA_FROMDEVICE);
 
-				/* *_IP_COPYSUM isn't defined anywhere and
-				   eth_copy_and_sum is memcpy for all archs so
-				   this is kind of pointless right now
-				   ... or? */
 				eth_copy_and_sum(skb,
 						 rp->rx_skbuff[entry]->tail,
 						 pkt_len, 0);
@@ -1574,7 +1587,6 @@
 		       ioaddr + ChipCmd);
 		writeb(readb(ioaddr + ChipCmd1) | Cmd1TxDemand,
 		       ioaddr + ChipCmd1);
-
 		IOSYNC;
 	}
 	else {
@@ -1834,7 +1846,7 @@
 
 
 static struct pci_driver rhine_driver = {
-	.name		= "via-rhine",
+	.name		= DRV_NAME,
 	.id_table	= rhine_pci_tbl,
 	.probe		= rhine_init_one,
 	.remove		= __devexit_p(rhine_remove_one),

From: Roger Luethi <rl@hellgate.ch>
Subject: [5/9][PATCH 2.6] Remove options, full_duplex parameters
Date: Tue, 15 Jun 2004 19:49:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615174921.GA11270@k3.hellgate.ch>
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

Nobody complained although media locking parameters were broken
forever. They were sort of fixed recently, but the code is still in a
bad shape.

More seriously, the options/full_duplex stuff has fundamental design
problems that have been discussed in-depth on the list (e.g. effect of
hotplugging, nameif, suspend/resume).

For those needing media locking with Linux 2.6+ via-rhine, ethtool(8)
is the replacement.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -145,19 +145,10 @@
 /* Select a backoff algorithm (Ethernet capture effect) */
 static int backoff;
 
-/* Used to pass the media type, etc.
-   Both 'options[]' and 'full_duplex[]' should exist for driver
-   interoperability.
-   The media type is usually passed in 'options[]'.
-   The default is autonegotiation for speed and duplex.
-     This should rarely be overridden.
-   Use option values 0x10/0x20 for 10Mbps, 0x100,0x200 for 100Mbps.
-   Use option values 0x10 and 0x100 for forcing half duplex fixed speed.
-   Use option values 0x20 and 0x200 for forcing full duplex operation.
-*/
-#define MAX_UNITS	8	/* More are supported, limit only on options */
-static int options[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+/*
+ * In case you are looking for 'options[]' or 'full_duplex[]', they
+ * are gone. Use ethtool(8) instead.
+ */
 
 /* Maximum number of multicast addresses to filter (vs. rx-all-multicast).
    The Rhine has a 64 element 8390-like hash table. */
@@ -246,14 +237,10 @@
 MODULE_PARM(debug, "i");
 MODULE_PARM(rx_copybreak, "i");
 MODULE_PARM(backoff, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM_DESC(max_interrupt_work, "VIA Rhine maximum events handled per interrupt");
 MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
 MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(backoff, "VIA Rhine: Bits 0-3: backoff algorithm");
-MODULE_PARM_DESC(options, "VIA Rhine: Bits 0-3: media type, bit 17: full duplex");
-MODULE_PARM_DESC(full_duplex, "VIA Rhine full duplex setting(s) (1)");
 
 /*
 		Theory of Operation
@@ -671,7 +658,7 @@
 {
 	struct net_device *dev;
 	struct rhine_private *rp;
-	int i, option, rc;
+	int i, rc;
 	u8 pci_rev;
 	u32 quirks;
 	static int card_idx = -1;
@@ -688,8 +675,6 @@
 		printk(version);
 #endif
 
-	card_idx++;
-	option = card_idx < MAX_UNITS ? options[card_idx] : 0;
 	pci_read_config_byte(pdev, PCI_REVISION_ID, &pci_rev);
 
 	io_size = 256;
@@ -817,9 +802,6 @@
 	rp->mii_if.phy_id_mask = 0x1f;
 	rp->mii_if.reg_num_mask = 0x1f;
 
-	if (dev->mem_start)
-		option = dev->mem_start;
-
 	/* The chip-specific entries in the device structure. */
 	dev->open = rhine_open;
 	dev->hard_start_xmit = rhine_start_tx;
@@ -841,20 +823,6 @@
 	if (rc)
 		goto err_out_unmap;
 
-	/* The lower four bits are the media type. */
-	if (option > 0) {
-		if (option & 0x220)
-			rp->mii_if.full_duplex = 1;
-	}
-	if (card_idx < MAX_UNITS && full_duplex[card_idx] > 0)
-		rp->mii_if.full_duplex = 1;
-
-	if (rp->mii_if.full_duplex) {
-		printk(KERN_INFO "%s: Set to forced full duplex, "
-		       "autonegotiation disabled.\n", dev->name);
-		rp->mii_if.force_media = 1;
-	}
-
 	printk(KERN_INFO "%s: VIA %s at 0x%lx, ",
 	       dev->name, name,
 #ifdef USE_MMIO
@@ -890,21 +858,6 @@
 	}
 	rp->mii_if.phy_id = phy_id;
 
-	/* Allow forcing the media type. */
-	if (option > 0) {
-		if (option & 0x220)
-			rp->mii_if.full_duplex = 1;
-		if (option & 0x330) {
-			printk(KERN_INFO " Forcing %dMbs %s-duplex "
-				"operation.\n",
-			       (option & 0x300 ? 100 : 10),
-			       (option & 0x220 ? "full" : "half"));
-			mdio_write(dev, phy_id, MII_BMCR,
-				   ((option & 0x300) ? 0x2000 : 0) | /* 100mbps? */
-				   ((option & 0x220) ? 0x0100 : 0)); /* Full duplex? */
-		}
-	}
-
 	return 0;
 
 err_out_unmap:

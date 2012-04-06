From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 16/39] starfire: remove deprecated options.
Date: Fri,  6 Apr 2012 12:06:30 +0200
Message-ID: <d4f8c16cc10a675dcdc3973be8d9bd722d90aa0a.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Ion Badulescu <ionut@badula.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43500 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756159Ab2DFKKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:49 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some settings are duplicated between ethtool link management and module
options. The latter is trimmed. The half duplex, speed and autonegotiation
defaults are kept unchanged.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Ion Badulescu <ionut@badula.org>
---
 drivers/net/ethernet/adaptec/starfire.c |   40 ++++--------------------------
 1 files changed, 6 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 4f27bff..d920a52 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -114,15 +114,6 @@ static int rx_copybreak /* = 0 */;
 #define DMA_BURST_SIZE 128
 #endif
 
-/* Used to pass the media type, etc.
-   Both 'options[]' and 'full_duplex[]' exist for driver interoperability.
-   The media type is usually passed in 'options[]'.
-   These variables are deprecated, use ethtool instead. -Ion
-*/
-#define MAX_UNITS 8		/* More are supported, limit only on options */
-static int options[MAX_UNITS] = {0, };
-static int full_duplex[MAX_UNITS] = {0, };
-
 /* Operational parameters that are set at compile time. */
 
 /* The "native" ring sizes are either 256 or 2048.
@@ -192,8 +183,6 @@ module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
 module_param(intr_latency, int, 0);
 module_param(small_frames, int, 0);
-module_param_array(options, int, NULL, 0);
-module_param_array(full_duplex, int, NULL, 0);
 module_param(enable_hw_cksum, int, 0);
 MODULE_PARM_DESC(max_interrupt_work, "Maximum events handled per interrupt");
 MODULE_PARM_DESC(mtu, "MTU (all boards)");
@@ -201,8 +190,6 @@ MODULE_PARM_DESC(debug, "Debug level (0-6)");
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(intr_latency, "Maximum interrupt latency, in microseconds");
 MODULE_PARM_DESC(small_frames, "Maximum size of receive frames that bypass interrupt latency (0,64,128,256,512)");
-MODULE_PARM_DESC(options, "Deprecated: Bits 0-3: media type, bit 17: full duplex");
-MODULE_PARM_DESC(full_duplex, "Deprecated: Forced full-duplex setting (0/1)");
 MODULE_PARM_DESC(enable_hw_cksum, "Enable/disable hardware cksum support (0/1)");
 
 /*
@@ -657,10 +644,10 @@ static const struct net_device_ops netdev_ops = {
 static int __devinit starfire_init_one(struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
 {
+	struct device *d = &pdev->dev;
 	struct netdev_private *np;
-	int i, irq, option, chip_idx = ent->driver_data;
+	int i, irq, chip_idx = ent->driver_data;
 	struct net_device *dev;
-	static int card_idx = -1;
 	long ioaddr;
 	void __iomem *base;
 	int drv_flags, io_size;
@@ -673,15 +660,13 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 		printk(version);
 #endif
 
-	card_idx++;
-
 	if (pci_enable_device (pdev))
 		return -EIO;
 
 	ioaddr = pci_resource_start(pdev, 0);
 	io_size = pci_resource_len(pdev, 0);
 	if (!ioaddr || ((pci_resource_flags(pdev, 0) & IORESOURCE_MEM) == 0)) {
-		printk(KERN_ERR DRV_NAME " %d: no PCI MEM resources, aborting\n", card_idx);
+		dev_err(d, "no PCI MEM resources, aborting\n");
 		return -ENODEV;
 	}
 
@@ -694,14 +679,14 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 	irq = pdev->irq;
 
 	if (pci_request_regions (pdev, DRV_NAME)) {
-		printk(KERN_ERR DRV_NAME " %d: cannot reserve PCI resources, aborting\n", card_idx);
+		dev_err(d, "cannot reserve PCI resources, aborting\n");
 		goto err_out_free_netdev;
 	}
 
 	base = ioremap(ioaddr, io_size);
 	if (!base) {
-		printk(KERN_ERR DRV_NAME " %d: cannot remap %#x @ %#lx, aborting\n",
-			card_idx, io_size, ioaddr);
+		dev_err(d, "cannot remap %#x @ %#lx, aborting\n",
+			io_size, ioaddr);
 		goto err_out_free_res;
 	}
 
@@ -769,19 +754,6 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 
 	drv_flags = netdrv_tbl[chip_idx].drv_flags;
 
-	option = card_idx < MAX_UNITS ? options[card_idx] : 0;
-
-	/* The lower four bits are the media type. */
-	if (option & 0x200)
-		np->mii_if.full_duplex = 1;
-
-	if (card_idx < MAX_UNITS && full_duplex[card_idx] > 0)
-		np->mii_if.full_duplex = 1;
-
-	if (np->mii_if.full_duplex)
-		np->mii_if.force_media = 1;
-	else
-		np->mii_if.force_media = 0;
 	np->speed100 = 1;
 
 	/* timer resolution is 128 * 0.8us */
-- 
1.7.7.6

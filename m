From: Phillip Michael Jordan <phil@philjordan.eu>
Subject: [PATCH] skge: Fix/workaround for DMA mask quirk on ASUS
	P5NSLI/Marvell Yukon-Lite
Date: Tue, 10 Feb 2009 19:56:53 +0100
Message-ID: <f1a0791a0902101056i6fd47886gc3cee4b5aff2a23e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:8727 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbZBJS44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 13:56:56 -0500
Received: by fg-out-1718.google.com with SMTP id 16so18485fgg.17
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 10:56:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phillip Michael Jordan <phil@philjordan.eu>

The onboard Marvell Yukon-Lite gigabit ethernet chip on my ASUS P5NSLI
motherboard with the nForce570 SLI/Intel chipset (any BIOS version,
including latest), using the skge module, stopped working after
upgrading the system to more than 3GB of physical RAM. The problem has
been around for a while, at least since 2.6.22. Symptoms on earlier
kernels (at least up to 2.6.27) are severely corrupted ethernet
packets (observed via wireshark) and associated IP packet loss and
eventual failure of any packets being delivered at all. As of
2.6.29-rc4, the kernel panics about 1-2 seconds after insmod with 8GB
memory installed, as far as I can tell this is due to memory
corruption.

I have now traced this problem to DMA to/from memory above the 32-bit
boundary, which despite the pci_set_dma_mask() and
pci_set_consistent_dma_mask() calls in skge_probe() apparently
succeeding with a DMA_64BIT_MASK. Switching to a DMA_32BIT_MASK makes
the problem disappear entirely, so this patch against 2.6.29-rc4 does
just that for the affected system by identifying the board via DMI
data and ethernet chip via vendor/product ID. I've tried to make it as
unintrusive as possible, and attempted to make it easy to add other
devices that behave similarly in the future. Nothing changes for
devices not on the blacklist. (admittedly unable to verify due to lack
of other skge hardware)

Searching the web, others have had similar problems, though not on the
same specific motherboard. Passing iommu=force to the kernel seems to
work in some of these previous cases. In my case, this just breaks a
number of other PCI(e) devices, including all of USB, video, etc. -
and skge still doesn't work. I can therefore only conclude that there
is a bug in either the chipset or the BIOS.

Signed-off-by: Phillip Michael Jordan <phil@philjordan.eu>

---

I don't have documentation for the hardware, I'm fighting the symptoms
here. Oddly enough, no other device in my system seems to suffer from
the problem, so I struggled to pin the fix somewhere other than in
skge. I'm not sure if the method of querying DMI data is the canonical
way of detecting quirks like this - if there's a better way, I'd
appreciate some information on that.

Patch applies cleanly to earlier kernel versions.

Comments & suggestions welcome!

phil


diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index c9dbb06..8d4127a 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -39,6 +39,7 @@
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #include <linux/mii.h>
+#include <linux/dmi.h>
 #include <asm/irq.h>

 #include "skge.h"
@@ -3891,12 +3892,48 @@ static void __devinit skge_show_addr(struct
net_device *dev)
 		       dev->name, dev->dev_addr);
 }

+/* nonzero if the device has troubles with 64-bit DMA address mask on
+ * this system. */
+static int __devinit skge_use_32bit_dma_quirk(struct pci_dev *pdev)
+{
+	/* Blacklist of Motherboard(s) & onboard chips that incorrectly report
+	 * 64-bit DMA mask capability and require forcing 32-bit mask to work. */
+	static struct pci_device_id marvell_4320[] =
+	{
+		{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },
+		{ }
+	};
+	static struct dmi_system_id quirk_devices[] = {
+		{
+			.ident = "Marvell 88E8001 on ASUS P5NSLI",
+			.matches = {
+				DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
+				DMI_MATCH(DMI_BOARD_NAME, "P5NSLI")
+			},
+			.driver_data = marvell_4320
+		},
+		{ }	/* terminate list */
+	};
+	
+	/* see if we can find our system on the blacklist */
+	const struct dmi_system_id* remaining = quirk_devices;
+	while ((remaining = dmi_first_match(remaining)) != NULL)
+	{
+		/* found the motherboard, check whether the current net device is quirky */
+		if (pci_match_id((const struct pci_device_id*)remaining->driver_data, pdev))
+			return 1;
+		++remaining;
+	}
+	
+	return 0;
+}
+
 static int __devinit skge_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	struct net_device *dev, *dev1;
 	struct skge_hw *hw;
-	int err, using_dac = 0;
+	int err, using_dac = 0, dma_32bit_quirk = 0;

 	err = pci_enable_device(pdev);
 	if (err) {
@@ -3912,7 +3949,10 @@ static int __devinit skge_probe(struct pci_dev *pdev,

 	pci_set_master(pdev);

-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	/* check if we're on a system which falsely claims to allow 64-bit DMA mask */
+	dma_32bit_quirk = skge_use_32bit_dma_quirk(pdev);
+	
+	if (!dma_32bit_quirk && !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
 		using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
 	} else if (!(err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
@@ -3958,9 +3998,10 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_out_iounmap;

-	printk(KERN_INFO PFX DRV_VERSION " addr 0x%llx irq %d chip %s rev %d\n",
+	printk(KERN_INFO PFX DRV_VERSION " addr 0x%llx irq %d chip %s rev %d %s\n",
 	       (unsigned long long)pci_resource_start(pdev, 0), pdev->irq,
-	       skge_board_name(hw), hw->chip_rev);
+	       skge_board_name(hw), hw->chip_rev,
+	       dma_32bit_quirk ? "32-bit DMA mask quirk on" : "");

 	dev = skge_devinit(hw, 0, using_dac);
 	if (!dev)

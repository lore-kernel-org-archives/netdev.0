From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/5] sky2: chip version printout
Date: Tue, 17 Jun 2008 09:04:25 -0700
Message-ID: <20080617160503.450104179@vyatta.com>
References: <20080617160423.205070938@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:50962 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880AbYFQQH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 12:07:58 -0400
Content-Disposition: inline; filename=sky2-chip-name.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change how chip version is printed so that if an unknown version is detected
nothing breaks.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2008-06-16 09:38:34.000000000 -0700
+++ b/drivers/net/sky2.c	2008-06-16 09:47:41.000000000 -0700
@@ -147,17 +147,6 @@ static const unsigned txqaddr[] = { Q_XA
 static const unsigned rxqaddr[] = { Q_R1, Q_R2 };
 static const u32 portirq_msk[] = { Y2_IS_PORT_1, Y2_IS_PORT_2 };
 
-/* This driver supports yukon2 chipset only */
-static const char *yukon2_name[] = {
-	"XL",		/* 0xb3 */
-	"EC Ultra", 	/* 0xb4 */
-	"Extreme",	/* 0xb5 */
-	"EC",		/* 0xb6 */
-	"FE",		/* 0xb7 */
-	"FE+",		/* 0xb8 */
-	"Supreme",	/* 0xb9 */
-};
-
 static void sky2_set_multicast(struct net_device *dev);
 
 /* Access to PHY via serial interconnect */
@@ -4266,12 +4255,33 @@ static int __devinit pci_wake_enabled(st
 	return value & PCI_PM_CTRL_PME_ENABLE;
 }
 
+/* This driver supports yukon2 chipset only */
+static const char *sky2_name(u8 chipid, char *buf, int sz)
+{
+	const char *name[] = {
+		"XL",		/* 0xb3 */
+		"EC Ultra", 	/* 0xb4 */
+		"Extreme",	/* 0xb5 */
+		"EC",		/* 0xb6 */
+		"FE",		/* 0xb7 */
+		"FE+",		/* 0xb8 */
+		"Supreme",	/* 0xb9 */
+	};
+
+	if (chipid >= CHIP_ID_YUKON_XL && chipid < CHIP_ID_YUKON_SUPR)
+		strncpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
+	else
+		snprintf(buf, sz, "(chip %#x)", chipid);
+	return buf;
+}
+
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct sky2_hw *hw;
 	int err, using_dac = 0, wol_default;
+	char buf1[16];
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -4342,10 +4352,10 @@ static int __devinit sky2_probe(struct p
 	if (err)
 		goto err_out_iounmap;
 
-	dev_info(&pdev->dev, "v%s addr 0x%llx irq %d Yukon-%s (0x%x) rev %d\n",
-	       DRV_VERSION, (unsigned long long)pci_resource_start(pdev, 0),
-	       pdev->irq, yukon2_name[hw->chip_id - CHIP_ID_YUKON_XL],
-	       hw->chip_id, hw->chip_rev);
+	dev_info(&pdev->dev, "v%s addr 0x%llx irq %d Yukon-2 %s rev %d\n",
+		 DRV_VERSION, (unsigned long long)pci_resource_start(pdev, 0),
+		 pdev->irq, sky2_name(hw->chip_id, buf1, sizeof(buf1)),
+		 hw->chip_rev);
 
 	sky2_reset(hw);
 

-- 


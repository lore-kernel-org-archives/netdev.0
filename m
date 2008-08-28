From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] sky2: display product info on boot.
Date: Wed, 27 Aug 2008 20:48:23 -0700
Message-ID: <20080827204823.551eff56@extreme>
References: <20080827204626.4b65862f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35391 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755166AbYH1Dss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 23:48:48 -0400
In-Reply-To: <20080827204626.4b65862f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change bootup messages to print more information. This is to help users
who may have old buggy EEPROM image.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
This can wait for 2.6.28

--- a/drivers/net/sky2.c	2008-08-27 19:21:52.000000000 -0700
+++ b/drivers/net/sky2.c	2008-08-27 19:21:56.000000000 -0700
@@ -4191,6 +4191,69 @@ static int __devinit pci_wake_enabled(st
 	return value & PCI_PM_CTRL_PME_ENABLE;
 }
 
+/*
+ * Read and parse the first part of Vital Product Data
+ */
+#define VPD_SIZE	128
+#define VPD_MAGIC	0x82
+
+static void __devinit sky2_vpd_info(struct sky2_hw *hw)
+{
+	int cap = pci_find_capability(hw->pdev, PCI_CAP_ID_VPD);
+	const u8 *p;
+	u8 *vpd_buf = NULL;
+	u16 len;
+	static struct vpd_tag {
+		char tag[2];
+		char *label;
+	} vpd_tags[] = {
+		{ "PN",	"Part Number" },
+		{ "EC", "Engineering Level" },
+		{ "MN", "Manufacturer" },
+	};
+
+	if (!cap)
+		goto out;
+
+	vpd_buf = kmalloc(VPD_SIZE, GFP_KERNEL);
+	if (!vpd_buf)
+		goto out;
+
+	if (sky2_vpd_read(hw, cap, vpd_buf, 0, VPD_SIZE))
+		goto out;
+
+	if (vpd_buf[0] != VPD_MAGIC)
+		goto out;
+	len = vpd_buf[1];
+	if (len == 0 || len > VPD_SIZE - 4)
+		goto out;
+	p = vpd_buf + 3;
+	dev_info(&hw->pdev->dev, "%.*s\n", len, p);
+	p += len;
+
+	while (p < vpd_buf + VPD_SIZE - 4) {
+		int i;
+
+		if (!memcmp("RW", p, 2))	/* end marker */
+			break;
+
+		len = p[2];
+		if (len > (p - vpd_buf) - 4)
+			break;
+
+		for (i = 0; i < ARRAY_SIZE(vpd_tags); i++) {
+			if (!memcmp(vpd_tags[i].tag, p, 2)) {
+				printk(KERN_DEBUG " %s: %.*s\n",
+				       vpd_tags[i].label, len, p + 3);
+				break;
+			}
+		}
+		p += len + 3;
+	}
+out:
+	kfree(vpd_buf);
+}
+
 /* This driver supports yukon2 chipset only */
 static const char *sky2_name(u8 chipid, char *buf, int sz)
 {
@@ -4289,13 +4352,13 @@ static int __devinit sky2_probe(struct p
 	if (err)
 		goto err_out_iounmap;
 
-	dev_info(&pdev->dev, "v%s addr 0x%llx irq %d Yukon-2 %s rev %d\n",
-		 DRV_VERSION, (unsigned long long)pci_resource_start(pdev, 0),
-		 pdev->irq, sky2_name(hw->chip_id, buf1, sizeof(buf1)),
-		 hw->chip_rev);
+	dev_info(&pdev->dev, "Yukon-2 %s chip revision %d\n",
+		 sky2_name(hw->chip_id, buf1, sizeof(buf1)), hw->chip_rev);
 
 	sky2_reset(hw);
 
+	sky2_vpd_info(hw);
+
 	dev = sky2_init_netdev(hw, 0, using_dac, wol_default);
 	if (!dev) {
 		err = -ENOMEM;
@@ -4546,6 +4609,8 @@ static struct pci_driver sky2_driver = {
 
 static int __init sky2_init_module(void)
 {
+	pr_info(PFX "driver version " DRV_VERSION "\n");
+
 	sky2_debug_init();
 	return pci_register_driver(&sky2_driver);
 }

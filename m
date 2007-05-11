From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/4] sky2: only disable 88e8056 on some boards
Date: Fri, 11 May 2007 11:21:47 -0700
Message-ID: <20070511182251.549415549@linux-foundation.org>
References: <20070511182143.872814956@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:56329 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760586AbXEKSZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 14:25:38 -0400
Content-Disposition: inline; filename=sky2-dmi-gigabyte.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use DMI to add a blacklist of broken boards (so far only one).
Hopefully, the problems will be solved later, and the the whole
blacklist can disappear.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

--- net-2.6.orig/drivers/net/sky2.c	2007-05-11 11:08:25.000000000 -0700
+++ net-2.6/drivers/net/sky2.c	2007-05-11 11:13:01.000000000 -0700
@@ -40,6 +40,7 @@
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
 #include <linux/mii.h>
+#include <linux/dmi.h>
 
 #include <asm/irq.h>
 
@@ -150,6 +151,8 @@ static const char *yukon2_name[] = {
 	"FE",		/* 0xb7 */
 };
 
+static int dmi_blacklisted;
+
 /* Access to external PHY */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 {
@@ -2531,6 +2534,17 @@ static int __devinit sky2_init(struct sk
 		return -EOPNOTSUPP;
 	}
 
+
+	/* Some Gigabyte motherboards have 88e8056 but cause problems
+	 * There is some unresolved hardware related problem that causes
+	 * descriptor errors and receive data corruption.
+	 */
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U && dmi_blacklisted) {
+		dev_err(&hw->pdev->dev,
+			"88E8056 on this motherboard not supported\n");
+		return -EOPNOTSUPP;
+	}
+
 	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
 	hw->ports = 1;
 	t8 = sky2_read8(hw, B2_Y2_HW_RES);
@@ -3578,17 +3592,6 @@ static int __devinit sky2_probe(struct p
 		goto err_out;
 	}
 
-	/* Some Gigabyte motherboards have 88e8056 but cause problems
-	 * There is some unresolved hardware related problem that causes
-	 * descriptor errors and receive data corruption.
-	 */
-	if (pdev->vendor == PCI_VENDOR_ID_MARVELL &&
-	    pdev->device == 0x4364 && pdev->subsystem_vendor == 0x1458) {
-		dev_err(&pdev->dev,
-			"88E8056 on Gigabyte motherboards not supported\n");
-		goto err_out_disable;
-	}
-
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
 		dev_err(&pdev->dev, "cannot obtain PCI resources\n");
@@ -3907,8 +3910,24 @@ static struct pci_driver sky2_driver = {
 	.shutdown = sky2_shutdown,
 };
 
+static struct dmi_system_id __initdata broken_dmi_table[] = {
+	{
+		.ident = "Gigabyte 965P-S3",
+		.matches = {
+			DMI_MATCH(DMI_SYS_VENDOR, "Gigabyte Technology Co., Ltd."),
+			DMI_MATCH(DMI_PRODUCT_NAME, "965P-S3"),
+
+		},
+	},
+	{ }
+};
+
 static int __init sky2_init_module(void)
 {
+	/* Look for sick motherboards */
+	if (dmi_check_system(broken_dmi_table))
+		dmi_blacklisted = 1;
+
 	return pci_register_driver(&sky2_driver);
 }
 

--
Stephen Hemminger <shemminger@linux-foundation.org>


From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 15/17] sky2: only disable 88e8056 on some boards
Date: Tue, 08 May 2007 20:50:04 -0700
Message-ID: <20070509035030.939143538@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:41579 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754076AbXEIEJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:09:21 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-dmi-gigabyte.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use DMI to add a blacklist of broken board. For now only one is known
bad. Gentoo users report driver works on other motherboards (strange).

Hopefully, the problems will be solved later, and the the whole
blacklist can disappear.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 15:58:11.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 16:09:03.000000000 -0700
@@ -41,6 +41,7 @@
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
 #include <linux/mii.h>
+#include <linux/dmi.h>
 
 #include <asm/irq.h>
 
@@ -151,6 +152,8 @@ static const char *yukon2_name[] = {
 	"FE",		/* 0xb7 */
 };
 
+static int broken_ec_u;			/* blacklist */
+
 /* Access to external PHY */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 {
@@ -2519,10 +2522,21 @@ static int __devinit sky2_init(struct sk
 		return -EOPNOTSUPP;
 	}
 
+
 	if (hw->chip_id == CHIP_ID_YUKON_EX)
 		dev_warn(&hw->pdev->dev, "this driver not yet tested on this chip type\n"
 			 "Please report success or failure to <netdev@vger.kernel.org>\n");
 
+
+	/* Some Gigabyte motherboards have 88e8056 but cause problems
+	 * There is some unresolved hardware related problem that causes
+	 * descriptor errors and receive data corruption.
+	 */
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U && broken_ec_u) {
+		dev_err(&hw->pdev->dev, "broken 88e8056 detected.\n");
+		return -EOPNOTSUPP;
+	}
+
 	/* Make sure and enable all clocks */
 	if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == CHIP_ID_YUKON_EC_U)
 		pci_write_config_dword(hw->pdev, PCI_DEV_REG3, 0);
@@ -3572,17 +3586,6 @@ static int __devinit sky2_probe(struct p
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
@@ -3895,8 +3898,24 @@ static struct pci_driver sky2_driver = {
 	.shutdown = sky2_shutdown,
 };
 
+
+static struct dmi_system_id __initdata gigabyte_dmi_table[] = {
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
+	if (dmi_check_system(gigabyte_dmi_table))
+		broken_ec_u = 1;
+
 	return pci_register_driver(&sky2_driver);
 }
 

--


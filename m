From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/8] sky2: set VPD size
Date: Wed, 17 Dec 2008 16:01:49 -0800
Message-ID: <20081218000241.225475921@vyatta.com>
References: <20081218000144.964015472@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52780 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbYLRAFj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 19:05:39 -0500
Content-Disposition: inline; filename=sky2-vpd-size.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read configuration register during probe and use it to size the
available VPD. Move existing code using same register slightly
earlier in probe handling.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2008-11-24 08:48:00.000000000 -0800
+++ b/drivers/net/sky2.c	2008-11-24 08:48:18.000000000 -0800
@@ -4315,6 +4315,7 @@ static int __devinit sky2_probe(struct p
 	struct net_device *dev;
 	struct sky2_hw *hw;
 	int err, using_dac = 0, wol_default;
+	u32 reg;
 	char buf1[16];
 
 	err = pci_enable_device(pdev);
@@ -4348,6 +4349,34 @@ static int __devinit sky2_probe(struct p
 		}
 	}
 
+	/* Get configuration information
+	 * Note: only regular PCI config access once to test for HW issues
+	 *       other PCI access through shared memory for speed and to
+	 *	 avoid MMCONFIG problems.
+	 */
+	err = pci_read_config_dword(pdev, PCI_DEV_REG2, &reg);
+	if (err) {
+		dev_err(&pdev->dev, "PCI read config failed\n");
+		goto err_out_free_regions;
+	}
+
+	/* size of available VPD, only impact sysfs */
+	err = pci_vpd_truncate(pdev, 1ul << (((reg & PCI_VPD_ROM_SZ) >> 14) + 8));
+	if (err)
+		dev_warn(&pdev->dev, "Can't set VPD size\n");
+
+#ifdef __BIG_ENDIAN
+	/* The sk98lin vendor driver uses hardware byte swapping but
+	 * this driver uses software swapping.
+	 */
+	reg &= ~PCI_REV_DESC;
+	err = pci_write_config_dword(pdev,PCI_DEV_REG2, reg);
+	if (err) {
+		dev_err(&pdev->dev, "PCI write config failed\n");
+		goto err_out_free_regions;
+	}
+#endif
+
 	wol_default = device_may_wakeup(&pdev->dev) ? WAKE_MAGIC : 0;
 
 	err = -ENOMEM;
@@ -4365,18 +4394,6 @@ static int __devinit sky2_probe(struct p
 		goto err_out_free_hw;
 	}
 
-#ifdef __BIG_ENDIAN
-	/* The sk98lin vendor driver uses hardware byte swapping but
-	 * this driver uses software swapping.
-	 */
-	{
-		u32 reg;
-		reg = sky2_pci_read32(hw, PCI_DEV_REG2);
-		reg &= ~PCI_REV_DESC;
-		sky2_pci_write32(hw, PCI_DEV_REG2, reg);
-	}
-#endif
-
 	/* ring for status responses */
 	hw->st_le = pci_alloc_consistent(pdev, STATUS_LE_BYTES, &hw->st_dma);
 	if (!hw->st_le)

-- 


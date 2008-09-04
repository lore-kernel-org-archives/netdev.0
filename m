From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/4] sky2: set VPD size
Date: Thu, 04 Sep 2008 13:56:40 -0700
Message-ID: <20080904205718.819202931@vyatta.com>
References: <20080904205636.130211321@vyatta.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:39264 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754734AbYIDVsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 17:48:40 -0400
Content-Disposition: inline; filename=sky2-vpd-size.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read configuration register during probe and use it to size the
available VPD. Move existing code using same register slightly
earlier in probe handling.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2008-09-04 11:27:34.000000000 -0700
+++ b/drivers/net/sky2.c	2008-09-04 11:44:49.000000000 -0700
@@ -4281,6 +4281,7 @@ static int __devinit sky2_probe(struct p
 	struct net_device *dev;
 	struct sky2_hw *hw;
 	int err, using_dac = 0, wol_default;
+	u32 reg;
 	char buf1[16];
 
 	err = pci_enable_device(pdev);
@@ -4314,6 +4315,34 @@ static int __devinit sky2_probe(struct p
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
+	err = pci_vpd_size(pdev, 1ul << (((reg & PCI_VPD_ROM_SZ) >> 14) + 8));
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
 	wol_default = pci_wake_enabled(pdev) ? WAKE_MAGIC : 0;
 
 	err = -ENOMEM;
@@ -4331,18 +4360,6 @@ static int __devinit sky2_probe(struct p
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


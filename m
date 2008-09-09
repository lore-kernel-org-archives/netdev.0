From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/9] skge: set VPD size
Date: Tue, 09 Sep 2008 11:20:47 -0700
Message-ID: <20080909182057.469130973@vyatta.com>
References: <20080909182040.246073057@vyatta.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline; filename=skge-vpd-size.patch
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Read configuration register during probe and use it to size the
available VPD.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/skge.c	2008-09-09 10:08:36.000000000 -0700
+++ b/drivers/net/skge.c	2008-09-09 11:19:31.000000000 -0700
@@ -3884,6 +3884,7 @@ static int __devinit skge_probe(struct p
 	struct net_device *dev, *dev1;
 	struct skge_hw *hw;
 	int err, using_dac = 0;
+	u32 reg;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -3912,15 +3913,17 @@ static int __devinit skge_probe(struct p
 		goto err_out_free_regions;
 	}
 
+	pci_read_config_dword(pdev, PCI_DEV_REG2, &reg);
+
+	/* set size of available VPD, only impacts sysfs */
+	err = pci_vpd_truncate(pdev, 1ul << (((reg & PCI_VPD_ROM_SZ) >> 14) + 8));
+	if (err)
+		dev_warn(&pdev->dev, "Can't set VPD size\n");
+
 #ifdef __BIG_ENDIAN
 	/* byte swap descriptors in hardware */
-	{
-		u32 reg;
-
-		pci_read_config_dword(pdev, PCI_DEV_REG2, &reg);
-		reg |= PCI_REV_DESC;
-		pci_write_config_dword(pdev, PCI_DEV_REG2, reg);
-	}
+	reg |= PCI_REV_DESC;
+	pci_write_config_dword(pdev, PCI_DEV_REG2, reg);
 #endif
 
 	err = -ENOMEM;

-- 

From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/8] skge: set VPD size
Date: Wed, 17 Dec 2008 16:01:51 -0800
Message-ID: <20081218000241.397407939@vyatta.com>
References: <20081218000144.964015472@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52786 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752587AbYLRAFm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 19:05:42 -0500
Content-Disposition: inline; filename=skge-vpd-size.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read configuration register during probe and use it to size the
available VPD.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/skge.c	2008-11-24 08:50:54.000000000 -0800
+++ b/drivers/net/skge.c	2008-11-24 08:50:58.000000000 -0800
@@ -3980,6 +3980,7 @@ static int __devinit skge_probe(struct p
 	struct net_device *dev, *dev1;
 	struct skge_hw *hw;
 	int err, using_dac = 0;
+	u32 reg;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -4008,15 +4009,17 @@ static int __devinit skge_probe(struct p
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


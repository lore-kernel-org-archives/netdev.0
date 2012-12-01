From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: sky2: fix cleanup sequence in probe() function
Date: Sat, 1 Dec 2012 13:39:28 +0100
Message-ID: <20121201123928.GA3914@neptun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: shemminger@vyatta.com, mlindner@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:59316 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751423Ab2LAMjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 07:39:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cleanup sequence in sky2_probe() that is called in case of an error is
mixed up in different places:

- pci_disable_device() is not called in each case the device has been enabled
before

- same for pci_disable_msi(): test_msi() may return with an error != EOPNOTSUPP
(due to failure of request_irq()). In that case msi is not disabled

- also failure of register_netdev() does not disable msi

This patch fixes the concerning parts.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/marvell/sky2.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index b20d2fd..eea58f6 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4919,13 +4919,13 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	err = pci_read_config_dword(pdev, PCI_DEV_REG2, &reg);
 	if (err) {
 		dev_err(&pdev->dev, "PCI read config failed\n");
-		goto err_out;
+		goto err_out_disable;
 	}
 
 	if (~reg == 0) {
 		dev_err(&pdev->dev, "PCI configuration read error\n");
 		err = -EIO;
-		goto err_out;
+		goto err_out_disable;
 	}
 
 	err = pci_request_regions(pdev, DRV_NAME);
@@ -5012,10 +5012,11 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 
 	if (!disable_msi && pci_enable_msi(pdev) == 0) {
 		err = sky2_test_msi(hw);
-		if (err == -EOPNOTSUPP)
+		if (err) {
  			pci_disable_msi(pdev);
-		else if (err)
-			goto err_out_free_netdev;
+			if (err != -EOPNOTSUPP)
+				goto err_out_free_netdev;
+		}
  	}
 
 	err = register_netdev(dev);
@@ -5063,10 +5064,10 @@ err_out_unregister_dev1:
 err_out_free_dev1:
 	free_netdev(dev1);
 err_out_unregister:
-	if (hw->flags & SKY2_HW_USE_MSI)
-		pci_disable_msi(pdev);
 	unregister_netdev(dev);
 err_out_free_netdev:
+	if (hw->flags & SKY2_HW_USE_MSI)
+		pci_disable_msi(pdev);
 	free_netdev(dev);
 err_out_free_pci:
 	pci_free_consistent(pdev, hw->st_size * sizeof(struct sky2_status_le),
-- 
1.7.9.5

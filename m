From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] sky2: resume clocks
Date: Sun, 7 Feb 2010 08:23:53 -0800
Message-ID: <20100207082353.2d0c6a93@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60451 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756282Ab0BGQ3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2010 11:29:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the resume path to use pci write config for a couple of reasons:
1. pci_write_config_dword() allows for more error
   checking of PCI health after resume.

2. better to toggle this register on all chip types, since that
   is what vendor driver does.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2010-02-03 09:17:01.602741445 -0800
+++ b/drivers/net/sky2.c	2010-02-03 09:24:17.943679463 -0800
@@ -4859,10 +4859,11 @@ static int sky2_resume(struct pci_dev *p
 	pci_enable_wake(pdev, PCI_D0, 0);
 
 	/* Re-enable all clocks */
-	if (hw->chip_id == CHIP_ID_YUKON_EX ||
-	    hw->chip_id == CHIP_ID_YUKON_EC_U ||
-	    hw->chip_id == CHIP_ID_YUKON_FE_P)
-		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+	err = pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
+	if (err) {
+		dev_err(&pdev->dev, "PCI write config failed\n");
+		goto out;
+	}
 
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);

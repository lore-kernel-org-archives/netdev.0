From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/7] sky2: handle advanced error recovery config issues
Date: Mon, 05 Nov 2007 15:52:13 -0800
Message-ID: <20071105235340.253183481@linux-foundation.org>
References: <20071105235207.799504040@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41544 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754671AbXKEX5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 18:57:00 -0500
Content-Disposition: inline; filename=sky2-noaer.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI AER support may not work for a couple of reasons.
It may not be configured into the kernel or there may be a BIOS
bug that prevents MMCONFIG from working.  If MMCONFIG doesn't work
then the PCI registers that control AER will not be accessible via
pci_read_config functions; luckly there is another window to access
PCI space in the device, so use that.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-11-05 15:10:56.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-05 15:21:58.000000000 -0800
@@ -2435,13 +2435,26 @@ static void sky2_hw_intr(struct sky2_hw 
 
 	if (status & Y2_IS_PCI_EXP) {
 		/* PCI-Express uncorrectable Error occurred */
-		int pos = pci_find_aer_capability(hw->pdev);
+		int aer = pci_find_aer_capability(hw->pdev);
 		u32 err;
 
-		pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_STATUS, &err);
+		if (aer) {
+			pci_read_config_dword(pdev, aer + PCI_ERR_UNCOR_STATUS,
+					      &err);
+			pci_cleanup_aer_uncorrect_error_status(pdev);
+		} else {
+			/* Either AER not configured, or not working
+			 * because of bad MMCONFIG, so just do recover
+			 * manually.
+			 */
+			err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
+			sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
+				     0xfffffffful);
+		}
+
 		if (net_ratelimit())
 			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
-		pci_cleanup_aer_uncorrect_error_status(pdev);
+
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -2799,9 +2812,18 @@ static void sky2_reset(struct sky2_hw *h
 
 	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (cap) {
-		/* Check for advanced error reporting */
-		pci_cleanup_aer_uncorrect_error_status(pdev);
-		pci_cleanup_aer_correct_error_status(pdev);
+		if (pci_find_aer_capability(pdev)) {
+			/* Check for advanced error reporting */
+			pci_cleanup_aer_uncorrect_error_status(pdev);
+			pci_cleanup_aer_correct_error_status(pdev);
+		} else {
+			dev_warn(&pdev->dev,
+				"PCI Express Advanced Error Reporting"
+				" not configured or MMCONFIG problem?\n");
+
+			sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
+				     0xfffffffful);
+		}
 
 		/* If error bit is stuck on ignore it */
 		if (sky2_read32(hw, B0_HWE_ISRC) & Y2_IS_PCI_EXP)
--- a/drivers/net/sky2.h	2007-11-05 10:01:10.000000000 -0800
+++ b/drivers/net/sky2.h	2007-11-05 15:18:58.000000000 -0800
@@ -247,7 +247,8 @@ enum csr_regs {
 	B3_PA_CTRL	= 0x01f0,
 	B3_PA_TEST	= 0x01f2,
 
-	Y2_CFG_SPC	= 0x1c00,
+	Y2_CFG_SPC	= 0x1c00,	/* PCI config space region */
+	Y2_CFG_AER      = 0x1d00,	/* PCI Advanced Error Report region */
 };
 
 /*	B0_CTST			16 bit	Control/Status register */

-- 
Stephen Hemminger <shemminger@linux-foundation.org>


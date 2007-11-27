From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/3] sky2: don't use AER routines
Date: Tue, 27 Nov 2007 11:02:32 -0800
Message-ID: <20071127110232.43d126c7@freepuppy.rosehill>
References: <20071127105727.1bcfa56f@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Zhang Yanmin <yanmin_zhang@linux.intel.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35858 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758732AbXK0WKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 17:10:33 -0500
In-Reply-To: <20071127105727.1bcfa56f@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using PCIE advanced error recovery stuff creates more user problems than it's worth.
The AER stuff depends on MMCONFIG and in many configurations it just doesn't work.
Plus it doesn't add any real functionality to the driver. The sky2
driver handles its own errors fine as is.

This reverts 555382cbfc6d2187b53888190755e56f52308cd6

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-11-26 14:02:31.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-26 14:02:36.000000000 -0800
@@ -31,7 +31,6 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/pci.h>
-#include <linux/aer.h>
 #include <linux/ip.h>
 #include <net/ip.h>
 #include <linux/tcp.h>
@@ -2432,26 +2431,15 @@ static void sky2_hw_intr(struct sky2_hw 
 
 	if (status & Y2_IS_PCI_EXP) {
 		/* PCI-Express uncorrectable Error occurred */
-		int aer = pci_find_aer_capability(hw->pdev);
 		u32 err;
 
-		if (aer) {
-			pci_read_config_dword(pdev, aer + PCI_ERR_UNCOR_STATUS,
-					      &err);
-			pci_cleanup_aer_uncorrect_error_status(pdev);
-		} else {
-			/* Either AER not configured, or not working
-			 * because of bad MMCONFIG, so just do recover
-			 * manually.
-			 */
-			err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
-			sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
-				     0xfffffffful);
-		}
-
+		err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
+		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
+			     0xfffffffful);
 		if (net_ratelimit())
 			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
 
+		sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -2806,24 +2794,13 @@ static void sky2_reset(struct sky2_hw *h
 
 	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (cap) {
-		if (pci_find_aer_capability(pdev)) {
-			/* Check for advanced error reporting */
-			pci_cleanup_aer_uncorrect_error_status(pdev);
-			pci_cleanup_aer_correct_error_status(pdev);
-		} else {
-			dev_warn(&pdev->dev,
-				"PCI Express Advanced Error Reporting"
-				" not configured or MMCONFIG problem?\n");
-
-			sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
-				     0xfffffffful);
-		}
+		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
+			     0xfffffffful);
 
 		/* If error bit is stuck on ignore it */
 		if (sky2_read32(hw, B0_HWE_ISRC) & Y2_IS_PCI_EXP)
 			dev_info(&pdev->dev, "ignoring stuck error report bit\n");
-
-		else if (pci_enable_pcie_error_reporting(pdev))
+		else
 			hwe_mask |= Y2_IS_PCI_EXP;
 	}
 

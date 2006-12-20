From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 2/6] sky2: power management/MSI workaround
Date: Wed, 20 Dec 2006 13:06:34 -0800
Message-ID: <20061220210922.806777269@osdl.org>
References: <20061220210632.183204605@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:58249 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423152AbWLVAlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 19:41:07 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-msi-resume.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MSI doesn't work properly on resume on many platforms because the
BIOS goes and changes it back to INTx mode after the sky2 driver has
restored in resume. 

It is really a bug in the base power management resume code, and 
this workaround is temporary until the change to PM code works it's way
through the release process.  The PM fix is non-trivial since it needs
to change when non-boot CPU's are enabled.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2-2.6.orig/drivers/net/sky2.c	2006-12-18 14:22:56.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2006-12-18 14:31:43.000000000 -0800
@@ -3638,6 +3638,29 @@
 out:
 	return err;
 }
+
+/* BIOS resume runs after device (it's a bug in PM)
+ * as a temporary workaround on suspend/resume leave MSI disabled
+ */
+static int sky2_suspend_late(struct pci_dev *pdev, pm_message_t state)
+{
+	struct sky2_hw *hw = pci_get_drvdata(pdev);
+
+	free_irq(pdev->irq, hw);
+	if (hw->msi) {
+		pci_disable_msi(pdev);
+		hw->msi = 0;
+	}
+	return 0;
+}
+
+static int sky2_resume_early(struct pci_dev *pdev)
+{
+	struct sky2_hw *hw = pci_get_drvdata(pdev);
+	struct net_device *dev = hw->dev[0];
+
+	return request_irq(pdev->irq, sky2_intr, IRQF_SHARED, dev->name, hw);
+}
 #endif
 
 static struct pci_driver sky2_driver = {
@@ -3648,6 +3671,8 @@
 #ifdef CONFIG_PM
 	.suspend = sky2_suspend,
 	.resume = sky2_resume,
+	.suspend_late = sky2_suspend_late,
+	.resume_early = sky2_resume_early,
 #endif
 };
 

--
Stephen Hemminger <shemminger@osdl.org>


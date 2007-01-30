From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: revert IRQ dance on suspend/resume
Date: Mon, 29 Jan 2007 16:38:07 -0800
Message-ID: <20070129163807.49739750@freekitty>
References: <Pine.LNX.4.64.0701241847360.25027@woody.linux-foundation.org>
	<1169931333.17469.125.camel@localhost.localdomain>
	<20070129113159.7ad22e4c@freekitty>
	<1170101430.29240.34.camel@localhost.localdomain>
	<20070129133849.1b523226@freekitty>
	<1170109401.29240.49.camel@localhost.localdomain>
	<Pine.LNX.4.64.0701291431320.3611@woody.linux-foundation.org>
	<20070129144055.151cfe52@freekitty>
	<Pine.LNX.4.64.0701291501180.3611@woody.linux-foundation.org>
	<20070129154518.40b0b3d3@freekitty>
	<Pine.LNX.4.64.0701291609180.3611@woody.linux-foundation.org>
	<20070129161626.33277eb1@freekitty>
	<Pine.LNX.4.64.0701291623360.3611@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35371 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965253AbXA3Akf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 19:40:35 -0500
In-Reply-To: <Pine.LNX.4.64.0701291623360.3611@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let's just backout the IRQ hack, and for those crap machines
(like some Sony VAIO's) can just disable MSI with the module
parameter.

Signed-off-by: Stephen Hemminger <shemminger@sony-laptop.(none)>
---
 drivers/net/sky2.c |   25 -------------------------
 1 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a2e804d..822dd0b 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3639,29 +3639,6 @@ static int sky2_resume(struct pci_dev *p
 out:
 	return err;
 }
-
-/* BIOS resume runs after device (it's a bug in PM)
- * as a temporary workaround on suspend/resume leave MSI disabled
- */
-static int sky2_suspend_late(struct pci_dev *pdev, pm_message_t state)
-{
-	struct sky2_hw *hw = pci_get_drvdata(pdev);
-
-	free_irq(pdev->irq, hw);
-	if (hw->msi) {
-		pci_disable_msi(pdev);
-		hw->msi = 0;
-	}
-	return 0;
-}
-
-static int sky2_resume_early(struct pci_dev *pdev)
-{
-	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	struct net_device *dev = hw->dev[0];
-
-	return request_irq(pdev->irq, sky2_intr, IRQF_SHARED, dev->name, hw);
-}
 #endif
 
 static struct pci_driver sky2_driver = {
@@ -3672,8 +3649,6 @@ static struct pci_driver sky2_driver = {
 #ifdef CONFIG_PM
 	.suspend = sky2_suspend,
 	.resume = sky2_resume,
-	.suspend_late = sky2_suspend_late,
-	.resume_early = sky2_resume_early,
 #endif
 };
 
-- 
1.4.1


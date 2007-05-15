From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/6] sky2: fix oops on shutdown
Date: Tue, 15 May 2007 15:08:27 -0700
Message-ID: <20070515220903.877649648@linux-foundation.org>
References: <20070515220821.676720721@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54346 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756595AbXEOWT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 18:19:28 -0400
Content-Disposition: inline; filename=sky2-shutdown.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the device fails during module startup for some reason like unsupported chip
version then the driver would crash dereferencing a null pointer, on shutdown
or suspend/resume.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- linux-2.6.21.y.orig/drivers/net/sky2.c	2007-05-15 09:07:14.000000000 -0700
+++ linux-2.6.21.y/drivers/net/sky2.c	2007-05-15 09:07:32.000000000 -0700
@@ -3719,6 +3719,7 @@ err_out_free_regions:
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 err_out:
+	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -3771,6 +3772,9 @@ static int sky2_suspend(struct pci_dev *
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return 0;
+
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
@@ -3802,6 +3806,9 @@ static int sky2_resume(struct pci_dev *p
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, err;
 
+	if (!hw)
+		return 0;
+
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
 		goto out;
@@ -3848,6 +3855,9 @@ static void sky2_shutdown(struct pci_dev
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return;
+
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 

--
Stephen Hemminger <shemminger@linux-foundation.org>


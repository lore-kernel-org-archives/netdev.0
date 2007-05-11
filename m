From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/4] sky2: fix oops on shutdown
Date: Fri, 11 May 2007 11:21:44 -0700
Message-ID: <20070511182251.277113203@linux-foundation.org>
References: <20070511182143.872814956@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:58197 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759123AbXEKSZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 14:25:38 -0400
Content-Disposition: inline; filename=sky2-shutdown.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the device is fails during module startup for some reason like
unsupported chip version then the driver would crash dereferencing a
null pointer, on shutdown or suspend/resume.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-10 10:27:48.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-10 11:29:17.000000000 -0700
@@ -3732,6 +3732,7 @@ err_out_free_regions:
 err_out_disable:
 	pci_disable_device(pdev);
 err_out:
+	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -3784,6 +3785,9 @@ static int sky2_suspend(struct pci_dev *
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return 0;
+
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
@@ -3815,6 +3819,9 @@ static int sky2_resume(struct pci_dev *p
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, err;
 
+	if (!hw)
+		return 0;
+
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
 		goto out;
@@ -3861,6 +3868,9 @@ static void sky2_shutdown(struct pci_dev
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return;
+
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 

--
Stephen Hemminger <shemminger@linux-foundation.org>


From: Brice Goglin <brice@myri.com>
Subject: [PATCH 5/5] myri10ge: handle failures in suspend and resume
Date: Mon, 18 Dec 2006 11:52:34 +0100
Message-ID: <458672F2.4050101@myri.com>
References: <45867228.1090406@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:41358 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753843AbWLRLVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 06:21:40 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <45867228.1090406@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On suspend, handle pci_set_power_state errors, and on resume
handle failures in pci_resume_state().

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/myri10ge/myri10ge.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2006-12-18 10:32:05.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2006-12-18 10:35:13.000000000 +0100
@@ -2540,8 +2540,8 @@
 	myri10ge_dummy_rdma(mgp, 0);
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-	return 0;
+
+	return pci_set_power_state(pdev, pci_choose_state(pdev, state));
 }
 
 static int myri10ge_resume(struct pci_dev *pdev)
@@ -2564,12 +2564,14 @@
 		return -EIO;
 	}
 
-	pci_restore_state(pdev);
+	status = pci_restore_state(pdev);
+	if (status)
+		return status;
 
 	status = pci_enable_device(pdev);
-	if (status < 0) {
+	if (status) {
 		dev_err(&pdev->dev, "failed to enable device\n");
-		return -EIO;
+		return status;
 	}
 
 	pci_set_master(pdev);



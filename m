From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/8] sky2: name irq after eth for irqbalance
Date: Tue, 26 Sep 2006 16:11:34 -0700
Message-ID: <20060926161134.4bb4071b@freekitty>
References: <20060926160814.79750148@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46515 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965144AbWIZXRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 19:17:53 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k8QNHInW026367
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:20 -0700
Received: from freekitty (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k8QNHIT0006577
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:18 -0700
To: netdev@vger.kernel.org
In-Reply-To: <20060926160814.79750148@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the ethernet device name when requesting the irq because the
irqbalance daemon looks for the name when deciding policy.
Better to play along with this dubious heuristic.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   37 ++++++++++++++++---------------------
 1 file changed, 16 insertions(+), 21 deletions(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-09-25 15:23:13.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2006-09-25 15:23:16.000000000 -0700
@@ -3349,6 +3349,14 @@
 	if (!dev)
 		goto err_out_free_pci;
 
+	if (!disable_msi && pci_enable_msi(pdev) == 0) {
+		err = sky2_test_msi(hw);
+		if (err == -EOPNOTSUPP)
+ 			pci_disable_msi(pdev);
+		else if (err)
+			goto err_out_free_netdev;
+ 	}
+
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR PFX "%s: cannot register net device\n",
@@ -3356,6 +3364,14 @@
 		goto err_out_free_netdev;
 	}
 
+	err = request_irq(pdev->irq,  sky2_intr, IRQF_SHARED, dev->name, hw);
+	if (err) {
+		printk(KERN_ERR PFX "%s: cannot assign irq %d\n",
+		       pci_name(pdev), pdev->irq);
+		goto err_out_unregister;
+	}
+	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+
 	sky2_show_addr(dev);
 
 	if (hw->ports > 1 && (dev1 = sky2_init_netdev(hw, 1, using_dac))) {
@@ -3370,23 +3386,6 @@
 		}
 	}
 
-	if (!disable_msi && pci_enable_msi(pdev) == 0) {
-		err = sky2_test_msi(hw);
-		if (err == -EOPNOTSUPP)
- 			pci_disable_msi(pdev);
-		else if (err)
-			goto err_out_unregister;
- 	}
-
-	err = request_irq(pdev->irq,  sky2_intr, IRQF_SHARED, DRV_NAME, hw);
-	if (err) {
-		printk(KERN_ERR PFX "%s: cannot assign irq %d\n",
-		       pci_name(pdev), pdev->irq);
-		goto err_out_unregister;
-	}
-
-	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
-
 	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
 	sky2_idle_start(hw);
 
@@ -3396,10 +3395,6 @@
 
 err_out_unregister:
 	pci_disable_msi(pdev);
-	if (dev1) {
-		unregister_netdev(dev1);
-		free_netdev(dev1);
-	}
 	unregister_netdev(dev);
 err_out_free_netdev:
 	free_netdev(dev);

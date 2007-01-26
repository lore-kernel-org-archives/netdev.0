From: shemminger@linux-foundation.org
Subject: [PATCH 1/5] sky2: handle network device allocation failure
Date: Fri, 26 Jan 2007 11:38:36 -0800
Message-ID: <20070126194004.028526000@linux-foundation.org>
References: <20070126193835.658962000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52044 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161227AbXAZTo4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 14:44:56 -0500
Content-Disposition: inline; filename=sky2-err-allocfail.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If alloc_etherdev() failed, then sky2_init_netdev will return NULL,
and sky2_probe would end up returning 0 instead of -ENOMEM.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- sky2-2.6.orig/drivers/net/sky2.c	2007-01-25 13:09:31.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2007-01-25 13:14:44.000000000 -0800
@@ -3350,7 +3350,7 @@
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
-	struct net_device *dev, *dev1 = NULL;
+	struct net_device *dev;
 	struct sky2_hw *hw;
 	int err, using_dac = 0;
 
@@ -3434,8 +3434,10 @@
 	       hw->chip_id, hw->chip_rev);
 
 	dev = sky2_init_netdev(hw, 0, using_dac);
-	if (!dev)
+	if (!dev) {
+		err = -ENOMEM;
 		goto err_out_free_pci;
+	}
 
 	if (!disable_msi && pci_enable_msi(pdev) == 0) {
 		err = sky2_test_msi(hw);
@@ -3463,13 +3465,19 @@
 
 	sky2_show_addr(dev);
 
-	if (hw->ports > 1 && (dev1 = sky2_init_netdev(hw, 1, using_dac))) {
-		if (register_netdev(dev1) == 0)
+	if (hw->ports > 1) {
+		struct net_device *dev1;
+
+		dev1 = sky2_init_netdev(hw, 1, using_dac);
+		if (!dev1) {
+			printk(KERN_WARNING PFX
+			       "allocation of second port failed\n");
+		}
+		else if (!(err = register_netdev(dev1)))
 			sky2_show_addr(dev1);
 		else {
-			/* Failure to register second port need not be fatal */
 			printk(KERN_WARNING PFX
-			       "register of second port failed\n");
+			       "register of second port failed (%d)\n", err);
 			hw->dev[1] = NULL;
 			free_netdev(dev1);
 		}

--
Stephen Hemminger <shemminger@linux-foundation.org>


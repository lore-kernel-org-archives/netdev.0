From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 1/4] defxx: Fix DEFPA enable error propagation
Date: Fri, 21 Nov 2014 14:09:52 +0000 (GMT)
Message-ID: <alpine.LFD.2.11.1411211122130.4773@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:59728 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758457AbaKUOJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 09:09:52 -0500
Received: from localhost.localdomain ([127.0.0.1]:49956 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S27006519AbaKUOJwEoAe0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:09:52 +0100
In-Reply-To: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correctly propagate the error code from `pci_enable_device' if non zero.
Currently a failure of this function is correctly recognized and device
initialization abandoned, however a successful completion code returned.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
linux-defpa-enable-err.patch
Index: linux-20141025-dolch/drivers/net/fddi/defxx.c
===================================================================
--- linux-20141025-dolch.orig/drivers/net/fddi/defxx.c
+++ linux-20141025-dolch/drivers/net/fddi/defxx.c
@@ -542,10 +542,13 @@ static int dfx_register(struct device *b
 	}
 
 	/* Enable PCI device. */
-	if (dfx_bus_pci && pci_enable_device(to_pci_dev(bdev))) {
-		printk(KERN_ERR "%s: Cannot enable PCI device, aborting\n",
-		       print_name);
-		goto err_out;
+	if (dfx_bus_pci) {
+		err = pci_enable_device(to_pci_dev(bdev));
+		if (err) {
+			pr_err("%s: Cannot enable PCI device, aborting\n",
+			       print_name);
+			goto err_out;
+		}
 	}
 
 	SET_NETDEV_DEV(dev, bdev);

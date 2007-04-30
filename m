From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Mon, 30 Apr 2007 14:23:49 -0700
Message-ID: <20070430142349.79754c1b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org,
	Francois SIMOND <curio@free.fr>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:59495 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946828AbXD3VZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 17:25:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the regression in 2.6.21 for users with 88e8056 on motherboard.
Allow all but the Gigabyte motherboard has some unresolved bus problems.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-04-27 13:37:32.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-04-30 14:01:15.000000000 -0700
@@ -123,10 +123,7 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) }, /* 88E8050 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) }, /* 88E8053 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) }, /* 88E8055 */
-#ifdef broken
-	/* This device causes data corruption problems that are not resolved */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) }, /* 88E8056 */
-#endif
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) }, /* 88EC036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) }, /* 88EC032 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
@@ -3580,10 +3577,21 @@ static int __devinit sky2_probe(struct p
 		goto err_out;
 	}
 
+	/* Some Gigabyte motherboards have 88e8056 but cause problems
+	 * There is some unresolved hardware related problem that causes
+	 * descriptor errors and receive data corruption.
+	 */
+	if (pdev->vendor == PCI_VENDOR_ID_MARVELL &&
+	    pdev->device == 0x4364 && pdev->subsystem_vendor == 0x1458) {
+		dev_err(&pdev->dev,
+			"88E8056 on Gigabyte motherboards not supported\n");
+		goto err_out_disable;
+	}
+
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
 		dev_err(&pdev->dev, "cannot obtain PCI resources\n");
-		goto err_out;
+		goto err_out_disable;
 	}
 
 	pci_set_master(pdev);
@@ -3720,6 +3728,7 @@ err_out_free_hw:
 	kfree(hw);
 err_out_free_regions:
 	pci_release_regions(pdev);
+err_out_disable:
 	pci_disable_device(pdev);
 err_out:
 	return err;

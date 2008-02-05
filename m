From: akpm@linux-foundation.org
Subject: [patch 4/4] drivers/net/tlan.c: compilation warning fix
Date: Mon, 04 Feb 2008 23:47:16 -0800
Message-ID: <200802050746.m157kvNk010407@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	lpotenza@inwind.it
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39999 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753560AbYBEHrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 02:47:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leonardo Potenza <lpotenza@inwind.it>

Add a check for the pci_register_driver() return value.  Removed unused
variable pad_allocated.

The aim of this patch is to remove the following warning messages:
drivers/net/tlan.c: In function 'tlan_probe':
drivers/net/tlan.c:486: warning: ignoring return value of 'pci_register_driver', declared with attribute warn_unused_result

Signed-off-by: Leonardo Potenza <lpotenza@inwind.it>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tlan.c |   25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff -puN drivers/net/tlan.c~drivers-net-tlanc-compilation-warning-fix drivers/net/tlan.c
--- a/drivers/net/tlan.c~drivers-net-tlanc-compilation-warning-fix
+++ a/drivers/net/tlan.c
@@ -465,7 +465,7 @@ static struct pci_driver tlan_driver = {
 
 static int __init tlan_probe(void)
 {
-	static int	pad_allocated;
+	int rc = -ENODEV;
 
 	printk(KERN_INFO "%s", tlan_banner);
 
@@ -473,17 +473,22 @@ static int __init tlan_probe(void)
 
 	if (TLanPadBuffer == NULL) {
 		printk(KERN_ERR "TLAN: Could not allocate memory for pad buffer.\n");
-		return -ENOMEM;
+		rc = -ENOMEM;
+		goto err_out;
 	}
 
 	memset(TLanPadBuffer, 0, TLAN_MIN_FRAME_SIZE);
-	pad_allocated = 1;
 
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting PCI Probe....\n");
 
 	/* Use new style PCI probing. Now the kernel will
 	   do most of this for us */
-	pci_register_driver(&tlan_driver);
+	rc = pci_register_driver(&tlan_driver);
+
+	if (rc != 0) {
+		printk(KERN_ERR "TLAN: Could not register pci driver.\n");
+		goto err_out_pci_free;
+	}
 
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting EISA Probe....\n");
 	TLan_EisaProbe();
@@ -493,11 +498,17 @@ static int __init tlan_probe(void)
 		 tlan_have_pci, tlan_have_eisa);
 
 	if (TLanDevicesInstalled == 0) {
-		pci_unregister_driver(&tlan_driver);
-		pci_free_consistent(NULL, TLAN_MIN_FRAME_SIZE, TLanPadBuffer, TLanPadBufferDMA);
-		return -ENODEV;
+		rc = -ENODEV;
+		goto  err_out_pci_unreg;
 	}
 	return 0;
+
+err_out_pci_unreg:
+	pci_unregister_driver(&tlan_driver);
+err_out_pci_free:
+	pci_free_consistent(NULL, TLAN_MIN_FRAME_SIZE, TLanPadBuffer, TLanPadBufferDMA);
+err_out:
+	return rc;
 }
 
 
_

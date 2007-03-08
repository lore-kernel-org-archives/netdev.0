From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] 3c59x: Fix several modpost warnings
Date: Thu, 8 Mar 2007 15:33:16 +0000
Message-ID: <20070308153316.GA17301@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:33773 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbXCHPfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 10:35:12 -0500
Received: from localhost.localdomain ([127.0.0.1]:37087 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021753AbXCHPfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:35:10 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WARNING: drivers/net/3c59x.o - Section mismatch: reference to .init.text: from .text between 'vortex_eisa_probe' (at offset 0x4580) and 'vortex_eisa_remove'
WARNING: drivers/net/3c59x.o - Section mismatch: reference to .init.text: from .text between 'vortex_eisa_probe' (at offset 0x4584) and 'vortex_eisa_remove'
WARNING: drivers/net/3c59x.o - Section mismatch: reference to .init.text: from .text between 'vortex_eisa_probe' (at offset 0x4588) and 'vortex_eisa_remove'
WARNING: drivers/net/3c59x.o - Section mismatch: reference to .init.text: from .text between 'vortex_eisa_probe' (at offset 0x458c) and 'vortex_eisa_remove'

Fixed by:

 o move definition of vortex_eisa_driver below the functions it references.
 o remove now unnecessary prototypes for vortex_eisa_probe and
   vortex_eisa_remove.
 o Make vortex_eisa_probe an __init function.
 o Make vortex_eisa_remove a __devexit function.
 o Wrap vortex_eisa_driver reference to vortex_eisa_remove with
   __devexit_p().

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/net/3c59x.c |   28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

Index: linux-mips/drivers/net/3c59x.c
===================================================================
--- linux-mips.orig/drivers/net/3c59x.c
+++ linux-mips/drivers/net/3c59x.c
@@ -858,19 +858,7 @@ static struct eisa_device_id vortex_eisa
 };
 MODULE_DEVICE_TABLE(eisa, vortex_eisa_ids);
 
-static int vortex_eisa_probe(struct device *device);
-static int vortex_eisa_remove(struct device *device);
-
-static struct eisa_driver vortex_eisa_driver = {
-	.id_table = vortex_eisa_ids,
-	.driver   = {
-		.name    = "3c59x",
-		.probe   = vortex_eisa_probe,
-		.remove  = vortex_eisa_remove
-	}
-};
-
-static int vortex_eisa_probe(struct device *device)
+static int __init vortex_eisa_probe(struct device *device)
 {
 	void __iomem *ioaddr;
 	struct eisa_device *edev;
@@ -893,7 +881,7 @@ static int vortex_eisa_probe(struct devi
 	return 0;
 }
 
-static int vortex_eisa_remove(struct device *device)
+static int __devexit vortex_eisa_remove(struct device *device)
 {
 	struct eisa_device *edev;
 	struct net_device *dev;
@@ -918,7 +906,17 @@ static int vortex_eisa_remove(struct dev
 	free_netdev(dev);
 	return 0;
 }
-#endif
+
+static struct eisa_driver vortex_eisa_driver = {
+	.id_table = vortex_eisa_ids,
+	.driver   = {
+		.name    = "3c59x",
+		.probe   = vortex_eisa_probe,
+		.remove  = __devexit_p(vortex_eisa_remove)
+	}
+};
+
+#endif /* CONFIG_EISA */
 
 /* returns count found (>= 0), or negative on error */
 static int __init vortex_eisa_init(void)

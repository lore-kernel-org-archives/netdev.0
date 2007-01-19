From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: Check error returns in initialization routines
Date: Thu, 18 Jan 2007 22:06:59 -0600
Message-ID: <45b043e3.NGzJyc7WBaqk9U0D%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

A number of the calls in the initialization routines fail to check the returned value for
errors. This patch adds the necessary checks and logs any errors found when appropriate.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

To be applied to wireless-2.6.


Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2980,8 +2980,10 @@ static int bcm43xx_chipset_attach(struct
 	err = bcm43xx_pctl_set_crystal(bcm, 1);
 	if (err)
 		goto out;
-	bcm43xx_pci_read_config16(bcm, PCI_STATUS, &pci_status);
-	bcm43xx_pci_write_config16(bcm, PCI_STATUS, pci_status & ~PCI_STATUS_SIG_TARGET_ABORT);
+	err = bcm43xx_pci_read_config16(bcm, PCI_STATUS, &pci_status);
+	if (err)
+		goto out;
+	err = bcm43xx_pci_write_config16(bcm, PCI_STATUS, pci_status & ~PCI_STATUS_SIG_TARGET_ABORT);
 
 out:
 	return err;
@@ -3793,12 +3795,18 @@ static int bcm43xx_attach_board(struct b
 	}
 	net_dev->base_addr = (unsigned long)bcm->mmio_addr;
 
-	bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_VENDOR_ID,
+	err = bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_VENDOR_ID,
 	                          &bcm->board_vendor);
-	bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_ID,
+	if (err)
+		goto err_iounmap;
+	err = bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_ID,
 	                          &bcm->board_type);
-	bcm43xx_pci_read_config16(bcm, PCI_REVISION_ID,
+	if (err)
+		goto err_iounmap;
+	err = bcm43xx_pci_read_config16(bcm, PCI_REVISION_ID,
 	                          &bcm->board_revision);
+	if (err)
+		goto err_iounmap;
 
 	err = bcm43xx_chipset_attach(bcm);
 	if (err)
@@ -3889,6 +3897,7 @@ err_pci_release:
 	pci_release_regions(pci_dev);
 err_pci_disable:
 	pci_disable_device(pci_dev);
+	printk(KERN_ERR PFX "Unable to attach board\n");
 	goto out;
 }

--- 

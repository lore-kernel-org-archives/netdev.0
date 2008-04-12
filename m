From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] natsemi: fix MMIO for PPC 44x platforms
Date: Sat, 12 Apr 2008 20:58:30 +0400
Message-ID: <200804122058.31075.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:9149 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753123AbYDLQ7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 12:59:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver stores the PCI resource address into 'unsigned long' variable before
calling ioremap()  on it. This warrants a kernel oops when the registers are
accessed on PPC 44x platforms which (being 32-bit) have PCI memory space mapped
beyond 4 GB.

The arch/ppc/ kernel has a fixup in ioremap() that creates an illusion of the
PCI memory resources are mapped below 4 GB, but arch/powerpc/ code got rid of
this trick, having instead CONFIG_RESOURCES_64BIT enabled.

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
Reposting the patch with the typecast, log, and summary corrected.
This is the same issue as the one that has been recently addressed by commits
3c34ac36ac1084e571ef9b6fb1d6a5b10ccc1fd0 (e1000: Fix for 32 bits platforms with
64 bits resources) and c976816b6e901341ec3c4653147316c15549a1c4 (siimage: fix
kernel oops on PPC 44x).  The patch has only been compile tested though...

 drivers/net/natsemi.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/net/natsemi.c
===================================================================
--- linux-2.6.orig/drivers/net/natsemi.c
+++ linux-2.6/drivers/net/natsemi.c
@@ -786,7 +786,8 @@ static int __devinit natsemi_probe1 (str
 	struct netdev_private *np;
 	int i, option, irq, chip_idx = ent->driver_data;
 	static int find_cnt = -1;
-	unsigned long iostart, iosize;
+	resource_size_t iostart;
+	unsigned long iosize;
 	void __iomem *ioaddr;
 	const int pcibar = 1; /* PCI base address register */
 	int prev_eedata;
@@ -946,10 +947,11 @@ static int __devinit natsemi_probe1 (str
 		goto err_create_file;
 
 	if (netif_msg_drv(np)) {
-		printk(KERN_INFO "natsemi %s: %s at %#08lx "
+		printk(KERN_INFO "natsemi %s: %s at %#08llx "
 		       "(%s), %s, IRQ %d",
-		       dev->name, natsemi_pci_info[chip_idx].name, iostart,
-		       pci_name(np->pci_dev), print_mac(mac, dev->dev_addr), irq);
+		       dev->name, natsemi_pci_info[chip_idx].name,
+		       (unsigned long long)iostart, pci_name(np->pci_dev),
+		       print_mac(mac, dev->dev_addr), irq);
 		if (dev->if_port == PORT_TP)
 			printk(", port TP.\n");
 		else if (np->ignore_phy)


From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net: fix PCI must_checks
Date: Wed, 4 Apr 2007 21:37:27 -0700
Message-ID: <20070404213727.2d137518.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, akpm <akpm@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:24871 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161148AbXDEEhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 00:37:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Check PCI interfaces results in net/ drivers.

Fixes these warnings:

drivers/net/3c59x.c:1499: warning: ignoring return value of 'pci_enable_device', declared with attribute warn_unused_result
drivers/net/ne2k-pci.c:676: warning: ignoring return value of 'pci_enable_device', declared with attribute warn_unused_result
drivers/net/eepro100.c:2298: warning: ignoring return value of 'pci_enable_device', declared with attribute warn_unused_result
drivers/net/natsemi.c:3255: warning: ignoring return value of 'pci_enable_device', declared with attribute warn_unused_result
drivers/net/starfire.c:743: warning: ignoring return value of 'pci_set_mwi', declared with attribute warn_unused_result
drivers/net/tulip/tulip_core.c:1158: warning: ignoring return value of 'pci_set_mwi', declared with attribute warn_unused_result
drivers/net/cassini.c:4925: warning: ignoring return value of 'pci_set_mwi', declared with attribute warn_unused_result

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/3c59x.c            |    8 +++++++-
 drivers/net/cassini.c          |    4 +++-
 drivers/net/eepro100.c         |    8 +++++++-
 drivers/net/natsemi.c          |   10 +++++++++-
 drivers/net/ne2k-pci.c         |    8 +++++++-
 drivers/net/starfire.c         |    4 +++-
 drivers/net/tulip/tulip_core.c |    9 +++++++--
 7 files changed, 43 insertions(+), 8 deletions(-)

--- linux-2.6.21-rc5-mm4.orig/drivers/net/3c59x.c
+++ linux-2.6.21-rc5-mm4/drivers/net/3c59x.c
@@ -1490,12 +1490,18 @@ vortex_up(struct net_device *dev)
 	void __iomem *ioaddr = vp->ioaddr;
 	unsigned int config;
 	int i, mii_reg1, mii_reg5;
+	int err;
 
 	if (VORTEX_PCI(vp)) {
 		pci_set_power_state(VORTEX_PCI(vp), PCI_D0);	/* Go active */
 		if (vp->pm_state_valid)
 			pci_restore_state(VORTEX_PCI(vp));
-		pci_enable_device(VORTEX_PCI(vp));
+		err = pci_enable_device(VORTEX_PCI(vp));
+		if (err) {
+			printk(KERN_ERR "%s: error %d enabling device\n",
+				dev->name, err);
+			return;
+		}
 	}
 
 	/* Before initializing select the active media port. */
--- linux-2.6.21-rc5-mm4.orig/drivers/net/ne2k-pci.c
+++ linux-2.6.21-rc5-mm4/drivers/net/ne2k-pci.c
@@ -670,10 +670,16 @@ static int ne2k_pci_suspend (struct pci_
 static int ne2k_pci_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
+	int err;
 
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev);
-	pci_enable_device(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "error %d enabling device for resume\n",
+			err);
+		return err;
+	}
 	NS8390_init(dev, 1);
 	netif_device_attach(dev);
 
--- linux-2.6.21-rc5-mm4.orig/drivers/net/eepro100.c
+++ linux-2.6.21-rc5-mm4/drivers/net/eepro100.c
@@ -2292,10 +2292,16 @@ static int eepro100_resume(struct pci_de
 	struct net_device *dev = pci_get_drvdata (pdev);
 	struct speedo_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = sp->regs;
+	int err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	pci_enable_device(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "error %d enabling device for resume\n",
+			err);
+		return err;
+	}
 	pci_set_master(pdev);
 
 	if (!netif_running(dev))
--- linux-2.6.21-rc5-mm4.orig/drivers/net/natsemi.c
+++ linux-2.6.21-rc5-mm4/drivers/net/natsemi.c
@@ -3250,8 +3250,16 @@ static int natsemi_resume (struct pci_de
 	if (netif_device_present(dev))
 		goto out;
 	if (netif_running(dev)) {
+		int err;
+
 		BUG_ON(!np->hands_off);
-		pci_enable_device(pdev);
+		err = pci_enable_device(pdev);
+		if (err) {
+			printk(KERN_ERR
+				"%s: error %d enabling device for resume\n",
+				dev->name, err);
+			return err;
+		}
 	/*	pci_power_on(pdev); */
 
 		natsemi_reset(dev);
--- linux-2.6.21-rc5-mm4.orig/drivers/net/starfire.c
+++ linux-2.6.21-rc5-mm4/drivers/net/starfire.c
@@ -740,7 +740,9 @@ static int __devinit starfire_init_one(s
 	pci_set_master(pdev);
 
 	/* enable MWI -- it vastly improves Rx performance on sparc64 */
-	pci_set_mwi(pdev);
+	if (pci_set_mwi(pdev))
+		printk(KERN_WARNING DRV_NAME
+			": error enabling PCI MWI transactions\n");
 
 #ifdef ZEROCOPY
 	/* Starfire can do TCP/UDP checksumming */
--- linux-2.6.21-rc5-mm4.orig/drivers/net/tulip/tulip_core.c
+++ linux-2.6.21-rc5-mm4/drivers/net/tulip/tulip_core.c
@@ -1155,8 +1155,13 @@ static void __devinit tulip_mwi_config (
 	/* set or disable MWI in the standard PCI command bit.
 	 * Check for the case where  mwi is desired but not available
 	 */
-	if (csr0 & MWI)	pci_set_mwi(pdev);
-	else		pci_clear_mwi(pdev);
+	if (csr0 & MWI) {
+		if (pci_set_mwi(pdev))
+			printk(KERN_WARNING
+				"%s: error enabling PCI MWI transactions\n",
+				pci_name(pdev));
+	} else
+		pci_clear_mwi(pdev);
 
 	/* read result from hardware (in case bit refused to enable) */
 	pci_read_config_word(pdev, PCI_COMMAND, &pci_command);
--- linux-2.6.21-rc5-mm4.orig/drivers/net/cassini.c
+++ linux-2.6.21-rc5-mm4/drivers/net/cassini.c
@@ -4919,7 +4919,9 @@ static int __devinit cas_init_one(struct
 	pci_cmd &= ~PCI_COMMAND_SERR;
 	pci_cmd |= PCI_COMMAND_PARITY;
 	pci_write_config_word(pdev, PCI_COMMAND, pci_cmd);
-	pci_set_mwi(pdev);
+	if (pci_set_mwi(pdev))
+		printk(KERN_WARNING "%s: error enabling PCI MWI transactions\n",
+			dev->name);
 	/*
 	 * On some architectures, the default cache line size set
 	 * by pci_set_mwi reduces perforamnce.  We have to increase

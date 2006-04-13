From: Marc Zyngier <maz@misterjones.org>
Subject: [PATCH] Repost : Convert cassini to pci_iomap
Date: Thu, 13 Apr 2006 11:38:20 +0200
Message-ID: <wrp1ww1izn7.fsf@wild-wind.fr.eu.org>
Reply-To: maz@misterjones.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lopsy-lu.misterjones.org ([62.4.18.26]:41609 "EHLO
	young-lust.wild-wind.fr.eu.org") by vger.kernel.org with ESMTP
	id S964862AbWDMJi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:38:27 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks,

This patch (against 2.6.17-rc1) converts the cassini driver to the
pci_iomap API that will do the right thing, so architectures like
PARISC can stop screaming about illegal usage of ioremap() on
non-cacheable regions.

Tested on 64bit PARISC kernel.

Signed-off-by: Marc Zyngier <maz@misterjones.org>

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index ac48f75..39f36aa 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4877,7 +4877,7 @@ static int __devinit cas_init_one(struct
 				  const struct pci_device_id *ent)
 {
 	static int cas_version_printed = 0;
-	unsigned long casreg_base, casreg_len;
+	unsigned long casreg_len;
 	struct net_device *dev;
 	struct cas *cp;
 	int i, err, pci_using_dac;
@@ -4972,7 +4972,6 @@ static int __devinit cas_init_one(struct
 		pci_using_dac = 0;
 	}
 
-	casreg_base = pci_resource_start(pdev, 0);
 	casreg_len = pci_resource_len(pdev, 0);
 
 	cp = netdev_priv(dev);
@@ -5024,7 +5023,7 @@ static int __devinit cas_init_one(struct
 	cp->timer_ticks = 0;
 
 	/* give us access to cassini registers */
-	cp->regs = ioremap(casreg_base, casreg_len);
+	cp->regs = pci_iomap(pdev, 0, casreg_len);
 	if (cp->regs == 0UL) {
 		printk(KERN_ERR PFX "Cannot map device registers, "
 		       "aborting.\n");
@@ -5123,7 +5122,7 @@ err_out_iounmap:
 		cas_shutdown(cp);
 	mutex_unlock(&cp->pm_mutex);
 
-	iounmap(cp->regs);
+	pci_iounmap(pdev, cp->regs);
 
 
 err_out_free_res:
@@ -5171,7 +5170,7 @@ static void __devexit cas_remove_one(str
 #endif
 	pci_free_consistent(pdev, sizeof(struct cas_init_block),
 			    cp->init_block, cp->block_dvma);
-	iounmap(cp->regs);
+	pci_iounmap(pdev, cp->regs);
 	free_netdev(dev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);

-- 
And if you don't know where you're going, any road will take you there...

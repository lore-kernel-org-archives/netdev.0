From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 10/18] isdn: hisax: call disable_pci_device() if pci_probe() failed
Date: Sat,  7 Aug 2010 00:02:21 +0400
Message-ID: <1281124949-14361-1-git-send-email-segooon@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Tilman Schmidt <tilman@imap.cc>, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:52928 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756868Ab0HFUCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 16:02:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver should call disable_pci_device() if it returns from pci_probe()
with error.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/isdn/hisax/avm_pci.c   |    2 ++
 drivers/isdn/hisax/elsa.c      |    5 +++++
 drivers/isdn/hisax/nj_u.c      |    2 ++
 drivers/isdn/hisax/sedlbauer.c |    3 +++
 drivers/isdn/hisax/w6692.c     |    6 +++++-
 5 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/hisax/avm_pci.c b/drivers/isdn/hisax/avm_pci.c
index fcf4ed1..c503d7f 100644
--- a/drivers/isdn/hisax/avm_pci.c
+++ b/drivers/isdn/hisax/avm_pci.c
@@ -845,12 +845,14 @@ static int __devinit avm_pci_setup(struct IsdnCardState *cs)
 		cs->irq = dev_avm->irq;
 		if (!cs->irq) {
 			printk(KERN_ERR "FritzPCI: No IRQ for PCI card found\n");
+			pci_disable_device(dev_avm);
 			return(0);
 		}
 
 		cs->hw.avm.cfg_reg = pci_resource_start(dev_avm, 1);
 		if (!cs->hw.avm.cfg_reg) {
 			printk(KERN_ERR "FritzPCI: No IO-Adr for PCI card found\n");
+			pci_disable_device(dev_avm);
 			return(0);
 		}
 
diff --git a/drivers/isdn/hisax/elsa.c b/drivers/isdn/hisax/elsa.c
index 5d9d338..452429a 100644
--- a/drivers/isdn/hisax/elsa.c
+++ b/drivers/isdn/hisax/elsa.c
@@ -1034,12 +1034,14 @@ static int __devinit
 setup_elsa_pci(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
+	struct pci_dev *pdev;
 
 	cs->subtyp = 0;
 	if ((dev_qs1000 = hisax_find_pci_device(PCI_VENDOR_ID_ELSA,
 		PCI_DEVICE_ID_ELSA_MICROLINK, dev_qs1000))) {
 		if (pci_enable_device(dev_qs1000))
 			return(0);
+		pdev = dev_qs1000;
 		cs->subtyp = ELSA_QS1000PCI;
 		cs->irq = dev_qs1000->irq;
 		cs->hw.elsa.cfg = pci_resource_start(dev_qs1000, 1);
@@ -1048,6 +1050,7 @@ setup_elsa_pci(struct IsdnCard *card)
 		PCI_DEVICE_ID_ELSA_QS3000, dev_qs3000))) {
 		if (pci_enable_device(dev_qs3000))
 			return(0);
+		pdev = dev_qs3000;
 		cs->subtyp = ELSA_QS3000PCI;
 		cs->irq = dev_qs3000->irq;
 		cs->hw.elsa.cfg = pci_resource_start(dev_qs3000, 1);
@@ -1058,11 +1061,13 @@ setup_elsa_pci(struct IsdnCard *card)
 	}
 	if (!cs->irq) {
 		printk(KERN_WARNING "Elsa: No IRQ for PCI card found\n");
+		pci_disable_device(pdev);
 		return(0);
 	}
 
 	if (!(cs->hw.elsa.base && cs->hw.elsa.cfg)) {
 		printk(KERN_WARNING "Elsa: No IO-Adr for PCI card found\n");
+		pci_disable_device(pdev);
 		return(0);
 	}
 	if ((cs->hw.elsa.cfg & 0xff) || (cs->hw.elsa.base & 0xf)) {
diff --git a/drivers/isdn/hisax/nj_u.c b/drivers/isdn/hisax/nj_u.c
index 095e974..bc5afbe 100644
--- a/drivers/isdn/hisax/nj_u.c
+++ b/drivers/isdn/hisax/nj_u.c
@@ -137,11 +137,13 @@ static int __devinit nju_pci_probe(struct pci_dev *dev_netjet,
 	cs->irq = dev_netjet->irq;
 	if (!cs->irq) {
 		printk(KERN_WARNING "NETspider-U: No IRQ for PCI card found\n");
+		pci_disable_device(dev_netjet);
 		return(0);
 	}
 	cs->hw.njet.base = pci_resource_start(dev_netjet, 0);
 	if (!cs->hw.njet.base) {
 		printk(KERN_WARNING "NETspider-U: No IO-Adr for PCI card found\n");
+		pci_disable_device(dev_netjet);
 		return(0);
 	}
 
diff --git a/drivers/isdn/hisax/sedlbauer.c b/drivers/isdn/hisax/sedlbauer.c
index 69dfc8d..dc9864b 100644
--- a/drivers/isdn/hisax/sedlbauer.c
+++ b/drivers/isdn/hisax/sedlbauer.c
@@ -614,6 +614,7 @@ setup_sedlbauer_pci(struct IsdnCard *card)
 		cs->irq = dev_sedl->irq;
 		if (!cs->irq) {
 			printk(KERN_WARNING "Sedlbauer: No IRQ for PCI card found\n");
+			pci_disable_device(dev_sedl);
 			return(0);
 		}
 		cs->hw.sedl.cfg_reg = pci_resource_start(dev_sedl, 0);
@@ -631,6 +632,7 @@ setup_sedlbauer_pci(struct IsdnCard *card)
 		cs->hw.sedl.cfg_reg);
 	if (sub_id != PCI_SUB_ID_SEDLBAUER) {
 		printk(KERN_ERR "Sedlbauer: unknown sub id %#x\n", sub_id);
+		pci_disable_device(dev_sedl);
 		return(0);
 	}
 	if (sub_vendor_id == PCI_SUBVENDOR_SPEEDFAX_PYRAMID) {
@@ -648,6 +650,7 @@ setup_sedlbauer_pci(struct IsdnCard *card)
 	} else {
 		printk(KERN_ERR "Sedlbauer: unknown sub vendor id %#x\n",
 			sub_vendor_id);
+		pci_disable_device(dev_sedl);
 		return(0);
 	}
 
diff --git a/drivers/isdn/hisax/w6692.c b/drivers/isdn/hisax/w6692.c
index e2cfb6f..4221cab 100644
--- a/drivers/isdn/hisax/w6692.c
+++ b/drivers/isdn/hisax/w6692.c
@@ -1012,8 +1012,10 @@ setup_w6692(struct IsdnCard *card)
 					    id_list[id_idx].device_id,
 					    dev_w6692);
 		if (dev_w6692) {
-			if (pci_enable_device(dev_w6692))
+			if (pci_enable_device(dev_w6692)) {
+				dev_w6692 = NULL;
 				continue;
+			}
 			cs->subtyp = id_idx;
 			break;
 		}
@@ -1040,10 +1042,12 @@ setup_w6692(struct IsdnCard *card)
 	cs->irq = pci_irq;
 	if (!cs->irq) {
 		printk(KERN_WARNING "W6692: No IRQ for PCI card found\n");
+		pci_disable_device(dev_w6692);
 		return (0);
 	}
 	if (!pci_ioaddr) {
 		printk(KERN_WARNING "W6692: NO I/O Base Address found\n");
+		pci_disable_device(dev_w6692);
 		return (0);
 	}
 	cs->hw.w6692.iobase = pci_ioaddr;
-- 
1.7.0.4


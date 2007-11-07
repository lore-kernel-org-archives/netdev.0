From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH] PCI: export pci_restore_msi_state()
Date: Wed, 7 Nov 2007 15:43:59 -0600
Message-ID: <20071107214359.GJ4239@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	mcarlson@broadcom.com, wenxiong@us.ibm.com, mchan@broadcom.com,
	"Kok, Auke" <auke-jan.h.kok@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:54825 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752949AbXKGVoa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 16:44:30 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA7Li61a007913
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 16:44:06 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA7Li1mk448286
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 16:44:06 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA7Li0jG016042
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 16:44:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


PCI error recovery usually involves the PCI adapter being reset.
If the device is using MSI, the reset will cause the MSI state 
to be lost; the device driver needs to restore the MSI state.

The pci_restore_msi_state() routine is currently protected
by CONFIG_PM; remove this, and also export the symbol, so
that it can be used in a modle.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
I am so sorry I wasn't able to send this 3 weeks ago, when
I first wrote the patch. There was simply no functional
hardware available to actually run this stuff :-(

Patches that use this, including those for tg3 and e1000e and ixgbe
i.e. MSI-using drivers, are to follow "real soon now". 

 drivers/pci/msi.c   |    3 +--
 drivers/pci/pci.h   |    6 ------
 include/linux/pci.h |    2 ++
 3 files changed, 3 insertions(+), 8 deletions(-)

Index: linux-2.6.23-rc8-mm1/drivers/pci/msi.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/drivers/pci/msi.c	2007-10-16 15:14:20.000000000 -0500
+++ linux-2.6.23-rc8-mm1/drivers/pci/msi.c	2007-10-16 15:14:42.000000000 -0500
@@ -224,7 +224,6 @@ static struct msi_desc* alloc_msi_entry(
 	return entry;
 }
 
-#ifdef CONFIG_PM
 static void __pci_restore_msi_state(struct pci_dev *dev)
 {
 	int pos;
@@ -282,7 +281,7 @@ void pci_restore_msi_state(struct pci_de
 	__pci_restore_msi_state(dev);
 	__pci_restore_msix_state(dev);
 }
-#endif	/* CONFIG_PM */
+EXPORT_SYMBOL_GPL(pci_restore_msi_state);
 
 /**
  * msi_capability_init - configure device's MSI capability structure
Index: linux-2.6.23-rc8-mm1/drivers/pci/pci.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/drivers/pci/pci.h	2007-10-16 15:14:20.000000000 -0500
+++ linux-2.6.23-rc8-mm1/drivers/pci/pci.h	2007-10-16 15:19:33.000000000 -0500
@@ -45,12 +45,6 @@ static inline void pci_no_msi(void) { }
 static inline void pci_msi_init_pci_dev(struct pci_dev *dev) { }
 #endif
 
-#if defined(CONFIG_PCI_MSI) && defined(CONFIG_PM)
-void pci_restore_msi_state(struct pci_dev *dev);
-#else
-static inline void pci_restore_msi_state(struct pci_dev *dev) {}
-#endif
-
 static inline int pci_no_d1d2(struct pci_dev *dev)
 {
 	unsigned int parent_dstates = 0;
Index: linux-2.6.23-rc8-mm1/include/linux/pci.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/pci.h	2007-10-01 13:26:38.000000000 -0500
+++ linux-2.6.23-rc8-mm1/include/linux/pci.h	2007-10-16 15:19:07.000000000 -0500
@@ -665,6 +665,7 @@ static inline int pci_enable_msix(struct
 	struct msix_entry *entries, int nvec) {return -1;}
 static inline void pci_disable_msix(struct pci_dev *dev) {}
 static inline void msi_remove_pci_irq_vectors(struct pci_dev *dev) {}
+static inline void pci_restore_msi_state(struct pci_dev *dev) {}
 #else
 extern int pci_enable_msi(struct pci_dev *dev);
 extern void pci_disable_msi(struct pci_dev *dev);
@@ -672,6 +673,7 @@ extern int pci_enable_msix(struct pci_de
 	struct msix_entry *entries, int nvec);
 extern void pci_disable_msix(struct pci_dev *dev);
 extern void msi_remove_pci_irq_vectors(struct pci_dev *dev);
+extern void pci_restore_msi_state(struct pci_dev *dev);
 #endif
 
 #ifdef CONFIG_HT_IRQ

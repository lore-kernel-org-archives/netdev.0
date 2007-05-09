From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 14/17] pci_wake_enabled function
Date: Tue, 08 May 2007 20:50:03 -0700
Message-ID: <20070509035030.716588432@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:59899 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1033324AbXEIEER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:04:17 -0400
Cc: Greg KH <greg@kroah.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz
Content-Disposition: inline; filename=pci_pme_enabled.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both skge and sky2 drivers have test to see if PCI wakeup is enabled
in the BIOS. It makes sense to move this to common code.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c  |   18 ------------------
 drivers/net/sky2.c  |   11 -----------
 drivers/pci/pci.c   |   22 ++++++++++++++++++++++
 include/linux/pci.h |    1 +
 4 files changed, 23 insertions(+), 29 deletions(-)

--- sky2-2.6.21.orig/drivers/net/skge.c	2007-05-08 15:36:57.000000000 -0700
+++ sky2-2.6.21/drivers/net/skge.c	2007-05-08 15:37:06.000000000 -0700
@@ -144,24 +144,6 @@ static u32 wol_supported(const struct sk
 	return WAKE_MAGIC | WAKE_PHY;
 }
 
-static u32 pci_wake_enabled(struct pci_dev *dev)
-{
-	int pm = pci_find_capability(dev, PCI_CAP_ID_PM);
-	u16 value;
-
-	/* If device doesn't support PM Capabilities, but request is to disable
-	 * wake events, it's a nop; otherwise fail */
-	if (!pm)
-		return 0;
-
-	pci_read_config_word(dev, pm + PCI_PM_PMC, &value);
-
-	value &= PCI_PM_CAP_PME_MASK;
-	value >>= ffs(PCI_PM_CAP_PME_MASK) - 1;   /* First bit of mask */
-
-	return value != 0;
-}
-
 static void skge_wol_init(struct skge_port *skge)
 {
 	struct skge_hw *hw = skge->hw;
--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 15:37:04.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 15:37:06.000000000 -0700
@@ -3558,17 +3558,6 @@ static int __devinit sky2_test_msi(struc
 	return err;
 }
 
-static int __devinit pci_wake_enabled(struct pci_dev *dev)
-{
-	int pm  = pci_find_capability(dev, PCI_CAP_ID_PM);
-	u16 value;
-
-	if (!pm)
-		return 0;
-	if (pci_read_config_word(dev, pm + PCI_PM_CTRL, &value))
-		return 0;
-	return value & PCI_PM_CTRL_PME_ENABLE;
-}
 
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
--- sky2-2.6.21.orig/drivers/pci/pci.c	2007-05-08 15:36:57.000000000 -0700
+++ sky2-2.6.21/drivers/pci/pci.c	2007-05-08 15:37:06.000000000 -0700
@@ -991,6 +991,27 @@ int pci_enable_wake(struct pci_dev *dev,
 	return 0;
 }
 
+/**
+ * pci_wake_enabled - is wakeup event from this PCI device entabled
+ * @dev: PCI device affected
+ *
+ * This checks if device has a wakeup event source.
+ *
+ * 0 is returned if the device is not a wakeup event source.
+ * 1 is returned if the device cat generate wakeup events.
+ */
+int pci_wake_enabled(struct pci_dev *dev)
+{
+	int pm  = pci_find_capability(dev, PCI_CAP_ID_PM);
+	u16 value;
+
+	if (!pm)
+		return 0;
+	if (pci_read_config_word(dev, pm + PCI_PM_CTRL, &value))
+		return 0;
+	return (value & PCI_PM_CTRL_PME_ENABLE) != 0;
+}
+
 int
 pci_get_interrupt_pin(struct pci_dev *dev, struct pci_dev **bridge)
 {
@@ -1454,5 +1475,6 @@ EXPORT_SYMBOL(pci_set_power_state);
 EXPORT_SYMBOL(pci_save_state);
 EXPORT_SYMBOL(pci_restore_state);
 EXPORT_SYMBOL(pci_enable_wake);
+EXPORT_SYMBOL(pci_wake_enabled);
 EXPORT_SYMBOL_GPL(pci_set_pcie_reset_state);
 
--- sky2-2.6.21.orig/include/linux/pci.h	2007-05-08 15:36:57.000000000 -0700
+++ sky2-2.6.21/include/linux/pci.h	2007-05-08 15:37:06.000000000 -0700
@@ -567,6 +567,7 @@ int pci_restore_state(struct pci_dev *de
 int pci_set_power_state(struct pci_dev *dev, pci_power_t state);
 pci_power_t pci_choose_state(struct pci_dev *dev, pm_message_t state);
 int pci_enable_wake(struct pci_dev *dev, pci_power_t state, int enable);
+int pci_wake_enabled(struct pci_dev *dev);
 
 /* Helper functions for low-level code (drivers/pci/setup-[bus,res].c) */
 void pci_bus_assign_resources(struct pci_bus *bus);

--


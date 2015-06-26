From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 03/10] e1000e: fix locking issue with e1000e_disable_aspm
Date: Fri, 26 Jun 2015 03:20:33 -0700
Message-ID: <1435314040-3228-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58214 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751682AbbFZKUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 06:20:47 -0400
In-Reply-To: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

e1000e_disable_aspm called pci_disable_link_state_locked which requires
pci_bus_sem to be held, but is also called from places where this semaphore
was not previously acquired. This patch implements two flavors of
disable_aspm, one that acquires the lock, and the other (_locked) which
should be called when the semaphore is already acquired.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 38 ++++++++++++++++++++++++++----
 1 file changed, 34 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e62b9dc..89d788d 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6354,13 +6354,14 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
 }
 
 /**
- * e1000e_disable_aspm - Disable ASPM states
+ * __e1000e_disable_aspm - Disable ASPM states
  * @pdev: pointer to PCI device struct
  * @state: bit-mask of ASPM states to disable
+ * @locked: indication if this context holds pci_bus_sem locked.
  *
  * Some devices *must* have certain ASPM states disabled per hardware errata.
  **/
-static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
+static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state, int locked)
 {
 	struct pci_dev *parent = pdev->bus->self;
 	u16 aspm_dis_mask = 0;
@@ -6399,7 +6400,10 @@ static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
 		 "L1" : "");
 
 #ifdef CONFIG_PCIEASPM
-	pci_disable_link_state_locked(pdev, state);
+	if (locked)
+		pci_disable_link_state_locked(pdev, state);
+	else
+		pci_disable_link_state(pdev, state);
 
 	/* Double-check ASPM control.  If not disabled by the above, the
 	 * BIOS is preventing that from happening (or CONFIG_PCIEASPM is
@@ -6422,6 +6426,32 @@ static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
 					   aspm_dis_mask);
 }
 
+/**
+ * e1000e_disable_aspm - Disable ASPM states.
+ * @pdev: pointer to PCI device struct
+ * @state: bit-mask of ASPM states to disable
+ *
+ * This function acquires the pci_bus_sem!
+ * Some devices *must* have certain ASPM states disabled per hardware errata.
+ **/
+static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
+{
+	__e1000e_disable_aspm(pdev, state, 0);
+}
+
+/**
+ * e1000e_disable_aspm_locked   Disable ASPM states.
+ * @pdev: pointer to PCI device struct
+ * @state: bit-mask of ASPM states to disable
+ *
+ * This function must be called with pci_bus_sem acquired!
+ * Some devices *must* have certain ASPM states disabled per hardware errata.
+ **/
+static void e1000e_disable_aspm_locked(struct pci_dev *pdev, u16 state)
+{
+	__e1000e_disable_aspm(pdev, state, 1);
+}
+
 #ifdef CONFIG_PM
 static int __e1000_resume(struct pci_dev *pdev)
 {
@@ -6435,7 +6465,7 @@ static int __e1000_resume(struct pci_dev *pdev)
 	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
 		aspm_disable_flag |= PCIE_LINK_STATE_L1;
 	if (aspm_disable_flag)
-		e1000e_disable_aspm(pdev, aspm_disable_flag);
+		e1000e_disable_aspm_locked(pdev, aspm_disable_flag);
 
 	pci_set_master(pdev);
 
-- 
2.4.3

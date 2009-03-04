From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/2] PCI: Add PCI quirk to disable L0s ASPM state for
	82575 and 82598
Date: Tue, 03 Mar 2009 18:03:09 -0800
Message-ID: <20090304020308.15176.40527.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-pci <linux-pci@vger.kernel.org>,
	Matthew Wilcox <willy@linux.intel.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: davem@davemloft.net
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is intended to disable L0s ASPM link state for 82598 (ixgbe)
parts due to the fact that it is possible to corrupt TX data when coming
back out of L0s on some systems.  The workaround had been added for 82575
(igb) previously, but did not use the ASPM api.  This quirk uses the ASPM
api to prevent the ASPM subsystem from re-enabling the L0s state.

Instead of adding the fix in igb to the ixgbe driver as well it was
decided to move it into a pci quirk.  It is necessary to move the fix out
of the driver and into a pci quirk in order to prevent the issue from
occuring prior to driver load to handle the possibility of the device being
passed to a VM via direct assignment.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: linux-pci <linux-pci@vger.kernel.org>
CC: Matthew Wilcox <willy@linux.intel.com>
CC: Jesse Barnes <jbarnes@virtuousgeek.org>
---

 drivers/pci/quirks.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index f20d553..1a7c48d 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -23,6 +23,7 @@
 #include <linux/acpi.h>
 #include <linux/kallsyms.h>
 #include <linux/dmi.h>
+#include <linux/pci-aspm.h>
 #include "pci.h"
 
 int isa_dma_bridge_buggy;
@@ -1749,6 +1750,30 @@ static void __devinit quirk_e100_interrupt(struct pci_dev *dev)
 }
 DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_ANY_ID, quirk_e100_interrupt);
 
+/*
+ * The 82575 and 82598 may experience data corruption issues when transitioning
+ * out of L0S.  To prevent this we need to disable L0S on the pci-e link
+ */
+static void __devinit quirk_disable_aspm_l0s(struct pci_dev *dev)
+{
+	dev_info(&dev->dev, "Disabling L0s\n");
+	pci_disable_link_state(dev, PCIE_LINK_STATE_L0S);
+}
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10a7, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10a9, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10b6, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10c6, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10c7, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10c8, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10d6, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10db, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10dd, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10e1, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10ec, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10f1, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10f4, quirk_disable_aspm_l0s);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x1508, quirk_disable_aspm_l0s);
+
 static void __devinit fixup_rev1_53c810(struct pci_dev* dev)
 {
 	/* rev 1 ncr53c810 chips don't set the class at all which means

From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH V2 2/4] pci: Enable bus master till the FLR completes
Date: Tue,  6 Aug 2013 15:48:37 +0530
Message-ID: <1375784319-25760-3-git-send-email-vipul@chelsio.com>
References: <1375784319-25760-1-git-send-email-vipul@chelsio.com>
Cc: bhelgaas@google.com, leedom@chelsio.com, tomreu@chelsio.com,
	vipul@chelsio.com, divy@chelsio.com, dm@chelsio.com,
	nirranjan@chelsio.com, eilong@broadcom.com, netdev@vger.kernel.org
To: linux-pci@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1375784319-25760-1-git-send-email-vipul@chelsio.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Casey Leedom <leedom@chelsio.com>

T4 can wedge if there are DMAs in flight within the chip and Bus master has
been disabled.  We need to have it on till the Function Level Reset completes.
T4 can also suffer a Head Of Line blocking problem if MSI-X interrupts are
disabled before the FLR has completed.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
V2: Added pci_wait_for_pending_transaction routine and replaced it at respective
places. Made the patch series for the same.
V2: Used dev->msix_cap directly for capability offset
V2: Removed use of 'rc' variable.

 drivers/pci/quirks.c | 79 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 79 insertions(+)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 2e2ea22..4a64fc4 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -3208,6 +3208,83 @@ reset_complete:
 	return 0;
 }
 
+/*
+ * Device-specific reset method for Chelsio T4-based adapters.
+ */
+static int reset_chelsio_generic_dev(struct pci_dev *dev, int probe)
+{
+	u16 old_command;
+	u16 msix_flags;
+
+	/*
+	 * If this isn't a Chelsio T4-based device, return -ENOTTY indicating
+	 * that we have no device-specific reset method.
+	 */
+	if ((dev->device & 0xf000) != 0x4000)
+		return -ENOTTY;
+
+	/*
+	 * If this is the "probe" phase, return 0 indicating that we can
+	 * reset this device.
+	 */
+	if (probe)
+		return 0;
+
+	/*
+	 * T4 can wedge if their are DMAs in flight within the chip and Bus
+	 * master has been disabled.  We need to have it on till the Function
+	 * Level Reset completes.  (BUS_MASTER is disabled in
+	 * pci_reset_function()).
+	 */
+	pci_read_config_word(dev, PCI_COMMAND, &old_command);
+	pci_write_config_word(dev, PCI_COMMAND,
+			      old_command | PCI_COMMAND_MASTER);
+
+	/*
+	 * Perform the actual device function reset, saving and restoring
+	 * configuration information around the reset.
+	 */
+	pci_save_state(dev);
+
+	/*
+	 * T4 also suffers a Head-Of-Line blocking problem if MSI-X interrupts
+	 * are disabled when an MSI-X interrupt message needs to be delivered.
+	 * So we briefly re-enable MSI-X interrupts for the duration of the
+	 * FLR.  The pci_restore_state() below will restore the original
+	 * MSI-X state.
+	 */
+	pci_read_config_word(dev, dev->msix_cap+PCI_MSIX_FLAGS, &msix_flags);
+	if ((msix_flags & PCI_MSIX_FLAGS_ENABLE) == 0)
+		pci_write_config_word(dev, dev->msix_cap+PCI_MSIX_FLAGS,
+				      msix_flags |
+				      PCI_MSIX_FLAGS_ENABLE |
+				      PCI_MSIX_FLAGS_MASKALL);
+
+	/*
+	 * Start of pcie_flr() code sequence.  This reset code is a copy of
+	 * the guts of pcie_flr() because that's not an exported function.
+	 */
+
+	if (!pci_wait_for_pending_transaction(dev))
+		dev_err(&dev->dev, "transaction is not cleared; proceeding with reset anyway\n");
+
+	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_BCR_FLR);
+	msleep(100);
+
+	/*
+	 * End of pcie_flr() code sequence.
+	 */
+
+	/*
+	 * Restore the configuration information (BAR values, etc.) including
+	 * the original PCI Configuration Space Command word, and return
+	 * success.
+	 */
+	pci_restore_state(dev);
+	pci_write_config_word(dev, PCI_COMMAND, old_command);
+	return 0;
+}
+
 #define PCI_DEVICE_ID_INTEL_82599_SFP_VF   0x10ed
 #define PCI_DEVICE_ID_INTEL_IVB_M_VGA      0x0156
 #define PCI_DEVICE_ID_INTEL_IVB_M2_VGA     0x0166
@@ -3221,6 +3298,8 @@ static const struct pci_dev_reset_methods pci_dev_reset_methods[] = {
 		reset_ivb_igd },
 	{ PCI_VENDOR_ID_INTEL, PCI_ANY_ID,
 		reset_intel_generic_dev },
+	{ PCI_VENDOR_ID_CHELSIO, PCI_ANY_ID,
+		reset_chelsio_generic_dev },
 	{ 0 }
 };
 
-- 
1.8.0

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: shutdown all IRQs and disable MSI-X when suspended
Date: Fri, 29 Sep 2017 17:45:04 -0700
Message-ID: <20170930004507.20072-13-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57175 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752666AbdI3Apv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:51 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

On some platforms with a large number of CPUs, we will allocate many IRQ
vectors. When hibernating, the system will attempt to migrate all of the
vectors back to CPU0 when shutting down all the other CPUs. It is
possible that we have so many vectors that it cannot re-assign them to
CPU0. This is even more likely if we have many devices installed in one
platform.

The end result is failure to hibernate, as it is not possible to
shutdown the CPUs. We can avoid this by disabling MSI-X and clearing our
interrupt scheme when the device is suspended. A more ideal solution
would be some method for the stack to properly handle this for all
drivers, rather than on a case-by-case basis for each driver to fix
itself.

However, until this more ideal solution exists, we can do our part and
shutdown our IRQs during suspend, which should allow systems with
a large number of CPUs to safely suspend or hibernate.

It may be worth investigating if we should shut down even further when
we suspend as it may make the path cleaner, but this was the minimum fix
for the hibernation issue mentioned here.

Testing-hints:
  This affects systems with a large number of CPUs, and with multiple
  devices enabled. Without this change, those platforms are unable to
  hibernate at all.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 68 ++++++++++++++++++++++++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |  2 +-
 2 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 368373459ad5..8a44793d5390 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8354,6 +8354,57 @@ static int i40e_init_interrupt_scheme(struct i40e_pf *pf)
 	return 0;
 }
 
+#ifdef CONFIG_PM
+/**
+ * i40e_restore_interrupt_scheme - Restore the interrupt scheme
+ * @pf: private board data structure
+ *
+ * Restore the interrupt scheme that was cleared when we suspended the
+ * device. This should be called during resume to re-allocate the q_vectors
+ * and reacquire IRQs.
+ */
+static int i40e_restore_interrupt_scheme(struct i40e_pf *pf)
+{
+	int err, i;
+
+	/* We cleared the MSI and MSI-X flags when disabling the old interrupt
+	 * scheme. We need to re-enabled them here in order to attempt to
+	 * re-acquire the MSI or MSI-X vectors
+	 */
+	pf->flags |= (I40E_FLAG_MSIX_ENABLED | I40E_FLAG_MSI_ENABLED);
+
+	err = i40e_init_interrupt_scheme(pf);
+	if (err)
+		return err;
+
+	/* Now that we've re-acquired IRQs, we need to remap the vectors and
+	 * rings together again.
+	 */
+	for (i = 0; i < pf->num_alloc_vsi; i++) {
+		if (pf->vsi[i]) {
+			err = i40e_vsi_alloc_q_vectors(pf->vsi[i]);
+			if (err)
+				goto err_unwind;
+			i40e_vsi_map_rings_to_vectors(pf->vsi[i]);
+		}
+	}
+
+	err = i40e_setup_misc_vector(pf);
+	if (err)
+		goto err_unwind;
+
+	return 0;
+
+err_unwind:
+	while (i--) {
+		if (pf->vsi[i])
+			i40e_vsi_free_q_vectors(pf->vsi[i]);
+	}
+
+	return err;
+}
+#endif /* CONFIG_PM */
+
 /**
  * i40e_setup_misc_vector - Setup the misc vector to handle non queue events
  * @pf: board private structure
@@ -12077,7 +12128,12 @@ static int i40e_suspend(struct device *dev)
 	wr32(hw, I40E_PFPM_APM, (pf->wol_en ? I40E_PFPM_APM_APME_MASK : 0));
 	wr32(hw, I40E_PFPM_WUFC, (pf->wol_en ? I40E_PFPM_WUFC_MAG_MASK : 0));
 
-	i40e_free_misc_vector(pf);
+	/* Clear the interrupt scheme and release our IRQs so that the system
+	 * can safely hibernate even when there are a large number of CPUs.
+	 * Otherwise hibernation might fail when mapping all the vectors back
+	 * to CPU0.
+	 */
+	i40e_clear_interrupt_scheme(pf);
 
 	return 0;
 }
@@ -12090,11 +12146,21 @@ static int i40e_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
+	int err;
 
 	/* If we're not suspended, then there is nothing to do */
 	if (!test_bit(__I40E_SUSPENDED, pf->state))
 		return 0;
 
+	/* We cleared the interrupt scheme when we suspended, so we need to
+	 * restore it now to resume device functionality.
+	 */
+	err = i40e_restore_interrupt_scheme(pf);
+	if (err) {
+		dev_err(&pdev->dev, "Cannot restore interrupt scheme: %d\n",
+			err);
+	}
+
 	clear_bit(__I40E_DOWN, pf->state);
 	i40e_reset_and_rebuild(pf, false, false);
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index c243f9da95ae..80ade6510279 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -46,7 +46,7 @@ static const char i40evf_driver_string[] =
 
 #define DRV_VERSION_MAJOR 3
 #define DRV_VERSION_MINOR 0
-#define DRV_VERSION_BUILD 0
+#define DRV_VERSION_BUILD 1
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD) \
-- 
2.14.1

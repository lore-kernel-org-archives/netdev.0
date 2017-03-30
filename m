From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v6 PATCH 1/7] i40e: Introduce devlink interface
Date: Wed, 29 Mar 2017 17:22:49 -0700
Message-ID: <1490833375-2788-2-git-send-email-sridhar.samudrala@intel.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        alexander.h.duyck@intel.com, anjali.singhai@intel.com,
        jakub.kicinski@netronome.com, gerlitz.or@gmail.com,
        jiri@resnulli.us, sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25988 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932757AbdC3AW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 20:22:58 -0400
In-Reply-To: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add initial devlink support to get/set the mode of SRIOV switch.
This patch sets the default mode as 'legacy' and enables getting the mode
and and setting it to 'legacy'.

The switch mode can be get/set via following 'devlink' commands.

# devlink dev eswitch show pci/0000:42:00.0
pci/0000:42:00.0: mode legacy
# devlink dev eswitch set pci/0000:42:00.0 mode switchdev
devlink answers: Operation not supported
# devlink dev eswitch set pci/0000:42:00.0 mode legacy
# devlink dev eswitch show pci/0000:42:00.0
pci/0000:05:00.0: mode legacy

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/Kconfig          |  1 +
 drivers/net/ethernet/intel/i40e/i40e.h      |  3 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c | 77 ++++++++++++++++++++++++++---
 3 files changed, 75 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 1542a21..ababcae 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -215,6 +215,7 @@ config I40E
 	tristate "Intel(R) Ethernet Controller XL710 Family support"
 	imply PTP_1588_CLOCK
 	depends on PCI
+	depends on MAY_USE_DEVLINK
 	---help---
 	  This driver supports Intel(R) Ethernet Controller XL710 Family of
 	  devices.  For more information on how to identify your adapter, go
diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 421ea57..f788125c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -54,6 +54,8 @@
 #include <linux/clocksource.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
+#include <net/devlink.h>
+
 #include "i40e_type.h"
 #include "i40e_prototype.h"
 #include "i40e_client.h"
@@ -517,6 +519,7 @@ struct i40e_pf {
 	u32 ioremap_len;
 	u32 fd_inv;
 	u16 phy_led_val;
+	enum devlink_eswitch_mode eswitch_mode;
 };
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1a4643c..afcf14d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10823,6 +10823,57 @@ static void i40e_get_platform_mac_addr(struct pci_dev *pdev, struct i40e_pf *pf)
 }
 
 /**
+ * i40e_devlink_eswitch_mode_get
+ *
+ * @devlink: pointer to devlink struct
+ * @mode: sr-iov switch mode pointer
+ *
+ * Returns the switch mode of the associated PF in the @mode pointer.
+ */
+static int i40e_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
+{
+	struct i40e_pf *pf = devlink_priv(devlink);
+
+	*mode = pf->eswitch_mode;
+
+	return 0;
+}
+
+/**
+ * i40e_devlink_eswitch_mode_set
+ *
+ * @devlink: pointer to devlink struct
+ * @mode: sr-iov switch mode
+ *
+ * Set the switch mode of the associated PF.
+ * Returns 0 on success and -EOPNOTSUPP on error.
+ */
+static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
+{
+	struct i40e_pf *pf = devlink_priv(devlink);
+	int err = 0;
+
+	if (mode == pf->eswitch_mode)
+		goto done;
+
+	switch (mode) {
+	case DEVLINK_ESWITCH_MODE_LEGACY:
+		pf->eswitch_mode = mode;
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+done:
+	return err;
+}
+
+static const struct devlink_ops i40e_devlink_ops = {
+	.eswitch_mode_get = i40e_devlink_eswitch_mode_get,
+	.eswitch_mode_set = i40e_devlink_eswitch_mode_set,
+};
+
+/**
  * i40e_probe - Device initialization routine
  * @pdev: PCI device information struct
  * @ent: entry in i40e_pci_tbl
@@ -10839,6 +10890,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct i40e_pf *pf;
 	struct i40e_hw *hw;
 	static u16 pfs_found;
+	struct devlink *devlink;
 	u16 wol_nvm_bits;
 	u16 link_status;
 	int err, globr_probe = 1;
@@ -10877,11 +10929,15 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * the Admin Queue structures and then querying for the
 	 * device's current profile information.
 	 */
-	pf = kzalloc(sizeof(*pf), GFP_KERNEL);
-	if (!pf) {
+
+	devlink = devlink_alloc(&i40e_devlink_ops, sizeof(*pf));
+	if (!devlink) {
+		dev_err(&pdev->dev, "devlink_alloc failed\n");
 		err = -ENOMEM;
-		goto err_pf_alloc;
+		goto err_devlink_alloc;
 	}
+
+	pf = devlink_priv(devlink);
 	pf->next_vsi = 0;
 	pf->pdev = pdev;
 	set_bit(__I40E_DOWN, &pf->state);
@@ -11080,6 +11136,11 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	device_set_wakeup_enable(&pf->pdev->dev, pf->wol_en);
 
 	/* set up the main switch operations */
+	pf->eswitch_mode = DEVLINK_ESWITCH_MODE_LEGACY;
+	err = devlink_register(devlink, &pdev->dev);
+	if (err)
+		goto err_devlink_register;
+
 	i40e_determine_queue_usage(pf);
 	err = i40e_init_interrupt_scheme(pf);
 	if (err)
@@ -11339,6 +11400,8 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_switch_setup:
 	i40e_reset_interrupt_capability(pf);
 	del_timer_sync(&pf->service_timer);
+	devlink_unregister(devlink);
+err_devlink_register:
 err_mac_addr:
 err_configure_lan_hmc:
 	(void)i40e_shutdown_lan_hmc(hw);
@@ -11349,8 +11412,8 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_pf_reset:
 	iounmap(hw->hw_addr);
 err_ioremap:
-	kfree(pf);
-err_pf_alloc:
+	devlink_free(devlink);
+err_devlink_alloc:
 	pci_disable_pcie_error_reporting(pdev);
 	pci_release_mem_regions(pdev);
 err_pci_reg:
@@ -11372,6 +11435,7 @@ static void i40e_remove(struct pci_dev *pdev)
 {
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 	struct i40e_hw *hw = &pf->hw;
+	struct devlink *devlink = priv_to_devlink(pf);
 	i40e_status ret_code;
 	int i;
 
@@ -11458,7 +11522,8 @@ static void i40e_remove(struct pci_dev *pdev)
 	kfree(pf->vsi);
 
 	iounmap(hw->hw_addr);
-	kfree(pf);
+	devlink_unregister(devlink);
+	devlink_free(devlink);
 	pci_release_mem_regions(pdev);
 
 	pci_disable_pcie_error_reporting(pdev);
-- 
1.8.3.1

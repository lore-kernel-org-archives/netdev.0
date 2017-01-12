From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v4 PATCH 1/7] i40e: Introduce devlink interface.
Date: Thu, 12 Jan 2017 14:35:04 -0800
Message-ID: <1484260510-9162-2-git-send-email-sridhar.samudrala@intel.com>
References: <1484260510-9162-1-git-send-email-sridhar.samudrala@intel.com>
To: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, scott.d.peterson@intel.com,
        gerlitz.or@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:60232 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751134AbdALWfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 17:35:16 -0500
In-Reply-To: <1484260510-9162-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add initial devlink support to get/set the mode of SRIOV switch.
This patch sets the default mode as 'legacy' and enables getting the mode
and and setting it to 'legacy'.

The switch mode can be get/set via following 'devlink' commands.

# devlink dev eswitch show pci/0000:05:00.0
pci/0000:05:00.0: mode legacy
# devlink dev eswitch set pci/0000:05:00.0 mode switchdev
devlink answers: Operation not supported
# devlink dev eswitch set pci/0000:05:00.0 mode legacy
# devlink dev eswitch show pci/0000:05:00.0
pci/0000:05:00.0: mode legacy

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/Kconfig          |  1 +
 drivers/net/ethernet/intel/i40e/i40e.h      |  3 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c | 80 ++++++++++++++++++++++++++---
 3 files changed, 76 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 1349b45..0dbb87e 100644
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
index 9b51026..331a1e0 100644
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
 #ifdef I40E_FCOE
@@ -476,6 +478,7 @@ struct i40e_pf {
 	u32 ioremap_len;
 	u32 fd_inv;
 	u16 phy_led_val;
+	enum devlink_eswitch_mode eswitch_mode;
 };
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b685b55..ac49f89 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11294,6 +11294,57 @@ static void i40e_get_platform_mac_addr(struct pci_dev *pdev, struct i40e_pf *pf)
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
@@ -11310,6 +11361,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct i40e_pf *pf;
 	struct i40e_hw *hw;
 	static u16 pfs_found;
+	struct devlink *devlink;
 	u16 wol_nvm_bits;
 	u16 link_status;
 	int err;
@@ -11343,20 +11395,28 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_enable_pcie_error_reporting(pdev);
 	pci_set_master(pdev);
 
+	devlink = devlink_alloc(&i40e_devlink_ops, sizeof(*pf));
+	if (!devlink) {
+		dev_err(&pdev->dev, "devlink_alloc failed\n");
+		err = -ENOMEM;
+		goto err_devlink_alloc;
+	}
+
 	/* Now that we have a PCI connection, we need to do the
 	 * low level device setup.  This is primarily setting up
 	 * the Admin Queue structures and then querying for the
 	 * device's current profile information.
 	 */
-	pf = kzalloc(sizeof(*pf), GFP_KERNEL);
-	if (!pf) {
-		err = -ENOMEM;
-		goto err_pf_alloc;
-	}
+	pf = devlink_priv(devlink);
 	pf->next_vsi = 0;
 	pf->pdev = pdev;
 	set_bit(__I40E_DOWN, &pf->state);
 
+	pf->eswitch_mode = DEVLINK_ESWITCH_MODE_LEGACY;
+	err = devlink_register(devlink, &pdev->dev);
+	if (err)
+		goto err_devlink_register;
+
 	hw = &pf->hw;
 	hw->back = pf;
 
@@ -11830,8 +11890,10 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_pf_reset:
 	iounmap(hw->hw_addr);
 err_ioremap:
-	kfree(pf);
-err_pf_alloc:
+	devlink_unregister(devlink);
+err_devlink_register:
+	devlink_free(devlink);
+err_devlink_alloc:
 	pci_disable_pcie_error_reporting(pdev);
 	pci_release_mem_regions(pdev);
 err_pci_reg:
@@ -11853,6 +11915,7 @@ static void i40e_remove(struct pci_dev *pdev)
 {
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 	struct i40e_hw *hw = &pf->hw;
+	struct devlink *devlink = priv_to_devlink(pf);
 	i40e_status ret_code;
 	int i;
 
@@ -11941,7 +12004,8 @@ static void i40e_remove(struct pci_dev *pdev)
 	kfree(pf->vsi);
 
 	iounmap(hw->hw_addr);
-	kfree(pf);
+	devlink_unregister(devlink);
+	devlink_free(devlink);
 	pci_release_mem_regions(pdev);
 
 	pci_disable_pcie_error_reporting(pdev);
-- 
2.5.5

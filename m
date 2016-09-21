From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: Introduce devlink interface
Date: Tue, 20 Sep 2016 20:43:40 -0700
Message-ID: <1474429432-102772-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:33017 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753010AbcIUDn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:56 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

Add initial devlink support to set/get the mode of SRIOV switch.
By default the switch mode is set to 'switchdev' as VF Port representors
are created by default.
This patch allows the mode to be set to 'legacy' to disable creation of
VF Port representor netdevs.

With smode support in iproute2 'devlink' utility, switch mode can be set
and get via following commands.

    # devlink dev smode pci/0000:05:00.0
    mode: switchdev
    # devlink dev set pci/0000:05:00.0 smode legacy
    # devlink dev smode pci/0000:05:00.0
    mode: legacy

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig                 |  1 +
 drivers/net/ethernet/intel/i40e/i40e.h             |  3 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 91 ++++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  6 +-
 4 files changed, 91 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index c0e1743..2ede229 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -215,6 +215,7 @@ config I40E
 	tristate "Intel(R) Ethernet Controller XL710 Family support"
 	select PTP_1588_CLOCK
 	depends on PCI
+	depends on MAY_USE_DEVLINK
 	---help---
 	  This driver supports Intel(R) Ethernet Controller XL710 Family of
 	  devices.  For more information on how to identify your adapter, go
diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 13b1f75..6e211f2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -53,6 +53,8 @@
 #include <linux/clocksource.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
+#include <net/devlink.h>
+
 #include "i40e_type.h"
 #include "i40e_prototype.h"
 #ifdef I40E_FCOE
@@ -442,6 +444,7 @@ struct i40e_pf {
 	u32 ioremap_len;
 	u32 fd_inv;
 	u16 phy_led_val;
+	enum devlink_eswitch_mode eswitch_mode;
 };
 
 enum i40e_filter_state {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 61b0fc4..b3e9ce4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10721,6 +10721,68 @@ static void i40e_get_platform_mac_addr(struct pci_dev *pdev, struct i40e_pf *pf)
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
+	struct i40e_vf *vf;
+	int i, err = 0;
+
+	if (mode == pf->eswitch_mode)
+		goto done;
+
+	switch (mode) {
+	case DEVLINK_ESWITCH_MODE_LEGACY:
+		for (i = 0; i < pf->num_alloc_vfs; i++) {
+			vf = &(pf->vf[i]);
+			i40e_free_vf_netdev(vf);
+		}
+		pf->eswitch_mode = mode;
+		break;
+	case DEVLINK_ESWITCH_MODE_SWITCHDEV:
+		pf->eswitch_mode = mode;
+		for (i = 0; i < pf->num_alloc_vfs; i++) {
+			vf = &(pf->vf[i]);
+			i40e_alloc_vf_netdev(vf, i);
+		}
+		break;
+	default:
+		err = -EOPNOTSUPP;
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
@@ -10737,6 +10799,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct i40e_pf *pf;
 	struct i40e_hw *hw;
 	static u16 pfs_found;
+	struct devlink *devlink;
 	u16 wol_nvm_bits;
 	u16 link_status;
 	int err;
@@ -10770,20 +10833,28 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
 
+	pf->eswitch_mode = DEVLINK_ESWITCH_MODE_SWITCHDEV;
+	err = devlink_register(devlink, &pdev->dev);
+	if (err)
+		goto err_devlink_register;
+
 	hw = &pf->hw;
 	hw->back = pf;
 
@@ -11254,8 +11325,10 @@ err_adminq_setup:
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
@@ -11277,6 +11350,7 @@ static void i40e_remove(struct pci_dev *pdev)
 {
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 	struct i40e_hw *hw = &pf->hw;
+	struct devlink *devlink = priv_to_devlink(pf);
 	i40e_status ret_code;
 	int i;
 
@@ -11367,7 +11441,8 @@ static void i40e_remove(struct pci_dev *pdev)
 	kfree(pf->vsi);
 
 	iounmap(hw->hw_addr);
-	kfree(pf);
+	devlink_unregister(devlink);
+	devlink_free(devlink);
 	pci_release_mem_regions(pdev);
 
 	pci_disable_pcie_error_reporting(pdev);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index cacb797..f98aa84 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1131,7 +1131,8 @@ void i40e_free_vfs(struct i40e_pf *pf)
 		/* disable qp mappings */
 		i40e_disable_vf_mappings(&pf->vf[i]);
 
-		i40e_free_vf_netdev(&pf->vf[i]);
+		if (pf->eswitch_mode == DEVLINK_ESWITCH_MODE_SWITCHDEV)
+			i40e_free_vf_netdev(&pf->vf[i]);
 	}
 
 	kfree(pf->vf);
@@ -1199,7 +1200,8 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 		/* VF resources get allocated during reset */
 		i40e_reset_vf(&vfs[i], false);
 
-		i40e_alloc_vf_netdev(&vfs[i], i);
+		if (pf->eswitch_mode == DEVLINK_ESWITCH_MODE_SWITCHDEV)
+			i40e_alloc_vf_netdev(&vfs[i], i);
 
 	}
 	pf->num_alloc_vfs = num_alloc_vfs;
-- 
2.7.4

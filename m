From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] ixgbe: Add module parameter to allow untested and unsafe SFP+ modules
Date: Wed,  1 Feb 2012 11:19:21 -0800
Message-ID: <1328123961-17237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11972 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756548Ab2BATTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 14:19:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

The X520 family of network devices, with the 82599 chip, support a
small number of Intel-verified SFP+ modules on their NICs.  To maintain
stability and quality, the current devices restrict untested 3rd party
SFP+ modules.

This patch introduces a module parameter for ixgbe to allow these untested
modules at the user's peril.  It also includes a warning to the syslog
alerting users that the modules aren't supported, and results may
vary.

CC: Jesper Dangaard Brouer <hawk@comx.dk>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    8 ++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  |   14 +++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    1 +
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1ee5d0f..2e8e764 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -131,6 +131,11 @@ MODULE_PARM_DESC(max_vfs,
 		 "Maximum number of virtual functions to allocate per physical function");
 #endif /* CONFIG_PCI_IOV */
 
+static unsigned int allow_unsupported_sfp;
+module_param(allow_unsupported_sfp, uint, 0);
+MODULE_PARM_DESC(allow_unsupported_sfp,
+		 "Allow unsupported and untested SFP+ modules on 82599-based adapters");
+
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
@@ -7489,6 +7494,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			e_crit(probe, "Fan has stopped, replace the adapter\n");
 	}
 
+	if (allow_unsupported_sfp)
+		hw->allow_unsupported_sfp = allow_unsupported_sfp;
+
 	/* reset_hw fills in the perm_addr as well */
 	hw->phy.reset_if_overtemp = true;
 	err = hw->mac.ops.reset_hw(hw);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 7cf1e1f..29fda97 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -834,6 +834,7 @@ out:
  **/
 s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 {
+	struct ixgbe_adapter *adapter = hw->back;
 	s32 status = IXGBE_ERR_PHY_ADDR_INVALID;
 	u32 vendor_oui = 0;
 	enum ixgbe_sfp_type stored_sfp_type = hw->phy.sfp_type;
@@ -1068,9 +1069,16 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 			if (hw->phy.type == ixgbe_phy_sfp_intel) {
 				status = 0;
 			} else {
-				hw_dbg(hw, "SFP+ module not supported\n");
-				hw->phy.type = ixgbe_phy_sfp_unsupported;
-				status = IXGBE_ERR_SFP_NOT_SUPPORTED;
+				if (hw->allow_unsupported_sfp) {
+					e_warn(drv, "WARNING: Intel (R) Network Connections are quality tested using Intel (R) Ethernet Optics.  Using untested modules is not supported and may cause unstable operation or damage to the module or the adapter.  Intel Corporation is not responsible for any harm caused by using untested modules.");
+					status = 0;
+				} else {
+					hw_dbg(hw,
+					       "SFP+ module not supported\n");
+					hw->phy.type =
+						ixgbe_phy_sfp_unsupported;
+					status = IXGBE_ERR_SFP_NOT_SUPPORTED;
+				}
 			}
 		} else {
 			status = 0;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 775602e..2dc5e71 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2892,6 +2892,7 @@ struct ixgbe_hw {
 	u8				revision_id;
 	bool				adapter_stopped;
 	bool				force_full_reset;
+	bool				allow_unsupported_sfp;
 };
 
 struct ixgbe_info {
-- 
1.7.7.6

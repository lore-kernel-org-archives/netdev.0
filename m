From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] ixgbe: Drop probe_vf and merge functionality into ixgbe_enable_sriov
Date: Sat, 21 Jul 2012 16:08:50 -0700
Message-ID: <1342912142-11130-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11129 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab2GUXJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:07 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This is meant to fix a bug in which we were not checking for pre-existing
VFs if we were not setting the max_vfs value at driver load.  What happens
now is that we always call ixgbe_enable_sriov and this checks for
pre-existing VFs ore requested VFs prior to deciding on no SR-IOV.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c   |    3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |   33 +++++++-----------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   24 ++++++++++++-----
 3 files changed, 28 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 38d1b65..3ff5aa8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -1061,8 +1061,7 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	}
 	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
 	adapter->atr_sample_rate = 0;
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
-		ixgbe_disable_sriov(adapter);
+	ixgbe_disable_sriov(adapter);
 
 	adapter->ring_feature[RING_F_RSS].limit = 1;
 	ixgbe_set_num_queues(adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f4e53c1..24f2b45 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4490,6 +4490,12 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->fc.send_xon = true;
 	hw->fc.disable_fc_autoneg = false;
 
+#ifdef CONFIG_PCI_IOV
+	/* assign number of SR-IOV VFs */
+	if (hw->mac.type != ixgbe_mac_82598EB)
+		adapter->num_vfs = (max_vfs > 63) ? 0 : max_vfs;
+
+#endif
 	/* enable itr by default in dynamic mode */
 	adapter->rx_itr_setting = 1;
 	adapter->tx_itr_setting = 1;
@@ -6942,26 +6948,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fdb_dump		= ixgbe_ndo_fdb_dump,
 };
 
-static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
-				     const struct ixgbe_info *ii)
-{
-#ifdef CONFIG_PCI_IOV
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	if (hw->mac.type == ixgbe_mac_82598EB)
-		return;
-
-	/* The 82599 supports up to 64 VFs per physical function
-	 * but this implementation limits allocation to 63 so that
-	 * basic networking resources are still available to the
-	 * physical function.  If the user requests greater thn
-	 * 63 VFs then it is an error - reset to default of zero.
-	 */
-	adapter->num_vfs = (max_vfs > 63) ? 0 : max_vfs;
-	ixgbe_enable_sriov(adapter, ii);
-#endif /* CONFIG_PCI_IOV */
-}
-
 /**
  * ixgbe_wol_supported - Check whether device supports WoL
  * @hw: hw specific details
@@ -7206,8 +7192,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_sw_init;
 	}
 
-	ixgbe_probe_vf(adapter, ii);
+#ifdef CONFIG_PCI_IOV
+	ixgbe_enable_sriov(adapter, ii);
 
+#endif
 	netdev->features = NETIF_F_SG |
 			   NETIF_F_IP_CSUM |
 			   NETIF_F_IPV6_CSUM |
@@ -7411,8 +7399,7 @@ err_register:
 	ixgbe_release_hw_control(adapter);
 	ixgbe_clear_interrupt_scheme(adapter);
 err_sw_init:
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
-		ixgbe_disable_sriov(adapter);
+	ixgbe_disable_sriov(adapter);
 	adapter->flags2 &= ~IXGBE_FLAG2_SEARCH_FOR_SFP;
 	iounmap(hw->hw_addr);
 err_ioremap:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index a825d48..593fdd5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -82,7 +82,6 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 			 const struct ixgbe_info *ii)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int err = 0;
 	int num_vf_macvlans, i;
 	struct vf_macvlans *mv_list;
 	int pre_existing_vfs = 0;
@@ -106,10 +105,21 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 			 "enabled for this device - Please reload all "
 			 "VF drivers to avoid spoofed packet errors\n");
 	} else {
+		int err;
+		/*
+		 * The 82599 supports up to 64 VFs per physical function
+		 * but this implementation limits allocation to 63 so that
+		 * basic networking resources are still available to the
+		 * physical function.  If the user requests greater thn
+		 * 63 VFs then it is an error - reset to default of zero.
+		 */
+		adapter->num_vfs = min_t(unsigned int, adapter->num_vfs, 63);
+
 		err = pci_enable_sriov(adapter->pdev, adapter->num_vfs);
 		if (err) {
 			e_err(probe, "Failed to enable PCI sriov: %d\n", err);
-			goto err_novfs;
+			adapter->num_vfs = 0;
+			return;
 		}
 	}
 
@@ -193,11 +203,7 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 	/* Oh oh */
 	e_err(probe, "Unable to allocate memory for VF Data Storage - "
 	      "SRIOV disabled\n");
-	pci_disable_sriov(adapter->pdev);
-
-err_novfs:
-	adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
-	adapter->num_vfs = 0;
+	ixgbe_disable_sriov(adapter);
 }
 #endif /* #ifdef CONFIG_PCI_IOV */
 
@@ -219,6 +225,10 @@ void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 	kfree(adapter->mv_list);
 	adapter->mv_list = NULL;
 
+	/* if SR-IOV is already disabled then there is nothing to do */
+	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
+		return;
+
 #ifdef CONFIG_PCI_IOV
 	/* disable iov and allow time for transactions to clear */
 	pci_disable_sriov(adapter->pdev);
-- 
1.7.10.4

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 12/13] ixgbe: Add SR-IOV features to main module
Date: Sat, 09 Jan 2010 04:26:46 -0800
Message-ID: <20100109122645.4462.30086.stgit@localhost.localdomain>
References: <20100109120719.4462.66489.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:57221 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751745Ab0AIM1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 07:27:05 -0500
In-Reply-To: <20100109120719.4462.66489.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Adds SR-IOV features supported by the 82599 controller to the main driver
module.  If the CONFIG_PCI_IOV kernel option is selected then the SR-IOV
features are enabled.  Use the max_vfs module option to allocate up to 63
virtual functions per physical port.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  278 +++++++++++++++++++++++++++++++++++++++-
 1 files changed, 268 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c8cd96e..5d51725 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -45,6 +45,7 @@
 #include "ixgbe.h"
 #include "ixgbe_common.h"
 #include "ixgbe_dcb_82599.h"
+#include "ixgbe_sriov.h"
 
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
@@ -124,6 +125,13 @@ static struct notifier_block dca_notifier = {
 };
 #endif
 
+#ifdef CONFIG_PCI_IOV
+static unsigned int max_vfs;
+module_param(max_vfs, uint, 0);
+MODULE_PARM_DESC(max_vfs, "Maximum number of virtual functions to allocate "
+                 "per physical function");
+#endif /* CONFIG_PCI_IOV */
+
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
@@ -131,6 +139,41 @@ MODULE_VERSION(DRV_VERSION);
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
 
+static inline void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 gcr;
+	u32 gpie;
+	u32 vmdctl;
+
+#ifdef CONFIG_PCI_IOV
+	/* disable iov and allow time for transactions to clear */
+	pci_disable_sriov(adapter->pdev);
+#endif
+
+	/* turn off device IOV mode */
+	gcr = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
+	gcr &= ~(IXGBE_GCR_EXT_SRIOV);
+	IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, gcr);
+	gpie = IXGBE_READ_REG(hw, IXGBE_GPIE);
+	gpie &= ~IXGBE_GPIE_VTMODE_MASK;
+	IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
+
+	/* set default pool back to 0 */
+	vmdctl = IXGBE_READ_REG(hw, IXGBE_VT_CTL);
+	vmdctl &= ~IXGBE_VT_CTL_POOL_MASK;
+	IXGBE_WRITE_REG(hw, IXGBE_VT_CTL, vmdctl);
+
+	/* take a breather then clean up driver data */
+	msleep(100);
+	if (adapter->vfinfo)
+		kfree(adapter->vfinfo);
+	adapter->vfinfo = NULL;
+
+	adapter->num_vfs = 0;
+	adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
+}
+
 static void ixgbe_release_hw_control(struct ixgbe_adapter *adapter)
 {
 	u32 ctrl_ext;
@@ -1025,7 +1068,12 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 
 	/* set up to autoclear timer, and the vectors */
 	mask = IXGBE_EIMS_ENABLE_MASK;
-	mask &= ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC);
+	if (adapter->num_vfs)
+		mask &= ~(IXGBE_EIMS_OTHER |
+			  IXGBE_EIMS_MAILBOX |
+			  IXGBE_EIMS_LSC);
+	else
+		mask &= ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC, mask);
 }
 
@@ -1254,6 +1302,9 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);
 
+	if (eicr & IXGBE_EICR_MAILBOX)
+		ixgbe_msg_task(adapter);
+
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		ixgbe_check_fan_failure(adapter, eicr);
 
@@ -1768,6 +1819,8 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 		mask |= IXGBE_EIMS_ECC;
 		mask |= IXGBE_EIMS_GPI_SDP1;
 		mask |= IXGBE_EIMS_GPI_SDP2;
+		if (adapter->num_vfs)
+			mask |= IXGBE_EIMS_MAILBOX;
 	}
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
 	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
@@ -1776,6 +1829,11 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
 	ixgbe_irq_enable_queues(adapter, ~0);
 	IXGBE_WRITE_FLUSH(&adapter->hw);
+
+	if (adapter->num_vfs > 32) {
+		u32 eitrsel = (1 << (adapter->num_vfs - 32)) - 1;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITRSEL, eitrsel);
+	}
 }
 
 /**
@@ -1905,6 +1963,8 @@ static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFF0000);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(0), ~0);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1), ~0);
+		if (adapter->num_vfs > 32)
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITRSEL, 0);
 	}
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
@@ -1989,18 +2049,32 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 
 	if (hw->mac.type == ixgbe_mac_82599EB) {
 		u32 rttdcs;
+		u32 mask;
 
 		/* disable the arbiter while setting MTQC */
 		rttdcs = IXGBE_READ_REG(hw, IXGBE_RTTDCS);
 		rttdcs |= IXGBE_RTTDCS_ARBDIS;
 		IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, rttdcs);
 
-		/* We enable 8 traffic classes, DCB only */
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
-			IXGBE_WRITE_REG(hw, IXGBE_MTQC, (IXGBE_MTQC_RT_ENA |
-			                IXGBE_MTQC_8TC_8TQ));
-		else
+		/* set transmit pool layout */
+		mask = (IXGBE_FLAG_SRIOV_ENABLED | IXGBE_FLAG_DCB_ENABLED);
+		switch (adapter->flags & mask) {
+
+		case (IXGBE_FLAG_SRIOV_ENABLED):
+			IXGBE_WRITE_REG(hw, IXGBE_MTQC,
+					(IXGBE_MTQC_VT_ENA | IXGBE_MTQC_64VF));
+			break;
+
+		case (IXGBE_FLAG_DCB_ENABLED):
+			/* We enable 8 traffic classes, DCB only */
+			IXGBE_WRITE_REG(hw, IXGBE_MTQC,
+				      (IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ));
+			break;
+
+		default:
 			IXGBE_WRITE_REG(hw, IXGBE_MTQC, IXGBE_MTQC_64Q_1PB);
+			break;
+		}
 
 		/* re-eable the arbiter */
 		rttdcs &= ~IXGBE_RTTDCS_ARBDIS;
@@ -2059,12 +2133,16 @@ static u32 ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 #ifdef CONFIG_IXGBE_DCB
 				 | IXGBE_FLAG_DCB_ENABLED
 #endif
+				 | IXGBE_FLAG_SRIOV_ENABLED
 				);
 
 	switch (mask) {
 	case (IXGBE_FLAG_RSS_ENABLED):
 		mrqc = IXGBE_MRQC_RSSEN;
 		break;
+	case (IXGBE_FLAG_SRIOV_ENABLED):
+		mrqc = IXGBE_MRQC_VMDQEN;
+		break;
 #ifdef CONFIG_IXGBE_DCB
 	case (IXGBE_FLAG_DCB_ENABLED):
 		mrqc = IXGBE_MRQC_RT8TCEN;
@@ -2145,7 +2223,9 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	int rx_buf_len;
 
 	/* Decide whether to use packet split mode or not */
-	adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
+	/* Do not use packet split if we're in SR-IOV Mode */
+	if (!adapter->num_vfs)
+		adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
 
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
@@ -2157,7 +2237,9 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			              IXGBE_PSRTYPE_IPV4HDR |
 			              IXGBE_PSRTYPE_IPV6HDR |
 			              IXGBE_PSRTYPE_L2HDR;
-			IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(0), psrtype);
+			IXGBE_WRITE_REG(hw,
+					IXGBE_PSRTYPE(adapter->num_vfs),
+					psrtype);
 		}
 	} else {
 		if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
@@ -2243,6 +2325,30 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
 	}
 
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		u32 vt_reg_bits;
+		u32 reg_offset, vf_shift;
+		u32 vmdctl = IXGBE_READ_REG(hw, IXGBE_VT_CTL);
+		vt_reg_bits = IXGBE_VMD_CTL_VMDQ_EN
+			| IXGBE_VT_CTL_REPLEN;
+		vt_reg_bits |= (adapter->num_vfs <<
+				IXGBE_VT_CTL_POOL_SHIFT);
+		IXGBE_WRITE_REG(hw, IXGBE_VT_CTL, vmdctl | vt_reg_bits);
+		IXGBE_WRITE_REG(hw, IXGBE_MRQC, 0);
+
+		vf_shift = adapter->num_vfs % 32;
+		reg_offset = adapter->num_vfs / 32;
+		IXGBE_WRITE_REG(hw, IXGBE_VFRE(0), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_VFRE(1), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_VFTE(0), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_VFTE(1), 0);
+		/* Enable only the PF's pool for Tx/Rx */
+		IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), (1 << vf_shift));
+		IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (1 << vf_shift));
+		IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
+		ixgbe_set_vmolr(hw, adapter->num_vfs);
+	}
+
 	/* Program MRQC for the distribution of queues */
 	mrqc = ixgbe_setup_mrqc(adapter);
 
@@ -2274,6 +2380,20 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	}
 	IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
 
+	if (adapter->num_vfs) {
+		u32 reg;
+
+		/* Map PF MAC address in RAR Entry 0 to first pool
+		 * following VFs */
+		hw->mac.ops.set_vmdq(hw, 0, adapter->num_vfs);
+
+		/* Set up VF register offsets for selected VT Mode, i.e.
+		 * 64 VFs for SR-IOV */
+		reg = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
+		reg |= IXGBE_GCR_EXT_SRIOV;
+		IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, reg);
+	}
+
 	rxcsum = IXGBE_READ_REG(hw, IXGBE_RXCSUM);
 
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED ||
@@ -2454,6 +2574,8 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		addr_list = netdev->mc_list->dmi_addr;
 	hw->mac.ops.update_mc_addr_list(hw, addr_list, addr_count,
 	                                ixgbe_addr_list_itr);
+	if (adapter->num_vfs)
+		ixgbe_restore_vf_multicasts(adapter);
 }
 
 static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
@@ -2714,6 +2836,10 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 			/* MSI only */
 			gpie = 0;
 		}
+		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+			gpie &= ~IXGBE_GPIE_VTMODE_MASK;
+			gpie |= IXGBE_GPIE_VTMODE_64;
+		}
 		/* XXX: to interrupt immediately for EICS writes, enable this */
 		/* gpie |= IXGBE_GPIE_EIMEN; */
 		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
@@ -2788,6 +2914,18 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
 		txdctl |= IXGBE_TXDCTL_ENABLE;
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
+		if (hw->mac.type == ixgbe_mac_82599EB) {
+			int wait_loop = 10;
+			/* poll for Tx Enable ready */
+			do {
+				msleep(1);
+				txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
+			} while (--wait_loop &&
+			         !(txdctl & IXGBE_TXDCTL_ENABLE));
+			if (!wait_loop)
+				DPRINTK(DRV, ERR, "Could not enable "
+				        "Tx Queue %d\n", j);
+		}
 	}
 
 	for (i = 0; i < num_rx_rings; i++) {
@@ -2923,7 +3061,8 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	}
 
 	/* reprogram the RAR[0] in case user changed it. */
-	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
+	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, adapter->num_vfs,
+			    IXGBE_RAH_AV);
 }
 
 /**
@@ -3291,6 +3430,19 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 }
 
 #endif /* IXGBE_FCOE */
+/**
+ * ixgbe_set_sriov_queues: Allocate queues for IOV use
+ * @adapter: board private structure to initialize
+ *
+ * IOV doesn't actually use anything, so just NAK the
+ * request for now and let the other queue routines
+ * figure out what to do.
+ */
+static inline bool ixgbe_set_sriov_queues(struct ixgbe_adapter *adapter)
+{
+	return false;
+}
+
 /*
  * ixgbe_set_num_queues: Allocate queues for device, feature dependant
  * @adapter: board private structure to initialize
@@ -3304,6 +3456,15 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 {
+	/* Start with base case */
+	adapter->num_rx_queues = 1;
+	adapter->num_tx_queues = 1;
+	adapter->num_rx_pools = adapter->num_rx_queues;
+	adapter->num_rx_queues_per_pool = 1;
+
+	if (ixgbe_set_sriov_queues(adapter))
+		return;
+
 #ifdef IXGBE_FCOE
 	if (ixgbe_set_fcoe_queues(adapter))
 		goto done;
@@ -3575,6 +3736,24 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 
 #endif /* IXGBE_FCOE */
 /**
+ * ixgbe_cache_ring_sriov - Descriptor ring to register mapping for sriov
+ * @adapter: board private structure to initialize
+ *
+ * SR-IOV doesn't use any descriptor rings but changes the default if
+ * no other mapping is used.
+ *
+ */
+static inline bool ixgbe_cache_ring_sriov(struct ixgbe_adapter *adapter)
+{
+	adapter->rx_ring[0].reg_idx = adapter->num_vfs * 2;
+	adapter->tx_ring[0].reg_idx = adapter->num_vfs * 2;
+	if (adapter->num_vfs)
+		return true;
+	else
+		return false;
+}
+
+/**
  * ixgbe_cache_ring_register - Descriptor ring to register mapping
  * @adapter: board private structure to initialize
  *
@@ -3591,6 +3770,9 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 	adapter->rx_ring[0].reg_idx = 0;
 	adapter->tx_ring[0].reg_idx = 0;
 
+	if (ixgbe_cache_ring_sriov(adapter))
+		return;
+
 #ifdef IXGBE_FCOE
 	if (ixgbe_cache_ring_fcoe(adapter))
 		return;
@@ -3700,6 +3882,9 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
 	adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
 	adapter->atr_sample_rate = 0;
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		ixgbe_disable_sriov(adapter);
+
 	ixgbe_set_num_queues(adapter);
 
 	err = pci_enable_msi(adapter->pdev);
@@ -5484,7 +5669,8 @@ static int ixgbe_set_mac(struct net_device *netdev, void *p)
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
 
-	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
+	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, adapter->num_vfs,
+			    IXGBE_RAH_AV);
 
 	return 0;
 }
@@ -5617,6 +5803,61 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 #endif /* IXGBE_FCOE */
 };
 
+static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
+			   const struct ixgbe_info *ii)
+{
+#ifdef CONFIG_PCI_IOV
+	struct ixgbe_hw *hw = &adapter->hw;
+	int err;
+
+	if (hw->mac.type != ixgbe_mac_82599EB || !max_vfs)
+		return;
+
+	/* The 82599 supports up to 64 VFs per physical function
+	 * but this implementation limits allocation to 63 so that
+	 * basic networking resources are still available to the
+	 * physical function
+	 */
+	adapter->num_vfs = (max_vfs > 63) ? 63 : max_vfs;
+	adapter->flags |= IXGBE_FLAG_SRIOV_ENABLED;
+	err = pci_enable_sriov(adapter->pdev, adapter->num_vfs);
+	if (err) {
+		DPRINTK(PROBE, ERR,
+			"Failed to enable PCI sriov: %d\n", err);
+		goto err_novfs;
+	}
+	/* If call to enable VFs succeeded then allocate memory
+	 * for per VF control structures.
+	 */
+	adapter->vfinfo =
+		kcalloc(adapter->num_vfs,
+			sizeof(struct vf_data_storage), GFP_KERNEL);
+	if (adapter->vfinfo) {
+		/* Now that we're sure SR-IOV is enabled
+		 * and memory allocated set up the mailbox parameters
+		 */
+		ixgbe_init_mbx_params_pf(hw);
+		memcpy(&hw->mbx.ops, ii->mbx_ops,
+		       sizeof(hw->mbx.ops));
+
+		/* Disable RSC when in SR-IOV mode */
+		adapter->flags2 &= ~(IXGBE_FLAG2_RSC_CAPABLE |
+				     IXGBE_FLAG2_RSC_ENABLED);
+		return;
+	}
+
+	/* Oh oh */
+	DPRINTK(PROBE, ERR,
+		"Unable to allocate memory for VF "
+		"Data Storage - SRIOV disabled\n");
+	pci_disable_sriov(adapter->pdev);
+
+err_novfs:
+	adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
+	adapter->num_vfs = 0;
+#endif /* CONFIG_PCI_IOV */
+}
+
 /**
  * ixgbe_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -5791,6 +6032,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_sw_init;
 	}
 
+	ixgbe_probe_vf(adapter, ii);
+
 	netdev->features = NETIF_F_SG |
 	                   NETIF_F_IP_CSUM |
 	                   NETIF_F_HW_VLAN_TX |
@@ -5811,6 +6054,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		adapter->flags &= ~(IXGBE_FLAG_RSS_ENABLED |
+				    IXGBE_FLAG_DCB_ENABLED);
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 
@@ -5937,6 +6183,13 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		ixgbe_setup_dca(adapter);
 	}
 #endif
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		DPRINTK(PROBE, INFO, "IOV is enabled with %d VFs\n",
+			adapter->num_vfs);
+		for (i = 0; i < adapter->num_vfs; i++)
+			ixgbe_vf_configuration(pdev, (i | 0x10000000));
+	}
+
 	/* add san mac addr to netdev */
 	ixgbe_add_sanmac_netdev(netdev);
 
@@ -5949,6 +6202,8 @@ err_register:
 	ixgbe_clear_interrupt_scheme(adapter);
 err_sw_init:
 err_eeprom:
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		ixgbe_disable_sriov(adapter);
 	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
 	del_timer_sync(&adapter->sfp_timer);
 	cancel_work_sync(&adapter->sfp_task);
@@ -6017,6 +6272,9 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
 
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		ixgbe_disable_sriov(adapter);
+
 	ixgbe_clear_interrupt_scheme(adapter);
 
 	ixgbe_release_hw_control(adapter);


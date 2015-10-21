From: Lan Tianyu <tianyu.lan@intel.com>
Subject: [RFC Patch 02/12] IXGBE: Add new mail box event to restore VF status in the PF driver
Date: Thu, 22 Oct 2015 00:37:34 +0800
Message-ID: <1445445464-5056-3-git-send-email-tianyu.lan@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Cc: Lan Tianyu <tianyu.lan@intel.com>
To: bhelgaas@google.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, eddie.dong@intel.com,
	nrupal.jani@intel.com, yang.z.zhang@intel.com, agraf@suse.de,
	kvm@vger.kernel.org, pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to restore VF status in the PF driver when get event
from VF.

Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 40 ++++++++++++++++++++++++++
 3 files changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 636f9e3..9d5669a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -148,6 +148,7 @@ struct vf_data_storage {
 	bool pf_set_mac;
 	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
 	u16 pf_qos;
+	u32 vf_lpe;
 	u16 tx_rate;
 	u16 vlan_count;
 	u8 spoofchk_enabled;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index b1e4703..8fdb38d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -91,6 +91,7 @@ enum ixgbe_pfvf_api_rev {
 
 /* mailbox API, version 1.1 VF requests */
 #define IXGBE_VF_GET_QUEUES	0x09 /* get queue configuration */
+#define IXGBE_VF_NOTIFY_RESUME    0x0c /* VF notify PF migration finishing */
 
 /* GET_QUEUES return data indices within the mailbox */
 #define IXGBE_VF_TX_QUEUES	1	/* number of Tx queues supported */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 1d17b58..ab2a2e2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -648,6 +648,42 @@ static inline void ixgbe_write_qde(struct ixgbe_adapter *adapter, u32 vf,
 	}
 }
 
+/**
+ *  Restore the settings by mailbox, after migration
+ **/
+void ixgbe_restore_setting(struct ixgbe_adapter *adapter, u32 vf)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 reg, reg_offset, vf_shift;
+	int rar_entry = hw->mac.num_rar_entries - (vf + 1);
+
+	vf_shift = vf % 32;
+	reg_offset = vf / 32;
+
+	/* enable transmit and receive for vf */
+	reg = IXGBE_READ_REG(hw, IXGBE_VFTE(reg_offset));
+	reg |= (1 << vf_shift);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), reg);
+
+	reg = IXGBE_READ_REG(hw, IXGBE_VFRE(reg_offset));
+	reg |= (1 << vf_shift);
+	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), reg);
+
+	reg = IXGBE_READ_REG(hw, IXGBE_VMECM(reg_offset));
+	reg |= (1 << vf_shift);
+	IXGBE_WRITE_REG(hw, IXGBE_VMECM(reg_offset), reg);
+
+	ixgbe_vf_reset_event(adapter, vf);
+
+	hw->mac.ops.set_rar(hw, rar_entry,
+			    adapter->vfinfo[vf].vf_mac_addresses,
+			    vf, IXGBE_RAH_AV);
+
+
+	if (adapter->vfinfo[vf].vf_lpe)
+		ixgbe_set_vf_lpe(adapter, &adapter->vfinfo[vf].vf_lpe, vf);
+}
+
 static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 {
 	struct ixgbe_ring_feature *vmdq = &adapter->ring_feature[RING_F_VMDQ];
@@ -1047,6 +1083,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 		break;
 	case IXGBE_VF_SET_LPE:
 		retval = ixgbe_set_vf_lpe(adapter, msgbuf, vf);
+		adapter->vfinfo[vf].vf_lpe = *msgbuf;
 		break;
 	case IXGBE_VF_SET_MACVLAN:
 		retval = ixgbe_set_vf_macvlan_msg(adapter, msgbuf, vf);
@@ -1063,6 +1100,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	case IXGBE_VF_GET_RSS_KEY:
 		retval = ixgbe_get_vf_rss_key(adapter, msgbuf, vf);
 		break;
+	case IXGBE_VF_NOTIFY_RESUME:
+		ixgbe_restore_setting(adapter, vf);
+		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
 		retval = IXGBE_ERR_MBX;
-- 
1.8.4.rc0.1.g8f6a3e5.dirty

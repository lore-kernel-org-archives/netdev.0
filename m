From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 03/13] ixgbe: Add macvlan support for VF
Date: Sat, 14 May 2011 18:23:37 -0700
Message-ID: <1305422627-9583-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52581 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759483Ab1EOBXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:50 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add infrastructure in the PF driver to support macvlan in the VF driver.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h       |   13 +++++
 drivers/net/ixgbe/ixgbe_main.c  |   28 +++++++++++-
 drivers/net/ixgbe/ixgbe_mbx.h   |    1 +
 drivers/net/ixgbe/ixgbe_sriov.c |   96 ++++++++++++++++++++++++++++++++++++++-
 4 files changed, 134 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 37ff531..91c1540 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -106,6 +106,7 @@
 #define IXGBE_MAX_VF_FUNCTIONS          64
 #define IXGBE_MAX_VFTA_ENTRIES          128
 #define MAX_EMULATION_MAC_ADDRS         16
+#define IXGBE_MAX_PF_MACVLANS           15
 #define VMDQ_P(p)   ((p) + adapter->num_vfs)
 
 struct vf_data_storage {
@@ -121,6 +122,15 @@ struct vf_data_storage {
 	u16 tx_rate;
 };
 
+struct vf_macvlans {
+	struct list_head l;
+	int vf;
+	int rar_entry;
+	bool free;
+	bool is_macvlan;
+	u8 vf_macvlan[ETH_ALEN];
+};
+
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgbe_tx_buffer {
@@ -471,6 +481,9 @@ struct ixgbe_adapter {
 	unsigned int num_vfs;
 	struct vf_data_storage *vfinfo;
 	int vf_rate_link_speed;
+	struct vf_macvlans vf_mvs;
+	struct vf_macvlans *mv_list;
+	bool antispoofing_enabled;
 };
 
 enum ixbge_state_t {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a3e384b..f8196e0 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3188,7 +3188,9 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	/* enable Tx loopback for VF/PF communication */
 	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 	/* Enable MAC Anti-Spoofing */
-	hw->mac.ops.set_mac_anti_spoofing(hw, (adapter->num_vfs != 0),
+	hw->mac.ops.set_mac_anti_spoofing(hw,
+					  (adapter->antispoofing_enabled =
+					   (adapter->num_vfs != 0)),
 					  adapter->num_vfs);
 }
 
@@ -3497,7 +3499,7 @@ static int ixgbe_write_uc_addr_list(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	unsigned int vfn = adapter->num_vfs;
-	unsigned int rar_entries = hw->mac.num_rar_entries - (vfn + 1);
+	unsigned int rar_entries = IXGBE_MAX_PF_MACVLANS;
 	int count = 0;
 
 	/* return ENOMEM indicating insufficient memory for addresses */
@@ -7107,6 +7109,8 @@ static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
 #ifdef CONFIG_PCI_IOV
 	struct ixgbe_hw *hw = &adapter->hw;
 	int err;
+	int num_vf_macvlans, i;
+	struct vf_macvlans *mv_list;
 
 	if (hw->mac.type == ixgbe_mac_82598EB || !max_vfs)
 		return;
@@ -7123,6 +7127,26 @@ static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
 		e_err(probe, "Failed to enable PCI sriov: %d\n", err);
 		goto err_novfs;
 	}
+
+	num_vf_macvlans = hw->mac.num_rar_entries -
+		(IXGBE_MAX_PF_MACVLANS + 1 + adapter->num_vfs);
+
+	adapter->mv_list = mv_list = kcalloc(num_vf_macvlans,
+					     sizeof(struct vf_macvlans),
+					     GFP_KERNEL);
+	if (mv_list) {
+		/* Initialize list of VF macvlans */
+		INIT_LIST_HEAD(&adapter->vf_mvs.l);
+		for (i = 0; i < num_vf_macvlans; i++) {
+			mv_list->vf = -1;
+			mv_list->free = true;
+			mv_list->rar_entry = hw->mac.num_rar_entries -
+				(i + adapter->num_vfs + 1);
+			list_add(&mv_list->l, &adapter->vf_mvs.l);
+			mv_list++;
+		}
+	}
+
 	/* If call to enable VFs succeeded then allocate memory
 	 * for per VF control structures.
 	 */
diff --git a/drivers/net/ixgbe/ixgbe_mbx.h b/drivers/net/ixgbe/ixgbe_mbx.h
index f53dc5b..b239bda 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ixgbe/ixgbe_mbx.h
@@ -67,6 +67,7 @@
 #define IXGBE_VF_SET_MULTICAST    0x03 /* VF requests PF to set MC addr */
 #define IXGBE_VF_SET_VLAN         0x04 /* VF requests PF to set VLAN */
 #define IXGBE_VF_SET_LPE          0x05 /* VF requests PF to set VMOLR.LPE */
+#define IXGBE_VF_SET_MACVLAN      0x06 /* VF requests PF for unicast filter */
 
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN 4
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 4765027..9f97246 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -82,6 +82,21 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
 	return 0;
 }
 
+static void ixgbe_restore_vf_macvlans(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct list_head *pos;
+	struct vf_macvlans *entry;
+
+	list_for_each(pos, &adapter->vf_mvs.l) {
+		entry = list_entry(pos, struct vf_macvlans, l);
+		if (entry->free == false)
+			hw->mac.ops.set_rar(hw, entry->rar_entry,
+					    entry->vf_macvlan,
+					    entry->vf, IXGBE_RAH_AV);
+	}
+}
+
 void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -102,6 +117,9 @@ void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter)
 			IXGBE_WRITE_REG(hw, IXGBE_MTA(vector_reg), mta_reg);
 		}
 	}
+
+	/* Restore any VF macvlans */
+	ixgbe_restore_vf_macvlans(adapter);
 }
 
 static int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid,
@@ -200,6 +218,61 @@ static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
 	return 0;
 }
 
+static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
+				int vf, int index, unsigned char *mac_addr)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct list_head *pos;
+	struct vf_macvlans *entry;
+
+	if (index <= 1) {
+		list_for_each(pos, &adapter->vf_mvs.l) {
+			entry = list_entry(pos, struct vf_macvlans, l);
+			if (entry->vf == vf) {
+				entry->vf = -1;
+				entry->free = true;
+				entry->is_macvlan = false;
+				hw->mac.ops.clear_rar(hw, entry->rar_entry);
+			}
+		}
+	}
+
+	/*
+	 * If index was zero then we were asked to clear the uc list
+	 * for the VF.  We're done.
+	 */
+	if (!index)
+		return 0;
+
+	entry = NULL;
+
+	list_for_each(pos, &adapter->vf_mvs.l) {
+		entry = list_entry(pos, struct vf_macvlans, l);
+		if (entry->free)
+			break;
+	}
+
+	/*
+	 * If we traversed the entire list and didn't find a free entry
+	 * then we're out of space on the RAR table.  Also entry may
+	 * be NULL because the original memory allocation for the list
+	 * failed, which is not fatal but does mean we can't support
+	 * VF requests for MACVLAN because we couldn't allocate
+	 * memory for the list management required.
+	 */
+	if (!entry || !entry->free)
+		return -ENOSPC;
+
+	entry->free = false;
+	entry->is_macvlan = true;
+	entry->vf = vf;
+	memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);
+
+	hw->mac.ops.set_rar(hw, entry->rar_entry, mac_addr, vf, IXGBE_RAH_AV);
+
+	return 0;
+}
+
 int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 {
 	unsigned char vf_mac_addr[6];
@@ -256,7 +329,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	s32 retval;
 	int entries;
 	u16 *hash_list;
-	int add, vid;
+	int add, vid, index;
 	u8 *new_mac;
 
 	retval = ixgbe_read_mbx(hw, msgbuf, mbx_size, vf);
@@ -345,6 +418,24 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 			retval = ixgbe_set_vf_vlan(adapter, add, vid, vf);
 		}
 		break;
+	case IXGBE_VF_SET_MACVLAN:
+		index = (msgbuf[0] & IXGBE_VT_MSGINFO_MASK) >>
+			IXGBE_VT_MSGINFO_SHIFT;
+		/*
+		 * If the VF is allowed to set MAC filters then turn off
+		 * anti-spoofing to avoid false positives.  An index
+		 * greater than 0 will indicate the VF is setting a
+		 * macvlan MAC filter.
+		 */
+		if (index > 0 && adapter->antispoofing_enabled) {
+			hw->mac.ops.set_mac_anti_spoofing(hw, false,
+							  adapter->num_vfs);
+			hw->mac.ops.set_vlan_anti_spoofing(hw, false, vf);
+			adapter->antispoofing_enabled = false;
+		}
+		retval = ixgbe_set_vf_macvlan(adapter, vf, index,
+					      (unsigned char *)(&msgbuf[1]));
+		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
 		retval = IXGBE_ERR_MBX;
@@ -452,7 +543,8 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 			goto out;
 		ixgbe_set_vmvir(adapter, vlan | (qos << VLAN_PRIO_SHIFT), vf);
 		ixgbe_set_vmolr(hw, vf, false);
-		hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
+		if (adapter->antispoofing_enabled)
+			hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
 		adapter->vfinfo[vf].pf_vlan = vlan;
 		adapter->vfinfo[vf].pf_qos = qos;
 		dev_info(&adapter->pdev->dev,
-- 
1.7.4.4


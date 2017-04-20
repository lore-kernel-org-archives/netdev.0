From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/7] igb/igbvf: Add VF MAC filter request capabilities
Date: Thu, 20 Apr 2017 16:33:33 -0700
Message-ID: <20170420233335.34900-6-jeffrey.t.kirsher@intel.com>
References: <20170420233335.34900-1-jeffrey.t.kirsher@intel.com>
Cc: Yury Kylulin <yury.kylulin@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8369 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S947982AbdDTXdt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 19:33:49 -0400
In-Reply-To: <20170420233335.34900-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yury Kylulin <yury.kylulin@intel.com>

Add functionality for the VF to request up to 3 additional MAC filters.
This is done using existing E1000_VF_SET_MAC_ADDR message, but with
additional message info - E1000_VF_MAC_FILTER_CLR to clear all unicast
MAC filters previously set for this VF and E1000_VF_MAC_FILTER_ADD to
add MAC filter.

Additional filters can be added only in case if administrator did not
set VF MAC explicitly and allowed to change default MAC to the VF.

Due to the limited number of RAR entries reserve at least 3 MAC filters
for the PF.

If SRIOV is supported by the NIC after this change RAR entries starting
from 1 to (RAR MAX ENTRIES - NUM SRIOV VFS) will be used for PF and VF
MAC filters.

Signed-off-by: Yury Kylulin <yury.kylulin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_mbx.h |   4 +
 drivers/net/ethernet/intel/igb/igb.h       |  12 +++
 drivers/net/ethernet/intel/igb/igb_main.c  | 147 ++++++++++++++++++++++++++---
 drivers/net/ethernet/intel/igbvf/igbvf.h   |   2 +
 drivers/net/ethernet/intel/igbvf/mbx.h     |   4 +
 drivers/net/ethernet/intel/igbvf/netdev.c  |  44 ++++++++-
 drivers/net/ethernet/intel/igbvf/vf.c      |  41 ++++++++
 drivers/net/ethernet/intel/igbvf/vf.h      |   1 +
 8 files changed, 240 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mbx.h b/drivers/net/ethernet/intel/igb/e1000_mbx.h
index d20af6b2f581..3e7fed73df15 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mbx.h
+++ b/drivers/net/ethernet/intel/igb/e1000_mbx.h
@@ -55,6 +55,10 @@
 
 #define E1000_VF_RESET		0x01 /* VF requests reset */
 #define E1000_VF_SET_MAC_ADDR	0x02 /* VF requests to set MAC addr */
+/* VF requests to clear all unicast MAC filters */
+#define E1000_VF_MAC_FILTER_CLR	(0x01 << E1000_VT_MSGINFO_SHIFT)
+/* VF requests to add unicast MAC filter */
+#define E1000_VF_MAC_FILTER_ADD	(0x02 << E1000_VT_MSGINFO_SHIFT)
 #define E1000_VF_SET_MULTICAST	0x03 /* VF requests to set MC addr */
 #define E1000_VF_SET_VLAN	0x04 /* VF requests to set VLAN */
 #define E1000_VF_SET_LPE	0x05 /* VF requests to set VMOLR.LPE */
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 97f348aa6ba4..bf9bf9056d0c 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -111,6 +111,16 @@ struct vf_data_storage {
 	bool spoofchk_enabled;
 };
 
+/* Number of unicast MAC filters reserved for the PF in the RAR registers */
+#define IGB_PF_MAC_FILTERS_RESERVED	3
+
+struct vf_mac_filter {
+	struct list_head l;
+	int vf;
+	bool free;
+	u8 vf_mac[ETH_ALEN];
+};
+
 #define IGB_VF_FLAG_CTS            0x00000001 /* VF is clear to send data */
 #define IGB_VF_FLAG_UNI_PROMISC    0x00000002 /* VF has unicast promisc */
 #define IGB_VF_FLAG_MULTI_PROMISC  0x00000004 /* VF has multicast promisc */
@@ -586,6 +596,8 @@ struct igb_adapter {
 	bool etype_bitmap[MAX_ETYPE_FILTER];
 
 	struct igb_mac_addr *mac_table;
+	struct vf_mac_filter vf_macs;
+	struct vf_mac_filter *vf_mac_list;
 };
 
 /* flags controlling PTP/1588 function */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index bb5d5ac22f04..53e66c87abaf 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1158,6 +1158,8 @@ static void igb_set_interrupt_capability(struct igb_adapter *adapter, bool msix)
 		pci_disable_sriov(adapter->pdev);
 		msleep(500);
 
+		kfree(adapter->vf_mac_list);
+		adapter->vf_mac_list = NULL;
 		kfree(adapter->vf_data);
 		adapter->vf_data = NULL;
 		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
@@ -2809,6 +2811,8 @@ static int igb_disable_sriov(struct pci_dev *pdev)
 			msleep(500);
 		}
 
+		kfree(adapter->vf_mac_list);
+		adapter->vf_mac_list = NULL;
 		kfree(adapter->vf_data);
 		adapter->vf_data = NULL;
 		adapter->vfs_allocated_count = 0;
@@ -2829,8 +2833,9 @@ static int igb_enable_sriov(struct pci_dev *pdev, int num_vfs)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	int old_vfs = pci_num_vf(pdev);
+	struct vf_mac_filter *mac_list;
 	int err = 0;
-	int i;
+	int num_vf_mac_filters, i;
 
 	if (!(adapter->flags & IGB_FLAG_HAS_MSIX) || num_vfs > 7) {
 		err = -EPERM;
@@ -2858,6 +2863,38 @@ static int igb_enable_sriov(struct pci_dev *pdev, int num_vfs)
 		goto out;
 	}
 
+	/* Due to the limited number of RAR entries calculate potential
+	 * number of MAC filters available for the VFs. Reserve entries
+	 * for PF default MAC, PF MAC filters and at least one RAR entry
+	 * for each VF for VF MAC.
+	 */
+	num_vf_mac_filters = adapter->hw.mac.rar_entry_count -
+			     (1 + IGB_PF_MAC_FILTERS_RESERVED +
+			      adapter->vfs_allocated_count);
+
+	adapter->vf_mac_list = kcalloc(num_vf_mac_filters,
+				       sizeof(struct vf_mac_filter),
+				       GFP_KERNEL);
+
+	mac_list = adapter->vf_mac_list;
+	INIT_LIST_HEAD(&adapter->vf_macs.l);
+
+	if (adapter->vf_mac_list) {
+		/* Initialize list of VF MAC filters */
+		for (i = 0; i < num_vf_mac_filters; i++) {
+			mac_list->vf = -1;
+			mac_list->free = true;
+			list_add(&mac_list->l, &adapter->vf_macs.l);
+			mac_list++;
+		}
+	} else {
+		/* If we could not allocate memory for the VF MAC filters
+		 * we can continue without this feature but warn user.
+		 */
+		dev_err(&pdev->dev,
+			"Unable to allocate memory for VF MAC filter list\n");
+	}
+
 	/* only call pci_enable_sriov() if no VFs are allocated already */
 	if (!old_vfs) {
 		err = pci_enable_sriov(pdev, adapter->vfs_allocated_count);
@@ -2874,6 +2911,8 @@ static int igb_enable_sriov(struct pci_dev *pdev, int num_vfs)
 	goto out;
 
 err_out:
+	kfree(adapter->vf_mac_list);
+	adapter->vf_mac_list = NULL;
 	kfree(adapter->vf_data);
 	adapter->vf_data = NULL;
 	adapter->vfs_allocated_count = 0;
@@ -6501,18 +6540,106 @@ static int igb_uc_unsync(struct net_device *netdev, const unsigned char *addr)
 	return 0;
 }
 
+int igb_set_vf_mac_filter(struct igb_adapter *adapter, const int vf,
+			  const u32 info, const u8 *addr)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	struct vf_data_storage *vf_data = &adapter->vf_data[vf];
+	struct list_head *pos;
+	struct vf_mac_filter *entry = NULL;
+	int ret = 0;
+
+	switch (info) {
+	case E1000_VF_MAC_FILTER_CLR:
+		/* remove all unicast MAC filters related to the current VF */
+		list_for_each(pos, &adapter->vf_macs.l) {
+			entry = list_entry(pos, struct vf_mac_filter, l);
+			if (entry->vf == vf) {
+				entry->vf = -1;
+				entry->free = true;
+				igb_del_mac_filter(adapter, entry->vf_mac, vf);
+			}
+		}
+		break;
+	case E1000_VF_MAC_FILTER_ADD:
+		if (vf_data->flags & IGB_VF_FLAG_PF_SET_MAC) {
+			dev_warn(&pdev->dev,
+				 "VF %d requested MAC filter but is administratively denied\n",
+				 vf);
+			return -EINVAL;
+		}
+
+		if (!is_valid_ether_addr(addr)) {
+			dev_warn(&pdev->dev,
+				 "VF %d attempted to set invalid MAC filter\n",
+				 vf);
+			return -EINVAL;
+		}
+
+		/* try to find empty slot in the list */
+		list_for_each(pos, &adapter->vf_macs.l) {
+			entry = list_entry(pos, struct vf_mac_filter, l);
+			if (entry->free)
+				break;
+		}
+
+		if (entry && entry->free) {
+			entry->free = false;
+			entry->vf = vf;
+			ether_addr_copy(entry->vf_mac, addr);
+
+			ret = igb_add_mac_filter(adapter, addr, vf);
+			ret = min_t(int, ret, 0);
+		} else {
+			ret = -ENOSPC;
+		}
+
+		if (ret == -ENOSPC)
+			dev_warn(&pdev->dev,
+				 "VF %d has requested MAC filter but there is no space for it\n",
+				 vf);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
 static int igb_set_vf_mac_addr(struct igb_adapter *adapter, u32 *msg, int vf)
 {
+	struct pci_dev *pdev = adapter->pdev;
+	struct vf_data_storage *vf_data = &adapter->vf_data[vf];
+	u32 info = msg[0] & E1000_VT_MSGINFO_MASK;
+
 	/* The VF MAC Address is stored in a packed array of bytes
 	 * starting at the second 32 bit word of the msg array
 	 */
-	unsigned char *addr = (char *)&msg[1];
-	int err = -1;
+	unsigned char *addr = (unsigned char *)&msg[1];
+	int ret = 0;
 
-	if (is_valid_ether_addr(addr))
-		err = igb_set_vf_mac(adapter, vf, addr);
+	if (!info) {
+		if (vf_data->flags & IGB_VF_FLAG_PF_SET_MAC) {
+			dev_warn(&pdev->dev,
+				 "VF %d attempted to override administratively set MAC address\nReload the VF driver to resume operations\n",
+				 vf);
+			return -EINVAL;
+		}
 
-	return err;
+		if (!is_valid_ether_addr(addr)) {
+			dev_warn(&pdev->dev,
+				 "VF %d attempted to set invalid MAC\n",
+				 vf);
+			return -EINVAL;
+		}
+
+		ret = igb_set_vf_mac(adapter, vf, addr);
+	} else {
+		ret = igb_set_vf_mac_filter(adapter, vf, info, addr);
+	}
+
+	return ret;
 }
 
 static void igb_rcv_ack_from_vf(struct igb_adapter *adapter, u32 vf)
@@ -6569,13 +6696,7 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 
 	switch ((msgbuf[0] & 0xFFFF)) {
 	case E1000_VF_SET_MAC_ADDR:
-		retval = -EINVAL;
-		if (!(vf_data->flags & IGB_VF_FLAG_PF_SET_MAC))
-			retval = igb_set_vf_mac_addr(adapter, msgbuf, vf);
-		else
-			dev_warn(&pdev->dev,
-				 "VF %d attempted to override administratively set MAC address\nReload the VF driver to resume operations\n",
-				 vf);
+		retval = igb_set_vf_mac_addr(adapter, msgbuf, vf);
 		break;
 	case E1000_VF_SET_PROMISC:
 		retval = igb_set_vf_promisc(adapter, msgbuf, vf);
diff --git a/drivers/net/ethernet/intel/igbvf/igbvf.h b/drivers/net/ethernet/intel/igbvf/igbvf.h
index 6f4290d6dc9f..2a53ed84d9fc 100644
--- a/drivers/net/ethernet/intel/igbvf/igbvf.h
+++ b/drivers/net/ethernet/intel/igbvf/igbvf.h
@@ -101,6 +101,8 @@ enum latency_range {
 
 #define IGBVF_MNG_VLAN_NONE	(-1)
 
+#define IGBVF_MAX_MAC_FILTERS	3
+
 /* Number of packet split data buffers (not including the header buffer) */
 #define PS_PAGE_BUFFERS		(MAX_PS_BUFFERS - 1)
 
diff --git a/drivers/net/ethernet/intel/igbvf/mbx.h b/drivers/net/ethernet/intel/igbvf/mbx.h
index f800bf8eedae..30d58c4a444e 100644
--- a/drivers/net/ethernet/intel/igbvf/mbx.h
+++ b/drivers/net/ethernet/intel/igbvf/mbx.h
@@ -62,6 +62,10 @@
 
 #define E1000_VF_RESET		0x01 /* VF requests reset */
 #define E1000_VF_SET_MAC_ADDR	0x02 /* VF requests PF to set MAC addr */
+/* VF requests PF to clear all unicast MAC filters */
+#define E1000_VF_MAC_FILTER_CLR (0x01 << E1000_VT_MSGINFO_SHIFT)
+/* VF requests PF to add unicast MAC filter */
+#define E1000_VF_MAC_FILTER_ADD (0x02 << E1000_VT_MSGINFO_SHIFT)
 #define E1000_VF_SET_MULTICAST	0x03 /* VF requests PF to set MC addr */
 #define E1000_VF_SET_VLAN	0x04 /* VF requests PF to set VLAN */
 #define E1000_VF_SET_LPE	0x05 /* VF requests PF to set VMOLR.LPE */
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 839ba110f7fb..6029854b6a70 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1433,12 +1433,52 @@ static void igbvf_set_multi(struct net_device *netdev)
 }
 
 /**
+ * igbvf_set_uni - Configure unicast MAC filters
+ * @netdev: network interface device structure
+ *
+ * This routine is responsible for configuring the hardware for proper
+ * unicast filters.
+ **/
+static int igbvf_set_uni(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (netdev_uc_count(netdev) > IGBVF_MAX_MAC_FILTERS) {
+		pr_err("Too many unicast filters - No Space\n");
+		return -ENOSPC;
+	}
+
+	/* Clear all unicast MAC filters */
+	hw->mac.ops.set_uc_addr(hw, E1000_VF_MAC_FILTER_CLR, NULL);
+
+	if (!netdev_uc_empty(netdev)) {
+		struct netdev_hw_addr *ha;
+
+		/* Add MAC filters one by one */
+		netdev_for_each_uc_addr(ha, netdev) {
+			hw->mac.ops.set_uc_addr(hw, E1000_VF_MAC_FILTER_ADD,
+						ha->addr);
+			udelay(200);
+		}
+	}
+
+	return 0;
+}
+
+static void igbvf_set_rx_mode(struct net_device *netdev)
+{
+	igbvf_set_multi(netdev);
+	igbvf_set_uni(netdev);
+}
+
+/**
  * igbvf_configure - configure the hardware for Rx and Tx
  * @adapter: private board structure
  **/
 static void igbvf_configure(struct igbvf_adapter *adapter)
 {
-	igbvf_set_multi(adapter->netdev);
+	igbvf_set_rx_mode(adapter->netdev);
 
 	igbvf_restore_vlan(adapter);
 
@@ -2636,7 +2676,7 @@ static const struct net_device_ops igbvf_netdev_ops = {
 	.ndo_stop		= igbvf_close,
 	.ndo_start_xmit		= igbvf_xmit_frame,
 	.ndo_get_stats		= igbvf_get_stats,
-	.ndo_set_rx_mode	= igbvf_set_multi,
+	.ndo_set_rx_mode	= igbvf_set_rx_mode,
 	.ndo_set_mac_address	= igbvf_set_mac,
 	.ndo_change_mtu		= igbvf_change_mtu,
 	.ndo_do_ioctl		= igbvf_ioctl,
diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
index 335ba6642145..528be116184e 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.c
+++ b/drivers/net/ethernet/intel/igbvf/vf.c
@@ -36,6 +36,7 @@ static void e1000_update_mc_addr_list_vf(struct e1000_hw *hw, u8 *,
 					 u32, u32, u32);
 static void e1000_rar_set_vf(struct e1000_hw *, u8 *, u32);
 static s32 e1000_read_mac_addr_vf(struct e1000_hw *);
+static s32 e1000_set_uc_addr_vf(struct e1000_hw *hw, u32 subcmd, u8 *addr);
 static s32 e1000_set_vfta_vf(struct e1000_hw *, u16, bool);
 
 /**
@@ -66,6 +67,8 @@ static s32 e1000_init_mac_params_vf(struct e1000_hw *hw)
 	mac->ops.rar_set = e1000_rar_set_vf;
 	/* read mac address */
 	mac->ops.read_mac_addr = e1000_read_mac_addr_vf;
+	/* set mac filter */
+	mac->ops.set_uc_addr = e1000_set_uc_addr_vf;
 	/* set vlan filter table array */
 	mac->ops.set_vfta = e1000_set_vfta_vf;
 
@@ -338,6 +341,44 @@ static s32 e1000_read_mac_addr_vf(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_set_uc_addr_vf - Set or clear unicast filters
+ *  @hw: pointer to the HW structure
+ *  @sub_cmd: add or clear filters
+ *  @addr: pointer to the filter MAC address
+ **/
+static s32 e1000_set_uc_addr_vf(struct e1000_hw *hw, u32 sub_cmd, u8 *addr)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	u32 msgbuf[3], msgbuf_chk;
+	u8 *msg_addr = (u8 *)(&msgbuf[1]);
+	s32 ret_val;
+
+	memset(msgbuf, 0, sizeof(msgbuf));
+	msgbuf[0] |= sub_cmd;
+	msgbuf[0] |= E1000_VF_SET_MAC_ADDR;
+	msgbuf_chk = msgbuf[0];
+
+	if (addr)
+		memcpy(msg_addr, addr, ETH_ALEN);
+
+	ret_val = mbx->ops.write_posted(hw, msgbuf, 3);
+
+	if (!ret_val)
+		ret_val = mbx->ops.read_posted(hw, msgbuf, 3);
+
+	msgbuf[0] &= ~E1000_VT_MSGTYPE_CTS;
+
+	if (!ret_val) {
+		msgbuf[0] &= ~E1000_VT_MSGTYPE_CTS;
+
+		if (msgbuf[0] == (msgbuf_chk | E1000_VT_MSGTYPE_NACK))
+			return -ENOSPC;
+	}
+
+	return ret_val;
+}
+
+/**
  *  e1000_check_for_link_vf - Check for link for a virtual interface
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/ethernet/intel/igbvf/vf.h b/drivers/net/ethernet/intel/igbvf/vf.h
index f00a41d9a1ca..4cf78b0dec50 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.h
+++ b/drivers/net/ethernet/intel/igbvf/vf.h
@@ -179,6 +179,7 @@ struct e1000_mac_operations {
 	s32  (*get_bus_info)(struct e1000_hw *);
 	s32  (*get_link_up_info)(struct e1000_hw *, u16 *, u16 *);
 	void (*update_mc_addr_list)(struct e1000_hw *, u8 *, u32, u32, u32);
+	s32  (*set_uc_addr)(struct e1000_hw *, u32, u8 *);
 	s32  (*reset_hw)(struct e1000_hw *);
 	s32  (*init_hw)(struct e1000_hw *);
 	s32  (*setup_link)(struct e1000_hw *);
-- 
2.12.2

From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v6 4/4] igb/igbvf: implement ndo_get_phys_port_id
Date: Mon, 29 Jul 2013 18:16:52 +0200
Message-ID: <1375114612-537-5-git-send-email-jiri@resnulli.us>
References: <1375114612-537-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36400 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757497Ab3G2QRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 12:17:09 -0400
Received: by mail-wi0-f169.google.com with SMTP id f14so1079586wiw.2
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 09:17:07 -0700 (PDT)
In-Reply-To: <1375114612-537-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

igb driver generated random number which will identify physical port.
This id is available via ndo_get_phys_port_id directly on igb netdev.
Also, id is passed to igbvf using mailbox. After that, it is available via
ndo_get_phys_port_id on igbvf netdev as well.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
 drivers/net/ethernet/intel/igb/igb.h       |  3 +++
 drivers/net/ethernet/intel/igb/igb_main.c  | 37 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/intel/igbvf/igbvf.h   |  4 ++++
 drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
 drivers/net/ethernet/intel/igbvf/netdev.c  | 38 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.c      | 34 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
 8 files changed, 118 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mbx.h b/drivers/net/ethernet/intel/igb/e1000_mbx.h
index de9bba4..1788480 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mbx.h
+++ b/drivers/net/ethernet/intel/igb/e1000_mbx.h
@@ -64,6 +64,7 @@
 #define E1000_VF_SET_LPE	0x05 /* VF requests to set VMOLR.LPE */
 #define E1000_VF_SET_PROMISC	0x06 /*VF requests to clear VMOLR.ROPE/MPME*/
 #define E1000_VF_SET_PROMISC_MULTICAST	(0x02 << E1000_VT_MSGINFO_SHIFT)
+#define E1000_VF_GET_PHYS_PORT_ID 0x07 /* VF requests to get physical port id */
 
 #define E1000_PF_CONTROL_MSG	0x0100 /* PF control message */
 
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 15ea8dc..fcbb1c7 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -444,6 +444,9 @@ struct igb_adapter {
 	struct i2c_algo_bit_data i2c_algo;
 	struct i2c_adapter i2c_adap;
 	struct i2c_client *i2c_client;
+
+#define IGB_PHYS_PORT_ID_LEN	16
+	u8 phys_port_id[IGB_PHYS_PORT_ID_LEN];
 };
 
 #define IGB_FLAG_HAS_MSI		(1 << 0)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6a0c1b6..8015e9f 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -58,6 +58,7 @@
 #include <linux/dca.h>
 #endif
 #include <linux/i2c.h>
+#include <linux/uuid.h>
 #include "igb.h"
 
 #define MAJ 5
@@ -1892,6 +1893,24 @@ static int igb_set_features(struct net_device *netdev,
 	return 0;
 }
 
+/**
+ * igb_get_phys_port_id - Get physical port ID
+ * @netdev: network interface device structure
+ * @ppid: pointer to a physical port id structure
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int igb_get_phys_port_id(struct net_device *netdev,
+				struct netdev_phys_port_id *ppid)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+
+	ppid->id_len = sizeof(adapter->phys_port_id);
+	memcpy(ppid->id, adapter->phys_port_id, ppid->id_len);
+
+	return 0;
+}
+
 static const struct net_device_ops igb_netdev_ops = {
 	.ndo_open		= igb_open,
 	.ndo_stop		= igb_close,
@@ -1915,6 +1934,7 @@ static const struct net_device_ops igb_netdev_ops = {
 #endif
 	.ndo_fix_features	= igb_fix_features,
 	.ndo_set_features	= igb_set_features,
+	.ndo_get_phys_port_id	= igb_get_phys_port_id,
 };
 
 /**
@@ -1982,6 +2002,14 @@ static s32 igb_init_i2c(struct igb_adapter *adapter)
 	return status;
 }
 
+void igb_gen_phys_port_id(struct igb_adapter *adapter)
+{
+	uuid_le uuid;
+
+	uuid_le_gen(&uuid);
+	memcpy(adapter->phys_port_id, uuid.b, sizeof(adapter->phys_port_id));
+}
+
 /**
  *  igb_probe - Device Initialization Routine
  *  @pdev: PCI device information struct
@@ -2287,6 +2315,8 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * driver. */
 	igb_get_hw_control(adapter);
 
+	igb_gen_phys_port_id(adapter);
+
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
@@ -5698,6 +5728,7 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 	struct e1000_hw *hw = &adapter->hw;
 	struct vf_data_storage *vf_data = &adapter->vf_data[vf];
 	s32 retval;
+	u16 write_size = 1;
 
 	retval = igb_read_mbx(hw, msgbuf, E1000_VFMAILBOX_SIZE, vf);
 
@@ -5757,6 +5788,10 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 		else
 			retval = igb_set_vf_vlan(adapter, msgbuf, vf);
 		break;
+	case E1000_VF_GET_PHYS_PORT_ID:
+		memcpy(&msgbuf[1], adapter->phys_port_id, IGB_PHYS_PORT_ID_LEN);
+		write_size += IGB_PHYS_PORT_ID_LEN / 4;
+		break;
 	default:
 		dev_err(&pdev->dev, "Unhandled Msg %08x\n", msgbuf[0]);
 		retval = -1;
@@ -5771,7 +5806,7 @@ out:
 	else
 		msgbuf[0] |= E1000_VT_MSGTYPE_ACK;
 
-	igb_write_mbx(hw, msgbuf, 1, vf);
+	igb_write_mbx(hw, msgbuf, write_size, vf);
 }
 
 static void igb_msg_task(struct igb_adapter *adapter)
diff --git a/drivers/net/ethernet/intel/igbvf/igbvf.h b/drivers/net/ethernet/intel/igbvf/igbvf.h
index a1463e3..27ddbb0 100644
--- a/drivers/net/ethernet/intel/igbvf/igbvf.h
+++ b/drivers/net/ethernet/intel/igbvf/igbvf.h
@@ -283,6 +283,10 @@ struct igbvf_adapter {
 
 	unsigned int flags;
 	unsigned long last_reset;
+
+#define IGBVF_PHYS_PORT_ID_LEN	16
+	u8 phys_port_id[IGBVF_PHYS_PORT_ID_LEN];
+	bool phys_port_id_set;
 };
 
 struct igbvf_info {
diff --git a/drivers/net/ethernet/intel/igbvf/mbx.h b/drivers/net/ethernet/intel/igbvf/mbx.h
index 24370bc..1040d36 100644
--- a/drivers/net/ethernet/intel/igbvf/mbx.h
+++ b/drivers/net/ethernet/intel/igbvf/mbx.h
@@ -66,6 +66,7 @@
 #define E1000_VF_SET_MULTICAST    0x03 /* VF requests PF to set MC addr */
 #define E1000_VF_SET_VLAN         0x04 /* VF requests PF to set VLAN */
 #define E1000_VF_SET_LPE          0x05 /* VF requests PF to set VMOLR.LPE */
+#define E1000_VF_GET_PHYS_PORT_ID 0x07 /* VF requests to get physical port id */
 
 #define E1000_PF_CONTROL_MSG      0x0100 /* PF control message */
 
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 93eb7ee..46e4d16 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1444,6 +1444,18 @@ static void igbvf_configure(struct igbvf_adapter *adapter)
 	                       igbvf_desc_unused(adapter->rx_ring));
 }
 
+static void igbvf_refresh_ppid(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int err;
+
+	err = hw->mac.ops.ppid_get_vf(hw, adapter->phys_port_id);
+	if (err)
+		adapter->phys_port_id_set = false;
+	else
+		adapter->phys_port_id_set = true;
+}
+
 /* igbvf_reset - bring the hardware into a known good state
  *
  * This function boots the hardware and enables some settings that
@@ -1461,6 +1473,8 @@ static void igbvf_reset(struct igbvf_adapter *adapter)
 	if (mac->ops.reset_hw(hw))
 		dev_err(&adapter->pdev->dev, "PF still resetting\n");
 
+	igbvf_refresh_ppid(adapter);
+
 	mac->ops.init_hw(hw);
 
 	if (is_valid_ether_addr(adapter->hw.mac.addr)) {
@@ -1753,6 +1767,27 @@ static int igbvf_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
+/**
+ * igbvf_get_phys_port_id - Get physical port ID
+ * @netdev: network interface device structure
+ * @ppid: pointer to a physical port id structure
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int igbvf_get_phys_port_id(struct net_device *netdev,
+				  struct netdev_phys_port_id *ppid)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	if (!adapter->phys_port_id_set)
+		return -EOPNOTSUPP;
+
+	ppid->id_len = sizeof(adapter->phys_port_id);
+	memcpy(ppid->id, adapter->phys_port_id, ppid->id_len);
+
+	return 0;
+}
+
 #define UPDATE_VF_COUNTER(reg, name)                                    \
 	{                                                               \
 		u32 current_counter = er32(reg);                        \
@@ -2610,6 +2645,7 @@ static const struct net_device_ops igbvf_netdev_ops = {
 	.ndo_poll_controller            = igbvf_netpoll,
 #endif
 	.ndo_set_features               = igbvf_set_features,
+	.ndo_get_phys_port_id		= igbvf_get_phys_port_id,
 };
 
 /**
@@ -2759,6 +2795,8 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			netdev->addr_len);
 	}
 
+	igbvf_refresh_ppid(adapter);
+
 	setup_timer(&adapter->watchdog_timer, &igbvf_watchdog,
 	            (unsigned long) adapter);
 
diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
index eea0e10..291175d 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.c
+++ b/drivers/net/ethernet/intel/igbvf/vf.c
@@ -39,6 +39,7 @@ static void e1000_update_mc_addr_list_vf(struct e1000_hw *hw, u8 *,
 static void e1000_rar_set_vf(struct e1000_hw *, u8 *, u32);
 static s32 e1000_read_mac_addr_vf(struct e1000_hw *);
 static s32 e1000_set_vfta_vf(struct e1000_hw *, u16, bool);
+static s32 e1000_ppid_get_vf(struct e1000_hw *hw, u8 *id);
 
 /**
  *  e1000_init_mac_params_vf - Inits MAC params
@@ -70,6 +71,8 @@ static s32 e1000_init_mac_params_vf(struct e1000_hw *hw)
 	mac->ops.read_mac_addr = e1000_read_mac_addr_vf;
 	/* set vlan filter table array */
 	mac->ops.set_vfta = e1000_set_vfta_vf;
+	/* get physical port ID */
+	mac->ops.ppid_get_vf = e1000_ppid_get_vf;
 
 	return E1000_SUCCESS;
 }
@@ -398,3 +401,34 @@ out:
 	return ret_val;
 }
 
+/**
+ *  e1000_ppid_get_vf - get device MAC physical port ID
+ *  @hw: pointer to the HW structure
+ *  @id: pointer where port ID will be written
+ **/
+static s32 e1000_ppid_get_vf(struct e1000_hw *hw, u8 *id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	u32 msgbuf[5];
+	s32 ret_val;
+
+	memset(msgbuf, 0, sizeof(msgbuf));
+	msgbuf[0] = E1000_VF_GET_PHYS_PORT_ID;
+
+	ret_val = mbx->ops.write_posted(hw, msgbuf, 1);
+	if (ret_val)
+		goto out;
+
+	ret_val = mbx->ops.read_posted(hw, msgbuf, 5);
+	if (ret_val)
+		goto out;
+
+	if (msgbuf[0] & E1000_VT_MSGTYPE_NACK) {
+		ret_val = -E1000_ERR_MAC_INIT;
+		goto out;
+	}
+	memcpy(id, &msgbuf[1], 16);
+
+out:
+	return ret_val;
+}
diff --git a/drivers/net/ethernet/intel/igbvf/vf.h b/drivers/net/ethernet/intel/igbvf/vf.h
index 57db3c6..2b690bb 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.h
+++ b/drivers/net/ethernet/intel/igbvf/vf.h
@@ -188,6 +188,7 @@ struct e1000_mac_operations {
 	void (*rar_set)(struct e1000_hw *, u8*, u32);
 	s32  (*read_mac_addr)(struct e1000_hw *);
 	s32  (*set_vfta)(struct e1000_hw *, u16, bool);
+	s32  (*ppid_get_vf)(struct e1000_hw *, u8 *);
 };
 
 struct e1000_mac_info {
-- 
1.8.1.4

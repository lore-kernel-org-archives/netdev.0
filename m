From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 4/4] igb/igbvf: implement ndo_get_phys_port_id
Date: Thu, 25 Jul 2013 15:03:05 +0200
Message-ID: <1374757385-10875-5-git-send-email-jiri@resnulli.us>
References: <1374757385-10875-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-ee0-f47.google.com ([74.125.83.47]:43254 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573Ab3GYNDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:03:24 -0400
Received: by mail-ee0-f47.google.com with SMTP id e49so900346eek.6
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 06:03:23 -0700 (PDT)
In-Reply-To: <1374757385-10875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

igb driver computes hash which will identify physical port. This hash is
available via ndo_get_phys_port_id directly on igb netdev. Also, this
hash is passed to igbvf using mailbox. After that, it is available via
ndo_get_phys_port_id on igbvf netdev as well.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
 drivers/net/ethernet/intel/igb/igb.h       |  2 ++
 drivers/net/ethernet/intel/igb/igb_main.c  | 43 +++++++++++++++++++++++++++-
 drivers/net/ethernet/intel/igbvf/igbvf.h   |  3 ++
 drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
 drivers/net/ethernet/intel/igbvf/netdev.c  | 45 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.c      | 34 ++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
 8 files changed, 129 insertions(+), 1 deletion(-)

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
index 15ea8dc..12a25b1 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -444,6 +444,8 @@ struct igb_adapter {
 	struct i2c_algo_bit_data i2c_algo;
 	struct i2c_adapter i2c_adap;
 	struct i2c_client *i2c_client;
+
+	u32 phys_port_id;
 };
 
 #define IGB_FLAG_HAS_MSI		(1 << 0)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6a0c1b6..4db3fde 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1892,6 +1892,24 @@ static int igb_set_features(struct net_device *netdev,
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
+	memcpy(ppid->id, &adapter->phys_port_id, ppid->id_len);
+
+	return 0;
+}
+
 static const struct net_device_ops igb_netdev_ops = {
 	.ndo_open		= igb_open,
 	.ndo_stop		= igb_close,
@@ -1915,6 +1933,7 @@ static const struct net_device_ops igb_netdev_ops = {
 #endif
 	.ndo_fix_features	= igb_fix_features,
 	.ndo_set_features	= igb_set_features,
+	.ndo_get_phys_port_id	= igb_get_phys_port_id,
 };
 
 /**
@@ -1982,6 +2001,21 @@ static s32 igb_init_i2c(struct igb_adapter *adapter)
 	return status;
 }
 
+static void igb_compute_phys_port_id(struct igb_adapter *adapter)
+{
+	adapter->phys_port_id = *((u32 *) adapter->netdev->dev_addr);
+	adapter->phys_port_id ^= *((u32 *) adapter->netdev->dev_addr + 4);
+	adapter->phys_port_id ^= (long) adapter;
+	adapter->phys_port_id ^= (long) adapter->hw.hw_addr;
+	adapter->phys_port_id ^= (long) adapter->hw.flash_address;
+	adapter->phys_port_id ^= (u32) adapter->hw.io_base;
+	adapter->phys_port_id ^= adapter->hw.device_id;
+	adapter->phys_port_id ^= adapter->hw.subsystem_vendor_id;
+	adapter->phys_port_id ^= adapter->hw.subsystem_device_id;
+	adapter->phys_port_id ^= adapter->hw.vendor_id;
+	adapter->phys_port_id ^= adapter->hw.revision_id;
+}
+
 /**
  *  igb_probe - Device Initialization Routine
  *  @pdev: PCI device information struct
@@ -2287,6 +2321,8 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * driver. */
 	igb_get_hw_control(adapter);
 
+	igb_compute_phys_port_id(adapter);
+
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
@@ -5698,6 +5734,7 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 	struct e1000_hw *hw = &adapter->hw;
 	struct vf_data_storage *vf_data = &adapter->vf_data[vf];
 	s32 retval;
+	u16 write_size = 1;
 
 	retval = igb_read_mbx(hw, msgbuf, E1000_VFMAILBOX_SIZE, vf);
 
@@ -5757,6 +5794,10 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 		else
 			retval = igb_set_vf_vlan(adapter, msgbuf, vf);
 		break;
+	case E1000_VF_GET_PHYS_PORT_ID:
+		msgbuf[1] = adapter->phys_port_id;
+		write_size = 2;
+		break;
 	default:
 		dev_err(&pdev->dev, "Unhandled Msg %08x\n", msgbuf[0]);
 		retval = -1;
@@ -5771,7 +5812,7 @@ out:
 	else
 		msgbuf[0] |= E1000_VT_MSGTYPE_ACK;
 
-	igb_write_mbx(hw, msgbuf, 1, vf);
+	igb_write_mbx(hw, msgbuf, write_size, vf);
 }
 
 static void igb_msg_task(struct igb_adapter *adapter)
diff --git a/drivers/net/ethernet/intel/igbvf/igbvf.h b/drivers/net/ethernet/intel/igbvf/igbvf.h
index a1463e3..559ccaf 100644
--- a/drivers/net/ethernet/intel/igbvf/igbvf.h
+++ b/drivers/net/ethernet/intel/igbvf/igbvf.h
@@ -283,6 +283,9 @@ struct igbvf_adapter {
 
 	unsigned int flags;
 	unsigned long last_reset;
+
+	u32 phys_port_id;
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
index 93eb7ee..475cccb 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1444,6 +1444,21 @@ static void igbvf_configure(struct igbvf_adapter *adapter)
 	                       igbvf_desc_unused(adapter->rx_ring));
 }
 
+static void igbvf_refresh_ppid(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int err;
+
+	err = hw->mac.ops.ppid_get_vf(hw, &adapter->phys_port_id);
+	if (err) {
+		adapter->phys_port_id_set = false;
+		dev_err(&adapter->pdev->dev,
+			"Failed to get physical port ID\n");
+	} else {
+		adapter->phys_port_id_set = true;
+	}
+}
+
 /* igbvf_reset - bring the hardware into a known good state
  *
  * This function boots the hardware and enables some settings that
@@ -1461,6 +1476,8 @@ static void igbvf_reset(struct igbvf_adapter *adapter)
 	if (mac->ops.reset_hw(hw))
 		dev_err(&adapter->pdev->dev, "PF still resetting\n");
 
+	igbvf_refresh_ppid(adapter);
+
 	mac->ops.init_hw(hw);
 
 	if (is_valid_ether_addr(adapter->hw.mac.addr)) {
@@ -1753,6 +1770,27 @@ static int igbvf_set_mac(struct net_device *netdev, void *p)
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
+	memcpy(ppid->id, &adapter->phys_port_id, ppid->id_len);
+
+	return 0;
+}
+
 #define UPDATE_VF_COUNTER(reg, name)                                    \
 	{                                                               \
 		u32 current_counter = er32(reg);                        \
@@ -2610,6 +2648,7 @@ static const struct net_device_ops igbvf_netdev_ops = {
 	.ndo_poll_controller            = igbvf_netpoll,
 #endif
 	.ndo_set_features               = igbvf_set_features,
+	.ndo_get_phys_port_id		= igbvf_get_phys_port_id,
 };
 
 /**
@@ -2750,6 +2789,10 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			dev_info(&pdev->dev, "MAC address not assigned by administrator.\n");
 		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
 		       netdev->addr_len);
+		err = hw->mac.ops.ppid_get_vf(hw, &adapter->phys_port_id);
+		if (err)
+			dev_err(&pdev->dev,
+				 "Failed to get physical port ID\n");
 	}
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
@@ -2759,6 +2802,8 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			netdev->addr_len);
 	}
 
+	igbvf_refresh_ppid(adapter);
+
 	setup_timer(&adapter->watchdog_timer, &igbvf_watchdog,
 	            (unsigned long) adapter);
 
diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
index eea0e10..1a4afa5 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.c
+++ b/drivers/net/ethernet/intel/igbvf/vf.c
@@ -39,6 +39,7 @@ static void e1000_update_mc_addr_list_vf(struct e1000_hw *hw, u8 *,
 static void e1000_rar_set_vf(struct e1000_hw *, u8 *, u32);
 static s32 e1000_read_mac_addr_vf(struct e1000_hw *);
 static s32 e1000_set_vfta_vf(struct e1000_hw *, u16, bool);
+static s32 e1000_ppid_get_vf(struct e1000_hw *hw, u32 *id);
 
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
+static s32 e1000_ppid_get_vf(struct e1000_hw *hw, u32 *id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	u32 msgbuf[2];
+	s32 ret_val;
+
+	memset(msgbuf, 0, sizeof(msgbuf));
+	msgbuf[0] = E1000_VF_GET_PHYS_PORT_ID;
+
+	ret_val = mbx->ops.write_posted(hw, msgbuf, 1);
+	if (ret_val)
+		goto out;
+
+	ret_val = mbx->ops.read_posted(hw, msgbuf, 2);
+	if (ret_val)
+		goto out;
+
+	if (msgbuf[0] & E1000_VT_MSGTYPE_NACK) {
+		ret_val = -E1000_ERR_MAC_INIT;
+		goto out;
+	}
+	*id = msgbuf[1];
+
+out:
+	return ret_val;
+}
diff --git a/drivers/net/ethernet/intel/igbvf/vf.h b/drivers/net/ethernet/intel/igbvf/vf.h
index 57db3c6..aa04f46 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.h
+++ b/drivers/net/ethernet/intel/igbvf/vf.h
@@ -188,6 +188,7 @@ struct e1000_mac_operations {
 	void (*rar_set)(struct e1000_hw *, u8*, u32);
 	s32  (*read_mac_addr)(struct e1000_hw *);
 	s32  (*set_vfta)(struct e1000_hw *, u16, bool);
+	s32  (*ppid_get_vf)(struct e1000_hw *, u32 *);
 };
 
 struct e1000_mac_info {
-- 
1.8.1.4

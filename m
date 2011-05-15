From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 02/13] ixgbevf: Add macvlan support in the set rx mode op
Date: Sat, 14 May 2011 18:23:36 -0700
Message-ID: <1305422627-9583-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1031 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755970Ab1EOBXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:50 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Implement setup of unicast address list in the VF driver's set_rx_mode
netdev op.  Unicast addresses are sent to the PF via a mailbox message
and the PF will check if it has room in the RAR table and if so set the
filter for the VF.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/ixgbevf_main.c |   30 ++++++++++++++++++++++++++++++
 drivers/net/ixgbevf/mbx.h          |    1 +
 drivers/net/ixgbevf/vf.c           |   34 ++++++++++++++++++++++++++++++++++
 drivers/net/ixgbevf/vf.h           |    1 +
 4 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 05fa7c8..d7ab202 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -1460,6 +1460,34 @@ static void ixgbevf_restore_vlan(struct ixgbevf_adapter *adapter)
 	}
 }
 
+static int ixgbevf_write_uc_addr_list(struct net_device *netdev)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	int count = 0;
+
+	if ((netdev_uc_count(netdev)) > 10) {
+		printk(KERN_ERR "Too many unicast filters - No Space\n");
+		return -ENOSPC;
+	}
+
+	if (!netdev_uc_empty(netdev)) {
+		struct netdev_hw_addr *ha;
+		netdev_for_each_uc_addr(ha, netdev) {
+			hw->mac.ops.set_uc_addr(hw, ++count, ha->addr);
+			udelay(200);
+		}
+	} else {
+		/*
+		 * If the list is empty then send message to PF driver to
+		 * clear all macvlans on this VF.
+		 */
+		hw->mac.ops.set_uc_addr(hw, 0, NULL);
+	}
+
+	return count;
+}
+
 /**
  * ixgbevf_set_rx_mode - Multicast set
  * @netdev: network interface device structure
@@ -1476,6 +1504,8 @@ static void ixgbevf_set_rx_mode(struct net_device *netdev)
 	/* reprogram multicast list */
 	if (hw->mac.ops.update_mc_addr_list)
 		hw->mac.ops.update_mc_addr_list(hw, netdev);
+
+	ixgbevf_write_uc_addr_list(netdev);
 }
 
 static void ixgbevf_napi_enable_all(struct ixgbevf_adapter *adapter)
diff --git a/drivers/net/ixgbevf/mbx.h b/drivers/net/ixgbevf/mbx.h
index b2b5bf5..ea393eb 100644
--- a/drivers/net/ixgbevf/mbx.h
+++ b/drivers/net/ixgbevf/mbx.h
@@ -81,6 +81,7 @@
 #define IXGBE_VF_SET_MULTICAST    0x03 /* VF requests PF to set MC addr */
 #define IXGBE_VF_SET_VLAN         0x04 /* VF requests PF to set VLAN */
 #define IXGBE_VF_SET_LPE          0x05 /* VF requests PF to set VMOLR.LPE */
+#define IXGBE_VF_SET_MACVLAN      0x06 /* VF requests PF for unicast filter */
 
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN 4
diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/ixgbevf/vf.c
index eecd3bf..aa3682e 100644
--- a/drivers/net/ixgbevf/vf.c
+++ b/drivers/net/ixgbevf/vf.c
@@ -216,6 +216,39 @@ static s32 ixgbevf_get_mac_addr_vf(struct ixgbe_hw *hw, u8 *mac_addr)
 	return 0;
 }
 
+static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	u32 msgbuf[3];
+	u8 *msg_addr = (u8 *)(&msgbuf[1]);
+	s32 ret_val;
+
+	memset(msgbuf, 0, sizeof(msgbuf));
+	/*
+	 * If index is one then this is the start of a new list and needs
+	 * indication to the PF so it can do it's own list management.
+	 * If it is zero then that tells the PF to just clear all of
+	 * this VF's macvlans and there is no new list.
+	 */
+	msgbuf[0] |= index << IXGBE_VT_MSGINFO_SHIFT;
+	msgbuf[0] |= IXGBE_VF_SET_MACVLAN;
+	if (addr)
+		memcpy(msg_addr, addr, 6);
+	ret_val = mbx->ops.write_posted(hw, msgbuf, 3);
+
+	if (!ret_val)
+		ret_val = mbx->ops.read_posted(hw, msgbuf, 3);
+
+	msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
+
+	if (!ret_val)
+		if (msgbuf[0] ==
+		    (IXGBE_VF_SET_MACVLAN | IXGBE_VT_MSGTYPE_NACK))
+			ret_val = -ENOMEM;
+
+	return ret_val;
+}
+
 /**
  *  ixgbevf_set_rar_vf - set device MAC address
  *  @hw: pointer to hardware structure
@@ -378,6 +411,7 @@ static struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.check_link          = ixgbevf_check_mac_link_vf,
 	.set_rar             = ixgbevf_set_rar_vf,
 	.update_mc_addr_list = ixgbevf_update_mc_addr_list_vf,
+	.set_uc_addr         = ixgbevf_set_uc_addr_vf,
 	.set_vfta            = ixgbevf_set_vfta_vf,
 };
 
diff --git a/drivers/net/ixgbevf/vf.h b/drivers/net/ixgbevf/vf.h
index 23eb114..10306b4 100644
--- a/drivers/net/ixgbevf/vf.h
+++ b/drivers/net/ixgbevf/vf.h
@@ -62,6 +62,7 @@ struct ixgbe_mac_operations {
 
 	/* RAR, Multicast, VLAN */
 	s32 (*set_rar)(struct ixgbe_hw *, u32, u8 *, u32);
+	s32 (*set_uc_addr)(struct ixgbe_hw *, u32, u8 *);
 	s32 (*init_rx_addrs)(struct ixgbe_hw *);
 	s32 (*update_mc_addr_list)(struct ixgbe_hw *, struct net_device *);
 	s32 (*enable_mc)(struct ixgbe_hw *);
-- 
1.7.4.4


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 1/7] ixgbe: Enable Jumbo Frames on the X540 10Gigabit Controller
Date: Thu, 24 Feb 2011 02:58:23 -0800
Message-ID: <1298545109-8990-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8720 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755489Ab1BXK6f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 05:58:35 -0500
In-Reply-To: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The X540 controller supports jumbo frames in SR-IOV mode.  Allow
configuration of jumbo frames either in the PF driver or on behalf of
a VF.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c  |   18 ++++++++++++++++--
 drivers/net/ixgbe/ixgbe_sriov.c |   29 ++++++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_type.h  |    2 ++
 3 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index eca762d..f0d0c5a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3077,6 +3077,14 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 	ixgbe_configure_srrctl(adapter, ring);
 	ixgbe_configure_rscctl(adapter, ring);
 
+	/* If operating in IOV mode set RLPML for X540 */
+	if ((adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) &&
+	    hw->mac.type == ixgbe_mac_X540) {
+		rxdctl &= ~IXGBE_RXDCTL_RLPMLMASK;
+		rxdctl |= ((ring->netdev->mtu + ETH_HLEN +
+			    ETH_FCS_LEN + VLAN_HLEN) | IXGBE_RXDCTL_RLPML_EN);
+	}
+
 	if (hw->mac.type == ixgbe_mac_82598EB) {
 		/*
 		 * enable cache line friendly hardware writes:
@@ -5441,8 +5449,14 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
 	/* MTU < 68 is an error and causes problems on some kernels */
-	if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
-		return -EINVAL;
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED &&
+	    hw->mac.type != ixgbe_mac_X540) {
+		if ((new_mtu < 68) || (max_frame > MAXIMUM_ETHERNET_VLAN_SIZE))
+			return -EINVAL;
+	} else {
+		if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
+			return -EINVAL;
+	}
 
 	e_info(probe, "changing MTU from %d to %d\n", netdev->mtu, new_mtu);
 	/* must set new MTU before calling down or up */
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 187b3a1..fb4868d 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -110,6 +110,33 @@ static int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid,
 	return adapter->hw.mac.ops.set_vfta(&adapter->hw, vid, vf, (bool)add);
 }
 
+void ixgbe_set_vf_lpe(struct ixgbe_adapter *adapter, u32 *msgbuf)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int new_mtu = msgbuf[1];
+	u32 max_frs;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+
+	/* Only X540 supports jumbo frames in IOV mode */
+	if (adapter->hw.mac.type != ixgbe_mac_X540)
+		return;
+
+	/* MTU < 68 is an error and causes problems on some kernels */
+	if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE)) {
+		e_err(drv, "VF mtu %d out of range\n", new_mtu);
+		return;
+	}
+
+	max_frs = (IXGBE_READ_REG(hw, IXGBE_MAXFRS) &
+		   IXGBE_MHADD_MFS_MASK) >> IXGBE_MHADD_MFS_SHIFT;
+	if (max_frs < new_mtu) {
+		max_frs = new_mtu << IXGBE_MHADD_MFS_SHIFT;
+		IXGBE_WRITE_REG(hw, IXGBE_MAXFRS, max_frs);
+	}
+
+	e_info(hw, "VF requests change max MTU to %d\n", new_mtu);
+}
+
 static void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf, bool aupe)
 {
 	u32 vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
@@ -302,7 +329,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 		                                 hash_list, vf);
 		break;
 	case IXGBE_VF_SET_LPE:
-		WARN_ON((msgbuf[0] & 0xFFFF) == IXGBE_VF_SET_LPE);
+		ixgbe_set_vf_lpe(adapter, msgbuf);
 		break;
 	case IXGBE_VF_SET_VLAN:
 		add = (msgbuf[0] & IXGBE_VT_MSGINFO_MASK)
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index fd3358f..ab65d13 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1680,6 +1680,8 @@
 #define IXGBE_RXCTRL_DMBYPS     0x00000002  /* Descriptor Monitor Bypass */
 #define IXGBE_RXDCTL_ENABLE     0x02000000  /* Enable specific Rx Queue */
 #define IXGBE_RXDCTL_VME        0x40000000  /* VLAN mode enable */
+#define IXGBE_RXDCTL_RLPMLMASK  0x00003FFF  /* Only supported on the X540 */
+#define IXGBE_RXDCTL_RLPML_EN   0x00008000
 
 #define IXGBE_FCTRL_SBP 0x00000002 /* Store Bad Packet */
 #define IXGBE_FCTRL_MPE 0x00000100 /* Multicast Promiscuous Ena*/
-- 
1.7.4


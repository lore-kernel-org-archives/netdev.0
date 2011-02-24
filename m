From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 2/7] ixgbevf: Enable jumbo frame support for X540 VF
Date: Thu, 24 Feb 2011 02:58:24 -0800
Message-ID: <1298545109-8990-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49882 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756088Ab1BXK6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 05:58:36 -0500
In-Reply-To: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The X540 controller allows jumbo frame setup on a per VF basis.  Enable
use of jumbo frames when the VF device belongs to the X540 controller.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/defines.h      |    2 ++
 drivers/net/ixgbevf/ixgbevf_main.c |   19 +++++++++++++++++--
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbevf/defines.h b/drivers/net/ixgbevf/defines.h
index de643eb..78abb6f 100644
--- a/drivers/net/ixgbevf/defines.h
+++ b/drivers/net/ixgbevf/defines.h
@@ -65,6 +65,8 @@ typedef u32 ixgbe_link_speed;
 #define IXGBE_RXCTRL_DMBYPS     0x00000002  /* Descriptor Monitor Bypass */
 #define IXGBE_RXDCTL_ENABLE     0x02000000  /* Enable specific Rx Queue */
 #define IXGBE_RXDCTL_VME        0x40000000  /* VLAN mode enable */
+#define IXGBE_RXDCTL_RLPMLMASK  0x00003FFF  /* Only supported on the X540 */
+#define IXGBE_RXDCTL_RLPML_EN   0x00008000
 
 /* DCA Control */
 #define IXGBE_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 464e6c9..1f36f8f 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -51,7 +51,7 @@ char ixgbevf_driver_name[] = "ixgbevf";
 static const char ixgbevf_driver_string[] =
 	"Intel(R) 82599 Virtual Function";
 
-#define DRV_VERSION "1.0.19-k0"
+#define DRV_VERSION "1.1.0-k0"
 const char ixgbevf_driver_version[] = DRV_VERSION;
 static char ixgbevf_copyright[] =
 	"Copyright (c) 2009 - 2010 Intel Corporation.";
@@ -1665,6 +1665,11 @@ static int ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 		j = adapter->rx_ring[i].reg_idx;
 		rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(j));
 		rxdctl |= IXGBE_RXDCTL_ENABLE;
+		if (hw->mac.type == ixgbe_mac_X540_vf) {
+			rxdctl &= ~IXGBE_RXDCTL_RLPMLMASK;
+			rxdctl |= ((netdev->mtu + ETH_HLEN + ETH_FCS_LEN) |
+				   IXGBE_RXDCTL_RLPML_EN);
+		}
 		IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(j), rxdctl);
 		ixgbevf_rx_desc_queue_enable(adapter, i);
 	}
@@ -3217,10 +3222,16 @@ static int ixgbevf_set_mac(struct net_device *netdev, void *p)
 static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+	int max_possible_frame = MAXIMUM_ETHERNET_VLAN_SIZE;
+	u32 msg[2];
+
+	if (adapter->hw.mac.type == ixgbe_mac_X540_vf)
+		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
 
 	/* MTU < 68 is an error and causes problems on some kernels */
-	if ((new_mtu < 68) || (max_frame > MAXIMUM_ETHERNET_VLAN_SIZE))
+	if ((new_mtu < 68) || (max_frame > max_possible_frame))
 		return -EINVAL;
 
 	hw_dbg(&adapter->hw, "changing MTU from %d to %d\n",
@@ -3228,6 +3239,10 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
 
+	msg[0] = IXGBE_VF_SET_LPE;
+	msg[1] = max_frame;
+	hw->mbx.ops.write_posted(hw, msg, 2);
+
 	if (netif_running(netdev))
 		ixgbevf_reinit_locked(adapter);
 
-- 
1.7.4


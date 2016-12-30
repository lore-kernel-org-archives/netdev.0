From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 20/21] ixgbevf: Add support for VF promiscuous mode
Date: Fri, 30 Dec 2016 01:33:40 -0800
Message-ID: <20161230093341.14674-21-jeffrey.t.kirsher@intel.com>
References: <20161230093341.14674-1-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:32169 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752365AbcL3Jdu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Dec 2016 04:33:50 -0500
In-Reply-To: <20161230093341.14674-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch extends the mailbox message to allow for VF promiscuous
mode support.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 15 +++++++++++++-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  1 +
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 24 +++++++++++++++++++----
 4 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 5639fbe..3fe6504 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -464,6 +464,7 @@ enum ixgbevf_xcast_modes {
 	IXGBEVF_XCAST_MODE_NONE = 0,
 	IXGBEVF_XCAST_MODE_MULTI,
 	IXGBEVF_XCAST_MODE_ALLMULTI,
+	IXGBEVF_XCAST_MODE_PROMISC,
 };
 
 extern const struct ixgbevf_info ixgbevf_82599_vf_info;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 544307c..dbdd938 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1930,6 +1930,16 @@ static void ixgbevf_set_rx_mode(struct net_device *netdev)
 		     (flags & (IFF_BROADCAST | IFF_MULTICAST)) ?
 		     IXGBEVF_XCAST_MODE_MULTI : IXGBEVF_XCAST_MODE_NONE;
 
+	/* request the most inclusive mode we need */
+	if (flags & IFF_PROMISC)
+		xcast_mode = IXGBEVF_XCAST_MODE_PROMISC;
+	else if (flags & IFF_ALLMULTI)
+		xcast_mode = IXGBEVF_XCAST_MODE_ALLMULTI;
+	else if (flags & (IFF_BROADCAST | IFF_MULTICAST))
+		xcast_mode = IXGBEVF_XCAST_MODE_MULTI;
+	else
+		xcast_mode = IXGBEVF_XCAST_MODE_NONE;
+
 	spin_lock_bh(&adapter->mbx_lock);
 
 	hw->mac.ops.update_xcast_mode(hw, xcast_mode);
@@ -2071,7 +2081,8 @@ static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
 static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int api[] = { ixgbe_mbox_api_12,
+	int api[] = { ixgbe_mbox_api_13,
+		      ixgbe_mbox_api_12,
 		      ixgbe_mbox_api_11,
 		      ixgbe_mbox_api_10,
 		      ixgbe_mbox_api_unknown };
@@ -2373,6 +2384,7 @@ static void ixgbevf_set_num_queues(struct ixgbevf_adapter *adapter)
 		switch (hw->api_version) {
 		case ixgbe_mbox_api_11:
 		case ixgbe_mbox_api_12:
+		case ixgbe_mbox_api_13:
 			adapter->num_rx_queues = rss;
 			adapter->num_tx_queues = rss;
 		default:
@@ -4117,6 +4129,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	switch (adapter->hw.api_version) {
 	case ixgbe_mbox_api_11:
 	case ixgbe_mbox_api_12:
+	case ixgbe_mbox_api_13:
 		netdev->max_mtu = IXGBE_MAX_JUMBO_FRAME_SIZE -
 				  (ETH_HLEN + ETH_FCS_LEN);
 		break;
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 340cdd4..bc0442a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -84,6 +84,7 @@ enum ixgbe_pfvf_api_rev {
 	ixgbe_mbox_api_20,	/* API version 2.0, solaris Phase1 VF driver */
 	ixgbe_mbox_api_11,	/* API version 1.1, linux/freebsd VF driver */
 	ixgbe_mbox_api_12,	/* API version 1.2, linux/freebsd VF driver */
+	ixgbe_mbox_api_13,	/* API version 1.3, linux/freebsd VF driver */
 	/* This value should always be last */
 	ixgbe_mbox_api_unknown,	/* indicates that API version is not known */
 };
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index d46ba1d..8a5db9d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -330,9 +330,14 @@ int ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *reta, int num_rx_queues)
 	 * Thus return an error if API doesn't support RETA querying or querying
 	 * is not supported for this device type.
 	 */
-	if (hw->api_version != ixgbe_mbox_api_12 ||
-	    hw->mac.type >= ixgbe_mac_X550_vf)
+	switch (hw->api_version) {
+	case ixgbe_mbox_api_13:
+	case ixgbe_mbox_api_12:
+		if (hw->mac.type >= ixgbe_mac_X550_vf)
+			break;
+	default:
 		return -EOPNOTSUPP;
+	}
 
 	msgbuf[0] = IXGBE_VF_GET_RETA;
 
@@ -391,9 +396,14 @@ int ixgbevf_get_rss_key_locked(struct ixgbe_hw *hw, u8 *rss_key)
 	 * Thus return an error if API doesn't support RSS Random Key retrieval
 	 * or if the operation is not supported for this device type.
 	 */
-	if (hw->api_version != ixgbe_mbox_api_12 ||
-	    hw->mac.type >= ixgbe_mac_X550_vf)
+	switch (hw->api_version) {
+	case ixgbe_mbox_api_13:
+	case ixgbe_mbox_api_12:
+		if (hw->mac.type >= ixgbe_mac_X550_vf)
+			break;
+	default:
 		return -EOPNOTSUPP;
+	}
 
 	msgbuf[0] = IXGBE_VF_GET_RSS_KEY;
 	err = hw->mbx.ops.write_posted(hw, msgbuf, 1);
@@ -545,6 +555,11 @@ static s32 ixgbevf_update_xcast_mode(struct ixgbe_hw *hw, int xcast_mode)
 
 	switch (hw->api_version) {
 	case ixgbe_mbox_api_12:
+		/* promisc introduced in 1.3 version */
+		if (xcast_mode == IXGBEVF_XCAST_MODE_PROMISC)
+			return -EOPNOTSUPP;
+		/* Fall threw */
+	case ixgbe_mbox_api_13:
 		break;
 	default:
 		return -EOPNOTSUPP;
@@ -884,6 +899,7 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 	switch (hw->api_version) {
 	case ixgbe_mbox_api_11:
 	case ixgbe_mbox_api_12:
+	case ixgbe_mbox_api_13:
 		break;
 	default:
 		return 0;
-- 
2.9.3

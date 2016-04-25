From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] ixgbe: Add work around for empty SFP+ cage crosstalk
Date: Mon, 25 Apr 2016 05:44:23 -0700
Message-ID: <1461588269-128728-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10855 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932413AbcDYMog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 08:44:36 -0400
In-Reply-To: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

It is possible on some systems that crosstalk could lead to link flap
on empty SFP+ cages.  A new NVM bit was defined to let SW know it
needs to implement the work around which consists of verifying that
there is a module in the cage before acting on the LSC.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 39 +++++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  1 +
 3 files changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 94e39c1..22cf2a9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -803,6 +803,8 @@ struct ixgbe_adapter {
 
 #define IXGBE_RSS_KEY_SIZE     40  /* size of RSS Hash Key in bytes */
 	u32 rss_key[IXGBE_RSS_KEY_SIZE / sizeof(u32)];
+
+	bool need_crosstalk_fix;
 };
 
 static inline u8 ixgbe_max_rss_indices(struct ixgbe_adapter *adapter)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 517f06e..09d7c8bd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5572,6 +5572,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned int rss, fdir;
 	u32 fwsm;
+	u16 device_caps;
 #ifdef CONFIG_IXGBE_DCB
 	int j;
 	struct tc_configuration *tc;
@@ -5737,6 +5738,22 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->tx_ring_count = IXGBE_DEFAULT_TXD;
 	adapter->rx_ring_count = IXGBE_DEFAULT_RXD;
 
+	/* Cache bit indicating need for crosstalk fix */
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X550EM_x:
+	case ixgbe_mac_x550em_a:
+		hw->mac.ops.get_device_caps(hw, &device_caps);
+		if (device_caps & IXGBE_DEVICE_CAPS_NO_CROSSTALK_WR)
+			adapter->need_crosstalk_fix = false;
+		else
+			adapter->need_crosstalk_fix = true;
+		break;
+	default:
+		adapter->need_crosstalk_fix = false;
+		break;
+	}
+
 	/* set default work limits */
 	adapter->tx_work_limit = IXGBE_DEFAULT_TX_WORK;
 
@@ -6659,6 +6676,18 @@ static void ixgbe_watchdog_update_link(struct ixgbe_adapter *adapter)
 		link_up = true;
 	}
 
+	/* If Crosstalk fix enabled do the sanity check of making sure
+	 * the SFP+ cage is empty.
+	 */
+	if (adapter->need_crosstalk_fix) {
+		u32 sfp_cage_full;
+
+		sfp_cage_full = IXGBE_READ_REG(hw, IXGBE_ESDP) &
+				IXGBE_ESDP_SDP2;
+		if (ixgbe_is_sfp(hw) && link_up && !sfp_cage_full)
+			link_up = false;
+	}
+
 	if (adapter->ixgbe_ieee_pfc)
 		pfc_en |= !!(adapter->ixgbe_ieee_pfc->pfc_en);
 
@@ -7005,6 +7034,16 @@ static void ixgbe_sfp_detection_subtask(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	s32 err;
 
+	/* If crosstalk fix enabled verify the SFP+ cage is full */
+	if (adapter->need_crosstalk_fix) {
+		u32 sfp_cage_full;
+
+		sfp_cage_full = IXGBE_READ_REG(hw, IXGBE_ESDP) &
+				IXGBE_ESDP_SDP2;
+		if (!sfp_cage_full)
+			return;
+	}
+
 	/* not searching for SFP so there is nothing to do here */
 	if (!(adapter->flags2 & IXGBE_FLAG2_SEARCH_FOR_SFP) &&
 	    !(adapter->flags2 & IXGBE_FLAG2_SFP_NEEDS_RESET))
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 29a1c42..8e7decb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2124,6 +2124,7 @@ enum {
 #define IXGBE_SAN_MAC_ADDR_PORT1_OFFSET  0x3
 #define IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP  0x1
 #define IXGBE_DEVICE_CAPS_FCOE_OFFLOADS  0x2
+#define IXGBE_DEVICE_CAPS_NO_CROSSTALK_WR	BIT(7)
 #define IXGBE_FW_LESM_PARAMETERS_PTR     0x2
 #define IXGBE_FW_LESM_STATE_1            0x1
 #define IXGBE_FW_LESM_STATE_ENABLED      0x8000 /* LESM Enable bit */
-- 
2.5.5

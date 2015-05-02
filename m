From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] e1000e: Cleanup handling of VLAN_HLEN as a part of max frame size
Date: Sat,  2 May 2015 03:42:30 -0700
Message-ID: <1430563358-113833-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39277 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbbEBKmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 06:42:47 -0400
In-Reply-To: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

When the VLAN_HLEN was added to the calculation for the maximum frame size
there seems to have been a number of issues added to the driver.

The first issue is that in some cases the maximum frame size for a device
never really reached the actual maximum frame size as the VLAN header
length was not included the calculation for that value.  As a result some
parts only supported a maximum frame size of either 1496 in the case of
parts that didn't support jumbo frames, and 8996 in the case of the parts
that do.

The second issue is the fact that there were several checks that weren't
updated so as a result setting an MTU of 1500 was treated as enabling jumbo
frames as the calculated value was 1522 instead of 1518.  I have addressed
those by replacing ETH_FRAME_LEN with VLAN_ETH_FRAME_LEN where appropriate.

The final issue was the fact that lowering the MTU below 1500 would cause
the driver to allocate 2K buffers for the rings.  This is an old issue that
was fixed several years ago in igb/ixgbe and I am addressing now by just
replacing == with a <= so that we always just round up to 1522 for anything
that isn't a jumbo frame.

Fixes: c751a3d58cf2d ("e1000e: Correctly include VLAN_HLEN when changing interface MTU")
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c   |  2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 10 +++++-----
 drivers/net/ethernet/intel/e1000e/netdev.c  | 18 ++++++++----------
 3 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index dc79ed8..32e7775 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -2010,7 +2010,7 @@ const struct e1000_info e1000_82573_info = {
 	.flags2			= FLAG2_DISABLE_ASPM_L1
 				  | FLAG2_DISABLE_ASPM_L0S,
 	.pba			= 20,
-	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
+	.max_hw_frame_size	= VLAN_ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_m88,
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 9d81c03..e2498db 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1563,7 +1563,7 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	    ((adapter->hw.mac.type >= e1000_pch2lan) &&
 	     (!(er32(CTRL_EXT) & E1000_CTRL_EXT_LSECCK)))) {
 		adapter->flags &= ~FLAG_HAS_JUMBO_FRAMES;
-		adapter->max_hw_frame_size = ETH_FRAME_LEN + ETH_FCS_LEN;
+		adapter->max_hw_frame_size = VLAN_ETH_FRAME_LEN + ETH_FCS_LEN;
 
 		hw->mac.ops.blink_led = NULL;
 	}
@@ -5681,7 +5681,7 @@ const struct e1000_info e1000_ich8_info = {
 				  | FLAG_HAS_FLASH
 				  | FLAG_APME_IN_WUC,
 	.pba			= 8,
-	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
+	.max_hw_frame_size	= VLAN_ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
 	.phy_ops		= &ich8_phy_ops,
@@ -5754,7 +5754,7 @@ const struct e1000_info e1000_pch2_info = {
 	.flags2			= FLAG2_HAS_PHY_STATS
 				  | FLAG2_HAS_EEE,
 	.pba			= 26,
-	.max_hw_frame_size	= 9018,
+	.max_hw_frame_size	= 9022,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
 	.phy_ops		= &ich8_phy_ops,
@@ -5774,7 +5774,7 @@ const struct e1000_info e1000_pch_lpt_info = {
 	.flags2			= FLAG2_HAS_PHY_STATS
 				  | FLAG2_HAS_EEE,
 	.pba			= 26,
-	.max_hw_frame_size	= 9018,
+	.max_hw_frame_size	= 9022,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
 	.phy_ops		= &ich8_phy_ops,
@@ -5794,7 +5794,7 @@ const struct e1000_info e1000_pch_spt_info = {
 	.flags2			= FLAG2_HAS_PHY_STATS
 				  | FLAG2_HAS_EEE,
 	.pba			= 26,
-	.max_hw_frame_size	= 9018,
+	.max_hw_frame_size	= 9022,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
 	.phy_ops		= &ich8_phy_ops,
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c509a5c..68913d1 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3807,7 +3807,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	/* reset Packet Buffer Allocation to default */
 	ew32(PBA, pba);
 
-	if (adapter->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN) {
+	if (adapter->max_frame_size > (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)) {
 		/* To maintain wire speed transmits, the Tx FIFO should be
 		 * large enough to accommodate two full transmit packets,
 		 * rounded up to the next 1KB and expressed in KB.  Likewise,
@@ -4196,9 +4196,9 @@ static int e1000_sw_init(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
-	adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN;
+	adapter->rx_buffer_len = VLAN_ETH_FRAME_LEN + ETH_FCS_LEN;
 	adapter->rx_ps_bsize0 = 128;
-	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	adapter->max_frame_size = netdev->mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 	adapter->tx_ring_count = E1000_DEFAULT_TXD;
 	adapter->rx_ring_count = E1000_DEFAULT_RXD;
@@ -5781,17 +5781,17 @@ struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	int max_frame = new_mtu + VLAN_HLEN + ETH_HLEN + ETH_FCS_LEN;
+	int max_frame = new_mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
 
 	/* Jumbo frame support */
-	if ((max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) &&
+	if ((max_frame > (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)) &&
 	    !(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
 		e_err("Jumbo Frames not supported.\n");
 		return -EINVAL;
 	}
 
 	/* Supported frame sizes */
-	if ((new_mtu < ETH_ZLEN + ETH_FCS_LEN + VLAN_HLEN) ||
+	if ((new_mtu < (VLAN_ETH_ZLEN + ETH_FCS_LEN)) ||
 	    (max_frame > adapter->max_hw_frame_size)) {
 		e_err("Unsupported MTU setting\n");
 		return -EINVAL;
@@ -5831,10 +5831,8 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		adapter->rx_buffer_len = 4096;
 
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
-	if ((max_frame == ETH_FRAME_LEN + ETH_FCS_LEN) ||
-	    (max_frame == ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN))
-		adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN
-		    + ETH_FCS_LEN;
+	if (max_frame <= (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN))
+		adapter->rx_buffer_len = VLAN_ETH_FRAME_LEN + ETH_FCS_LEN;
 
 	if (netif_running(netdev))
 		e1000e_up(adapter);
-- 
2.1.0

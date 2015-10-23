From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 2/4] e1000e: Add ndo_enc_hdr_len
Date: Fri, 23 Oct 2015 12:49:31 +0900
Message-ID: <1445572173-15402-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1445572173-15402-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:36964 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbbJWDuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 23:50:04 -0400
In-Reply-To: <1445572173-15402-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000e has 4 bytes additional room for vlan header, so set default
enc_hdr_len to 4.
Note that e1000e uses mtu to validate frame size in some places, which
are needed to be modified to use max_frame_size as extra header room
became variable.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 79 +++++++++++++++++++++---------
 1 file changed, 57 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 0a854a4..6a54f07 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3046,7 +3046,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	if (hw->mac.type >= e1000_pch2lan) {
 		s32 ret_val;
 
-		if (adapter->netdev->mtu > ETH_DATA_LEN)
+		if (adapter->max_frame_size > VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
 			ret_val = e1000_lv_jumbo_workaround_ich8lan(hw, true);
 		else
 			ret_val = e1000_lv_jumbo_workaround_ich8lan(hw, false);
@@ -3066,7 +3066,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	rctl &= ~E1000_RCTL_SBP;
 
 	/* Enable Long Packet receive */
-	if (adapter->netdev->mtu <= ETH_DATA_LEN)
+	if (adapter->max_frame_size <= VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
 		rctl &= ~E1000_RCTL_LPE;
 	else
 		rctl |= E1000_RCTL_LPE;
@@ -3286,7 +3286,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	/* With jumbo frames, excessive C-state transition latencies result
 	 * in dropped transactions.
 	 */
-	if (adapter->netdev->mtu > ETH_DATA_LEN) {
+	if (adapter->max_frame_size > VLAN_ETH_FRAME_LEN + ETH_FCS_LEN) {
 		u32 lat =
 		    ((er32(PBA) & E1000_PBA_RXA_MASK) * 1024 -
 		     adapter->max_frame_size) * 8 / 1000;
@@ -3978,7 +3978,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	switch (hw->mac.type) {
 	case e1000_ich9lan:
 	case e1000_ich10lan:
-		if (adapter->netdev->mtu > ETH_DATA_LEN) {
+		if (adapter->max_frame_size > VLAN_ETH_FRAME_LEN + ETH_FCS_LEN) {
 			pba = 14;
 			ew32(PBA, pba);
 			fc->high_water = 0x2800;
@@ -3997,7 +3997,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		/* Workaround PCH LOM adapter hangs with certain network
 		 * loads.  If hangs persist, try disabling Tx flow control.
 		 */
-		if (adapter->netdev->mtu > ETH_DATA_LEN) {
+		if (adapter->max_frame_size > VLAN_ETH_FRAME_LEN + ETH_FCS_LEN) {
 			fc->high_water = 0x3500;
 			fc->low_water = 0x1500;
 		} else {
@@ -4011,7 +4011,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	case e1000_pch_spt:
 		fc->refresh_time = 0x0400;
 
-		if (adapter->netdev->mtu <= ETH_DATA_LEN) {
+		if (adapter->max_frame_size <= VLAN_ETH_FRAME_LEN + ETH_FCS_LEN) {
 			fc->high_water = 0x05C20;
 			fc->low_water = 0x05048;
 			fc->pause_time = 0x0650;
@@ -4247,7 +4247,7 @@ void e1000e_down(struct e1000_adapter *adapter, bool reset)
 
 	/* Disable Si errata workaround on PCHx for jumbo frame flow */
 	if ((hw->mac.type >= e1000_pch2lan) &&
-	    (adapter->netdev->mtu > ETH_DATA_LEN) &&
+	    (adapter->max_frame_size > VLAN_ETH_FRAME_LEN + ETH_FCS_LEN) &&
 	    e1000_lv_jumbo_workaround_ich8lan(hw, false))
 		e_dbg("failed to disable jumbo frame workaround mode\n");
 
@@ -4346,7 +4346,8 @@ static int e1000_sw_init(struct e1000_adapter *adapter)
 
 	adapter->rx_buffer_len = VLAN_ETH_FRAME_LEN + ETH_FCS_LEN;
 	adapter->rx_ps_bsize0 = 128;
-	adapter->max_frame_size = netdev->mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
+	adapter->max_frame_size = netdev->mtu + netdev->enc_hdr_len +
+				  ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 	adapter->tx_ring_count = E1000_DEFAULT_TXD;
 	adapter->rx_ring_count = E1000_DEFAULT_RXD;
@@ -5920,17 +5921,10 @@ struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
 	return stats;
 }
 
-/**
- * e1000_change_mtu - Change the Maximum Transfer Unit
- * @netdev: network interface device structure
- * @new_mtu: new value for maximum frame size
- *
- * Returns 0 on success, negative on failure
- **/
-static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
+static int e1000_change_max_frame(struct net_device *netdev, int max_frame,
+				  int new_mtu)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	int max_frame = new_mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
 
 	/* Jumbo frame support */
 	if ((max_frame > (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)) &&
@@ -5940,7 +5934,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	}
 
 	/* Supported frame sizes */
-	if ((new_mtu < (VLAN_ETH_ZLEN + ETH_FCS_LEN)) ||
+	if ((new_mtu && new_mtu < (VLAN_ETH_ZLEN + ETH_FCS_LEN)) ||
 	    (max_frame > adapter->max_hw_frame_size)) {
 		e_err("Unsupported MTU setting\n");
 		return -EINVAL;
@@ -5949,7 +5943,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	/* Jumbo frame workaround on 82579 and newer requires CRC be stripped */
 	if ((adapter->hw.mac.type >= e1000_pch2lan) &&
 	    !(adapter->flags2 & FLAG2_CRC_STRIPPING) &&
-	    (new_mtu > ETH_DATA_LEN)) {
+	    (max_frame > VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)) {
 		e_err("Jumbo Frames not supported on this device when CRC stripping is disabled.\n");
 		return -EINVAL;
 	}
@@ -5957,9 +5951,14 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
 	/* e1000e_down -> e1000e_reset dependent on max_frame_size & mtu */
+	if (new_mtu) {
+		e_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
+		netdev->mtu = new_mtu;
+	} else {
+		e_info("changing max frame size from %d to %d\n",
+		       adapter->max_frame_size, max_frame);
+	}
 	adapter->max_frame_size = max_frame;
-	e_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
-	netdev->mtu = new_mtu;
 
 	pm_runtime_get_sync(netdev->dev.parent);
 
@@ -5995,6 +5994,20 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
+/**
+ * e1000_change_mtu - Change the Maximum Transfer Unit
+ * @netdev: network interface device structure
+ * @new_mtu: new value for maximum frame size
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	int max_frame = new_mtu + netdev->enc_hdr_len + ETH_HLEN + ETH_FCS_LEN;
+
+	return e1000_change_max_frame(netdev, max_frame, new_mtu);
+}
+
 static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 			   int cmd)
 {
@@ -6889,7 +6902,8 @@ static netdev_features_t e1000_fix_features(struct net_device *netdev,
 	struct e1000_hw *hw = &adapter->hw;
 
 	/* Jumbo frame workaround on 82579 and newer requires CRC be stripped */
-	if ((hw->mac.type >= e1000_pch2lan) && (netdev->mtu > ETH_DATA_LEN))
+	if (hw->mac.type >= e1000_pch2lan &&
+	    adapter->max_frame_size > VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
 		features &= ~NETIF_F_RXFCS;
 
 	return features;
@@ -6933,6 +6947,24 @@ static int e1000_set_features(struct net_device *netdev,
 	return 0;
 }
 
+/**
+ * e1000_enc_hdr_len - Expand encapsulation header room
+ * @netdev: network interface device structure
+ * @new_mtu: new value for maximum encapsulation header length
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int e1000_enc_hdr_len(struct net_device *netdev, int new_len)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	int max_frame = netdev->mtu + new_len + ETH_HLEN + ETH_FCS_LEN;
+
+	if (max_frame <= adapter->max_frame_size)
+		return 0;
+
+	return e1000_change_max_frame(netdev, max_frame, 0);
+}
+
 static const struct net_device_ops e1000e_netdev_ops = {
 	.ndo_open		= e1000_open,
 	.ndo_stop		= e1000_close,
@@ -6953,6 +6985,7 @@ static const struct net_device_ops e1000e_netdev_ops = {
 	.ndo_set_features = e1000_set_features,
 	.ndo_fix_features = e1000_fix_features,
 	.ndo_features_check	= passthru_features_check,
+	.ndo_enc_hdr_len	= e1000_enc_hdr_len,
 };
 
 /**
@@ -7075,6 +7108,8 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->mem_start = mmio_start;
 	netdev->mem_end = mmio_start + mmio_len;
 
+	netdev->enc_hdr_len = VLAN_HLEN;
+
 	adapter->bd_number = cards_found++;
 
 	e1000e_check_options(adapter);
-- 
1.8.1.2

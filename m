From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 03/15] ethernet/intel: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:05 -0400
Message-ID: <20161017195417.48259-4-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35110 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758787AbcJQTy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 15:54:29 -0400
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e100: min_mtu 68, max_mtu 1500
- remove e100_change_mtu entirely, is identical to old eth_change_mtu,
  and no longer serves a purpose. No need to set min_mtu or max_mtu
  explicitly, as ether_setup() will already set them to 68 and 1500.

e1000: min_mtu 46, max_mtu 16110

e1000e: min_mtu 68, max_mtu varies based on adapter

fm10k: min_mtu 68, max_mtu 15342
- remove fm10k_change_mtu entirely, does nothing now

i40e: min_mtu 68, max_mtu 9706

i40evf: min_mtu 68, max_mtu 9706

igb: min_mtu 68, max_mtu 9216
- There are two different "max" frame sizes claimed and both checked in
  the driver, the larger value wasn't relevant though, so I've set max_mtu
  to the smaller of the two values here to retain identical behavior.

igbvf: min_mtu 68, max_mtu 9216
- Same issue as igb duplicated

ixgb: min_mtu 68, max_mtu 16114
- Also remove pointless old == new check, as that's done in dev_set_mtu

ixgbe: min_mtu 68, max_mtu 9710

ixgbevf: min_mtu 68, max_mtu dependent on hardware/firmware
- Some hw can only handle up to max_mtu 1504 on a vf, others 9710

CC: netdev@vger.kernel.org
CC: intel-wired-lan@lists.osuosl.org
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/intel/e100.c                 |  9 -------
 drivers/net/ethernet/intel/e1000/e1000_main.c     | 12 ++++-----
 drivers/net/ethernet/intel/e1000e/netdev.c        | 14 +++++-----
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c   | 15 +++--------
 drivers/net/ethernet/intel/i40e/i40e_main.c       | 10 +++----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |  8 +++---
 drivers/net/ethernet/intel/igb/e1000_defines.h    |  3 ++-
 drivers/net/ethernet/intel/igb/igb_main.c         | 15 +++--------
 drivers/net/ethernet/intel/igbvf/defines.h        |  3 ++-
 drivers/net/ethernet/intel/igbvf/netdev.c         | 14 +++-------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       | 16 +++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 11 ++++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 33 ++++++++++++-----------
 13 files changed, 62 insertions(+), 101 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 068789e..25c6dfd 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2286,14 +2286,6 @@ static int e100_set_mac_address(struct net_device *netdev, void *p)
 	return 0;
 }
 
-static int e100_change_mtu(struct net_device *netdev, int new_mtu)
-{
-	if (new_mtu < ETH_ZLEN || new_mtu > ETH_DATA_LEN)
-		return -EINVAL;
-	netdev->mtu = new_mtu;
-	return 0;
-}
-
 static int e100_asf(struct nic *nic)
 {
 	/* ASF can be enabled from eeprom */
@@ -2834,7 +2826,6 @@ static const struct net_device_ops e100_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= e100_set_multicast_list,
 	.ndo_set_mac_address	= e100_set_mac_address,
-	.ndo_change_mtu		= e100_change_mtu,
 	.ndo_do_ioctl		= e100_do_ioctl,
 	.ndo_tx_timeout		= e100_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index f42129d..33076fa 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1085,6 +1085,10 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	    hw->subsystem_vendor_id != PCI_VENDOR_ID_VMWARE)
 		netdev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* MTU range: 46 - 16110 */
+	netdev->min_mtu = ETH_ZLEN - ETH_HLEN;
+	netdev->max_mtu = MAX_JUMBO_FRAME_SIZE - (ETH_HLEN + ETH_FCS_LEN);
+
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(hw);
 
 	/* initialize eeprom parameters */
@@ -3549,13 +3553,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
-
-	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
-	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		e_err(probe, "Invalid MTU setting\n");
-		return -EINVAL;
-	}
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
 	/* Adapter-specific max frame size limits. */
 	switch (hw->mac_type) {
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7017281..8759d92 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5974,19 +5974,12 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	int max_frame = new_mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
 
 	/* Jumbo frame support */
-	if ((max_frame > (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)) &&
+	if ((new_mtu > ETH_DATA_LEN) &&
 	    !(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
 		e_err("Jumbo Frames not supported.\n");
 		return -EINVAL;
 	}
 
-	/* Supported frame sizes */
-	if ((new_mtu < (VLAN_ETH_ZLEN + ETH_FCS_LEN)) ||
-	    (max_frame > adapter->max_hw_frame_size)) {
-		e_err("Unsupported MTU setting\n");
-		return -EINVAL;
-	}
-
 	/* Jumbo frame workaround on 82579 and newer requires CRC be stripped */
 	if ((adapter->hw.mac.type >= e1000_pch2lan) &&
 	    !(adapter->flags2 & FLAG2_CRC_STRIPPING) &&
@@ -7187,6 +7180,11 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
 
+	/* MTU range: 68 - max_hw_frame_size */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = adapter->max_hw_frame_size -
+			  (VLAN_ETH_HLEN + ETH_FCS_LEN);
+
 	if (e1000e_enable_mng_pass_thru(&adapter->hw))
 		adapter->flags |= FLAG_MNG_PT_ENABLED;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 0562938..bc5ef6e 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -706,16 +706,6 @@ static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 	return err;
 }
 
-static int fm10k_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if (new_mtu < 68 || new_mtu > FM10K_MAX_JUMBO_FRAME_SIZE)
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-
-	return 0;
-}
-
 /**
  * fm10k_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
@@ -1405,7 +1395,6 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_start_xmit		= fm10k_xmit_frame,
 	.ndo_set_mac_address	= fm10k_set_mac,
-	.ndo_change_mtu		= fm10k_change_mtu,
 	.ndo_tx_timeout		= fm10k_tx_timeout,
 	.ndo_vlan_rx_add_vid	= fm10k_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= fm10k_vlan_rx_kill_vid,
@@ -1490,5 +1479,9 @@ struct net_device *fm10k_alloc_netdev(const struct fm10k_info *info)
 
 	dev->hw_features |= hw_features;
 
+	/* MTU range: 68 - 15342 */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = FM10K_MAX_JUMBO_FRAME_SIZE;
+
 	return dev;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ac1faee..83edbe8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2239,13 +2239,8 @@ static void i40e_sync_filters_subtask(struct i40e_pf *pf)
 static int i40e_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
-	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 	struct i40e_vsi *vsi = np->vsi;
 
-	/* MTU < 68 is an error and causes problems on some kernels */
-	if ((new_mtu < 68) || (max_frame > I40E_MAX_RXBUFFER))
-		return -EINVAL;
-
 	netdev_info(netdev, "changing MTU from %d to %d\n",
 		    netdev->mtu, new_mtu);
 	netdev->mtu = new_mtu;
@@ -9220,6 +9215,11 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	i40e_fcoe_config_netdev(netdev, vsi);
 #endif
 
+	/* MTU range: 68 - 9706 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = I40E_MAX_RXBUFFER -
+			  (ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 1437281..777eb29 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2133,10 +2133,6 @@ static struct net_device_stats *i40evf_get_stats(struct net_device *netdev)
 static int i40evf_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
-	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
-
-	if ((new_mtu < 68) || (max_frame > I40E_MAX_RXBUFFER))
-		return -EINVAL;
 
 	netdev->mtu = new_mtu;
 	adapter->flags |= I40EVF_FLAG_RESET_NEEDED;
@@ -2424,6 +2420,10 @@ static void i40evf_init_task(struct work_struct *work)
 	i40evf_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
 
+	/* MTU range: 68 - 9710 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = I40E_MAX_RXBUFFER - (ETH_HLEN + ETH_FCS_LEN);
+
 	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
 		dev_info(&pdev->dev, "Invalid MAC address %pM, using random\n",
 			 adapter->hw.mac.addr);
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 2688180..8aee314 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -357,7 +357,8 @@
 #define ETHERNET_IEEE_VLAN_TYPE 0x8100  /* 802.3ac packet */
 
 /* As per the EAS the maximum supported size is 9.5KB (9728 bytes) */
-#define MAX_JUMBO_FRAME_SIZE	0x2600
+#define MAX_JUMBO_FRAME_SIZE		0x2600
+#define MAX_STD_JUMBO_FRAME_SIZE	9216
 
 /* PBA constants */
 #define E1000_PBA_34K 0x0022
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index edc9a6a..4feca69 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2468,6 +2468,10 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* MTU range: 68 - 9216 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = MAX_STD_JUMBO_FRAME_SIZE;
+
 	adapter->en_mng_pt = igb_enable_mng_pass_thru(hw);
 
 	/* before reading the NVM, reset the controller to put the device in a
@@ -5408,17 +5412,6 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 	struct pci_dev *pdev = adapter->pdev;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 
-	if ((new_mtu < 68) || (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		dev_err(&pdev->dev, "Invalid MTU setting\n");
-		return -EINVAL;
-	}
-
-#define MAX_STD_JUMBO_FRAME_SIZE 9238
-	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
-		dev_err(&pdev->dev, "MTU > 9216 not supported.\n");
-		return -EINVAL;
-	}
-
 	/* adjust max frame to be at least the size of a standard frame */
 	if (max_frame < (ETH_FRAME_LEN + ETH_FCS_LEN))
 		max_frame = ETH_FRAME_LEN + ETH_FCS_LEN;
diff --git a/drivers/net/ethernet/intel/igbvf/defines.h b/drivers/net/ethernet/intel/igbvf/defines.h
index ee1ef08..f1789d1 100644
--- a/drivers/net/ethernet/intel/igbvf/defines.h
+++ b/drivers/net/ethernet/intel/igbvf/defines.h
@@ -85,7 +85,8 @@
 #define E1000_TXD_CMD_DEXT	0x20000000 /* Desc extension (0 = legacy) */
 #define E1000_TXD_STAT_DD	0x00000001 /* Desc Done */
 
-#define MAX_JUMBO_FRAME_SIZE	0x3F00
+#define MAX_JUMBO_FRAME_SIZE		0x3F00
+#define MAX_STD_JUMBO_FRAME_SIZE	9216
 
 /* 802.1q VLAN Packet Size */
 #define VLAN_TAG_SIZE		4    /* 802.3ac tag (not DMA'd) */
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 12bb877..810fcf7 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2356,16 +2356,6 @@ static int igbvf_change_mtu(struct net_device *netdev, int new_mtu)
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
-	if (new_mtu < 68 || new_mtu > INT_MAX - ETH_HLEN - ETH_FCS_LEN ||
-	    max_frame > MAX_JUMBO_FRAME_SIZE)
-		return -EINVAL;
-
-#define MAX_STD_JUMBO_FRAME_SIZE 9234
-	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
-		dev_err(&adapter->pdev->dev, "MTU > 9216 not supported.\n");
-		return -EINVAL;
-	}
-
 	while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
 	/* igbvf_down has a dependency on max_frame_size */
@@ -2786,6 +2776,10 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			    NETIF_F_HW_VLAN_CTAG_RX |
 			    NETIF_F_HW_VLAN_CTAG_TX;
 
+	/* MTU range: 68 - 9216 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = MAX_STD_JUMBO_FRAME_SIZE;
+
 	/*reset the controller to put the device in a known good state */
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 31f9145..5826b1d 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -487,6 +487,10 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
 
+	/* MTU range: 68 - 16114 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = IXGB_MAX_JUMBO_FRAME_SIZE - ETH_HLEN;
+
 	/* make sure the EEPROM is good */
 
 	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
@@ -1619,18 +1623,6 @@ ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
-	int old_max_frame = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
-
-	/* MTU < 68 is an error for IPv4 traffic, just don't allow it */
-	if ((new_mtu < 68) ||
-	    (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
-		netif_err(adapter, probe, adapter->netdev,
-			  "Invalid MTU setting %d\n", new_mtu);
-		return -EINVAL;
-	}
-
-	if (old_max_frame == max_frame)
-		return 0;
 
 	if (netif_running(netdev))
 		ixgb_down(adapter, true);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 784b0b9..7dfde20 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6049,11 +6049,6 @@ static void ixgbe_free_all_rx_resources(struct ixgbe_adapter *adapter)
 static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
-
-	/* MTU < 68 is an error and causes problems on some kernels */
-	if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
-		return -EINVAL;
 
 	/*
 	 * For 82599EB we cannot allow legacy VFs to enable their receive
@@ -6062,7 +6057,7 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 	 */
 	if ((adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) &&
 	    (adapter->hw.mac.type == ixgbe_mac_82599EB) &&
-	    (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)))
+	    (new_mtu > ETH_DATA_LEN))
 		e_warn(probe, "Setting MTU > 1500 will disable legacy VFs\n");
 
 	e_info(probe, "changing MTU from %d to %d\n", netdev->mtu, new_mtu);
@@ -9608,6 +9603,10 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
+	/* MTU range: 68 - 9710 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = IXGBE_MAX_JUMBO_FRAME_SIZE - (ETH_HLEN + ETH_FCS_LEN);
+
 #ifdef CONFIG_IXGBE_DCB
 	if (adapter->flags & IXGBE_FLAG_DCB_CAPABLE)
 		netdev->dcbnl_ops = &dcbnl_ops;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 7eaac32..d2775f0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3742,24 +3742,8 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
-	int max_possible_frame = MAXIMUM_ETHERNET_VLAN_SIZE;
 	int ret;
 
-	switch (adapter->hw.api_version) {
-	case ixgbe_mbox_api_11:
-	case ixgbe_mbox_api_12:
-		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
-		break;
-	default:
-		if (adapter->hw.mac.type != ixgbe_mac_82599_vf)
-			max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
-		break;
-	}
-
-	/* MTU < 68 is an error and causes problems on some kernels */
-	if ((new_mtu < 68) || (max_frame > max_possible_frame))
-		return -EINVAL;
-
 	spin_lock_bh(&adapter->mbx_lock);
 	/* notify the PF of our intent to use this size of frame */
 	ret = hw->mac.ops.set_rlpml(hw, max_frame);
@@ -4104,6 +4088,23 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* MTU range: 68 - 1504 or 9710 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	switch (adapter->hw.api_version) {
+	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
+		netdev->max_mtu = IXGBE_MAX_JUMBO_FRAME_SIZE -
+				  (ETH_HLEN + ETH_FCS_LEN);
+		break;
+	default:
+		if (adapter->hw.mac.type != ixgbe_mac_82599_vf)
+			netdev->max_mtu = IXGBE_MAX_JUMBO_FRAME_SIZE -
+					  (ETH_HLEN + ETH_FCS_LEN);
+		else
+			netdev->max_mtu = ETH_DATA_LEN + ETH_FCS_LEN;
+		break;
+	}
+
 	if (IXGBE_REMOVED(hw->hw_addr)) {
 		err = -EIO;
 		goto err_sw_init;
-- 
2.10.0

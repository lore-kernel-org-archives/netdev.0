From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] igbvf: add lock around mailbox ops
Date: Wed,  9 Aug 2017 14:47:43 -0700
Message-ID: <20170809214746.28139-10-jeffrey.t.kirsher@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: Greg Edwards <gedwards@ddn.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:44498 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752353AbdHIVr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:57 -0400
In-Reply-To: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Edwards <gedwards@ddn.com>

The PF driver assumes the VF will not send another mailbox message until
the PF has written its reply to the previous message.  If the VF does,
that message will be silently dropped by the PF before it writes its
reply to the mailbox.  This results in a VF mailbox timeout for posted
messages waiting for an ACK, and the VF is reset by the
igbvf_watchdog_task in the VM.

Add a lock around the VF mailbox ops to prevent the VF from sending
another message while the PF is still processing the previous one.

Signed-off-by: Greg Edwards <gedwards@ddn.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/ethtool.c |  4 +++
 drivers/net/ethernet/intel/igbvf/mbx.c     |  4 +++
 drivers/net/ethernet/intel/igbvf/netdev.c  | 47 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
 4 files changed, 56 insertions(+)

diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index 34faa113a8a0..a127688e83e6 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -296,8 +296,12 @@ static int igbvf_link_test(struct igbvf_adapter *adapter, u64 *data)
 	struct e1000_hw *hw = &adapter->hw;
 	*data = 0;
 
+	spin_lock_bh(&hw->mbx_lock);
+
 	hw->mac.ops.check_for_link(hw);
 
+	spin_unlock_bh(&hw->mbx_lock);
+
 	if (!(er32(STATUS) & E1000_STATUS_LU))
 		*data = 1;
 
diff --git a/drivers/net/ethernet/intel/igbvf/mbx.c b/drivers/net/ethernet/intel/igbvf/mbx.c
index 01752f44ace2..c9a441632e9f 100644
--- a/drivers/net/ethernet/intel/igbvf/mbx.c
+++ b/drivers/net/ethernet/intel/igbvf/mbx.c
@@ -264,6 +264,8 @@ static s32 e1000_write_mbx_vf(struct e1000_hw *hw, u32 *msg, u16 size)
 	s32 err;
 	u16 i;
 
+	WARN_ON_ONCE(!spin_is_locked(&hw->mbx_lock));
+
 	/* lock the mailbox to prevent pf/vf race condition */
 	err = e1000_obtain_mbx_lock_vf(hw);
 	if (err)
@@ -300,6 +302,8 @@ static s32 e1000_read_mbx_vf(struct e1000_hw *hw, u32 *msg, u16 size)
 	s32 err;
 	u16 i;
 
+	WARN_ON_ONCE(!spin_is_locked(&hw->mbx_lock));
+
 	/* lock the mailbox to prevent pf/vf race condition */
 	err = e1000_obtain_mbx_lock_vf(hw);
 	if (err)
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 1b9cbbe88f6f..1ed556911b14 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1235,7 +1235,12 @@ static void igbvf_set_rlpml(struct igbvf_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	max_frame_size = adapter->max_frame_size + VLAN_TAG_SIZE;
+
+	spin_lock_bh(&hw->mbx_lock);
+
 	e1000_rlpml_set_vf(hw, max_frame_size);
+
+	spin_unlock_bh(&hw->mbx_lock);
 }
 
 static int igbvf_vlan_rx_add_vid(struct net_device *netdev,
@@ -1244,10 +1249,16 @@ static int igbvf_vlan_rx_add_vid(struct net_device *netdev,
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
+	spin_lock_bh(&hw->mbx_lock);
+
 	if (hw->mac.ops.set_vfta(hw, vid, true)) {
 		dev_err(&adapter->pdev->dev, "Failed to add vlan id %d\n", vid);
+		spin_unlock_bh(&hw->mbx_lock);
 		return -EINVAL;
 	}
+
+	spin_unlock_bh(&hw->mbx_lock);
+
 	set_bit(vid, adapter->active_vlans);
 	return 0;
 }
@@ -1258,11 +1269,17 @@ static int igbvf_vlan_rx_kill_vid(struct net_device *netdev,
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
+	spin_lock_bh(&hw->mbx_lock);
+
 	if (hw->mac.ops.set_vfta(hw, vid, false)) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to remove vlan id %d\n", vid);
+		spin_unlock_bh(&hw->mbx_lock);
 		return -EINVAL;
 	}
+
+	spin_unlock_bh(&hw->mbx_lock);
+
 	clear_bit(vid, adapter->active_vlans);
 	return 0;
 }
@@ -1428,7 +1445,11 @@ static void igbvf_set_multi(struct net_device *netdev)
 	netdev_for_each_mc_addr(ha, netdev)
 		memcpy(mta_list + (i++ * ETH_ALEN), ha->addr, ETH_ALEN);
 
+	spin_lock_bh(&hw->mbx_lock);
+
 	hw->mac.ops.update_mc_addr_list(hw, mta_list, i, 0, 0);
+
+	spin_unlock_bh(&hw->mbx_lock);
 	kfree(mta_list);
 }
 
@@ -1449,16 +1470,24 @@ static int igbvf_set_uni(struct net_device *netdev)
 		return -ENOSPC;
 	}
 
+	spin_lock_bh(&hw->mbx_lock);
+
 	/* Clear all unicast MAC filters */
 	hw->mac.ops.set_uc_addr(hw, E1000_VF_MAC_FILTER_CLR, NULL);
 
+	spin_unlock_bh(&hw->mbx_lock);
+
 	if (!netdev_uc_empty(netdev)) {
 		struct netdev_hw_addr *ha;
 
 		/* Add MAC filters one by one */
 		netdev_for_each_uc_addr(ha, netdev) {
+			spin_lock_bh(&hw->mbx_lock);
+
 			hw->mac.ops.set_uc_addr(hw, E1000_VF_MAC_FILTER_ADD,
 						ha->addr);
+
+			spin_unlock_bh(&hw->mbx_lock);
 			udelay(200);
 		}
 	}
@@ -1503,12 +1532,16 @@ static void igbvf_reset(struct igbvf_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
 
+	spin_lock_bh(&hw->mbx_lock);
+
 	/* Allow time for pending master requests to run */
 	if (mac->ops.reset_hw(hw))
 		dev_err(&adapter->pdev->dev, "PF still resetting\n");
 
 	mac->ops.init_hw(hw);
 
+	spin_unlock_bh(&hw->mbx_lock);
+
 	if (is_valid_ether_addr(adapter->hw.mac.addr)) {
 		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
 		       netdev->addr_len);
@@ -1643,6 +1676,7 @@ static int igbvf_sw_init(struct igbvf_adapter *adapter)
 	igbvf_irq_disable(adapter);
 
 	spin_lock_init(&adapter->stats_lock);
+	spin_lock_init(&adapter->hw.mbx_lock);
 
 	set_bit(__IGBVF_DOWN, &adapter->state);
 	return 0;
@@ -1786,8 +1820,12 @@ static int igbvf_set_mac(struct net_device *netdev, void *p)
 
 	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
 
+	spin_lock_bh(&hw->mbx_lock);
+
 	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
 
+	spin_unlock_bh(&hw->mbx_lock);
+
 	if (!ether_addr_equal(addr->sa_data, hw->mac.addr))
 		return -EADDRNOTAVAIL;
 
@@ -1858,7 +1896,12 @@ static bool igbvf_has_link(struct igbvf_adapter *adapter)
 	if (test_bit(__IGBVF_DOWN, &adapter->state))
 		return false;
 
+	spin_lock_bh(&hw->mbx_lock);
+
 	ret_val = hw->mac.ops.check_for_link(hw);
+
+	spin_unlock_bh(&hw->mbx_lock);
+
 	link_active = !hw->mac.get_link_status;
 
 	/* if check for link returns error we will need to reset */
@@ -2808,6 +2851,8 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->min_mtu = ETH_MIN_MTU;
 	netdev->max_mtu = MAX_STD_JUMBO_FRAME_SIZE;
 
+	spin_lock_bh(&hw->mbx_lock);
+
 	/*reset the controller to put the device in a known good state */
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
@@ -2824,6 +2869,8 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		       netdev->addr_len);
 	}
 
+	spin_unlock_bh(&hw->mbx_lock);
+
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
 		dev_info(&pdev->dev, "Assigning random MAC address.\n");
 		eth_hw_addr_random(netdev);
diff --git a/drivers/net/ethernet/intel/igbvf/vf.h b/drivers/net/ethernet/intel/igbvf/vf.h
index 4cf78b0dec50..d213eefb6169 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.h
+++ b/drivers/net/ethernet/intel/igbvf/vf.h
@@ -245,6 +245,7 @@ struct e1000_hw {
 
 	struct e1000_mac_info  mac;
 	struct e1000_mbx_info mbx;
+	spinlock_t mbx_lock;		/* serializes mailbox ops */
 
 	union {
 		struct e1000_dev_spec_vf vf;
-- 
2.13.3

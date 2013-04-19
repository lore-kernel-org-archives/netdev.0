From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/6] net: vlan: prepare for 802.1ad VLAN filtering offload
Date: Fri, 19 Apr 2013 14:04:28 +0200
Message-ID: <1366373072-19621-3-git-send-email-kaber@trash.net>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46097 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968306Ab3DSMEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:04:38 -0400
In-Reply-To: <1366373072-19621-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the rx_{add,kill}_vid callbacks to take a protocol argument in
preparation of 802.1ad support. The protocol argument used so far is
always htons(ETH_P_8021Q).

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 drivers/net/bonding/bond_main.c                   | 17 ++++----
 drivers/net/ethernet/adaptec/starfire.c           |  6 ++-
 drivers/net/ethernet/brocade/bna/bnad.c           |  6 +--
 drivers/net/ethernet/cisco/enic/enic_dev.c        |  4 +-
 drivers/net/ethernet/cisco/enic/enic_dev.h        |  4 +-
 drivers/net/ethernet/emulex/benet/be_main.c       |  4 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c         |  4 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c     | 22 +++++++----
 drivers/net/ethernet/intel/e1000e/netdev.c        | 20 ++++++----
 drivers/net/ethernet/intel/igb/igb_main.c         | 12 +++---
 drivers/net/ethernet/intel/igbvf/netdev.c         |  8 ++--
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       | 12 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 10 +++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  9 +++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |  6 ++-
 drivers/net/ethernet/neterion/vxge/vxge-main.c    |  8 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c  |  8 ++--
 drivers/net/ethernet/qlogic/qlge/qlge_main.c      |  4 +-
 drivers/net/ethernet/renesas/sh_eth.c             |  6 ++-
 drivers/net/ethernet/tehuti/tehuti.c              |  4 +-
 drivers/net/ethernet/ti/cpsw.c                    |  4 +-
 drivers/net/ethernet/via/via-rhine.c              | 10 +++--
 drivers/net/ethernet/via/via-velocity.c           |  6 ++-
 drivers/net/macvlan.c                             |  8 ++--
 drivers/net/team/team.c                           | 10 ++---
 drivers/net/virtio_net.c                          |  6 ++-
 drivers/net/vmxnet3/vmxnet3_drv.c                 |  4 +-
 drivers/s390/net/qeth_l2_main.c                   |  6 ++-
 drivers/s390/net/qeth_l3_main.c                   |  6 ++-
 include/linux/if_vlan.h                           |  4 +-
 include/linux/netdevice.h                         | 16 ++++----
 net/8021q/vlan.c                                  | 10 ++---
 net/8021q/vlan_core.c                             | 47 +++++++++++++----------
 net/bridge/br_vlan.c                              | 10 +++--
 34 files changed, 184 insertions(+), 137 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8d324f8..35e89e1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -428,14 +428,15 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
  * @bond_dev: bonding net device that got called
  * @vid: vlan id being added
  */
-static int bond_vlan_rx_add_vid(struct net_device *bond_dev, uint16_t vid)
+static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
+				__be16 proto, u16 vid)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *stop_at;
 	int i, res;
 
 	bond_for_each_slave(bond, slave, i) {
-		res = vlan_vid_add(slave->dev, vid);
+		res = vlan_vid_add(slave->dev, proto, vid);
 		if (res)
 			goto unwind;
 	}
@@ -453,7 +454,7 @@ unwind:
 	/* unwind from head to the slave that failed */
 	stop_at = slave;
 	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at)
-		vlan_vid_del(slave->dev, vid);
+		vlan_vid_del(slave->dev, proto, vid);
 
 	return res;
 }
@@ -463,14 +464,15 @@ unwind:
  * @bond_dev: bonding net device that got called
  * @vid: vlan id being removed
  */
-static int bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
+static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
+				 __be16 proto, u16 vid)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	int i, res;
 
 	bond_for_each_slave(bond, slave, i)
-		vlan_vid_del(slave->dev, vid);
+		vlan_vid_del(slave->dev, proto, vid);
 
 	res = bond_del_vlan(bond, vid);
 	if (res) {
@@ -488,7 +490,8 @@ static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *sla
 	int res;
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		res = vlan_vid_add(slave_dev, vlan->vlan_id);
+		res = vlan_vid_add(slave_dev, htons(ETH_P_8021Q),
+				   vlan->vlan_id);
 		if (res)
 			pr_warning("%s: Failed to add vlan id %d to device %s\n",
 				   bond->dev->name, vlan->vlan_id,
@@ -504,7 +507,7 @@ static void bond_del_vlans_from_slave(struct bonding *bond,
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (!vlan->vlan_id)
 			continue;
-		vlan_vid_del(slave_dev, vlan->vlan_id);
+		vlan_vid_del(slave_dev, htons(ETH_P_8021Q), vlan->vlan_id);
 	}
 }
 
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 3658651..cdbc544 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -594,7 +594,8 @@ static const struct ethtool_ops ethtool_ops;
 
 
 #ifdef VLAN_SUPPORT
-static int netdev_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+static int netdev_vlan_rx_add_vid(struct net_device *dev,
+				  __be16 proto, u16 vid)
 {
 	struct netdev_private *np = netdev_priv(dev);
 
@@ -608,7 +609,8 @@ static int netdev_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	return 0;
 }
 
-static int netdev_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+static int netdev_vlan_rx_kill_vid(struct net_device *dev,
+				   __be16 proto, u16 vid)
 {
 	struct netdev_private *np = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 1d9d037..c0bc44e 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3068,8 +3068,7 @@ bnad_change_mtu(struct net_device *netdev, int new_mtu)
 }
 
 static int
-bnad_vlan_rx_add_vid(struct net_device *netdev,
-				 unsigned short vid)
+bnad_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	unsigned long flags;
@@ -3090,8 +3089,7 @@ bnad_vlan_rx_add_vid(struct net_device *netdev,
 }
 
 static int
-bnad_vlan_rx_kill_vid(struct net_device *netdev,
-				  unsigned short vid)
+bnad_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	unsigned long flags;
diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.c b/drivers/net/ethernet/cisco/enic/enic_dev.c
index bf0fc56..4b6e569 100644
--- a/drivers/net/ethernet/cisco/enic/enic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/enic_dev.c
@@ -212,7 +212,7 @@ int enic_dev_deinit_done(struct enic *enic, int *status)
 }
 
 /* rtnl lock is held */
-int enic_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+int enic_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct enic *enic = netdev_priv(netdev);
 	int err;
@@ -225,7 +225,7 @@ int enic_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 }
 
 /* rtnl lock is held */
-int enic_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+int enic_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct enic *enic = netdev_priv(netdev);
 	int err;
diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.h b/drivers/net/ethernet/cisco/enic/enic_dev.h
index da1cba3..08bded0 100644
--- a/drivers/net/ethernet/cisco/enic/enic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/enic_dev.h
@@ -46,8 +46,8 @@ int enic_dev_packet_filter(struct enic *enic, int directed, int multicast,
 	int broadcast, int promisc, int allmulti);
 int enic_dev_add_addr(struct enic *enic, u8 *addr);
 int enic_dev_del_addr(struct enic *enic, u8 *addr);
-int enic_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
-int enic_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
+int enic_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16 vid);
+int enic_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid);
 int enic_dev_notify_unset(struct enic *enic);
 int enic_dev_hang_notify(struct enic *enic);
 int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index bde26d4..b413331 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -902,7 +902,7 @@ set_vlan_promisc:
 	return status;
 }
 
-static int be_vlan_add_vid(struct net_device *netdev, u16 vid)
+static int be_vlan_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status = 0;
@@ -928,7 +928,7 @@ ret:
 	return status;
 }
 
-static int be_vlan_rem_vid(struct net_device *netdev, u16 vid)
+static int be_vlan_rem_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status = 0;
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 9c9fa74..d1812aa 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -2110,7 +2110,7 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static int ehea_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+static int ehea_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	struct ehea_adapter *adapter = port->adapter;
@@ -2148,7 +2148,7 @@ out:
 	return err;
 }
 
-static int ehea_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+static int ehea_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	struct ehea_adapter *adapter = port->adapter;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 8d0d0d4..8239daf 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -166,8 +166,10 @@ static void e1000_vlan_mode(struct net_device *netdev,
 			    netdev_features_t features);
 static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 				     bool filter_on);
-static int e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
-static int e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
+static int e1000_vlan_rx_add_vid(struct net_device *netdev,
+				 __be16 proto, u16 vid);
+static int e1000_vlan_rx_kill_vid(struct net_device *netdev,
+				  __be16 proto, u16 vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
 
 #ifdef CONFIG_PM
@@ -333,7 +335,7 @@ static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
 	if (!test_bit(vid, adapter->active_vlans)) {
 		if (hw->mng_cookie.status &
 		    E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) {
-			e1000_vlan_rx_add_vid(netdev, vid);
+			e1000_vlan_rx_add_vid(netdev, htons(ETH_P_8021Q), vid);
 			adapter->mng_vlan_id = vid;
 		} else {
 			adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
@@ -341,7 +343,8 @@ static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
 		if ((old_vid != (u16)E1000_MNG_VLAN_NONE) &&
 		    (vid != old_vid) &&
 		    !test_bit(old_vid, adapter->active_vlans))
-			e1000_vlan_rx_kill_vid(netdev, old_vid);
+			e1000_vlan_rx_kill_vid(netdev, htons(ETH_P_8021Q),
+					       old_vid);
 	} else {
 		adapter->mng_vlan_id = vid;
 	}
@@ -1457,7 +1460,8 @@ static int e1000_close(struct net_device *netdev)
 	if ((hw->mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
 	    !test_bit(adapter->mng_vlan_id, adapter->active_vlans)) {
-		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
+		e1000_vlan_rx_kill_vid(netdev, htons(ETH_P_8021Q),
+				       adapter->mng_vlan_id);
 	}
 
 	return 0;
@@ -4837,7 +4841,8 @@ static void e1000_vlan_mode(struct net_device *netdev,
 		e1000_irq_enable(adapter);
 }
 
-static int e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+static int e1000_vlan_rx_add_vid(struct net_device *netdev,
+				 __be16 proto, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -4862,7 +4867,8 @@ static int e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	return 0;
 }
 
-static int e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+static int e1000_vlan_rx_kill_vid(struct net_device *netdev,
+				  __be16 proto, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -4896,7 +4902,7 @@ static void e1000_restore_vlan(struct e1000_adapter *adapter)
 
 	e1000_vlan_filter_on_off(adapter, true);
 	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
-		e1000_vlan_rx_add_vid(adapter->netdev, vid);
+		e1000_vlan_rx_add_vid(adapter->netdev, htons(ETH_P_8021Q), vid);
 }
 
 int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a2e7db3..8c17f01 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2672,7 +2672,8 @@ static int e1000e_poll(struct napi_struct *napi, int weight)
 	return work_done;
 }
 
-static int e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+static int e1000_vlan_rx_add_vid(struct net_device *netdev,
+				 __be16 proto, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -2697,7 +2698,8 @@ static int e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	return 0;
 }
 
-static int e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+static int e1000_vlan_rx_kill_vid(struct net_device *netdev,
+				  __be16 proto, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -2741,7 +2743,8 @@ static void e1000e_vlan_filter_disable(struct e1000_adapter *adapter)
 		ew32(RCTL, rctl);
 
 		if (adapter->mng_vlan_id != (u16)E1000_MNG_VLAN_NONE) {
-			e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
+			e1000_vlan_rx_kill_vid(netdev, htons(ETH_P_8021Q),
+					       adapter->mng_vlan_id);
 			adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 		}
 	}
@@ -2802,22 +2805,22 @@ static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
 	u16 old_vid = adapter->mng_vlan_id;
 
 	if (adapter->hw.mng_cookie.status & E1000_MNG_DHCP_COOKIE_STATUS_VLAN) {
-		e1000_vlan_rx_add_vid(netdev, vid);
+		e1000_vlan_rx_add_vid(netdev, htons(ETH_P_8021Q), vid);
 		adapter->mng_vlan_id = vid;
 	}
 
 	if ((old_vid != (u16)E1000_MNG_VLAN_NONE) && (vid != old_vid))
-		e1000_vlan_rx_kill_vid(netdev, old_vid);
+		e1000_vlan_rx_kill_vid(netdev, htons(ETH_P_8021Q), old_vid);
 }
 
 static void e1000_restore_vlan(struct e1000_adapter *adapter)
 {
 	u16 vid;
 
-	e1000_vlan_rx_add_vid(adapter->netdev, 0);
+	e1000_vlan_rx_add_vid(adapter->netdev, htons(ETH_P_8021Q), 0);
 
 	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
-	    e1000_vlan_rx_add_vid(adapter->netdev, vid);
+	    e1000_vlan_rx_add_vid(adapter->netdev, htons(ETH_P_8021Q), vid);
 }
 
 static void e1000_init_manageability_pt(struct e1000_adapter *adapter)
@@ -4384,7 +4387,8 @@ static int e1000_close(struct net_device *netdev)
 	 * the same ID is registered on the host OS (let 8021q kill it)
 	 */
 	if (adapter->hw.mng_cookie.status & E1000_MNG_DHCP_COOKIE_STATUS_VLAN)
-		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
+		e1000_vlan_rx_kill_vid(netdev, htons(ETH_P_8021Q),
+				       adapter->mng_vlan_id);
 
 	/* If AMT is enabled, let the firmware know that the network
 	 * interface is now closed
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 05980de..e128388 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -156,8 +156,8 @@ static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
 static void igb_vlan_mode(struct net_device *netdev, netdev_features_t features);
-static int igb_vlan_rx_add_vid(struct net_device *, u16);
-static int igb_vlan_rx_kill_vid(struct net_device *, u16);
+static int igb_vlan_rx_add_vid(struct net_device *, __be16, u16);
+static int igb_vlan_rx_kill_vid(struct net_device *, __be16, u16);
 static void igb_restore_vlan(struct igb_adapter *);
 static void igb_rar_set_qsel(struct igb_adapter *, u8 *, u32 , u8);
 static void igb_ping_all_vfs(struct igb_adapter *);
@@ -6950,7 +6950,8 @@ static void igb_vlan_mode(struct net_device *netdev, netdev_features_t features)
 	igb_rlpml_set(adapter);
 }
 
-static int igb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+static int igb_vlan_rx_add_vid(struct net_device *netdev,
+			       __be16 proto, u16 vid)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -6967,7 +6968,8 @@ static int igb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	return 0;
 }
 
-static int igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+static int igb_vlan_rx_kill_vid(struct net_device *netdev,
+				__be16 proto, u16 vid)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -6993,7 +6995,7 @@ static void igb_restore_vlan(struct igb_adapter *adapter)
 	igb_vlan_mode(adapter->netdev, adapter->netdev->features);
 
 	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
-		igb_vlan_rx_add_vid(adapter->netdev, vid);
+		igb_vlan_rx_add_vid(adapter->netdev, htons(ETH_P_8021Q), vid);
 }
 
 int igb_set_spd_dplx(struct igb_adapter *adapter, u32 spd, u8 dplx)
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 33e7b30..3854fd6 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1230,7 +1230,8 @@ static void igbvf_set_rlpml(struct igbvf_adapter *adapter)
 	e1000_rlpml_set_vf(hw, max_frame_size);
 }
 
-static int igbvf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+static int igbvf_vlan_rx_add_vid(struct net_device *netdev,
+				 __be16 proto, u16 vid)
 {
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -1243,7 +1244,8 @@ static int igbvf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	return 0;
 }
 
-static int igbvf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+static int igbvf_vlan_rx_kill_vid(struct net_device *netdev,
+				  __be16 proto, u16 vid)
 {
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -1262,7 +1264,7 @@ static void igbvf_restore_vlan(struct igbvf_adapter *adapter)
 	u16 vid;
 
 	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
-		igbvf_vlan_rx_add_vid(adapter->netdev, vid);
+		igbvf_vlan_rx_add_vid(adapter->netdev, htons(ETH_P_8021Q), vid);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index e65d9e9..a32f274 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -101,8 +101,10 @@ static void ixgb_tx_timeout_task(struct work_struct *work);
 
 static void ixgb_vlan_strip_enable(struct ixgb_adapter *adapter);
 static void ixgb_vlan_strip_disable(struct ixgb_adapter *adapter);
-static int ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
-static int ixgb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
+static int ixgb_vlan_rx_add_vid(struct net_device *netdev,
+				__be16 proto, u16 vid);
+static int ixgb_vlan_rx_kill_vid(struct net_device *netdev,
+				 __be16 proto, u16 vid);
 static void ixgb_restore_vlan(struct ixgb_adapter *adapter);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2209,7 +2211,7 @@ ixgb_vlan_strip_disable(struct ixgb_adapter *adapter)
 }
 
 static int
-ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+ixgb_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	u32 vfta, index;
@@ -2226,7 +2228,7 @@ ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 }
 
 static int
-ixgb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+ixgb_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	u32 vfta, index;
@@ -2248,7 +2250,7 @@ ixgb_restore_vlan(struct ixgb_adapter *adapter)
 	u16 vid;
 
 	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
-		ixgb_vlan_rx_add_vid(adapter->netdev, vid);
+		ixgb_vlan_rx_add_vid(adapter->netdev, htons(ETH_P_8021Q), vid);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6839785..d128695 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3421,7 +3421,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	hw->mac.ops.enable_rx_dma(hw, rxctrl);
 }
 
-static int ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+static int ixgbe_vlan_rx_add_vid(struct net_device *netdev,
+				 __be16 proto, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -3433,7 +3434,8 @@ static int ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	return 0;
 }
 
-static int ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+static int ixgbe_vlan_rx_kill_vid(struct net_device *netdev,
+				  __be16 proto, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -3538,10 +3540,10 @@ static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
 {
 	u16 vid;
 
-	ixgbe_vlan_rx_add_vid(adapter->netdev, 0);
+	ixgbe_vlan_rx_add_vid(adapter->netdev, htons(ETH_P_8021Q), 0);
 
 	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
-		ixgbe_vlan_rx_add_vid(adapter->netdev, vid);
+		ixgbe_vlan_rx_add_vid(adapter->netdev, htons(ETH_P_8021Q), vid);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 8f907b7..4bc1f84 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1179,7 +1179,8 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 	}
 }
 
-static int ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+static int ixgbevf_vlan_rx_add_vid(struct net_device *netdev,
+				   __be16 proto, u16 vid)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -1204,7 +1205,8 @@ static int ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	return err;
 }
 
-static int ixgbevf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+static int ixgbevf_vlan_rx_kill_vid(struct net_device *netdev,
+				    __be16 proto, u16 vid)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -1227,7 +1229,8 @@ static void ixgbevf_restore_vlan(struct ixgbevf_adapter *adapter)
 	u16 vid;
 
 	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
-		ixgbevf_vlan_rx_add_vid(adapter->netdev, vid);
+		ixgbevf_vlan_rx_add_vid(adapter->netdev,
+					htons(ETH_P_8021Q), vid);
 }
 
 static int ixgbevf_write_uc_addr_list(struct net_device *netdev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b2ba39c..e7e2784 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -356,7 +356,8 @@ static void mlx4_en_filter_rfs_expire(struct mlx4_en_priv *priv)
 }
 #endif
 
-static int mlx4_en_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+static int mlx4_en_vlan_rx_add_vid(struct net_device *dev,
+				   __be16 proto, u16 vid)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
@@ -381,7 +382,8 @@ static int mlx4_en_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	return 0;
 }
 
-static int mlx4_en_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+static int mlx4_en_vlan_rx_kill_vid(struct net_device *dev,
+				    __be16 proto, u16 vid)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index e9e58aa..a939614 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3300,12 +3300,13 @@ static void vxge_tx_watchdog(struct net_device *dev)
 /**
  * vxge_vlan_rx_add_vid
  * @dev: net device pointer.
+ * @proto: vlan protocol
  * @vid: vid
  *
  * Add the vlan id to the devices vlan id table
  */
 static int
-vxge_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+vxge_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct vxgedev *vdev = netdev_priv(dev);
 	struct vxge_vpath *vpath;
@@ -3323,14 +3324,15 @@ vxge_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 }
 
 /**
- * vxge_vlan_rx_add_vid
+ * vxge_vlan_rx_kill_vid
  * @dev: net device pointer.
+ * @proto: vlan protocol
  * @vid: vid
  *
  * Remove the vlan id from the device's vlan id table
  */
 static int
-vxge_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+vxge_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct vxgedev *vdev = netdev_priv(dev);
 	struct vxge_vpath *vpath;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 845ba1d..e88e013 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -86,8 +86,8 @@ static void qlcnic_dev_set_npar_ready(struct qlcnic_adapter *);
 static int qlcnicvf_start_firmware(struct qlcnic_adapter *);
 static void qlcnic_set_netdev_features(struct qlcnic_adapter *,
 				struct qlcnic_esw_func_cfg *);
-static int qlcnic_vlan_rx_add(struct net_device *, u16);
-static int qlcnic_vlan_rx_del(struct net_device *, u16);
+static int qlcnic_vlan_rx_add(struct net_device *, __be16, u16);
+static int qlcnic_vlan_rx_del(struct net_device *, __be16, u16);
 
 #define QLCNIC_IS_TSO_CAPABLE(adapter)	\
 	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
@@ -902,7 +902,7 @@ void qlcnic_set_vlan_config(struct qlcnic_adapter *adapter,
 }
 
 static int
-qlcnic_vlan_rx_add(struct net_device *netdev, u16 vid)
+qlcnic_vlan_rx_add(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	set_bit(vid, adapter->vlans);
@@ -910,7 +910,7 @@ qlcnic_vlan_rx_add(struct net_device *netdev, u16 vid)
 }
 
 static int
-qlcnic_vlan_rx_del(struct net_device *netdev, u16 vid)
+qlcnic_vlan_rx_del(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 8e3f43c..a9016ac 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2326,7 +2326,7 @@ static int __qlge_vlan_rx_add_vid(struct ql_adapter *qdev, u16 vid)
 	return err;
 }
 
-static int qlge_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
+static int qlge_vlan_rx_add_vid(struct net_device *ndev, __be16 proto, u16 vid)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	int status;
@@ -2357,7 +2357,7 @@ static int __qlge_vlan_rx_kill_vid(struct ql_adapter *qdev, u16 vid)
 	return err;
 }
 
-static int qlge_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
+static int qlge_vlan_rx_kill_vid(struct net_device *ndev, __be16 proto, u16 vid)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	int status;
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 3d4a1ed..b8e52cd 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2448,7 +2448,8 @@ static int sh_eth_get_vtag_index(struct sh_eth_private *mdp)
 		return TSU_VTAG1;
 }
 
-static int sh_eth_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
+static int sh_eth_vlan_rx_add_vid(struct net_device *ndev,
+				  __be16 proto, u16 vid)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int vtag_reg_index = sh_eth_get_vtag_index(mdp);
@@ -2478,7 +2479,8 @@ static int sh_eth_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
 	return 0;
 }
 
-static int sh_eth_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
+static int sh_eth_vlan_rx_kill_vid(struct net_device *ndev,
+				   __be16 proto, u16 vid)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int vtag_reg_index = sh_eth_get_vtag_index(mdp);
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 5ca4b33..f7050c5 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -733,7 +733,7 @@ static void __bdx_vlan_rx_vid(struct net_device *ndev, uint16_t vid, int enable)
  * @ndev: network device
  * @vid:  VLAN vid to add
  */
-static int bdx_vlan_rx_add_vid(struct net_device *ndev, uint16_t vid)
+static int bdx_vlan_rx_add_vid(struct net_device *ndev, __be16 proto, u16 vid)
 {
 	__bdx_vlan_rx_vid(ndev, vid, 1);
 	return 0;
@@ -744,7 +744,7 @@ static int bdx_vlan_rx_add_vid(struct net_device *ndev, uint16_t vid)
  * @ndev: network device
  * @vid:  VLAN vid to kill
  */
-static int bdx_vlan_rx_kill_vid(struct net_device *ndev, unsigned short vid)
+static int bdx_vlan_rx_kill_vid(struct net_device *ndev, __be16 proto, u16 vid)
 {
 	__bdx_vlan_rx_vid(ndev, vid, 0);
 	return 0;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 0849929..5cf8d03 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1251,7 +1251,7 @@ clean_vid:
 }
 
 static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
-		unsigned short vid)
+				    __be16 proto, u16 vid)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
@@ -1263,7 +1263,7 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 }
 
 static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
-		unsigned short vid)
+				     __be16 proto, u16 vid)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int ret;
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 8c0f407..2a60d71 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -508,8 +508,10 @@ static struct rtnl_link_stats64 *rhine_get_stats64(struct net_device *dev,
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
 static int  rhine_close(struct net_device *dev);
-static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid);
-static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid);
+static int rhine_vlan_rx_add_vid(struct net_device *dev,
+				 __be16 proto, u16 vid);
+static int rhine_vlan_rx_kill_vid(struct net_device *dev,
+				  __be16 proto, u16 vid);
 static void rhine_restart_tx(struct net_device *dev);
 
 static void rhine_wait_bit(struct rhine_private *rp, u8 reg, u8 mask, bool low)
@@ -1415,7 +1417,7 @@ static void rhine_update_vcam(struct net_device *dev)
 	rhine_set_vlan_cam_mask(ioaddr, vCAMmask);
 }
 
-static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+static int rhine_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
@@ -1426,7 +1428,7 @@ static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	return 0;
 }
 
-static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+static int rhine_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index c1c55a7..91cd591 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -525,7 +525,8 @@ static void velocity_init_cam_filter(struct velocity_info *vptr)
 	mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
 }
 
-static int velocity_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+static int velocity_vlan_rx_add_vid(struct net_device *dev,
+				    __be16 proto, u16 vid)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 
@@ -536,7 +537,8 @@ static int velocity_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	return 0;
 }
 
-static int velocity_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+static int velocity_vlan_rx_kill_vid(struct net_device *dev,
+				     __be16 proto, u16 vid)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index fedd34c..7347cdb 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -567,21 +567,21 @@ static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
 }
 
 static int macvlan_vlan_rx_add_vid(struct net_device *dev,
-				    unsigned short vid)
+				   __be16 proto, u16 vid)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
-	return vlan_vid_add(lowerdev, vid);
+	return vlan_vid_add(lowerdev, proto, vid);
 }
 
 static int macvlan_vlan_rx_kill_vid(struct net_device *dev,
-				     unsigned short vid)
+				    __be16 proto, u16 vid)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
-	vlan_vid_del(lowerdev, vid);
+	vlan_vid_del(lowerdev, proto, vid);
 	return 0;
 }
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 9290eb23d..7c43261 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1598,7 +1598,7 @@ team_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	return stats;
 }
 
-static int team_vlan_rx_add_vid(struct net_device *dev, uint16_t vid)
+static int team_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct team *team = netdev_priv(dev);
 	struct team_port *port;
@@ -1610,7 +1610,7 @@ static int team_vlan_rx_add_vid(struct net_device *dev, uint16_t vid)
 	 */
 	mutex_lock(&team->lock);
 	list_for_each_entry(port, &team->port_list, list) {
-		err = vlan_vid_add(port->dev, vid);
+		err = vlan_vid_add(port->dev, proto, vid);
 		if (err)
 			goto unwind;
 	}
@@ -1620,20 +1620,20 @@ static int team_vlan_rx_add_vid(struct net_device *dev, uint16_t vid)
 
 unwind:
 	list_for_each_entry_continue_reverse(port, &team->port_list, list)
-		vlan_vid_del(port->dev, vid);
+		vlan_vid_del(port->dev, proto, vid);
 	mutex_unlock(&team->lock);
 
 	return err;
 }
 
-static int team_vlan_rx_kill_vid(struct net_device *dev, uint16_t vid)
+static int team_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct team *team = netdev_priv(dev);
 	struct team_port *port;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(port, &team->port_list, list)
-		vlan_vid_del(port->dev, vid);
+		vlan_vid_del(port->dev, proto, vid);
 	rcu_read_unlock();
 
 	return 0;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b61d57a..5007775 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1006,7 +1006,8 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	kfree(buf);
 }
 
-static int virtnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
+static int virtnet_vlan_rx_add_vid(struct net_device *dev,
+				   __be16 proto, u16 vid)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg;
@@ -1019,7 +1020,8 @@ static int virtnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
 	return 0;
 }
 
-static int virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
+static int virtnet_vlan_rx_kill_vid(struct net_device *dev,
+				    __be16 proto, u16 vid)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg;
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index ba9bdad..27b8899 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1931,7 +1931,7 @@ vmxnet3_restore_vlan(struct vmxnet3_adapter *adapter)
 
 
 static int
-vmxnet3_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+vmxnet3_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 
@@ -1953,7 +1953,7 @@ vmxnet3_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 
 
 static int
-vmxnet3_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+vmxnet3_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 90ddd82..e68f79b 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -302,7 +302,8 @@ static void qeth_l2_process_vlans(struct qeth_card *card)
 	spin_unlock_bh(&card->vlanlock);
 }
 
-static int qeth_l2_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+static int qeth_l2_vlan_rx_add_vid(struct net_device *dev,
+				   __be16 proto, u16 vid)
 {
 	struct qeth_card *card = dev->ml_priv;
 	struct qeth_vlan_vid *id;
@@ -331,7 +332,8 @@ static int qeth_l2_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	return 0;
 }
 
-static int qeth_l2_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+static int qeth_l2_vlan_rx_kill_vid(struct net_device *dev,
+				    __be16 proto, u16 vid)
 {
 	struct qeth_vlan_vid *id, *tmpid = NULL;
 	struct qeth_card *card = dev->ml_priv;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 04261bc..6426868 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1824,7 +1824,8 @@ static void qeth_l3_free_vlan_addresses(struct qeth_card *card,
 	rcu_read_unlock();
 }
 
-static int qeth_l3_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+static int qeth_l3_vlan_rx_add_vid(struct net_device *dev,
+				   __be16 proto, u16 vid)
 {
 	struct qeth_card *card = dev->ml_priv;
 
@@ -1832,7 +1833,8 @@ static int qeth_l3_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	return 0;
 }
 
-static int qeth_l3_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+static int qeth_l3_vlan_rx_kill_vid(struct net_device *dev,
+				    __be16 proto, u16 vid)
 {
 	struct qeth_card *card = dev->ml_priv;
 	unsigned long flags;
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index fee2829..fcb9ef8 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -93,8 +93,8 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 extern bool vlan_do_receive(struct sk_buff **skb);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 
-extern int vlan_vid_add(struct net_device *dev, unsigned short vid);
-extern void vlan_vid_del(struct net_device *dev, unsigned short vid);
+extern int vlan_vid_add(struct net_device *dev, __be16 proto, u16 vid);
+extern void vlan_vid_del(struct net_device *dev, __be16 proto, u16 vid);
 
 extern int vlan_vids_add_by_dev(struct net_device *dev,
 				const struct net_device *by_dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7eb7e03..f8898a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -784,15 +784,13 @@ struct netdev_fcoe_hbainfo {
  *	3. Update dev->stats asynchronously and atomically, and define
  *	   neither operation.
  *
- * int (*ndo_vlan_rx_add_vid)(struct net_device *dev, unsigned short vid);
- *	If device support VLAN filtering (dev->features &
-		 *			  NETIF_F_HW_VLAN_CTAG_FILTER)
- *	this function is called when a VLAN id is registered.
+ * int (*ndo_vlan_rx_add_vid)(struct net_device *dev, __be16 proto, u16t vid);
+ *	If device support VLAN filtering this function is called when a
+ *	VLAN id is registered.
  *
  * int (*ndo_vlan_rx_kill_vid)(struct net_device *dev, unsigned short vid);
- *	If device support VLAN filtering (dev->features &
-		 *			  NETIF_F_HW_VLAN_CTAG_FILTER)
- *	this function is called when a VLAN id is unregistered.
+ *	If device support VLAN filtering this function is called when a
+ *	VLAN id is unregistered.
  *
  * void (*ndo_poll_controller)(struct net_device *dev);
  *
@@ -936,9 +934,9 @@ struct net_device_ops {
 	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
 
 	int			(*ndo_vlan_rx_add_vid)(struct net_device *dev,
-						       unsigned short vid);
+						       __be16 proto, u16 vid);
 	int			(*ndo_vlan_rx_kill_vid)(struct net_device *dev,
-						        unsigned short vid);
+						        __be16 proto, u16 vid);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 	int			(*ndo_netpoll_setup)(struct net_device *dev,
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d913fee..447c5c9 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -112,7 +112,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	 * VLAN is not 0 (leave it there for 802.1p).
 	 */
 	if (vlan_id)
-		vlan_vid_del(real_dev, vlan_id);
+		vlan_vid_del(real_dev, htons(ETH_P_8021Q), vlan_id);
 
 	/* Get rid of the vlan's reference to real_dev */
 	dev_put(real_dev);
@@ -142,7 +142,7 @@ int register_vlan_dev(struct net_device *dev)
 	struct vlan_group *grp;
 	int err;
 
-	err = vlan_vid_add(real_dev, vlan_id);
+	err = vlan_vid_add(real_dev, htons(ETH_P_8021Q), vlan_id);
 	if (err)
 		return err;
 
@@ -195,7 +195,7 @@ out_uninit_gvrp:
 	if (grp->nr_vlan_devs == 0)
 		vlan_gvrp_uninit_applicant(real_dev);
 out_vid_del:
-	vlan_vid_del(real_dev, vlan_id);
+	vlan_vid_del(real_dev, htons(ETH_P_8021Q), vlan_id);
 	return err;
 }
 
@@ -350,7 +350,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	    (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
 		pr_info("adding VLAN 0 to HW filter on device %s\n",
 			dev->name);
-		vlan_vid_add(dev, 0);
+		vlan_vid_add(dev, htons(ETH_P_8021Q), 0);
 	}
 
 	vlan_info = rtnl_dereference(dev->vlan_info);
@@ -416,7 +416,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_DOWN:
 		if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
-			vlan_vid_del(dev, 0);
+			vlan_vid_del(dev, htons(ETH_P_8021Q), 0);
 
 		/* Put all VLANs for this dev in the down state too.  */
 		for (i = 0; i < VLAN_N_VID; i++) {
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 3df29d3..04e3b95 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -185,35 +185,37 @@ static struct vlan_info *vlan_info_alloc(struct net_device *dev)
 
 struct vlan_vid_info {
 	struct list_head list;
-	unsigned short vid;
+	__be16 proto;
+	u16 vid;
 	int refcount;
 };
 
 static struct vlan_vid_info *vlan_vid_info_get(struct vlan_info *vlan_info,
-					       unsigned short vid)
+					       __be16 proto, u16 vid)
 {
 	struct vlan_vid_info *vid_info;
 
 	list_for_each_entry(vid_info, &vlan_info->vid_list, list) {
-		if (vid_info->vid == vid)
+		if (vid_info->proto == proto && vid_info->vid == vid)
 			return vid_info;
 	}
 	return NULL;
 }
 
-static struct vlan_vid_info *vlan_vid_info_alloc(unsigned short vid)
+static struct vlan_vid_info *vlan_vid_info_alloc(__be16 proto, u16 vid)
 {
 	struct vlan_vid_info *vid_info;
 
 	vid_info = kzalloc(sizeof(struct vlan_vid_info), GFP_KERNEL);
 	if (!vid_info)
 		return NULL;
+	vid_info->proto = proto;
 	vid_info->vid = vid;
 
 	return vid_info;
 }
 
-static int __vlan_vid_add(struct vlan_info *vlan_info, unsigned short vid,
+static int __vlan_vid_add(struct vlan_info *vlan_info, __be16 proto, u16 vid,
 			  struct vlan_vid_info **pvid_info)
 {
 	struct net_device *dev = vlan_info->real_dev;
@@ -221,12 +223,13 @@ static int __vlan_vid_add(struct vlan_info *vlan_info, unsigned short vid,
 	struct vlan_vid_info *vid_info;
 	int err;
 
-	vid_info = vlan_vid_info_alloc(vid);
+	vid_info = vlan_vid_info_alloc(proto, vid);
 	if (!vid_info)
 		return -ENOMEM;
 
-	if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER) {
-		err =  ops->ndo_vlan_rx_add_vid(dev, vid);
+	if (proto == htons(ETH_P_8021Q) &&
+	    dev->features & NETIF_F_HW_VLAN_CTAG_FILTER) {
+		err =  ops->ndo_vlan_rx_add_vid(dev, proto, vid);
 		if (err) {
 			kfree(vid_info);
 			return err;
@@ -238,7 +241,7 @@ static int __vlan_vid_add(struct vlan_info *vlan_info, unsigned short vid,
 	return 0;
 }
 
-int vlan_vid_add(struct net_device *dev, unsigned short vid)
+int vlan_vid_add(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct vlan_info *vlan_info;
 	struct vlan_vid_info *vid_info;
@@ -254,9 +257,9 @@ int vlan_vid_add(struct net_device *dev, unsigned short vid)
 			return -ENOMEM;
 		vlan_info_created = true;
 	}
-	vid_info = vlan_vid_info_get(vlan_info, vid);
+	vid_info = vlan_vid_info_get(vlan_info, proto, vid);
 	if (!vid_info) {
-		err = __vlan_vid_add(vlan_info, vid, &vid_info);
+		err = __vlan_vid_add(vlan_info, proto, vid, &vid_info);
 		if (err)
 			goto out_free_vlan_info;
 	}
@@ -279,14 +282,16 @@ static void __vlan_vid_del(struct vlan_info *vlan_info,
 {
 	struct net_device *dev = vlan_info->real_dev;
 	const struct net_device_ops *ops = dev->netdev_ops;
-	unsigned short vid = vid_info->vid;
+	__be16 proto = vid_info->proto;
+	u16 vid = vid_info->vid;
 	int err;
 
-	if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER) {
-		err = ops->ndo_vlan_rx_kill_vid(dev, vid);
+	if (proto == htons(ETH_P_8021Q) &&
+	    dev->features & NETIF_F_HW_VLAN_CTAG_FILTER) {
+		err = ops->ndo_vlan_rx_kill_vid(dev, proto, vid);
 		if (err) {
-			pr_warn("failed to kill vid %d for device %s\n",
-				vid, dev->name);
+			pr_warn("failed to kill vid %04x/%d for device %s\n",
+				proto, vid, dev->name);
 		}
 	}
 	list_del(&vid_info->list);
@@ -294,7 +299,7 @@ static void __vlan_vid_del(struct vlan_info *vlan_info,
 	vlan_info->nr_vids--;
 }
 
-void vlan_vid_del(struct net_device *dev, unsigned short vid)
+void vlan_vid_del(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct vlan_info *vlan_info;
 	struct vlan_vid_info *vid_info;
@@ -305,7 +310,7 @@ void vlan_vid_del(struct net_device *dev, unsigned short vid)
 	if (!vlan_info)
 		return;
 
-	vid_info = vlan_vid_info_get(vlan_info, vid);
+	vid_info = vlan_vid_info_get(vlan_info, proto, vid);
 	if (!vid_info)
 		return;
 	vid_info->refcount--;
@@ -333,7 +338,7 @@ int vlan_vids_add_by_dev(struct net_device *dev,
 		return 0;
 
 	list_for_each_entry(vid_info, &vlan_info->vid_list, list) {
-		err = vlan_vid_add(dev, vid_info->vid);
+		err = vlan_vid_add(dev, vid_info->proto, vid_info->vid);
 		if (err)
 			goto unwind;
 	}
@@ -343,7 +348,7 @@ unwind:
 	list_for_each_entry_continue_reverse(vid_info,
 					     &vlan_info->vid_list,
 					     list) {
-		vlan_vid_del(dev, vid_info->vid);
+		vlan_vid_del(dev, vid_info->proto, vid_info->vid);
 	}
 
 	return err;
@@ -363,7 +368,7 @@ void vlan_vids_del_by_dev(struct net_device *dev,
 		return;
 
 	list_for_each_entry(vid_info, &vlan_info->vid_list, list)
-		vlan_vid_del(dev, vid_info->vid);
+		vlan_vid_del(dev, vid_info->proto, vid_info->vid);
 }
 EXPORT_SYMBOL(vlan_vids_del_by_dev);
 
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 0b3dbbe..c3076e2 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -34,6 +34,7 @@ static void __vlan_add_flags(struct net_port_vlans *v, u16 vid, u16 flags)
 
 static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 {
+	const struct net_device_ops *ops;
 	struct net_bridge_port *p = NULL;
 	struct net_bridge *br;
 	struct net_device *dev;
@@ -53,6 +54,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 			br = v->parent.br;
 			dev = br->dev;
 		}
+		ops = dev->netdev_ops;
 
 		if (p && (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
 			/* Add VLAN to the device filter if it is supported.
@@ -61,7 +63,8 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 			 * that ever changes this code will allow tagged
 			 * traffic to enter the bridge.
 			 */
-			err = dev->netdev_ops->ndo_vlan_rx_add_vid(dev, vid);
+			err = ops->ndo_vlan_rx_add_vid(dev, htons(ETH_P_8021Q),
+						       vid);
 			if (err)
 				return err;
 		}
@@ -83,7 +86,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 
 out_filt:
 	if (p && (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
-		dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, vid);
+		ops->ndo_vlan_rx_kill_vid(dev, htons(ETH_P_8021Q), vid);
 	return err;
 }
 
@@ -97,9 +100,10 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 
 	if (v->port_idx && vid) {
 		struct net_device *dev = v->parent.port->dev;
+		const struct net_device_ops *ops = dev->netdev_ops;
 
 		if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
-			dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, vid);
+			ops->ndo_vlan_rx_kill_vid(dev, htons(ETH_P_8021Q), vid);
 	}
 
 	clear_bit(vid, v->vlan_bitmap);
-- 
1.8.1.4

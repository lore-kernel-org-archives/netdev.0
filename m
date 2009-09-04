From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/3] igb: add support for set_rx_mode netdevice
	operation
Date: Thu, 03 Sep 2009 17:48:56 -0700
Message-ID: <20090904004828.14537.72187.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:53654 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754016AbZIDAtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 20:49:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for the set_rx_mode netdevice operation so that igb
can better support multiple unicast addresses.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   73 +++++++++++++++++++++++++++++---------------
 1 files changed, 48 insertions(+), 25 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7a054d9..95089a8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -94,7 +94,7 @@ static void igb_clean_all_tx_rings(struct igb_adapter *);
 static void igb_clean_all_rx_rings(struct igb_adapter *);
 static void igb_clean_tx_ring(struct igb_ring *);
 static void igb_clean_rx_ring(struct igb_ring *);
-static void igb_set_multi(struct net_device *);
+static void igb_set_rx_mode(struct net_device *);
 static void igb_update_phy_info(unsigned long);
 static void igb_watchdog(unsigned long);
 static void igb_watchdog_task(struct work_struct *);
@@ -928,7 +928,7 @@ static void igb_configure(struct igb_adapter *adapter)
 	int i;
 
 	igb_get_hw_control(adapter);
-	igb_set_multi(netdev);
+	igb_set_rx_mode(netdev);
 
 	igb_restore_vlan(adapter);
 
@@ -1169,7 +1169,8 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_stop		= igb_close,
 	.ndo_start_xmit		= igb_xmit_frame_adv,
 	.ndo_get_stats		= igb_get_stats,
-	.ndo_set_multicast_list	= igb_set_multi,
+	.ndo_set_rx_mode	= igb_set_rx_mode,
+	.ndo_set_multicast_list	= igb_set_rx_mode,
 	.ndo_set_mac_address	= igb_set_mac,
 	.ndo_change_mtu		= igb_change_mtu,
 	.ndo_do_ioctl		= igb_ioctl,
@@ -2519,48 +2520,70 @@ static int igb_set_mac(struct net_device *netdev, void *p)
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
 
-	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
-
+	igb_rar_set(hw, hw->mac.addr, 0);
 	igb_set_rah_pool(hw, adapter->vfs_allocated_count, 0);
 
 	return 0;
 }
 
 /**
- * igb_set_multi - Multicast and Promiscuous mode set
+ * igb_set_rx_mode - Secondary Unicast, Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
- * The set_multi entry point is called whenever the multicast address
- * list or the network interface flags are updated.  This routine is
- * responsible for configuring the hardware for proper multicast,
+ * The set_rx_mode entry point is called whenever the unicast or multicast
+ * address lists or the network interface flags are updated.  This routine is
+ * responsible for configuring the hardware for proper unicast, multicast,
  * promiscuous mode, and all-multi behavior.
  **/
-static void igb_set_multi(struct net_device *netdev)
+static void igb_set_rx_mode(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	unsigned int rar_entries = hw->mac.rar_entry_count -
+	                           (adapter->vfs_allocated_count + 1);
+	struct dev_mc_list *mc_ptr = netdev->mc_list;
 	u8  *mta_list = NULL;
 	u32 rctl;
 	int i;
 
 	/* Check for Promiscuous and All Multicast modes */
-
 	rctl = rd32(E1000_RCTL);
 
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
 		rctl &= ~E1000_RCTL_VFE;
 	} else {
-		if (netdev->flags & IFF_ALLMULTI) {
+		if (netdev->flags & IFF_ALLMULTI)
 			rctl |= E1000_RCTL_MPE;
+		else
+			rctl &= ~E1000_RCTL_MPE;
+
+		if (netdev->uc.count > rar_entries)
+			rctl |= E1000_RCTL_UPE;
+		else
 			rctl &= ~E1000_RCTL_UPE;
-		} else
-			rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
 		rctl |= E1000_RCTL_VFE;
 	}
 	wr32(E1000_RCTL, rctl);
 
+	if (netdev->uc.count && rar_entries) {
+		struct netdev_hw_addr *ha;
+		list_for_each_entry(ha, &netdev->uc.list, list) {
+			if (!rar_entries)
+				break;
+			igb_rar_set(hw, ha->addr, rar_entries);
+			igb_set_rah_pool(hw, adapter->vfs_allocated_count,
+			                 rar_entries);
+			rar_entries--;
+		}
+	}
+	/* write the addresses in reverse order to avoid write combining */
+	for (; rar_entries > 0 ; rar_entries--) {
+		wr32(E1000_RAH(rar_entries), 0);
+		wr32(E1000_RAL(rar_entries), 0);
+	}
+	wrfl();
+
 	if (!netdev->mc_count) {
 		/* nothing to program, so clear mc list */
 		igb_update_mc_addr_list(hw, NULL, 0);
@@ -2576,8 +2599,6 @@ static void igb_set_multi(struct net_device *netdev)
 	}
 
 	/* The shared function expects a packed array of only addresses. */
-	mc_ptr = netdev->mc_list;
-
 	for (i = 0; i < netdev->mc_count; i++) {
 		if (!mc_ptr)
 			break;
@@ -3938,7 +3959,7 @@ static int igb_set_vf_multicasts(struct igb_adapter *adapter,
 		vf_data->vf_mc_hashes[i] = hash_list[i];;
 
 	/* Flush and reset the mta with the new values */
-	igb_set_multi(adapter->netdev);
+	igb_set_rx_mode(adapter->netdev);
 
 	return 0;
 }
@@ -4072,13 +4093,14 @@ static inline void igb_vf_reset_event(struct igb_adapter *adapter, u32 vf)
 	adapter->vf_data[vf].num_vf_mc_hashes = 0;
 
 	/* Flush and reset the mta with the new values */
-	igb_set_multi(adapter->netdev);
+	igb_set_rx_mode(adapter->netdev);
 }
 
 static inline void igb_vf_reset_msg(struct igb_adapter *adapter, u32 vf)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	unsigned char *vf_mac = adapter->vf_data[vf].vf_mac_addresses;
+	int rar_entry = hw->mac.rar_entry_count - (vf + 1);
 	u32 reg, msgbuf[3];
 	u8 *addr = (u8 *)(&msgbuf[1]);
 
@@ -4086,8 +4108,8 @@ static inline void igb_vf_reset_msg(struct igb_adapter *adapter, u32 vf)
 	igb_vf_reset_event(adapter, vf);
 
 	/* set vf mac address */
-	igb_rar_set(hw, vf_mac, vf + 1);
-	igb_set_rah_pool(hw, vf, vf + 1);
+	igb_rar_set(hw, vf_mac, rar_entry);
+	igb_set_rah_pool(hw, vf, rar_entry);
 
 	/* enable transmit and receive for vf */
 	reg = rd32(E1000_VFTE);
@@ -5228,7 +5250,7 @@ static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 	if (wufc) {
 		igb_setup_rctl(adapter);
-		igb_set_multi(netdev);
+		igb_set_rx_mode(netdev);
 
 		/* turn on all-multi mode if wake on multicast is enabled */
 		if (wufc & E1000_WUFC_MC) {
@@ -5482,12 +5504,13 @@ static int igb_set_vf_mac(struct igb_adapter *adapter,
                           int vf, unsigned char *mac_addr)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	int rar_entry = vf + 1; /* VF MAC addresses start at entry 1 */
-
-	igb_rar_set(hw, mac_addr, rar_entry);
+	/* VF MAC addresses start at end of receive addresses and moves
+	 * torwards the first, as a result a collision should not be possible */
+	int rar_entry = hw->mac.rar_entry_count - (vf + 1);
 
 	memcpy(adapter->vf_data[vf].vf_mac_addresses, mac_addr, ETH_ALEN);
 
+	igb_rar_set(hw, mac_addr, rar_entry);
 	igb_set_rah_pool(hw, vf, rar_entry);
 
 	return 0;


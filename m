From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 10/29] fm10k: Add support for L2 filtering
Date: Thu, 18 Sep 2014 18:37:04 -0400
Message-ID: <20140918223703.10373.77102.stgit@ahduyck-bv4.jf.intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8597 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757161AbaIRWpu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 18:45:50 -0400
In-Reply-To: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for L2 filtering.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |    2 
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |  355 +++++++++++++++++++++++
 2 files changed, 356 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index fa3e5e1..33256fa 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -133,4 +133,6 @@ void fm10k_unregister_pci_driver(void);
 
 /* Netdev */
 struct net_device *fm10k_alloc_netdev(void);
+void fm10k_restore_rx_state(struct fm10k_intfc *);
+void fm10k_reset_rx_state(struct fm10k_intfc *);
 #endif /* _FM10K_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 9a4f3a6..cf7b4f3 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -36,24 +36,365 @@ static int fm10k_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static int fm10k_uc_vlan_unsync(struct net_device *netdev,
+				const unsigned char *uc_addr)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct fm10k_hw *hw = &interface->hw;
+	u16 glort = interface->glort;
+	u16 vid = interface->vid;
+	bool set = !!(vid / VLAN_N_VID);
+	int err;
+
+	/* drop any leading bits on the VLAN ID */
+	vid &= VLAN_N_VID - 1;
+
+	err = hw->mac.ops.update_uc_addr(hw, glort, uc_addr, vid, set, 0);
+	if (err)
+		return err;
+
+	/* return non-zero value as we are only doing a partial sync/unsync */
+	return 1;
+}
+
+static int fm10k_mc_vlan_unsync(struct net_device *netdev,
+				const unsigned char *mc_addr)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct fm10k_hw *hw = &interface->hw;
+	u16 glort = interface->glort;
+	u16 vid = interface->vid;
+	bool set = !!(vid / VLAN_N_VID);
+	int err;
+
+	/* drop any leading bits on the VLAN ID */
+	vid &= VLAN_N_VID - 1;
+
+	err = hw->mac.ops.update_mc_addr(hw, glort, mc_addr, vid, set);
+	if (err)
+		return err;
+
+	/* return non-zero value as we are only doing a partial sync/unsync */
+	return 1;
+}
+
+static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct fm10k_hw *hw = &interface->hw;
+	s32 err;
+
+	/* updates do not apply to VLAN 0 */
+	if (!vid)
+		return 0;
+
+	if (vid >= VLAN_N_VID)
+		return -EINVAL;
+
+	/* Verify we have permission to add VLANs */
+	if (hw->mac.vlan_override)
+		return -EACCES;
+
+	/* if default VLAN is already present do nothing */
+	if (vid == hw->mac.default_vid)
+		return -EBUSY;
+
+	/* update active_vlans bitmask */
+	set_bit(vid, interface->active_vlans);
+	if (!set)
+		clear_bit(vid, interface->active_vlans);
+
+	fm10k_mbx_lock(interface);
+
+	/* only need to update the VLAN if not in promiscous mode */
+	if (!(netdev->flags & IFF_PROMISC)) {
+		err = hw->mac.ops.update_vlan(hw, vid, 0, set);
+		if (err)
+			return err;
+	}
+
+	/* update our base MAC address */
+	err = hw->mac.ops.update_uc_addr(hw, interface->glort, hw->mac.addr,
+					 vid, set, 0);
+	if (err)
+		return err;
+
+	/* set vid prior to syncing/unsyncing the VLAN */
+	interface->vid = vid + (set ? VLAN_N_VID : 0);
+
+	/* Update the unicast and multicast address list to add/drop VLAN */
+	__dev_uc_unsync(netdev, fm10k_uc_vlan_unsync);
+	__dev_mc_unsync(netdev, fm10k_mc_vlan_unsync);
+
+	fm10k_mbx_unlock(interface);
+
+	return 0;
+}
+
+static int fm10k_vlan_rx_add_vid(struct net_device *netdev,
+				 __always_unused __be16 proto, u16 vid)
+{
+	/* update VLAN and address table based on changes */
+	return fm10k_update_vid(netdev, vid, true);
+}
+
+static int fm10k_vlan_rx_kill_vid(struct net_device *netdev,
+				  __always_unused __be16 proto, u16 vid)
+{
+	/* update VLAN and address table based on changes */
+	return fm10k_update_vid(netdev, vid, false);
+}
+
+static u16 fm10k_find_next_vlan(struct fm10k_intfc *interface, u16 vid)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	u16 default_vid = hw->mac.default_vid;
+	u16 vid_limit = vid < default_vid ? default_vid : VLAN_N_VID;
+
+	vid = find_next_bit(interface->active_vlans, vid_limit, ++vid);
+
+	return vid;
+}
+
+static void fm10k_clear_unused_vlans(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	u32 vid, prev_vid;
+
+	/* loop through and find any gaps in the table */
+	for (vid = 0, prev_vid = 0;
+	     prev_vid < VLAN_N_VID;
+	     prev_vid = vid + 1, vid = fm10k_find_next_vlan(interface, vid)) {
+		if (prev_vid == vid)
+			continue;
+
+		/* send request to clear multiple bits at a time */
+		prev_vid += (vid - prev_vid - 1) << FM10K_VLAN_LENGTH_SHIFT;
+		hw->mac.ops.update_vlan(hw, prev_vid, 0, false);
+	}
+}
+
+static int __fm10k_uc_sync(struct net_device *dev,
+			   const unsigned char *addr, bool sync)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_hw *hw = &interface->hw;
+	u16 vid, glort = interface->glort;
+	s32 err;
+
+	if (!is_valid_ether_addr(addr))
+		return -EADDRNOTAVAIL;
+
+	/* update table with current entries */
+	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 0;
+	     vid < VLAN_N_VID;
+	     vid = fm10k_find_next_vlan(interface, vid)) {
+		err = hw->mac.ops.update_uc_addr(hw, glort, addr,
+						  vid, sync, 0);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int fm10k_uc_sync(struct net_device *dev,
+			 const unsigned char *addr)
+{
+	return __fm10k_uc_sync(dev, addr, true);
+}
+
+static int fm10k_uc_unsync(struct net_device *dev,
+			   const unsigned char *addr)
+{
+	return __fm10k_uc_sync(dev, addr, false);
+}
+
 static int fm10k_set_mac(struct net_device *dev, void *p)
 {
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_hw *hw = &interface->hw;
 	struct sockaddr *addr = p;
 	s32 err = 0;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	if (dev->flags & IFF_UP) {
+		/* setting MAC address requires mailbox */
+		fm10k_mbx_lock(interface);
+
+		err = fm10k_uc_sync(dev, addr->sa_data);
+		if (!err)
+			fm10k_uc_unsync(dev, hw->mac.addr);
+
+		fm10k_mbx_unlock(interface);
+	}
+
 	if (!err) {
 		ether_addr_copy(dev->dev_addr, addr->sa_data);
+		ether_addr_copy(hw->mac.addr, addr->sa_data);
 		dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	}
 
-	return err;
+	/* if we had a mailbox error suggest trying again */
+	return err ? -EAGAIN : 0;
+}
+
+static int __fm10k_mc_sync(struct net_device *dev,
+			   const unsigned char *addr, bool sync)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_hw *hw = &interface->hw;
+	u16 vid, glort = interface->glort;
+	s32 err;
+
+	if (!is_multicast_ether_addr(addr))
+		return -EADDRNOTAVAIL;
+
+	/* update table with current entries */
+	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 0;
+	     vid < VLAN_N_VID;
+	     vid = fm10k_find_next_vlan(interface, vid)) {
+		err = hw->mac.ops.update_mc_addr(hw, glort, addr, vid, sync);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int fm10k_mc_sync(struct net_device *dev,
+			 const unsigned char *addr)
+{
+	return __fm10k_mc_sync(dev, addr, true);
+}
+
+static int fm10k_mc_unsync(struct net_device *dev,
+			   const unsigned char *addr)
+{
+	return __fm10k_mc_sync(dev, addr, false);
 }
 
 static void fm10k_set_rx_mode(struct net_device *dev)
 {
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_hw *hw = &interface->hw;
+	int xcast_mode;
+
+	/* no need to update the harwdare if we are not running */
+	if (!(dev->flags & IFF_UP))
+		return;
+
+	/* determine new mode based on flags */
+	xcast_mode = (dev->flags & IFF_PROMISC) ? FM10K_XCAST_MODE_PROMISC :
+		     (dev->flags & IFF_ALLMULTI) ? FM10K_XCAST_MODE_ALLMULTI :
+		     (dev->flags & (IFF_BROADCAST | IFF_MULTICAST)) ?
+		     FM10K_XCAST_MODE_MULTI : FM10K_XCAST_MODE_NONE;
+
+	fm10k_mbx_lock(interface);
+
+	/* syncronize all of the addresses */
+	if (xcast_mode != FM10K_XCAST_MODE_PROMISC) {
+		__dev_uc_sync(dev, fm10k_uc_sync, fm10k_uc_unsync);
+		if (xcast_mode != FM10K_XCAST_MODE_ALLMULTI)
+			__dev_mc_sync(dev, fm10k_mc_sync, fm10k_mc_unsync);
+	}
+
+	/* if we aren't changing modes there is nothing to do */
+	if (interface->xcast_mode != xcast_mode) {
+		/* update VLAN table */
+		if (xcast_mode == FM10K_XCAST_MODE_PROMISC)
+			hw->mac.ops.update_vlan(hw, FM10K_VLAN_ALL, 0, true);
+		if (interface->xcast_mode == FM10K_XCAST_MODE_PROMISC)
+			fm10k_clear_unused_vlans(interface);
+
+		/* update xcast mode */
+		hw->mac.ops.update_xcast_mode(hw, interface->glort, xcast_mode);
+
+		/* record updated xcast mode state */
+		interface->xcast_mode = xcast_mode;
+	}
+
+	fm10k_mbx_unlock(interface);
+}
+
+void fm10k_restore_rx_state(struct fm10k_intfc *interface)
+{
+	struct net_device *netdev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+	int xcast_mode;
+	u16 vid, glort;
+
+	/* record glort for this interface */
+	glort = interface->glort;
+
+	/* convert interface flags to xcast mode */
+	if (netdev->flags & IFF_PROMISC)
+		xcast_mode = FM10K_XCAST_MODE_PROMISC;
+	else if (netdev->flags & IFF_ALLMULTI)
+		xcast_mode = FM10K_XCAST_MODE_ALLMULTI;
+	else if (netdev->flags & (IFF_BROADCAST | IFF_MULTICAST))
+		xcast_mode = FM10K_XCAST_MODE_MULTI;
+	else
+		xcast_mode = FM10K_XCAST_MODE_NONE;
+
+	fm10k_mbx_lock(interface);
+
+	/* Enable logical port */
+	hw->mac.ops.update_lport_state(hw, glort, interface->glort_count, true);
+
+	/* update VLAN table */
+	hw->mac.ops.update_vlan(hw, FM10K_VLAN_ALL, 0,
+				xcast_mode == FM10K_XCAST_MODE_PROMISC);
+
+	/* Add filter for VLAN 0 */
+	hw->mac.ops.update_vlan(hw, 0, 0, true);
+
+	/* update table with current entries */
+	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 0;
+	     vid < VLAN_N_VID;
+	     vid = fm10k_find_next_vlan(interface, vid)) {
+		hw->mac.ops.update_vlan(hw, vid, 0, true);
+		hw->mac.ops.update_uc_addr(hw, glort, hw->mac.addr,
+					   vid, true, 0);
+	}
+
+	/* syncronize all of the addresses */
+	if (xcast_mode != FM10K_XCAST_MODE_PROMISC) {
+		__dev_uc_sync(netdev, fm10k_uc_sync, fm10k_uc_unsync);
+		if (xcast_mode != FM10K_XCAST_MODE_ALLMULTI)
+			__dev_mc_sync(netdev, fm10k_mc_sync, fm10k_mc_unsync);
+	}
+
+	/* update xcast mode */
+	hw->mac.ops.update_xcast_mode(hw, glort, xcast_mode);
+
+	fm10k_mbx_unlock(interface);
+
+	/* record updated xcast mode state */
+	interface->xcast_mode = xcast_mode;
+}
+
+void fm10k_reset_rx_state(struct fm10k_intfc *interface)
+{
+	struct net_device *netdev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+
+	fm10k_mbx_lock(interface);
+
+	/* clear the logical port state on lower device */
+	hw->mac.ops.update_lport_state(hw, interface->glort,
+				       interface->glort_count, false);
+
+	fm10k_mbx_unlock(interface);
+
+	/* reset flags to default state */
+	interface->xcast_mode = FM10K_XCAST_MODE_NONE;
+
+	/* clear the sync flag since the lport has been dropped */
+	__dev_uc_unsync(netdev, NULL);
+	__dev_mc_unsync(netdev, NULL);
 }
 
 static const struct net_device_ops fm10k_netdev_ops = {
@@ -61,6 +402,8 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_start_xmit		= fm10k_xmit_frame,
 	.ndo_set_mac_address	= fm10k_set_mac,
 	.ndo_change_mtu		= fm10k_change_mtu,
+	.ndo_vlan_rx_add_vid	= fm10k_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= fm10k_vlan_rx_kill_vid,
 	.ndo_set_rx_mode	= fm10k_set_rx_mode,
 };
 
@@ -94,5 +437,15 @@ struct net_device *fm10k_alloc_netdev(void)
 	/* configure tunnel offloads */
 	dev->hw_enc_features = NETIF_F_SG;
 
+	/* we want to leave these both on as we cannot disable VLAN tag
+	 * insertion or stripping on the hardware since it is contained
+	 * in the FTAG and not in the frame itself.
+	 */
+	dev->features |= NETIF_F_HW_VLAN_CTAG_TX |
+			 NETIF_F_HW_VLAN_CTAG_RX |
+			 NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	dev->priv_flags |= IFF_UNICAST_FLT;
+
 	return dev;
 }

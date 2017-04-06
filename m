From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/7] fm10k: do not enqueue mailbox when host not ready
Date: Thu,  6 Apr 2017 00:54:56 -0700
Message-ID: <20170406075456.27757-8-jeffrey.t.kirsher@intel.com>
References: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Cc: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jacob Keller <jacob.e.keller@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:39569 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756760AbdDFH4A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 03:56:00 -0400
In-Reply-To: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>

Interfaces will reset whenever the TX mailbox FIFO has become full. This
occurs more frequently whenever the IES API application is not running
to process and clear the messages in the FIFO. Thus, this could lead to
situations where the interface would enter an infinite reset loop. That
is: if the interface is trying to synchronize a huge number of unicast
and multicast entries with the IES API application, the TX mailbox FIFO
will become full and the interface resets. Once the interface exits
reset, it'll try to synchronize the unicast and multicast entries again.
Ergo, this creates an infinite loop. Other actions such as multiple
mulitcast mode or up/down transitions will fill the TX mailbox FIFO and
induce the interface to reset. To correct these situations, check if the
interface's "host_ready" flag is enabled before enqueuing any messages
to the TX mailbox FIFO. This check will be conducted by a function call.
Lastly, this issue mainly affects the PF and, thus, the VF is exempt.

Signed-off-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 105 ++++++++++++++++++------
 1 file changed, 80 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 70cd121d465f..24f2f6f86f5a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -737,6 +737,23 @@ static void fm10k_tx_timeout(struct net_device *netdev)
 	}
 }
 
+/**
+ * fm10k_host_mbx_ready - Check PF interface's mailbox readiness
+ * @interface: board private structure
+ *
+ * This function checks if the PF interface's mailbox is ready before queueing
+ * mailbox messages for transmission. This will prevent filling the TX mailbox
+ * queue when the receiver is not ready. VF interfaces are exempt from this
+ * check since it will block all PF-VF mailbox messages from being sent from
+ * the VF to the PF at initialization.
+ **/
+static bool fm10k_host_mbx_ready(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+
+	return (hw->mac.type == fm10k_mac_vf || interface->host_ready);
+}
+
 static int fm10k_uc_vlan_unsync(struct net_device *netdev,
 				const unsigned char *uc_addr)
 {
@@ -745,12 +762,15 @@ static int fm10k_uc_vlan_unsync(struct net_device *netdev,
 	u16 glort = interface->glort;
 	u16 vid = interface->vid;
 	bool set = !!(vid / VLAN_N_VID);
-	int err;
+	int err = -EHOSTDOWN;
 
 	/* drop any leading bits on the VLAN ID */
 	vid &= VLAN_N_VID - 1;
 
-	err = hw->mac.ops.update_uc_addr(hw, glort, uc_addr, vid, set, 0);
+	if (fm10k_host_mbx_ready(interface))
+		err = hw->mac.ops.update_uc_addr(hw, glort, uc_addr,
+						 vid, set, 0);
+
 	if (err)
 		return err;
 
@@ -766,12 +786,14 @@ static int fm10k_mc_vlan_unsync(struct net_device *netdev,
 	u16 glort = interface->glort;
 	u16 vid = interface->vid;
 	bool set = !!(vid / VLAN_N_VID);
-	int err;
+	int err = -EHOSTDOWN;
 
 	/* drop any leading bits on the VLAN ID */
 	vid &= VLAN_N_VID - 1;
 
-	err = hw->mac.ops.update_mc_addr(hw, glort, mc_addr, vid, set);
+	if (fm10k_host_mbx_ready(interface))
+		err = hw->mac.ops.update_mc_addr(hw, glort, mc_addr, vid, set);
+
 	if (err)
 		return err;
 
@@ -834,9 +856,13 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 			goto err_out;
 	}
 
-	/* update our base MAC address */
-	err = hw->mac.ops.update_uc_addr(hw, interface->glort, hw->mac.addr,
-					 vid, set, 0);
+	/* update our base MAC address if host's mailbox is ready */
+	if (fm10k_host_mbx_ready(interface))
+		err = hw->mac.ops.update_uc_addr(hw, interface->glort,
+						 hw->mac.addr, vid, set, 0);
+	else
+		err = -EHOSTDOWN;
+
 	if (err)
 		goto err_out;
 
@@ -907,12 +933,15 @@ static int __fm10k_uc_sync(struct net_device *dev,
 	if (!is_valid_ether_addr(addr))
 		return -EADDRNOTAVAIL;
 
-	/* update table with current entries */
+	/* update table with current entries if host's mailbox is ready */
+	if (!fm10k_host_mbx_ready(interface))
+		return -EHOSTDOWN;
+
 	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 1;
 	     vid < VLAN_N_VID;
 	     vid = fm10k_find_next_vlan(interface, vid)) {
 		err = hw->mac.ops.update_uc_addr(hw, glort, addr,
-						  vid, sync, 0);
+						 vid, sync, 0);
 		if (err)
 			return err;
 	}
@@ -970,7 +999,10 @@ static int __fm10k_mc_sync(struct net_device *dev,
 	struct fm10k_hw *hw = &interface->hw;
 	u16 vid, glort = interface->glort;
 
-	/* update table with current entries */
+	/* update table with current entries if host's mailbox is ready */
+	if (!fm10k_host_mbx_ready(interface))
+		return 0;
+
 	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 1;
 	     vid < VLAN_N_VID;
 	     vid = fm10k_find_next_vlan(interface, vid)) {
@@ -1018,8 +1050,10 @@ static void fm10k_set_rx_mode(struct net_device *dev)
 		if (interface->xcast_mode == FM10K_XCAST_MODE_PROMISC)
 			fm10k_clear_unused_vlans(interface);
 
-		/* update xcast mode */
-		hw->mac.ops.update_xcast_mode(hw, interface->glort, xcast_mode);
+		/* update xcast mode if host's mailbox is ready */
+		if (fm10k_host_mbx_ready(interface))
+			hw->mac.ops.update_xcast_mode(hw, interface->glort,
+						      xcast_mode);
 
 		/* record updated xcast mode state */
 		interface->xcast_mode = xcast_mode;
@@ -1054,8 +1088,10 @@ void fm10k_restore_rx_state(struct fm10k_intfc *interface)
 
 	fm10k_mbx_lock(interface);
 
-	/* Enable logical port */
-	hw->mac.ops.update_lport_state(hw, glort, interface->glort_count, true);
+	/* Enable logical port if host's mailbox is ready */
+	if (fm10k_host_mbx_ready(interface))
+		hw->mac.ops.update_lport_state(hw, glort,
+					       interface->glort_count, true);
 
 	/* update VLAN table */
 	hw->mac.ops.update_vlan(hw, FM10K_VLAN_ALL, 0,
@@ -1069,12 +1105,18 @@ void fm10k_restore_rx_state(struct fm10k_intfc *interface)
 	     vid < VLAN_N_VID;
 	     vid = fm10k_find_next_vlan(interface, vid)) {
 		hw->mac.ops.update_vlan(hw, vid, 0, true);
-		hw->mac.ops.update_uc_addr(hw, glort, hw->mac.addr,
-					   vid, true, 0);
+
+		/* Update unicast entries if host's mailbox is ready */
+		if (fm10k_host_mbx_ready(interface))
+			hw->mac.ops.update_uc_addr(hw, glort, hw->mac.addr,
+						   vid, true, 0);
 	}
 
-	/* update xcast mode before synchronizing addresses */
-	hw->mac.ops.update_xcast_mode(hw, glort, xcast_mode);
+	/* update xcast mode before synchronizing addresses if host's mailbox
+	 * is ready
+	 */
+	if (fm10k_host_mbx_ready(interface))
+		hw->mac.ops.update_xcast_mode(hw, glort, xcast_mode);
 
 	/* synchronize all of the addresses */
 	__dev_uc_sync(netdev, fm10k_uc_sync, fm10k_uc_unsync);
@@ -1096,9 +1138,12 @@ void fm10k_reset_rx_state(struct fm10k_intfc *interface)
 
 	fm10k_mbx_lock(interface);
 
-	/* clear the logical port state on lower device */
-	hw->mac.ops.update_lport_state(hw, interface->glort,
-				       interface->glort_count, false);
+	/* clear the logical port state on lower device if host's mailbox is
+	 * ready
+	 */
+	if (fm10k_host_mbx_ready(interface))
+		hw->mac.ops.update_lport_state(hw, interface->glort,
+					       interface->glort_count, false);
 
 	fm10k_mbx_unlock(interface);
 
@@ -1319,8 +1364,13 @@ static void *fm10k_dfwd_add_station(struct net_device *dev,
 	fm10k_mbx_lock(interface);
 
 	glort = l2_accel->dglort + 1 + i;
-	hw->mac.ops.update_xcast_mode(hw, glort, FM10K_XCAST_MODE_MULTI);
-	hw->mac.ops.update_uc_addr(hw, glort, sdev->dev_addr, 0, true, 0);
+
+	if (fm10k_host_mbx_ready(interface)) {
+		hw->mac.ops.update_xcast_mode(hw, glort,
+					      FM10K_XCAST_MODE_MULTI);
+		hw->mac.ops.update_uc_addr(hw, glort, sdev->dev_addr,
+					   0, true, 0);
+	}
 
 	fm10k_mbx_unlock(interface);
 
@@ -1354,8 +1404,13 @@ static void fm10k_dfwd_del_station(struct net_device *dev, void *priv)
 	fm10k_mbx_lock(interface);
 
 	glort = l2_accel->dglort + 1 + i;
-	hw->mac.ops.update_xcast_mode(hw, glort, FM10K_XCAST_MODE_NONE);
-	hw->mac.ops.update_uc_addr(hw, glort, sdev->dev_addr, 0, false, 0);
+
+	if (fm10k_host_mbx_ready(interface)) {
+		hw->mac.ops.update_xcast_mode(hw, glort,
+					      FM10K_XCAST_MODE_NONE);
+		hw->mac.ops.update_uc_addr(hw, glort, sdev->dev_addr,
+					   0, false, 0);
+	}
 
 	fm10k_mbx_unlock(interface);
 
-- 
2.12.2

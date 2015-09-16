From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/18] fm10k: send traffic on default VID to VLAN device if we have one
Date: Tue, 15 Sep 2015 17:36:39 -0700
Message-ID: <1442363803-47237-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26175 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753305AbbIPAgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:51 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch ensures that VLAN traffic on the default VID will go to the
corresponding VLAN device if it exists. To do this, mask the rx_ring VID
if we have an active VLAN on that VID.

For this to work correctly, we need to update fm10k_process_skb_fields
to correctly mask off the VLAN_PRIO_MASK bits and compare them
separately, otherwise we incorrectly compare the priority bits with the
cleared flag. This also happens to fix a related bug where having
priority bits set causes us to incorrectly classify traffic.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |  5 ++++-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 12 ++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |  4 ++++
 3 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 6ad03e0..92d4155 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -497,8 +497,11 @@ static unsigned int fm10k_process_skb_fields(struct fm10k_ring *rx_ring,
 	if (rx_desc->w.vlan) {
 		u16 vid = le16_to_cpu(rx_desc->w.vlan);
 
-		if (vid != rx_ring->vid)
+		if ((vid & VLAN_VID_MASK) != rx_ring->vid)
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
+		else if (vid & VLAN_PRIO_MASK)
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+					       vid & VLAN_PRIO_MASK);
 	}
 
 	fm10k_type_trans(rx_ring, rx_desc, skb);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index e1ceb3a..3a6230b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -758,6 +758,7 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 	struct fm10k_intfc *interface = netdev_priv(netdev);
 	struct fm10k_hw *hw = &interface->hw;
 	s32 err;
+	int i;
 
 	/* updates do not apply to VLAN 0 */
 	if (!vid)
@@ -775,6 +776,17 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 	if (!set)
 		clear_bit(vid, interface->active_vlans);
 
+	/* disable the default VID on ring if we have an active VLAN */
+	for (i = 0; i < interface->num_rx_queues; i++) {
+		struct fm10k_ring *rx_ring = interface->rx_ring[i];
+		u16 rx_vid = rx_ring->vid & (VLAN_N_VID - 1);
+
+		if (test_bit(rx_vid, interface->active_vlans))
+			rx_ring->vid |= FM10K_VLAN_CLEAR;
+		else
+			rx_ring->vid &= ~FM10K_VLAN_CLEAR;
+	}
+
 	/* Do not remove default VID related entries from VLAN and MAC tables */
 	if (!set && vid == hw->mac.default_vid)
 		return 0;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 9f2b2f1..9bdc04d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -678,6 +678,10 @@ static void fm10k_configure_rx_ring(struct fm10k_intfc *interface,
 	/* assign default VLAN to queue */
 	ring->vid = hw->mac.default_vid;
 
+	/* if we have an active VLAN, disable default VID */
+	if (test_bit(hw->mac.default_vid, interface->active_vlans))
+		ring->vid |= FM10K_VLAN_CLEAR;
+
 	/* Map interrupt */
 	if (ring->q_vector) {
 		rxint = ring->q_vector->v_idx + NON_Q_VECTORS(hw);
-- 
2.4.3

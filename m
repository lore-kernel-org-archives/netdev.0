From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/18] fm10k: update netdev perm_addr during reinit, instead of at up
Date: Tue, 15 Sep 2015 17:36:32 -0700
Message-ID: <1442363803-47237-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:26285 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288AbbIPAgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:49 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Update the netdev permanent address during fm10k_reinit enables the user
to immediately see the new MAC address on the VF even if the device
isn't up. The previous code required that the device by opened before
changes would appear.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 15 ---------------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    | 15 +++++++++++++++
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 818bc8b..b2065cb 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -996,21 +996,6 @@ void fm10k_restore_rx_state(struct fm10k_intfc *interface)
 	int xcast_mode;
 	u16 vid, glort;
 
-	/* restore our address if perm_addr is set */
-	if (hw->mac.type == fm10k_mac_vf) {
-		if (is_valid_ether_addr(hw->mac.perm_addr)) {
-			ether_addr_copy(hw->mac.addr, hw->mac.perm_addr);
-			ether_addr_copy(netdev->perm_addr, hw->mac.perm_addr);
-			ether_addr_copy(netdev->dev_addr, hw->mac.perm_addr);
-			netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
-		}
-
-		if (hw->mac.vlan_override)
-			netdev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
-		else
-			netdev->features |= NETIF_F_HW_VLAN_CTAG_RX;
-	}
-
 	/* record glort for this interface */
 	glort = interface->glort;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 2d87c32..db237b7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -170,6 +170,21 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 	/* reassociate interrupts */
 	fm10k_mbx_request_irq(interface);
 
+	/* update hardware address for VFs if perm_addr has changed */
+	if (hw->mac.type == fm10k_mac_vf) {
+		if (is_valid_ether_addr(hw->mac.perm_addr)) {
+			ether_addr_copy(hw->mac.addr, hw->mac.perm_addr);
+			ether_addr_copy(netdev->perm_addr, hw->mac.perm_addr);
+			ether_addr_copy(netdev->dev_addr, hw->mac.perm_addr);
+			netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
+		}
+
+		if (hw->mac.vlan_override)
+			netdev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
+		else
+			netdev->features |= NETIF_F_HW_VLAN_CTAG_RX;
+	}
+
 	/* reset clock */
 	fm10k_ts_reset(interface);
 
-- 
2.4.3

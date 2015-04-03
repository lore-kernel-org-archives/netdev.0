From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e/i40evf: Set Ethernet protocol correctly when Tx VLAN offloads are disabled
Date: Fri,  3 Apr 2015 05:04:51 -0700
Message-ID: <1428062698-16180-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10571 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752456AbbDCMFk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 08:05:40 -0400
In-Reply-To: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If transmit VLAN HW offloads are disabled then the network stack sends up
an skb with the protocol set to 8021q. In that case to get the correct
checksum offloads we have to reset the skb protocol to the encapsulated
ethertype.

Change-ID: I903d78533de09b1c5d3ec695ee1990dd0fa5dd0d
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 13 +++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 14 ++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5a1a677..d8989f9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2057,6 +2057,19 @@ static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 	__be16 protocol = skb->protocol;
 	u32  tx_flags = 0;
 
+	if (protocol == htons(ETH_P_8021Q) &&
+	    !(tx_ring->netdev->features & NETIF_F_HW_VLAN_CTAG_TX)) {
+		/* When HW VLAN acceleration is turned off by the user the
+		 * stack sets the protocol to 8021q so that the driver
+		 * can take any steps required to support the SW only
+		 * VLAN handling.  In our case the driver doesn't need
+		 * to take any further steps so just set the protocol
+		 * to the encapsulated ethertype.
+		 */
+		skb->protocol = vlan_get_protocol(skb);
+		goto out;
+	}
+
 	/* if we have a HW VLAN tag being added, default to the HW one */
 	if (skb_vlan_tag_present(skb)) {
 		tx_flags |= skb_vlan_tag_get(skb) << I40E_TX_FLAGS_VLAN_SHIFT;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 2be50a8..e2ddb30 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1370,6 +1370,19 @@ static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 	__be16 protocol = skb->protocol;
 	u32  tx_flags = 0;
 
+	if (protocol == htons(ETH_P_8021Q) &&
+	    !(tx_ring->netdev->features & NETIF_F_HW_VLAN_CTAG_TX)) {
+		/* When HW VLAN acceleration is turned off by the user the
+		 * stack sets the protocol to 8021q so that the driver
+		 * can take any steps required to support the SW only
+		 * VLAN handling.  In our case the driver doesn't need
+		 * to take any further steps so just set the protocol
+		 * to the encapsulated ethertype.
+		 */
+		skb->protocol = vlan_get_protocol(skb);
+		goto out;
+	}
+
 	/* if we have a HW VLAN tag being added, default to the HW one */
 	if (skb_vlan_tag_present(skb)) {
 		tx_flags |= skb_vlan_tag_get(skb) << I40E_TX_FLAGS_VLAN_SHIFT;
@@ -1386,6 +1399,7 @@ static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 		tx_flags |= I40E_TX_FLAGS_SW_VLAN;
 	}
 
+out:
 	*flags = tx_flags;
 	return 0;
 }
-- 
1.9.3

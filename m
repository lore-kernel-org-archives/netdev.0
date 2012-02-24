From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] e1000: Support sending custom Ethernet CRC.
Date: Fri, 24 Feb 2012 02:13:00 -0800
Message-ID: <1330078389-8203-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34282 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697Ab2BXKNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:17 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Good for testing the RX logic for bad CRC handling.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index e72dc81..bd1d28f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1067,6 +1067,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	   (hw->mac_type != e1000_82547))
 		netdev->hw_features |= NETIF_F_TSO;
 
+	netdev->priv_flags |= IFF_SUPP_NOFCS;
+
 	netdev->features |= netdev->hw_features;
 	netdev->hw_features |= NETIF_F_RXCSUM;
 
@@ -2692,6 +2694,7 @@ set_itr_now:
 #define E1000_TX_FLAGS_VLAN		0x00000002
 #define E1000_TX_FLAGS_TSO		0x00000004
 #define E1000_TX_FLAGS_IPV4		0x00000008
+#define E1000_TX_FLAGS_NO_FCS		0x00000010
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
@@ -2993,6 +2996,9 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 		txd_upper |= (tx_flags & E1000_TX_FLAGS_VLAN_MASK);
 	}
 
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS))
+		txd_lower &= ~(E1000_TXD_CMD_IFCS);
+
 	i = tx_ring->next_to_use;
 
 	while (count--) {
@@ -3007,6 +3013,10 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
 
+	/* txd_cmd re-enables FCS, so we'll re-disable it here as desired. */
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS))
+		tx_desc->lower.data &= ~(cpu_to_le32(E1000_TXD_CMD_IFCS));
+
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
 	 * applicable for weak-ordered memory model archs,
@@ -3222,6 +3232,9 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	if (likely(skb->protocol == htons(ETH_P_IP)))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
+	if (unlikely(skb->no_fcs))
+		tx_flags |= E1000_TX_FLAGS_NO_FCS;
+
 	count = e1000_tx_map(adapter, tx_ring, skb, first, max_per_txd,
 	                     nr_frags, mss);
 
-- 
1.7.7.6

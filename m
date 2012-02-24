From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/16] e1000e: Support sending custom Ethernet CRC.
Date: Fri, 24 Feb 2012 02:12:57 -0800
Message-ID: <1330078389-8203-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43469 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915Ab2BXKNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:15 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This can aid with testing the RX logic for bad
CRCs.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 30c8c15..340442c 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4613,6 +4613,7 @@ link_up:
 #define E1000_TX_FLAGS_VLAN		0x00000002
 #define E1000_TX_FLAGS_TSO		0x00000004
 #define E1000_TX_FLAGS_IPV4		0x00000008
+#define E1000_TX_FLAGS_NO_FCS		0x00000010
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
@@ -4872,6 +4873,9 @@ static void e1000_tx_queue(struct e1000_ring *tx_ring, int tx_flags, int count)
 		txd_upper |= (tx_flags & E1000_TX_FLAGS_VLAN_MASK);
 	}
 
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS))
+		txd_lower &= ~(E1000_TXD_CMD_IFCS);
+
 	i = tx_ring->next_to_use;
 
 	do {
@@ -4889,6 +4893,10 @@ static void e1000_tx_queue(struct e1000_ring *tx_ring, int tx_flags, int count)
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
 
+	/* txd_cmd re-enables FCS, so we'll re-disable it here as desired. */
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS))
+		tx_desc->lower.data &= ~(cpu_to_le32(E1000_TXD_CMD_IFCS));
+
 	/*
 	 * Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
@@ -5094,6 +5102,9 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
+	if (unlikely(skb->no_fcs))
+		tx_flags |= E1000_TX_FLAGS_NO_FCS;
+
 	/* if count is 0 then mapping error has occurred */
 	count = e1000_tx_map(tx_ring, skb, first, max_per_txd, nr_frags, mss);
 	if (count) {
@@ -6221,6 +6232,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	/* Set user-changeable features (subset of all device features) */
 	netdev->hw_features = netdev->features;
 	netdev->hw_features |= NETIF_F_RXFCS;
+	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
 	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
 		netdev->features |= NETIF_F_HW_VLAN_FILTER;
-- 
1.7.7.6

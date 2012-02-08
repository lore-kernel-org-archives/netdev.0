From: greearb@candelatech.com
Subject: [PATCH v2 10/10] e1000: Support sending custom Ethernet CRC.
Date: Wed,  8 Feb 2012 11:54:45 -0800
Message-ID: <1328730885-10941-11-git-send-email-greearb@candelatech.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55726 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756957Ab2BHT4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 14:56:39 -0500
In-Reply-To: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Good for testing the RX logic for bad CRC handling.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 1f86a70... 64b73bc... M	drivers/net/ethernet/intel/e1000/e1000_main.c
 drivers/net/ethernet/intel/e1000/e1000_main.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 1f86a70..64b73bc 100644
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
1.7.3.4

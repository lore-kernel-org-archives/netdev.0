From: greearb@candelatech.com
Subject: [PATCH v2 06/10] e1000e:  Support sending custom Ethernet CRC.
Date: Wed,  8 Feb 2012 11:54:41 -0800
Message-ID: <1328730885-10941-7-git-send-email-greearb@candelatech.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55718 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757322Ab2BHT4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 14:56:06 -0500
In-Reply-To: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This can aid with testing the RX logic for bad
CRCs.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 e3eefda... 2f9434c... M	drivers/net/ethernet/intel/e1000e/netdev.c
 drivers/net/ethernet/intel/e1000e/netdev.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e3eefda..2f9434c 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4618,6 +4618,7 @@ link_up:
 #define E1000_TX_FLAGS_VLAN		0x00000002
 #define E1000_TX_FLAGS_TSO		0x00000004
 #define E1000_TX_FLAGS_IPV4		0x00000008
+#define E1000_TX_FLAGS_NO_FCS		0x00000010
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
@@ -4877,6 +4878,9 @@ static void e1000_tx_queue(struct e1000_ring *tx_ring, int tx_flags, int count)
 		txd_upper |= (tx_flags & E1000_TX_FLAGS_VLAN_MASK);
 	}
 
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS))
+		txd_lower &= ~(E1000_TXD_CMD_IFCS);
+
 	i = tx_ring->next_to_use;
 
 	do {
@@ -4894,6 +4898,10 @@ static void e1000_tx_queue(struct e1000_ring *tx_ring, int tx_flags, int count)
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
 
+	/* txd_cmd re-enables FCS, so we'll re-disable it here as desired. */
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS))
+		tx_desc->lower.data &= ~(cpu_to_le32(E1000_TXD_CMD_IFCS));
+
 	/*
 	 * Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
@@ -5099,6 +5107,9 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
+	if (unlikely(skb->no_fcs))
+		tx_flags |= E1000_TX_FLAGS_NO_FCS;
+
 	/* if count is 0 then mapping error has occurred */
 	count = e1000_tx_map(tx_ring, skb, first, max_per_txd, nr_frags, mss);
 	if (count) {
@@ -6226,6 +6237,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	/* Set user-changeable features (subset of all device features) */
 	netdev->hw_features = netdev->features;
 	netdev->hw_features |= NETIF_F_RXFCS;
+	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
 	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
 		netdev->features |= NETIF_F_HW_VLAN_FILTER;
-- 
1.7.3.4

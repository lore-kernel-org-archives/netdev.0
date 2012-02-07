From: greearb@candelatech.com
Subject: [PATCH 3/5] e1000e:  Support sending custom Ethernet CRC.
Date: Tue,  7 Feb 2012 11:49:42 -0800
Message-ID: <1328644182-7872-3-git-send-email-greearb@candelatech.com>
References: <1328644182-7872-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35674 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756574Ab2BGTuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 14:50:02 -0500
In-Reply-To: <1328644182-7872-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This can aid with testing the RX logic for bad
CRCs.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 1a8dd2f... 0c94e55... M	drivers/net/ethernet/intel/e1000e/netdev.c
 drivers/net/ethernet/intel/e1000e/netdev.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 1a8dd2f..0c94e55 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4599,6 +4599,7 @@ link_up:
 #define E1000_TX_FLAGS_VLAN		0x00000002
 #define E1000_TX_FLAGS_TSO		0x00000004
 #define E1000_TX_FLAGS_IPV4		0x00000008
+#define E1000_TX_FLAGS_NO_FCS		0x00000010
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
@@ -4858,6 +4859,9 @@ static void e1000_tx_queue(struct e1000_ring *tx_ring, int tx_flags, int count)
 		txd_upper |= (tx_flags & E1000_TX_FLAGS_VLAN_MASK);
 	}
 
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS))
+		txd_lower &= ~(E1000_TXD_CMD_IFCS);
+
 	i = tx_ring->next_to_use;
 
 	do {
@@ -4875,6 +4879,10 @@ static void e1000_tx_queue(struct e1000_ring *tx_ring, int tx_flags, int count)
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
 
+	/* txd_cmd re-enables FCS, so we'll re-disable it here as desired. */
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS))
+		tx_desc->lower.data &= ~(cpu_to_le32(E1000_TXD_CMD_IFCS));
+
 	/*
 	 * Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
@@ -5080,6 +5088,9 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
+	if (unlikely(skb->no_fcs && netdev->features & NETIF_F_NOFCS))
+		tx_flags |= E1000_TX_FLAGS_NO_FCS;
+
 	/* if count is 0 then mapping error has occurred */
 	count = e1000_tx_map(tx_ring, skb, first, max_per_txd, nr_frags, mss);
 	if (count) {
@@ -6187,6 +6198,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 			    NETIF_F_TSO6 |
 			    NETIF_F_RXHASH |
 			    NETIF_F_RXCSUM |
+			    NETIF_F_NOFCS |
 			    NETIF_F_HW_CSUM);
 
 	/* Set user-changeable features (subset of all device features) */
-- 
1.7.3.4

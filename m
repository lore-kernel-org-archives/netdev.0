From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] igb: add support for NETIF_F_RXHASH
Date: Fri,  7 Oct 2011 23:47:41 -0700
Message-ID: <1318056461-19562-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:16687 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178Ab1JHGrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Oct 2011 02:47:52 -0400
In-Reply-To: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for Rx hashing.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   52 +++++++++++++++++++---------
 1 files changed, 35 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 77ade67..10670f9 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1978,23 +1978,32 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		dev_info(&pdev->dev,
 			"PHY reset is blocked due to SOL/IDER session.\n");
 
-	netdev->hw_features = NETIF_F_SG |
-			   NETIF_F_IP_CSUM |
-			   NETIF_F_IPV6_CSUM |
-			   NETIF_F_TSO |
-			   NETIF_F_TSO6 |
-			   NETIF_F_RXCSUM |
-			   NETIF_F_HW_VLAN_RX;
-
-	netdev->features = netdev->hw_features |
-			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_FILTER;
-
-	netdev->vlan_features |= NETIF_F_TSO;
-	netdev->vlan_features |= NETIF_F_TSO6;
-	netdev->vlan_features |= NETIF_F_IP_CSUM;
-	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
-	netdev->vlan_features |= NETIF_F_SG;
+	/*
+	 * features is initialized to 0 in allocation, it might have bits
+	 * set by igb_sw_init so we should use an or instead of an
+	 * assignment.
+	 */
+	netdev->features |= NETIF_F_SG |
+			    NETIF_F_IP_CSUM |
+			    NETIF_F_IPV6_CSUM |
+			    NETIF_F_TSO |
+			    NETIF_F_TSO6 |
+			    NETIF_F_RXHASH |
+			    NETIF_F_RXCSUM |
+			    NETIF_F_HW_VLAN_RX |
+			    NETIF_F_HW_VLAN_TX;
+
+	/* copy netdev features into list of user selectable features */
+	netdev->hw_features |= netdev->features;
+
+	/* set this bit last since it cannot be part of hw_features */
+	netdev->features |= NETIF_F_HW_VLAN_FILTER;
+
+	netdev->vlan_features |= NETIF_F_TSO |
+				 NETIF_F_TSO6 |
+				 NETIF_F_IP_CSUM |
+				 NETIF_F_IPV6_CSUM |
+				 NETIF_F_SG;
 
 	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
@@ -5827,6 +5836,14 @@ static inline void igb_rx_checksum(struct igb_ring *ring,
 		le32_to_cpu(rx_desc->wb.upper.status_error));
 }
 
+static inline void igb_rx_hash(struct igb_ring *ring,
+			       union e1000_adv_rx_desc *rx_desc,
+			       struct sk_buff *skb)
+{
+	if (ring->netdev->features & NETIF_F_RXHASH)
+		skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+}
+
 static void igb_rx_hwtstamp(struct igb_q_vector *q_vector,
 			    union e1000_adv_rx_desc *rx_desc,
 			    struct sk_buff *skb)
@@ -5959,6 +5976,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 		}
 
 		igb_rx_hwtstamp(q_vector, rx_desc, skb);
+		igb_rx_hash(rx_ring, rx_desc, skb);
 		igb_rx_checksum(rx_ring, rx_desc, skb);
 
 		if (igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
-- 
1.7.6.4

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] igb: Combine post-processing of skb into a single function
Date: Fri, 19 Oct 2012 04:45:08 -0700
Message-ID: <1350647114-6768-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31782 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932189Ab2JSLpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 07:45:45 -0400
In-Reply-To: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to just clean-up a number of function calls that were
made at the end of the Rx clean-up path by combining them into a single
function call.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 69 ++++++++++++++++++++-----------
 1 file changed, 44 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 665eafa..9e38f14 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5877,22 +5877,6 @@ static inline void igb_rx_hash(struct igb_ring *ring,
 		skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
 }
 
-static void igb_rx_vlan(struct igb_ring *ring,
-			union e1000_adv_rx_desc *rx_desc,
-			struct sk_buff *skb)
-{
-	if (igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
-		u16 vid;
-		if (igb_test_staterr(rx_desc, E1000_RXDEXT_STATERR_LB) &&
-		    test_bit(IGB_RING_FLAG_RX_LB_VLAN_BSWAP, &ring->flags))
-			vid = be16_to_cpu(rx_desc->wb.upper.vlan);
-		else
-			vid = le16_to_cpu(rx_desc->wb.upper.vlan);
-
-		__vlan_hwaccel_put_tag(skb, vid);
-	}
-}
-
 /**
  * igb_get_headlen - determine size of header for LRO/GRO
  * @data: pointer to the start of the headers
@@ -6101,6 +6085,47 @@ static bool igb_cleanup_headers(struct igb_ring *rx_ring,
 	return false;
 }
 
+/**
+ * igb_process_skb_fields - Populate skb header fields from Rx descriptor
+ * @rx_ring: rx descriptor ring packet is being transacted on
+ * @rx_desc: pointer to the EOP Rx descriptor
+ * @skb: pointer to current skb being populated
+ *
+ * This function checks the ring, descriptor, and packet information in
+ * order to populate the hash, checksum, VLAN, timestamp, protocol, and
+ * other fields within the skb.
+ **/
+static void igb_process_skb_fields(struct igb_ring *rx_ring,
+				   union e1000_adv_rx_desc *rx_desc,
+				   struct sk_buff *skb)
+{
+	struct net_device *dev = rx_ring->netdev;
+
+	igb_rx_hash(rx_ring, rx_desc, skb);
+
+	igb_rx_checksum(rx_ring, rx_desc, skb);
+
+#ifdef CONFIG_IGB_PTP
+	igb_ptp_rx_hwtstamp(rx_ring->q_vector, rx_desc, skb);
+#endif /* CONFIG_IGB_PTP */
+
+	if ((dev->features & NETIF_F_HW_VLAN_RX) &&
+	    igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
+		u16 vid;
+		if (igb_test_staterr(rx_desc, E1000_RXDEXT_STATERR_LB) &&
+		    test_bit(IGB_RING_FLAG_RX_LB_VLAN_BSWAP, &rx_ring->flags))
+			vid = be16_to_cpu(rx_desc->wb.upper.vlan);
+		else
+			vid = le16_to_cpu(rx_desc->wb.upper.vlan);
+
+		__vlan_hwaccel_put_tag(skb, vid);
+	}
+
+	skb_record_rx_queue(skb, rx_ring->queue_index);
+
+	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+}
+
 static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 {
 	struct igb_ring *rx_ring = q_vector->rx.ring;
@@ -6185,18 +6210,12 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 			continue;
 		}
 
-#ifdef CONFIG_IGB_PTP
-		igb_ptp_rx_hwtstamp(q_vector, rx_desc, skb);
-#endif /* CONFIG_IGB_PTP */
-		igb_rx_hash(rx_ring, rx_desc, skb);
-		igb_rx_checksum(rx_ring, rx_desc, skb);
-		igb_rx_vlan(rx_ring, rx_desc, skb);
-
+		/* probably a little skewed due to removing CRC */
 		total_bytes += skb->len;
 		total_packets++;
 
-		skb_record_rx_queue(skb, rx_ring->queue_index);
-		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+		/* populate checksum, timestamp, VLAN, and protocol */
+		igb_process_skb_fields(rx_ring, rx_desc, skb);
 
 		napi_gro_receive(&q_vector->napi, skb);
 
-- 
1.7.11.7

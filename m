From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/15] ixgbevf: Combine the logic for post Rx processing into single function
Date: Thu, 20 Nov 2014 15:09:01 -0800
Message-ID: <1416524953-15161-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55349 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757108AbaKTXJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 18:09:20 -0500
In-Reply-To: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch cleans up ixgbevf_clean_rx_irq() by merging several similar
operations into a new function - ixgbevf_process_skb_fields().

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 68 ++++++++++++-----------
 2 files changed, 38 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 5f7d2f3..90d5751 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -346,8 +346,10 @@ static inline void ixgbevf_write_tail(struct ixgbevf_ring *ring, u32 value)
 
 /* board specific private data structure */
 struct ixgbevf_adapter {
-	struct timer_list watchdog_timer;
+	/* this field must be first, see ixgbevf_process_skb_fields */
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+
+	struct timer_list watchdog_timer;
 	struct work_struct reset_task;
 	struct ixgbevf_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 19062dc..36b005e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -328,37 +328,12 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 }
 
 /**
- * ixgbevf_receive_skb - Send a completed packet up the stack
- * @q_vector: structure containing interrupt and ring information
- * @skb: packet to send up
- * @rx_desc: rx descriptor
- **/
-static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
-				struct sk_buff *skb,
-				union ixgbe_adv_rx_desc *rx_desc)
-{
-	struct ixgbevf_adapter *adapter = q_vector->adapter;
-	bool is_vlan = !!ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_VP);
-	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
-
-	if (is_vlan && test_bit(tag & VLAN_VID_MASK, adapter->active_vlans))
-		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), tag);
-
-	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-		napi_gro_receive(&q_vector->napi, skb);
-	else
-		netif_rx(skb);
-}
-
-/**
  * ixgbevf_rx_skb - Helper function to determine proper Rx method
  * @q_vector: structure containing interrupt and ring information
  * @skb: packet to send up
- * @rx_desc: rx descriptor
  **/
 static void ixgbevf_rx_skb(struct ixgbevf_q_vector *q_vector,
-			   struct sk_buff *skb,
-			   union ixgbe_adv_rx_desc *rx_desc)
+			   struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	skb_mark_napi_id(skb, &q_vector->napi);
@@ -369,8 +344,10 @@ static void ixgbevf_rx_skb(struct ixgbevf_q_vector *q_vector,
 		return;
 	}
 #endif /* CONFIG_NET_RX_BUSY_POLL */
-
-	ixgbevf_receive_skb(q_vector, skb, rx_desc);
+	if (!(q_vector->adapter->flags & IXGBE_FLAG_IN_NETPOLL))
+		napi_gro_receive(&q_vector->napi, skb);
+	else
+		netif_rx(skb);
 }
 
 /* ixgbevf_rx_checksum - indicate in skb if hw indicated a good cksum
@@ -407,6 +384,32 @@ static inline void ixgbevf_rx_checksum(struct ixgbevf_ring *ring,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
 
+/* ixgbevf_process_skb_fields - Populate skb header fields from Rx descriptor
+ * @rx_ring: rx descriptor ring packet is being transacted on
+ * @rx_desc: pointer to the EOP Rx descriptor
+ * @skb: pointer to current skb being populated
+ *
+ * This function checks the ring, descriptor, and packet information in
+ * order to populate the checksum, VLAN, protocol, and other fields within
+ * the skb.
+ */
+static void ixgbevf_process_skb_fields(struct ixgbevf_ring *rx_ring,
+				       union ixgbe_adv_rx_desc *rx_desc,
+				       struct sk_buff *skb)
+{
+	ixgbevf_rx_checksum(rx_ring, rx_desc, skb);
+
+	if (ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {
+		u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);
+		unsigned long *active_vlans = netdev_priv(rx_ring->netdev);
+
+		if (test_bit(vid & VLAN_VID_MASK, active_vlans))
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
+	}
+
+	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+}
+
 static bool ixgbevf_alloc_mapped_skb(struct ixgbevf_ring *rx_ring,
 				     struct ixgbevf_rx_buffer *bi)
 {
@@ -576,14 +579,10 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			goto next_desc;
 		}
 
-		ixgbevf_rx_checksum(rx_ring, rx_desc, skb);
-
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
 
-		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
-
 		/* Workaround hardware that can't do proper VEPA multicast
 		 * source pruning.
 		 */
@@ -595,7 +594,10 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			goto next_desc;
 		}
 
-		ixgbevf_rx_skb(q_vector, skb, rx_desc);
+		/* populate checksum, VLAN, and protocol */
+		ixgbevf_process_skb_fields(rx_ring, rx_desc, skb);
+
+		ixgbevf_rx_skb(q_vector, skb);
 
 next_desc:
 		/* return some buffers to hardware, one at a time is too slow */
-- 
1.9.3

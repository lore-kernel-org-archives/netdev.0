From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbevf: Add checksum statistics counters to rings
Date: Thu, 15 Nov 2012 06:39:47 -0800
Message-ID: <1352990387-3872-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:65384 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768076Ab2KOOj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 09:39:57 -0500
In-Reply-To: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add hardware checksum statistic counters to the ring structures and
then during packet processing update those counters instead of the
global counters in the adapter structure.  Only update the adapter
structure counters when all other statistics are gathered in the
ixgbevf_update_stats() function.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  2 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 23 ++++++++++++++++-------
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index dbdf39b..fc0af9a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -74,6 +74,8 @@ struct ixgbevf_ring {
 	u64			total_bytes;
 	u64			total_packets;
 	struct u64_stats_sync	syncp;
+	u64 hw_csum_rx_error;
+	u64 hw_csum_rx_good;
 
 	u16 head;
 	u16 tail;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a52b14e..f267c00 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -295,12 +295,11 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 
 /**
  * ixgbevf_rx_checksum - indicate in skb if hw indicated a good cksum
- * @adapter: address of board private structure
+ * @ring: pointer to Rx descriptor ring structure
  * @status_err: hardware indication of status of receive
  * @skb: skb currently being received and modified
  **/
-static inline void ixgbevf_rx_checksum(struct ixgbevf_adapter *adapter,
-				       struct ixgbevf_ring *ring,
+static inline void ixgbevf_rx_checksum(struct ixgbevf_ring *ring,
 				       u32 status_err, struct sk_buff *skb)
 {
 	skb_checksum_none_assert(skb);
@@ -312,7 +311,7 @@ static inline void ixgbevf_rx_checksum(struct ixgbevf_adapter *adapter,
 	/* if IP and error */
 	if ((status_err & IXGBE_RXD_STAT_IPCS) &&
 	    (status_err & IXGBE_RXDADV_ERR_IPE)) {
-		adapter->hw_csum_rx_error++;
+		ring->hw_csum_rx_error++;
 		return;
 	}
 
@@ -320,13 +319,13 @@ static inline void ixgbevf_rx_checksum(struct ixgbevf_adapter *adapter,
 		return;
 
 	if (status_err & IXGBE_RXDADV_ERR_TCPE) {
-		adapter->hw_csum_rx_error++;
+		ring->hw_csum_rx_error++;
 		return;
 	}
 
 	/* It must be a TCP or UDP packet with a valid checksum */
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
-	adapter->hw_csum_rx_good++;
+	ring->hw_csum_rx_good++;
 }
 
 /**
@@ -462,7 +461,7 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			goto next_desc;
 		}
 
-		ixgbevf_rx_checksum(adapter, rx_ring, staterr, skb);
+		ixgbevf_rx_checksum(rx_ring, staterr, skb);
 
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
@@ -2094,6 +2093,7 @@ out:
 void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
 
 	UPDATE_VF_COUNTER_32bit(IXGBE_VFGPRC, adapter->stats.last_vfgprc,
 				adapter->stats.vfgprc);
@@ -2107,6 +2107,15 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 				adapter->stats.vfgotc);
 	UPDATE_VF_COUNTER_32bit(IXGBE_VFMPRC, adapter->stats.last_vfmprc,
 				adapter->stats.vfmprc);
+
+	for (i = 0;  i  < adapter->num_rx_queues;  i++) {
+		adapter->hw_csum_rx_error +=
+			adapter->rx_ring[i].hw_csum_rx_error;
+		adapter->hw_csum_rx_good +=
+			adapter->rx_ring[i].hw_csum_rx_good;
+		adapter->rx_ring[i].hw_csum_rx_error = 0;
+		adapter->rx_ring[i].hw_csum_rx_good = 0;
+	}
 }
 
 /**
-- 
1.7.11.7

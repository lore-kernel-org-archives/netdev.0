From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/12] igb: Add workaround for byte swapped VLAN on i350 local traffic
Date: Tue, 11 Oct 2011 20:38:24 -0700
Message-ID: <1318390708-12232-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34679 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751256Ab1JLDio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 23:38:44 -0400
In-Reply-To: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

On i350 when traffic is looped back from a VF to the PF the value is byte
swapped from the normal format.  In order to address this we need to add a
flag indicating that the ring will need to byte swap the loopback packets
prior to processing them.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_defines.h |    1 +
 drivers/net/ethernet/intel/igb/igb.h           |    1 +
 drivers/net/ethernet/intel/igb/igb_main.c      |   29 +++++++++++++++++++-----
 3 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 68558be..f5fc572 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -85,6 +85,7 @@
 #define E1000_RXD_STAT_TCPCS    0x20    /* TCP xsum calculated */
 #define E1000_RXD_STAT_TS       0x10000 /* Pkt was time stamped */
 
+#define E1000_RXDEXT_STATERR_LB    0x00040000
 #define E1000_RXDEXT_STATERR_CE    0x01000000
 #define E1000_RXDEXT_STATERR_SE    0x02000000
 #define E1000_RXDEXT_STATERR_SEQ   0x04000000
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 5def94c..e6e770d 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -243,6 +243,7 @@ struct igb_ring {
 
 enum e1000_ring_flags_t {
 	IGB_RING_FLAG_RX_SCTP_CSUM,
+	IGB_RING_FLAG_RX_LB_VLAN_BSWAP,
 	IGB_RING_FLAG_TX_CTX_IDX,
 	IGB_RING_FLAG_TX_DETECT_HANG
 };
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 43caf84..7c6e526 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -712,6 +712,11 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		/* set flag indicating ring supports SCTP checksum offload */
 		if (adapter->hw.mac.type >= e1000_82576)
 			set_bit(IGB_RING_FLAG_RX_SCTP_CSUM, &ring->flags);
+
+		/* On i350, loopback VLAN packets have the tag byte-swapped. */
+		if (adapter->hw.mac.type == e1000_i350)
+			set_bit(IGB_RING_FLAG_RX_LB_VLAN_BSWAP, &ring->flags);
+
 		adapter->rx_ring[i] = ring;
 	}
 
@@ -5794,6 +5799,23 @@ static void igb_rx_hwtstamp(struct igb_q_vector *q_vector,
 
 	igb_systim_to_hwtstamp(adapter, skb_hwtstamps(skb), regval);
 }
+
+static void igb_rx_vlan(struct igb_ring *ring,
+			union e1000_adv_rx_desc *rx_desc,
+			struct sk_buff *skb)
+{
+	if (igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
+		u16 vid;
+		if (igb_test_staterr(rx_desc, E1000_RXDEXT_STATERR_LB) &&
+		    test_bit(IGB_RING_FLAG_RX_LB_VLAN_BSWAP, &ring->flags))
+			vid = be16_to_cpu(rx_desc->wb.upper.vlan);
+		else
+			vid = le16_to_cpu(rx_desc->wb.upper.vlan);
+
+		__vlan_hwaccel_put_tag(skb, vid);
+	}
+}
+
 static inline u16 igb_get_hlen(union e1000_adv_rx_desc *rx_desc)
 {
 	/* HW will not DMA in data larger than the given buffer, even if it
@@ -5890,12 +5912,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 		igb_rx_hwtstamp(q_vector, rx_desc, skb);
 		igb_rx_hash(rx_ring, rx_desc, skb);
 		igb_rx_checksum(rx_ring, rx_desc, skb);
-
-		if (igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
-			u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);
-
-			__vlan_hwaccel_put_tag(skb, vid);
-		}
+		igb_rx_vlan(rx_ring, rx_desc, skb);
 
 		total_bytes += skb->len;
 		total_packets++;
-- 
1.7.6.4

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/12] ixgbe: Write gso_segs and bytcount to the ring sooner
Date: Sat, 17 Mar 2012 01:50:59 -0700
Message-ID: <1331974260-6383-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56951 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756177Ab2CQIvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 04:51:35 -0400
In-Reply-To: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that gso_segs and bytecount are written to the ring
sooner.  This helps to simplify the logic for the two since segmentation
offloads can now update them within their own function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |   11 +++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   35 +++++++++---------------
 2 files changed, 21 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 910847a..5f943d3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -532,9 +532,14 @@ int ixgbe_fso(struct ixgbe_ring *tx_ring,
 	*hdr_len = sizeof(struct fcoe_crc_eof);
 
 	/* hdr_len includes fc_hdr if FCoE LSO is enabled */
-	if (skb_is_gso(skb))
-		*hdr_len += (skb_transport_offset(skb) +
-			     sizeof(struct fc_frame_header));
+	if (skb_is_gso(skb)) {
+		*hdr_len += skb_transport_offset(skb) +
+			    sizeof(struct fc_frame_header);
+		/* update gso_segs and bytecount */
+		first->gso_segs = DIV_ROUND_UP(skb->len - *hdr_len,
+					       skb_shinfo(skb)->gso_size);
+		first->bytecount += (first->gso_segs - 1) * *hdr_len;
+	}
 
 	/* mss_l4len_id: use 1 for FSO as TSO, no need for L4LEN */
 	mss_l4len_idx = skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c05d560..40d729e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -763,6 +763,10 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		/* clear next_to_watch to prevent false hangs */
 		tx_buffer->next_to_watch = NULL;
 
+		/* update the statistics for this packet */
+		total_bytes += tx_buffer->bytecount;
+		total_packets += tx_buffer->gso_segs;
+
 		/* free the skb */
 		dev_kfree_skb_any(tx_buffer->skb);
 
@@ -771,13 +775,9 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 
 		do {
 			ixgbe_unmap_tx_resource(tx_ring, tx_buffer);
-			if (likely(tx_desc == eop_desc)) {
+			if (likely(tx_desc == eop_desc))
 				eop_desc = NULL;
 
-				total_bytes += tx_buffer->bytecount;
-				total_packets += tx_buffer->gso_segs;
-			}
-
 			tx_buffer++;
 			tx_desc++;
 			i++;
@@ -6593,9 +6593,14 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 				     0, IPPROTO_TCP, 0);
 	}
 
+	/* compute header lengths */
 	l4len = tcp_hdrlen(skb);
 	*hdr_len = skb_transport_offset(skb) + l4len;
 
+	/* update gso size and bytecount with header size */
+	first->gso_segs = skb_shinfo(skb)->gso_segs;
+	first->bytecount += (first->gso_segs - 1) * *hdr_len;
+
 	/* mss_l4len_id: use 1 as index for TSO */
 	mss_l4len_idx = l4len << IXGBE_ADVTXD_L4LEN_SHIFT;
 	mss_l4len_idx |= skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT;
@@ -6757,7 +6762,6 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	u32 offset = 0;
 	u32 paylen = skb->len - hdr_len;
 	u16 i = tx_ring->next_to_use;
-	u16 gso_segs;
 
 #ifdef IXGBE_FCOE
 	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
@@ -6843,22 +6847,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 
 	tx_ring->next_to_use = i;
 
-	if (tx_flags & IXGBE_TX_FLAGS_TSO)
-		gso_segs = skb_shinfo(skb)->gso_segs;
-#ifdef IXGBE_FCOE
-	/* adjust for FCoE Sequence Offload */
-	else if (tx_flags & IXGBE_TX_FLAGS_FSO)
-		gso_segs = DIV_ROUND_UP(skb->len - hdr_len,
-					skb_shinfo(skb)->gso_size);
-#endif /* IXGBE_FCOE */
-	else
-		gso_segs = 1;
-
-	/* multiply data chunks by size of headers */
-	tx_buffer_info->bytecount = paylen + (gso_segs * hdr_len);
-	tx_buffer_info->gso_segs = gso_segs;
-
-	netdev_tx_sent_queue(txring_txq(tx_ring), tx_buffer_info->bytecount);
+	netdev_tx_sent_queue(txring_txq(tx_ring), first->bytecount);
 
 	/* set the timestamp */
 	first->time_stamp = jiffies;
@@ -7071,6 +7060,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	/* record the location of the first descriptor for this packet */
 	first = &tx_ring->tx_buffer_info[tx_ring->next_to_use];
 	first->skb = skb;
+	first->bytecount = skb->len;
+	first->gso_segs = 1;
 
 	/* if we have a HW VLAN tag being added default to the HW one */
 	if (vlan_tx_tag_present(skb)) {
-- 
1.7.7.6

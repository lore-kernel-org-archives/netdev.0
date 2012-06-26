From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbe: Do not pad FCoE frames as this can cause issues with FCoE DDP
Date: Tue, 26 Jun 2012 00:54:46 -0700
Message-ID: <1340697286-3047-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	<stable@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11146 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758452Ab2FZHyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 03:54:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

FCoE target mode was experiencing issues due to the fact that we were
sending up data frames that were padded to 60 bytes after the DDP logic had
already stripped the frame down to 52 or 56 depending on the use of VLANs.
This was resulting in the FCoE DDP logic having issues since it thought the
frame still had data in it due to the padding.

To resolve this, adding code so that we do not pad FCoE frames prior to
handling them to the stack.

CC: <stable@vger.kernel.org>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   14 ++++++++++----
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 3ef3c52..7af291e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -196,7 +196,7 @@ enum ixgbe_ring_state_t {
 	__IXGBE_HANG_CHECK_ARMED,
 	__IXGBE_RX_RSC_ENABLED,
 	__IXGBE_RX_CSUM_UDP_ZERO_ERR,
-	__IXGBE_RX_FCOE_BUFSZ,
+	__IXGBE_RX_FCOE,
 };
 
 #define check_for_tx_hang(ring) \
@@ -290,7 +290,7 @@ struct ixgbe_ring_feature {
 #if defined(IXGBE_FCOE) && (PAGE_SIZE < 8192)
 static inline unsigned int ixgbe_rx_pg_order(struct ixgbe_ring *ring)
 {
-	return test_bit(__IXGBE_RX_FCOE_BUFSZ, &ring->state) ? 1 : 0;
+	return test_bit(__IXGBE_RX_FCOE, &ring->state) ? 1 : 0;
 }
 #else
 #define ixgbe_rx_pg_order(_ring) 0
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index af1a531..c377706 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -634,7 +634,7 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 			f = &adapter->ring_feature[RING_F_FCOE];
 			if ((rxr_idx >= f->mask) &&
 			    (rxr_idx < f->mask + f->indices))
-				set_bit(__IXGBE_RX_FCOE_BUFSZ, &ring->state);
+				set_bit(__IXGBE_RX_FCOE, &ring->state);
 		}
 
 #endif /* IXGBE_FCOE */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cbb05d6..18ca3bc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1058,17 +1058,17 @@ static inline void ixgbe_rx_hash(struct ixgbe_ring *ring,
 #ifdef IXGBE_FCOE
 /**
  * ixgbe_rx_is_fcoe - check the rx desc for incoming pkt type
- * @adapter: address of board private structure
+ * @ring: structure containing ring specific data
  * @rx_desc: advanced rx descriptor
  *
  * Returns : true if it is FCoE pkt
  */
-static inline bool ixgbe_rx_is_fcoe(struct ixgbe_adapter *adapter,
+static inline bool ixgbe_rx_is_fcoe(struct ixgbe_ring *ring,
 				    union ixgbe_adv_rx_desc *rx_desc)
 {
 	__le16 pkt_info = rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
 
-	return (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
+	return test_bit(__IXGBE_RX_FCOE, &ring->state) &&
 	       ((pkt_info & cpu_to_le16(IXGBE_RXDADV_PKTTYPE_ETQF_MASK)) ==
 		(cpu_to_le16(IXGBE_ETQF_FILTER_FCOE <<
 			     IXGBE_RXDADV_PKTTYPE_ETQF_SHIFT)));
@@ -1549,6 +1549,12 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
 		skb->truesize -= ixgbe_rx_bufsz(rx_ring);
 	}
 
+#ifdef IXGBE_FCOE
+	/* do not attempt to pad FCoE Frames as this will disrupt DDP */
+	if (ixgbe_rx_is_fcoe(rx_ring, rx_desc))
+		return false;
+
+#endif
 	/* if skb_pad returns an error the skb was freed */
 	if (unlikely(skb->len < 60)) {
 		int pad_len = 60 - skb->len;
@@ -1775,7 +1781,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 #ifdef IXGBE_FCOE
 		/* if ddp, not passing to ULD unless for FCP_RSP or error */
-		if (ixgbe_rx_is_fcoe(adapter, rx_desc)) {
+		if (ixgbe_rx_is_fcoe(rx_ring, rx_desc)) {
 			ddp_bytes = ixgbe_fcoe_ddp(adapter, rx_desc, skb);
 			if (!ddp_bytes) {
 				dev_kfree_skb_any(skb);
-- 
1.7.10.2

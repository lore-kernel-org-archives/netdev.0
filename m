From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net-next 8/9] ixgbe: Roll RSC code into non-EOP code
Date: Thu, 16 Aug 2012 15:48:37 -0700
Message-ID: <1345157318-23731-9-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35330 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755488Ab2HPWsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 18:48:52 -0400
In-Reply-To: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves the RSC code into the non-EOP descriptor handling
function. The main motivation behind this change is to help reduce the
overhead in the non-RSC case. Previously the non-RSC path code would
always be checking for append count even if RSC had been disabled. Now
this code is completely skipped in a single conditional check instead of
having to make two separate checks.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 51 ++++++++++-----------------
 1 file changed, 19 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9e72ae6..aa37b84 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1320,29 +1320,6 @@ static unsigned int ixgbe_get_headlen(unsigned char *data,
 		return max_len;
 }
 
-static void ixgbe_get_rsc_cnt(struct ixgbe_ring *rx_ring,
-			      union ixgbe_adv_rx_desc *rx_desc,
-			      struct sk_buff *skb)
-{
-	__le32 rsc_enabled;
-	u32 rsc_cnt;
-
-	if (!ring_is_rsc_enabled(rx_ring))
-		return;
-
-	rsc_enabled = rx_desc->wb.lower.lo_dword.data &
-		      cpu_to_le32(IXGBE_RXDADV_RSCCNT_MASK);
-
-	/* If this is an RSC frame rsc_cnt should be non-zero */
-	if (!rsc_enabled)
-		return;
-
-	rsc_cnt = le32_to_cpu(rsc_enabled);
-	rsc_cnt >>= IXGBE_RXDADV_RSCCNT_SHIFT;
-
-	IXGBE_CB(skb)->append_cnt += rsc_cnt - 1;
-}
-
 static void ixgbe_set_rsc_gso_size(struct ixgbe_ring *ring,
 				   struct sk_buff *skb)
 {
@@ -1440,16 +1417,28 @@ static bool ixgbe_is_non_eop(struct ixgbe_ring *rx_ring,
 
 	prefetch(IXGBE_RX_DESC(rx_ring, ntc));
 
-	if (likely(ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP)))
-		return false;
+	/* update RSC append count if present */
+	if (ring_is_rsc_enabled(rx_ring)) {
+		__le32 rsc_enabled = rx_desc->wb.lower.lo_dword.data &
+				     cpu_to_le32(IXGBE_RXDADV_RSCCNT_MASK);
+
+		if (unlikely(rsc_enabled)) {
+			u32 rsc_cnt = le32_to_cpu(rsc_enabled);
+
+			rsc_cnt >>= IXGBE_RXDADV_RSCCNT_SHIFT;
+			IXGBE_CB(skb)->append_cnt += rsc_cnt - 1;
 
-	/* append_cnt indicates packet is RSC, if so fetch nextp */
-	if (IXGBE_CB(skb)->append_cnt) {
-		ntc = le32_to_cpu(rx_desc->wb.upper.status_error);
-		ntc &= IXGBE_RXDADV_NEXTP_MASK;
-		ntc >>= IXGBE_RXDADV_NEXTP_SHIFT;
+			/* update ntc based on RSC value */
+			ntc = le32_to_cpu(rx_desc->wb.upper.status_error);
+			ntc &= IXGBE_RXDADV_NEXTP_MASK;
+			ntc >>= IXGBE_RXDADV_NEXTP_SHIFT;
+		}
 	}
 
+	/* if we are the last buffer then there is nothing else to do */
+	if (likely(ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP)))
+		return false;
+
 	/* place skb in next buffer to be received */
 	rx_ring->rx_buffer_info[ntc].skb = skb;
 	rx_ring->rx_stats.non_eop_descs++;
@@ -1829,8 +1818,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		if (!skb)
 			break;
 
-		ixgbe_get_rsc_cnt(rx_ring, rx_desc, skb);
-
 		cleaned_count++;
 
 		/* place incomplete frames back on ring for completion */
-- 
1.7.11.2

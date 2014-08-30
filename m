From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/7] e1000: move e1000_tbi_adjust_stats to where its used
Date: Sat, 30 Aug 2014 20:28:21 +0200
Message-ID: <1409423307-23470-2-git-send-email-fw@strlen.de>
References: <1409423307-23470-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43550 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751705AbaH3S2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2014 14:28:55 -0400
In-Reply-To: <1409423307-23470-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... and make it static.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c   | 78 ---------------------------
 drivers/net/ethernet/intel/e1000/e1000_hw.h   |  2 -
 drivers/net/ethernet/intel/e1000/e1000_main.c | 77 ++++++++++++++++++++++++++
 3 files changed, 77 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index 1acf503..45c8c864 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -4837,84 +4837,6 @@ void e1000_update_adaptive(struct e1000_hw *hw)
 }
 
 /**
- * e1000_tbi_adjust_stats
- * @hw: Struct containing variables accessed by shared code
- * @frame_len: The length of the frame in question
- * @mac_addr: The Ethernet destination address of the frame in question
- *
- * Adjusts the statistic counters when a frame is accepted by TBI_ACCEPT
- */
-void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats,
-			    u32 frame_len, u8 *mac_addr)
-{
-	u64 carry_bit;
-
-	/* First adjust the frame length. */
-	frame_len--;
-	/* We need to adjust the statistics counters, since the hardware
-	 * counters overcount this packet as a CRC error and undercount
-	 * the packet as a good packet
-	 */
-	/* This packet should not be counted as a CRC error. */
-	stats->crcerrs--;
-	/* This packet does count as a Good Packet Received. */
-	stats->gprc++;
-
-	/* Adjust the Good Octets received counters */
-	carry_bit = 0x80000000 & stats->gorcl;
-	stats->gorcl += frame_len;
-	/* If the high bit of Gorcl (the low 32 bits of the Good Octets
-	 * Received Count) was one before the addition,
-	 * AND it is zero after, then we lost the carry out,
-	 * need to add one to Gorch (Good Octets Received Count High).
-	 * This could be simplified if all environments supported
-	 * 64-bit integers.
-	 */
-	if (carry_bit && ((stats->gorcl & 0x80000000) == 0))
-		stats->gorch++;
-	/* Is this a broadcast or multicast?  Check broadcast first,
-	 * since the test for a multicast frame will test positive on
-	 * a broadcast frame.
-	 */
-	if (is_broadcast_ether_addr(mac_addr))
-		/* Broadcast packet */
-		stats->bprc++;
-	else if (is_multicast_ether_addr(mac_addr))
-		/* Multicast packet */
-		stats->mprc++;
-
-	if (frame_len == hw->max_frame_size) {
-		/* In this case, the hardware has overcounted the number of
-		 * oversize frames.
-		 */
-		if (stats->roc > 0)
-			stats->roc--;
-	}
-
-	/* Adjust the bin counters when the extra byte put the frame in the
-	 * wrong bin. Remember that the frame_len was adjusted above.
-	 */
-	if (frame_len == 64) {
-		stats->prc64++;
-		stats->prc127--;
-	} else if (frame_len == 127) {
-		stats->prc127++;
-		stats->prc255--;
-	} else if (frame_len == 255) {
-		stats->prc255++;
-		stats->prc511--;
-	} else if (frame_len == 511) {
-		stats->prc511++;
-		stats->prc1023--;
-	} else if (frame_len == 1023) {
-		stats->prc1023++;
-		stats->prc1522--;
-	} else if (frame_len == 1522) {
-		stats->prc1522++;
-	}
-}
-
-/**
  * e1000_get_bus_info
  * @hw: Struct containing variables accessed by shared code
  *
diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.h b/drivers/net/ethernet/intel/e1000/e1000_hw.h
index 11578c8..5cf7268 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.h
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.h
@@ -393,8 +393,6 @@ s32 e1000_blink_led_start(struct e1000_hw *hw);
 /* Everything else */
 void e1000_reset_adaptive(struct e1000_hw *hw);
 void e1000_update_adaptive(struct e1000_hw *hw);
-void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats,
-			    u32 frame_len, u8 * mac_addr);
 void e1000_get_bus_info(struct e1000_hw *hw);
 void e1000_pci_set_mwi(struct e1000_hw *hw);
 void e1000_pci_clear_mwi(struct e1000_hw *hw);
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index cbc330b..fe56fac 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3978,6 +3978,83 @@ static void e1000_receive_skb(struct e1000_adapter *adapter, u8 status,
 }
 
 /**
+ * e1000_tbi_adjust_stats
+ * @hw: Struct containing variables accessed by shared code
+ * @frame_len: The length of the frame in question
+ * @mac_addr: The Ethernet destination address of the frame in question
+ *
+ * Adjusts the statistic counters when a frame is accepted by TBI_ACCEPT
+ */
+static void e1000_tbi_adjust_stats(struct e1000_hw *hw,
+				   struct e1000_hw_stats *stats,
+				   u32 frame_len, const u8 *mac_addr)
+{
+	u64 carry_bit;
+
+	/* First adjust the frame length. */
+	frame_len--;
+	/* We need to adjust the statistics counters, since the hardware
+	 * counters overcount this packet as a CRC error and undercount
+	 * the packet as a good packet
+	 */
+	/* This packet should not be counted as a CRC error. */
+	stats->crcerrs--;
+	/* This packet does count as a Good Packet Received. */
+	stats->gprc++;
+
+	/* Adjust the Good Octets received counters */
+	carry_bit = 0x80000000 & stats->gorcl;
+	stats->gorcl += frame_len;
+	/* If the high bit of Gorcl (the low 32 bits of the Good Octets
+	 * Received Count) was one before the addition,
+	 * AND it is zero after, then we lost the carry out,
+	 * need to add one to Gorch (Good Octets Received Count High).
+	 * This could be simplified if all environments supported
+	 * 64-bit integers.
+	 */
+	if (carry_bit && ((stats->gorcl & 0x80000000) == 0))
+		stats->gorch++;
+	/* Is this a broadcast or multicast?  Check broadcast first,
+	 * since the test for a multicast frame will test positive on
+	 * a broadcast frame.
+	 */
+	if (is_broadcast_ether_addr(mac_addr))
+		stats->bprc++;
+	else if (is_multicast_ether_addr(mac_addr))
+		stats->mprc++;
+
+	if (frame_len == hw->max_frame_size) {
+		/* In this case, the hardware has overcounted the number of
+		 * oversize frames.
+		 */
+		if (stats->roc > 0)
+			stats->roc--;
+	}
+
+	/* Adjust the bin counters when the extra byte put the frame in the
+	 * wrong bin. Remember that the frame_len was adjusted above.
+	 */
+	if (frame_len == 64) {
+		stats->prc64++;
+		stats->prc127--;
+	} else if (frame_len == 127) {
+		stats->prc127++;
+		stats->prc255--;
+	} else if (frame_len == 255) {
+		stats->prc255++;
+		stats->prc511--;
+	} else if (frame_len == 511) {
+		stats->prc511++;
+		stats->prc1023--;
+	} else if (frame_len == 1023) {
+		stats->prc1023++;
+		stats->prc1522--;
+	} else if (frame_len == 1522) {
+		stats->prc1522++;
+	}
+}
+
+/**
  * e1000_clean_jumbo_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
  * @rx_ring: ring to clean
-- 
1.8.1.5

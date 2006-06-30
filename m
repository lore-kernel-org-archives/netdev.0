From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/5] tg3: Add rx BD workaround
Date: Thu, 29 Jun 2006 18:29:14 -0700
Message-ID: <1151630955.21798.18.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:62732 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751383AbWF3B2L
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 21:28:11 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add workaround to limit the burst size of rx BDs being DMA'ed to the
chip.  This works around hardware errata on a number of 5750, 5752,
and 5755 chips.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2447fa3..c32655c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3195,7 +3195,7 @@ static int tg3_vlan_rx(struct tg3 *tp, s
  */
 static int tg3_rx(struct tg3 *tp, int budget)
 {
-	u32 work_mask;
+	u32 work_mask, rx_std_posted = 0;
 	u32 sw_idx = tp->rx_rcb_ptr;
 	u16 hw_idx;
 	int received;
@@ -3222,6 +3222,7 @@ static int tg3_rx(struct tg3 *tp, int bu
 						  mapping);
 			skb = tp->rx_std_buffers[desc_idx].skb;
 			post_ptr = &tp->rx_std_ptr;
+			rx_std_posted++;
 		} else if (opaque_key == RXD_OPAQUE_RING_JUMBO) {
 			dma_addr = pci_unmap_addr(&tp->rx_jumbo_buffers[desc_idx],
 						  mapping);
@@ -3309,6 +3310,15 @@ static int tg3_rx(struct tg3 *tp, int bu
 
 next_pkt:
 		(*post_ptr)++;
+
+		if (unlikely(rx_std_posted >= tp->rx_std_max_post)) {
+			u32 idx = *post_ptr % TG3_RX_RING_SIZE;
+
+			tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX +
+				     TG3_64BIT_REG_LOW, idx);
+			work_mask &= ~RXD_OPAQUE_RING_STD;
+			rx_std_posted = 0;
+		}
 next_pkt_nopost:
 		sw_idx++;
 		sw_idx %= TG3_RX_RCB_RING_SIZE(tp);
@@ -5981,7 +5991,13 @@ static int tg3_reset_hw(struct tg3 *tp, 
 	}
 
 	/* Setup replenish threshold. */
-	tw32(RCVBDI_STD_THRESH, tp->rx_pending / 8);
+	val = tp->rx_pending / 8;
+	if (val == 0)
+		val = 1;
+	else if (val > tp->rx_std_max_post)
+		val = tp->rx_std_max_post;
+
+	tw32(RCVBDI_STD_THRESH, val);
 
 	/* Initialize TG3_BDINFO's at:
 	 *  RCVDBDI_STD_BD:	standard eth size rx ring
@@ -10545,6 +10561,16 @@ static int __devinit tg3_get_invariants(
 	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE) != 0)
 		tp->rx_offset = 0;
 
+	tp->rx_std_max_post = TG3_RX_RING_SIZE;
+
+	/* Increment the rx prod index on the rx std ring by at most
+	 * 8 for these chips to workaround hw errata.
+	 */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
+		tp->rx_std_max_post = 8;
+
 	/* By default, disable wake-on-lan.  User can change this
 	 * using ETHTOOL_SWOL.
 	 */
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 8209da5..e9177f8 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2137,6 +2137,7 @@ struct tg3 {
 	struct tg3_rx_buffer_desc	*rx_std;
 	struct ring_info		*rx_std_buffers;
 	dma_addr_t			rx_std_mapping;
+	u32				rx_std_max_post;
 
 	struct tg3_rx_buffer_desc	*rx_jumbo;
 	struct ring_info		*rx_jumbo_buffers;



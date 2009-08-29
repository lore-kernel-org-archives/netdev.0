From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 13/17] tg3: Convert napi handlers to use tnapi
Date: Fri, 28 Aug 2009 17:02:18 -0700
Message-ID: <1251585290.29699@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2837 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbZH2Wez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the napi interrupt handler functions to accept and
use tg3_napi structures.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   55 ++++++++++++++++++++++++++++++----------------------
 1 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bf9a333..27ebe3b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -643,8 +643,9 @@ static void tg3_enable_ints(struct tg3 *tp)
 	tg3_cond_int(tp);
 }
 
-static inline unsigned int tg3_has_work(struct tg3 *tp)
+static inline unsigned int tg3_has_work(struct tg3_napi *tnapi)
 {
+	struct tg3 *tp = tnapi->tp;
 	struct tg3_hw_status *sblk = tp->hw_status;
 	unsigned int work_exists = 0;
 
@@ -663,13 +664,15 @@ static inline unsigned int tg3_has_work(struct tg3 *tp)
 	return work_exists;
 }
 
-/* tg3_restart_ints
+/* tg3_int_reenable
  *  similar to tg3_enable_ints, but it accurately determines whether there
  *  is new work pending and can return without flushing the PIO write
  *  which reenables interrupts
  */
-static void tg3_restart_ints(struct tg3 *tp)
+static void tg3_int_reenable(struct tg3_napi *tnapi)
 {
+	struct tg3 *tp = tnapi->tp;
+
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 		     tp->last_tag << 24);
 	mmiowb();
@@ -679,7 +682,7 @@ static void tg3_restart_ints(struct tg3 *tp)
 	 * work we've completed.
 	 */
 	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
-	    tg3_has_work(tp))
+	    tg3_has_work(tnapi))
 		tw32(HOSTCC_MODE, tp->coalesce_mode |
 		     (HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW));
 }
@@ -4278,8 +4281,9 @@ static inline u32 tg3_tx_avail(struct tg3 *tp)
  * need special logic to handle SKBs that have not had all
  * of their frags sent yet, like SunGEM does.
  */
-static void tg3_tx(struct tg3 *tp)
+static void tg3_tx(struct tg3_napi *tnapi)
 {
+	struct tg3 *tp = tnapi->tp;
 	u32 hw_idx = tp->hw_status->idx[0].tx_consumer;
 	u32 sw_idx = tp->tx_cons;
 
@@ -4344,9 +4348,10 @@ static void tg3_tx(struct tg3 *tp)
  * buffers the cpu only reads the last cacheline of the RX descriptor
  * (to fetch the error flags, vlan tag, checksum, and opaque cookie).
  */
-static int tg3_alloc_rx_skb(struct tg3 *tp, u32 opaque_key,
+static int tg3_alloc_rx_skb(struct tg3_napi *tnapi, u32 opaque_key,
 			    int src_idx, u32 dest_idx_unmasked)
 {
+	struct tg3 *tp = tnapi->tp;
 	struct tg3_rx_buffer_desc *desc;
 	struct ring_info *map, *src_map;
 	struct sk_buff *skb;
@@ -4409,9 +4414,10 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, u32 opaque_key,
  * members of the RX descriptor are invariant.  See notes above
  * tg3_alloc_rx_skb for full details.
  */
-static void tg3_recycle_rx(struct tg3 *tp, u32 opaque_key,
+static void tg3_recycle_rx(struct tg3_napi *tnapi, u32 opaque_key,
 			   int src_idx, u32 dest_idx_unmasked)
 {
+	struct tg3 *tp = tnapi->tp;
 	struct tg3_rx_buffer_desc *src_desc, *dest_desc;
 	struct ring_info *src_map, *dest_map;
 	int dest_idx;
@@ -4471,8 +4477,9 @@ static void tg3_recycle_rx(struct tg3 *tp, u32 opaque_key,
  * If both the host and chip were to write into the same ring, cache line
  * eviction could occur since both entities want it in an exclusive state.
  */
-static int tg3_rx(struct tg3 *tp, int budget)
+static int tg3_rx(struct tg3_napi *tnapi, int budget)
 {
+	struct tg3 *tp = tnapi->tp;
 	u32 work_mask, rx_std_posted = 0;
 	u32 sw_idx = tp->rx_rcb_ptr;
 	u16 hw_idx;
@@ -4515,7 +4522,7 @@ static int tg3_rx(struct tg3 *tp, int budget)
 		if ((desc->err_vlan & RXD_ERR_MASK) != 0 &&
 		    (desc->err_vlan != RXD_ERR_ODD_NIBBLE_RCVD_MII)) {
 		drop_it:
-			tg3_recycle_rx(tp, opaque_key,
+			tg3_recycle_rx(tnapi, opaque_key,
 				       desc_idx, *post_ptr);
 		drop_it_no_recycle:
 			/* Other statistics kept track of by card. */
@@ -4535,7 +4542,7 @@ static int tg3_rx(struct tg3 *tp, int budget)
 		) {
 			int skb_size;
 
-			skb_size = tg3_alloc_rx_skb(tp, opaque_key,
+			skb_size = tg3_alloc_rx_skb(tnapi, opaque_key,
 						    desc_idx, *post_ptr);
 			if (skb_size < 0)
 				goto drop_it;
@@ -4547,7 +4554,7 @@ static int tg3_rx(struct tg3 *tp, int budget)
 		} else {
 			struct sk_buff *copy_skb;
 
-			tg3_recycle_rx(tp, opaque_key,
+			tg3_recycle_rx(tnapi, opaque_key,
 				       desc_idx, *post_ptr);
 
 			copy_skb = netdev_alloc_skb(tp->dev,
@@ -4584,11 +4591,11 @@ static int tg3_rx(struct tg3 *tp, int budget)
 #if TG3_VLAN_TAG_USED
 		if (tp->vlgrp != NULL &&
 		    desc->type_flags & RXD_FLAG_VLAN) {
-			vlan_gro_receive(&tp->napi[0].napi, tp->vlgrp,
+			vlan_gro_receive(&tnapi->napi, tp->vlgrp,
 					 desc->err_vlan & RXD_VLAN_MASK, skb);
 		} else
 #endif
-			napi_gro_receive(&tp->napi[0].napi, skb);
+			napi_gro_receive(&tnapi->napi, skb);
 
 		received++;
 		budget--;
@@ -4635,8 +4642,9 @@ next_pkt_nopost:
 	return received;
 }
 
-static int tg3_poll_work(struct tg3 *tp, int work_done, int budget)
+static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 {
+	struct tg3 *tp = tnapi->tp;
 	struct tg3_hw_status *sblk = tp->hw_status;
 
 	/* handle link change and other phy events */
@@ -4662,7 +4670,7 @@ static int tg3_poll_work(struct tg3 *tp, int work_done, int budget)
 
 	/* run TX completion thread */
 	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
-		tg3_tx(tp);
+		tg3_tx(tnapi);
 		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
 			return work_done;
 	}
@@ -4672,7 +4680,7 @@ static int tg3_poll_work(struct tg3 *tp, int work_done, int budget)
 	 * code synchronizes with tg3->napi.poll()
 	 */
 	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr)
-		work_done += tg3_rx(tp, budget - work_done);
+		work_done += tg3_rx(tnapi, budget - work_done);
 
 	return work_done;
 }
@@ -4685,7 +4693,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 	struct tg3_hw_status *sblk = tp->hw_status;
 
 	while (1) {
-		work_done = tg3_poll_work(tp, work_done, budget);
+		work_done = tg3_poll_work(tnapi, work_done, budget);
 
 		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
 			goto tx_recovery;
@@ -4694,7 +4702,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 			break;
 
 		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
-			/* tp->last_tag is used in tg3_restart_ints() below
+			/* tp->last_tag is used in tg3_int_reenable() below
 			 * to tell the hw how much work has been processed,
 			 * so we must read it before checking for more work.
 			 */
@@ -4704,9 +4712,9 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 		} else
 			sblk->status &= ~SD_STATUS_UPDATED;
 
-		if (likely(!tg3_has_work(tp))) {
+		if (likely(!tg3_has_work(tnapi))) {
 			napi_complete(napi);
-			tg3_restart_ints(tp);
+			tg3_int_reenable(tnapi);
 			break;
 		}
 	}
@@ -4829,7 +4837,7 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	if (tg3_irq_sync(tp))
 		goto out;
 	sblk->status &= ~SD_STATUS_UPDATED;
-	if (likely(tg3_has_work(tp))) {
+	if (likely(tg3_has_work(tnapi))) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 		napi_schedule(&tnapi->napi);
 	} else {
@@ -5560,6 +5568,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 				 struct tg3_rx_prodring_set *tpr)
 {
 	u32 i, rx_pkt_dma_sz;
+	struct tg3_napi *tnapi = &tp->napi[0];
 
 	/* Zero out all descriptors. */
 	memset(tpr->rx_std, 0, TG3_RX_RING_BYTES);
@@ -5586,7 +5595,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 
 	/* Now allocate fresh SKBs for each rx ring. */
 	for (i = 0; i < tp->rx_pending; i++) {
-		if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_STD, -1, i) < 0) {
+		if (tg3_alloc_rx_skb(tnapi, RXD_OPAQUE_RING_STD, -1, i) < 0) {
 			printk(KERN_WARNING PFX
 			       "%s: Using a smaller RX standard ring, "
 			       "only %d out of %d buffers were allocated "
@@ -5617,7 +5626,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 		}
 
 		for (i = 0; i < tp->rx_jumbo_pending; i++) {
-			if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_JUMBO,
+			if (tg3_alloc_rx_skb(tnapi, RXD_OPAQUE_RING_JUMBO,
 					     -1, i) < 0) {
 				printk(KERN_WARNING PFX
 				       "%s: Using a smaller RX jumbo ring, "
-- 
1.6.3.3



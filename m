From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net 2/4] qed: fix handling of concurrent ramrods.
Date: Mon, 7 Dec 2015 06:25:57 -0500
Message-ID: <1449487559-31811-3-git-send-email-manish.chopra@qlogic.com>
References: <1449487559-31811-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>, Tomer Tayar <Tomer.Tayar@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:62086 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751450AbbLGMGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 07:06:24 -0500
In-Reply-To: <1449487559-31811-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@qlogic.com>

Concurrent non-blocking slowpath ramrods can be completed
out-of-order on the completion chain. Recycling completed elements,
while previously sent elements are still completion pending,
can lead to overriding of active elements on the chain. Furthermore,
sending pending slowpath ramrods currently lacks the update of the
chain element physical pointer.

This patch:
* Ensures that ramrods are sent to the FW with
  consecutive echo values.
* Handles out-of-order completions by freeing only first
  successive completed entries.
* Updates the chain element physical pointer when copying
  a pending element into a free element for sending.

Signed-off-by: Tomer Tayar <Tomer.Tayar@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sp.h  |    8 +++-
 drivers/net/ethernet/qlogic/qed/qed_spq.c |   63 ++++++++++++++++++++++-------
 include/linux/qed/common_hsi.h            |    2 +
 3 files changed, 56 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index 31a1f1e..287fadf 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -124,8 +124,12 @@ struct qed_spq {
 	dma_addr_t		p_phys;
 	struct qed_spq_entry	*p_virt;
 
-	/* Used as index for completions (returns on EQ by FW) */
-	u16			echo_idx;
+#define SPQ_RING_SIZE \
+	(CORE_SPQE_PAGE_SIZE_BYTES / sizeof(struct slow_path_element))
+
+	/* Bitmap for handling out-of-order completions */
+	DECLARE_BITMAP(p_comp_bitmap, SPQ_RING_SIZE);
+	u8			comp_bitmap_idx;
 
 	/* Statistics */
 	u32			unlimited_pending_count;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 7c0b845..3dd548a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -112,8 +112,6 @@ static int
 qed_spq_fill_entry(struct qed_hwfn *p_hwfn,
 		   struct qed_spq_entry *p_ent)
 {
-	p_ent->elem.hdr.echo = 0;
-	p_hwfn->p_spq->echo_idx++;
 	p_ent->flags = 0;
 
 	switch (p_ent->comp_mode) {
@@ -195,10 +193,12 @@ static int qed_spq_hw_post(struct qed_hwfn *p_hwfn,
 			   struct qed_spq *p_spq,
 			   struct qed_spq_entry *p_ent)
 {
-	struct qed_chain		*p_chain = &p_hwfn->p_spq->chain;
+	struct qed_chain *p_chain = &p_hwfn->p_spq->chain;
+	u16 echo = qed_chain_get_prod_idx(p_chain);
 	struct slow_path_element	*elem;
 	struct core_db_data		db;
 
+	p_ent->elem.hdr.echo	= cpu_to_le16(echo);
 	elem = qed_chain_produce(p_chain);
 	if (!elem) {
 		DP_NOTICE(p_hwfn, "Failed to produce from SPQ chain\n");
@@ -437,7 +437,9 @@ void qed_spq_setup(struct qed_hwfn *p_hwfn)
 	p_spq->comp_count		= 0;
 	p_spq->comp_sent_count		= 0;
 	p_spq->unlimited_pending_count	= 0;
-	p_spq->echo_idx			= 0;
+
+	bitmap_zero(p_spq->p_comp_bitmap, SPQ_RING_SIZE);
+	p_spq->comp_bitmap_idx = 0;
 
 	/* SPQ cid, cannot fail */
 	qed_cxt_acquire_cid(p_hwfn, PROTOCOLID_CORE, &p_spq->cid);
@@ -582,26 +584,32 @@ qed_spq_add_entry(struct qed_hwfn *p_hwfn,
 	struct qed_spq *p_spq = p_hwfn->p_spq;
 
 	if (p_ent->queue == &p_spq->unlimited_pending) {
-		struct qed_spq_entry *p_en2;
 
 		if (list_empty(&p_spq->free_pool)) {
 			list_add_tail(&p_ent->list, &p_spq->unlimited_pending);
 			p_spq->unlimited_pending_count++;
 
 			return 0;
-		}
+		} else {
+			struct qed_spq_entry *p_en2;
 
-		p_en2 = list_first_entry(&p_spq->free_pool,
-					 struct qed_spq_entry,
-					 list);
-		list_del(&p_en2->list);
+			p_en2 = list_first_entry(&p_spq->free_pool,
+						 struct qed_spq_entry,
+						 list);
+			list_del(&p_en2->list);
+
+			/* Copy the ring element physical pointer to the new
+			 * entry, since we are about to override the entire ring
+			 * entry and don't want to lose the pointer.
+			 */
+			p_ent->elem.data_ptr = p_en2->elem.data_ptr;
 
-		/* Strcut assignment */
-		*p_en2 = *p_ent;
+			*p_en2 = *p_ent;
 
-		kfree(p_ent);
+			kfree(p_ent);
 
-		p_ent = p_en2;
+			p_ent = p_en2;
+		}
 	}
 
 	/* entry is to be placed in 'pending' queue */
@@ -777,13 +785,38 @@ int qed_spq_completion(struct qed_hwfn *p_hwfn,
 	list_for_each_entry_safe(p_ent, tmp, &p_spq->completion_pending,
 				 list) {
 		if (p_ent->elem.hdr.echo == echo) {
+			u16 pos = le16_to_cpu(echo) % SPQ_RING_SIZE;
+
 			list_del(&p_ent->list);
 
-			qed_chain_return_produced(&p_spq->chain);
+			/* Avoid overriding of SPQ entries when getting
+			 * out-of-order completions, by marking the completions
+			 * in a bitmap and increasing the chain consumer only
+			 * for the first successive completed entries.
+			 */
+			bitmap_set(p_spq->p_comp_bitmap, pos, SPQ_RING_SIZE);
+
+			while (test_bit(p_spq->comp_bitmap_idx,
+					p_spq->p_comp_bitmap)) {
+				bitmap_clear(p_spq->p_comp_bitmap,
+					     p_spq->comp_bitmap_idx,
+					     SPQ_RING_SIZE);
+				p_spq->comp_bitmap_idx++;
+				qed_chain_return_produced(&p_spq->chain);
+			}
+
 			p_spq->comp_count++;
 			found = p_ent;
 			break;
 		}
+
+		/* This is relatively uncommon - depends on scenarios
+		 * which have mutliple per-PF sent ramrods.
+		 */
+		DP_VERBOSE(p_hwfn, QED_MSG_SPQ,
+			   "Got completion for echo %04x - doesn't match echo %04x in completion pending list\n",
+			   le16_to_cpu(echo),
+			   le16_to_cpu(p_ent->elem.hdr.echo));
 	}
 
 	/* Release lock before callback, as callback may post
diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
index 6a43476..1d1ba2c 100644
--- a/include/linux/qed/common_hsi.h
+++ b/include/linux/qed/common_hsi.h
@@ -9,6 +9,8 @@
 #ifndef __COMMON_HSI__
 #define __COMMON_HSI__
 
+#define CORE_SPQE_PAGE_SIZE_BYTES                       4096
+
 #define FW_MAJOR_VERSION	8
 #define FW_MINOR_VERSION	4
 #define FW_REVISION_VERSION	2
-- 
1.7.1

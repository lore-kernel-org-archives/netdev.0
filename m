From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 2/4] qed: fix handling of concurrent ramrods
Date: Thu, 3 Dec 2015 05:59:14 -0500
Message-ID: <1449140356-17419-3-git-send-email-manish.chopra@qlogic.com>
References: <1449140356-17419-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>, Tomer Tayar <Tomer.Tayar@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:4291 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964954AbbLCLjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:39:32 -0500
In-Reply-To: <1449140356-17419-1-git-send-email-manish.chopra@qlogic.com>
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
 drivers/net/ethernet/qlogic/qed/qed_sp.h  |   15 ++++++-
 drivers/net/ethernet/qlogic/qed/qed_spq.c |   60 +++++++++++++++++++++-------
 include/linux/qed/common_hsi.h            |    2 +
 3 files changed, 60 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index 31a1f1e..467f7e1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -124,8 +124,19 @@ struct qed_spq {
 	dma_addr_t		p_phys;
 	struct qed_spq_entry	*p_virt;
 
-	/* Used as index for completions (returns on EQ by FW) */
-	u16			echo_idx;
+	/* Bitmap for handling out-of-order completions */
+#define SPQ_RING_SIZE \
+	(CORE_SPQE_PAGE_SIZE_BYTES / sizeof(struct slow_path_element))
+#define SPQ_COMP_BMAP_SIZE	(SPQ_RING_SIZE / BITS_PER_LONG)
+	unsigned long		p_comp_bitmap[SPQ_COMP_BMAP_SIZE];
+	u8			comp_bitmap_idx;
+
+#define SPQ_COMP_BMAP_SET_BIT(p_spq, idx)	\
+	__set_bit((idx) % SPQ_RING_SIZE, (p_spq)->p_comp_bitmap)
+#define SPQ_COMP_BMAP_CLEAR_BIT(p_spq, idx)	\
+	__clear_bit((idx) % SPQ_RING_SIZE, (p_spq)->p_comp_bitmap)
+#define SPQ_COMP_BMAP_TEST_BIT(p_spq, idx)	\
+	test_bit((idx) % SPQ_RING_SIZE, (p_spq)->p_comp_bitmap)
 
 	/* Statistics */
 	u32			unlimited_pending_count;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 7c0b845..55294f7 100644
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
@@ -437,7 +437,10 @@ void qed_spq_setup(struct qed_hwfn *p_hwfn)
 	p_spq->comp_count		= 0;
 	p_spq->comp_sent_count		= 0;
 	p_spq->unlimited_pending_count	= 0;
-	p_spq->echo_idx			= 0;
+
+	memset(p_spq->p_comp_bitmap, 0, SPQ_COMP_BMAP_SIZE *
+	       sizeof(unsigned long));
+	p_spq->comp_bitmap_idx = 0;
 
 	/* SPQ cid, cannot fail */
 	qed_cxt_acquire_cid(p_hwfn, PROTOCOLID_CORE, &p_spq->cid);
@@ -582,26 +585,32 @@ qed_spq_add_entry(struct qed_hwfn *p_hwfn,
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
@@ -779,11 +788,32 @@ int qed_spq_completion(struct qed_hwfn *p_hwfn,
 		if (p_ent->elem.hdr.echo == echo) {
 			list_del(&p_ent->list);
 
-			qed_chain_return_produced(&p_spq->chain);
+			/* Avoid overriding of SPQ entries when getting
+			 * out-of-order completions, by marking the completions
+			 * in a bitmap and increasing the chain consumer only
+			 * for the first successive completed entries.
+			 */
+			SPQ_COMP_BMAP_SET_BIT(p_spq, le16_to_cpu(echo));
+			while (SPQ_COMP_BMAP_TEST_BIT(p_spq,
+						      p_spq->comp_bitmap_idx)) {
+				SPQ_COMP_BMAP_CLEAR_BIT(p_spq,
+							p_spq->comp_bitmap_idx);
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

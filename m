From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 8/8] qed: Make OOO archipelagos into an array
Date: Thu, 6 Apr 2017 15:58:35 +0300
Message-ID: <1491483515-13502-9-git-send-email-Yuval.Mintz@cavium.com>
References: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon@cavium.com>,
        Michal Kalderon <Michal.Kalderon@caviumc.om>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53267 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754302AbdDFNBR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:01:17 -0400
In-Reply-To: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <Michal.Kalderon@cavium.com>

No need to maintain the various open archipelagos as a list -
The maximal number of them is known, and we can use the CID
as key for random-access into the array.

Signed-off-by: Michal Kalderon <Michal.Kalderon@caviumc.om>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ooo.c | 102 ++++++++----------------------
 drivers/net/ethernet/qlogic/qed/qed_ooo.h |   6 +-
 2 files changed, 30 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ooo.c b/drivers/net/ethernet/qlogic/qed/qed_ooo.c
index 378afce..db96670 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ooo.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ooo.c
@@ -41,6 +41,7 @@
 #include "qed_iscsi.h"
 #include "qed_ll2.h"
 #include "qed_ooo.h"
+#include "qed_cxt.h"
 
 static struct qed_ooo_archipelago
 *qed_ooo_seek_archipelago(struct qed_hwfn *p_hwfn,
@@ -48,15 +49,18 @@
 			  *p_ooo_info,
 			  u32 cid)
 {
-	struct qed_ooo_archipelago *p_archipelago = NULL;
+	u32 idx = (cid & 0xffff) - p_ooo_info->cid_base;
+	struct qed_ooo_archipelago *p_archipelago;
 
-	list_for_each_entry(p_archipelago,
-			    &p_ooo_info->archipelagos_list, list_entry) {
-		if (p_archipelago->cid == cid)
-			return p_archipelago;
-	}
+	if (idx >= p_ooo_info->max_num_archipelagos)
+		return NULL;
 
-	return NULL;
+	p_archipelago = &p_ooo_info->p_archipelagos_mem[idx];
+
+	if (list_empty(&p_archipelago->isles_list))
+		return NULL;
+
+	return p_archipelago;
 }
 
 static struct qed_ooo_isle *qed_ooo_seek_isle(struct qed_hwfn *p_hwfn,
@@ -97,8 +101,8 @@ void qed_ooo_save_history_entry(struct qed_hwfn *p_hwfn,
 
 struct qed_ooo_info *qed_ooo_alloc(struct qed_hwfn *p_hwfn)
 {
+	u16 max_num_archipelagos = 0, cid_base;
 	struct qed_ooo_info *p_ooo_info;
-	u16 max_num_archipelagos = 0;
 	u16 max_num_isles = 0;
 	u32 i;
 
@@ -110,6 +114,7 @@ struct qed_ooo_info *qed_ooo_alloc(struct qed_hwfn *p_hwfn)
 
 	max_num_archipelagos = p_hwfn->pf_params.iscsi_pf_params.num_cons;
 	max_num_isles = QED_MAX_NUM_ISLES + max_num_archipelagos;
+	cid_base = (u16)qed_cxt_get_proto_cid_start(p_hwfn, PROTOCOLID_ISCSI);
 
 	if (!max_num_archipelagos) {
 		DP_NOTICE(p_hwfn,
@@ -121,11 +126,12 @@ struct qed_ooo_info *qed_ooo_alloc(struct qed_hwfn *p_hwfn)
 	if (!p_ooo_info)
 		return NULL;
 
+	p_ooo_info->cid_base = cid_base;
+	p_ooo_info->max_num_archipelagos = max_num_archipelagos;
+
 	INIT_LIST_HEAD(&p_ooo_info->free_buffers_list);
 	INIT_LIST_HEAD(&p_ooo_info->ready_buffers_list);
 	INIT_LIST_HEAD(&p_ooo_info->free_isles_list);
-	INIT_LIST_HEAD(&p_ooo_info->free_archipelagos_list);
-	INIT_LIST_HEAD(&p_ooo_info->archipelagos_list);
 
 	p_ooo_info->p_isles_mem = kcalloc(max_num_isles,
 					  sizeof(struct qed_ooo_isle),
@@ -146,11 +152,8 @@ struct qed_ooo_info *qed_ooo_alloc(struct qed_hwfn *p_hwfn)
 	if (!p_ooo_info->p_archipelagos_mem)
 		goto no_archipelagos_mem;
 
-	for (i = 0; i < max_num_archipelagos; i++) {
+	for (i = 0; i < max_num_archipelagos; i++)
 		INIT_LIST_HEAD(&p_ooo_info->p_archipelagos_mem[i].isles_list);
-		list_add_tail(&p_ooo_info->p_archipelagos_mem[i].list_entry,
-			      &p_ooo_info->free_archipelagos_list);
-	}
 
 	p_ooo_info->ooo_history.p_cqes =
 				kcalloc(QED_MAX_NUM_OOO_HISTORY_ENTRIES,
@@ -178,21 +181,9 @@ void qed_ooo_release_connection_isles(struct qed_hwfn *p_hwfn,
 	struct qed_ooo_archipelago *p_archipelago;
 	struct qed_ooo_buffer *p_buffer;
 	struct qed_ooo_isle *p_isle;
-	bool b_found = false;
-
-	if (list_empty(&p_ooo_info->archipelagos_list))
-		return;
 
-	list_for_each_entry(p_archipelago,
-			    &p_ooo_info->archipelagos_list, list_entry) {
-		if (p_archipelago->cid == cid) {
-			list_del(&p_archipelago->list_entry);
-			b_found = true;
-			break;
-		}
-	}
-
-	if (!b_found)
+	p_archipelago = qed_ooo_seek_archipelago(p_hwfn, p_ooo_info, cid);
+	if (!p_archipelago)
 		return;
 
 	while (!list_empty(&p_archipelago->isles_list)) {
@@ -216,27 +207,21 @@ void qed_ooo_release_connection_isles(struct qed_hwfn *p_hwfn,
 		list_add_tail(&p_isle->list_entry,
 			      &p_ooo_info->free_isles_list);
 	}
-
-	list_add_tail(&p_archipelago->list_entry,
-		      &p_ooo_info->free_archipelagos_list);
 }
 
 void qed_ooo_release_all_isles(struct qed_hwfn *p_hwfn,
 			       struct qed_ooo_info *p_ooo_info)
 {
-	struct qed_ooo_archipelago *p_arch;
+	struct qed_ooo_archipelago *p_archipelago;
 	struct qed_ooo_buffer *p_buffer;
 	struct qed_ooo_isle *p_isle;
+	u32 i;
 
-	while (!list_empty(&p_ooo_info->archipelagos_list)) {
-		p_arch = list_first_entry(&p_ooo_info->archipelagos_list,
-					  struct qed_ooo_archipelago,
-					  list_entry);
-
-		list_del(&p_arch->list_entry);
+	for (i = 0; i < p_ooo_info->max_num_archipelagos; i++) {
+		p_archipelago = &(p_ooo_info->p_archipelagos_mem[i]);
 
-		while (!list_empty(&p_arch->isles_list)) {
-			p_isle = list_first_entry(&p_arch->isles_list,
+		while (!list_empty(&p_archipelago->isles_list)) {
+			p_isle = list_first_entry(&p_archipelago->isles_list,
 						  struct qed_ooo_isle,
 						  list_entry);
 
@@ -258,8 +243,6 @@ void qed_ooo_release_all_isles(struct qed_hwfn *p_hwfn,
 			list_add_tail(&p_isle->list_entry,
 				      &p_ooo_info->free_isles_list);
 		}
-		list_add_tail(&p_arch->list_entry,
-			      &p_ooo_info->free_archipelagos_list);
 	}
 	if (!list_empty(&p_ooo_info->ready_buffers_list))
 		list_splice_tail_init(&p_ooo_info->ready_buffers_list,
@@ -378,12 +361,6 @@ void qed_ooo_delete_isles(struct qed_hwfn *p_hwfn,
 		p_ooo_info->cur_isles_number--;
 		list_add(&p_isle->list_entry, &p_ooo_info->free_isles_list);
 	}
-
-	if (list_empty(&p_archipelago->isles_list)) {
-		list_del(&p_archipelago->list_entry);
-		list_add(&p_archipelago->list_entry,
-			 &p_ooo_info->free_archipelagos_list);
-	}
 }
 
 void qed_ooo_add_new_isle(struct qed_hwfn *p_hwfn,
@@ -426,28 +403,10 @@ void qed_ooo_add_new_isle(struct qed_hwfn *p_hwfn,
 		return;
 	}
 
-	if (!p_archipelago &&
-	    !list_empty(&p_ooo_info->free_archipelagos_list)) {
-		p_archipelago =
-		    list_first_entry(&p_ooo_info->free_archipelagos_list,
-				     struct qed_ooo_archipelago, list_entry);
+	if (!p_archipelago) {
+		u32 idx = (cid & 0xffff) - p_ooo_info->cid_base;
 
-		list_del(&p_archipelago->list_entry);
-		if (!list_empty(&p_archipelago->isles_list)) {
-			DP_NOTICE(p_hwfn,
-				  "Free OOO connection is not empty\n");
-			INIT_LIST_HEAD(&p_archipelago->isles_list);
-		}
-		p_archipelago->cid = cid;
-		list_add(&p_archipelago->list_entry,
-			 &p_ooo_info->archipelagos_list);
-	} else if (!p_archipelago) {
-		DP_NOTICE(p_hwfn, "No more free OOO connections\n");
-		list_add(&p_isle->list_entry,
-			 &p_ooo_info->free_isles_list);
-		list_add(&p_buffer->list_entry,
-			 &p_ooo_info->free_buffers_list);
-		return;
+		p_archipelago = &p_ooo_info->p_archipelagos_mem[idx];
 	}
 
 	list_add(&p_buffer->list_entry, &p_isle->buffers_list);
@@ -517,11 +476,6 @@ void qed_ooo_join_isles(struct qed_hwfn *p_hwfn,
 	} else {
 		list_splice_tail_init(&p_right_isle->buffers_list,
 				      &p_ooo_info->ready_buffers_list);
-		if (list_empty(&p_archipelago->isles_list)) {
-			list_del(&p_archipelago->list_entry);
-			list_add(&p_archipelago->list_entry,
-				 &p_ooo_info->free_archipelagos_list);
-		}
 	}
 	list_add_tail(&p_right_isle->list_entry, &p_ooo_info->free_isles_list);
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ooo.h b/drivers/net/ethernet/qlogic/qed/qed_ooo.h
index 4f138fb..791ad0f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ooo.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_ooo.h
@@ -60,9 +60,7 @@ struct qed_ooo_isle {
 };
 
 struct qed_ooo_archipelago {
-	struct list_head list_entry;
 	struct list_head isles_list;
-	u32 cid;
 };
 
 struct qed_ooo_history {
@@ -75,14 +73,14 @@ struct qed_ooo_info {
 	struct list_head free_buffers_list;
 	struct list_head ready_buffers_list;
 	struct list_head free_isles_list;
-	struct list_head free_archipelagos_list;
-	struct list_head archipelagos_list;
 	struct qed_ooo_archipelago *p_archipelagos_mem;
 	struct qed_ooo_isle *p_isles_mem;
 	struct qed_ooo_history ooo_history;
 	u32 cur_isles_number;
 	u32 max_isles_number;
 	u32 gen_isles_number;
+	u16 max_num_archipelagos;
+	u16 cid_base;
 };
 
 #if IS_ENABLED(CONFIG_QED_ISCSI)
-- 
1.9.3

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 4/6] qed: verify RoCE resource bitmaps are released
Date: Sun, 30 Apr 2017 11:49:08 +0300
Message-ID: <1493542150-21826-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ram.Amrani@cavium.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0055.outbound.protection.outlook.com ([104.47.33.55]:21120
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2999110AbdD3Itr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 04:49:47 -0400
In-Reply-To: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

Add mechanism to verify RoCE resources are released prior to freeing the
bitmaps. If this is not the case, print what resources were not released.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 105 +++++++++++++++++++++--------
 drivers/net/ethernet/qlogic/qed/qed_roce.h |   2 +
 2 files changed, 80 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 0c449dd..f36e3c3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -90,7 +90,7 @@ void qed_roce_async_event(struct qed_hwfn *p_hwfn,
 }
 
 static int qed_rdma_bmap_alloc(struct qed_hwfn *p_hwfn,
-			       struct qed_bmap *bmap, u32 max_count)
+			       struct qed_bmap *bmap, u32 max_count, char *name)
 {
 	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "max_count = %08x\n", max_count);
 
@@ -104,26 +104,24 @@ static int qed_rdma_bmap_alloc(struct qed_hwfn *p_hwfn,
 		return -ENOMEM;
 	}
 
-	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Allocated bitmap %p\n",
-		   bmap->bitmap);
+	snprintf(bmap->name, QED_RDMA_MAX_BMAP_NAME, "%s", name);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "0\n");
 	return 0;
 }
 
 static int qed_rdma_bmap_alloc_id(struct qed_hwfn *p_hwfn,
 				  struct qed_bmap *bmap, u32 *id_num)
 {
-	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "bmap = %p\n", bmap);
-
 	*id_num = find_first_zero_bit(bmap->bitmap, bmap->max_count);
-
-	if (*id_num >= bmap->max_count) {
-		DP_NOTICE(p_hwfn, "no id available max_count=%d\n",
-			  bmap->max_count);
+	if (*id_num >= bmap->max_count)
 		return -EINVAL;
-	}
 
 	__set_bit(*id_num, bmap->bitmap);
 
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "%s bitmap: allocated id %d\n",
+		   bmap->name, *id_num);
+
 	return 0;
 }
 
@@ -141,15 +139,18 @@ static void qed_bmap_release_id(struct qed_hwfn *p_hwfn,
 {
 	bool b_acquired;
 
-	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "id_num = %08x", id_num);
 	if (id_num >= bmap->max_count)
 		return;
 
 	b_acquired = test_and_clear_bit(id_num, bmap->bitmap);
 	if (!b_acquired) {
-		DP_NOTICE(p_hwfn, "ID %d already released\n", id_num);
+		DP_NOTICE(p_hwfn, "%s bitmap: id %d already released\n",
+			  bmap->name, id_num);
 		return;
 	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "%s bitmap: released id %d\n",
+		   bmap->name, id_num);
 }
 
 static int qed_bmap_test_id(struct qed_hwfn *p_hwfn,
@@ -224,7 +225,8 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 	}
 
 	/* Allocate bit map for pd's */
-	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->pd_map, RDMA_MAX_PDS);
+	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->pd_map, RDMA_MAX_PDS,
+				 "PD");
 	if (rc) {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
 			   "Failed to allocate pd_map, rc = %d\n",
@@ -234,7 +236,7 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 
 	/* Allocate DPI bitmap */
 	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->dpi_map,
-				 p_hwfn->dpi_count);
+				 p_hwfn->dpi_count, "DPI");
 	if (rc) {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
 			   "Failed to allocate DPI bitmap, rc = %d\n", rc);
@@ -245,7 +247,7 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 	 * twice the number of QPs.
 	 */
 	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->cq_map,
-				 p_rdma_info->num_qps * 2);
+				 p_rdma_info->num_qps * 2, "CQ");
 	if (rc) {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
 			   "Failed to allocate cq bitmap, rc = %d\n", rc);
@@ -257,7 +259,7 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 	 * The maximum number of CQs is bounded to  twice the number of QPs.
 	 */
 	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->toggle_bits,
-				 p_rdma_info->num_qps * 2);
+				 p_rdma_info->num_qps * 2, "Toggle");
 	if (rc) {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
 			   "Failed to allocate toogle bits, rc = %d\n", rc);
@@ -266,7 +268,7 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 
 	/* Allocate bitmap for itids */
 	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->tid_map,
-				 p_rdma_info->num_mrs);
+				 p_rdma_info->num_mrs, "MR");
 	if (rc) {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
 			   "Failed to allocate itids bitmaps, rc = %d\n", rc);
@@ -274,7 +276,8 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 	}
 
 	/* Allocate bitmap for cids used for qps. */
-	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->cid_map, num_cons);
+	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->cid_map, num_cons,
+				 "CID");
 	if (rc) {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
 			   "Failed to allocate cid bitmap, rc = %d\n", rc);
@@ -282,7 +285,8 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 	}
 
 	/* Allocate bitmap for cids used for responders/requesters. */
-	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->real_cid_map, num_cons);
+	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->real_cid_map, num_cons,
+				 "REAL_CID");
 	if (rc) {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
 			   "Failed to allocate real cid bitmap, rc = %d\n", rc);
@@ -313,6 +317,54 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+static void qed_rdma_bmap_free(struct qed_hwfn *p_hwfn,
+			       struct qed_bmap *bmap, bool check)
+{
+	int weight = bitmap_weight(bmap->bitmap, bmap->max_count);
+	int last_line = bmap->max_count / (64 * 8);
+	int last_item = last_line * 8 +
+	    DIV_ROUND_UP(bmap->max_count % (64 * 8), 64);
+	u64 *pmap = (u64 *)bmap->bitmap;
+	int line, item, offset;
+	u8 str_last_line[200] = { 0 };
+
+	if (!weight || !check)
+		goto end;
+
+	DP_NOTICE(p_hwfn,
+		  "%s bitmap not free - size=%d, weight=%d, 512 bits per line\n",
+		  bmap->name, bmap->max_count, weight);
+
+	/* print aligned non-zero lines, if any */
+	for (item = 0, line = 0; line < last_line; line++, item += 8)
+		if (bitmap_weight((unsigned long *)&pmap[item], 64 * 8))
+			DP_NOTICE(p_hwfn,
+				  "line 0x%04x: 0x%016llx 0x%016llx 0x%016llx 0x%016llx 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
+				  line,
+				  pmap[item],
+				  pmap[item + 1],
+				  pmap[item + 2],
+				  pmap[item + 3],
+				  pmap[item + 4],
+				  pmap[item + 5],
+				  pmap[item + 6], pmap[item + 7]);
+
+	/* print last unaligned non-zero line, if any */
+	if ((bmap->max_count % (64 * 8)) &&
+	    (bitmap_weight((unsigned long *)&pmap[item],
+			   bmap->max_count - item * 64))) {
+		offset = sprintf(str_last_line, "line 0x%04x: ", line);
+		for (; item < last_item; item++)
+			offset += sprintf(str_last_line + offset,
+					  "0x%016llx ", pmap[item]);
+		DP_NOTICE(p_hwfn, "%s\n", str_last_line);
+	}
+
+end:
+	kfree(bmap->bitmap);
+	bmap->bitmap = NULL;
+}
+
 static void qed_rdma_resc_free(struct qed_hwfn *p_hwfn)
 {
 	struct qed_bmap *rcid_map = &p_hwfn->p_rdma_info->real_cid_map;
@@ -332,12 +384,12 @@ static void qed_rdma_resc_free(struct qed_hwfn *p_hwfn)
 		}
 	}
 
-	kfree(p_rdma_info->cid_map.bitmap);
-	kfree(p_rdma_info->tid_map.bitmap);
-	kfree(p_rdma_info->toggle_bits.bitmap);
-	kfree(p_rdma_info->cq_map.bitmap);
-	kfree(p_rdma_info->dpi_map.bitmap);
-	kfree(p_rdma_info->pd_map.bitmap);
+	qed_rdma_bmap_free(p_hwfn, &p_hwfn->p_rdma_info->cid_map, 1);
+	qed_rdma_bmap_free(p_hwfn, &p_hwfn->p_rdma_info->pd_map, 1);
+	qed_rdma_bmap_free(p_hwfn, &p_hwfn->p_rdma_info->dpi_map, 1);
+	qed_rdma_bmap_free(p_hwfn, &p_hwfn->p_rdma_info->cq_map, 1);
+	qed_rdma_bmap_free(p_hwfn, &p_hwfn->p_rdma_info->toggle_bits, 0);
+	qed_rdma_bmap_free(p_hwfn, &p_hwfn->p_rdma_info->tid_map, 1);
 
 	kfree(p_rdma_info->port);
 	kfree(p_rdma_info->dev);
@@ -954,8 +1006,7 @@ static int qed_rdma_create_cq(void *rdma_cxt,
 
 	/* Allocate icid */
 	spin_lock_bh(&p_info->lock);
-	rc = qed_rdma_bmap_alloc_id(p_hwfn,
-				    &p_info->cq_map, &returned_id);
+	rc = qed_rdma_bmap_alloc_id(p_hwfn, &p_info->cq_map, &returned_id);
 	spin_unlock_bh(&p_info->lock);
 
 	if (rc) {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.h b/drivers/net/ethernet/qlogic/qed/qed_roce.h
index 3ccc08a..9742af5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.h
@@ -67,9 +67,11 @@ enum qed_rdma_toggle_bit {
 	QED_RDMA_TOGGLE_BIT_SET = 1
 };
 
+#define QED_RDMA_MAX_BMAP_NAME	(10)
 struct qed_bmap {
 	unsigned long *bitmap;
 	u32 max_count;
+	char name[QED_RDMA_MAX_BMAP_NAME];
 };
 
 struct qed_rdma_info {
-- 
1.9.3

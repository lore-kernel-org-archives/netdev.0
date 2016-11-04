From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH for-next 09/11] IB/hns: Change qpn allocation to round-robin mode.
Date: Fri, 4 Nov 2016 16:36:31 +0000
Message-ID: <20161104163633.141880-10-salil.mehta@huawei.com>
References: <20161104163633.141880-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161104163633.141880-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

When using CM to establish connections, qp number that was freed
just now will be rejected by ib core. To fix these problem, We
change qpn allocation to round-robin mode. We added the round-robin
mode for allocating resources using bitmap. We use round-robin mode
for qp number and non round-robing mode for other resources like
cq number, pd number etc.

Signed-off-by: Wei Hu (Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta  <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/hns/hns_roce_alloc.c  |   11 +++++++----
 drivers/infiniband/hw/hns/hns_roce_cq.c     |    4 ++--
 drivers/infiniband/hw/hns/hns_roce_device.h |    9 +++++++--
 drivers/infiniband/hw/hns/hns_roce_mr.c     |    2 +-
 drivers/infiniband/hw/hns/hns_roce_pd.c     |    5 +++--
 drivers/infiniband/hw/hns/hns_roce_qp.c     |    2 +-
 6 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_alloc.c b/drivers/infiniband/hw/hns/hns_roce_alloc.c
index 863a17a..605962f 100644
--- a/drivers/infiniband/hw/hns/hns_roce_alloc.c
+++ b/drivers/infiniband/hw/hns/hns_roce_alloc.c
@@ -61,9 +61,10 @@ int hns_roce_bitmap_alloc(struct hns_roce_bitmap *bitmap, unsigned long *obj)
 	return ret;
 }
 
-void hns_roce_bitmap_free(struct hns_roce_bitmap *bitmap, unsigned long obj)
+void hns_roce_bitmap_free(struct hns_roce_bitmap *bitmap, unsigned long obj,
+			  int rr)
 {
-	hns_roce_bitmap_free_range(bitmap, obj, 1);
+	hns_roce_bitmap_free_range(bitmap, obj, 1, rr);
 }
 
 int hns_roce_bitmap_alloc_range(struct hns_roce_bitmap *bitmap, int cnt,
@@ -106,7 +107,8 @@ int hns_roce_bitmap_alloc_range(struct hns_roce_bitmap *bitmap, int cnt,
 }
 
 void hns_roce_bitmap_free_range(struct hns_roce_bitmap *bitmap,
-				unsigned long obj, int cnt)
+				unsigned long obj, int cnt,
+				int rr)
 {
 	int i;
 
@@ -116,7 +118,8 @@ void hns_roce_bitmap_free_range(struct hns_roce_bitmap *bitmap,
 	for (i = 0; i < cnt; i++)
 		clear_bit(obj + i, bitmap->table);
 
-	bitmap->last = min(bitmap->last, obj);
+	if (!rr)
+		bitmap->last = min(bitmap->last, obj);
 	bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
 		       & bitmap->mask;
 	spin_unlock(&bitmap->lock);
diff --git a/drivers/infiniband/hw/hns/hns_roce_cq.c b/drivers/infiniband/hw/hns/hns_roce_cq.c
index 461a273..c9f6c3d 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_cq.c
@@ -166,7 +166,7 @@ static int hns_roce_cq_alloc(struct hns_roce_dev *hr_dev, int nent,
 	hns_roce_table_put(hr_dev, &cq_table->table, hr_cq->cqn);
 
 err_out:
-	hns_roce_bitmap_free(&cq_table->bitmap, hr_cq->cqn);
+	hns_roce_bitmap_free(&cq_table->bitmap, hr_cq->cqn, BITMAP_NO_RR);
 	return ret;
 }
 
@@ -204,7 +204,7 @@ static void hns_roce_free_cq(struct hns_roce_dev *hr_dev,
 	spin_unlock_irq(&cq_table->lock);
 
 	hns_roce_table_put(hr_dev, &cq_table->table, hr_cq->cqn);
-	hns_roce_bitmap_free(&cq_table->bitmap, hr_cq->cqn);
+	hns_roce_bitmap_free(&cq_table->bitmap, hr_cq->cqn, BITMAP_NO_RR);
 }
 
 static int hns_roce_ib_get_cq_umem(struct hns_roce_dev *hr_dev,
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 7242b14..593a42a 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -72,6 +72,9 @@
 #define HNS_ROCE_MAX_GID_NUM			16
 #define HNS_ROCE_GID_SIZE			16
 
+#define BITMAP_NO_RR				0
+#define BITMAP_RR				1
+
 #define MR_TYPE_MR				0x00
 #define MR_TYPE_DMA				0x03
 
@@ -661,7 +664,8 @@ int hns_roce_buf_write_mtt(struct hns_roce_dev *hr_dev,
 void hns_roce_cleanup_qp_table(struct hns_roce_dev *hr_dev);
 
 int hns_roce_bitmap_alloc(struct hns_roce_bitmap *bitmap, unsigned long *obj);
-void hns_roce_bitmap_free(struct hns_roce_bitmap *bitmap, unsigned long obj);
+void hns_roce_bitmap_free(struct hns_roce_bitmap *bitmap, unsigned long obj,
+			 int rr);
 int hns_roce_bitmap_init(struct hns_roce_bitmap *bitmap, u32 num, u32 mask,
 			 u32 reserved_bot, u32 resetrved_top);
 void hns_roce_bitmap_cleanup(struct hns_roce_bitmap *bitmap);
@@ -669,7 +673,8 @@ int hns_roce_bitmap_init(struct hns_roce_bitmap *bitmap, u32 num, u32 mask,
 int hns_roce_bitmap_alloc_range(struct hns_roce_bitmap *bitmap, int cnt,
 				int align, unsigned long *obj);
 void hns_roce_bitmap_free_range(struct hns_roce_bitmap *bitmap,
-				unsigned long obj, int cnt);
+				unsigned long obj, int cnt,
+				int rr);
 
 struct ib_ah *hns_roce_create_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr);
 int hns_roce_query_ah(struct ib_ah *ibah, struct ib_ah_attr *ah_attr);
diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
index 2227962..6396bc5 100644
--- a/drivers/infiniband/hw/hns/hns_roce_mr.c
+++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
@@ -288,7 +288,7 @@ static void hns_roce_mr_free(struct hns_roce_dev *hr_dev,
 	}
 
 	hns_roce_bitmap_free(&hr_dev->mr_table.mtpt_bitmap,
-			     key_to_hw_index(mr->key));
+			     key_to_hw_index(mr->key), BITMAP_NO_RR);
 }
 
 static int hns_roce_mr_enable(struct hns_roce_dev *hr_dev,
diff --git a/drivers/infiniband/hw/hns/hns_roce_pd.c b/drivers/infiniband/hw/hns/hns_roce_pd.c
index 05db7d5..a64500f 100644
--- a/drivers/infiniband/hw/hns/hns_roce_pd.c
+++ b/drivers/infiniband/hw/hns/hns_roce_pd.c
@@ -40,7 +40,7 @@ static int hns_roce_pd_alloc(struct hns_roce_dev *hr_dev, unsigned long *pdn)
 
 static void hns_roce_pd_free(struct hns_roce_dev *hr_dev, unsigned long pdn)
 {
-	hns_roce_bitmap_free(&hr_dev->pd_bitmap, pdn);
+	hns_roce_bitmap_free(&hr_dev->pd_bitmap, pdn, BITMAP_NO_RR);
 }
 
 int hns_roce_init_pd_table(struct hns_roce_dev *hr_dev)
@@ -121,7 +121,8 @@ int hns_roce_uar_alloc(struct hns_roce_dev *hr_dev, struct hns_roce_uar *uar)
 
 void hns_roce_uar_free(struct hns_roce_dev *hr_dev, struct hns_roce_uar *uar)
 {
-	hns_roce_bitmap_free(&hr_dev->uar_table.bitmap, uar->index);
+	hns_roce_bitmap_free(&hr_dev->uar_table.bitmap, uar->index,
+			     BITMAP_NO_RR);
 }
 
 int hns_roce_init_uar_table(struct hns_roce_dev *hr_dev)
diff --git a/drivers/infiniband/hw/hns/hns_roce_qp.c b/drivers/infiniband/hw/hns/hns_roce_qp.c
index e86dd8d..4775b5c 100644
--- a/drivers/infiniband/hw/hns/hns_roce_qp.c
+++ b/drivers/infiniband/hw/hns/hns_roce_qp.c
@@ -250,7 +250,7 @@ void hns_roce_release_range_qp(struct hns_roce_dev *hr_dev, int base_qpn,
 	if (base_qpn < SQP_NUM)
 		return;
 
-	hns_roce_bitmap_free_range(&qp_table->bitmap, base_qpn, cnt);
+	hns_roce_bitmap_free_range(&qp_table->bitmap, base_qpn, cnt, BITMAP_RR);
 }
 
 static int hns_roce_set_rq_size(struct hns_roce_dev *hr_dev,
-- 
1.7.9.5


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 11/11] IB/cm: Remove compare_data checks
Date: Mon, 15 Jun 2015 11:47:16 +0300
Message-ID: <1434358036-15526-12-git-send-email-haggaie@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434358036-15526-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Now that there are no ib_cm clients using the compare_data feature for
matching IB CM requests' private data, remove the compare_data parameter of
ib_cm_listen and remove the code implementing the feature.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cm.c            | 87 ++++-----------------------------
 drivers/infiniband/core/ucm.c           |  3 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c |  2 +-
 drivers/infiniband/ulp/srpt/ib_srpt.c   |  2 +-
 include/rdma/ib_cm.h                    | 14 +-----
 5 files changed, 14 insertions(+), 94 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index d124a891430b..2d769aad5c4f 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -221,7 +221,6 @@ struct cm_id_private {
 	/* todo: use alternate port on send failure */
 	struct cm_av av;
 	struct cm_av alt_av;
-	struct ib_cm_compare_data *compare_data;
 
 	void *private_data;
 	__be64 tid;
@@ -442,40 +441,6 @@ static struct cm_id_private * cm_acquire_id(__be32 local_id, __be32 remote_id)
 	return cm_id_priv;
 }
 
-static void cm_mask_copy(u32 *dst, const u32 *src, const u32 *mask)
-{
-	int i;
-
-	for (i = 0; i < IB_CM_COMPARE_SIZE; i++)
-		dst[i] = src[i] & mask[i];
-}
-
-static int cm_compare_data(struct ib_cm_compare_data *src_data,
-			   struct ib_cm_compare_data *dst_data)
-{
-	u32 src[IB_CM_COMPARE_SIZE];
-	u32 dst[IB_CM_COMPARE_SIZE];
-
-	if (!src_data || !dst_data)
-		return 0;
-
-	cm_mask_copy(src, src_data->data, dst_data->mask);
-	cm_mask_copy(dst, dst_data->data, src_data->mask);
-	return memcmp(src, dst, sizeof(src));
-}
-
-static int cm_compare_private_data(u32 *private_data,
-				   struct ib_cm_compare_data *dst_data)
-{
-	u32 src[IB_CM_COMPARE_SIZE];
-
-	if (!dst_data)
-		return 0;
-
-	cm_mask_copy(src, private_data, dst_data->mask);
-	return memcmp(src, dst_data->data, sizeof(src));
-}
-
 /*
  * Trivial helpers to strip endian annotation and compare; the
  * endianness doesn't actually matter since we just need a stable
@@ -508,18 +473,14 @@ static struct cm_id_private * cm_insert_listen(struct cm_id_private *cm_id_priv)
 	struct cm_id_private *cur_cm_id_priv;
 	__be64 service_id = cm_id_priv->id.service_id;
 	__be64 service_mask = cm_id_priv->id.service_mask;
-	int data_cmp;
 
 	while (*link) {
 		parent = *link;
 		cur_cm_id_priv = rb_entry(parent, struct cm_id_private,
 					  service_node);
-		data_cmp = cm_compare_data(cm_id_priv->compare_data,
-					   cur_cm_id_priv->compare_data);
 		if ((cur_cm_id_priv->id.service_mask & service_id) ==
 		    (service_mask & cur_cm_id_priv->id.service_id) &&
-		    (cm_id_priv->id.device == cur_cm_id_priv->id.device) &&
-		    !data_cmp)
+		    (cm_id_priv->id.device == cur_cm_id_priv->id.device))
 			return cur_cm_id_priv;
 
 		if (cm_id_priv->id.device < cur_cm_id_priv->id.device)
@@ -530,8 +491,6 @@ static struct cm_id_private * cm_insert_listen(struct cm_id_private *cm_id_priv)
 			link = &(*link)->rb_left;
 		else if (be64_gt(service_id, cur_cm_id_priv->id.service_id))
 			link = &(*link)->rb_right;
-		else if (data_cmp < 0)
-			link = &(*link)->rb_left;
 		else
 			link = &(*link)->rb_right;
 	}
@@ -541,20 +500,16 @@ static struct cm_id_private * cm_insert_listen(struct cm_id_private *cm_id_priv)
 }
 
 static struct cm_id_private * cm_find_listen(struct ib_device *device,
-					     __be64 service_id,
-					     u32 *private_data)
+					     __be64 service_id)
 {
 	struct rb_node *node = cm.listen_service_table.rb_node;
 	struct cm_id_private *cm_id_priv;
-	int data_cmp;
 
 	while (node) {
 		cm_id_priv = rb_entry(node, struct cm_id_private, service_node);
-		data_cmp = cm_compare_private_data(private_data,
-						   cm_id_priv->compare_data);
 		if ((cm_id_priv->id.service_mask & service_id) ==
 		     cm_id_priv->id.service_id &&
-		    (cm_id_priv->id.device == device) && !data_cmp)
+		    (cm_id_priv->id.device == device))
 			return cm_id_priv;
 
 		if (device < cm_id_priv->id.device)
@@ -565,8 +520,6 @@ static struct cm_id_private * cm_find_listen(struct ib_device *device,
 			node = node->rb_left;
 		else if (be64_gt(service_id, cm_id_priv->id.service_id))
 			node = node->rb_right;
-		else if (data_cmp < 0)
-			node = node->rb_left;
 		else
 			node = node->rb_right;
 	}
@@ -932,7 +885,6 @@ retest:
 	wait_for_completion(&cm_id_priv->comp);
 	while ((work = cm_dequeue_work(cm_id_priv)) != NULL)
 		cm_free_work(work);
-	kfree(cm_id_priv->compare_data);
 	kfree(cm_id_priv->private_data);
 	kfree(cm_id_priv);
 }
@@ -955,16 +907,12 @@ EXPORT_SYMBOL(ib_destroy_cm_id);
  *   range of service IDs.  If set to 0, the service ID is matched
  *   exactly.  This parameter is ignored if %service_id is set to
  *   IB_CM_ASSIGN_SERVICE_ID.
- * @compare_data: This parameter is optional.  It specifies data that must
- *   appear in the private data of a connection request for the specified
- *   listen request.
  * @lock: If set, lock the cm.lock spin-lock when adding the id to the
  *   listener tree. When false, the caller must already hold the spin-lock,
  *   and compare_data must be NULL.
  */
 static int __ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id,
 			  __be64 service_mask,
-			  struct ib_cm_compare_data *compare_data,
 			  bool lock)
 {
 	struct cm_id_private *cm_id_priv, *cur_cm_id_priv;
@@ -981,17 +929,6 @@ static int __ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id,
 	if (cm_id->state != IB_CM_IDLE)
 		return -EINVAL;
 
-	if (compare_data) {
-		cm_id_priv->compare_data = kzalloc(sizeof *compare_data,
-						   GFP_KERNEL);
-		if (!cm_id_priv->compare_data)
-			return -ENOMEM;
-		cm_mask_copy(cm_id_priv->compare_data->data,
-			     compare_data->data, compare_data->mask);
-		memcpy(cm_id_priv->compare_data->mask, compare_data->mask,
-		       sizeof(compare_data->mask));
-	}
-
 	cm_id->state = IB_CM_LISTEN;
 
 	if (lock)
@@ -1009,18 +946,14 @@ static int __ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id,
 
 	if (cur_cm_id_priv) {
 		cm_id->state = IB_CM_IDLE;
-		kfree(cm_id_priv->compare_data);
-		cm_id_priv->compare_data = NULL;
 		ret = -EBUSY;
 	}
 	return ret;
 }
 
-int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
-		 struct ib_cm_compare_data *compare_data)
+int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask)
 {
-	return __ib_cm_listen(cm_id, service_id, service_mask, compare_data,
-			      true);
+	return __ib_cm_listen(cm_id, service_id, service_mask, true);
 }
 EXPORT_SYMBOL(ib_cm_listen);
 
@@ -1066,7 +999,7 @@ struct ib_cm_id *ib_cm_id_create_and_listen(
 		goto new_id;
 
 	/* Find an existing ID */
-	cm_id_priv = cm_find_listen(device, service_id, NULL);
+	cm_id_priv = cm_find_listen(device, service_id);
 	if (cm_id_priv) {
 		atomic_inc(&cm_id_priv->refcount);
 		++cm_id_priv->listen_sharecount;
@@ -1083,7 +1016,7 @@ struct ib_cm_id *ib_cm_id_create_and_listen(
 
 new_id:
 	/* Use newly created ID */
-	err = __ib_cm_listen(cm_id, service_id, service_mask, NULL, false);
+	err = __ib_cm_listen(cm_id, service_id, service_mask, false);
 
 	spin_unlock_irqrestore(&cm.lock, flags);
 
@@ -1589,8 +1522,7 @@ static struct cm_id_private * cm_match_req(struct cm_work *work,
 
 	/* Find matching listen request. */
 	listen_cm_id_priv = cm_find_listen(cm_id_priv->id.device,
-					   req_msg->service_id,
-					   req_msg->private_data);
+					   req_msg->service_id);
 	if (!listen_cm_id_priv) {
 		cm_cleanup_timewait(cm_id_priv->timewait_info);
 		spin_unlock_irq(&cm.lock);
@@ -3144,8 +3076,7 @@ static int cm_sidr_req_handler(struct cm_work *work)
 	}
 	cm_id_priv->id.state = IB_CM_SIDR_REQ_RCVD;
 	cur_cm_id_priv = cm_find_listen(cm_id->device,
-					sidr_req_msg->service_id,
-					sidr_req_msg->private_data);
+					sidr_req_msg->service_id);
 	if (!cur_cm_id_priv) {
 		spin_unlock_irq(&cm.lock);
 		cm_reject_sidr_req(cm_id_priv, IB_SIDR_UNSUPPORTED);
diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.c
index 62c24b1452b8..1003b5ec5591 100644
--- a/drivers/infiniband/core/ucm.c
+++ b/drivers/infiniband/core/ucm.c
@@ -658,8 +658,7 @@ static ssize_t ib_ucm_listen(struct ib_ucm_file *file,
 	if (result)
 		goto out;
 
-	result = ib_cm_listen(ctx->cm_id, cmd.service_id, cmd.service_mask,
-			      NULL);
+	result = ib_cm_listen(ctx->cm_id, cmd.service_id, cmd.service_mask);
 out:
 	ib_ucm_ctx_put(ctx);
 	return result;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index cf32a778e7d0..626959927f4d 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -854,7 +854,7 @@ int ipoib_cm_dev_open(struct net_device *dev)
 	}
 
 	ret = ib_cm_listen(priv->cm.id, cpu_to_be64(IPOIB_CM_IETF_ID | priv->qp->qp_num),
-			   0, NULL);
+			   0);
 	if (ret) {
 		printk(KERN_WARNING "%s: failed to listen on ID 0x%llx\n", priv->ca->name,
 		       IPOIB_CM_IETF_ID | priv->qp->qp_num);
diff --git a/drivers/infiniband/ulp/srpt/ib_srpt.c b/drivers/infiniband/ulp/srpt/ib_srpt.c
index 0b2857b1b112..481ce1fffc62 100644
--- a/drivers/infiniband/ulp/srpt/ib_srpt.c
+++ b/drivers/infiniband/ulp/srpt/ib_srpt.c
@@ -3259,7 +3259,7 @@ static void srpt_add_one(struct ib_device *device)
 	 * in the system as service_id; therefore, the target_id will change
 	 * if this HCA is gone bad and replaced by different HCA
 	 */
-	if (ib_cm_listen(sdev->cm_id, cpu_to_be64(srpt_service_guid), 0, NULL))
+	if (ib_cm_listen(sdev->cm_id, cpu_to_be64(srpt_service_guid), 0))
 		goto err_cm;
 
 	INIT_IB_EVENT_HANDLER(&sdev->event_handler, sdev->device,
diff --git a/include/rdma/ib_cm.h b/include/rdma/ib_cm.h
index 0dc2ff983198..4e315c982ec3 100644
--- a/include/rdma/ib_cm.h
+++ b/include/rdma/ib_cm.h
@@ -105,8 +105,6 @@ enum ib_cm_data_size {
 	IB_CM_SIDR_REQ_PRIVATE_DATA_SIZE = 216,
 	IB_CM_SIDR_REP_PRIVATE_DATA_SIZE = 136,
 	IB_CM_SIDR_REP_INFO_LENGTH	 = 72,
-	/* compare done u32 at a time */
-	IB_CM_COMPARE_SIZE		 = (64 / sizeof(u32))
 };
 
 struct ib_cm_id;
@@ -340,11 +338,6 @@ void ib_destroy_cm_id(struct ib_cm_id *cm_id);
 #define IB_SDP_SERVICE_ID	cpu_to_be64(0x0000000000010000ULL)
 #define IB_SDP_SERVICE_ID_MASK	cpu_to_be64(0xFFFFFFFFFFFF0000ULL)
 
-struct ib_cm_compare_data {
-	u32  data[IB_CM_COMPARE_SIZE];
-	u32  mask[IB_CM_COMPARE_SIZE];
-};
-
 /**
  * ib_cm_listen - Initiates listening on the specified service ID for
  *   connection and service ID resolution requests.
@@ -357,12 +350,9 @@ struct ib_cm_compare_data {
  *   range of service IDs.  If set to 0, the service ID is matched
  *   exactly.  This parameter is ignored if %service_id is set to
  *   IB_CM_ASSIGN_SERVICE_ID.
- * @compare_data: This parameter is optional.  It specifies data that must
- *   appear in the private data of a connection request for the specified
- *   listen request.
  */
-int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
-		 struct ib_cm_compare_data *compare_data);
+int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id,
+		 __be64 service_mask);
 
 struct ib_cm_id *ib_cm_id_create_and_listen(
 		struct ib_device *device, ib_cm_handler cm_handler,
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v1 12/12] IB/cm: Remove compare_data checks
Date: Mon, 22 Jun 2015 15:42:41 +0300
Message-ID: <1434976961-27424-13-git-send-email-haggaie@mellanox.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434976961-27424-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Now that there are no ib_cm clients using the compare_data feature for
matching IB CM requests' private data, remove the compare_data parameter of
ib_cm_listen and remove the code implementing the feature.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cm.c            | 105 ++++++--------------------------
 drivers/infiniband/core/ucm.c           |   3 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c |   2 +-
 drivers/infiniband/ulp/srpt/ib_srpt.c   |   2 +-
 include/rdma/ib_cm.h                    |  14 +----
 5 files changed, 22 insertions(+), 104 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 6d91bf69b11a..411c08b0c743 100644
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
@@ -927,7 +880,6 @@ retest:
 	wait_for_completion(&cm_id_priv->comp);
 	while ((work = cm_dequeue_work(cm_id_priv)) != NULL)
 		cm_free_work(work);
-	kfree(cm_id_priv->compare_data);
 	kfree(cm_id_priv->private_data);
 	kfree(cm_id_priv);
 }
@@ -950,20 +902,11 @@ EXPORT_SYMBOL(ib_destroy_cm_id);
  *   range of service IDs.  If set to 0, the service ID is matched
  *   exactly.  This parameter is ignored if %service_id is set to
  *   IB_CM_ASSIGN_SERVICE_ID.
- * @compare_data: This parameter is optional.  It specifies data that must
- *   appear in the private data of a connection request for the specified
- *   listen request.
- * @lock: If set, lock the cm.lock spin-lock when adding the id to the
- *   listener tree. When false, the caller must already hold the spin-lock,
- *   and compare_data must be NULL.
  */
 static int __ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id,
-			  __be64 service_mask,
-			  struct ib_cm_compare_data *compare_data,
-			  bool lock)
+			  __be64 service_mask)
 {
 	struct cm_id_private *cm_id_priv, *cur_cm_id_priv;
-	unsigned long flags = 0;
 	int ret = 0;
 
 	service_mask = service_mask ? service_mask : ~cpu_to_be64(0);
@@ -976,22 +919,9 @@ static int __ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id,
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
 	++cm_id_priv->listen_sharecount;
 
-	if (lock)
-		spin_lock_irqsave(&cm.lock, flags);
 	if (service_id == IB_CM_ASSIGN_SERVICE_ID) {
 		cm_id->service_id = cpu_to_be64(cm.listen_service_id++);
 		cm_id->service_mask = ~cpu_to_be64(0);
@@ -1000,24 +930,25 @@ static int __ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id,
 		cm_id->service_mask = service_mask;
 	}
 	cur_cm_id_priv = cm_insert_listen(cm_id_priv);
-	if (lock)
-		spin_unlock_irqrestore(&cm.lock, flags);
 
 	if (cur_cm_id_priv) {
 		cm_id->state = IB_CM_IDLE;
 		--cm_id_priv->listen_sharecount;
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
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&cm.lock, flags);
+	ret = __ib_cm_listen(cm_id, service_id, service_mask);
+	spin_unlock_irqrestore(&cm.lock, flags);
+
+	return ret;
 }
 EXPORT_SYMBOL(ib_cm_listen);
 
@@ -1061,7 +992,7 @@ struct ib_cm_id *ib_cm_insert_listen(struct ib_device *device,
 		goto new_id;
 
 	/* Find an existing ID */
-	cm_id_priv = cm_find_listen(device, service_id, NULL);
+	cm_id_priv = cm_find_listen(device, service_id);
 	if (cm_id_priv) {
 		if (cm_id->cm_handler != cm_handler || cm_id->context) {
 			/* Sharing an ib_cm_id with different handlers is not
@@ -1080,7 +1011,7 @@ struct ib_cm_id *ib_cm_insert_listen(struct ib_device *device,
 
 new_id:
 	/* Use newly created ID */
-	err = __ib_cm_listen(cm_id, service_id, service_mask, NULL, false);
+	err = __ib_cm_listen(cm_id, service_id, service_mask);
 
 	spin_unlock_irqrestore(&cm.lock, flags);
 
@@ -1586,8 +1517,7 @@ static struct cm_id_private * cm_match_req(struct cm_work *work,
 
 	/* Find matching listen request. */
 	listen_cm_id_priv = cm_find_listen(cm_id_priv->id.device,
-					   req_msg->service_id,
-					   req_msg->private_data);
+					   req_msg->service_id);
 	if (!listen_cm_id_priv) {
 		cm_cleanup_timewait(cm_id_priv->timewait_info);
 		spin_unlock_irq(&cm.lock);
@@ -3134,8 +3064,7 @@ static int cm_sidr_req_handler(struct cm_work *work)
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
index 2ce29cd43639..2c20f076c84f 100644
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
index 54da6e8ddfa1..7cc65784dae2 100644
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
index f7fd22f10bae..c2be7c050bc0 100644
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
@@ -338,11 +336,6 @@ void ib_destroy_cm_id(struct ib_cm_id *cm_id);
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
@@ -355,12 +348,9 @@ struct ib_cm_compare_data {
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
 
 struct ib_cm_id *ib_cm_insert_listen(struct ib_device *device,
 				     ib_cm_handler cm_handler,
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in

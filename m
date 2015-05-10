From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Sun, 10 May 2015 13:26:36 +0300
Message-ID: <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:49340 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752199AbbEJK1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 06:27:21 -0400
In-Reply-To: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add reference count (kref) to the ib_cm_id to allow automatic destruction
of an ib_cm_id. This will allow multiple RDMA CM IDs to use a single
ib_cm_id when they are on different network namespaces.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 drivers/infiniband/core/cm.c | 41 +++++++++++++++++++++++++++++++++++++----
 include/rdma/ib_cm.h         | 10 +++++++---
 2 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 08b18044552a..6b68402fd6df 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -711,6 +711,7 @@ struct ib_cm_id *ib_create_cm_id(struct ib_device *device,
 	cm_id_priv->id.cm_handler = cm_handler;
 	cm_id_priv->id.context = context;
 	cm_id_priv->id.remote_cm_qpn = 1;
+	kref_init(&cm_id_priv->id.ref);
 	ret = cm_alloc_id(cm_id_priv);
 	if (ret)
 		goto error;
@@ -921,10 +922,42 @@ retest:
 	kfree(cm_id_priv);
 }
 
-void ib_destroy_cm_id(struct ib_cm_id *cm_id)
+static void __ib_destroy_cm_id(struct kref *ref)
 {
+	struct ib_cm_id *cm_id = container_of(ref, struct ib_cm_id, ref);
+
 	cm_destroy_id(cm_id, 0);
 }
+
+/**
+ * ib_cm_id_get - Increase the reference count on an existing ib_cm_id.
+ * @cm_id: Connection identifier to take reference of
+ */
+void ib_cm_id_get(struct ib_cm_id *cm_id)
+{
+	kref_get(&cm_id->ref);
+}
+EXPORT_SYMBOL(ib_cm_id_get);
+
+/**
+ * ib_cm_id_put - Release a connection identifier.
+ * @cm_id: Connection identifier to release
+ *
+ * This call may block until the connection identifier is destroyed.
+ * Returns 1 if the ib_cm_id has been destroyed
+ */
+int ib_cm_id_put(struct ib_cm_id *cm_id)
+{
+	return kref_put(&cm_id->ref, __ib_destroy_cm_id);
+}
+EXPORT_SYMBOL(ib_cm_id_put);
+
+void ib_destroy_cm_id(struct ib_cm_id *cm_id)
+{
+	int destroyed = ib_cm_id_put(cm_id);
+
+	WARN_ON_ONCE(!destroyed);
+}
 EXPORT_SYMBOL(ib_destroy_cm_id);
 
 int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
@@ -1603,7 +1636,7 @@ rejected:
 	atomic_dec(&cm_id_priv->refcount);
 	cm_deref_id(listen_cm_id_priv);
 destroy:
-	ib_destroy_cm_id(cm_id);
+	ib_cm_id_put(cm_id);
 	return ret;
 }
 
@@ -3038,7 +3071,7 @@ static int cm_sidr_req_handler(struct cm_work *work)
 	cm_deref_id(cur_cm_id_priv);
 	return 0;
 out:
-	ib_destroy_cm_id(&cm_id_priv->id);
+	ib_cm_id_put(&cm_id_priv->id);
 	return -EINVAL;
 }
 
@@ -3197,7 +3230,7 @@ static void cm_process_send_error(struct ib_mad_send_buf *msg,
 	ret = cm_id_priv->id.cm_handler(&cm_id_priv->id, &cm_event);
 	cm_free_msg(msg);
 	if (ret)
-		ib_destroy_cm_id(&cm_id_priv->id);
+		ib_cm_id_put(&cm_id_priv->id);
 	return;
 discard:
 	spin_unlock_irq(&cm_id_priv->lock);
diff --git a/include/rdma/ib_cm.h b/include/rdma/ib_cm.h
index 39ed2d2fbd51..22da34de3bc7 100644
--- a/include/rdma/ib_cm.h
+++ b/include/rdma/ib_cm.h
@@ -287,9 +287,9 @@ struct ib_cm_event {
  * IB_CM_REQ_RECEIVED and all other events, the returned @cm_id corresponds
  * to a user's existing communication identifier.
  *
- * Users may not call ib_destroy_cm_id while in the context of this callback;
- * however, returning a non-zero value instructs the communication manager to
- * destroy the @cm_id after the callback completes.
+ * Users may not call ib_destroy_cm_id or ib_cm_id_put while in the context of
+ * this callback; however, returning a non-zero value instructs the
+ * communication manager to destroy the @cm_id after the callback completes.
  */
 typedef int (*ib_cm_handler)(struct ib_cm_id *cm_id,
 			     struct ib_cm_event *event);
@@ -305,6 +305,7 @@ struct ib_cm_id {
 	__be32			local_id;
 	__be32			remote_id;
 	u32			remote_cm_qpn;  /* 1 unless redirected */
+	struct kref		ref;
 };
 
 /**
@@ -330,6 +331,9 @@ struct ib_cm_id *ib_create_cm_id(struct ib_device *device,
  */
 void ib_destroy_cm_id(struct ib_cm_id *cm_id);
 
+void ib_cm_id_get(struct ib_cm_id *cm_id);
+int ib_cm_id_put(struct ib_cm_id *cm_id);
+
 #define IB_SERVICE_ID_AGN_MASK	cpu_to_be64(0xFF00000000000000ULL)
 #define IB_CM_ASSIGN_SERVICE_ID	cpu_to_be64(0x0200000000000000ULL)
 #define IB_CMA_SERVICE_ID	cpu_to_be64(0x0000000001000000ULL)
-- 
1.7.11.2

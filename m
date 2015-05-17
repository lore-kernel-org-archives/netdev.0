From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v4 for-next 05/12] IB/cm: Share listening CM IDs
Date: Sun, 17 May 2015 08:51:01 +0300
Message-ID: <1431841868-28063-6-git-send-email-haggaie@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:34518 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751967AbbEQFwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2015 01:52:31 -0400
In-Reply-To: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enabling network namespaces for RDMA CM will allow processes on different
namespaces to listen on the same port. In order to leave namespace support
out of the CM layer, this requires that multiple RDMA CM IDs will be able
to share a single CM ID.

This patch adds infrastructure to retrieve an existing listening ib_cm_id,
based on its device and service ID, or create a new one if one does not
already exist. It also adds a reference count for such instances
(cm_id_private.sharecount), and prevents cm_destroy_id from destroying a CM
if it is still shared. See the relevant discussion [1].

[1] Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
    http://www.spinics.net/lists/netdev/msg328860.html

Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 drivers/infiniband/core/cm.c | 121 +++++++++++++++++++++++++++++++++++++++++--
 include/rdma/ib_cm.h         |   4 ++
 2 files changed, 120 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 14423c20c55b..4f936932dd54 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -212,6 +212,8 @@ struct cm_id_private {
 	spinlock_t lock;	/* Do not acquire inside cm.lock */
 	struct completion comp;
 	atomic_t refcount;
+	/* Number of clients sharing this ib_cm_id. Only valid for listeners. */
+	atomic_t sharecount;
 
 	struct ib_mad_send_buf *msg;
 	struct cm_timewait_info *timewait_info;
@@ -720,6 +722,7 @@ struct ib_cm_id *ib_create_cm_id(struct ib_device *device,
 	INIT_LIST_HEAD(&cm_id_priv->work_list);
 	atomic_set(&cm_id_priv->work_count, -1);
 	atomic_set(&cm_id_priv->refcount, 1);
+	atomic_set(&cm_id_priv->sharecount, 1);
 	return &cm_id_priv->id;
 
 error:
@@ -841,6 +844,12 @@ static void cm_destroy_id(struct ib_cm_id *cm_id, int err)
 	struct cm_work *work;
 
 	cm_id_priv = container_of(cm_id, struct cm_id_private, id);
+
+	if (!atomic_dec_and_test(&cm_id_priv->sharecount)) {
+		/* The id is still shared. */
+		return;
+	}
+
 retest:
 	spin_lock_irq(&cm_id_priv->lock);
 	switch (cm_id->state) {
@@ -927,11 +936,32 @@ void ib_destroy_cm_id(struct ib_cm_id *cm_id)
 }
 EXPORT_SYMBOL(ib_destroy_cm_id);
 
-int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
-		 struct ib_cm_compare_data *compare_data)
+/**
+ * __ib_cm_listen - Initiates listening on the specified service ID for
+ *   connection and service ID resolution requests.
+ * @cm_id: Connection identifier associated with the listen request.
+ * @service_id: Service identifier matched against incoming connection
+ *   and service ID resolution requests.  The service ID should be specified
+ *   network-byte order.  If set to IB_CM_ASSIGN_SERVICE_ID, the CM will
+ *   assign a service ID to the caller.
+ * @service_mask: Mask applied to service ID used to listen across a
+ *   range of service IDs.  If set to 0, the service ID is matched
+ *   exactly.  This parameter is ignored if %service_id is set to
+ *   IB_CM_ASSIGN_SERVICE_ID.
+ * @compare_data: This parameter is optional.  It specifies data that must
+ *   appear in the private data of a connection request for the specified
+ *   listen request.
+ * @lock: If set, lock the cm.lock spin-lock when adding the id to the
+ *   listener tree. When false, the caller must already hold the spin-lock,
+ *   and compare_data must be NULL.
+ */
+static int __ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id,
+			  __be64 service_mask,
+			  struct ib_cm_compare_data *compare_data,
+			  bool lock)
 {
 	struct cm_id_private *cm_id_priv, *cur_cm_id_priv;
-	unsigned long flags;
+	unsigned long flags = 0;
 	int ret = 0;
 
 	service_mask = service_mask ? service_mask : ~cpu_to_be64(0);
@@ -957,7 +987,8 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
 
 	cm_id->state = IB_CM_LISTEN;
 
-	spin_lock_irqsave(&cm.lock, flags);
+	if (lock)
+		spin_lock_irqsave(&cm.lock, flags);
 	if (service_id == IB_CM_ASSIGN_SERVICE_ID) {
 		cm_id->service_id = cpu_to_be64(cm.listen_service_id++);
 		cm_id->service_mask = ~cpu_to_be64(0);
@@ -966,7 +997,8 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
 		cm_id->service_mask = service_mask;
 	}
 	cur_cm_id_priv = cm_insert_listen(cm_id_priv);
-	spin_unlock_irqrestore(&cm.lock, flags);
+	if (lock)
+		spin_unlock_irqrestore(&cm.lock, flags);
 
 	if (cur_cm_id_priv) {
 		cm_id->state = IB_CM_IDLE;
@@ -976,8 +1008,87 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
 	}
 	return ret;
 }
+
+int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
+		 struct ib_cm_compare_data *compare_data)
+{
+	return __ib_cm_listen(cm_id, service_id, service_mask, compare_data,
+			      true);
+}
 EXPORT_SYMBOL(ib_cm_listen);
 
+/**
+ * Create a new listening ib_cm_id and listen on the given service ID.
+ *
+ * If there's an existing ID listening on that same device and service ID,
+ * return it.
+ *
+ * @device: Device associated with the cm_id.  All related communication will
+ * be associated with the specified device.
+ * @cm_handler: Callback invoked to notify the user of CM events.
+ * @service_id: Service identifier matched against incoming connection
+ *   and service ID resolution requests.  The service ID should be specified
+ *   network-byte order.  If set to IB_CM_ASSIGN_SERVICE_ID, the CM will
+ *   assign a service ID to the caller.
+ * @service_mask: Mask applied to service ID used to listen across a
+ *   range of service IDs.  If set to 0, the service ID is matched
+ *   exactly.  This parameter is ignored if %service_id is set to
+ *   IB_CM_ASSIGN_SERVICE_ID.
+ */
+struct ib_cm_id *ib_cm_id_create_and_listen(
+		struct ib_device *device,
+		ib_cm_handler cm_handler,
+		__be64 service_id,
+		__be64 service_mask)
+{
+	struct cm_id_private *cm_id_priv;
+	struct ib_cm_id *cm_id;
+	unsigned long flags;
+	int err = 0;
+
+	/* Create an ID in advance, since the creation may sleep */
+	cm_id = ib_create_cm_id(device, cm_handler, NULL);
+	if (IS_ERR(cm_id))
+		return cm_id;
+
+	spin_lock_irqsave(&cm.lock, flags);
+
+	if (service_id == IB_CM_ASSIGN_SERVICE_ID)
+		goto new_id;
+
+	/* Find an existing ID */
+	cm_id_priv = cm_find_listen(device, service_id, NULL);
+	if (cm_id_priv) {
+		if (atomic_inc_return(&cm_id_priv->sharecount) == 1) {
+			/* This ID is already being destroyed */
+			atomic_dec(&cm_id_priv->sharecount);
+			goto new_id;
+		}
+
+		spin_unlock_irqrestore(&cm.lock, flags);
+		ib_destroy_cm_id(cm_id);
+		cm_id = &cm_id_priv->id;
+		if (cm_id->cm_handler != cm_handler || cm_id->context)
+			/* Sharing an ib_cm_id with different handlers is not
+			 * supported */
+			return ERR_PTR(-EINVAL);
+		return cm_id;
+	}
+
+new_id:
+	/* Use newly created ID */
+	err = __ib_cm_listen(cm_id, service_id, service_mask, NULL, false);
+
+	spin_unlock_irqrestore(&cm.lock, flags);
+
+	if (err) {
+		ib_destroy_cm_id(cm_id);
+		return ERR_PTR(err);
+	}
+	return cm_id;
+}
+EXPORT_SYMBOL(ib_cm_id_create_and_listen);
+
 static __be64 cm_form_tid(struct cm_id_private *cm_id_priv,
 			  enum cm_msg_sequence msg_seq)
 {
diff --git a/include/rdma/ib_cm.h b/include/rdma/ib_cm.h
index 39ed2d2fbd51..59f534b5f091 100644
--- a/include/rdma/ib_cm.h
+++ b/include/rdma/ib_cm.h
@@ -361,6 +361,10 @@ struct ib_cm_compare_data {
 int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
 		 struct ib_cm_compare_data *compare_data);
 
+struct ib_cm_id *ib_cm_id_create_and_listen(
+		struct ib_device *device, ib_cm_handler cm_handler,
+		__be64 service_id, __be64 service_mask);
+
 struct ib_cm_req_param {
 	struct ib_sa_path_rec	*primary_path;
 	struct ib_sa_path_rec	*alternate_path;
-- 
1.7.11.2

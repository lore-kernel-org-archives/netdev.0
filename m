From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v3 for-next 06/13] IB/cm: API to retrieve existing listening CM IDs
Date: Sun, 10 May 2015 13:26:37 +0300
Message-ID: <1431253604-9214-7-git-send-email-haggaie@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1431253604-9214-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Enabling network namespaces for RDMA CM will allow processes on different
namespaces to listen on the same port. In order to leave namespace support
out of the CM layer, this requires that multiple RDMA CM IDs will be able
to share a single CM ID.

This patch adds infrastructure to retrieve an existing listening ib_cm_id,
based on its device and service ID, or create a new one if one does not
already exist.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cm.c | 104 ++++++++++++++++++++++++++++++++++++++++---
 include/rdma/ib_cm.h         |   4 ++
 2 files changed, 103 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 6b68402fd6df..0be96a19734d 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -960,11 +960,32 @@ void ib_destroy_cm_id(struct ib_cm_id *cm_id)
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
@@ -990,7 +1011,8 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
 
 	cm_id->state = IB_CM_LISTEN;
 
-	spin_lock_irqsave(&cm.lock, flags);
+	if (lock)
+		spin_lock_irqsave(&cm.lock, flags);
 	if (service_id == IB_CM_ASSIGN_SERVICE_ID) {
 		cm_id->service_id = cpu_to_be64(cm.listen_service_id++);
 		cm_id->service_mask = ~cpu_to_be64(0);
@@ -999,7 +1021,8 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
 		cm_id->service_mask = service_mask;
 	}
 	cur_cm_id_priv = cm_insert_listen(cm_id_priv);
-	spin_unlock_irqrestore(&cm.lock, flags);
+	if (lock)
+		spin_unlock_irqrestore(&cm.lock, flags);
 
 	if (cur_cm_id_priv) {
 		cm_id->state = IB_CM_IDLE;
@@ -1009,8 +1032,79 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
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
+	if (service_id != IB_CM_ASSIGN_SERVICE_ID) {
+		/* Find an existing ID */
+		cm_id_priv = cm_find_listen(device, service_id, NULL);
+		if (cm_id_priv) {
+			spin_unlock_irqrestore(&cm.lock, flags);
+			ib_cm_id_put(cm_id);
+			cm_id = &cm_id_priv->id;
+			if (cm_id->cm_handler != cm_handler ||
+			    cm_id->context)
+				return ERR_PTR(-EINVAL);
+			ib_cm_id_get(cm_id);
+			return cm_id;
+		}
+	}
+
+	/* Use newly created ID */
+	err = __ib_cm_listen(cm_id, service_id, service_mask, NULL, false);
+
+	spin_unlock_irqrestore(&cm.lock, flags);
+
+	if (err) {
+		ib_cm_id_put(cm_id);
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
index 22da34de3bc7..4a17394bb556 100644
--- a/include/rdma/ib_cm.h
+++ b/include/rdma/ib_cm.h
@@ -365,6 +365,10 @@ struct ib_cm_compare_data {
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

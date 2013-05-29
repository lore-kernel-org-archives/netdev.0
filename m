From: sean.hefty@intel.com
Subject: [PATCH v5 17/28] rdma/cm: Set qkey for AF_IB
Date: Wed, 29 May 2013 10:09:23 -0700
Message-ID: <1369847374-12176-18-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
To: roland@purestorage.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33953 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759640Ab3E2RJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 13:09:56 -0400
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Hefty <sean.hefty@intel.com>

Allow the user to specify the qkey when using AF_IB.  The
qkey is added to struct rdma_ucm_conn_param in place of a reserved
field, but for backwards compatability, is only accessed if the
associated rdma_cm_id is using AF_IB.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
 drivers/infiniband/core/cma.c    |   35 +++++++++++++++++++++--------------
 drivers/infiniband/core/ucma.c   |    8 +++++---
 include/rdma/rdma_cm.h           |    1 +
 include/uapi/rdma/rdma_user_cm.h |    2 +-
 4 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index a807b18..6ea5ce7 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -293,16 +293,25 @@ static inline unsigned short cma_family(struct rdma_id_private *id_priv)
 	return id_priv->id.route.addr.src_addr.ss_family;
 }
 
-static int cma_set_qkey(struct rdma_id_private *id_priv)
+static int cma_set_qkey(struct rdma_id_private *id_priv, u32 qkey)
 {
 	struct ib_sa_mcmember_rec rec;
 	int ret = 0;
 
-	if (id_priv->qkey)
+	if (id_priv->qkey) {
+		if (qkey && id_priv->qkey != qkey)
+			return -EINVAL;
 		return 0;
+	}
+
+	if (qkey) {
+		id_priv->qkey = qkey;
+		return 0;
+	}
 
 	switch (id_priv->id.ps) {
 	case RDMA_PS_UDP:
+	case RDMA_PS_IB:
 		id_priv->qkey = RDMA_UDP_QKEY;
 		break;
 	case RDMA_PS_IPOIB:
@@ -689,7 +698,7 @@ static int cma_ib_init_qp_attr(struct rdma_id_private *id_priv,
 	*qp_attr_mask = IB_QP_STATE | IB_QP_PKEY_INDEX | IB_QP_PORT;
 
 	if (id_priv->id.qp_type == IB_QPT_UD) {
-		ret = cma_set_qkey(id_priv);
+		ret = cma_set_qkey(id_priv, 0);
 		if (ret)
 			return ret;
 
@@ -2624,15 +2633,10 @@ static int cma_sidr_rep_handler(struct ib_cm_id *cm_id,
 			event.status = ib_event->param.sidr_rep_rcvd.status;
 			break;
 		}
-		ret = cma_set_qkey(id_priv);
+		ret = cma_set_qkey(id_priv, rep->qkey);
 		if (ret) {
 			event.event = RDMA_CM_EVENT_ADDR_ERROR;
-			event.status = -EINVAL;
-			break;
-		}
-		if (id_priv->qkey != rep->qkey) {
-			event.event = RDMA_CM_EVENT_UNREACHABLE;
-			event.status = -EINVAL;
+			event.status = ret;
 			break;
 		}
 		ib_init_ah_from_path(id_priv->id.device, id_priv->id.port_num,
@@ -2922,7 +2926,7 @@ static int cma_accept_iw(struct rdma_id_private *id_priv,
 }
 
 static int cma_send_sidr_rep(struct rdma_id_private *id_priv,
-			     enum ib_cm_sidr_status status,
+			     enum ib_cm_sidr_status status, u32 qkey,
 			     const void *private_data, int private_data_len)
 {
 	struct ib_cm_sidr_rep_param rep;
@@ -2931,7 +2935,7 @@ static int cma_send_sidr_rep(struct rdma_id_private *id_priv,
 	memset(&rep, 0, sizeof rep);
 	rep.status = status;
 	if (status == IB_SIDR_SUCCESS) {
-		ret = cma_set_qkey(id_priv);
+		ret = cma_set_qkey(id_priv, qkey);
 		if (ret)
 			return ret;
 		rep.qp_num = id_priv->qp_num;
@@ -2965,11 +2969,12 @@ int rdma_accept(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
 		if (id->qp_type == IB_QPT_UD) {
 			if (conn_param)
 				ret = cma_send_sidr_rep(id_priv, IB_SIDR_SUCCESS,
+							conn_param->qkey,
 							conn_param->private_data,
 							conn_param->private_data_len);
 			else
 				ret = cma_send_sidr_rep(id_priv, IB_SIDR_SUCCESS,
-							NULL, 0);
+							0, NULL, 0);
 		} else {
 			if (conn_param)
 				ret = cma_accept_ib(id_priv, conn_param);
@@ -3030,7 +3035,7 @@ int rdma_reject(struct rdma_cm_id *id, const void *private_data,
 	switch (rdma_node_get_transport(id->device->node_type)) {
 	case RDMA_TRANSPORT_IB:
 		if (id->qp_type == IB_QPT_UD)
-			ret = cma_send_sidr_rep(id_priv, IB_SIDR_REJECT,
+			ret = cma_send_sidr_rep(id_priv, IB_SIDR_REJECT, 0,
 						private_data, private_data_len);
 		else
 			ret = ib_send_cm_rej(id_priv->cm_id.ib,
@@ -3091,6 +3096,8 @@ static int cma_ib_mc_handler(int status, struct ib_sa_multicast *multicast)
 	    cma_disable_callback(id_priv, RDMA_CM_ADDR_RESOLVED))
 		return 0;
 
+	if (!status)
+		status = cma_set_qkey(id_priv, be32_to_cpu(multicast->rec.qkey));
 	mutex_lock(&id_priv->qp_mutex);
 	if (!status && id_priv->id.qp)
 		status = ib_attach_mcast(id_priv->id.qp, &multicast->rec.mgid,
diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 5ca44cd..e813774 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -709,7 +709,8 @@ out:
 	return ret;
 }
 
-static void ucma_copy_conn_param(struct rdma_conn_param *dst,
+static void ucma_copy_conn_param(struct rdma_cm_id *id,
+				 struct rdma_conn_param *dst,
 				 struct rdma_ucm_conn_param *src)
 {
 	dst->private_data = src->private_data;
@@ -721,6 +722,7 @@ static void ucma_copy_conn_param(struct rdma_conn_param *dst,
 	dst->rnr_retry_count = src->rnr_retry_count;
 	dst->srq = src->srq;
 	dst->qp_num = src->qp_num;
+	dst->qkey = (id->route.addr.src_addr.ss_family == AF_IB) ? src->qkey : 0;
 }
 
 static ssize_t ucma_connect(struct ucma_file *file, const char __user *inbuf,
@@ -741,7 +743,7 @@ static ssize_t ucma_connect(struct ucma_file *file, const char __user *inbuf,
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
-	ucma_copy_conn_param(&conn_param, &cmd.conn_param);
+	ucma_copy_conn_param(ctx->cm_id, &conn_param, &cmd.conn_param);
 	ret = rdma_connect(ctx->cm_id, &conn_param);
 	ucma_put_ctx(ctx);
 	return ret;
@@ -784,7 +786,7 @@ static ssize_t ucma_accept(struct ucma_file *file, const char __user *inbuf,
 		return PTR_ERR(ctx);
 
 	if (cmd.conn_param.valid) {
-		ucma_copy_conn_param(&conn_param, &cmd.conn_param);
+		ucma_copy_conn_param(ctx->cm_id, &conn_param, &cmd.conn_param);
 		mutex_lock(&file->mut);
 		ret = rdma_accept(ctx->cm_id, &conn_param);
 		if (!ret)
diff --git a/include/rdma/rdma_cm.h b/include/rdma/rdma_cm.h
index 1e6c3c7..966f90b 100644
--- a/include/rdma/rdma_cm.h
+++ b/include/rdma/rdma_cm.h
@@ -98,6 +98,7 @@ struct rdma_conn_param {
 	/* Fields below ignored if a QP is created on the rdma_cm_id. */
 	u8 srq;
 	u32 qp_num;
+	u32 qkey;
 };
 
 struct rdma_ud_param {
diff --git a/include/uapi/rdma/rdma_user_cm.h b/include/uapi/rdma/rdma_user_cm.h
index 1ee9239..29de08f 100644
--- a/include/uapi/rdma/rdma_user_cm.h
+++ b/include/uapi/rdma/rdma_user_cm.h
@@ -131,7 +131,7 @@ struct rdma_ucm_query_route_resp {
 
 struct rdma_ucm_conn_param {
 	__u32 qp_num;
-	__u32 reserved;
+	__u32 qkey;
 	__u8  private_data[RDMA_MAX_PRIVATE_DATA];
 	__u8  private_data_len;
 	__u8  srq;
-- 
1.7.3

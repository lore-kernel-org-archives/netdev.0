From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 14/26 v3] rdma/cm: Set qkey for AF_IB
Date: Mon, 24 Sep 2012 23:55:33 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F109@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43083 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765Ab2IXXzf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:35 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the user to specify the qkey when using AF_IB.  The
qkey is added to struct rdma_ucm_conn_param in place of a reserved
field, but for backwards compatability, is only accessed if the
associated rdma_cm_id is using AF_IB.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/cma.c  |   35 +++++++++++++++++++++--------------
 drivers/infiniband/core/ucma.c |    8 +++++---
 include/rdma/rdma_cm.h         |    1 +
 include/rdma/rdma_user_cm.h    |    2 +-
 4 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 1264e97..13423bb 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -320,16 +320,25 @@ static inline unsigned short cma_family(struct rdma_id_private *id_priv)
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
@@ -717,7 +726,7 @@ static int cma_ib_init_qp_attr(struct rdma_id_private *id_priv,
 	*qp_attr_mask = IB_QP_STATE | IB_QP_PKEY_INDEX | IB_QP_PORT;
 
 	if (id_priv->id.qp_type == IB_QPT_UD) {
-		ret = cma_set_qkey(id_priv);
+		ret = cma_set_qkey(id_priv, 0);
 		if (ret)
 			return ret;
 
@@ -2687,15 +2696,10 @@ static int cma_sidr_rep_handler(struct ib_cm_id *cm_id,
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
@@ -2973,7 +2977,7 @@ static int cma_accept_iw(struct rdma_id_private *id_priv,
 }
 
 static int cma_send_sidr_rep(struct rdma_id_private *id_priv,
-			     enum ib_cm_sidr_status status,
+			     enum ib_cm_sidr_status status, u32 qkey,
 			     const void *private_data, int private_data_len)
 {
 	struct ib_cm_sidr_rep_param rep;
@@ -2982,7 +2986,7 @@ static int cma_send_sidr_rep(struct rdma_id_private *id_priv,
 	memset(&rep, 0, sizeof rep);
 	rep.status = status;
 	if (status == IB_SIDR_SUCCESS) {
-		ret = cma_set_qkey(id_priv);
+		ret = cma_set_qkey(id_priv, qkey);
 		if (ret)
 			return ret;
 		rep.qp_num = id_priv->qp_num;
@@ -3016,11 +3020,12 @@ int rdma_accept(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
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
@@ -3081,7 +3086,7 @@ int rdma_reject(struct rdma_cm_id *id, const void *private_data,
 	switch (rdma_node_get_transport(id->device->node_type)) {
 	case RDMA_TRANSPORT_IB:
 		if (id->qp_type == IB_QPT_UD)
-			ret = cma_send_sidr_rep(id_priv, IB_SIDR_REJECT,
+			ret = cma_send_sidr_rep(id_priv, IB_SIDR_REJECT, 0,
 						private_data, private_data_len);
 		else
 			ret = ib_send_cm_rej(id_priv->cm_id.ib,
@@ -3142,6 +3147,8 @@ static int cma_ib_mc_handler(int status, struct ib_sa_multicast *multicast)
 	    cma_disable_callback(id_priv, RDMA_CM_ADDR_RESOLVED))
 		return 0;
 
+	if (!status)
+		status = cma_set_qkey(id_priv, be32_to_cpu(multicast->rec.qkey));
 	mutex_lock(&id_priv->qp_mutex);
 	if (!status && id_priv->id.qp)
 		status = ib_attach_mcast(id_priv->id.qp, &multicast->rec.mgid,
diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 8002ae6..52c606b 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -726,7 +726,8 @@ out:
 	return ret;
 }
 
-static void ucma_copy_conn_param(struct rdma_conn_param *dst,
+static void ucma_copy_conn_param(struct rdma_cm_id *id,
+				 struct rdma_conn_param *dst,
 				 struct rdma_ucm_conn_param *src)
 {
 	dst->private_data = src->private_data;
@@ -738,6 +739,7 @@ static void ucma_copy_conn_param(struct rdma_conn_param *dst,
 	dst->rnr_retry_count = src->rnr_retry_count;
 	dst->srq = src->srq;
 	dst->qp_num = src->qp_num;
+	dst->qkey = (id->route.addr.src_addr.ss_family == AF_IB) ? src->qkey : 0;
 }
 
 static ssize_t ucma_connect(struct ucma_file *file, const char __user *inbuf,
@@ -758,7 +760,7 @@ static ssize_t ucma_connect(struct ucma_file *file, const char __user *inbuf,
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
-	ucma_copy_conn_param(&conn_param, &cmd.conn_param);
+	ucma_copy_conn_param(ctx->cm_id, &conn_param, &cmd.conn_param);
 	ret = rdma_connect(ctx->cm_id, &conn_param);
 	ucma_put_ctx(ctx);
 	return ret;
@@ -801,7 +803,7 @@ static ssize_t ucma_accept(struct ucma_file *file, const char __user *inbuf,
 		return PTR_ERR(ctx);
 
 	if (cmd.conn_param.valid) {
-		ucma_copy_conn_param(&conn_param, &cmd.conn_param);
+		ucma_copy_conn_param(ctx->cm_id, &conn_param, &cmd.conn_param);
 		mutex_lock(&file->mut);
 		ret = rdma_accept(ctx->cm_id, &conn_param);
 		if (!ret)
diff --git a/include/rdma/rdma_cm.h b/include/rdma/rdma_cm.h
index 5eb3179..0bb190f 100644
--- a/include/rdma/rdma_cm.h
+++ b/include/rdma/rdma_cm.h
@@ -98,6 +98,7 @@ struct rdma_conn_param {
 	/* Fields below ignored if a QP is created on the rdma_cm_id. */
 	u8 srq;
 	u32 qp_num;
+	u32 qkey;
 };
 
 struct rdma_ud_param {
diff --git a/include/rdma/rdma_user_cm.h b/include/rdma/rdma_user_cm.h
index 5348a00..ca8d4d4 100644
--- a/include/rdma/rdma_user_cm.h
+++ b/include/rdma/rdma_user_cm.h
@@ -131,7 +131,7 @@ struct rdma_ucm_query_route_resp {
 
 struct rdma_ucm_conn_param {
 	__u32 qp_num;
-	__u32 reserved;
+	__u32 qkey;
 	__u8  private_data[RDMA_MAX_PRIVATE_DATA];
 	__u8  private_data_len;
 	__u8  srq;

From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v5 16/28] rdma/cm: Expose private data when using AF_IB
Date: Wed, 29 May 2013 10:09:22 -0700
Message-ID: <1369847374-12176-17-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

If the source or destination address is AF_IB, then do not
reserve a portion of the private data in the IB CM REQ or SIDR
REQ messages for the cma header.  Instead, all private data
should be exported to the user.  When AF_IB is used, the
rdma cm does not have sufficient information to fill in the
cma header.  Additionally, this will be necessary to support
any IB connection through the rdma cm interface,

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |   56 +++++++++++++++++++++++++----------------
 1 files changed, 34 insertions(+), 22 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 69217f5..a807b18 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -893,9 +893,9 @@ static int cma_save_net_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id
 	return 0;
 }
 
-static inline int cma_user_data_offset(enum rdma_port_space ps)
+static inline int cma_user_data_offset(struct rdma_id_private *id_priv)
 {
-	return sizeof(struct cma_hdr);
+	return cma_family(id_priv) == AF_IB ? 0 : sizeof(struct cma_hdr);
 }
 
 static void cma_cancel_route(struct rdma_id_private *id_priv)
@@ -1265,7 +1265,7 @@ static int cma_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *ib_event)
 		return -ECONNABORTED;
 
 	memset(&event, 0, sizeof event);
-	offset = cma_user_data_offset(listen_id->id.ps);
+	offset = cma_user_data_offset(listen_id);
 	event.event = RDMA_CM_EVENT_CONNECT_REQUEST;
 	if (ib_event->event == IB_CM_SIDR_REQ_RECEIVED) {
 		conn_id = cma_new_udp_id(&listen_id->id, ib_event);
@@ -2585,7 +2585,7 @@ static int cma_format_hdr(void *hdr, struct rdma_id_private *id_priv)
 		cma_hdr->src_addr.ip4.addr = src4->sin_addr.s_addr;
 		cma_hdr->dst_addr.ip4.addr = dst4->sin_addr.s_addr;
 		cma_hdr->port = src4->sin_port;
-	} else {
+	} else if (cma_family(id_priv) == AF_INET6) {
 		struct sockaddr_in6 *src6, *dst6;
 
 		src6 = (struct sockaddr_in6 *) cma_src_addr(id_priv);
@@ -2668,24 +2668,30 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
 {
 	struct ib_cm_sidr_req_param req;
 	struct ib_cm_id	*id;
-	int ret;
+	int offset, ret;
 
-	req.private_data_len = sizeof(struct cma_hdr) +
-			       conn_param->private_data_len;
+	offset = cma_user_data_offset(id_priv);
+	req.private_data_len = offset + conn_param->private_data_len;
 	if (req.private_data_len < conn_param->private_data_len)
 		return -EINVAL;
 
-	req.private_data = kzalloc(req.private_data_len, GFP_ATOMIC);
-	if (!req.private_data)
-		return -ENOMEM;
+	if (req.private_data_len) {
+		req.private_data = kzalloc(req.private_data_len, GFP_ATOMIC);
+		if (!req.private_data)
+			return -ENOMEM;
+	} else {
+		req.private_data = NULL;
+	}
 
 	if (conn_param->private_data && conn_param->private_data_len)
-		memcpy((void *) req.private_data + sizeof(struct cma_hdr),
+		memcpy((void *) req.private_data + offset,
 		       conn_param->private_data, conn_param->private_data_len);
 
-	ret = cma_format_hdr((void *) req.private_data, id_priv);
-	if (ret)
-		goto out;
+	if (req.private_data) {
+		ret = cma_format_hdr((void *) req.private_data, id_priv);
+		if (ret)
+			goto out;
+	}
 
 	id = ib_create_cm_id(id_priv->id.device, cma_sidr_rep_handler,
 			     id_priv);
@@ -2720,14 +2726,18 @@ static int cma_connect_ib(struct rdma_id_private *id_priv,
 	int offset, ret;
 
 	memset(&req, 0, sizeof req);
-	offset = cma_user_data_offset(id_priv->id.ps);
+	offset = cma_user_data_offset(id_priv);
 	req.private_data_len = offset + conn_param->private_data_len;
 	if (req.private_data_len < conn_param->private_data_len)
 		return -EINVAL;
 
-	private_data = kzalloc(req.private_data_len, GFP_ATOMIC);
-	if (!private_data)
-		return -ENOMEM;
+	if (req.private_data_len) {
+		private_data = kzalloc(req.private_data_len, GFP_ATOMIC);
+		if (!private_data)
+			return -ENOMEM;
+	} else {
+		private_data = NULL;
+	}
 
 	if (conn_param->private_data && conn_param->private_data_len)
 		memcpy(private_data + offset, conn_param->private_data,
@@ -2741,10 +2751,12 @@ static int cma_connect_ib(struct rdma_id_private *id_priv,
 	id_priv->cm_id.ib = id;
 
 	route = &id_priv->id.route;
-	ret = cma_format_hdr(private_data, id_priv);
-	if (ret)
-		goto out;
-	req.private_data = private_data;
+	if (private_data) {
+		ret = cma_format_hdr(private_data, id_priv);
+		if (ret)
+			goto out;
+		req.private_data = private_data;
+	}
 
 	req.primary_path = &route->path_rec[0];
 	if (route->num_paths == 2)
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

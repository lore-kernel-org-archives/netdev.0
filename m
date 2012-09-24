From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 13/26 v3] rdma/cm: Expose private data when using AF_IB
Date: Mon, 24 Sep 2012 23:55:33 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F104@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25822 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752082Ab2IXXz7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:59 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the source or destination address is AF_IB, then do not
reserve a portion of the private data in the IB CM REQ or SIDR
REQ messages for the cma header.  Instead, all private data
should be exported to the user.  When AF_IB is used, the
rdma cm does not have sufficient information to fill in the
cma header.  Additionally, this will be necessary to support
any IB connection through the rdma cm interface,

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 4e205db..1264e97 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -907,14 +907,10 @@ static void cma_save_net_info(struct rdma_addr *addr,
 	}
 }
 
-static inline int cma_user_data_offset(enum rdma_port_space ps)
+static inline int cma_user_data_offset(struct rdma_id_private *id_priv)
 {
-	switch (ps) {
-	case RDMA_PS_SDP:
-		return 0;
-	default:
-		return sizeof(struct cma_hdr);
-	}
+	return (cma_family(id_priv) == AF_IB || id_priv->id.ps == RDMA_PS_SDP) ?
+		0 : sizeof(struct cma_hdr);
 }
 
 static void cma_cancel_route(struct rdma_id_private *id_priv)
@@ -1310,7 +1306,7 @@ static int cma_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *ib_event)
 		return -ECONNABORTED;
 
 	memset(&event, 0, sizeof event);
-	offset = cma_user_data_offset(listen_id->id.ps);
+	offset = cma_user_data_offset(listen_id);
 	event.event = RDMA_CM_EVENT_CONNECT_REQUEST;
 	if (ib_event->event == IB_CM_SIDR_REQ_RECEIVED) {
 		conn_id = cma_new_udp_id(&listen_id->id, ib_event);
@@ -2637,7 +2633,7 @@ static int cma_format_hdr(void *hdr, struct rdma_id_private *id_priv)
 			cma_hdr->port = src4->sin_port;
 			break;
 		}
-	} else {
+	} else if (cma_family(id_priv) == AF_INET6) {
 		struct sockaddr_in6 *src6, *dst6;
 
 		src6 = (struct sockaddr_in6 *) cma_src_addr(id_priv);
@@ -2735,10 +2731,10 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
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
 
@@ -2747,7 +2743,7 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
 		return -ENOMEM;
 
 	if (conn_param->private_data && conn_param->private_data_len)
-		memcpy((void *) req.private_data + sizeof(struct cma_hdr),
+		memcpy((void *) req.private_data + offset,
 		       conn_param->private_data, conn_param->private_data_len);
 
 	ret = cma_format_hdr((void *) req.private_data, id_priv);
@@ -2787,7 +2783,7 @@ static int cma_connect_ib(struct rdma_id_private *id_priv,
 	int offset, ret;
 
 	memset(&req, 0, sizeof req);
-	offset = cma_user_data_offset(id_priv->id.ps);
+	offset = cma_user_data_offset(id_priv);
 	req.private_data_len = offset + conn_param->private_data_len;
 	if (req.private_data_len < conn_param->private_data_len)
 		return -EINVAL;

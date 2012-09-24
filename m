From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 18/26 v3] rdma/ucm: Support querying when IB paths are not
 reversible
Date: Mon, 24 Sep 2012 23:55:34 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F131@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26227 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651Ab2IXXzg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:36 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current query_route call can return up to two path records.
The assumption being that one is the primary path, with optional
support for an alternate path.  In both cases, the paths are
assumed to be reversible and are used to send CM MADs.

With the ability to manually set IB path data, the rdma cm
can eventually be capable of using up to 6 paths per
connection:

	forward primary, reverse primary,
	forward alternate, reverse alternate,
	reversible primary path for CM MADs
	reversible alternate path for CM MADs.

(It is unclear at this time if IB routing will complicate this.)
In order to handle more flexible routing topologies, add a new
command to report any number of paths.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/ucma.c |   35 +++++++++++++++++++++++++++++++++++
 include/rdma/rdma_user_cm.h    |    9 ++++++++-
 2 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index b9ce266..9b60338 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -767,6 +767,38 @@ static ssize_t ucma_query_addr(struct ucma_context *ctx,
 	return ret;
 }
 
+static ssize_t ucma_query_path(struct ucma_context *ctx,
+			       void __user *response, int out_len)
+{
+	struct rdma_ucm_query_path_resp *resp;
+	int i, ret = 0;
+
+	if (out_len < sizeof(*resp))
+		return -ENOSPC;
+
+	resp = kzalloc(out_len, GFP_KERNEL);
+	if (!resp)
+		return -ENOMEM;
+
+	resp->num_paths = ctx->cm_id->route.num_paths;
+	for (i = 0, out_len -= sizeof(*resp);
+	     i < resp->num_paths && out_len > sizeof(struct ib_path_rec_data);
+	     i++, out_len -= sizeof(struct ib_path_rec_data)) {
+
+		resp->path_data[i].flags = IB_PATH_GMP | IB_PATH_PRIMARY |
+					   IB_PATH_BIDIRECTIONAL;
+		ib_sa_pack_path(&ctx->cm_id->route.path_rec[i],
+				&resp->path_data[i].path_rec);
+	}
+
+	if (copy_to_user(response, resp,
+			 sizeof(*resp) + (i * sizeof(struct ib_path_rec_data))))
+		ret = -EFAULT;
+
+	kfree(resp);
+	return ret;
+}
+
 static ssize_t ucma_query(struct ucma_file *file,
 			  const char __user *inbuf,
 			  int in_len, int out_len)
@@ -788,6 +820,9 @@ static ssize_t ucma_query(struct ucma_file *file,
 	case RDMA_USER_CM_QUERY_ADDR:
 		ret = ucma_query_addr(ctx, response, out_len);
 		break;
+	case RDMA_USER_CM_QUERY_PATH:
+		ret = ucma_query_path(ctx, response, out_len);
+		break;
 	default:
 		ret = -ENOSYS;
 		break;
diff --git a/include/rdma/rdma_user_cm.h b/include/rdma/rdma_user_cm.h
index 4037c48..effcb75 100644
--- a/include/rdma/rdma_user_cm.h
+++ b/include/rdma/rdma_user_cm.h
@@ -115,7 +115,8 @@ struct rdma_ucm_resolve_route {
 };
 
 enum {
-	RDMA_USER_CM_QUERY_ADDR
+	RDMA_USER_CM_QUERY_ADDR,
+	RDMA_USER_CM_QUERY_PATH
 };
 
 struct rdma_ucm_query {
@@ -145,6 +146,12 @@ struct rdma_ucm_query_addr_resp {
 	struct sockaddr_storage dst_addr;
 };
 
+struct rdma_ucm_query_path_resp {
+	__u32 num_paths;
+	__u32 reserved;
+	struct ib_path_rec_data path_data[0];
+};
+
 struct rdma_ucm_conn_param {
 	__u32 qp_num;
 	__u32 qkey;

From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v5 21/28] rdma/ucm: Support querying when IB paths are not reversible
Date: Wed, 29 May 2013 10:09:27 -0700
Message-ID: <1369847374-12176-22-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

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

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/ucma.c   |   35 +++++++++++++++++++++++++++++++++++
 include/uapi/rdma/rdma_user_cm.h |    9 ++++++++-
 2 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 18bdccc..722f2ff 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -750,6 +750,38 @@ static ssize_t ucma_query_addr(struct ucma_context *ctx,
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
@@ -771,6 +803,9 @@ static ssize_t ucma_query(struct ucma_file *file,
 	case RDMA_USER_CM_QUERY_ADDR:
 		ret = ucma_query_addr(ctx, response, out_len);
 		break;
+	case RDMA_USER_CM_QUERY_PATH:
+		ret = ucma_query_path(ctx, response, out_len);
+		break;
 	default:
 		ret = -ENOSYS;
 		break;
diff --git a/include/uapi/rdma/rdma_user_cm.h b/include/uapi/rdma/rdma_user_cm.h
index 3ea7e7a..07eb6cf 100644
--- a/include/uapi/rdma/rdma_user_cm.h
+++ b/include/uapi/rdma/rdma_user_cm.h
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
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

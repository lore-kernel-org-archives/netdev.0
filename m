From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v5 19/28] rdma/ucm: Support querying for AF_IB addresses
Date: Wed, 29 May 2013 10:09:25 -0700
Message-ID: <1369847374-12176-20-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

The sockaddr structure for AF_IB is larger than sockaddr_in6.
The rdma cm user space ABI uses the latter to exchange address
information between user space and the kernel.

To support querying for larger addresses, define a new query
command that exchanges data using sockaddr_storage, rather
than sockaddr_in6.  Unlike the existing query_route command,
the new command only returns address information.  Route
(i.e. path record) data is separated.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/ucma.c   |   76 +++++++++++++++++++++++++++++++++++++-
 include/uapi/rdma/rdma_user_cm.h |   22 +++++++++-
 2 files changed, 93 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index e813774..18bdccc 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -47,6 +47,7 @@
 #include <rdma/ib_marshall.h>
 #include <rdma/rdma_cm.h>
 #include <rdma/rdma_cm_ib.h>
+#include <rdma/ib_addr.h>
 
 MODULE_AUTHOR("Sean Hefty");
 MODULE_DESCRIPTION("RDMA Userspace Connection Manager Access");
@@ -649,7 +650,7 @@ static ssize_t ucma_query_route(struct ucma_file *file,
 				const char __user *inbuf,
 				int in_len, int out_len)
 {
-	struct rdma_ucm_query_route cmd;
+	struct rdma_ucm_query cmd;
 	struct rdma_ucm_query_route_resp resp;
 	struct ucma_context *ctx;
 	struct sockaddr *addr;
@@ -709,6 +710,76 @@ out:
 	return ret;
 }
 
+static void ucma_query_device_addr(struct rdma_cm_id *cm_id,
+				   struct rdma_ucm_query_addr_resp *resp)
+{
+	if (!cm_id->device)
+		return;
+
+	resp->node_guid = (__force __u64) cm_id->device->node_guid;
+	resp->port_num = cm_id->port_num;
+	resp->pkey = (__force __u16) cpu_to_be16(
+		     ib_addr_get_pkey(&cm_id->route.addr.dev_addr));
+}
+
+static ssize_t ucma_query_addr(struct ucma_context *ctx,
+			       void __user *response, int out_len)
+{
+	struct rdma_ucm_query_addr_resp resp;
+	struct sockaddr *addr;
+	int ret = 0;
+
+	if (out_len < sizeof(resp))
+		return -ENOSPC;
+
+	memset(&resp, 0, sizeof resp);
+
+	addr = (struct sockaddr *) &ctx->cm_id->route.addr.src_addr;
+	resp.src_size = rdma_addr_size(addr);
+	memcpy(&resp.src_addr, addr, resp.src_size);
+
+	addr = (struct sockaddr *) &ctx->cm_id->route.addr.dst_addr;
+	resp.dst_size = rdma_addr_size(addr);
+	memcpy(&resp.dst_addr, addr, resp.dst_size);
+
+	ucma_query_device_addr(ctx->cm_id, &resp);
+
+	if (copy_to_user(response, &resp, sizeof(resp)))
+		ret = -EFAULT;
+
+	return ret;
+}
+
+static ssize_t ucma_query(struct ucma_file *file,
+			  const char __user *inbuf,
+			  int in_len, int out_len)
+{
+	struct rdma_ucm_query cmd;
+	struct ucma_context *ctx;
+	void __user *response;
+	int ret;
+
+	if (copy_from_user(&cmd, inbuf, sizeof(cmd)))
+		return -EFAULT;
+
+	response = (void __user *)(unsigned long) cmd.response;
+	ctx = ucma_get_ctx(file, cmd.id);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	switch (cmd.option) {
+	case RDMA_USER_CM_QUERY_ADDR:
+		ret = ucma_query_addr(ctx, response, out_len);
+		break;
+	default:
+		ret = -ENOSYS;
+		break;
+	}
+
+	ucma_put_ctx(ctx);
+	return ret;
+}
+
 static void ucma_copy_conn_param(struct rdma_cm_id *id,
 				 struct rdma_conn_param *dst,
 				 struct rdma_ucm_conn_param *src)
@@ -1241,7 +1312,8 @@ static ssize_t (*ucma_cmd_table[])(struct ucma_file *file,
 	[RDMA_USER_CM_CMD_NOTIFY]	= ucma_notify,
 	[RDMA_USER_CM_CMD_JOIN_MCAST]	= ucma_join_multicast,
 	[RDMA_USER_CM_CMD_LEAVE_MCAST]	= ucma_leave_multicast,
-	[RDMA_USER_CM_CMD_MIGRATE_ID]	= ucma_migrate_id
+	[RDMA_USER_CM_CMD_MIGRATE_ID]	= ucma_migrate_id,
+	[RDMA_USER_CM_CMD_QUERY]	= ucma_query
 };
 
 static ssize_t ucma_write(struct file *filp, const char __user *buf,
diff --git a/include/uapi/rdma/rdma_user_cm.h b/include/uapi/rdma/rdma_user_cm.h
index 29de08f..3ea7e7a 100644
--- a/include/uapi/rdma/rdma_user_cm.h
+++ b/include/uapi/rdma/rdma_user_cm.h
@@ -61,7 +61,8 @@ enum {
 	RDMA_USER_CM_CMD_NOTIFY,
 	RDMA_USER_CM_CMD_JOIN_MCAST,
 	RDMA_USER_CM_CMD_LEAVE_MCAST,
-	RDMA_USER_CM_CMD_MIGRATE_ID
+	RDMA_USER_CM_CMD_MIGRATE_ID,
+	RDMA_USER_CM_CMD_QUERY
 };
 
 /*
@@ -113,10 +114,14 @@ struct rdma_ucm_resolve_route {
 	__u32 timeout_ms;
 };
 
-struct rdma_ucm_query_route {
+enum {
+	RDMA_USER_CM_QUERY_ADDR
+};
+
+struct rdma_ucm_query {
 	__u64 response;
 	__u32 id;
-	__u32 reserved;
+	__u32 option;
 };
 
 struct rdma_ucm_query_route_resp {
@@ -129,6 +134,17 @@ struct rdma_ucm_query_route_resp {
 	__u8 reserved[3];
 };
 
+struct rdma_ucm_query_addr_resp {
+	__u64 node_guid;
+	__u8  port_num;
+	__u8  reserved;
+	__u16 pkey;
+	__u16 src_size;
+	__u16 dst_size;
+	struct sockaddr_storage src_addr;
+	struct sockaddr_storage dst_addr;
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

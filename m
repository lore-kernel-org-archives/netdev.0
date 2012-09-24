From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 16/26 v3] rdma/ucm: Support querying for AF_IB addresses
Date: Mon, 24 Sep 2012 23:55:34 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F11C@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26227 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747Ab2IXXzf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:35 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sockaddr structure for AF_IB is larger than sockaddr_in6.
The rdma cm user space ABI uses the latter to exchange address
information between user space and the kernel.

To support querying for larger addresses, define a new query
command that exchanges data using sockaddr_storage, rather
than sockaddr_in6.  Unlike the existing query_route command,
the new command only returns address information.  Route
(i.e. path record) data is separated.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/ucma.c |   76 +++++++++++++++++++++++++++++++++++++++-
 include/rdma/rdma_user_cm.h    |   22 ++++++++++--
 2 files changed, 93 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 52c606b..b9ce266 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -47,6 +47,7 @@
 #include <rdma/ib_marshall.h>
 #include <rdma/rdma_cm.h>
 #include <rdma/rdma_cm_ib.h>
+#include <rdma/ib_addr.h>
 
 MODULE_AUTHOR("Sean Hefty");
 MODULE_DESCRIPTION("RDMA Userspace Connection Manager Access");
@@ -666,7 +667,7 @@ static ssize_t ucma_query_route(struct ucma_file *file,
 				const char __user *inbuf,
 				int in_len, int out_len)
 {
-	struct rdma_ucm_query_route cmd;
+	struct rdma_ucm_query cmd;
 	struct rdma_ucm_query_route_resp resp;
 	struct ucma_context *ctx;
 	struct sockaddr *addr;
@@ -726,6 +727,76 @@ out:
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
@@ -1256,7 +1327,8 @@ static ssize_t (*ucma_cmd_table[])(struct ucma_file *file,
 	[RDMA_USER_CM_CMD_NOTIFY]	= ucma_notify,
 	[RDMA_USER_CM_CMD_JOIN_MCAST]	= ucma_join_multicast,
 	[RDMA_USER_CM_CMD_LEAVE_MCAST]	= ucma_leave_multicast,
-	[RDMA_USER_CM_CMD_MIGRATE_ID]	= ucma_migrate_id
+	[RDMA_USER_CM_CMD_MIGRATE_ID]	= ucma_migrate_id,
+	[RDMA_USER_CM_CMD_QUERY]	= ucma_query
 };
 
 static ssize_t ucma_write(struct file *filp, const char __user *buf,
diff --git a/include/rdma/rdma_user_cm.h b/include/rdma/rdma_user_cm.h
index ca8d4d4..4037c48 100644
--- a/include/rdma/rdma_user_cm.h
+++ b/include/rdma/rdma_user_cm.h
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

From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 23/26 v3] rdma/ucm: Allow user space to pass AF_IB into
 resolve
Date: Mon, 24 Sep 2012 23:55:36 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F157@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:20382 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752086Ab2IXXz7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:59 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow user space applications to call resolve_addr using
AF_IB.  To support sockaddr_ib, we need to define a new
structure capable of handling the larger address size.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/ucma.c |   30 +++++++++++++++++++++++++++++-
 include/rdma/rdma_user_cm.h    |   13 ++++++++++++-
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index d23bc1bf..ecbe404 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -594,6 +594,33 @@ static ssize_t ucma_resolve_ip(struct ucma_file *file,
 	return ret;
 }
 
+static ssize_t ucma_resolve_addr(struct ucma_file *file,
+				 const char __user *inbuf,
+				 int in_len, int out_len)
+{
+	struct rdma_ucm_resolve_addr cmd;
+	struct sockaddr *src, *dst;
+	struct ucma_context *ctx;
+	int ret;
+
+	if (copy_from_user(&cmd, inbuf, sizeof(cmd)))
+		return -EFAULT;
+
+	src = (struct sockaddr *) &cmd.src_addr;
+	dst = (struct sockaddr *) &cmd.dst_addr;
+	if (cmd.reserved || (cmd.src_size && (cmd.src_size != rdma_addr_size(src))) ||
+	    !cmd.dst_size || (cmd.dst_size != rdma_addr_size(dst)))
+		return -EINVAL;
+
+	ctx = ucma_get_ctx(file, cmd.id);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = rdma_resolve_addr(ctx->cm_id, src, dst, cmd.timeout_ms);
+	ucma_put_ctx(ctx);
+	return ret;
+}
+
 static ssize_t ucma_resolve_route(struct ucma_file *file,
 				  const char __user *inbuf,
 				  int in_len, int out_len)
@@ -1438,7 +1465,8 @@ static ssize_t (*ucma_cmd_table[])(struct ucma_file *file,
 	[RDMA_USER_CM_CMD_LEAVE_MCAST]	 = ucma_leave_multicast,
 	[RDMA_USER_CM_CMD_MIGRATE_ID]	 = ucma_migrate_id,
 	[RDMA_USER_CM_CMD_QUERY]	 = ucma_query,
-	[RDMA_USER_CM_CMD_BIND]		 = ucma_bind
+	[RDMA_USER_CM_CMD_BIND]		 = ucma_bind,
+	[RDMA_USER_CM_CMD_RESOLVE_ADDR]	 = ucma_resolve_addr
 };
 
 static ssize_t ucma_write(struct file *filp, const char __user *buf,
diff --git a/include/rdma/rdma_user_cm.h b/include/rdma/rdma_user_cm.h
index cae3e27..b731b5e 100644
--- a/include/rdma/rdma_user_cm.h
+++ b/include/rdma/rdma_user_cm.h
@@ -63,7 +63,8 @@ enum {
 	RDMA_USER_CM_CMD_LEAVE_MCAST,
 	RDMA_USER_CM_CMD_MIGRATE_ID,
 	RDMA_USER_CM_CMD_QUERY,
-	RDMA_USER_CM_CMD_BIND
+	RDMA_USER_CM_CMD_BIND,
+	RDMA_USER_CM_CMD_RESOLVE_ADDR
 };
 
 /*
@@ -117,6 +118,16 @@ struct rdma_ucm_resolve_ip {
 	__u32 timeout_ms;
 };
 
+struct rdma_ucm_resolve_addr {
+	__u32 id;
+	__u32 timeout_ms;
+	__u16 src_size;
+	__u16 dst_size;
+	__u32 reserved;
+	struct sockaddr_storage src_addr;
+	struct sockaddr_storage dst_addr;
+};
+
 struct rdma_ucm_resolve_route {
 	__u32 id;
 	__u32 timeout_ms;

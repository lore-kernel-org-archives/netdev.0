From: sean.hefty@intel.com
Subject: [PATCH v5 25/28] rdma/ucm: Allow user space to bind to AF_IB
Date: Wed, 29 May 2013 10:09:31 -0700
Message-ID: <1369847374-12176-26-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
To: roland@purestorage.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6764 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759702Ab3E2RKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 13:10:05 -0400
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Hefty <sean.hefty@intel.com>

Support user space binding to addresses using AF_IB.  Since
sockaddr_ib is larger than sockaddr_in6, we need to define
a larger structure when binding using AF_IB.  This time we
use sockaddr_storage to cover future cases.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
 drivers/infiniband/core/ucma.c   |   27 ++++++++++++++++++++++++++-
 include/uapi/rdma/rdma_user_cm.h |   10 +++++++++-
 2 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 82fb1e6..22ed97e 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -531,6 +531,30 @@ static ssize_t ucma_bind_ip(struct ucma_file *file, const char __user *inbuf,
 	return ret;
 }
 
+static ssize_t ucma_bind(struct ucma_file *file, const char __user *inbuf,
+			 int in_len, int out_len)
+{
+	struct rdma_ucm_bind cmd;
+	struct sockaddr *addr;
+	struct ucma_context *ctx;
+	int ret;
+
+	if (copy_from_user(&cmd, inbuf, sizeof(cmd)))
+		return -EFAULT;
+
+	addr = (struct sockaddr *) &cmd.addr;
+	if (cmd.reserved || !cmd.addr_size || (cmd.addr_size != rdma_addr_size(addr)))
+		return -EINVAL;
+
+	ctx = ucma_get_ctx(file, cmd.id);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = rdma_bind_addr(ctx->cm_id, addr);
+	ucma_put_ctx(ctx);
+	return ret;
+}
+
 static ssize_t ucma_resolve_ip(struct ucma_file *file,
 			       const char __user *inbuf,
 			       int in_len, int out_len)
@@ -1398,7 +1422,8 @@ static ssize_t (*ucma_cmd_table[])(struct ucma_file *file,
 	[RDMA_USER_CM_CMD_JOIN_IP_MCAST] = ucma_join_ip_multicast,
 	[RDMA_USER_CM_CMD_LEAVE_MCAST]	 = ucma_leave_multicast,
 	[RDMA_USER_CM_CMD_MIGRATE_ID]	 = ucma_migrate_id,
-	[RDMA_USER_CM_CMD_QUERY]	 = ucma_query
+	[RDMA_USER_CM_CMD_QUERY]	 = ucma_query,
+	[RDMA_USER_CM_CMD_BIND]		 = ucma_bind
 };
 
 static ssize_t ucma_write(struct file *filp, const char __user *buf,
diff --git a/include/uapi/rdma/rdma_user_cm.h b/include/uapi/rdma/rdma_user_cm.h
index 79f68f7..895a427 100644
--- a/include/uapi/rdma/rdma_user_cm.h
+++ b/include/uapi/rdma/rdma_user_cm.h
@@ -62,7 +62,8 @@ enum {
 	RDMA_USER_CM_CMD_JOIN_IP_MCAST,
 	RDMA_USER_CM_CMD_LEAVE_MCAST,
 	RDMA_USER_CM_CMD_MIGRATE_ID,
-	RDMA_USER_CM_CMD_QUERY
+	RDMA_USER_CM_CMD_QUERY,
+	RDMA_USER_CM_CMD_BIND
 };
 
 /*
@@ -102,6 +103,13 @@ struct rdma_ucm_bind_ip {
 	__u32 id;
 };
 
+struct rdma_ucm_bind {
+	__u32 id;
+	__u16 addr_size;
+	__u16 reserved;
+	struct sockaddr_storage addr;
+};
+
 struct rdma_ucm_resolve_ip {
 	struct sockaddr_in6 src_addr;
 	struct sockaddr_in6 dst_addr;
-- 
1.7.3

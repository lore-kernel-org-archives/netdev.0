From: sean.hefty@intel.com
Subject: [PATCH v5 23/28] rdma/ucm: Add ability to query GID addresses
Date: Wed, 29 May 2013 10:09:29 -0700
Message-ID: <1369847374-12176-24-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
To: roland@purestorage.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18285 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759693Ab3E2RKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 13:10:03 -0400
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Hefty <sean.hefty@intel.com>

Part of address resolution is mapping IP addresses to IB GIDs.
With the changes to support querying larger addresses and more
path records, also provide a way to query IB GIDs after
resolution completes.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
 drivers/infiniband/core/ucma.c   |   50 ++++++++++++++++++++++++++++++++++++++
 include/uapi/rdma/rdma_user_cm.h |    3 +-
 2 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 722f2ff..45bb052 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -48,6 +48,7 @@
 #include <rdma/rdma_cm.h>
 #include <rdma/rdma_cm_ib.h>
 #include <rdma/ib_addr.h>
+#include <rdma/ib.h>
 
 MODULE_AUTHOR("Sean Hefty");
 MODULE_DESCRIPTION("RDMA Userspace Connection Manager Access");
@@ -782,6 +783,52 @@ static ssize_t ucma_query_path(struct ucma_context *ctx,
 	return ret;
 }
 
+static ssize_t ucma_query_gid(struct ucma_context *ctx,
+			      void __user *response, int out_len)
+{
+	struct rdma_ucm_query_addr_resp resp;
+	struct sockaddr_ib *addr;
+	int ret = 0;
+
+	if (out_len < sizeof(resp))
+		return -ENOSPC;
+
+	memset(&resp, 0, sizeof resp);
+
+	ucma_query_device_addr(ctx->cm_id, &resp);
+
+	addr = (struct sockaddr_ib *) &resp.src_addr;
+	resp.src_size = sizeof(*addr);
+	if (ctx->cm_id->route.addr.src_addr.ss_family == AF_IB) {
+		memcpy(addr, &ctx->cm_id->route.addr.src_addr, resp.src_size);
+	} else {
+		addr->sib_family = AF_IB;
+		addr->sib_pkey = (__force __be16) resp.pkey;
+		rdma_addr_get_sgid(&ctx->cm_id->route.addr.dev_addr,
+				   (union ib_gid *) &addr->sib_addr);
+		addr->sib_sid = rdma_get_service_id(ctx->cm_id, (struct sockaddr *)
+						    &ctx->cm_id->route.addr.src_addr);
+	}
+
+	addr = (struct sockaddr_ib *) &resp.dst_addr;
+	resp.dst_size = sizeof(*addr);
+	if (ctx->cm_id->route.addr.dst_addr.ss_family == AF_IB) {
+		memcpy(addr, &ctx->cm_id->route.addr.dst_addr, resp.dst_size);
+	} else {
+		addr->sib_family = AF_IB;
+		addr->sib_pkey = (__force __be16) resp.pkey;
+		rdma_addr_get_dgid(&ctx->cm_id->route.addr.dev_addr,
+				   (union ib_gid *) &addr->sib_addr);
+		addr->sib_sid = rdma_get_service_id(ctx->cm_id, (struct sockaddr *)
+						    &ctx->cm_id->route.addr.dst_addr);
+	}
+
+	if (copy_to_user(response, &resp, sizeof(resp)))
+		ret = -EFAULT;
+
+	return ret;
+}
+
 static ssize_t ucma_query(struct ucma_file *file,
 			  const char __user *inbuf,
 			  int in_len, int out_len)
@@ -806,6 +853,9 @@ static ssize_t ucma_query(struct ucma_file *file,
 	case RDMA_USER_CM_QUERY_PATH:
 		ret = ucma_query_path(ctx, response, out_len);
 		break;
+	case RDMA_USER_CM_QUERY_GID:
+		ret = ucma_query_gid(ctx, response, out_len);
+		break;
 	default:
 		ret = -ENOSYS;
 		break;
diff --git a/include/uapi/rdma/rdma_user_cm.h b/include/uapi/rdma/rdma_user_cm.h
index 07eb6cf..ea79253 100644
--- a/include/uapi/rdma/rdma_user_cm.h
+++ b/include/uapi/rdma/rdma_user_cm.h
@@ -116,7 +116,8 @@ struct rdma_ucm_resolve_route {
 
 enum {
 	RDMA_USER_CM_QUERY_ADDR,
-	RDMA_USER_CM_QUERY_PATH
+	RDMA_USER_CM_QUERY_PATH,
+	RDMA_USER_CM_QUERY_GID
 };
 
 struct rdma_ucm_query {
-- 
1.7.3

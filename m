From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 24/26 v3] rdma/ucm: Allow user space to specify AF_IB when
 joining multicast
Date: Mon, 24 Sep 2012 23:55:36 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F163@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:35874 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751808Ab2IXXzj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:39 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow user space applications to join multicast groups using MGIDs
directly.  MGIDs may be passed using AF_IB addresses.  Since the
current multicast join command only supports addresses as large as
sockaddr_in6, define a new structure for joining addresses specified
using sockaddr_ib.

Since AF_IB allows the user to specify the qkey when
resolving a remote UD QP address, when joining the multicast
group use the qkey value, if one has been assigned.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/cma.c  |    9 +++++--
 drivers/infiniband/core/ucma.c |   55 ++++++++++++++++++++++++++++++++--------
 include/rdma/rdma_user_cm.h    |   12 ++++++++-
 3 files changed, 62 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 8f9c05f..93f7b5c 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -3200,6 +3200,8 @@ static void cma_set_mgid(struct rdma_id_private *id_priv,
 								 0xFF10A01B)) {
 		/* IPv6 address is an SA assigned MGID. */
 		memcpy(mgid, &sin6->sin6_addr, sizeof *mgid);
+	} else if (addr->sa_family == AF_IB) {
+		memcpy(mgid, &((struct sockaddr_ib *) addr)->sib_addr, sizeof *mgid);
 	} else if ((addr->sa_family == AF_INET6)) {
 		ipv6_ib_mc_map(&sin6->sin6_addr, dev_addr->broadcast, mc_map);
 		if (id_priv->id.ps == RDMA_PS_UDP)
@@ -3227,9 +3229,12 @@ static int cma_join_ib_multicast(struct rdma_id_private *id_priv,
 	if (ret)
 		return ret;
 
+	ret = cma_set_qkey(id_priv, 0);
+	if (ret)
+		return ret;
+
 	cma_set_mgid(id_priv, (struct sockaddr *) &mc->addr, &rec.mgid);
-	if (id_priv->id.ps == RDMA_PS_UDP)
-		rec.qkey = cpu_to_be32(RDMA_UDP_QKEY);
+	rec.qkey = cpu_to_be32(id_priv->qkey);
 	rdma_addr_get_sgid(dev_addr, &rec.port_gid);
 	rec.pkey = cpu_to_be16(ib_addr_get_pkey(dev_addr));
 	rec.join_state = 1;
diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index ecbe404..83e02f0 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -1244,23 +1244,23 @@ static ssize_t ucma_notify(struct ucma_file *file, const char __user *inbuf,
 	return ret;
 }
 
-static ssize_t ucma_join_ip_multicast(struct ucma_file *file,
-				      const char __user *inbuf,
-				      int in_len, int out_len)
+static ssize_t ucma_process_join(struct ucma_file *file,
+				 struct rdma_ucm_join_mcast *cmd,  int out_len)
 {
-	struct rdma_ucm_join_ip_mcast cmd;
 	struct rdma_ucm_create_id_resp resp;
 	struct ucma_context *ctx;
 	struct ucma_multicast *mc;
+	struct sockaddr *addr;
 	int ret;
 
 	if (out_len < sizeof(resp))
 		return -ENOSPC;
 
-	if (copy_from_user(&cmd, inbuf, sizeof(cmd)))
-		return -EFAULT;
+	addr = (struct sockaddr *) &cmd->addr;
+	if (cmd->reserved || !cmd->addr_size || (cmd->addr_size != rdma_addr_size(addr)))
+		return -EINVAL;
 
-	ctx = ucma_get_ctx(file, cmd.id);
+	ctx = ucma_get_ctx(file, cmd->id);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
@@ -1271,14 +1271,14 @@ static ssize_t ucma_join_ip_multicast(struct ucma_file *file,
 		goto err1;
 	}
 
-	mc->uid = cmd.uid;
-	memcpy(&mc->addr, &cmd.addr, sizeof cmd.addr);
+	mc->uid = cmd->uid;
+	memcpy(&mc->addr, addr, cmd->addr_size);
 	ret = rdma_join_multicast(ctx->cm_id, (struct sockaddr *) &mc->addr, mc);
 	if (ret)
 		goto err2;
 
 	resp.id = mc->id;
-	if (copy_to_user((void __user *)(unsigned long)cmd.response,
+	if (copy_to_user((void __user *)(unsigned long) cmd->response,
 			 &resp, sizeof(resp))) {
 		ret = -EFAULT;
 		goto err3;
@@ -1303,6 +1303,38 @@ err1:
 	return ret;
 }
 
+static ssize_t ucma_join_ip_multicast(struct ucma_file *file,
+				      const char __user *inbuf,
+				      int in_len, int out_len)
+{
+	struct rdma_ucm_join_ip_mcast cmd;
+	struct rdma_ucm_join_mcast join_cmd;
+
+	if (copy_from_user(&cmd, inbuf, sizeof(cmd)))
+		return -EFAULT;
+
+	join_cmd.response = cmd.response;
+	join_cmd.uid = cmd.uid;
+	join_cmd.id = cmd.id;
+	join_cmd.addr_size = rdma_addr_size((struct sockaddr *) &cmd.addr);
+	join_cmd.reserved = 0;
+	memcpy(&join_cmd.addr, &cmd.addr, join_cmd.addr_size);
+
+	return ucma_process_join(file, &join_cmd, out_len);
+}
+
+static ssize_t ucma_join_multicast(struct ucma_file *file,
+				   const char __user *inbuf,
+				   int in_len, int out_len)
+{
+	struct rdma_ucm_join_mcast cmd;
+
+	if (copy_from_user(&cmd, inbuf, sizeof(cmd)))
+		return -EFAULT;
+
+	return ucma_process_join(file, &cmd, out_len);
+}
+
 static ssize_t ucma_leave_multicast(struct ucma_file *file,
 				    const char __user *inbuf,
 				    int in_len, int out_len)
@@ -1466,7 +1498,8 @@ static ssize_t (*ucma_cmd_table[])(struct ucma_file *file,
 	[RDMA_USER_CM_CMD_MIGRATE_ID]	 = ucma_migrate_id,
 	[RDMA_USER_CM_CMD_QUERY]	 = ucma_query,
 	[RDMA_USER_CM_CMD_BIND]		 = ucma_bind,
-	[RDMA_USER_CM_CMD_RESOLVE_ADDR]	 = ucma_resolve_addr
+	[RDMA_USER_CM_CMD_RESOLVE_ADDR]	 = ucma_resolve_addr,
+	[RDMA_USER_CM_CMD_JOIN_MCAST]	 = ucma_join_multicast
 };
 
 static ssize_t ucma_write(struct file *filp, const char __user *buf,
diff --git a/include/rdma/rdma_user_cm.h b/include/rdma/rdma_user_cm.h
index b731b5e..bf34156 100644
--- a/include/rdma/rdma_user_cm.h
+++ b/include/rdma/rdma_user_cm.h
@@ -64,7 +64,8 @@ enum {
 	RDMA_USER_CM_CMD_MIGRATE_ID,
 	RDMA_USER_CM_CMD_QUERY,
 	RDMA_USER_CM_CMD_BIND,
-	RDMA_USER_CM_CMD_RESOLVE_ADDR
+	RDMA_USER_CM_CMD_RESOLVE_ADDR,
+	RDMA_USER_CM_CMD_JOIN_MCAST
 };
 
 /*
@@ -242,6 +243,15 @@ struct rdma_ucm_join_ip_mcast {
 	__u32 id;
 };
 
+struct rdma_ucm_join_mcast {
+	__u64 response;		/* rdma_ucma_create_id_resp */
+	__u64 uid;
+	__u32 id;
+	__u16 addr_size;
+	__u16 reserved;
+	struct sockaddr_storage addr;
+};
+
 struct rdma_ucm_get_event {
 	__u64 response;
 };

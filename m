From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 1/5] RDS: Add GET_MR_FOR_DEST sockopt
Date: Fri, 30 Oct 2009 11:54:53 -0700
Message-ID: <1256928893-17844-2-git-send-email-andy.grover@oracle.com>
References: <1256928893-17844-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:46568 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757326AbZJ3SzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 14:55:17 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9UIus0l003418
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 18:56:56 GMT
In-Reply-To: <1256928893-17844-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS currently supports a GET_MR sockopt to establish a
memory region (MR) for a chunk of memory. However, the fastreg
method ties a MR to a particular destination. The GET_MR_FOR_DEST
sockopt allows the remote machine to be specified, and thus
support for fastreg (aka FRWRs).

Note that this patch does *not* do all of this - it simply
implements the new sockopt in terms of the old one, so applications
can begin to use the new sockopt in preparation for cutover to
FRWRs.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 include/linux/rds.h |    8 ++++++++
 net/rds/af_rds.c    |    3 +++
 net/rds/rdma.c      |   24 ++++++++++++++++++++++++
 net/rds/rdma.h      |    1 +
 4 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/include/linux/rds.h b/include/linux/rds.h
index 89d46e1..cab4994 100644
--- a/include/linux/rds.h
+++ b/include/linux/rds.h
@@ -56,6 +56,7 @@
 /* deprecated: RDS_BARRIER 4 */
 #define RDS_RECVERR			5
 #define RDS_CONG_MONITOR		6
+#define RDS_GET_MR_FOR_DEST		7
 
 /*
  * Control message types for SOL_RDS.
@@ -224,6 +225,13 @@ struct rds_get_mr_args {
 	uint64_t	flags;
 };
 
+struct rds_get_mr_for_dest_args {
+	struct sockaddr_storage	dest_addr;
+	struct rds_iovec 	vec;
+	u_int64_t		cookie_addr;
+	uint64_t		flags;
+};
+
 struct rds_free_mr_args {
 	rds_rdma_cookie_t cookie;
 	u_int64_t	flags;
diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index a202e5b..2b978dc 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -265,6 +265,9 @@ static int rds_setsockopt(struct socket *sock, int level, int optname,
 	case RDS_GET_MR:
 		ret = rds_get_mr(rs, optval, optlen);
 		break;
+	case RDS_GET_MR_FOR_DEST:
+		ret = rds_get_mr_for_dest(rs, optval, optlen);
+		break;
 	case RDS_FREE_MR:
 		ret = rds_free_mr(rs, optval, optlen);
 		break;
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 8dc83d2..971b5a6 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -317,6 +317,30 @@ int rds_get_mr(struct rds_sock *rs, char __user *optval, int optlen)
 	return __rds_rdma_map(rs, &args, NULL, NULL);
 }
 
+int rds_get_mr_for_dest(struct rds_sock *rs, char __user *optval, int optlen)
+{
+	struct rds_get_mr_for_dest_args args;
+	struct rds_get_mr_args new_args;
+
+	if (optlen != sizeof(struct rds_get_mr_for_dest_args))
+		return -EINVAL;
+
+	if (copy_from_user(&args, (struct rds_get_mr_for_dest_args __user *)optval,
+			   sizeof(struct rds_get_mr_for_dest_args)))
+		return -EFAULT;
+
+	/*
+	 * Initially, just behave like get_mr().
+	 * TODO: Implement get_mr as wrapper around this
+	 *	 and deprecate it.
+	 */
+	new_args.vec = args.vec;
+	new_args.cookie_addr = args.cookie_addr;
+	new_args.flags = args.flags;
+
+	return __rds_rdma_map(rs, &new_args, NULL, NULL);
+}
+
 /*
  * Free the MR indicated by the given R_Key
  */
diff --git a/net/rds/rdma.h b/net/rds/rdma.h
index 4255120..909c398 100644
--- a/net/rds/rdma.h
+++ b/net/rds/rdma.h
@@ -61,6 +61,7 @@ static inline u32 rds_rdma_cookie_offset(rds_rdma_cookie_t cookie)
 }
 
 int rds_get_mr(struct rds_sock *rs, char __user *optval, int optlen);
+int rds_get_mr_for_dest(struct rds_sock *rs, char __user *optval, int optlen);
 int rds_free_mr(struct rds_sock *rs, char __user *optval, int optlen);
 void rds_rdma_drop_keys(struct rds_sock *rs);
 int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
-- 
1.6.3.3


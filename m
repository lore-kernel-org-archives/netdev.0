From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v3 16/17] RDS: make message size limit compliant with spec
Date: Mon,  2 Jan 2017 14:45:51 -0800
Message-ID: <1483397152-8307-17-git-send-email-santosh.shilimkar@oracle.com>
References: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Avinash Repaka <avinash.repaka@oracle.com>

RDS support max message size as 1M but the code doesn't check this
in all cases. Patch fixes it for RDMA & non-RDMA and RDS MR size
and its enforced irrespective of underlying transport.

Signed-off-by: Avinash Repaka <avinash.repaka@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/rdma.c |  9 ++++++++-
 net/rds/rds.h  |  3 +++
 net/rds/send.c | 31 +++++++++++++++++++++++++++++++
 3 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 138aef6..f06fac4 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -40,7 +40,6 @@
 /*
  * XXX
  *  - build with sparse
- *  - should we limit the size of a mr region?  let transport return failure?
  *  - should we detect duplicate keys on a socket?  hmm.
  *  - an rdma is an mlock, apply rlimit?
  */
@@ -200,6 +199,14 @@ static int __rds_rdma_map(struct rds_sock *rs, struct rds_get_mr_args *args,
 		goto out;
 	}
 
+	/* Restrict the size of mr irrespective of underlying transport
+	 * To account for unaligned mr regions, subtract one from nr_pages
+	 */
+	if ((nr_pages - 1) > (RDS_MAX_MSG_SIZE >> PAGE_SHIFT)) {
+		ret = -EMSGSIZE;
+		goto out;
+	}
+
 	rdsdebug("RDS: get_mr addr %llx len %llu nr_pages %u\n",
 		args->vec.addr, args->vec.bytes, nr_pages);
 
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 8ccd5a9..f713194 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -50,6 +50,9 @@ void rdsdebug(char *fmt, ...)
 #define RDS_FRAG_SHIFT	12
 #define RDS_FRAG_SIZE	((unsigned int)(1 << RDS_FRAG_SHIFT))
 
+/* Used to limit both RDMA and non-RDMA RDS message to 1MB */
+#define RDS_MAX_MSG_SIZE	((unsigned int)(1 << 20))
+
 #define RDS_CONG_MAP_BYTES	(65536 / 8)
 #define RDS_CONG_MAP_PAGES	(PAGE_ALIGN(RDS_CONG_MAP_BYTES) / PAGE_SIZE)
 #define RDS_CONG_MAP_PAGE_BITS	(PAGE_SIZE * 8)
diff --git a/net/rds/send.c b/net/rds/send.c
index 45e025b..5cc6403 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -994,6 +994,26 @@ static int rds_send_mprds_hash(struct rds_sock *rs, struct rds_connection *conn)
 	return hash;
 }
 
+static int rds_rdma_bytes(struct msghdr *msg, size_t *rdma_bytes)
+{
+	struct rds_rdma_args *args;
+	struct cmsghdr *cmsg;
+
+	for_each_cmsghdr(cmsg, msg) {
+		if (!CMSG_OK(msg, cmsg))
+			return -EINVAL;
+
+		if (cmsg->cmsg_level != SOL_RDS)
+			continue;
+
+		if (cmsg->cmsg_type == RDS_CMSG_RDMA_ARGS) {
+			args = CMSG_DATA(cmsg);
+			*rdma_bytes += args->remote_vec.bytes;
+		}
+	}
+	return 0;
+}
+
 int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 {
 	struct sock *sk = sock->sk;
@@ -1008,6 +1028,7 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	int nonblock = msg->msg_flags & MSG_DONTWAIT;
 	long timeo = sock_sndtimeo(sk, nonblock);
 	struct rds_conn_path *cpath;
+	size_t total_payload_len = payload_len, rdma_payload_len = 0;
 
 	/* Mirror Linux UDP mirror of BSD error message compatibility */
 	/* XXX: Perhaps MSG_MORE someday */
@@ -1040,6 +1061,16 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	}
 	release_sock(sk);
 
+	ret = rds_rdma_bytes(msg, &rdma_payload_len);
+	if (ret)
+		goto out;
+
+	total_payload_len += rdma_payload_len;
+	if (max_t(size_t, payload_len, rdma_payload_len) > RDS_MAX_MSG_SIZE) {
+		ret = -EMSGSIZE;
+		goto out;
+	}
+
 	if (payload_len > rds_sk_sndbuf(rs)) {
 		ret = -EMSGSIZE;
 		goto out;
-- 
1.9.1

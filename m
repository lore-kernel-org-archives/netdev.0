From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v3 07/17] RDS: RDMA: return appropriate error on rdma map failures
Date: Mon,  2 Jan 2017 14:45:42 -0800
Message-ID: <1483397152-8307-8-git-send-email-santosh.shilimkar@oracle.com>
References: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first message to a remote node should prompt a new
connection even if it is RDMA operation. For RDMA operation
the MR mapping can fail because connections is not yet up.

Since the connection establishment is asynchronous,
we make sure the map failure because of unavailable
connection reach to the user by appropriate error code.
Before returning to the user, lets trigger the connection
so that its ready for the next retry.

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/send.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index bb13c56..0a6f38b 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -945,6 +945,11 @@ static int rds_cmsg_send(struct rds_sock *rs, struct rds_message *rm,
 			ret = rds_cmsg_rdma_map(rs, rm, cmsg);
 			if (!ret)
 				*allocated_mr = 1;
+			else if (ret == -ENODEV)
+				/* Accommodate the get_mr() case which can fail
+				 * if connection isn't established yet.
+				 */
+				ret = -EAGAIN;
 			break;
 		case RDS_CMSG_ATOMIC_CSWP:
 		case RDS_CMSG_ATOMIC_FADD:
@@ -1082,8 +1087,12 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 
 	/* Parse any control messages the user may have included. */
 	ret = rds_cmsg_send(rs, rm, msg, &allocated_mr);
-	if (ret)
+	if (ret) {
+		/* Trigger connection so that its ready for the next retry */
+		if (ret ==  -EAGAIN)
+			rds_conn_connect_if_down(conn);
 		goto out;
+	}
 
 	if (rm->rdma.op_active && !conn->c_trans->xmit_rdma) {
 		printk_ratelimited(KERN_NOTICE "rdma_op %p conn xmit_rdma %p\n",
-- 
1.9.1

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 02/13] RDS: Add support for SO_TIMESTAMP for incoming messages
Date: Sat, 20 Feb 2016 03:29:53 -0800
Message-ID: <1455967804-27644-3-git-send-email-santosh.shilimkar@oracle.com>
References: <1455967804-27644-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25222 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2994091AbcBTLaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 06:30:55 -0500
In-Reply-To: <1455967804-27644-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SO_TIMESTAMP generates time stamp for each incoming RDS messages
User app can enable it by using SO_TIMESTAMP setsocketopt() at
SOL_SOCKET level. CMSG data of cmsg type SO_TIMESTAMP contains the
time stamp in struct timeval format.

Reviewed-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/af_rds.c | 26 ++++++++++++++++++++++++++
 net/rds/rds.h    |  1 +
 net/rds/recv.c   | 20 ++++++++++++++++++--
 3 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index b5476aeb..6beaeb1 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -277,6 +277,27 @@ static int rds_set_transport(struct rds_sock *rs, char __user *optval,
 	return rs->rs_transport ? 0 : -ENOPROTOOPT;
 }
 
+static int rds_enable_recvtstamp(struct sock *sk, char __user *optval,
+				 int optlen)
+{
+	int val, valbool;
+
+	if (optlen != sizeof(int))
+		return -EFAULT;
+
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+
+	valbool = val ? 1 : 0;
+
+	if (valbool)
+		sock_set_flag(sk, SOCK_RCVTSTAMP);
+	else
+		sock_reset_flag(sk, SOCK_RCVTSTAMP);
+
+	return 0;
+}
+
 static int rds_setsockopt(struct socket *sock, int level, int optname,
 			  char __user *optval, unsigned int optlen)
 {
@@ -312,6 +333,11 @@ static int rds_setsockopt(struct socket *sock, int level, int optname,
 		ret = rds_set_transport(rs, optval, optlen);
 		release_sock(sock->sk);
 		break;
+	case SO_TIMESTAMP:
+		lock_sock(sock->sk);
+		ret = rds_enable_recvtstamp(sock->sk, optval, optlen);
+		release_sock(sock->sk);
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 	}
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 0e2797b..80256b0 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -222,6 +222,7 @@ struct rds_incoming {
 	__be32			i_saddr;
 
 	rds_rdma_cookie_t	i_rdma_cookie;
+	struct timeval		i_rx_tstamp;
 };
 
 struct rds_mr {
diff --git a/net/rds/recv.c b/net/rds/recv.c
index a00462b..c0be1ec 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -35,6 +35,8 @@
 #include <net/sock.h>
 #include <linux/in.h>
 #include <linux/export.h>
+#include <linux/time.h>
+#include <linux/rds.h>
 
 #include "rds.h"
 
@@ -46,6 +48,8 @@ void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
 	inc->i_conn = conn;
 	inc->i_saddr = saddr;
 	inc->i_rdma_cookie = 0;
+	inc->i_rx_tstamp.tv_sec = 0;
+	inc->i_rx_tstamp.tv_usec = 0;
 }
 EXPORT_SYMBOL_GPL(rds_inc_init);
 
@@ -228,6 +232,8 @@ void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 		rds_recv_rcvbuf_delta(rs, sk, inc->i_conn->c_lcong,
 				      be32_to_cpu(inc->i_hdr.h_len),
 				      inc->i_hdr.h_dport);
+		if (sock_flag(sk, SOCK_RCVTSTAMP))
+			do_gettimeofday(&inc->i_rx_tstamp);
 		rds_inc_addref(inc);
 		list_add_tail(&inc->i_item, &rs->rs_recv_queue);
 		__rds_wake_sk_sleep(sk);
@@ -381,7 +387,8 @@ static int rds_notify_cong(struct rds_sock *rs, struct msghdr *msghdr)
 /*
  * Receive any control messages.
  */
-static int rds_cmsg_recv(struct rds_incoming *inc, struct msghdr *msg)
+static int rds_cmsg_recv(struct rds_incoming *inc, struct msghdr *msg,
+			 struct rds_sock *rs)
 {
 	int ret = 0;
 
@@ -392,6 +399,15 @@ static int rds_cmsg_recv(struct rds_incoming *inc, struct msghdr *msg)
 			return ret;
 	}
 
+	if ((inc->i_rx_tstamp.tv_sec != 0) &&
+	    sock_flag(rds_rs_to_sk(rs), SOCK_RCVTSTAMP)) {
+		ret = put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP,
+			       sizeof(struct timeval),
+			       &inc->i_rx_tstamp);
+		if (ret)
+			return ret;
+	}
+
 	return 0;
 }
 
@@ -474,7 +490,7 @@ int rds_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 			msg->msg_flags |= MSG_TRUNC;
 		}
 
-		if (rds_cmsg_recv(inc, msg)) {
+		if (rds_cmsg_recv(inc, msg, rs)) {
 			ret = -EFAULT;
 			goto out;
 		}
-- 
1.9.1

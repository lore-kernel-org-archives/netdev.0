From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Fri, 11 Mar 2016 13:29:49 -0500
Message-ID: <20160311182949.GG3383@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37357 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbcCKS3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 13:29:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some payload sizes/patterns stand to gain performance benefits by
tuning the size of the TCP socket buffers, so this commit adds
module parameters to customize those values when desired.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index ad60299..b59e7a2 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -52,7 +52,13 @@ static LIST_HEAD(rds_tcp_conn_list);
 
 static struct kmem_cache *rds_tcp_conn_slab;
 
-#define RDS_TCP_DEFAULT_BUFSIZE (128 * 1024)
+static int sndbuf_size = 16384;
+module_param(sndbuf_size, int, 0444);
+MODULE_PARM_DESC(sndbuf_size, "SO_SNDBUF size of kernel tcp socket");
+
+static int rcvbuf_size = 87380;
+module_param(rcvbuf_size, int, 0444);
+MODULE_PARM_DESC(rcvbuf_size, "SO_RCVBUF size of kernel tcp socket");
 
 /* doing it this way avoids calling tcp_sk() */
 void rds_tcp_nonagle(struct socket *sock)
@@ -72,7 +78,15 @@ void rds_tcp_nonagle(struct socket *sock)
  */
 void rds_tcp_tune(struct socket *sock)
 {
+	struct sock *sk = sock->sk;
+
 	rds_tcp_nonagle(sock);
+
+	lock_sock(sk);
+	sk->sk_sndbuf = sndbuf_size;
+	sk->sk_rcvbuf = rcvbuf_size;
+	sk->sk_userlocks |= SOCK_SNDBUF_LOCK | SOCK_RCVBUF_LOCK;
+	release_sock(sk);
 }
 
 u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc)
-- 
1.7.1

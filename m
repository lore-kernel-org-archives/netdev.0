From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/3] RDS-TCP: Do not bloat sndbuf/rcvbuf in rds_tcp_tune
Date: Wed, 30 Sep 2015 09:45:53 -0400
Message-ID: <516b757660b32ff77caacd0dec56ac6970bbc4d9.1443569239.git.sowmini.varadhan@oracle.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1443569239.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1443569239.git.sowmini.varadhan@oracle.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using the value of RDS_TCP_DEFAULT_BUFSIZE (128K)
clobbers efficient use of TSO because it inflates the size_goal
that is computed in tcp_sendmsg/tcp_sendpage and skews packet
latency, and the default values for these parameters actually
results in significantly better performance.

In request-response tests using rds-stress with a packet size of
100K with 16 threads (test parameters -q 100000 -a 256 -t16 -d16)
between a single pair of IP addresses achieves a throughput of
6-8 Gbps. Without this patch, throughput maxes at 2-3 Gbps under
equivalent conditions on these platforms.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index c42b60b..9d6ddba 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -67,21 +67,13 @@ void rds_tcp_nonagle(struct socket *sock)
 	set_fs(oldfs);
 }
 
+/* All module specific customizations to the RDS-TCP socket should be done in
+ * rds_tcp_tune() and applied after socket creation. In general these
+ * customizations should be tunable via module_param()
+ */
 void rds_tcp_tune(struct socket *sock)
 {
-	struct sock *sk = sock->sk;
-
 	rds_tcp_nonagle(sock);
-
-	/*
-	 * We're trying to saturate gigabit with the default,
-	 * see svc_sock_setbufsize().
-	 */
-	lock_sock(sk);
-	sk->sk_sndbuf = RDS_TCP_DEFAULT_BUFSIZE;
-	sk->sk_rcvbuf = RDS_TCP_DEFAULT_BUFSIZE;
-	sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
-	release_sock(sk);
 }
 
 u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc)
-- 
1.7.1

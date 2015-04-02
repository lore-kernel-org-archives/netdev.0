From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2 6/6] RDS: don't trust the LL_SEND_FULL bit
Date: Thu,  2 Apr 2015 10:19:40 -0400
Message-ID: <9beb842f86688d9e2a95fb9c0d57672b98a6d05b.1427983908.git.sowmini.varadhan@oracle.com>
References: <cover.1427983908.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28501 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbbDBOT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:19:57 -0400
In-Reply-To: <cover.1427983908.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1427983908.git.sowmini.varadhan@oracle.com>
References: <cover.1427983908.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing connections stuck with the LL_SEND_FULL bit getting
set and never cleared.  This changes RDS to stop trusting the
LL_SEND_FULL bit and kick krdsd after any time we
see -ENOMEM from the ring allocation code.

Original patch by Chris Mason

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>

---
v2: comments from Sergei Shtylyov

 net/rds/send.c    |   10 ++++++----
 net/rds/threads.c |    2 ++
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 23135a8..8e2b36a 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1108,8 +1108,9 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	 */
 	rds_stats_inc(s_send_queued);
 
-	if (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags))
-		rds_send_xmit(conn);
+	ret = rds_send_xmit(conn);
+	if (ret == -ENOMEM || ret == -EAGAIN)
+		queue_delayed_work(rds_wq, &conn->c_send_w, 1);
 
 	rds_message_put(rm);
 	return payload_len;
@@ -1165,8 +1166,9 @@ rds_send_pong(struct rds_connection *conn, __be16 dport)
 	rds_stats_inc(s_send_queued);
 	rds_stats_inc(s_send_pong);
 
-	if (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags))
-		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
+	ret = rds_send_xmit(conn);
+	if (ret == -ENOMEM || ret == -EAGAIN)
+		queue_delayed_work(rds_wq, &conn->c_send_w, 1);
 
 	rds_message_put(rm);
 	return 0;
diff --git a/net/rds/threads.c b/net/rds/threads.c
index dc2402e..454aa6d 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -162,7 +162,9 @@ void rds_send_worker(struct work_struct *work)
 	int ret;
 
 	if (rds_conn_state(conn) == RDS_CONN_UP) {
+		clear_bit(RDS_LL_SEND_FULL, &conn->c_flags);
 		ret = rds_send_xmit(conn);
+		cond_resched();
 		rdsdebug("conn %p ret %d\n", conn, ret);
 		switch (ret) {
 		case -EAGAIN:
-- 
1.7.1

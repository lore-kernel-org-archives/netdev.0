From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 6/6] RDS: don't trust the LL_SEND_FULL bit
Date: Thu,  2 Apr 2015 09:50:49 -0400
Message-ID: <dbc7c4e9d12f373c971c5b0d0e5936abb345ea7c.1427936719.git.sowmini.varadhan@oracle.com>
References: <cover.1427936719.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48541 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbbDBN4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 09:56:07 -0400
In-Reply-To: <cover.1427936719.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1427936719.git.sowmini.varadhan@oracle.com>
References: <cover.1427936719.git.sowmini.varadhan@oracle.com>
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
 net/rds/send.c    |   11 +++++++----
 net/rds/threads.c |    2 ++
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 23135a8..9d9c90c 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1108,8 +1108,10 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	 */
 	rds_stats_inc(s_send_queued);
 
-	if (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags))
-		rds_send_xmit(conn);
+	ret = rds_send_xmit(conn);
+	if (ret == -ENOMEM || ret == -EAGAIN)
+		queue_delayed_work(rds_wq, &conn->c_send_w, 1);
+
 
 	rds_message_put(rm);
 	return payload_len;
@@ -1165,8 +1167,9 @@ rds_send_pong(struct rds_connection *conn, __be16 dport)
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

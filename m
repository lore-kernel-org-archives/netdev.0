From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH v3 06/14] RDS: use rds_send_xmit() state instead of RDS_LL_SEND_FULL
Date: Mon,  5 Oct 2015 10:56:29 -0700
Message-ID: <1444067797-14101-7-git-send-email-santosh.shilimkar@oracle.com>
References: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In Transport indepedent rds_sendmsg(), we shouldn't make decisions based
on RDS_LL_SEND_FULL which is used to manage the ring for RDMA based
transports. We can safely issue rds_send_xmit() and the using its
return value take decision on deferred work. This will also fix
the scenario where at times we are seeing connections stuck with
the LL_SEND_FULL bit getting set and never cleared.

We kick krdsd after any time we see -ENOMEM or -EAGAIN from the
ring allocation code.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/send.c    | 10 ++++++----
 net/rds/threads.c |  2 ++
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index b3406da..81ac604 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1122,8 +1122,9 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	 */
 	rds_stats_inc(s_send_queued);
 
-	if (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags))
-		rds_send_xmit(conn);
+	ret = rds_send_xmit(conn);
+	if (ret == -ENOMEM || ret == -EAGAIN)
+		queue_delayed_work(rds_wq, &conn->c_send_w, 1);
 
 	rds_message_put(rm);
 	return payload_len;
@@ -1179,8 +1180,9 @@ rds_send_pong(struct rds_connection *conn, __be16 dport)
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
1.9.1

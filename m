From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2 4/6] RDS: make sure not to loop forever inside rds_send_xmit
Date: Thu,  2 Apr 2015 10:19:38 -0400
Message-ID: <874dcb97cd3ab989259ac41c5e503ee978daabf5.1427983908.git.sowmini.varadhan@oracle.com>
References: <cover.1427983908.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427983908.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1427983908.git.sowmini.varadhan@oracle.com>
References: <cover.1427983908.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a determined set of concurrent senders keep the send queue full,
we can loop forever inside rds_send_xmit.  This fix has two parts.

First we are dropping out of the while(1) loop after we've processed a
large batch of messages.

Second we add a generation number that gets bumped each time the
xmit bit lock is acquired.  If someone else has jumped in and
made progress in the queue, we skip our goto restart.

Original patch by Chris Mason.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
---
 net/rds/connection.c |    1 +
 net/rds/rds.h        |    1 +
 net/rds/send.c       |   47 +++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 7952a5b..14f0413 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -193,6 +193,7 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 	}
 
 	atomic_set(&conn->c_state, RDS_CONN_DOWN);
+	conn->c_send_gen = 0;
 	conn->c_reconnect_jiffies = 0;
 	INIT_DELAYED_WORK(&conn->c_send_w, rds_send_worker);
 	INIT_DELAYED_WORK(&conn->c_recv_w, rds_recv_worker);
diff --git a/net/rds/rds.h b/net/rds/rds.h
index c3f2855..0d41155 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -110,6 +110,7 @@ struct rds_connection {
 	void			*c_transport_data;
 
 	atomic_t		c_state;
+	unsigned long		c_send_gen;
 	unsigned long		c_flags;
 	unsigned long		c_reconnect_jiffies;
 	struct delayed_work	c_send_w;
diff --git a/net/rds/send.c b/net/rds/send.c
index b1741a2..aec3f9d 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -141,9 +141,13 @@ int rds_send_xmit(struct rds_connection *conn)
 	int ret = 0;
 	LIST_HEAD(to_be_dropped);
 	int same_rm = 0;
+	int batch_count;
+	unsigned long send_gen = 0;
 
 restart:
 
+	batch_count = 0;
+
 	/*
 	 * sendmsg calls here after having queued its message on the send
 	 * queue.  We only have one task feeding the connection at a time.  If
@@ -158,6 +162,17 @@ int rds_send_xmit(struct rds_connection *conn)
 	}
 
 	/*
+	 * we record the send generation after doing the xmit acquire.
+	 * if someone else manages to jump in and do some work, we'll use
+	 * this to avoid a goto restart farther down.
+	 *
+	 * we don't need a lock because the counter is only incremented
+	 * while we have the in_xmit bit held.
+	 */
+	conn->c_send_gen++;
+	send_gen = conn->c_send_gen;
+
+	/*
 	 * rds_conn_shutdown() sets the conn state and then tests RDS_IN_XMIT,
 	 * we do the opposite to avoid races.
 	 */
@@ -215,6 +230,16 @@ int rds_send_xmit(struct rds_connection *conn)
 		if (!rm) {
 			unsigned int len;
 
+			batch_count++;
+
+			/* we want to process as big a batch as we can, but
+			 * we also want to avoid softlockups.  If we've been
+			 * through a lot of messages, lets back off and see
+			 * if anyone else jumps in
+			 */
+			if (batch_count >= 1024)
+				goto over_batch;
+
 			spin_lock_irqsave(&conn->c_lock, flags);
 
 			if (!list_empty(&conn->c_send_queue)) {
@@ -370,9 +395,9 @@ int rds_send_xmit(struct rds_connection *conn)
 		}
 	}
 
+over_batch:
 	if (conn->c_trans->xmit_complete)
 		conn->c_trans->xmit_complete(conn);
-
 	release_in_xmit(conn);
 
 	/* Nuke any messages we decided not to retransmit. */
@@ -393,12 +418,26 @@ int rds_send_xmit(struct rds_connection *conn)
 	 * If the transport cannot continue (i.e ret != 0), then it must
 	 * call us when more room is available, such as from the tx
 	 * completion handler.
+	 *
+	 * We have an extra generation check here so that if someone manages
+	 * to jump in after our release_in_xmit, we'll see that they have done
+	 * some work and we will skip our goto
 	 */
 	if (ret == 0) {
 		smp_mb();
-		if (!list_empty(&conn->c_send_queue)) {
-			rds_stats_inc(s_send_lock_queue_raced);
-			goto restart;
+		if (!list_empty(&conn->c_send_queue) &&
+		    send_gen == conn->c_send_gen) {
+			cond_resched();
+			/* repeat our check after the resched in case
+			 * someone else was kind enough to empty or process
+			 * the queue
+			 */
+			smp_mb();
+			if (!list_empty(&conn->c_send_queue) &&
+			    send_gen == conn->c_send_gen) {
+				rds_stats_inc(s_send_lock_queue_raced);
+				goto restart;
+			}
 		}
 	}
 out:
-- 
1.7.1

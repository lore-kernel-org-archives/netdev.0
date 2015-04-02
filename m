From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 5/6] RDS: rds_send_xmit is called under a spinlock, lets not do a cond_resched()
Date: Thu,  2 Apr 2015 09:50:48 -0400
Message-ID: <4b4fb362d20a5c97165f929d049065518f7fa108.1427936719.git.sowmini.varadhan@oracle.com>
References: <cover.1427936719.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427936719.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1427936719.git.sowmini.varadhan@oracle.com>
References: <cover.1427936719.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Original patch by Chris Mason

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/send.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index aec3f9d..23135a8 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -199,7 +199,6 @@ int rds_send_xmit(struct rds_connection *conn)
 			same_rm++;
 			if (same_rm >= 4096) {
 				printk_ratelimited(KERN_ERR "RDS: Stuck rm\n");
-				cond_resched();
 				ret = -EAGAIN;
 				break;
 			}
@@ -427,17 +426,8 @@ int rds_send_xmit(struct rds_connection *conn)
 		smp_mb();
 		if (!list_empty(&conn->c_send_queue) &&
 		    send_gen == conn->c_send_gen) {
-			cond_resched();
-			/* repeat our check after the resched in case
-			 * someone else was kind enough to empty or process
-			 * the queue
-			 */
-			smp_mb();
-			if (!list_empty(&conn->c_send_queue) &&
-			    send_gen == conn->c_send_gen) {
-				rds_stats_inc(s_send_lock_queue_raced);
-				goto restart;
-			}
+			rds_stats_inc(s_send_lock_queue_raced);
+			goto restart;
 		}
 	}
 out:
-- 
1.7.1

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 06/15] RDS: defer the over_batch work to send worker
Date: Sat, 19 Sep 2015 19:04:43 -0400
Message-ID: <1442703892-26692-7-git-send-email-santosh.shilimkar@oracle.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current process gives up if its send work over the batch limit.
The work queue will get  kicked to finish off any other requests.
This fixes remainder condition from commit 443be0e5affe ("RDS: make
sure not to loop forever inside rds_send_xmit").

The restart condition is only for the case where we reached to
over_batch code for some other reason so just retrying again
before giving up.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/send.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 4df61a5..f1e709c 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -423,7 +423,9 @@ over_batch:
 		     !list_empty(&conn->c_send_queue)) &&
 		    send_gen == conn->c_send_gen) {
 			rds_stats_inc(s_send_lock_queue_raced);
-			goto restart;
+			if (batch_count < 1024)
+				goto restart;
+			queue_delayed_work(rds_wq, &conn->c_send_w, 1);
 		}
 	}
 out:
-- 
1.9.1

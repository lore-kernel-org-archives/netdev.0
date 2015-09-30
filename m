From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 05/14] RDS: defer the over_batch work to send worker
Date: Wed, 30 Sep 2015 13:24:24 -0400
Message-ID: <1443633873-13359-6-git-send-email-santosh.shilimkar@oracle.com>
References: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443633873-13359-1-git-send-email-santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Current process gives up if its send work over the batch limit.
The work queue will get  kicked to finish off any other requests.
This fixes remainder condition from commit 443be0e5affe ("RDS: make
sure not to loop forever inside rds_send_xmit").

The restart condition is only for the case where we reached to
over_batch code for some other reason so just retrying again
before giving up.

Signed-off-by: Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

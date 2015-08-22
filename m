From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 02/14] RDS: always free recv frag as we free its ring entry
Date: Sat, 22 Aug 2015 15:45:23 -0700
Message-ID: <1440283535-4800-3-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We were still seeing rare occurrences of the WARN_ON(recv->r_frag) which
indicates that the recv refill path was finding allocated frags in ring
entries that were marked free. These were usually followed by OOM crashes.
They only seem to be occurring in the presence of completion errors and
connection resets.

This patch ensures that we free the frag as we mark the ring entry free.
This should stop the refill path from finding allocated frags in ring
entries that were marked free.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_recv.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index cac5b45..2a6a75c 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -982,10 +982,17 @@ static inline void rds_poll_cq(struct rds_ib_connection *ic,
 		}
 
 		/*
-		 * It's very important that we only free this ring entry if we've truly
-		 * freed the resources allocated to the entry.  The refilling path can
-		 * leak if we don't.
+		 * rds_ib_process_recv() doesn't always consume the frag, and
+		 * we might not have called it at all if the wc didn't indicate
+		 * success. We already unmapped the frag's pages, though, and
+		 * the following rds_ib_ring_free() call tells the refill path
+		 * that it will not find an allocated frag here. Make sure we
+		 * keep that promise by freeing a frag that's still on the ring.
 		 */
+		if (recv->r_frag) {
+			rds_ib_frag_free(ic, recv->r_frag);
+			recv->r_frag = NULL;
+		}
 		rds_ib_ring_free(&ic->i_recv_ring, 1);
 	}
 }
-- 
1.9.1

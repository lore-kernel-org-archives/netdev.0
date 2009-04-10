From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 04/12] RDS/IW+IB: Allow max credit advertise window.
Date: Thu,  9 Apr 2009 17:09:39 -0700
Message-ID: <1239322187-3764-5-git-send-email-andy.grover@oracle.com>
References: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Steve Wise <swise@opengridcomputing.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:53281 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937152AbZDJAKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 20:10:04 -0400
In-Reply-To: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Fix hack that restricts the credit advertisement to 127.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib.h      |    2 +-
 net/rds/ib_recv.c |    2 +-
 net/rds/ib_send.c |    8 ++++----
 net/rds/iw.h      |    2 +-
 net/rds/iw_recv.c |    2 +-
 net/rds/iw_send.c |    8 ++++----
 net/rds/rds.h     |    2 +-
 7 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index 069206c..455ae73 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -333,7 +333,7 @@ int rds_ib_xmit_rdma(struct rds_connection *conn, struct rds_rdma_op *op);
 void rds_ib_send_add_credits(struct rds_connection *conn, unsigned int credits);
 void rds_ib_advertise_credits(struct rds_connection *conn, unsigned int posted);
 int rds_ib_send_grab_credits(struct rds_ib_connection *ic, u32 wanted,
-			     u32 *adv_credits, int need_posted);
+			     u32 *adv_credits, int need_posted, int max_posted);
 
 /* ib_stats.c */
 DECLARE_PER_CPU(struct rds_ib_statistics, rds_ib_stats);
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 36d9315..5709bad 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -524,7 +524,7 @@ void rds_ib_attempt_ack(struct rds_ib_connection *ic)
 	}
 
 	/* Can we get a send credit? */
-	if (!rds_ib_send_grab_credits(ic, 1, &adv_credits, 0)) {
+	if (!rds_ib_send_grab_credits(ic, 1, &adv_credits, 0, RDS_MAX_ADV_CREDIT)) {
 		rds_ib_stats_inc(s_ib_tx_throttle);
 		clear_bit(IB_ACK_IN_FLIGHT, &ic->i_ack_flags);
 		return;
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index fa684b7..23bf830 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -311,7 +311,7 @@ void rds_ib_send_cq_comp_handler(struct ib_cq *cq, void *context)
  * and using atomic_cmpxchg when updating the two counters.
  */
 int rds_ib_send_grab_credits(struct rds_ib_connection *ic,
-			     u32 wanted, u32 *adv_credits, int need_posted)
+			     u32 wanted, u32 *adv_credits, int need_posted, int max_posted)
 {
 	unsigned int avail, posted, got = 0, advertise;
 	long oldval, newval;
@@ -351,7 +351,7 @@ try_again:
 	 * available.
 	 */
 	if (posted && (got || need_posted)) {
-		advertise = min_t(unsigned int, posted, RDS_MAX_ADV_CREDIT);
+		advertise = min_t(unsigned int, posted, max_posted);
 		newval -= IB_SET_POST_CREDITS(advertise);
 	}
 
@@ -498,7 +498,7 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 
 	credit_alloc = work_alloc;
 	if (ic->i_flowctl) {
-		credit_alloc = rds_ib_send_grab_credits(ic, work_alloc, &posted, 0);
+		credit_alloc = rds_ib_send_grab_credits(ic, work_alloc, &posted, 0, RDS_MAX_ADV_CREDIT);
 		adv_credits += posted;
 		if (credit_alloc < work_alloc) {
 			rds_ib_ring_unalloc(&ic->i_send_ring, work_alloc - credit_alloc);
@@ -571,7 +571,7 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 		/*
 		 * Update adv_credits since we reset the ACK_REQUIRED bit.
 		 */
-		rds_ib_send_grab_credits(ic, 0, &posted, 1);
+		rds_ib_send_grab_credits(ic, 0, &posted, 1, RDS_MAX_ADV_CREDIT - adv_credits);
 		adv_credits += posted;
 		BUG_ON(adv_credits > 255);
 	} else if (ic->i_rm != rm)
diff --git a/net/rds/iw.h b/net/rds/iw.h
index b4fb272..0715dde 100644
--- a/net/rds/iw.h
+++ b/net/rds/iw.h
@@ -361,7 +361,7 @@ int rds_iw_xmit_rdma(struct rds_connection *conn, struct rds_rdma_op *op);
 void rds_iw_send_add_credits(struct rds_connection *conn, unsigned int credits);
 void rds_iw_advertise_credits(struct rds_connection *conn, unsigned int posted);
 int rds_iw_send_grab_credits(struct rds_iw_connection *ic, u32 wanted,
-			     u32 *adv_credits, int need_posted);
+			     u32 *adv_credits, int need_posted, int max_posted);
 
 /* ib_stats.c */
 DECLARE_PER_CPU(struct rds_iw_statistics, rds_iw_stats);
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
index fde470f..8683f5f 100644
--- a/net/rds/iw_recv.c
+++ b/net/rds/iw_recv.c
@@ -524,7 +524,7 @@ void rds_iw_attempt_ack(struct rds_iw_connection *ic)
 	}
 
 	/* Can we get a send credit? */
-	if (!rds_iw_send_grab_credits(ic, 1, &adv_credits, 0)) {
+	if (!rds_iw_send_grab_credits(ic, 1, &adv_credits, 0, RDS_MAX_ADV_CREDIT)) {
 		rds_iw_stats_inc(s_iw_tx_throttle);
 		clear_bit(IB_ACK_IN_FLIGHT, &ic->i_ack_flags);
 		return;
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index 626290b..44a6a05 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -347,7 +347,7 @@ void rds_iw_send_cq_comp_handler(struct ib_cq *cq, void *context)
  * and using atomic_cmpxchg when updating the two counters.
  */
 int rds_iw_send_grab_credits(struct rds_iw_connection *ic,
-			     u32 wanted, u32 *adv_credits, int need_posted)
+			     u32 wanted, u32 *adv_credits, int need_posted, int max_posted)
 {
 	unsigned int avail, posted, got = 0, advertise;
 	long oldval, newval;
@@ -387,7 +387,7 @@ try_again:
 	 * available.
 	 */
 	if (posted && (got || need_posted)) {
-		advertise = min_t(unsigned int, posted, RDS_MAX_ADV_CREDIT);
+		advertise = min_t(unsigned int, posted, max_posted);
 		newval -= IB_SET_POST_CREDITS(advertise);
 	}
 
@@ -541,7 +541,7 @@ int rds_iw_xmit(struct rds_connection *conn, struct rds_message *rm,
 
 	credit_alloc = work_alloc;
 	if (ic->i_flowctl) {
-		credit_alloc = rds_iw_send_grab_credits(ic, work_alloc, &posted, 0);
+		credit_alloc = rds_iw_send_grab_credits(ic, work_alloc, &posted, 0, RDS_MAX_ADV_CREDIT);
 		adv_credits += posted;
 		if (credit_alloc < work_alloc) {
 			rds_iw_ring_unalloc(&ic->i_send_ring, work_alloc - credit_alloc);
@@ -614,7 +614,7 @@ int rds_iw_xmit(struct rds_connection *conn, struct rds_message *rm,
 		/*
 		 * Update adv_credits since we reset the ACK_REQUIRED bit.
 		 */
-		rds_iw_send_grab_credits(ic, 0, &posted, 1);
+		rds_iw_send_grab_credits(ic, 0, &posted, 1, RDS_MAX_ADV_CREDIT - adv_credits);
 		adv_credits += posted;
 		BUG_ON(adv_credits > 255);
 	} else if (ic->i_rm != rm)
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 619f0a3..1f82ec0 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -132,7 +132,7 @@ struct rds_connection {
 #define RDS_FLAG_CONG_BITMAP	0x01
 #define RDS_FLAG_ACK_REQUIRED	0x02
 #define RDS_FLAG_RETRANSMITTED	0x04
-#define RDS_MAX_ADV_CREDIT	127
+#define RDS_MAX_ADV_CREDIT	255
 
 /*
  * Maximum space available for extension headers.
-- 
1.5.6.3


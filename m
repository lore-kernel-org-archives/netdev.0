From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net] bnx2x: bail out if unable to acquire stats_sema
Date: Tue,  3 Sep 2013 17:45:59 +0200
Message-ID: <1378223159-8710-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, Dmitry Kravkov <dmitry@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754607Ab3ICPqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 11:46:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we fail to acquire stats_sema in the specified time limit,
the chip is probably dead. It probably does not matter whether we
try to continue or not, but certainly we should not up() the semaphore
afterwards.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 24 +++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 86436c7..d60bb8b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -538,16 +538,20 @@ static void __bnx2x_stats_start(struct bnx2x *bp)
 
 static void bnx2x_stats_start(struct bnx2x *bp)
 {
-	if (down_timeout(&bp->stats_sema, HZ/10))
+	if (down_timeout(&bp->stats_sema, HZ/10)) {
 		BNX2X_ERR("Unable to acquire stats lock\n");
+		return;
+	}
 	__bnx2x_stats_start(bp);
 	up(&bp->stats_sema);
 }
 
 static void bnx2x_stats_pmf_start(struct bnx2x *bp)
 {
-	if (down_timeout(&bp->stats_sema, HZ/10))
+	if (down_timeout(&bp->stats_sema, HZ/10)) {
 		BNX2X_ERR("Unable to acquire stats lock\n");
+		return;
+	}
 	bnx2x_stats_comp(bp);
 	__bnx2x_stats_pmf_update(bp);
 	__bnx2x_stats_start(bp);
@@ -556,8 +560,10 @@ static void bnx2x_stats_pmf_start(struct bnx2x *bp)
 
 static void bnx2x_stats_pmf_update(struct bnx2x *bp)
 {
-	if (down_timeout(&bp->stats_sema, HZ/10))
+	if (down_timeout(&bp->stats_sema, HZ/10)) {
 		BNX2X_ERR("Unable to acquire stats lock\n");
+		return;
+	}
 	__bnx2x_stats_pmf_update(bp);
 	up(&bp->stats_sema);
 }
@@ -569,8 +575,10 @@ static void bnx2x_stats_restart(struct bnx2x *bp)
 	 */
 	if (IS_VF(bp))
 		return;
-	if (down_timeout(&bp->stats_sema, HZ/10))
+	if (down_timeout(&bp->stats_sema, HZ/10)) {
 		BNX2X_ERR("Unable to acquire stats lock\n");
+		return;
+	}
 	bnx2x_stats_comp(bp);
 	__bnx2x_stats_start(bp);
 	up(&bp->stats_sema);
@@ -1361,8 +1369,10 @@ static void bnx2x_stats_stop(struct bnx2x *bp)
 {
 	int update = 0;
 
-	if (down_timeout(&bp->stats_sema, HZ/10))
+	if (down_timeout(&bp->stats_sema, HZ/10)) {
 		BNX2X_ERR("Unable to acquire stats lock\n");
+		return;
+	}
 
 	bp->stats_started = false;
 
@@ -1997,8 +2007,10 @@ void bnx2x_afex_collect_stats(struct bnx2x *bp, void *void_afex_stats,
 void bnx2x_stats_safe_exec(struct bnx2x *bp,
 			   void (func_to_exec)(void *cookie),
 			   void *cookie){
-	if (down_timeout(&bp->stats_sema, HZ/10))
+	if (down_timeout(&bp->stats_sema, HZ/10)) {
 		BNX2X_ERR("Unable to acquire stats lock\n");
+		return;
+	}
 	bnx2x_stats_comp(bp);
 	func_to_exec(cookie);
 	__bnx2x_stats_start(bp);
-- 
1.8.3.1

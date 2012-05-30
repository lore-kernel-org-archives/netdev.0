From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net 3/3] bql: Avoid possible inconsistent calculation.
Date: Thu, 31 May 2012 07:25:37 +0900
Message-ID: <20120531072537.920f0cb0.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, denys@visp.net.lb,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:39139 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757180Ab2E3WZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 18:25:40 -0400
Received: by mail-pz0-f46.google.com with SMTP id y13so388540dad.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 15:25:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dql->num_queued could change while processing dql_completed().
To provide consistent calculation, added an on stack variable.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Denys Fedoryshchenko <denys@visp.net.lb>
---
 lib/dynamic_queue_limits.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
index 0fafa77..0777c5a 100644
--- a/lib/dynamic_queue_limits.c
+++ b/lib/dynamic_queue_limits.c
@@ -17,16 +17,18 @@
 void dql_completed(struct dql *dql, unsigned int count)
 {
 	unsigned int inprogress, prev_inprogress, limit;
-	unsigned int ovlimit, completed;
+	unsigned int ovlimit, completed, num_queued;
 	bool all_prev_completed;
 
+	num_queued = ACCESS_ONCE(dql->num_queued);
+
 	/* Can't complete more than what's in queue */
-	BUG_ON(count > dql->num_queued - dql->num_completed);
+	BUG_ON(count > num_queued - dql->num_completed);
 
 	completed = dql->num_completed + count;
 	limit = dql->limit;
-	ovlimit = POSDIFF(dql->num_queued - dql->num_completed, limit);
-	inprogress = dql->num_queued - completed;
+	ovlimit = POSDIFF(num_queued - dql->num_completed, limit);
+	inprogress = num_queued - completed;
 	prev_inprogress = dql->prev_num_queued - dql->num_completed;
 	all_prev_completed = AFTER_EQ(completed, dql->prev_num_queued);
 
@@ -106,7 +108,7 @@ void dql_completed(struct dql *dql, unsigned int count)
 	dql->prev_ovlimit = ovlimit;
 	dql->prev_last_obj_cnt = dql->last_obj_cnt;
 	dql->num_completed = completed;
-	dql->prev_num_queued = dql->num_queued;
+	dql->prev_num_queued = num_queued;
 }
 EXPORT_SYMBOL(dql_completed);
 
-- 
1.7.3.4

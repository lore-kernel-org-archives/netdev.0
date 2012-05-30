From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net 2/3] bql: Avoid unneeded limit decrement.
Date: Thu, 31 May 2012 07:25:19 +0900
Message-ID: <20120531072519.16464513.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, denys@visp.net.lb,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:39139 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754850Ab2E3WZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 18:25:22 -0400
Received: by dady13 with SMTP id y13so388540dad.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 15:25:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When below pattern is observed,

                                               TIME
       dql_queued()         dql_completed()     |
      a) initial state                          |
                                                |
      b) X bytes queued                         V

      c) Y bytes queued
                           d) X bytes completed
      e) Z bytes queued
                           f) Y bytes completed

a) dql->limit has already some value and there is no in-flight packet.
b) X bytes queued.
c) Y bytes queued and excess limit.
d) X bytes completed and dql->prev_ovlimit is set and also
   dql->prev_num_queued is set Y.
e) Z bytes queued.
f) Y bytes completed. inprogress and prev_inprogress are true.

At f), according to the comment, all_prev_completed becomes
true and limit should be increased. But POSDIFF() ignores
(completed == dql->prev_num_queued) case, so limit is decreased.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Denys Fedoryshchenko <denys@visp.net.lb>
---
 lib/dynamic_queue_limits.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
index c87eb76..0fafa77 100644
--- a/lib/dynamic_queue_limits.c
+++ b/lib/dynamic_queue_limits.c
@@ -11,12 +11,14 @@
 #include <linux/dynamic_queue_limits.h>
 
 #define POSDIFF(A, B) ((int)((A) - (B)) > 0 ? (A) - (B) : 0)
+#define AFTER_EQ(A, B) ((int)((A) - (B)) >= 0)
 
 /* Records completed count and recalculates the queue limit */
 void dql_completed(struct dql *dql, unsigned int count)
 {
 	unsigned int inprogress, prev_inprogress, limit;
-	unsigned int ovlimit, all_prev_completed, completed;
+	unsigned int ovlimit, completed;
+	bool all_prev_completed;
 
 	/* Can't complete more than what's in queue */
 	BUG_ON(count > dql->num_queued - dql->num_completed);
@@ -26,7 +28,7 @@ void dql_completed(struct dql *dql, unsigned int count)
 	ovlimit = POSDIFF(dql->num_queued - dql->num_completed, limit);
 	inprogress = dql->num_queued - completed;
 	prev_inprogress = dql->prev_num_queued - dql->num_completed;
-	all_prev_completed = POSDIFF(completed, dql->prev_num_queued);
+	all_prev_completed = AFTER_EQ(completed, dql->prev_num_queued);
 
 	if ((ovlimit && !inprogress) ||
 	    (dql->prev_ovlimit && all_prev_completed)) {
-- 
1.7.3.4

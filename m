From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 4/6] neigh: align the usage of neigh timer with one of sock timer
Date: Fri, 15 May 2015 14:55:44 +0800
Message-ID: <1431672946-300-5-git-send-email-ying.xue@windriver.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <alexei@purestorage.com>,
	<joern@purestorage.com>, <ja@ssi.bg>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:48103 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264AbbEOG5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 02:57:25 -0400
In-Reply-To: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep the usage of neigh timer aligned with one of sock timer, making
the usage of neigh timer more understandable. To reach the goal, a new
function - __neigh_release() is introduced in neigh_del_timer(), and
it just decreases neigh refcount but doesn't call neigh_destroy().
This makes sense because neigh recount has been taken when its timer
is added, and it cannot hit zero when the timer is deleted.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/neighbour.c |   18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 433b617..8a438fc 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -173,14 +173,18 @@ static void neigh_add_timer(struct neighbour *n, unsigned long when)
 	}
 }
 
-static int neigh_del_timer(struct neighbour *n)
+/* Ungrab neigh in the context, which assumes that neigh refcnt
+ * cannot hit zero.
+ */
+static void __neigh_release(struct neighbour *n)
 {
-	if ((n->nud_state & NUD_IN_TIMER) &&
-	    del_timer(&n->timer)) {
-		neigh_release(n);
-		return 1;
-	}
-	return 0;
+	atomic_dec(&n->refcnt);
+}
+
+static void neigh_del_timer(struct neighbour *n)
+{
+	if ((n->nud_state & NUD_IN_TIMER) && del_timer(&n->timer))
+		__neigh_release(n);
 }
 
 static void pneigh_queue_purge(struct sk_buff_head *list)
-- 
1.7.9.5

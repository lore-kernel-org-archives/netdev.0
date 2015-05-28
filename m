From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] neigh: Add missing rcu_assign_pointer
Date: Thu, 28 May 2015 16:28:20 +0800
Message-ID: <1432801700-29300-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:41086 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbbE1Ia0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 04:30:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e4c4e448cf55 ("neigh: Convert garbage collection from softirq
to workqueue") misses to use rcu_assign_pointer() macro to assign a
RCU-protected pointer.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/neighbour.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 3a74df7..aaad3a5 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -783,7 +783,8 @@ static void neigh_periodic_work(struct work_struct *work)
 			if (atomic_read(&n->refcnt) == 1 &&
 			    (state == NUD_FAILED ||
 			     time_after(jiffies, n->used + NEIGH_VAR(n->parms, GC_STALETIME)))) {
-				*np = n->next;
+				rcu_assign_pointer(*np, rcu_dereference_protected(n->next,
+								lockdep_is_held(&tbl->lock)));
 				n->dead = 1;
 				write_unlock(&n->lock);
 				neigh_cleanup_and_release(n);
-- 
1.7.9.5

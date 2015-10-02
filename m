From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 2/3] af_unix: Convert gc_flags to flags
Date: Fri,  2 Oct 2015 20:43:58 +0000 (GMT)
Message-ID: <91a760d3870d33dfd05625e6b8e6bd57b6c39f74.1443817522.git.jbaron@akamai.com>
References: <cover.1443817522.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1443817522.git.jbaron@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert gc_flags to flags in preparation for the subsequent patch, which will
make use of a flag bit for a non-gc purpose.

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 include/net/af_unix.h |  2 +-
 net/unix/garbage.c    | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 9698aff..6a4a345 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -58,7 +58,7 @@ struct unix_sock {
 	atomic_long_t		inflight;
 	spinlock_t		lock;
 	unsigned char		recursion_level;
-	unsigned long		gc_flags;
+	unsigned long		flags;
 #define UNIX_GC_CANDIDATE	0
 #define UNIX_GC_MAYBE_CYCLE	1
 	struct socket_wq	peer_wq;
diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index a73a226..39794d9 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -179,7 +179,7 @@ static void scan_inflight(struct sock *x, void (*func)(struct unix_sock *),
 					 * have been added to the queues after
 					 * starting the garbage collection
 					 */
-					if (test_bit(UNIX_GC_CANDIDATE, &u->gc_flags)) {
+					if (test_bit(UNIX_GC_CANDIDATE, &u->flags)) {
 						hit = true;
 
 						func(u);
@@ -246,7 +246,7 @@ static void inc_inflight_move_tail(struct unix_sock *u)
 	 * of the list, so that it's checked even if it was already
 	 * passed over
 	 */
-	if (test_bit(UNIX_GC_MAYBE_CYCLE, &u->gc_flags))
+	if (test_bit(UNIX_GC_MAYBE_CYCLE, &u->flags))
 		list_move_tail(&u->link, &gc_candidates);
 }
 
@@ -305,8 +305,8 @@ void unix_gc(void)
 		BUG_ON(total_refs < inflight_refs);
 		if (total_refs == inflight_refs) {
 			list_move_tail(&u->link, &gc_candidates);
-			__set_bit(UNIX_GC_CANDIDATE, &u->gc_flags);
-			__set_bit(UNIX_GC_MAYBE_CYCLE, &u->gc_flags);
+			__set_bit(UNIX_GC_CANDIDATE, &u->flags);
+			__set_bit(UNIX_GC_MAYBE_CYCLE, &u->flags);
 		}
 	}
 
@@ -332,7 +332,7 @@ void unix_gc(void)
 
 		if (atomic_long_read(&u->inflight) > 0) {
 			list_move_tail(&u->link, &not_cycle_list);
-			__clear_bit(UNIX_GC_MAYBE_CYCLE, &u->gc_flags);
+			__clear_bit(UNIX_GC_MAYBE_CYCLE, &u->flags);
 			scan_children(&u->sk, inc_inflight_move_tail, NULL);
 		}
 	}
@@ -343,7 +343,7 @@ void unix_gc(void)
 	 */
 	while (!list_empty(&not_cycle_list)) {
 		u = list_entry(not_cycle_list.next, struct unix_sock, link);
-		__clear_bit(UNIX_GC_CANDIDATE, &u->gc_flags);
+		__clear_bit(UNIX_GC_CANDIDATE, &u->flags);
 		list_move_tail(&u->link, &gc_inflight_list);
 	}
 
-- 
1.8.2.rc2

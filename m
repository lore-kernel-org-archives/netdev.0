From: kuznet@ms2.inr.ac.ru
Subject: [PATCH] repairing rtcache killer
Date: Tue, 5 Aug 2003 17:40:42 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308051340.RAA28267@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!


Alexey

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1613  -> 1.1614 
#	    net/ipv4/route.c	1.66    -> 1.67   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/05	kuznet@mops.inr.ac.ru	1.1614
# route.c:
#   [IPV4] Repair calculation of rtcache entries score
# 
#   Two serious and interesting mistakes were made in the patch of 2003-06-16.
#   1. Variance of hash chain turned out to be unexpectedly high, so truncation
#      chain length at <=ip_rt_gc_elasticity results in strong growth of
#      cache misses. Set the threshould to 2*ip_rt_gc_elasticity.
#      And continue to think how to switch to mode when lots of cache
#      entries are used once or twice, so truncation should be done at 1.
#   2. The selection rt_score() function based on use count resulted in killing
#      new fresh entries. Actually, it is clear when minimal brain efforts
#      are applied. :-) So, switch to scoring using last used time, which
#      should give real LRU behaviour.
# --------------------------------------------
#
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Tue Aug  5 17:37:41 2003
+++ b/net/ipv4/route.c	Tue Aug  5 17:37:41 2003
@@ -463,7 +463,9 @@
  */
 static inline u32 rt_score(struct rtable *rt)
 {
-	u32 score = rt->u.dst.__use;
+	u32 score = jiffies - rt->u.dst.lastuse;
+
+	score = ~score & ~(3<<30);
 
 	if (rt_valuable(rt))
 		score |= (1<<31);
@@ -807,8 +809,7 @@
 		 * The second limit is less certain. At the moment it allows
 		 * only 2 entries per bucket. We will see.
 		 */
-		if (chain_length > ip_rt_gc_elasticity ||
-		    (chain_length > 1 && !(min_score & (1<<31)))) {
+		if (chain_length > 2*ip_rt_gc_elasticity) {
 			*candp = cand->u.rt_next;
 			rt_free(cand);
 		}

From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Remove unnecessary code from rt_check_expire().
Date: Tue, 26 Jun 2012 00:21:24 -0700 (PDT)
Message-ID: <20120626.002124.2220875506847485306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758391Ab2FZHVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 03:21:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IPv4 routing cache entries no longer use dst->expires, because the
metrics, PMTU, and redirect information are stored in the inetpeer
cache.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Eric, when you did commit 9f28a2fc0bd77511f649c0a788c7bf9a5fd04edb
(ipv4: reintroduce route cache garbage collector) do you remember
if the thing we needed was the real expiry or both the
rt_is_expired() and the rt_may_expire() cases?

I really want to remove rt_may_expire() from this conditional because
it results in absolutely stupid behavior.  If your system is idle
for 5 minutes, all of your input routing cache entries are purged.

 net/ipv4/route.c |   34 +++++++++++-----------------------
 1 file changed, 11 insertions(+), 23 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8d62d85..846961c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -870,34 +870,22 @@ static void rt_check_expire(void)
 		while ((rth = rcu_dereference_protected(*rthp,
 					lockdep_is_held(rt_hash_lock_addr(i)))) != NULL) {
 			prefetch(rth->dst.rt_next);
-			if (rt_is_expired(rth)) {
+			if (rt_is_expired(rth) ||
+			    rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
 				*rthp = rth->dst.rt_next;
 				rt_free(rth);
 				continue;
 			}
-			if (rth->dst.expires) {
-				/* Entry is expired even if it is in use */
-				if (time_before_eq(jiffies, rth->dst.expires)) {
-nofree:
-					tmo >>= 1;
-					rthp = &rth->dst.rt_next;
-					/*
-					 * We only count entries on
-					 * a chain with equal hash inputs once
-					 * so that entries for different QOS
-					 * levels, and other non-hash input
-					 * attributes don't unfairly skew
-					 * the length computation
-					 */
-					length += has_noalias(rt_hash_table[i].chain, rth);
-					continue;
-				}
-			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout))
-				goto nofree;
 
-			/* Cleanup aged off entries. */
-			*rthp = rth->dst.rt_next;
-			rt_free(rth);
+			/* We only count entries on a chain with equal
+			 * hash inputs once so that entries for
+			 * different QOS levels, and other non-hash
+			 * input attributes don't unfairly skew the
+			 * length computation
+			 */
+			tmo >>= 1;
+			rthp = &rth->dst.rt_next;
+			length += has_noalias(rt_hash_table[i].chain, rth);
 		}
 		spin_unlock_bh(rt_hash_lock_addr(i));
 		sum += length;
-- 
1.7.10

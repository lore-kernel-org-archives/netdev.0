From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 11/17] [IPV4]: rt_cache_get_next should take rt_genid into account.
Date: Wed,  6 Feb 2008 13:53:31 +0300
Message-ID: <1202295217-22769-11-git-send-email-den@openvz.org>
References: <47A99196.2030105@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:55430 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758509AbYBFKxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 05:53:15 -0500
In-Reply-To: <47A99196.2030105@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the other case /proc/net/rt_cache will look inconsistent in respect to
genid.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
 net/ipv4/route.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 92ff622..b03de57 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -294,7 +294,8 @@ static struct rtable *rt_cache_get_first(struct rt_cache_iter_state *st)
 	return r;
 }
 
-static struct rtable *rt_cache_get_next(struct rt_cache_iter_state *st, struct rtable *r)
+static struct rtable *__rt_cache_get_next(struct rt_cache_iter_state *st,
+					  struct rtable *r)
 {
 	r = r->u.dst.rt_next;
 	while (!r) {
@@ -307,16 +308,23 @@ static struct rtable *rt_cache_get_next(struct rt_cache_iter_state *st, struct r
 	return rcu_dereference(r);
 }
 
+static struct rtable *rt_cache_get_next(struct rt_cache_iter_state *st,
+					struct rtable *r)
+{
+	while ((r = __rt_cache_get_next(st, r)) != NULL) {
+		if (r->rt_genid == st->genid)
+			break;
+	}
+	return r;
+}
+
 static struct rtable *rt_cache_get_idx(struct rt_cache_iter_state *st, loff_t pos)
 {
 	struct rtable *r = rt_cache_get_first(st);
 
 	if (r)
-		while (pos && (r = rt_cache_get_next(st, r))) {
-			if (r->rt_genid != st->genid)
-				continue;
+		while (pos && (r = rt_cache_get_next(st, r)))
 			--pos;
-		}
 	return pos ? NULL : r;
 }
 
-- 
1.5.3.rc5


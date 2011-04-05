From: kaber@trash.net
Subject: [PATCH 1/8] netfilter: ipset: list:set timeout variant fixes
Date: Tue,  5 Apr 2011 15:04:12 +0200
Message-ID: <1302008659-21141-2-git-send-email-kaber@trash.net>
References: <1302008659-21141-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39604 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750Ab1DENEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 09:04:34 -0400
In-Reply-To: <1302008659-21141-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

- the timeout value was actually not set
- the garbage collector was broken

The variant is fixed, the tests to the ipset testsuite are added.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_list_set.c |   53 +++++++++++++++------------------
 1 files changed, 24 insertions(+), 29 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index a47c329..f4a46c0 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -43,14 +43,19 @@ struct list_set {
 static inline struct set_elem *
 list_set_elem(const struct list_set *map, u32 id)
 {
-	return (struct set_elem *)((char *)map->members + id * map->dsize);
+	return (struct set_elem *)((void *)map->members + id * map->dsize);
+}
+
+static inline struct set_telem *
+list_set_telem(const struct list_set *map, u32 id)
+{
+	return (struct set_telem *)((void *)map->members + id * map->dsize);
 }
 
 static inline bool
 list_set_timeout(const struct list_set *map, u32 id)
 {
-	const struct set_telem *elem =
-		(const struct set_telem *) list_set_elem(map, id);
+	const struct set_telem *elem = list_set_telem(map, id);
 
 	return ip_set_timeout_test(elem->timeout);
 }
@@ -58,19 +63,11 @@ list_set_timeout(const struct list_set *map, u32 id)
 static inline bool
 list_set_expired(const struct list_set *map, u32 id)
 {
-	const struct set_telem *elem =
-		(const struct set_telem *) list_set_elem(map, id);
+	const struct set_telem *elem = list_set_telem(map, id);
 
 	return ip_set_timeout_expired(elem->timeout);
 }
 
-static inline int
-list_set_exist(const struct set_telem *elem)
-{
-	return elem->id != IPSET_INVALID_ID &&
-	       !ip_set_timeout_expired(elem->timeout);
-}
-
 /* Set list without and with timeout */
 
 static int
@@ -146,11 +143,11 @@ list_elem_tadd(struct list_set *map, u32 i, ip_set_id_t id,
 	struct set_telem *e;
 
 	for (; i < map->size; i++) {
-		e = (struct set_telem *)list_set_elem(map, i);
+		e = list_set_telem(map, i);
 		swap(e->id, id);
+		swap(e->timeout, timeout);
 		if (e->id == IPSET_INVALID_ID)
 			break;
-		swap(e->timeout, timeout);
 	}
 }
 
@@ -164,7 +161,7 @@ list_set_add(struct list_set *map, u32 i, ip_set_id_t id,
 		/* Last element replaced: e.g. add new,before,last */
 		ip_set_put_byindex(e->id);
 	if (with_timeout(map->timeout))
-		list_elem_tadd(map, i, id, timeout);
+		list_elem_tadd(map, i, id, ip_set_timeout_set(timeout));
 	else
 		list_elem_add(map, i, id);
 
@@ -172,11 +169,11 @@ list_set_add(struct list_set *map, u32 i, ip_set_id_t id,
 }
 
 static int
-list_set_del(struct list_set *map, ip_set_id_t id, u32 i)
+list_set_del(struct list_set *map, u32 i)
 {
 	struct set_elem *a = list_set_elem(map, i), *b;
 
-	ip_set_put_byindex(id);
+	ip_set_put_byindex(a->id);
 
 	for (; i < map->size - 1; i++) {
 		b = list_set_elem(map, i + 1);
@@ -308,11 +305,11 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 				 (before == 0 ||
 				  (before > 0 &&
 				   next_id_eq(map, i, refid))))
-				ret = list_set_del(map, id, i);
+				ret = list_set_del(map, i);
 			else if (before < 0 &&
 				 elem->id == refid &&
 				 next_id_eq(map, i, id))
-				ret = list_set_del(map, id, i + 1);
+				ret = list_set_del(map, i + 1);
 		}
 		break;
 	default:
@@ -460,17 +457,15 @@ list_set_gc(unsigned long ul_set)
 	struct list_set *map = set->data;
 	struct set_telem *e;
 	u32 i;
-
-	/* We run parallel with other readers (test element)
-	 * but adding/deleting new entries is locked out */
-	read_lock_bh(&set->lock);
-	for (i = map->size - 1; i >= 0; i--) {
-		e = (struct set_telem *) list_set_elem(map, i);
-		if (e->id != IPSET_INVALID_ID &&
-		    list_set_expired(map, i))
-			list_set_del(map, e->id, i);
+	
+	/* nfnl_lock should be called */
+	write_lock_bh(&set->lock);
+	for (i = 0; i < map->size; i++) {
+		e = list_set_telem(map, i);
+		if (e->id != IPSET_INVALID_ID && list_set_expired(map, i))
+			list_set_del(map, i);
 	}
-	read_unlock_bh(&set->lock);
+	write_unlock_bh(&set->lock);
 
 	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
 	add_timer(&map->gc);
-- 
1.7.2.3


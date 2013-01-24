From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] net neigh: Optimize neighbor entry size calculation.
Date: Thu, 24 Jan 2013 19:44:23 +0900
Message-ID: <51011087.1010801@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33756 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752270Ab3AXKo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 05:44:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When allocating memory for neighbour cache entry, if
tbl->entry_size is not set, we always calculate
sizeof(struct neighbour) + tbl->key_len, which is common
in the same table.

With this change, set tbl->entry_size during the table
initialization phase, if it was not set, and use it in
neigh_alloc() and neighbour_priv().

This change also allow us to have both of protocol private
data and device priate data at tha same time.

Note that the only user of prototcol private is DECnet
and the only user of device private is ATM CLIP.
Since those are exclusive, we have not been facing issues
here.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/neighbour.h |    2 +-
 net/core/neighbour.c    |   16 +++++++---------
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 0dab173..629ee57 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -184,7 +184,7 @@ struct neigh_table {
 
 static inline void *neighbour_priv(const struct neighbour *n)
 {
-	return (char *)n + ALIGN(sizeof(*n) + n->tbl->key_len, NEIGH_PRIV_ALIGN);
+	return (char *)n + n->tbl->entry_size;
 }
 
 /* flags for neigh_update() */
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 7bd0eed..3863b8f 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -290,15 +290,7 @@ static struct neighbour *neigh_alloc(struct neigh_table *tbl, struct net_device
 			goto out_entries;
 	}
 
-	if (tbl->entry_size)
-		n = kzalloc(tbl->entry_size, GFP_ATOMIC);
-	else {
-		int sz = sizeof(*n) + tbl->key_len;
-
-		sz = ALIGN(sz, NEIGH_PRIV_ALIGN);
-		sz += dev->neigh_priv_len;
-		n = kzalloc(sz, GFP_ATOMIC);
-	}
+	n = kzalloc(tbl->entry_size + dev->neigh_priv_len, GFP_ATOMIC);
 	if (!n)
 		goto out_entries;
 
@@ -1546,6 +1538,12 @@ static void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	if (!tbl->nht || !tbl->phash_buckets)
 		panic("cannot allocate neighbour cache hashes");
 
+	if (!tbl->entry_size)
+		tbl->entry_size = ALIGN(offsetof(struct neighbour, primary_key) +
+					tbl->key_len, NEIGH_PRIV_ALIGN);
+	else
+		WARN_ON(tbl->entry_size % NEIGH_PRIV_ALIGN);
+
 	rwlock_init(&tbl->lock);
 	INIT_DEFERRABLE_WORK(&tbl->gc_work, neigh_periodic_work);
 	schedule_delayed_work(&tbl->gc_work, tbl->parms.reachable_time);
-- 
1.7.9.5

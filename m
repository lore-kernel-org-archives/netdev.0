From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] neigh: __rcu annotations
Date: Thu, 20 Jan 2011 09:02:47 +0100
Message-ID: <1295510567.2653.487.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61825 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab1ATICx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 03:02:53 -0500
Received: by wyb28 with SMTP id 28so336611wyb.19
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 00:02:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix some minor issues and sparse (__rcu) warnings

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/neighbour.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 60a9029..799f06e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -316,7 +316,7 @@ static struct neigh_hash_table *neigh_hash_alloc(unsigned int entries)
 {
 	size_t size = entries * sizeof(struct neighbour *);
 	struct neigh_hash_table *ret;
-	struct neighbour **buckets;
+	struct neighbour __rcu **buckets;
 
 	ret = kmalloc(sizeof(*ret), GFP_ATOMIC);
 	if (!ret)
@@ -324,14 +324,14 @@ static struct neigh_hash_table *neigh_hash_alloc(unsigned int entries)
 	if (size <= PAGE_SIZE)
 		buckets = kzalloc(size, GFP_ATOMIC);
 	else
-		buckets = (struct neighbour **)
+		buckets = (struct neighbour __rcu **)
 			  __get_free_pages(GFP_ATOMIC | __GFP_ZERO,
 					   get_order(size));
 	if (!buckets) {
 		kfree(ret);
 		return NULL;
 	}
-	rcu_assign_pointer(ret->hash_buckets, buckets);
+	ret->hash_buckets = buckets;
 	ret->hash_mask = entries - 1;
 	get_random_bytes(&ret->hash_rnd, sizeof(ret->hash_rnd));
 	return ret;
@@ -343,7 +343,7 @@ static void neigh_hash_free_rcu(struct rcu_head *head)
 						    struct neigh_hash_table,
 						    rcu);
 	size_t size = (nht->hash_mask + 1) * sizeof(struct neighbour *);
-	struct neighbour **buckets = nht->hash_buckets;
+	struct neighbour __rcu **buckets = nht->hash_buckets;
 
 	if (size <= PAGE_SIZE)
 		kfree(buckets);
@@ -1540,7 +1540,7 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 		panic("cannot create neighbour proc dir entry");
 #endif
 
-	tbl->nht = neigh_hash_alloc(8);
+	RCU_INIT_POINTER(tbl->nht, neigh_hash_alloc(8));
 
 	phsize = (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
 	tbl->phash_buckets = kzalloc(phsize, GFP_KERNEL);
@@ -1602,7 +1602,8 @@ int neigh_table_clear(struct neigh_table *tbl)
 	}
 	write_unlock(&neigh_tbl_lock);
 
-	call_rcu(&tbl->nht->rcu, neigh_hash_free_rcu);
+	call_rcu(&rcu_dereference_protected(tbl->nht, 1)->rcu,
+		 neigh_hash_free_rcu);
 	tbl->nht = NULL;
 
 	kfree(tbl->phash_buckets);



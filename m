From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/12] netfilter: ipset: Support updating extensions when the set is full
Date: Wed,  3 Dec 2014 13:55:37 +0100
Message-ID: <1417611342-25257-8-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48793 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504AbaLCMxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 07:53:50 -0500
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

When the set was full (hash type and maxelem reached), it was not
possible to update the extension part of already existing elements.
The patch removes this limitation.

Fixes: https://bugzilla.netfilter.org/show_bug.cgi?id=880
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_gen.h |   40 ++++++++++++++-------------------
 1 file changed, 17 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index fee7c64e..a12ee04 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -633,29 +633,6 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	bool flag_exist = flags & IPSET_FLAG_EXIST;
 	u32 key, multi = 0;
 
-	if (h->elements >= h->maxelem && SET_WITH_FORCEADD(set)) {
-		rcu_read_lock_bh();
-		t = rcu_dereference_bh(h->table);
-		key = HKEY(value, h->initval, t->htable_bits);
-		n = hbucket(t,key);
-		if (n->pos) {
-			/* Choosing the first entry in the array to replace */
-			j = 0;
-			goto reuse_slot;
-		}
-		rcu_read_unlock_bh();
-	}
-	if (SET_WITH_TIMEOUT(set) && h->elements >= h->maxelem)
-		/* FIXME: when set is full, we slow down here */
-		mtype_expire(set, h, NLEN(set->family), set->dsize);
-
-	if (h->elements >= h->maxelem) {
-		if (net_ratelimit())
-			pr_warn("Set %s is full, maxelem %u reached\n",
-				set->name, h->maxelem);
-		return -IPSET_ERR_HASH_FULL;
-	}
-
 	rcu_read_lock_bh();
 	t = rcu_dereference_bh(h->table);
 	key = HKEY(value, h->initval, t->htable_bits);
@@ -680,6 +657,23 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		    j != AHASH_MAX(h) + 1)
 			j = i;
 	}
+	if (h->elements >= h->maxelem && SET_WITH_FORCEADD(set) && n->pos) {
+		/* Choosing the first entry in the array to replace */
+		j = 0;
+		goto reuse_slot;
+	}
+	if (SET_WITH_TIMEOUT(set) && h->elements >= h->maxelem)
+		/* FIXME: when set is full, we slow down here */
+		mtype_expire(set, h, NLEN(set->family), set->dsize);
+
+	if (h->elements >= h->maxelem) {
+		if (net_ratelimit())
+			pr_warn("Set %s is full, maxelem %u reached\n",
+				set->name, h->maxelem);
+		ret = -IPSET_ERR_HASH_FULL;
+		goto out;
+	}
+
 reuse_slot:
 	if (j != AHASH_MAX(h) + 1) {
 		/* Fill out reused slot */
-- 
1.7.10.4

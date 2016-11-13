From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 34/39] netfilter: ipset: Fix reported memory size for hash:* types
Date: Sun, 13 Nov 2016 23:25:28 +0100
Message-ID: <1479075933-4491-35-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47802 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965244AbcKMW0a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:30 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 395C0C107A
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:28 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 23B02DA843
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:28 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 22F59DA86E
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:26 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The calculation of the full allocated memory did not take
into account the size of the base hash bucket structure at some
places.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 1c9b84e53dcc..88b70fcc5ac5 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -85,6 +85,8 @@ struct htable {
 };
 
 #define hbucket(h, i)		((h)->bucket[i])
+#define ext_size(n, dsize)	\
+	(sizeof(struct hbucket) + (n) * (dsize))
 
 #ifndef IPSET_NET_COUNT
 #define IPSET_NET_COUNT		1
@@ -519,7 +521,7 @@ mtype_expire(struct ip_set *set, struct htype *h)
 				d++;
 			}
 			tmp->pos = d;
-			set->ext_size -= AHASH_INIT_SIZE * dsize;
+			set->ext_size -= ext_size(AHASH_INIT_SIZE, dsize);
 			rcu_assign_pointer(hbucket(t, i), tmp);
 			kfree_rcu(n, rcu);
 		}
@@ -625,7 +627,7 @@ mtype_resize(struct ip_set *set, bool retried)
 					goto cleanup;
 				}
 				m->size = AHASH_INIT_SIZE;
-				extsize = sizeof(*m) + AHASH_INIT_SIZE * dsize;
+				extsize = ext_size(AHASH_INIT_SIZE, dsize);
 				RCU_INIT_POINTER(hbucket(t, key), m);
 			} else if (m->pos >= m->size) {
 				struct hbucket *ht;
@@ -645,7 +647,7 @@ mtype_resize(struct ip_set *set, bool retried)
 				memcpy(ht, m, sizeof(struct hbucket) +
 					      m->size * dsize);
 				ht->size = m->size + AHASH_INIT_SIZE;
-				extsize += AHASH_INIT_SIZE * dsize;
+				extsize += ext_size(AHASH_INIT_SIZE, dsize);
 				kfree(m);
 				m = ht;
 				RCU_INIT_POINTER(hbucket(t, key), ht);
@@ -727,7 +729,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		if (!n)
 			return -ENOMEM;
 		n->size = AHASH_INIT_SIZE;
-		set->ext_size += sizeof(*n) + AHASH_INIT_SIZE * set->dsize;
+		set->ext_size += ext_size(AHASH_INIT_SIZE, set->dsize);
 		goto copy_elem;
 	}
 	for (i = 0; i < n->pos; i++) {
@@ -791,7 +793,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		memcpy(n, old, sizeof(struct hbucket) +
 		       old->size * set->dsize);
 		n->size = old->size + AHASH_INIT_SIZE;
-		set->ext_size += AHASH_INIT_SIZE * set->dsize;
+		set->ext_size += ext_size(AHASH_INIT_SIZE, set->dsize);
 	}
 
 copy_elem:
@@ -883,7 +885,7 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 				k++;
 		}
 		if (n->pos == 0 && k == 0) {
-			set->ext_size -= sizeof(*n) + n->size * dsize;
+			set->ext_size -= ext_size(n->size, dsize);
 			rcu_assign_pointer(hbucket(t, key), NULL);
 			kfree_rcu(n, rcu);
 		} else if (k >= AHASH_INIT_SIZE) {
@@ -902,7 +904,7 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 				k++;
 			}
 			tmp->pos = k;
-			set->ext_size -= AHASH_INIT_SIZE * dsize;
+			set->ext_size -= ext_size(AHASH_INIT_SIZE, dsize);
 			rcu_assign_pointer(hbucket(t, key), tmp);
 			kfree_rcu(n, rcu);
 		}
-- 
2.1.4

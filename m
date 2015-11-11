From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/10] netfilter: ipset: Fix hash type expire: release empty hash bucket block
Date: Wed, 11 Nov 2015 18:33:38 +0100
Message-ID: <1447263223-22662-6-git-send-email-pablo@netfilter.org>
References: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

When all entries are expired/all slots are empty, release the bucket.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index fa4f637..e5336ab 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -476,7 +476,7 @@ static void
 mtype_expire(struct ip_set *set, struct htype *h, u8 nets_length, size_t dsize)
 {
 	struct htable *t;
-	struct hbucket *n;
+	struct hbucket *n, *tmp;
 	struct mtype_elem *data;
 	u32 i, j, d;
 #ifdef IP_SET_HASH_WITH_NETS
@@ -511,9 +511,14 @@ mtype_expire(struct ip_set *set, struct htype *h, u8 nets_length, size_t dsize)
 			}
 		}
 		if (d >= AHASH_INIT_SIZE) {
-			struct hbucket *tmp = kzalloc(sizeof(*tmp) +
-					(n->size - AHASH_INIT_SIZE) * dsize,
-					GFP_ATOMIC);
+			if (d >= n->size) {
+				rcu_assign_pointer(hbucket(t, i), NULL);
+				kfree_rcu(n, rcu);
+				continue;
+			}
+			tmp = kzalloc(sizeof(*tmp) +
+				      (n->size - AHASH_INIT_SIZE) * dsize,
+				      GFP_ATOMIC);
 			if (!tmp)
 				/* Still try to delete expired elements */
 				continue;
-- 
2.1.4


From: pablo@netfilter.org
Subject: [PATCH 03/23] netfilter: ipset: Log warning when a hash type of set gets full
Date: Thu,  8 Mar 2012 02:00:52 +0100
Message-ID: <1331168472-5820-4-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

If the set is full, the SET target cannot add more elements.
Log warning so that the admin got notified about it.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set_ahash.h |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index b89fb79..bd1fc8d 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -353,9 +353,12 @@ retry:
 	htable_bits++;
 	pr_debug("attempt to resize set %s from %u to %u, t %p\n",
 		 set->name, orig->htable_bits, htable_bits, orig);
-	if (!htable_bits)
+	if (!htable_bits) {
 		/* In case we have plenty of memory :-) */
+		pr_warning("Cannot increase the hashsize of set %s further\n",
+			   set->name);
 		return -IPSET_ERR_HASH_FULL;
+	}
 	t = ip_set_alloc(sizeof(*t)
 			 + jhash_size(htable_bits) * sizeof(struct hbucket));
 	if (!t)
@@ -407,8 +410,12 @@ type_pf_add(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	int i, ret = 0;
 	u32 key, multi = 0;
 
-	if (h->elements >= h->maxelem)
+	if (h->elements >= h->maxelem) {
+		if (net_ratelimit())
+			pr_warning("Set %s is full, maxelem %u reached\n",
+				   set->name, h->maxelem);
 		return -IPSET_ERR_HASH_FULL;
+	}
 
 	rcu_read_lock_bh();
 	t = rcu_dereference_bh(h->table);
@@ -790,9 +797,12 @@ type_pf_tresize(struct ip_set *set, bool retried)
 retry:
 	ret = 0;
 	htable_bits++;
-	if (!htable_bits)
+	if (!htable_bits) {
 		/* In case we have plenty of memory :-) */
+		pr_warning("Cannot increase the hashsize of set %s further\n",
+			   set->name);
 		return -IPSET_ERR_HASH_FULL;
+	}
 	t = ip_set_alloc(sizeof(*t)
 			 + jhash_size(htable_bits) * sizeof(struct hbucket));
 	if (!t)
@@ -843,8 +853,12 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	if (h->elements >= h->maxelem)
 		/* FIXME: when set is full, we slow down here */
 		type_pf_expire(h);
-	if (h->elements >= h->maxelem)
+	if (h->elements >= h->maxelem) {
+		if (net_ratelimit())
+			pr_warning("Set %s is full, maxelem %u reached\n",
+				   set->name, h->maxelem);
 		return -IPSET_ERR_HASH_FULL;
+	}
 
 	rcu_read_lock_bh();
 	t = rcu_dereference_bh(h->table);
-- 
1.7.7.3


From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/36] netfilter: conntrack: keep BH enabled during lookup
Date: Mon,  9 May 2016 20:46:33 +0200
Message-ID: <1462819614-5402-16-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

No need to disable BH here anymore:

stats are switched to _ATOMIC variant (== this_cpu_inc()), which
nowadays generates same code as the non _ATOMIC NF_STAT, at least on x86.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 25 ++++++++-----------------
 1 file changed, 8 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 1fd0ff1..1b63359 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -472,18 +472,13 @@ ____nf_conntrack_find(struct net *net, const struct nf_conntrack_zone *zone,
 	struct hlist_nulls_node *n;
 	unsigned int bucket = hash_bucket(hash, net);
 
-	/* Disable BHs the entire time since we normally need to disable them
-	 * at least once for the stats anyway.
-	 */
-	local_bh_disable();
 begin:
 	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[bucket], hnnode) {
 		if (nf_ct_key_equal(h, tuple, zone)) {
-			NF_CT_STAT_INC(net, found);
-			local_bh_enable();
+			NF_CT_STAT_INC_ATOMIC(net, found);
 			return h;
 		}
-		NF_CT_STAT_INC(net, searched);
+		NF_CT_STAT_INC_ATOMIC(net, searched);
 	}
 	/*
 	 * if the nulls value we got at the end of this lookup is
@@ -491,10 +486,9 @@ begin:
 	 * We probably met an item that was moved to another chain.
 	 */
 	if (get_nulls_value(n) != bucket) {
-		NF_CT_STAT_INC(net, search_restart);
+		NF_CT_STAT_INC_ATOMIC(net, search_restart);
 		goto begin;
 	}
-	local_bh_enable();
 
 	return NULL;
 }
@@ -735,22 +729,19 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	zone = nf_ct_zone(ignored_conntrack);
 	hash = hash_conntrack(net, tuple);
 
-	/* Disable BHs the entire time since we need to disable them at
-	 * least once for the stats anyway.
-	 */
-	rcu_read_lock_bh();
+	rcu_read_lock();
 	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (ct != ignored_conntrack &&
 		    nf_ct_tuple_equal(tuple, &h->tuple) &&
 		    nf_ct_zone_equal(ct, zone, NF_CT_DIRECTION(h))) {
-			NF_CT_STAT_INC(net, found);
-			rcu_read_unlock_bh();
+			NF_CT_STAT_INC_ATOMIC(net, found);
+			rcu_read_unlock();
 			return 1;
 		}
-		NF_CT_STAT_INC(net, searched);
+		NF_CT_STAT_INC_ATOMIC(net, searched);
 	}
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 
 	return 0;
 }
-- 
2.1.4


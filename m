From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/53] netfilter: nf_ct_expect: Add nf_ct_remove_expect()
Date: Mon,  1 May 2017 12:46:33 +0200
Message-ID: <1493635640-24325-7-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

When remove one expect, it needs three statements. And there are
multiple duplicated codes in current code. So add one common function
nf_ct_remove_expect to consolidate this.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_expect.h |  1 +
 net/netfilter/nf_conntrack_expect.c         | 32 ++++++++++++++---------------
 net/netfilter/nf_conntrack_helper.c         |  7 ++-----
 net/netfilter/nf_conntrack_sip.c            |  4 +---
 4 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index e84df8d3bf37..2ba54feaccd8 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -105,6 +105,7 @@ static inline void nf_ct_unlink_expect(struct nf_conntrack_expect *exp)
 
 void nf_ct_remove_expectations(struct nf_conn *ct);
 void nf_ct_unexpect_related(struct nf_conntrack_expect *exp);
+bool nf_ct_remove_expect(struct nf_conntrack_expect *exp);
 
 /* Allocate space for an expectation: this is mandatory before calling
    nf_ct_expect_related.  You will have to call put afterwards. */
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index cb29e598605f..71d136469be0 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -103,6 +103,17 @@ nf_ct_exp_equal(const struct nf_conntrack_tuple *tuple,
 	       nf_ct_zone_equal_any(i->master, zone);
 }
 
+bool nf_ct_remove_expect(struct nf_conntrack_expect *exp)
+{
+	if (del_timer(&exp->timeout)) {
+		nf_ct_unlink_expect(exp);
+		nf_ct_expect_put(exp);
+		return true;
+	}
+	return false;
+}
+EXPORT_SYMBOL_GPL(nf_ct_remove_expect);
+
 struct nf_conntrack_expect *
 __nf_ct_expect_find(struct net *net,
 		    const struct nf_conntrack_zone *zone,
@@ -211,10 +222,7 @@ void nf_ct_remove_expectations(struct nf_conn *ct)
 
 	spin_lock_bh(&nf_conntrack_expect_lock);
 	hlist_for_each_entry_safe(exp, next, &help->expectations, lnode) {
-		if (del_timer(&exp->timeout)) {
-			nf_ct_unlink_expect(exp);
-			nf_ct_expect_put(exp);
-		}
+		nf_ct_remove_expect(exp);
 	}
 	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
@@ -255,10 +263,7 @@ static inline int expect_matches(const struct nf_conntrack_expect *a,
 void nf_ct_unexpect_related(struct nf_conntrack_expect *exp)
 {
 	spin_lock_bh(&nf_conntrack_expect_lock);
-	if (del_timer(&exp->timeout)) {
-		nf_ct_unlink_expect(exp);
-		nf_ct_expect_put(exp);
-	}
+	nf_ct_remove_expect(exp);
 	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
 EXPORT_SYMBOL_GPL(nf_ct_unexpect_related);
@@ -394,10 +399,8 @@ static void evict_oldest_expect(struct nf_conn *master,
 			last = exp;
 	}
 
-	if (last && del_timer(&last->timeout)) {
-		nf_ct_unlink_expect(last);
-		nf_ct_expect_put(last);
-	}
+	if (last)
+		nf_ct_remove_expect(last);
 }
 
 static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
@@ -419,11 +422,8 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 	h = nf_ct_expect_dst_hash(net, &expect->tuple);
 	hlist_for_each_entry_safe(i, next, &nf_ct_expect_hash[h], hnode) {
 		if (expect_matches(i, expect)) {
-			if (del_timer(&i->timeout)) {
-				nf_ct_unlink_expect(i);
-				nf_ct_expect_put(i);
+			if (nf_ct_remove_expect(expect))
 				break;
-			}
 		} else if (expect_clash(i, expect)) {
 			ret = -EBUSY;
 			goto out;
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 752a977e9eef..33ebb78649f8 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -451,11 +451,8 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 			if ((rcu_dereference_protected(
 					help->helper,
 					lockdep_is_held(&nf_conntrack_expect_lock)
-					) == me || exp->helper == me) &&
-			    del_timer(&exp->timeout)) {
-				nf_ct_unlink_expect(exp);
-				nf_ct_expect_put(exp);
-			}
+					) == me || exp->helper == me))
+				nf_ct_remove_expect(exp);
 		}
 	}
 	spin_unlock_bh(&nf_conntrack_expect_lock);
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 0d17894798b5..91a9c97b7e9a 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -829,10 +829,8 @@ static void flush_expectations(struct nf_conn *ct, bool media)
 	hlist_for_each_entry_safe(exp, next, &help->expectations, lnode) {
 		if ((exp->class != SIP_EXPECT_SIGNALLING) ^ media)
 			continue;
-		if (!del_timer(&exp->timeout))
+		if (!nf_ct_remove_expect(exp))
 			continue;
-		nf_ct_unlink_expect(exp);
-		nf_ct_expect_put(exp);
 		if (!media)
 			break;
 	}
-- 
2.1.4


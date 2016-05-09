From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/36] netfilter: conntrack: introduce nf_ct_acct_update()
Date: Mon,  9 May 2016 20:46:43 +0200
Message-ID: <1462819614-5402-26-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce a helper function to update conntrack counters.
__nf_ct_kill_acct() was unnecessarily subtracting skb_network_offset()
that is expected to be zero from the ipv4/ipv6 hooks.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 42 ++++++++++++++++++---------------------
 1 file changed, 19 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f72ede1..25e0c26 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -602,6 +602,21 @@ out:
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_hash_check_insert);
 
+static inline void nf_ct_acct_update(struct nf_conn *ct,
+				     enum ip_conntrack_info ctinfo,
+				     unsigned int len)
+{
+	struct nf_conn_acct *acct;
+
+	acct = nf_conn_acct_find(ct);
+	if (acct) {
+		struct nf_conn_counter *counter = acct->counter;
+
+		atomic64_inc(&counter[CTINFO2DIR(ctinfo)].packets);
+		atomic64_add(len, &counter[CTINFO2DIR(ctinfo)].bytes);
+	}
+}
+
 /* Confirm a connection given skb; places it in hash table */
 int
 __nf_conntrack_confirm(struct sk_buff *skb)
@@ -1258,17 +1273,8 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 	}
 
 acct:
-	if (do_acct) {
-		struct nf_conn_acct *acct;
-
-		acct = nf_conn_acct_find(ct);
-		if (acct) {
-			struct nf_conn_counter *counter = acct->counter;
-
-			atomic64_inc(&counter[CTINFO2DIR(ctinfo)].packets);
-			atomic64_add(skb->len, &counter[CTINFO2DIR(ctinfo)].bytes);
-		}
-	}
+	if (do_acct)
+		nf_ct_acct_update(ct, ctinfo, skb->len);
 }
 EXPORT_SYMBOL_GPL(__nf_ct_refresh_acct);
 
@@ -1277,18 +1283,8 @@ bool __nf_ct_kill_acct(struct nf_conn *ct,
 		       const struct sk_buff *skb,
 		       int do_acct)
 {
-	if (do_acct) {
-		struct nf_conn_acct *acct;
-
-		acct = nf_conn_acct_find(ct);
-		if (acct) {
-			struct nf_conn_counter *counter = acct->counter;
-
-			atomic64_inc(&counter[CTINFO2DIR(ctinfo)].packets);
-			atomic64_add(skb->len - skb_network_offset(skb),
-				     &counter[CTINFO2DIR(ctinfo)].bytes);
-		}
-	}
+	if (do_acct)
+		nf_ct_acct_update(ct, ctinfo, skb->len);
 
 	if (del_timer(&ct->timeout)) {
 		ct->timeout.function((unsigned long)ct);
-- 
2.1.4


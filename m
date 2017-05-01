From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/53] netfilter: nat: avoid use of nf_conn_nat extension
Date: Mon,  1 May 2017 12:46:35 +0200
Message-ID: <1493635640-24325-9-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

successful insert into the bysource hash sets IPS_SRC_NAT_DONE status bit
so we can check that instead of presence of nat extension which requires
extra deref.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c |  2 +-
 net/netfilter/nf_nat_core.c       | 18 ++++--------------
 2 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 3d621b8d7b8a..bcf1d2a6539e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -706,7 +706,7 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto->allow_clash &&
-	    !nfct_nat(ct) &&
+	    ((ct->status & IPS_NAT_DONE_MASK) == 0) &&
 	    !nf_ct_is_dying(ct) &&
 	    atomic_inc_not_zero(&ct->ct_general.use)) {
 		enum ip_conntrack_info oldinfo;
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 82802e4a6640..376c1b36f222 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -549,10 +549,6 @@ struct nf_nat_proto_clean {
 static int nf_nat_proto_remove(struct nf_conn *i, void *data)
 {
 	const struct nf_nat_proto_clean *clean = data;
-	struct nf_conn_nat *nat = nfct_nat(i);
-
-	if (!nat)
-		return 0;
 
 	if ((clean->l3proto && nf_ct_l3num(i) != clean->l3proto) ||
 	    (clean->l4proto && nf_ct_protonum(i) != clean->l4proto))
@@ -563,12 +559,10 @@ static int nf_nat_proto_remove(struct nf_conn *i, void *data)
 
 static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 {
-	struct nf_conn_nat *nat = nfct_nat(ct);
-
 	if (nf_nat_proto_remove(ct, data))
 		return 1;
 
-	if (!nat)
+	if ((ct->status & IPS_SRC_NAT_DONE) == 0)
 		return 0;
 
 	/* This netns is being destroyed, and conntrack has nat null binding.
@@ -716,13 +710,9 @@ EXPORT_SYMBOL_GPL(nf_nat_l3proto_unregister);
 /* No one using conntrack by the time this called. */
 static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
 {
-	struct nf_conn_nat *nat = nf_ct_ext_find(ct, NF_CT_EXT_NAT);
-
-	if (!nat)
-		return;
-
-	rhltable_remove(&nf_nat_bysource_table, &ct->nat_bysource,
-			nf_nat_bysource_params);
+	if (ct->status & IPS_SRC_NAT_DONE)
+		rhltable_remove(&nf_nat_bysource_table, &ct->nat_bysource,
+				nf_nat_bysource_params);
 }
 
 static struct nf_ct_ext_type nat_extend __read_mostly = {
-- 
2.1.4


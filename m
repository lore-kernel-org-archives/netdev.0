From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/12] netfilter: xt_CT: optimize XT_CT_NOTRACK
Date: Wed,  5 Jun 2013 22:40:22 +0200
Message-ID: <1370464832-4216-2-git-send-email-pablo@netfilter.org>
References: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

The percpu untracked ct are not currently used for XT_CT_NOTRACK.

xt_ct_tg_check()/xt_ct_target() provides a single ct.

Thats not optimal as the ct->ct_general.use cache line will bounce among
cpus.

Use the intended [1] thing : xt_ct_target() should select the percpu
object.

[1] Refs :
commit 5bfddbd46a95c97 ("netfilter: nf_conntrack: IPS_UNTRACKED bit")
commit b3c5163fe0193a7 ("netfilter: nf_conntrack: per_cpu untracking")

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index a60261c..da35ac0 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -26,6 +26,9 @@ static inline int xt_ct_target(struct sk_buff *skb, struct nf_conn *ct)
 	if (skb->nfct != NULL)
 		return XT_CONTINUE;
 
+	/* special case the untracked ct : we want the percpu object */
+	if (!ct)
+		ct = nf_ct_untracked_get();
 	atomic_inc(&ct->ct_general.use);
 	skb->nfct = &ct->ct_general;
 	skb->nfctinfo = IP_CT_NEW;
@@ -186,8 +189,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 	int ret = -EOPNOTSUPP;
 
 	if (info->flags & XT_CT_NOTRACK) {
-		ct = nf_ct_untracked_get();
-		atomic_inc(&ct->ct_general.use);
+		ct = NULL;
 		goto out;
 	}
 
@@ -311,7 +313,7 @@ static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par,
 	struct nf_conn *ct = info->ct;
 	struct nf_conn_help *help;
 
-	if (!nf_ct_is_untracked(ct)) {
+	if (ct && !nf_ct_is_untracked(ct)) {
 		help = nfct_help(ct);
 		if (help)
 			module_put(help->helper->me);
@@ -319,8 +321,8 @@ static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par,
 		nf_ct_l3proto_module_put(par->family);
 
 		xt_ct_destroy_timeout(ct);
+		nf_ct_put(info->ct);
 	}
-	nf_ct_put(info->ct);
 }
 
 static void xt_ct_tg_destroy_v0(const struct xt_tgdtor_param *par)
-- 
1.7.10.4


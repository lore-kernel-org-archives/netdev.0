From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH resend nf-next] netfilter: xt_CT: optimize XT_CT_NOTRACK
Date: Wed, 22 May 2013 14:10:57 -0700
Message-ID: <1369257057.3301.367.camel@edumazet-glaptop>
References: <1368132751.13473.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1368132751.13473.113.camel@edumazet-glaptop>
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
---
Sent Thu, 2013-05-09, this is a resend only, no changes

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



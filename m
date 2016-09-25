From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/53] netfilter: nf_conntrack: simplify __nf_ct_try_assign_helper() return logic
Date: Mon, 26 Sep 2016 01:06:30 +0200
Message-ID: <1474844823-2026-21-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira <pablo@netfilter.org>

Instead of several goto's just to return the result, simply return it.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_helper.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index b989b81ac156..4ffe388a9a1e 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -189,7 +189,6 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 	struct nf_conntrack_helper *helper = NULL;
 	struct nf_conn_help *help;
 	struct net *net = nf_ct_net(ct);
-	int ret = 0;
 
 	/* We already got a helper explicitly attached. The function
 	 * nf_conntrack_alter_reply - in case NAT is in use - asks for looking
@@ -223,15 +222,13 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 	if (helper == NULL) {
 		if (help)
 			RCU_INIT_POINTER(help->helper, NULL);
-		goto out;
+		return 0;
 	}
 
 	if (help == NULL) {
 		help = nf_ct_helper_ext_add(ct, helper, flags);
-		if (help == NULL) {
-			ret = -ENOMEM;
-			goto out;
-		}
+		if (help == NULL)
+			return -ENOMEM;
 	} else {
 		/* We only allow helper re-assignment of the same sort since
 		 * we cannot reallocate the helper extension area.
@@ -240,13 +237,13 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 
 		if (tmp && tmp->help != helper->help) {
 			RCU_INIT_POINTER(help->helper, NULL);
-			goto out;
+			return 0;
 		}
 	}
 
 	rcu_assign_pointer(help->helper, helper);
-out:
-	return ret;
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(__nf_ct_try_assign_helper);
 
-- 
2.1.4


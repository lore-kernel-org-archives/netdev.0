From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/18] netfilter: Simply the tests for enabling and disabling the ingress queue hook
Date: Tue,  4 Aug 2015 12:02:32 +0200
Message-ID: <1438682568-8346-3-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace an overcomplicated switch statement with a simple if statement.

This also removes the ingress queue enable outside of nf_hook_mutex as
the protection provided by the mutex is not necessary and the code is
clearer having both of the static key increments together.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c |   17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index a0e5497..c4c3b85 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -74,7 +74,6 @@ int nf_register_hook(struct nf_hook_ops *reg)
 		if (reg->hooknum == NF_NETDEV_INGRESS) {
 			BUG_ON(reg->dev == NULL);
 			nf_hook_list = &reg->dev->nf_hooks_ingress;
-			net_inc_ingress_queue();
 			break;
 		}
 #endif
@@ -90,6 +89,10 @@ int nf_register_hook(struct nf_hook_ops *reg)
 	}
 	list_add_rcu(&reg->list, elem->list.prev);
 	mutex_unlock(&nf_hook_mutex);
+#ifdef CONFIG_NETFILTER_INGRESS
+	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
+		net_inc_ingress_queue();
+#endif
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_inc(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
@@ -102,18 +105,10 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
 	mutex_lock(&nf_hook_mutex);
 	list_del_rcu(&reg->list);
 	mutex_unlock(&nf_hook_mutex);
-	switch (reg->pf) {
-	case NFPROTO_NETDEV:
 #ifdef CONFIG_NETFILTER_INGRESS
-		if (reg->hooknum == NF_NETDEV_INGRESS) {
-			net_dec_ingress_queue();
-			break;
-		}
-		break;
+	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
+		net_dec_ingress_queue();
 #endif
-	default:
-		break;
-	}
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
-- 
1.7.10.4


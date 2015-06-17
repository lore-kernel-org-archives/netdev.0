From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 24/43] netfilter: Make the netfilter hooks per network namespace
Date: Wed, 17 Jun 2015 10:28:33 -0500
Message-ID: <1434554932-4552-24-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W Biederman <ebiederm@xmission.com>

Work remains to register all of the hooks in the network namespaces
where they are wanted.

Inspired-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Eric W Biederman <ebiederm@xmission.com>
---
 include/linux/netfilter.h     | 12 ++++++------
 include/net/netns/netfilter.h |  1 +
 net/netfilter/core.c          | 20 ++++++++++----------
 3 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 3097a3e7a049..43db9eaf42f6 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -11,6 +11,7 @@
 #include <linux/list.h>
 #include <linux/static_key.h>
 #include <linux/netfilter_defs.h>
+#include <net/net_namespace.h>
 
 #ifdef CONFIG_NETFILTER
 static inline int NF_DROP_GETERR(int verdict)
@@ -131,8 +132,6 @@ void nf_unregister_hooks(struct net *net, struct nf_hook_ops *reg, unsigned int
 int nf_register_sockopt(struct nf_sockopt_ops *reg);
 void nf_unregister_sockopt(struct nf_sockopt_ops *reg);
 
-extern struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
-
 #ifdef HAVE_JUMP_LABEL
 extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 
@@ -153,9 +152,10 @@ static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
 }
 #endif
 
-static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
+static inline bool nf_hooks_active(struct net *net, u_int8_t pf,
+				   unsigned int hook)
 {
-	return nf_hook_list_active(&nf_hooks[pf][hook], pf, hook);
+	return nf_hook_list_active(&net->nf.hooks[pf][hook], pf, hook);
 }
 
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
@@ -176,10 +176,10 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 int (*okfn)(struct sock *, struct sk_buff *),
 				 int thresh)
 {
-	if (nf_hooks_active(pf, hook)) {
+	if (nf_hooks_active(net, pf, hook)) {
 		struct nf_hook_state state;
 
-		nf_hook_state_init(&state, &nf_hooks[pf][hook], hook, thresh,
+		nf_hook_state_init(&state, &net->nf.hooks[pf][hook], hook, thresh,
 				   pf, indev, outdev, sk, net, okfn);
 		return nf_hook_slow(skb, &state);
 	}
diff --git a/include/net/netns/netfilter.h b/include/net/netns/netfilter.h
index 532e4ba64f49..38aa4983e2a9 100644
--- a/include/net/netns/netfilter.h
+++ b/include/net/netns/netfilter.h
@@ -14,5 +14,6 @@ struct netns_nf {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header *nf_log_dir_header;
 #endif
+	struct list_head hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 };
 #endif
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 8fba484532be..ccf248607342 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -52,9 +52,6 @@ void nf_unregister_afinfo(const struct nf_afinfo *afinfo)
 }
 EXPORT_SYMBOL_GPL(nf_unregister_afinfo);
 
-struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS] __read_mostly;
-EXPORT_SYMBOL(nf_hooks);
-
 #ifdef HAVE_JUMP_LABEL
 struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 EXPORT_SYMBOL(nf_hooks_needed);
@@ -80,7 +77,7 @@ int nf_register_hook(struct net *net, struct nf_hook_ops *reg)
 #endif
 		/* Fall through. */
 	default:
-		nf_hook_list = &nf_hooks[reg->pf][reg->hooknum];
+		nf_hook_list = &net->nf.hooks[reg->pf][reg->hooknum];
 		break;
 	}
 
@@ -297,6 +294,13 @@ EXPORT_SYMBOL(nf_nat_decode_session_hook);
 
 static int __net_init netfilter_net_init(struct net *net)
 {
+	int i, h;
+
+	for (i = 0; i < NFPROTO_NUMPROTO; i++) {
+		for (h = 0; h < NF_MAX_HOOKS; h++)
+			INIT_LIST_HEAD(&net->nf.hooks[i][h]);
+	}
+
 #ifdef CONFIG_PROC_FS
 	net->nf.proc_netfilter = proc_net_mkdir(net, "netfilter",
 						net->proc_net);
@@ -307,6 +311,7 @@ static int __net_init netfilter_net_init(struct net *net)
 		return -ENOMEM;
 	}
 #endif
+
 	return 0;
 }
 
@@ -322,12 +327,7 @@ static struct pernet_operations netfilter_net_ops = {
 
 int __init netfilter_init(void)
 {
-	int i, h, ret;
-
-	for (i = 0; i < ARRAY_SIZE(nf_hooks); i++) {
-		for (h = 0; h < NF_MAX_HOOKS; h++)
-			INIT_LIST_HEAD(&nf_hooks[i][h]);
-	}
+	int ret;
 
 	ret = register_pernet_subsys(&netfilter_net_ops);
 	if (ret < 0)
-- 
2.2.1


From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netfilter: use jump_label for nf_hooks
Date: Sat, 19 Nov 2011 04:32:46 +0100
Message-ID: <1321673566.3157.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On configs where CONFIG_JUMP_LABEL=y, we can replace in fast path a
load/compare/conditional jump by a single jump with no dcache reference.

Jump target is modified as soon as nf_hooks[pf][hook] switches from
empty state to non empty states. jump_label state is kept outside of
nf_hooks array so has no cost on cpu caches.

This patch removes the test on CONFIG_NETFILTER_DEBUG : No need to call
nf_hook_slow() at all if nf_hooks[pf][hook] is empty, this didnt give
useful information, but slowed down things a lot.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Pablo Neira Ayuso <pablo@netfilter.org>
---
This is obviously a netfilter patch, but since David committed two other
jump_label patches lately, maybe its better he takes this patch as well
directly ? Thanks !

 include/linux/netfilter.h |   26 +++++++++++++++++++++-----
 net/netfilter/core.c      |   13 ++++++++++++-
 2 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 857f502..b809265 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -162,6 +162,24 @@ extern struct ctl_path nf_net_ipv4_netfilter_sysctl_path[];
 
 extern struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 
+#if defined(CONFIG_JUMP_LABEL)
+#include <linux/jump_label.h>
+extern struct jump_label_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
+static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
+{
+	if (__builtin_constant_p(pf) &&
+	    __builtin_constant_p(hook))
+		return static_branch(&nf_hooks_needed[pf][hook]);
+
+	return !list_empty(&nf_hooks[pf][hook]);
+}
+#else
+static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
+{
+	return !list_empty(&nf_hooks[pf][hook]);
+}
+#endif
+
 int nf_hook_slow(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
 		 struct net_device *indev, struct net_device *outdev,
 		 int (*okfn)(struct sk_buff *), int thresh);
@@ -179,11 +197,9 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 struct net_device *outdev,
 				 int (*okfn)(struct sk_buff *), int thresh)
 {
-#ifndef CONFIG_NETFILTER_DEBUG
-	if (list_empty(&nf_hooks[pf][hook]))
-		return 1;
-#endif
-	return nf_hook_slow(pf, hook, skb, indev, outdev, okfn, thresh);
+	if (nf_hooks_active(pf, hook))
+		return nf_hook_slow(pf, hook, skb, indev, outdev, okfn, thresh);
+	return 1;
 }
 
 static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index afca6c7..4aa0f4b 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -54,6 +54,12 @@ EXPORT_SYMBOL_GPL(nf_unregister_afinfo);
 
 struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS] __read_mostly;
 EXPORT_SYMBOL(nf_hooks);
+
+#if defined(CONFIG_JUMP_LABEL)
+struct jump_label_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
+EXPORT_SYMBOL(nf_hooks_needed);
+#endif
+
 static DEFINE_MUTEX(nf_hook_mutex);
 
 int nf_register_hook(struct nf_hook_ops *reg)
@@ -70,6 +76,9 @@ int nf_register_hook(struct nf_hook_ops *reg)
 	}
 	list_add_rcu(&reg->list, elem->list.prev);
 	mutex_unlock(&nf_hook_mutex);
+#if defined(CONFIG_JUMP_LABEL)
+	jump_label_inc(&nf_hooks_needed[reg->pf][reg->hooknum]);
+#endif
 	return 0;
 }
 EXPORT_SYMBOL(nf_register_hook);
@@ -79,7 +88,9 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
 	mutex_lock(&nf_hook_mutex);
 	list_del_rcu(&reg->list);
 	mutex_unlock(&nf_hook_mutex);
-
+#if defined(CONFIG_JUMP_LABEL)
+	jump_label_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
+#endif
 	synchronize_net();
 }
 EXPORT_SYMBOL(nf_unregister_hook);



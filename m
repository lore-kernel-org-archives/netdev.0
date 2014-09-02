From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/7] netfilter: HAVE_JUMP_LABEL instead of CONFIG_JUMP_LABEL
Date: Tue,  2 Sep 2014 12:14:01 +0200
Message-ID: <1409652844-10289-5-git-send-email-pablo@netfilter.org>
References: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhouyi Zhou <zhouzhouyi@gmail.com>

Use HAVE_JUMP_LABEL as elsewhere in the kernel to ensure
that the toolchain has the required support in addition to
CONFIG_JUMP_LABEL being set.

Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
Reviewed-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h |    5 +++--
 net/netfilter/core.c      |    6 +++---
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 2077489..2517ece 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -9,6 +9,7 @@
 #include <linux/in6.h>
 #include <linux/wait.h>
 #include <linux/list.h>
+#include <linux/static_key.h>
 #include <uapi/linux/netfilter.h>
 #ifdef CONFIG_NETFILTER
 static inline int NF_DROP_GETERR(int verdict)
@@ -99,9 +100,9 @@ void nf_unregister_sockopt(struct nf_sockopt_ops *reg);
 
 extern struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 
-#if defined(CONFIG_JUMP_LABEL)
-#include <linux/static_key.h>
+#ifdef HAVE_JUMP_LABEL
 extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
+
 static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
 {
 	if (__builtin_constant_p(pf) &&
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index a93c97f..024a2e2 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -54,7 +54,7 @@ EXPORT_SYMBOL_GPL(nf_unregister_afinfo);
 struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS] __read_mostly;
 EXPORT_SYMBOL(nf_hooks);
 
-#if defined(CONFIG_JUMP_LABEL)
+#ifdef HAVE_JUMP_LABEL
 struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 EXPORT_SYMBOL(nf_hooks_needed);
 #endif
@@ -72,7 +72,7 @@ int nf_register_hook(struct nf_hook_ops *reg)
 	}
 	list_add_rcu(&reg->list, elem->list.prev);
 	mutex_unlock(&nf_hook_mutex);
-#if defined(CONFIG_JUMP_LABEL)
+#ifdef HAVE_JUMP_LABEL
 	static_key_slow_inc(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
 	return 0;
@@ -84,7 +84,7 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
 	mutex_lock(&nf_hook_mutex);
 	list_del_rcu(&reg->list);
 	mutex_unlock(&nf_hook_mutex);
-#if defined(CONFIG_JUMP_LABEL)
+#ifdef HAVE_JUMP_LABEL
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
 	synchronize_net();
-- 
1.7.10.4


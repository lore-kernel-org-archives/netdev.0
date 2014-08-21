From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH 1/1] netfilter/jump_label: use HAVE_JUMP_LABEL?
Date: Thu, 21 Aug 2014 10:52:48 +0800
Message-ID: <1408589568-27046-1-git-send-email-yizhouzhou@ict.ac.cn>
Cc: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: <pablo@netfilter.org>, <kaber@trash.net>,
	<kadlec@blackhole.kfki.hu>, <davem@davemloft.net>,
	<netfilter-devel@vger.kernel.org>, <coreteam@netfilter.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jbaron@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


CONFIG_JUMP_LABEL doesn't ensure HAVE_JUMP_LABEL, if it
is not the case use maintainers's own mutex to guard
the modification of global values.

Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
---
 include/linux/netfilter.h |    5 +++--
 net/netfilter/core.c      |    6 +++---
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 2077489..83a1952 100644
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
@@ -99,8 +100,8 @@ void nf_unregister_sockopt(struct nf_sockopt_ops *reg);
 
 extern struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 
-#if defined(CONFIG_JUMP_LABEL)
-#include <linux/static_key.h>
+#ifdef HAVE_JUMP_LABEL
+
 extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
 {
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


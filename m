From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/18] netfilter: add and use jump label for xt_tee
Date: Tue,  4 Aug 2015 12:02:39 +0200
Message-ID: <1438682568-8346-10-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Don't bother testing if we need to switch to alternate stack
unless TEE target is used.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |    7 +++++++
 net/ipv4/netfilter/ip_tables.c     |    3 ++-
 net/ipv6/netfilter/ip6_tables.c    |    3 ++-
 net/netfilter/x_tables.c           |    3 +++
 net/netfilter/xt_TEE.c             |    2 ++
 5 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 1492845..b006b71 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -3,6 +3,7 @@
 
 
 #include <linux/netdevice.h>
+#include <linux/static_key.h>
 #include <uapi/linux/netfilter/x_tables.h>
 
 /**
@@ -280,6 +281,12 @@ void xt_free_table_info(struct xt_table_info *info);
  */
 DECLARE_PER_CPU(seqcount_t, xt_recseq);
 
+/* xt_tee_enabled - true if x_tables needs to handle reentrancy
+ *
+ * Enabled if current ip(6)tables ruleset has at least one -j TEE rule.
+ */
+extern struct static_key xt_tee_enabled;
+
 /**
  * xt_write_recseq_begin - start of a write section
  *
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index a2e4b01..ff585bd 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -340,7 +340,8 @@ ipt_do_table(struct sk_buff *skb,
 	 * For recursion via REJECT or SYNPROXY the stack will be clobbered
 	 * but it is no problem since absolute verdict is issued by these.
 	 */
-	jumpstack += private->stacksize * __this_cpu_read(nf_skb_duplicated);
+	if (static_key_false(&xt_tee_enabled))
+		jumpstack += private->stacksize * __this_cpu_read(nf_skb_duplicated);
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 531281f..ea6d105 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -366,7 +366,8 @@ ip6t_do_table(struct sk_buff *skb,
 	 * For recursion via REJECT or SYNPROXY the stack will be clobbered
 	 * but it is no problem since absolute verdict is issued by these.
 	 */
-	jumpstack += private->stacksize * __this_cpu_read(nf_skb_duplicated);
+	if (static_key_false(&xt_tee_enabled))
+		jumpstack += private->stacksize * __this_cpu_read(nf_skb_duplicated);
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 154447e..9b42b5e 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -727,6 +727,9 @@ EXPORT_SYMBOL_GPL(xt_compat_unlock);
 DEFINE_PER_CPU(seqcount_t, xt_recseq);
 EXPORT_PER_CPU_SYMBOL_GPL(xt_recseq);
 
+struct static_key xt_tee_enabled __read_mostly;
+EXPORT_SYMBOL_GPL(xt_tee_enabled);
+
 static int xt_jumpstack_alloc(struct xt_table_info *i)
 {
 	unsigned int size;
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 8950e79..c5d6556 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -251,6 +251,7 @@ static int tee_tg_check(const struct xt_tgchk_param *par)
 	} else
 		info->priv = NULL;
 
+	static_key_slow_inc(&xt_tee_enabled);
 	return 0;
 }
 
@@ -262,6 +263,7 @@ static void tee_tg_destroy(const struct xt_tgdtor_param *par)
 		unregister_netdevice_notifier(&info->priv->notifier);
 		kfree(info->priv);
 	}
+	static_key_slow_dec(&xt_tee_enabled);
 }
 
 static struct xt_target tee_tg_reg[] __read_mostly = {
-- 
1.7.10.4


From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 33/50] netfilter: nft_counter: add stateful object type
Date: Wed,  7 Dec 2016 22:52:39 +0100
Message-ID: <1481147576-5690-34-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Register a new percpu counter stateful object type into the stateful
object infrastructure.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |   1 +
 net/netfilter/nft_counter.c              | 140 +++++++++++++++++++++++++------
 2 files changed, 114 insertions(+), 27 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 18e30dbc8c3f..e352ef65d753 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1186,6 +1186,7 @@ enum nft_fib_flags {
 };
 
 #define NFT_OBJECT_UNSPEC	0
+#define NFT_OBJECT_COUNTER	1
 
 /**
  * enum nft_object_attributes - nf_tables stateful object netlink attributes
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index 77db8358ab14..6f3dd429f865 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -31,11 +31,10 @@ struct nft_counter_percpu_priv {
 	struct nft_counter_percpu __percpu *counter;
 };
 
-static void nft_counter_eval(const struct nft_expr *expr,
-			     struct nft_regs *regs,
-			     const struct nft_pktinfo *pkt)
+static inline void nft_counter_do_eval(struct nft_counter_percpu_priv *priv,
+				       struct nft_regs *regs,
+				       const struct nft_pktinfo *pkt)
 {
-	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
 	struct nft_counter_percpu *this_cpu;
 
 	local_bh_disable();
@@ -47,6 +46,60 @@ static void nft_counter_eval(const struct nft_expr *expr,
 	local_bh_enable();
 }
 
+static inline void nft_counter_obj_eval(struct nft_object *obj,
+					struct nft_regs *regs,
+					const struct nft_pktinfo *pkt)
+{
+	struct nft_counter_percpu_priv *priv = nft_obj_data(obj);
+
+	nft_counter_do_eval(priv, regs, pkt);
+}
+
+static int nft_counter_do_init(const struct nlattr * const tb[],
+			       struct nft_counter_percpu_priv *priv)
+{
+	struct nft_counter_percpu __percpu *cpu_stats;
+	struct nft_counter_percpu *this_cpu;
+
+	cpu_stats = netdev_alloc_pcpu_stats(struct nft_counter_percpu);
+	if (cpu_stats == NULL)
+		return -ENOMEM;
+
+	preempt_disable();
+	this_cpu = this_cpu_ptr(cpu_stats);
+	if (tb[NFTA_COUNTER_PACKETS]) {
+	        this_cpu->counter.packets =
+			be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_PACKETS]));
+	}
+	if (tb[NFTA_COUNTER_BYTES]) {
+		this_cpu->counter.bytes =
+			be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_BYTES]));
+	}
+	preempt_enable();
+	priv->counter = cpu_stats;
+	return 0;
+}
+
+static int nft_counter_obj_init(const struct nlattr * const tb[],
+				struct nft_object *obj)
+{
+	struct nft_counter_percpu_priv *priv = nft_obj_data(obj);
+
+	return nft_counter_do_init(tb, priv);
+}
+
+static void nft_counter_do_destroy(struct nft_counter_percpu_priv *priv)
+{
+	free_percpu(priv->counter);
+}
+
+static void nft_counter_obj_destroy(struct nft_object *obj)
+{
+	struct nft_counter_percpu_priv *priv = nft_obj_data(obj);
+
+	nft_counter_do_destroy(priv);
+}
+
 static void nft_counter_fetch(const struct nft_counter_percpu __percpu *counter,
 			      struct nft_counter *total)
 {
@@ -69,9 +122,9 @@ static void nft_counter_fetch(const struct nft_counter_percpu __percpu *counter,
 	}
 }
 
-static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr)
+static int nft_counter_do_dump(struct sk_buff *skb,
+			       const struct nft_counter_percpu_priv *priv)
 {
-	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
 	struct nft_counter total;
 
 	nft_counter_fetch(priv->counter, &total);
@@ -87,36 +140,54 @@ static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	return -1;
 }
 
+static int nft_counter_obj_dump(struct sk_buff *skb,
+				const struct nft_object *obj)
+{
+	const struct nft_counter_percpu_priv *priv = nft_obj_data(obj);
+
+	return nft_counter_do_dump(skb, priv);
+}
+
 static const struct nla_policy nft_counter_policy[NFTA_COUNTER_MAX + 1] = {
 	[NFTA_COUNTER_PACKETS]	= { .type = NLA_U64 },
 	[NFTA_COUNTER_BYTES]	= { .type = NLA_U64 },
 };
 
+static struct nft_object_type nft_counter_obj __read_mostly = {
+	.type		= NFT_OBJECT_COUNTER,
+	.size		= sizeof(struct nft_counter_percpu_priv),
+	.maxattr	= NFTA_COUNTER_MAX,
+	.policy		= nft_counter_policy,
+	.eval		= nft_counter_obj_eval,
+	.init		= nft_counter_obj_init,
+	.destroy	= nft_counter_obj_destroy,
+	.dump		= nft_counter_obj_dump,
+	.owner		= THIS_MODULE,
+};
+
+static void nft_counter_eval(const struct nft_expr *expr,
+			     struct nft_regs *regs,
+			     const struct nft_pktinfo *pkt)
+{
+	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
+
+	nft_counter_do_eval(priv, regs, pkt);
+}
+
+static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
+
+	return nft_counter_do_dump(skb, priv);
+}
+
 static int nft_counter_init(const struct nft_ctx *ctx,
 			    const struct nft_expr *expr,
 			    const struct nlattr * const tb[])
 {
 	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
-	struct nft_counter_percpu __percpu *cpu_stats;
-	struct nft_counter_percpu *this_cpu;
 
-	cpu_stats = netdev_alloc_pcpu_stats(struct nft_counter_percpu);
-	if (cpu_stats == NULL)
-		return -ENOMEM;
-
-	preempt_disable();
-	this_cpu = this_cpu_ptr(cpu_stats);
-	if (tb[NFTA_COUNTER_PACKETS]) {
-	        this_cpu->counter.packets =
-			be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_PACKETS]));
-	}
-	if (tb[NFTA_COUNTER_BYTES]) {
-		this_cpu->counter.bytes =
-			be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_BYTES]));
-	}
-	preempt_enable();
-	priv->counter = cpu_stats;
-	return 0;
+	return nft_counter_do_init(tb, priv);
 }
 
 static void nft_counter_destroy(const struct nft_ctx *ctx,
@@ -124,7 +195,7 @@ static void nft_counter_destroy(const struct nft_ctx *ctx,
 {
 	struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
 
-	free_percpu(priv->counter);
+	nft_counter_do_destroy(priv);
 }
 
 static int nft_counter_clone(struct nft_expr *dst, const struct nft_expr *src)
@@ -174,12 +245,26 @@ static struct nft_expr_type nft_counter_type __read_mostly = {
 
 static int __init nft_counter_module_init(void)
 {
-	return nft_register_expr(&nft_counter_type);
+	int err;
+
+	err = nft_register_obj(&nft_counter_obj);
+	if (err < 0)
+		return err;
+
+	err = nft_register_expr(&nft_counter_type);
+	if (err < 0)
+		goto err1;
+
+	return 0;
+err1:
+	nft_unregister_obj(&nft_counter_obj);
+	return err;
 }
 
 static void __exit nft_counter_module_exit(void)
 {
 	nft_unregister_expr(&nft_counter_type);
+	nft_unregister_obj(&nft_counter_obj);
 }
 
 module_init(nft_counter_module_init);
@@ -188,3 +273,4 @@ module_exit(nft_counter_module_exit);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_ALIAS_NFT_EXPR("counter");
+MODULE_ALIAS_NFT_OBJ(NFT_OBJECT_COUNTER);
-- 
2.1.4


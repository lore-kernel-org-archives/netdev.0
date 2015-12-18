From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/23] netfilter: nf_tables: wrap tracing with a static key
Date: Fri, 18 Dec 2015 21:26:41 +0100
Message-ID: <1450470409-31427-16-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58082 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965210AbbLRUeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:34:10 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 136331A5513
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BAD07DA80C
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:08 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1F013DA85D
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:02 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Only needed when meta nftrace rule(s) were added.
The assumption is that no such rules are active, so the call to
nft_trace_init is "never" needed.

When nftrace rules are active, we always call the nft_trace_* functions,
but will only send netlink messages when all of the following are true:

 - traceinfo structure was initialised
 - skb->nf_trace == 1
 - at least one subscriber to trace group.

Adding an extra conditional
(static_branch ... && skb->nf_trace)
	nft_trace_init( ..)

Is possible but results in a larger nft_do_chain footprint.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h |  1 +
 include/net/netfilter/nft_meta.h       |  3 +++
 net/bridge/netfilter/nft_meta_bridge.c |  1 +
 net/netfilter/nf_tables_core.c         |  9 ++++++---
 net/netfilter/nf_tables_trace.c        |  4 ++++
 net/netfilter/nft_meta.c               | 16 ++++++++++++++++
 6 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index 4ff5424..a9060dd 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -57,6 +57,7 @@ struct nft_payload_set {
 };
 
 extern const struct nft_expr_ops nft_payload_fast_ops;
+extern struct static_key_false nft_trace_enabled;
 
 int nft_payload_module_init(void);
 void nft_payload_module_exit(void);
diff --git a/include/net/netfilter/nft_meta.h b/include/net/netfilter/nft_meta.h
index 711887a..d27588c 100644
--- a/include/net/netfilter/nft_meta.h
+++ b/include/net/netfilter/nft_meta.h
@@ -33,4 +33,7 @@ void nft_meta_set_eval(const struct nft_expr *expr,
 		       struct nft_regs *regs,
 		       const struct nft_pktinfo *pkt);
 
+void nft_meta_set_destroy(const struct nft_ctx *ctx,
+			  const struct nft_expr *expr);
+
 #endif
diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index a21269b..4b901d9 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -84,6 +84,7 @@ static const struct nft_expr_ops nft_meta_bridge_set_ops = {
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_meta)),
 	.eval		= nft_meta_set_eval,
 	.init		= nft_meta_set_init,
+	.destroy	= nft_meta_set_destroy,
 	.dump		= nft_meta_set_dump,
 };
 
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 2395de7..67fa41d 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -16,6 +16,7 @@
 #include <linux/skbuff.h>
 #include <linux/netlink.h>
 #include <linux/netfilter.h>
+#include <linux/static_key.h>
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables_core.h>
@@ -50,7 +51,7 @@ static noinline void __nft_trace_packet(struct nft_traceinfo *info,
 {
 	const struct nft_pktinfo *pkt = info->pkt;
 
-	if (!pkt->skb->nf_trace)
+	if (!info->trace || !pkt->skb->nf_trace)
 		return;
 
 	info->chain = chain;
@@ -70,7 +71,7 @@ static inline void nft_trace_packet(struct nft_traceinfo *info,
 				    int rulenum,
 				    enum nft_trace_types type)
 {
-	if (unlikely(info->trace)) {
+	if (static_branch_unlikely(&nft_trace_enabled)) {
 		info->rule = rule;
 		__nft_trace_packet(info, chain, rulenum, type);
 	}
@@ -137,7 +138,9 @@ nft_do_chain(struct nft_pktinfo *pkt, void *priv)
 	unsigned int gencursor = nft_genmask_cur(net);
 	struct nft_traceinfo info;
 
-	nft_trace_init(&info, pkt, &regs.verdict, basechain);
+	info.trace = false;
+	if (static_branch_unlikely(&nft_trace_enabled))
+		nft_trace_init(&info, pkt, &regs.verdict, basechain);
 do_chain:
 	rulenum = 0;
 	rule = list_entry(&chain->rules, struct nft_rule, list);
diff --git a/net/netfilter/nf_tables_trace.c b/net/netfilter/nf_tables_trace.c
index 36fd7ad..e9e959f 100644
--- a/net/netfilter/nf_tables_trace.c
+++ b/net/netfilter/nf_tables_trace.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/static_key.h>
 #include <linux/hash.h>
 #include <linux/jhash.h>
 #include <linux/if_vlan.h>
@@ -24,6 +25,9 @@
 #define NFT_TRACETYPE_NETWORK_HSIZE	40
 #define NFT_TRACETYPE_TRANSPORT_HSIZE	20
 
+DEFINE_STATIC_KEY_FALSE(nft_trace_enabled);
+EXPORT_SYMBOL_GPL(nft_trace_enabled);
+
 static int trace_fill_id(struct sk_buff *nlskb, struct sk_buff *skb)
 {
 	__be32 id;
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 9dfaf4d..85a465b 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -18,10 +18,12 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/smp.h>
+#include <linux/static_key.h>
 #include <net/dst.h>
 #include <net/sock.h>
 #include <net/tcp_states.h> /* for TCP_TIME_WAIT */
 #include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
 #include <net/netfilter/nft_meta.h>
 
 void nft_meta_get_eval(const struct nft_expr *expr,
@@ -297,6 +299,9 @@ int nft_meta_set_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
+	if (priv->key == NFT_META_NFTRACE)
+		static_branch_inc(&nft_trace_enabled);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nft_meta_set_init);
@@ -334,6 +339,16 @@ nla_put_failure:
 }
 EXPORT_SYMBOL_GPL(nft_meta_set_dump);
 
+void nft_meta_set_destroy(const struct nft_ctx *ctx,
+			  const struct nft_expr *expr)
+{
+	const struct nft_meta *priv = nft_expr_priv(expr);
+
+	if (priv->key == NFT_META_NFTRACE)
+		static_branch_dec(&nft_trace_enabled);
+}
+EXPORT_SYMBOL_GPL(nft_meta_set_destroy);
+
 static struct nft_expr_type nft_meta_type;
 static const struct nft_expr_ops nft_meta_get_ops = {
 	.type		= &nft_meta_type,
@@ -348,6 +363,7 @@ static const struct nft_expr_ops nft_meta_set_ops = {
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_meta)),
 	.eval		= nft_meta_set_eval,
 	.init		= nft_meta_set_init,
+	.destroy	= nft_meta_set_destroy,
 	.dump		= nft_meta_set_dump,
 };
 
-- 
2.1.4

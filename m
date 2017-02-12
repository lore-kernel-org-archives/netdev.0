From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/21] netfilter: nft_ct: add zone id set support
Date: Sun, 12 Feb 2017 20:42:43 +0100
Message-ID: <1486928573-24773-12-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60438 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751297AbdBLTnT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 14:43:19 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0169BBA6E6
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:18 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E0C10DA850
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8318ADA85F
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:15 +0100 (CET)
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

zones allow tracking multiple connections sharing identical tuples,
this is needed e.g. when tracking distinct vlans with overlapping ip
addresses (conntrack is l2 agnostic).

Thus the zone has to be set before the packet is picked up by the
connection tracker.  This is done by means of 'conntrack templates' which
are conntrack structures used solely to pass this info from one netfilter
hook to the next.

The iptables CT target instantiates these connection tracking templates
once per rule, i.e. the template is fixed/tied to particular zone, can
be read-only and therefore be re-used by as many skbs simultaneously as
needed.

We can't follow this model because we want to take the zone id from
an sreg at rule eval time so we could e.g. fill in the zone id from
the packets vlan id or a e.g. nftables key : value maps.

To avoid cost of per packet alloc/free of the template, use a percpu
template 'scratch' object and use the refcount to detect the (unlikely)
case where the template is still attached to another skb (i.e., previous
skb was nfqueued ...).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c | 144 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 143 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 2d82df2737da..c6b8022c0e47 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -32,6 +32,11 @@ struct nft_ct {
 	};
 };
 
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+static DEFINE_PER_CPU(struct nf_conn *, nft_ct_pcpu_template);
+static unsigned int nft_ct_pcpu_template_refcnt __read_mostly;
+#endif
+
 static u64 nft_ct_get_eval_counter(const struct nf_conn_counter *c,
 				   enum nft_ct_keys k,
 				   enum ip_conntrack_dir d)
@@ -191,6 +196,53 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 	regs->verdict.code = NFT_BREAK;
 }
 
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+static void nft_ct_set_zone_eval(const struct nft_expr *expr,
+				 struct nft_regs *regs,
+				 const struct nft_pktinfo *pkt)
+{
+	struct nf_conntrack_zone zone = { .dir = NF_CT_DEFAULT_ZONE_DIR };
+	const struct nft_ct *priv = nft_expr_priv(expr);
+	struct sk_buff *skb = pkt->skb;
+	enum ip_conntrack_info ctinfo;
+	u16 value = regs->data[priv->sreg];
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct) /* already tracked */
+		return;
+
+	zone.id = value;
+
+	switch (priv->dir) {
+	case IP_CT_DIR_ORIGINAL:
+		zone.dir = NF_CT_ZONE_DIR_ORIG;
+		break;
+	case IP_CT_DIR_REPLY:
+		zone.dir = NF_CT_ZONE_DIR_REPL;
+		break;
+	default:
+		break;
+	}
+
+	ct = this_cpu_read(nft_ct_pcpu_template);
+
+	if (likely(atomic_read(&ct->ct_general.use) == 1)) {
+		nf_ct_zone_add(ct, &zone);
+	} else {
+		/* previous skb got queued to userspace */
+		ct = nf_ct_tmpl_alloc(nft_net(pkt), &zone, GFP_ATOMIC);
+		if (!ct) {
+			regs->verdict.code = NF_DROP;
+			return;
+		}
+	}
+
+	atomic_inc(&ct->ct_general.use);
+	nf_ct_set(skb, ct, IP_CT_NEW);
+}
+#endif
+
 static void nft_ct_set_eval(const struct nft_expr *expr,
 			    struct nft_regs *regs,
 			    const struct nft_pktinfo *pkt)
@@ -269,6 +321,45 @@ static void nft_ct_netns_put(struct net *net, uint8_t family)
 		nf_ct_netns_put(net, family);
 }
 
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+static void nft_ct_tmpl_put_pcpu(void)
+{
+	struct nf_conn *ct;
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		ct = per_cpu(nft_ct_pcpu_template, cpu);
+		if (!ct)
+			break;
+		nf_ct_put(ct);
+		per_cpu(nft_ct_pcpu_template, cpu) = NULL;
+	}
+}
+
+static bool nft_ct_tmpl_alloc_pcpu(void)
+{
+	struct nf_conntrack_zone zone = { .id = 0 };
+	struct nf_conn *tmp;
+	int cpu;
+
+	if (nft_ct_pcpu_template_refcnt)
+		return true;
+
+	for_each_possible_cpu(cpu) {
+		tmp = nf_ct_tmpl_alloc(&init_net, &zone, GFP_KERNEL);
+		if (!tmp) {
+			nft_ct_tmpl_put_pcpu();
+			return false;
+		}
+
+		atomic_set(&tmp->ct_general.use, 1);
+		per_cpu(nft_ct_pcpu_template, cpu) = tmp;
+	}
+
+	return true;
+}
+#endif
+
 static int nft_ct_get_init(const struct nft_ctx *ctx,
 			   const struct nft_expr *expr,
 			   const struct nlattr * const tb[])
@@ -394,6 +485,11 @@ static void __nft_ct_set_destroy(const struct nft_ctx *ctx, struct nft_ct *priv)
 		nf_connlabels_put(ctx->net);
 		break;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	case NFT_CT_ZONE:
+		if (--nft_ct_pcpu_template_refcnt == 0)
+			nft_ct_tmpl_put_pcpu();
+#endif
 	default:
 		break;
 	}
@@ -407,6 +503,7 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 	unsigned int len;
 	int err;
 
+	priv->dir = IP_CT_DIR_MAX;
 	priv->key = ntohl(nla_get_be32(tb[NFTA_CT_KEY]));
 	switch (priv->key) {
 #ifdef CONFIG_NF_CONNTRACK_MARK
@@ -426,10 +523,28 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 			return err;
 		break;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	case NFT_CT_ZONE:
+		if (!nft_ct_tmpl_alloc_pcpu())
+			return -ENOMEM;
+		nft_ct_pcpu_template_refcnt++;
+		break;
+#endif
 	default:
 		return -EOPNOTSUPP;
 	}
 
+	if (tb[NFTA_CT_DIRECTION]) {
+		priv->dir = nla_get_u8(tb[NFTA_CT_DIRECTION]);
+		switch (priv->dir) {
+		case IP_CT_DIR_ORIGINAL:
+		case IP_CT_DIR_REPLY:
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
 	priv->sreg = nft_parse_register(tb[NFTA_CT_SREG]);
 	err = nft_validate_register_load(priv->sreg, len);
 	if (err < 0)
@@ -504,6 +619,17 @@ static int nft_ct_set_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_CT_KEY, htonl(priv->key)))
 		goto nla_put_failure;
+
+	switch (priv->key) {
+	case NFT_CT_ZONE:
+		if (priv->dir < IP_CT_DIR_MAX &&
+		    nla_put_u8(skb, NFTA_CT_DIRECTION, priv->dir))
+			goto nla_put_failure;
+		break;
+	default:
+		break;
+	}
+
 	return 0;
 
 nla_put_failure:
@@ -529,6 +655,17 @@ static const struct nft_expr_ops nft_ct_set_ops = {
 	.dump		= nft_ct_set_dump,
 };
 
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+static const struct nft_expr_ops nft_ct_set_zone_ops = {
+	.type		= &nft_ct_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_ct)),
+	.eval		= nft_ct_set_zone_eval,
+	.init		= nft_ct_set_init,
+	.destroy	= nft_ct_set_destroy,
+	.dump		= nft_ct_set_dump,
+};
+#endif
+
 static const struct nft_expr_ops *
 nft_ct_select_ops(const struct nft_ctx *ctx,
 		    const struct nlattr * const tb[])
@@ -542,8 +679,13 @@ nft_ct_select_ops(const struct nft_ctx *ctx,
 	if (tb[NFTA_CT_DREG])
 		return &nft_ct_get_ops;
 
-	if (tb[NFTA_CT_SREG])
+	if (tb[NFTA_CT_SREG]) {
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+		if (nla_get_be32(tb[NFTA_CT_KEY]) == htonl(NFT_CT_ZONE))
+			return &nft_ct_set_zone_ops;
+#endif
 		return &nft_ct_set_ops;
+	}
 
 	return ERR_PTR(-EINVAL);
 }
-- 
2.1.4

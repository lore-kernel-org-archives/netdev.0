From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/50] netfilter: add and use nf_ct_netns_get/put
Date: Wed,  7 Dec 2016 22:52:20 +0100
Message-ID: <1481147576-5690-15-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60166 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933231AbcLGVxd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:33 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4A414C2310
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:31 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2B705DA841
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:31 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A9A58DA865
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:28 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

currently aliased to try_module_get/_put.
Will be changed in next patch when we add functions to make use of ->net
argument to store usercount per l3proto tracker.

This is needed to avoid registering the conntrack hooks in all netns and
later only enable connection tracking in those that need conntrack.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |  4 ++++
 net/ipv4/netfilter/ipt_CLUSTERIP.c   |  4 ++--
 net/ipv4/netfilter/ipt_SYNPROXY.c    |  4 ++--
 net/ipv6/netfilter/ip6t_SYNPROXY.c   |  4 ++--
 net/netfilter/nf_conntrack_proto.c   | 12 ++++++++++++
 net/netfilter/nft_ct.c               | 26 +++++++++++++-------------
 net/netfilter/xt_CONNSECMARK.c       |  4 ++--
 net/netfilter/xt_CT.c                |  6 +++---
 net/netfilter/xt_connbytes.c         |  4 ++--
 net/netfilter/xt_connlabel.c         |  6 +++---
 net/netfilter/xt_connlimit.c         |  6 +++---
 net/netfilter/xt_connmark.c          |  8 ++++----
 net/netfilter/xt_conntrack.c         |  4 ++--
 net/netfilter/xt_helper.c            |  4 ++--
 net/netfilter/xt_state.c             |  4 ++--
 15 files changed, 58 insertions(+), 42 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index d9d52c020a70..5916aa9ab3f0 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -181,6 +181,10 @@ static inline void nf_ct_put(struct nf_conn *ct)
 int nf_ct_l3proto_try_module_get(unsigned short l3proto);
 void nf_ct_l3proto_module_put(unsigned short l3proto);
 
+/* load module; enable/disable conntrack in this namespace */
+int nf_ct_netns_get(struct net *net, u8 nfproto);
+void nf_ct_netns_put(struct net *net, u8 nfproto);
+
 /*
  * Allocate a hashtable of hlist_head (if nulls == 0),
  * or hlist_nulls_head (if nulls == 1)
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index e6e206fa86c8..21db00d0362b 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -419,7 +419,7 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 	}
 	cipinfo->config = config;
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
@@ -444,7 +444,7 @@ static void clusterip_tg_destroy(const struct xt_tgdtor_param *par)
 
 	clusterip_config_put(cipinfo->config);
 
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_get(par->net, par->family);
 }
 
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 361411688221..30c0de53e254 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -418,12 +418,12 @@ static int synproxy_tg4_check(const struct xt_tgchk_param *par)
 	    e->ip.invflags & XT_INV_PROTO)
 		return -EINVAL;
 
-	return nf_ct_l3proto_try_module_get(par->family);
+	return nf_ct_netns_get(par->net, par->family);
 }
 
 static void synproxy_tg4_destroy(const struct xt_tgdtor_param *par)
 {
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static struct xt_target synproxy_tg4_reg __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 99a1216287c8..98c8dd38575a 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -440,12 +440,12 @@ static int synproxy_tg6_check(const struct xt_tgchk_param *par)
 	    e->ipv6.invflags & XT_INV_PROTO)
 		return -EINVAL;
 
-	return nf_ct_l3proto_try_module_get(par->family);
+	return nf_ct_netns_get(par->net, par->family);
 }
 
 static void synproxy_tg6_destroy(const struct xt_tgdtor_param *par)
 {
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static struct xt_target synproxy_tg6_reg __read_mostly = {
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index b218e70b2f74..948f1e2fc80b 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -125,6 +125,18 @@ void nf_ct_l3proto_module_put(unsigned short l3proto)
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_module_put);
 
+int nf_ct_netns_get(struct net *net, u8 nfproto)
+{
+	return nf_ct_l3proto_try_module_get(nfproto);
+}
+EXPORT_SYMBOL_GPL(nf_ct_netns_get);
+
+void nf_ct_netns_put(struct net *net, u8 nfproto)
+{
+	nf_ct_l3proto_module_put(nfproto);
+}
+EXPORT_SYMBOL_GPL(nf_ct_netns_put);
+
 struct nf_conntrack_l4proto *
 nf_ct_l4proto_find_get(u_int16_t l3num, u_int8_t l4num)
 {
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 6837348c8993..e6baeaebe653 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -208,37 +208,37 @@ static const struct nla_policy nft_ct_policy[NFTA_CT_MAX + 1] = {
 	[NFTA_CT_SREG]		= { .type = NLA_U32 },
 };
 
-static int nft_ct_l3proto_try_module_get(uint8_t family)
+static int nft_ct_netns_get(struct net *net, uint8_t family)
 {
 	int err;
 
 	if (family == NFPROTO_INET) {
-		err = nf_ct_l3proto_try_module_get(NFPROTO_IPV4);
+		err = nf_ct_netns_get(net, NFPROTO_IPV4);
 		if (err < 0)
 			goto err1;
-		err = nf_ct_l3proto_try_module_get(NFPROTO_IPV6);
+		err = nf_ct_netns_get(net, NFPROTO_IPV6);
 		if (err < 0)
 			goto err2;
 	} else {
-		err = nf_ct_l3proto_try_module_get(family);
+		err = nf_ct_netns_get(net, family);
 		if (err < 0)
 			goto err1;
 	}
 	return 0;
 
 err2:
-	nf_ct_l3proto_module_put(NFPROTO_IPV4);
+	nf_ct_netns_put(net, NFPROTO_IPV4);
 err1:
 	return err;
 }
 
-static void nft_ct_l3proto_module_put(uint8_t family)
+static void nft_ct_netns_put(struct net *net, uint8_t family)
 {
 	if (family == NFPROTO_INET) {
-		nf_ct_l3proto_module_put(NFPROTO_IPV4);
-		nf_ct_l3proto_module_put(NFPROTO_IPV6);
+		nf_ct_netns_put(net, NFPROTO_IPV4);
+		nf_ct_netns_put(net, NFPROTO_IPV6);
 	} else
-		nf_ct_l3proto_module_put(family);
+		nf_ct_netns_put(net, family);
 }
 
 static int nft_ct_get_init(const struct nft_ctx *ctx,
@@ -342,7 +342,7 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	err = nft_ct_l3proto_try_module_get(ctx->afi->family);
+	err = nft_ct_netns_get(ctx->net, ctx->afi->family);
 	if (err < 0)
 		return err;
 
@@ -390,7 +390,7 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		goto err1;
 
-	err = nft_ct_l3proto_try_module_get(ctx->afi->family);
+	err = nft_ct_netns_get(ctx->net, ctx->afi->family);
 	if (err < 0)
 		goto err1;
 
@@ -405,7 +405,7 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 static void nft_ct_get_destroy(const struct nft_ctx *ctx,
 			       const struct nft_expr *expr)
 {
-	nft_ct_l3proto_module_put(ctx->afi->family);
+	nf_ct_netns_put(ctx->net, ctx->afi->family);
 }
 
 static void nft_ct_set_destroy(const struct nft_ctx *ctx,
@@ -423,7 +423,7 @@ static void nft_ct_set_destroy(const struct nft_ctx *ctx,
 		break;
 	}
 
-	nft_ct_l3proto_module_put(ctx->afi->family);
+	nft_ct_netns_put(ctx->net, ctx->afi->family);
 }
 
 static int nft_ct_get_dump(struct sk_buff *skb, const struct nft_expr *expr)
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index e04dc282e3bb..da56c06a443c 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -106,7 +106,7 @@ static int connsecmark_tg_check(const struct xt_tgchk_param *par)
 		return -EINVAL;
 	}
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
@@ -115,7 +115,7 @@ static int connsecmark_tg_check(const struct xt_tgchk_param *par)
 
 static void connsecmark_tg_destroy(const struct xt_tgdtor_param *par)
 {
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static struct xt_target connsecmark_tg_reg __read_mostly = {
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 6669e68d589e..95c750358747 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -216,7 +216,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 		goto err1;
 #endif
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0)
 		goto err1;
 
@@ -260,7 +260,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 err3:
 	nf_ct_tmpl_free(ct);
 err2:
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 err1:
 	return ret;
 }
@@ -341,7 +341,7 @@ static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par,
 		if (help)
 			module_put(help->helper->me);
 
-		nf_ct_l3proto_module_put(par->family);
+		nf_ct_netns_put(par->net, par->family);
 
 		xt_ct_destroy_timeout(ct);
 		nf_ct_put(info->ct);
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index d4bec261e74e..cad0b7b5eb35 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -110,7 +110,7 @@ static int connbytes_mt_check(const struct xt_mtchk_param *par)
 	    sinfo->direction != XT_CONNBYTES_DIR_BOTH)
 		return -EINVAL;
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
@@ -129,7 +129,7 @@ static int connbytes_mt_check(const struct xt_mtchk_param *par)
 
 static void connbytes_mt_destroy(const struct xt_mtdtor_param *par)
 {
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static struct xt_match connbytes_mt_reg __read_mostly = {
diff --git a/net/netfilter/xt_connlabel.c b/net/netfilter/xt_connlabel.c
index 03d66f1c5e69..7827128d5a95 100644
--- a/net/netfilter/xt_connlabel.c
+++ b/net/netfilter/xt_connlabel.c
@@ -61,7 +61,7 @@ static int connlabel_mt_check(const struct xt_mtchk_param *par)
 		return -EINVAL;
 	}
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 							par->family);
@@ -70,14 +70,14 @@ static int connlabel_mt_check(const struct xt_mtchk_param *par)
 
 	ret = nf_connlabels_get(par->net, info->bit);
 	if (ret < 0)
-		nf_ct_l3proto_module_put(par->family);
+		nf_ct_netns_put(par->net, par->family);
 	return ret;
 }
 
 static void connlabel_mt_destroy(const struct xt_mtdtor_param *par)
 {
 	nf_connlabels_put(par->net);
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static struct xt_match connlabels_mt_reg __read_mostly = {
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index bb3845339efd..2aff2b7c4689 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -368,7 +368,7 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 
 	net_get_random_once(&connlimit_rnd, sizeof(connlimit_rnd));
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0) {
 		pr_info("cannot load conntrack support for "
 			"address family %u\n", par->family);
@@ -378,7 +378,7 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 	/* init private data */
 	info->data = kmalloc(sizeof(struct xt_connlimit_data), GFP_KERNEL);
 	if (info->data == NULL) {
-		nf_ct_l3proto_module_put(par->family);
+		nf_ct_netns_put(par->net, par->family);
 		return -ENOMEM;
 	}
 
@@ -414,7 +414,7 @@ static void connlimit_mt_destroy(const struct xt_mtdtor_param *par)
 	const struct xt_connlimit_info *info = par->matchinfo;
 	unsigned int i;
 
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 
 	for (i = 0; i < ARRAY_SIZE(info->data->climit_root4); ++i)
 		destroy_tree(&info->data->climit_root4[i]);
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index b83e158e116a..9935d5029b0e 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -77,7 +77,7 @@ static int connmark_tg_check(const struct xt_tgchk_param *par)
 {
 	int ret;
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
@@ -86,7 +86,7 @@ static int connmark_tg_check(const struct xt_tgchk_param *par)
 
 static void connmark_tg_destroy(const struct xt_tgdtor_param *par)
 {
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static bool
@@ -107,7 +107,7 @@ static int connmark_mt_check(const struct xt_mtchk_param *par)
 {
 	int ret;
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
@@ -116,7 +116,7 @@ static int connmark_mt_check(const struct xt_mtchk_param *par)
 
 static void connmark_mt_destroy(const struct xt_mtdtor_param *par)
 {
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static struct xt_target connmark_tg_reg __read_mostly = {
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 2dea15ebc55b..c0fb217bc649 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -271,7 +271,7 @@ static int conntrack_mt_check(const struct xt_mtchk_param *par)
 {
 	int ret;
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
@@ -280,7 +280,7 @@ static int conntrack_mt_check(const struct xt_mtchk_param *par)
 
 static void conntrack_mt_destroy(const struct xt_mtdtor_param *par)
 {
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static struct xt_match conntrack_mt_reg[] __read_mostly = {
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index f679dd4c272a..38a78151c0e9 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -59,7 +59,7 @@ static int helper_mt_check(const struct xt_mtchk_param *par)
 	struct xt_helper_info *info = par->matchinfo;
 	int ret;
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
@@ -71,7 +71,7 @@ static int helper_mt_check(const struct xt_mtchk_param *par)
 
 static void helper_mt_destroy(const struct xt_mtdtor_param *par)
 {
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static struct xt_match helper_mt_reg __read_mostly = {
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index a507922d80cd..5746a33789a5 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -43,7 +43,7 @@ static int state_mt_check(const struct xt_mtchk_param *par)
 {
 	int ret;
 
-	ret = nf_ct_l3proto_try_module_get(par->family);
+	ret = nf_ct_netns_get(par->net, par->family);
 	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
@@ -52,7 +52,7 @@ static int state_mt_check(const struct xt_mtchk_param *par)
 
 static void state_mt_destroy(const struct xt_mtdtor_param *par)
 {
-	nf_ct_l3proto_module_put(par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static struct xt_match state_mt_reg __read_mostly = {
-- 
2.1.4

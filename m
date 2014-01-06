From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/13] netfilter: nf_tables: remove nft_meta_target
Date: Mon,  6 Jan 2014 14:46:35 +0100
Message-ID: <1389016002-9116-7-git-send-email-pablo@netfilter.org>
References: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59547 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754710AbaAFNq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:46:58 -0500
In-Reply-To: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In e035b77 ("netfilter: nf_tables: nft_meta module get/set ops"),
we got the meta target merged into the existing meta expression.
So let's get rid of this dead code now that we fully support that
feature.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Makefile          |    1 -
 net/netfilter/nft_meta_target.c |  117 ---------------------------------------
 2 files changed, 118 deletions(-)
 delete mode 100644 net/netfilter/nft_meta_target.c

diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index e763746..dcc818a 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -77,7 +77,6 @@ obj-$(CONFIG_NFT_CT)		+= nft_ct.o
 obj-$(CONFIG_NFT_LIMIT)		+= nft_limit.o
 obj-$(CONFIG_NFT_NAT)		+= nft_nat.o
 obj-$(CONFIG_NFT_QUEUE)		+= nft_queue.o
-#nf_tables-objs			+= nft_meta_target.o
 obj-$(CONFIG_NFT_RBTREE)	+= nft_rbtree.o
 obj-$(CONFIG_NFT_HASH)		+= nft_hash.o
 obj-$(CONFIG_NFT_COUNTER)	+= nft_counter.o
diff --git a/net/netfilter/nft_meta_target.c b/net/netfilter/nft_meta_target.c
deleted file mode 100644
index 71177df..0000000
--- a/net/netfilter/nft_meta_target.c
+++ /dev/null
@@ -1,117 +0,0 @@
-/*
- * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * Development of this code funded by Astaro AG (http://www.astaro.com/)
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/list.h>
-#include <linux/rbtree.h>
-#include <linux/netlink.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter/nf_tables.h>
-#include <net/netfilter/nf_tables.h>
-
-struct nft_meta {
-	enum nft_meta_keys	key;
-};
-
-static void nft_meta_eval(const struct nft_expr *expr,
-			  struct nft_data *nfres,
-			  struct nft_data *data,
-			  const struct nft_pktinfo *pkt)
-{
-	const struct nft_meta *meta = nft_expr_priv(expr);
-	struct sk_buff *skb = pkt->skb;
-	u32 val = data->data[0];
-
-	switch (meta->key) {
-	case NFT_META_MARK:
-		skb->mark = val;
-		break;
-	case NFT_META_PRIORITY:
-		skb->priority = val;
-		break;
-	case NFT_META_NFTRACE:
-		skb->nf_trace = val;
-		break;
-#ifdef CONFIG_NETWORK_SECMARK
-	case NFT_META_SECMARK:
-		skb->secmark = val;
-		break;
-#endif
-	default:
-		WARN_ON(1);
-	}
-}
-
-static const struct nla_policy nft_meta_policy[NFTA_META_MAX + 1] = {
-	[NFTA_META_KEY]		= { .type = NLA_U32 },
-};
-
-static int nft_meta_init(const struct nft_expr *expr, struct nlattr *tb[])
-{
-	struct nft_meta *meta = nft_expr_priv(expr);
-
-	if (tb[NFTA_META_KEY] == NULL)
-		return -EINVAL;
-
-	meta->key = ntohl(nla_get_be32(tb[NFTA_META_KEY]));
-	switch (meta->key) {
-	case NFT_META_MARK:
-	case NFT_META_PRIORITY:
-	case NFT_META_NFTRACE:
-#ifdef CONFIG_NETWORK_SECMARK
-	case NFT_META_SECMARK:
-#endif
-		break;
-	default:
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-static int nft_meta_dump(struct sk_buff *skb, const struct nft_expr *expr)
-{
-	struct nft_meta *meta = nft_expr_priv(expr);
-
-	NLA_PUT_BE32(skb, NFTA_META_KEY, htonl(meta->key));
-	return 0;
-
-nla_put_failure:
-	return -1;
-}
-
-static struct nft_expr_ops meta_target __read_mostly = {
-	.name		= "meta",
-	.size		= NFT_EXPR_SIZE(sizeof(struct nft_meta)),
-	.owner		= THIS_MODULE,
-	.eval		= nft_meta_eval,
-	.init		= nft_meta_init,
-	.dump		= nft_meta_dump,
-	.policy		= nft_meta_policy,
-	.maxattr	= NFTA_META_MAX,
-};
-
-static int __init nft_meta_target_init(void)
-{
-	return nft_register_expr(&meta_target);
-}
-
-static void __exit nft_meta_target_exit(void)
-{
-	nft_unregister_expr(&meta_target);
-}
-
-module_init(nft_meta_target_init);
-module_exit(nft_meta_target_exit);
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_ALIAS_NFT_EXPR("meta");
-- 
1.7.10.4

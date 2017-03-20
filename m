From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/22] netfilter: provide nft_ctx in object init function
Date: Mon, 20 Mar 2017 11:08:38 +0100
Message-ID: <1490004530-9128-11-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52114 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754019AbdCTKJq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:46 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 44F9A523F9
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 34CE2DA874
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5572ADA87E
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:08 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

this is needed by the upcoming ct helper object type --
we'd like to be able use the table family (ip, ip6, inet) to figure
out which helper has to be requested.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 3 ++-
 net/netfilter/nf_tables_api.c     | 7 ++++---
 net/netfilter/nft_counter.c       | 3 ++-
 net/netfilter/nft_quota.c         | 3 ++-
 4 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f0d46726d06e..49436849d7d7 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -1017,7 +1017,8 @@ struct nft_object_type {
 	unsigned int			maxattr;
 	struct module			*owner;
 	const struct nla_policy		*policy;
-	int				(*init)(const struct nlattr * const tb[],
+	int				(*init)(const struct nft_ctx *ctx,
+						const struct nlattr *const tb[],
 						struct nft_object *obj);
 	void				(*destroy)(struct nft_object *obj);
 	int				(*dump)(struct sk_buff *skb,
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 4559f5d66bcc..12cc5218de96 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4095,7 +4095,8 @@ static const struct nla_policy nft_obj_policy[NFTA_OBJ_MAX + 1] = {
 	[NFTA_OBJ_DATA]		= { .type = NLA_NESTED },
 };
 
-static struct nft_object *nft_obj_init(const struct nft_object_type *type,
+static struct nft_object *nft_obj_init(const struct nft_ctx *ctx,
+				       const struct nft_object_type *type,
 				       const struct nlattr *attr)
 {
 	struct nlattr *tb[type->maxattr + 1];
@@ -4115,7 +4116,7 @@ static struct nft_object *nft_obj_init(const struct nft_object_type *type,
 	if (obj == NULL)
 		goto err1;
 
-	err = type->init((const struct nlattr * const *)tb, obj);
+	err = type->init(ctx, (const struct nlattr * const *)tb, obj);
 	if (err < 0)
 		goto err2;
 
@@ -4223,7 +4224,7 @@ static int nf_tables_newobj(struct net *net, struct sock *nlsk,
 	if (IS_ERR(type))
 		return PTR_ERR(type);
 
-	obj = nft_obj_init(type, nla[NFTA_OBJ_DATA]);
+	obj = nft_obj_init(&ctx, type, nla[NFTA_OBJ_DATA]);
 	if (IS_ERR(obj)) {
 		err = PTR_ERR(obj);
 		goto err1;
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index 7f8422213341..67a710ebde09 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -82,7 +82,8 @@ static int nft_counter_do_init(const struct nlattr * const tb[],
 	return 0;
 }
 
-static int nft_counter_obj_init(const struct nlattr * const tb[],
+static int nft_counter_obj_init(const struct nft_ctx *ctx,
+				const struct nlattr * const tb[],
 				struct nft_object *obj)
 {
 	struct nft_counter_percpu_priv *priv = nft_obj_data(obj);
diff --git a/net/netfilter/nft_quota.c b/net/netfilter/nft_quota.c
index 2d6fe3559912..25e33159be57 100644
--- a/net/netfilter/nft_quota.c
+++ b/net/netfilter/nft_quota.c
@@ -99,7 +99,8 @@ static int nft_quota_do_init(const struct nlattr * const tb[],
 	return 0;
 }
 
-static int nft_quota_obj_init(const struct nlattr * const tb[],
+static int nft_quota_obj_init(const struct nft_ctx *ctx,
+			      const struct nlattr * const tb[],
 			      struct nft_object *obj)
 {
 	struct nft_quota *priv = nft_obj_data(obj);
-- 
2.1.4

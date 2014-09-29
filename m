From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 33/34] netfilter: nf_tables: store and dump set policy
Date: Mon, 29 Sep 2014 14:39:22 +0200
Message-ID: <1411994363-8451-34-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34396 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754322AbaI2MjC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:39:02 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

We want to know in which cases the user explicitly sets the policy
options. In that case, we also want to dump back the info.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    2 ++
 net/netfilter/nf_tables_api.c     |    6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index c4d8619..3d72923 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -241,6 +241,7 @@ void nft_unregister_set(struct nft_set_ops *ops);
  * 	@dtype: data type (verdict or numeric type defined by userspace)
  * 	@size: maximum set size
  * 	@nelems: number of elements
+ *	@policy: set parameterization (see enum nft_set_policies)
  * 	@ops: set ops
  * 	@flags: set flags
  * 	@klen: key length
@@ -255,6 +256,7 @@ struct nft_set {
 	u32				dtype;
 	u32				size;
 	u32				nelems;
+	u16				policy;
 	/* runtime data below here */
 	const struct nft_set_ops	*ops ____cacheline_aligned;
 	u16				flags;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index a476b99..19e79f0 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2344,6 +2344,11 @@ static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
 			goto nla_put_failure;
 	}
 
+	if (set->policy != NFT_SET_POL_PERFORMANCE) {
+		if (nla_put_be32(skb, NFTA_SET_POLICY, htonl(set->policy)))
+			goto nla_put_failure;
+	}
+
 	desc = nla_nest_start(skb, NFTA_SET_DESC);
 	if (desc == NULL)
 		goto nla_put_failure;
@@ -2669,6 +2674,7 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	set->dlen  = desc.dlen;
 	set->flags = flags;
 	set->size  = desc.size;
+	set->policy = policy;
 
 	err = ops->init(set, &desc, nla);
 	if (err < 0)
-- 
1.7.10.4

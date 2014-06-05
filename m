From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: nf_tables: fix wrong transaction ordering in set elements
Date: Thu,  5 Jun 2014 17:08:22 +0200
Message-ID: <1401980906-25290-3-git-send-email-pablo@netfilter.org>
References: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39227 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638AbaFEPIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 11:08:36 -0400
In-Reply-To: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The transaction needs to be placed at the end of the commit list,
otherwise event notifications are reordered and we may crash when
releasing object via call_rcu.

This problem was introduced in 60319eb ("netfilter: nf_tables: use new
transaction infrastructure to handle elements").

Reported-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 0478847..9365531 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3077,7 +3077,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		goto err4;
 
 	nft_trans_elem(trans) = elem;
-	list_add(&trans->list, &ctx->net->nft.commit_list);
+	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
 	return 0;
 
 err4:
@@ -3161,7 +3161,7 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 		goto err2;
 
 	nft_trans_elem(trans) = elem;
-	list_add(&trans->list, &ctx->net->nft.commit_list);
+	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
 
 	nft_data_uninit(&elem.key, NFT_DATA_VALUE);
 	if (set->flags & NFT_SET_MAP)
-- 
1.7.10.4

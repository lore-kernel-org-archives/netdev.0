From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: nf_tables: fix memory leak if expr init fails
Date: Tue, 12 Jul 2016 18:10:57 +0200
Message-ID: <1468339862-4028-2-git-send-email-pablo@netfilter.org>
References: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

If expr init fails then we need to free it.

So when the user add a nft rule as follows:

  # nft add rule filter input tcp dport 22 flow table ssh \
    { ip saddr limit rate 0/second }

memory leak will happen.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 2c88187..cf7c745 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1724,9 +1724,11 @@ struct nft_expr *nft_expr_init(const struct nft_ctx *ctx,
 
 	err = nf_tables_newexpr(ctx, &info, expr);
 	if (err < 0)
-		goto err2;
+		goto err3;
 
 	return expr;
+err3:
+	kfree(expr);
 err2:
 	module_put(info.ops->type->owner);
 err1:
-- 
2.1.4


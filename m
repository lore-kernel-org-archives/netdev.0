From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/21] netfilter: nft_lookup: use nft_validate_register_store() to validate types
Date: Mon, 13 Apr 2015 21:29:42 +0200
Message-ID: <1428953401-4838-4-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39655 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618AbbDMTZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:25:52 -0400
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

In preparation of validating the length of a register store, use
nft_validate_register_store() in nft_lookup instead of open coding the
validation.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    7 ++++---
 net/netfilter/nft_lookup.c    |    9 ++++-----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index a1e4a92..c96070e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4169,7 +4169,7 @@ EXPORT_SYMBOL_GPL(nft_validate_output_register);
  * 	Validate that a data load uses the appropriate data type for
  * 	the destination register and the length is within the bounds.
  * 	A value of NULL for the data means that its runtime gathered
- * 	data, which is always of type NFT_DATA_VALUE.
+ * 	data.
  */
 int nft_validate_register_store(const struct nft_ctx *ctx,
 				enum nft_registers reg,
@@ -4180,10 +4180,11 @@ int nft_validate_register_store(const struct nft_ctx *ctx,
 
 	switch (reg) {
 	case NFT_REG_VERDICT:
-		if (data == NULL || type != NFT_DATA_VERDICT)
+		if (type != NFT_DATA_VERDICT)
 			return -EINVAL;
 
-		if (data->verdict == NFT_GOTO || data->verdict == NFT_JUMP) {
+		if (data != NULL &&
+		    (data->verdict == NFT_GOTO || data->verdict == NFT_JUMP)) {
 			err = nf_tables_check_loops(ctx, data->chain);
 			if (err < 0)
 				return err;
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index d8cf86f..3e4d8ef 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -84,11 +84,10 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 		if (err < 0)
 			return err;
 
-		if (priv->dreg == NFT_REG_VERDICT) {
-			if (set->dtype != NFT_DATA_VERDICT)
-				return -EINVAL;
-		} else if (set->dtype == NFT_DATA_VERDICT)
-			return -EINVAL;
+		err = nft_validate_register_store(ctx, priv->dreg, NULL,
+						  set->dtype, set->dlen);
+		if (err < 0)
+			return err;
 	} else if (set->flags & NFT_SET_MAP)
 		return -EINVAL;
 
-- 
1.7.10.4

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/9] netfilter: nft_hash: do not dump the auto generated seed
Date: Fri, 14 Apr 2017 02:26:50 +0200
Message-ID: <1492129611-29336-9-git-send-email-pablo@netfilter.org>
References: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

This can prevent the nft utility from printing out the auto generated
seed to the user, which is unnecessary and confusing.

Fixes: cb1b69b0b15b ("netfilter: nf_tables: add hash expression")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_hash.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index eb2721af898d..c4dad1254ead 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -21,6 +21,7 @@ struct nft_hash {
 	enum nft_registers      sreg:8;
 	enum nft_registers      dreg:8;
 	u8			len;
+	bool			autogen_seed:1;
 	u32			modulus;
 	u32			seed;
 	u32			offset;
@@ -82,10 +83,12 @@ static int nft_hash_init(const struct nft_ctx *ctx,
 	if (priv->offset + priv->modulus - 1 < priv->offset)
 		return -EOVERFLOW;
 
-	if (tb[NFTA_HASH_SEED])
+	if (tb[NFTA_HASH_SEED]) {
 		priv->seed = ntohl(nla_get_be32(tb[NFTA_HASH_SEED]));
-	else
+	} else {
+		priv->autogen_seed = true;
 		get_random_bytes(&priv->seed, sizeof(priv->seed));
+	}
 
 	return nft_validate_register_load(priv->sreg, len) &&
 	       nft_validate_register_store(ctx, priv->dreg, NULL,
@@ -105,7 +108,8 @@ static int nft_hash_dump(struct sk_buff *skb,
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_HASH_MODULUS, htonl(priv->modulus)))
 		goto nla_put_failure;
-	if (nla_put_be32(skb, NFTA_HASH_SEED, htonl(priv->seed)))
+	if (!priv->autogen_seed &&
+	    nla_put_be32(skb, NFTA_HASH_SEED, htonl(priv->seed)))
 		goto nla_put_failure;
 	if (priv->offset != 0)
 		if (nla_put_be32(skb, NFTA_HASH_OFFSET, htonl(priv->offset)))
-- 
2.1.4


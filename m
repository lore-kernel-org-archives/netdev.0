From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/3] netfilter: nf_tables: fix nft_cmp_fast failure on big endian for size < 4
Date: Tue, 15 Apr 2014 00:43:35 +0200
Message-ID: <1397515415-5477-4-git-send-email-pablo@netfilter.org>
References: <1397515415-5477-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1397515415-5477-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

nft_cmp_fast is used for equality comparisions of size <= 4. For
comparisions of size < 4 byte a mask is calculated that is applied to
both the data from userspace (during initialization) and the register
value (during runtime). Both values are stored using (in effect) memcpy
to a memory area that is then interpreted as u32 by nft_cmp_fast.

This works fine on little endian since smaller types have the same base
address, however on big endian this is not true and the smaller types
are interpreted as a big number with trailing zero bytes.

The mask therefore must not include the lower bytes, but the higher bytes
on big endian. Add a helper function that does a cpu_to_le32 to switch
the bytes on big endian. Since we're dealing with a mask of just consequitive
bits, this works out fine.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h |   10 ++++++++++
 net/netfilter/nf_tables_core.c         |    3 +--
 net/netfilter/nft_cmp.c                |    2 +-
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index cf2b7ae..a75fc8e 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -13,6 +13,16 @@ struct nft_cmp_fast_expr {
 	u8			len;
 };
 
+/* Calculate the mask for the nft_cmp_fast expression. On big endian the
+ * mask needs to include the *upper* bytes when interpreting that data as
+ * something smaller than the full u32, therefore a cpu_to_le32 is done.
+ */
+static inline u32 nft_cmp_fast_mask(unsigned int len)
+{
+	return cpu_to_le32(~0U >> (FIELD_SIZEOF(struct nft_cmp_fast_expr,
+						data) * BITS_PER_BYTE - len));
+}
+
 extern const struct nft_expr_ops nft_cmp_fast_ops;
 
 int nft_cmp_module_init(void);
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 90998a6..8041053 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -25,9 +25,8 @@ static void nft_cmp_fast_eval(const struct nft_expr *expr,
 			      struct nft_data data[NFT_REG_MAX + 1])
 {
 	const struct nft_cmp_fast_expr *priv = nft_expr_priv(expr);
-	u32 mask;
+	u32 mask = nft_cmp_fast_mask(priv->len);
 
-	mask = ~0U >> (sizeof(priv->data) * BITS_PER_BYTE - priv->len);
 	if ((data[priv->sreg].data[0] & mask) == priv->data)
 		return;
 	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 954925d..e2b3f51 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -128,7 +128,7 @@ static int nft_cmp_fast_init(const struct nft_ctx *ctx,
 	BUG_ON(err < 0);
 	desc.len *= BITS_PER_BYTE;
 
-	mask = ~0U >> (sizeof(priv->data) * BITS_PER_BYTE - desc.len);
+	mask = nft_cmp_fast_mask(desc.len);
 	priv->data = data.data[0] & mask;
 	priv->len  = desc.len;
 	return 0;
-- 
1.7.10.4


From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 4/9] netfilter: nf_tables: move fast operations to header
Date: Tue, 11 Mar 2014 10:19:15 +0100
Message-ID: <1394529560-3490-5-git-send-email-pablo@netfilter.org>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function will be used from different classifiers, so make
them inline and move them to the nf_tables_core.h header file.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_core.h |   42 ++++++++++++++++++++++++++++++++
 net/netfilter/nf_tables_core.c         |   40 ------------------------------
 2 files changed, 42 insertions(+), 40 deletions(-)

diff --git a/include/net/netfilter/nf_tables_core.h b/include/net/netfilter/nf_tables_core.h
index cf2b7ae..004c2aa 100644
--- a/include/net/netfilter/nf_tables_core.h
+++ b/include/net/netfilter/nf_tables_core.h
@@ -39,4 +39,46 @@ extern const struct nft_expr_ops nft_payload_fast_ops;
 int nft_payload_module_init(void);
 void nft_payload_module_exit(void);
 
+#include <net/netfilter/nf_tables.h>
+
+static inline void nft_cmp_fast_eval(const struct nft_expr *expr,
+				     struct nft_data data[NFT_REG_MAX + 1])
+{
+	const struct nft_cmp_fast_expr *priv = nft_expr_priv(expr);
+	u32 mask;
+
+	mask = ~0U >> (sizeof(priv->data) * BITS_PER_BYTE - priv->len);
+	if ((data[priv->sreg].data[0] & mask) == priv->data)
+		return;
+	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+}
+
+static inline bool nft_payload_fast_eval(const struct nft_expr *expr,
+					 struct nft_data data[NFT_REG_MAX + 1],
+					 const struct nft_pktinfo *pkt)
+{
+	const struct nft_payload *priv = nft_expr_priv(expr);
+	const struct sk_buff *skb = pkt->skb;
+	struct nft_data *dest = &data[priv->dreg];
+	unsigned char *ptr;
+
+	if (priv->base == NFT_PAYLOAD_NETWORK_HEADER)
+		ptr = skb_network_header(skb);
+	else
+		ptr = skb_network_header(skb) + pkt->xt.thoff;
+
+	ptr += priv->offset;
+
+	if (unlikely(ptr + priv->len >= skb_tail_pointer(skb)))
+		return false;
+
+	if (priv->len == 2)
+		*(u16 *)dest->data = *(u16 *)ptr;
+	else if (priv->len == 4)
+		*(u32 *)dest->data = *(u32 *)ptr;
+	else
+		*(u8 *)dest->data = *(u8 *)ptr;
+	return true;
+}
+
 #endif /* _NET_NF_TABLES_CORE_H */
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 90998a6..d71a0be 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -21,46 +21,6 @@
 #include <net/netfilter/nf_tables.h>
 #include <net/netfilter/nf_log.h>
 
-static void nft_cmp_fast_eval(const struct nft_expr *expr,
-			      struct nft_data data[NFT_REG_MAX + 1])
-{
-	const struct nft_cmp_fast_expr *priv = nft_expr_priv(expr);
-	u32 mask;
-
-	mask = ~0U >> (sizeof(priv->data) * BITS_PER_BYTE - priv->len);
-	if ((data[priv->sreg].data[0] & mask) == priv->data)
-		return;
-	data[NFT_REG_VERDICT].verdict = NFT_BREAK;
-}
-
-static bool nft_payload_fast_eval(const struct nft_expr *expr,
-				  struct nft_data data[NFT_REG_MAX + 1],
-				  const struct nft_pktinfo *pkt)
-{
-	const struct nft_payload *priv = nft_expr_priv(expr);
-	const struct sk_buff *skb = pkt->skb;
-	struct nft_data *dest = &data[priv->dreg];
-	unsigned char *ptr;
-
-	if (priv->base == NFT_PAYLOAD_NETWORK_HEADER)
-		ptr = skb_network_header(skb);
-	else
-		ptr = skb_network_header(skb) + pkt->xt.thoff;
-
-	ptr += priv->offset;
-
-	if (unlikely(ptr + priv->len >= skb_tail_pointer(skb)))
-		return false;
-
-	if (priv->len == 2)
-		*(u16 *)dest->data = *(u16 *)ptr;
-	else if (priv->len == 4)
-		*(u32 *)dest->data = *(u32 *)ptr;
-	else
-		*(u8 *)dest->data = *(u8 *)ptr;
-	return true;
-}
-
 struct nft_jumpstack {
 	const struct nft_chain	*chain;
 	const struct nft_rule	*rule;
-- 
1.7.10.4


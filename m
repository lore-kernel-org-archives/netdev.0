From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/20] netfilter: nf_tables: add GC synchronization helpers
Date: Thu,  9 Apr 2015 13:34:48 +0200
Message-ID: <1428579304-5520-5-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33039 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932892AbbDILbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:06 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

GC is expected to happen asynchrously to the netlink interface. In the
netlink path, both insertion and removal of elements consist of two
steps, insertion followed by activation or deactivation followed by
removal, during which the element must not be freed by GC.

The synchronization helpers use an unused bit in the genmask field to
atomically mark an element as "busy", meaning it is either currently
being handled through the netlink API or by GC.

Elements being processed by GC will never survive, netlink will simply
ignore them. Elements being currently processed through netlink will be
skipped by GC and reprocessed during the next run.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |   35 +++++++++++++++++++++++++++++++++++
 net/netfilter/nf_tables_api.c     |    2 +-
 2 files changed, 36 insertions(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 6fd4495..1ea13fc 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -852,6 +852,41 @@ static inline void nft_set_elem_change_active(const struct nft_set *set,
 	ext->genmask ^= nft_genmask_next(read_pnet(&set->pnet));
 }
 
+/*
+ * We use a free bit in the genmask field to indicate the element
+ * is busy, meaning it is currently being processed either by
+ * the netlink API or GC.
+ *
+ * Even though the genmask is only a single byte wide, this works
+ * because the extension structure if fully constant once initialized,
+ * so there are no non-atomic write accesses unless it is already
+ * marked busy.
+ */
+#define NFT_SET_ELEM_BUSY_MASK	(1 << 2)
+
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+#define NFT_SET_ELEM_BUSY_BIT	2
+#elif defined(__BIG_ENDIAN_BITFIELD)
+#define NFT_SET_ELEM_BUSY_BIT	(BITS_PER_LONG - BITS_PER_BYTE + 2)
+#else
+#error
+#endif
+
+static inline int nft_set_elem_mark_busy(struct nft_set_ext *ext)
+{
+	unsigned long *word = (unsigned long *)ext;
+
+	BUILD_BUG_ON(offsetof(struct nft_set_ext, genmask) != 0);
+	return test_and_set_bit(NFT_SET_ELEM_BUSY_BIT, word);
+}
+
+static inline void nft_set_elem_clear_busy(struct nft_set_ext *ext)
+{
+	unsigned long *word = (unsigned long *)ext;
+
+	clear_bit(NFT_SET_ELEM_BUSY_BIT, word);
+}
+
 /**
  *	struct nft_trans - nf_tables object update in transaction
  *
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 138e47f..3aa92b3 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3338,7 +3338,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	if (trans == NULL)
 		goto err4;
 
-	ext->genmask = nft_genmask_cur(ctx->net);
+	ext->genmask = nft_genmask_cur(ctx->net) | NFT_SET_ELEM_BUSY_MASK;
 	err = set->ops->insert(set, &elem);
 	if (err < 0)
 		goto err5;
-- 
1.7.10.4

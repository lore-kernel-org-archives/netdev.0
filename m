From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/20] netfilter: nf_tables: add set garbage collection helpers
Date: Thu,  9 Apr 2015 13:34:47 +0200
Message-ID: <1428579304-5520-4-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33088 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932936AbbDILbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:12 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add helpers for GC batch destruction: since element destruction needs
a RCU grace period for all set implementations, add some helper functions
for asynchronous batch destruction. Elements are collected in a batch
structure, which is asynchronously released using RCU once its full.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |   56 +++++++++++++++++++++++++++++++++++++
 net/netfilter/nf_tables_api.c     |   25 +++++++++++++++++
 2 files changed, 81 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f2726c5..6fd4495 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -460,6 +460,62 @@ static inline struct nft_set_ext *nft_set_elem_ext(const struct nft_set *set,
 void nft_set_elem_destroy(const struct nft_set *set, void *elem);
 
 /**
+ *	struct nft_set_gc_batch_head - nf_tables set garbage collection batch
+ *
+ *	@rcu: rcu head
+ *	@set: set the elements belong to
+ *	@cnt: count of elements
+ */
+struct nft_set_gc_batch_head {
+	struct rcu_head			rcu;
+	const struct nft_set		*set;
+	unsigned int			cnt;
+};
+
+#define NFT_SET_GC_BATCH_SIZE	((PAGE_SIZE -				  \
+				  sizeof(struct nft_set_gc_batch_head)) / \
+				 sizeof(void *))
+
+/**
+ *	struct nft_set_gc_batch - nf_tables set garbage collection batch
+ *
+ * 	@head: GC batch head
+ * 	@elems: garbage collection elements
+ */
+struct nft_set_gc_batch {
+	struct nft_set_gc_batch_head	head;
+	void				*elems[NFT_SET_GC_BATCH_SIZE];
+};
+
+struct nft_set_gc_batch *nft_set_gc_batch_alloc(const struct nft_set *set,
+						gfp_t gfp);
+void nft_set_gc_batch_release(struct rcu_head *rcu);
+
+static inline void nft_set_gc_batch_complete(struct nft_set_gc_batch *gcb)
+{
+	if (gcb != NULL)
+		call_rcu(&gcb->head.rcu, nft_set_gc_batch_release);
+}
+
+static inline struct nft_set_gc_batch *
+nft_set_gc_batch_check(const struct nft_set *set, struct nft_set_gc_batch *gcb,
+		       gfp_t gfp)
+{
+	if (gcb != NULL) {
+		if (gcb->head.cnt + 1 < ARRAY_SIZE(gcb->elems))
+			return gcb;
+		nft_set_gc_batch_complete(gcb);
+	}
+	return nft_set_gc_batch_alloc(set, gfp);
+}
+
+static inline void nft_set_gc_batch_add(struct nft_set_gc_batch *gcb,
+					void *elem)
+{
+	gcb->elems[gcb->head.cnt++] = elem;
+}
+
+/**
  *	struct nft_expr_type - nf_tables expression type
  *
  *	@select_ops: function to select nft_expr_ops
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 9e032db..138e47f 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3482,6 +3482,31 @@ static int nf_tables_delsetelem(struct sock *nlsk, struct sk_buff *skb,
 	return err;
 }
 
+void nft_set_gc_batch_release(struct rcu_head *rcu)
+{
+	struct nft_set_gc_batch *gcb;
+	unsigned int i;
+
+	gcb = container_of(rcu, struct nft_set_gc_batch, head.rcu);
+	for (i = 0; i < gcb->head.cnt; i++)
+		nft_set_elem_destroy(gcb->head.set, gcb->elems[i]);
+	kfree(gcb);
+}
+EXPORT_SYMBOL_GPL(nft_set_gc_batch_release);
+
+struct nft_set_gc_batch *nft_set_gc_batch_alloc(const struct nft_set *set,
+						gfp_t gfp)
+{
+	struct nft_set_gc_batch *gcb;
+
+	gcb = kzalloc(sizeof(*gcb), gfp);
+	if (gcb == NULL)
+		return gcb;
+	gcb->head.set = set;
+	return gcb;
+}
+EXPORT_SYMBOL_GPL(nft_set_gc_batch_alloc);
+
 static int nf_tables_fill_gen_info(struct sk_buff *skb, struct net *net,
 				   u32 portid, u32 seq)
 {
-- 
1.7.10.4

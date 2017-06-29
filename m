From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/29] netfilter: nf_tables: pass set description to ->privsize
Date: Fri, 30 Jun 2017 00:53:12 +0200
Message-ID: <1498776807-11124-15-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new non-resizable hashtable variant needs this to calculate the
size of the bucket array.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 3 ++-
 net/netfilter/nf_tables_api.c     | 2 +-
 net/netfilter/nft_set_bitmap.c    | 3 ++-
 net/netfilter/nft_set_hash.c      | 3 ++-
 net/netfilter/nft_set_rbtree.c    | 3 ++-
 5 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f27012098846..bd5be0d691d5 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -351,7 +351,8 @@ struct nft_set_ops {
 						struct nft_set *set,
 						struct nft_set_iter *iter);
 
-	unsigned int			(*privsize)(const struct nlattr * const nla[]);
+	unsigned int			(*privsize)(const struct nlattr * const nla[],
+						    const struct nft_set_desc *desc);
 	bool				(*estimate)(const struct nft_set_desc *desc,
 						    u32 features,
 						    struct nft_set_estimate *est);
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index c0b2b19607e1..2969016d8cad 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3052,7 +3052,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 
 	size = 0;
 	if (ops->privsize != NULL)
-		size = ops->privsize(nla);
+		size = ops->privsize(nla, &desc);
 
 	err = -ENOMEM;
 	set = kzalloc(sizeof(*set) + size + udlen, GFP_KERNEL);
diff --git a/net/netfilter/nft_set_bitmap.c b/net/netfilter/nft_set_bitmap.c
index 87d17691278f..734989c40579 100644
--- a/net/netfilter/nft_set_bitmap.c
+++ b/net/netfilter/nft_set_bitmap.c
@@ -236,7 +236,8 @@ static inline u32 nft_bitmap_total_size(u32 klen)
 	return sizeof(struct nft_bitmap) + nft_bitmap_size(klen);
 }
 
-static unsigned int nft_bitmap_privsize(const struct nlattr * const nla[])
+static unsigned int nft_bitmap_privsize(const struct nlattr * const nla[],
+					const struct nft_set_desc *desc)
 {
 	u32 klen = ntohl(nla_get_be32(nla[NFTA_SET_KEY_LEN]));
 
diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 4ba0717408d9..455a11ce8cd0 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -321,7 +321,8 @@ static void nft_rhash_gc(struct work_struct *work)
 			   nft_set_gc_interval(set));
 }
 
-static unsigned int nft_rhash_privsize(const struct nlattr * const nla[])
+static unsigned int nft_rhash_privsize(const struct nlattr * const nla[],
+				       const struct nft_set_desc *desc)
 {
 	return sizeof(struct nft_rhash);
 }
diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index 29d41d378339..491e805d3ca2 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -251,7 +251,8 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 	read_unlock_bh(&priv->lock);
 }
 
-static unsigned int nft_rbtree_privsize(const struct nlattr * const nla[])
+static unsigned int nft_rbtree_privsize(const struct nlattr * const nla[],
+					const struct nft_set_desc *desc)
 {
 	return sizeof(struct nft_rbtree);
 }
-- 
2.1.4


From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/20] netfilter: nf_tables: add set timeout API support
Date: Thu,  9 Apr 2015 13:34:45 +0200
Message-ID: <1428579304-5520-2-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Add set timeout support to the netlink API. Sets with timeout support
enabled can have a default timeout value and garbage collection interval
specified.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |    9 +++++++++
 include/uapi/linux/netfilter/nf_tables.h |    6 ++++++
 net/netfilter/nf_tables_api.c            |   30 ++++++++++++++++++++++++++++--
 3 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index b8cd60d..8936803 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -258,6 +258,8 @@ void nft_unregister_set(struct nft_set_ops *ops);
  * 	@dtype: data type (verdict or numeric type defined by userspace)
  * 	@size: maximum set size
  * 	@nelems: number of elements
+ * 	@timeout: default timeout value in msecs
+ * 	@gc_int: garbage collection interval in msecs
  *	@policy: set parameterization (see enum nft_set_policies)
  * 	@ops: set ops
  * 	@pnet: network namespace
@@ -274,6 +276,8 @@ struct nft_set {
 	u32				dtype;
 	u32				size;
 	u32				nelems;
+	u64				timeout;
+	u32				gc_int;
 	u16				policy;
 	/* runtime data below here */
 	const struct nft_set_ops	*ops ____cacheline_aligned;
@@ -295,6 +299,11 @@ struct nft_set *nf_tables_set_lookup(const struct nft_table *table,
 struct nft_set *nf_tables_set_lookup_byid(const struct net *net,
 					  const struct nlattr *nla);
 
+static inline unsigned long nft_set_gc_interval(const struct nft_set *set)
+{
+	return set->gc_int ? msecs_to_jiffies(set->gc_int) : HZ;
+}
+
 /**
  *	struct nft_set_binding - nf_tables set binding
  *
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index b978393..971d245 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -208,12 +208,14 @@ enum nft_rule_compat_attributes {
  * @NFT_SET_CONSTANT: set contents may not change while bound
  * @NFT_SET_INTERVAL: set contains intervals
  * @NFT_SET_MAP: set is used as a dictionary
+ * @NFT_SET_TIMEOUT: set uses timeouts
  */
 enum nft_set_flags {
 	NFT_SET_ANONYMOUS		= 0x1,
 	NFT_SET_CONSTANT		= 0x2,
 	NFT_SET_INTERVAL		= 0x4,
 	NFT_SET_MAP			= 0x8,
+	NFT_SET_TIMEOUT			= 0x10,
 };
 
 /**
@@ -252,6 +254,8 @@ enum nft_set_desc_attributes {
  * @NFTA_SET_POLICY: selection policy (NLA_U32)
  * @NFTA_SET_DESC: set description (NLA_NESTED)
  * @NFTA_SET_ID: uniquely identifies a set in a transaction (NLA_U32)
+ * @NFTA_SET_TIMEOUT: default timeout value (NLA_U64)
+ * @NFTA_SET_GC_INTERVAL: garbage collection interval (NLA_U32)
  */
 enum nft_set_attributes {
 	NFTA_SET_UNSPEC,
@@ -265,6 +269,8 @@ enum nft_set_attributes {
 	NFTA_SET_POLICY,
 	NFTA_SET_DESC,
 	NFTA_SET_ID,
+	NFTA_SET_TIMEOUT,
+	NFTA_SET_GC_INTERVAL,
 	__NFTA_SET_MAX
 };
 #define NFTA_SET_MAX		(__NFTA_SET_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 5604c2d..6320b64 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2216,6 +2216,8 @@ static const struct nla_policy nft_set_policy[NFTA_SET_MAX + 1] = {
 	[NFTA_SET_POLICY]		= { .type = NLA_U32 },
 	[NFTA_SET_DESC]			= { .type = NLA_NESTED },
 	[NFTA_SET_ID]			= { .type = NLA_U32 },
+	[NFTA_SET_TIMEOUT]		= { .type = NLA_U64 },
+	[NFTA_SET_GC_INTERVAL]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy nft_set_desc_policy[NFTA_SET_DESC_MAX + 1] = {
@@ -2366,6 +2368,13 @@ static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
 			goto nla_put_failure;
 	}
 
+	if (set->timeout &&
+	    nla_put_be64(skb, NFTA_SET_TIMEOUT, cpu_to_be64(set->timeout)))
+		goto nla_put_failure;
+	if (set->gc_int &&
+	    nla_put_be32(skb, NFTA_SET_GC_INTERVAL, htonl(set->gc_int)))
+		goto nla_put_failure;
+
 	if (set->policy != NFT_SET_POL_PERFORMANCE) {
 		if (nla_put_be32(skb, NFTA_SET_POLICY, htonl(set->policy)))
 			goto nla_put_failure;
@@ -2578,7 +2587,8 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	char name[IFNAMSIZ];
 	unsigned int size;
 	bool create;
-	u32 ktype, dtype, flags, policy;
+	u64 timeout;
+	u32 ktype, dtype, flags, policy, gc_int;
 	struct nft_set_desc desc;
 	int err;
 
@@ -2605,7 +2615,8 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	if (nla[NFTA_SET_FLAGS] != NULL) {
 		flags = ntohl(nla_get_be32(nla[NFTA_SET_FLAGS]));
 		if (flags & ~(NFT_SET_ANONYMOUS | NFT_SET_CONSTANT |
-			      NFT_SET_INTERVAL | NFT_SET_MAP))
+			      NFT_SET_INTERVAL | NFT_SET_MAP |
+			      NFT_SET_TIMEOUT))
 			return -EINVAL;
 	}
 
@@ -2631,6 +2642,19 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	} else if (flags & NFT_SET_MAP)
 		return -EINVAL;
 
+	timeout = 0;
+	if (nla[NFTA_SET_TIMEOUT] != NULL) {
+		if (!(flags & NFT_SET_TIMEOUT))
+			return -EINVAL;
+		timeout = be64_to_cpu(nla_get_be64(nla[NFTA_SET_TIMEOUT]));
+	}
+	gc_int = 0;
+	if (nla[NFTA_SET_GC_INTERVAL] != NULL) {
+		if (!(flags & NFT_SET_TIMEOUT))
+			return -EINVAL;
+		gc_int = ntohl(nla_get_be32(nla[NFTA_SET_GC_INTERVAL]));
+	}
+
 	policy = NFT_SET_POL_PERFORMANCE;
 	if (nla[NFTA_SET_POLICY] != NULL)
 		policy = ntohl(nla_get_be32(nla[NFTA_SET_POLICY]));
@@ -2699,6 +2723,8 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	set->flags = flags;
 	set->size  = desc.size;
 	set->policy = policy;
+	set->timeout = timeout;
+	set->gc_int = gc_int;
 
 	err = ops->init(set, &desc, nla);
 	if (err < 0)
-- 
1.7.10.4


From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/7] netfilter: nf_tables: fix userdata length overflow
Date: Thu,  5 Mar 2015 21:48:48 +0100
Message-ID: <1425588529-4573-7-git-send-email-pablo@netfilter.org>
References: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The NFT_USERDATA_MAXLEN is defined to 256, however we only have a u8
to store its size. Introduce a struct nft_userdata which contains a
length field and indicate its presence using a single bit in the rule.

The length field of struct nft_userdata is also a u8, however we don't
store zero sized data, so the actual length is udata->len + 1.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |   22 +++++++++++++++++++---
 net/netfilter/nf_tables_api.c     |   28 +++++++++++++++++++---------
 2 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 9eaaa78..decb9a0 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -119,6 +119,22 @@ int nft_validate_data_load(const struct nft_ctx *ctx, enum nft_registers reg,
 			   const struct nft_data *data,
 			   enum nft_data_types type);
 
+
+/**
+ *	struct nft_userdata - user defined data associated with an object
+ *
+ *	@len: length of the data
+ *	@data: content
+ *
+ *	The presence of user data is indicated in an object specific fashion,
+ *	so a length of zero can't occur and the value "len" indicates data
+ *	of length len + 1.
+ */
+struct nft_userdata {
+	u8			len;
+	unsigned char		data[0];
+};
+
 /**
  *	struct nft_set_elem - generic representation of set elements
  *
@@ -380,7 +396,7 @@ static inline void *nft_expr_priv(const struct nft_expr *expr)
  *	@handle: rule handle
  *	@genmask: generation mask
  *	@dlen: length of expression data
- *	@ulen: length of user data (used for comments)
+ *	@udata: user data is appended to the rule
  *	@data: expression data
  */
 struct nft_rule {
@@ -388,7 +404,7 @@ struct nft_rule {
 	u64				handle:42,
 					genmask:2,
 					dlen:12,
-					ulen:8;
+					udata:1;
 	unsigned char			data[]
 		__attribute__((aligned(__alignof__(struct nft_expr))));
 };
@@ -476,7 +492,7 @@ static inline struct nft_expr *nft_expr_last(const struct nft_rule *rule)
 	return (struct nft_expr *)&rule->data[rule->dlen];
 }
 
-static inline void *nft_userdata(const struct nft_rule *rule)
+static inline struct nft_userdata *nft_userdata(const struct nft_rule *rule)
 {
 	return (void *)&rule->data[rule->dlen];
 }
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 7baafd5..74e4b87 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1711,9 +1711,12 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, struct net *net,
 	}
 	nla_nest_end(skb, list);
 
-	if (rule->ulen &&
-	    nla_put(skb, NFTA_RULE_USERDATA, rule->ulen, nft_userdata(rule)))
-		goto nla_put_failure;
+	if (rule->udata) {
+		struct nft_userdata *udata = nft_userdata(rule);
+		if (nla_put(skb, NFTA_RULE_USERDATA, udata->len + 1,
+			    udata->data) < 0)
+			goto nla_put_failure;
+	}
 
 	nlmsg_end(skb, nlh);
 	return 0;
@@ -1896,11 +1899,12 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 	struct nft_table *table;
 	struct nft_chain *chain;
 	struct nft_rule *rule, *old_rule = NULL;
+	struct nft_userdata *udata;
 	struct nft_trans *trans = NULL;
 	struct nft_expr *expr;
 	struct nft_ctx ctx;
 	struct nlattr *tmp;
-	unsigned int size, i, n, ulen = 0;
+	unsigned int size, i, n, ulen = 0, usize = 0;
 	int err, rem;
 	bool create;
 	u64 handle, pos_handle;
@@ -1973,11 +1977,14 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 	if (size >= 1 << 12)
 		goto err1;
 
-	if (nla[NFTA_RULE_USERDATA])
+	if (nla[NFTA_RULE_USERDATA]) {
 		ulen = nla_len(nla[NFTA_RULE_USERDATA]);
+		if (ulen > 0)
+			usize = sizeof(struct nft_userdata) + ulen;
+	}
 
 	err = -ENOMEM;
-	rule = kzalloc(sizeof(*rule) + size + ulen, GFP_KERNEL);
+	rule = kzalloc(sizeof(*rule) + size + usize, GFP_KERNEL);
 	if (rule == NULL)
 		goto err1;
 
@@ -1985,10 +1992,13 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 
 	rule->handle = handle;
 	rule->dlen   = size;
-	rule->ulen   = ulen;
+	rule->udata  = ulen ? 1 : 0;
 
-	if (ulen)
-		nla_memcpy(nft_userdata(rule), nla[NFTA_RULE_USERDATA], ulen);
+	if (ulen) {
+		udata = nft_userdata(rule);
+		udata->len = ulen - 1;
+		nla_memcpy(udata->data, nla[NFTA_RULE_USERDATA], ulen);
+	}
 
 	expr = nft_expr_first(rule);
 	for (i = 0; i < n; i++) {
-- 
1.7.10.4


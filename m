From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/38] netfilter: nf_tables: add optional user data area to rules
Date: Mon, 17 Mar 2014 13:42:29 +0100
Message-ID: <1395060178-11833-10-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows us to store user comment strings, but it could be also
used to store any kind of information that the user application needs
to link to the rule.

Scratch 8 bits for the new ulen field that indicates the length the
user data area. 4 bits from the handle (so it's 42 bits long, according
to Patrick, it would last 139 years with 1000 new rules per second)
and 4 bits from dlen (so the expression data area is 4K, which seems
sufficient by now even considering the compatibility layer).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_tables.h        |   11 +++++++++--
 include/uapi/linux/netfilter/nf_tables.h |    5 ++++-
 net/netfilter/nf_tables_api.c            |   17 +++++++++++++++--
 3 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 81abd61..5af56da 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -326,13 +326,15 @@ static inline void *nft_expr_priv(const struct nft_expr *expr)
  *	@handle: rule handle
  *	@genmask: generation mask
  *	@dlen: length of expression data
+ *	@ulen: length of user data (used for comments)
  *	@data: expression data
  */
 struct nft_rule {
 	struct list_head		list;
-	u64				handle:46,
+	u64				handle:42,
 					genmask:2,
-					dlen:16;
+					dlen:12,
+					ulen:8;
 	unsigned char			data[]
 		__attribute__((aligned(__alignof__(struct nft_expr))));
 };
@@ -371,6 +373,11 @@ static inline struct nft_expr *nft_expr_last(const struct nft_rule *rule)
 	return (struct nft_expr *)&rule->data[rule->dlen];
 }
 
+static inline void *nft_userdata(const struct nft_rule *rule)
+{
+	return (void *)&rule->data[rule->dlen];
+}
+
 /*
  * The last pointer isn't really necessary, but the compiler isn't able to
  * determine that the result of nft_expr_last() is always the same since it
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index c84c452..c88ccbf 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1,7 +1,8 @@
 #ifndef _LINUX_NF_TABLES_H
 #define _LINUX_NF_TABLES_H
 
-#define NFT_CHAIN_MAXNAMELEN 32
+#define NFT_CHAIN_MAXNAMELEN	32
+#define NFT_USERDATA_MAXLEN	256
 
 enum nft_registers {
 	NFT_REG_VERDICT,
@@ -156,6 +157,7 @@ enum nft_chain_attributes {
  * @NFTA_RULE_EXPRESSIONS: list of expressions (NLA_NESTED: nft_expr_attributes)
  * @NFTA_RULE_COMPAT: compatibility specifications of the rule (NLA_NESTED: nft_rule_compat_attributes)
  * @NFTA_RULE_POSITION: numeric handle of the previous rule (NLA_U64)
+ * @NFTA_RULE_USERDATA: user data (NLA_BINARY, NFT_USERDATA_MAXLEN)
  */
 enum nft_rule_attributes {
 	NFTA_RULE_UNSPEC,
@@ -165,6 +167,7 @@ enum nft_rule_attributes {
 	NFTA_RULE_EXPRESSIONS,
 	NFTA_RULE_COMPAT,
 	NFTA_RULE_POSITION,
+	NFTA_RULE_USERDATA,
 	__NFTA_RULE_MAX
 };
 #define NFTA_RULE_MAX		(__NFTA_RULE_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 0b56340..f25d011 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1295,6 +1295,8 @@ static const struct nla_policy nft_rule_policy[NFTA_RULE_MAX + 1] = {
 	[NFTA_RULE_EXPRESSIONS]	= { .type = NLA_NESTED },
 	[NFTA_RULE_COMPAT]	= { .type = NLA_NESTED },
 	[NFTA_RULE_POSITION]	= { .type = NLA_U64 },
+	[NFTA_RULE_USERDATA]	= { .type = NLA_BINARY,
+				    .len = NFT_USERDATA_MAXLEN },
 };
 
 static int nf_tables_fill_rule_info(struct sk_buff *skb, u32 portid, u32 seq,
@@ -1347,6 +1349,10 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, u32 portid, u32 seq,
 	}
 	nla_nest_end(skb, list);
 
+	if (rule->ulen &&
+	    nla_put(skb, NFTA_RULE_USERDATA, rule->ulen, nft_userdata(rule)))
+		goto nla_put_failure;
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -1583,7 +1589,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 	struct nft_expr *expr;
 	struct nft_ctx ctx;
 	struct nlattr *tmp;
-	unsigned int size, i, n;
+	unsigned int size, i, n, ulen = 0;
 	int err, rem;
 	bool create;
 	u64 handle, pos_handle;
@@ -1649,8 +1655,11 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 		}
 	}
 
+	if (nla[NFTA_RULE_USERDATA])
+		ulen = nla_len(nla[NFTA_RULE_USERDATA]);
+
 	err = -ENOMEM;
-	rule = kzalloc(sizeof(*rule) + size, GFP_KERNEL);
+	rule = kzalloc(sizeof(*rule) + size + ulen, GFP_KERNEL);
 	if (rule == NULL)
 		goto err1;
 
@@ -1658,6 +1667,10 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 
 	rule->handle = handle;
 	rule->dlen   = size;
+	rule->ulen   = ulen;
+
+	if (ulen)
+		nla_memcpy(nft_userdata(rule), nla[NFTA_RULE_USERDATA], ulen);
 
 	expr = nft_expr_first(rule);
 	for (i = 0; i < n; i++) {
-- 
1.7.10.4


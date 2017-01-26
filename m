From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/14] netfilter: nf_tables: validate the name size when possible
Date: Thu, 26 Jan 2017 17:38:03 +0100
Message-ID: <1485448687-6072-11-git-send-email-pablo@netfilter.org>
References: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

Currently, if the user add a stateful object with the name size exceed
NFT_OBJ_MAXNAMELEN - 1 (i.e. 31), we truncate it down to 31 silently.
This is not friendly, furthermore, this will cause duplicated stateful
objects when the first 31 characters of the name is same. So limit the
stateful object's name size to NFT_OBJ_MAXNAMELEN - 1.

After apply this patch, error message will be printed out like this:
  # name_32=$(printf "%0.sQ" {1..32})
  # nft add counter filter $name_32
  <cmdline>:1:1-52: Error: Could not process rule: Numerical result out
  of range
  add counter filter QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Also this patch cleans up the codes which missing the name size limit
validation in nftables.

Fixes: e50092404c1b ("netfilter: nf_tables: add stateful objects")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 21 ++++++++++++++-------
 net/netfilter/nft_dynset.c    |  3 ++-
 net/netfilter/nft_lookup.c    |  3 ++-
 net/netfilter/nft_objref.c    |  6 ++++--
 4 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 091d2dcc63b2..b84c7b25219b 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -928,7 +928,8 @@ static struct nft_chain *nf_tables_chain_lookup(const struct nft_table *table,
 }
 
 static const struct nla_policy nft_chain_policy[NFTA_CHAIN_MAX + 1] = {
-	[NFTA_CHAIN_TABLE]	= { .type = NLA_STRING },
+	[NFTA_CHAIN_TABLE]	= { .type = NLA_STRING,
+				    .len = NFT_TABLE_MAXNAMELEN - 1 },
 	[NFTA_CHAIN_HANDLE]	= { .type = NLA_U64 },
 	[NFTA_CHAIN_NAME]	= { .type = NLA_STRING,
 				    .len = NFT_CHAIN_MAXNAMELEN - 1 },
@@ -1854,7 +1855,8 @@ static struct nft_rule *nf_tables_rule_lookup(const struct nft_chain *chain,
 }
 
 static const struct nla_policy nft_rule_policy[NFTA_RULE_MAX + 1] = {
-	[NFTA_RULE_TABLE]	= { .type = NLA_STRING },
+	[NFTA_RULE_TABLE]	= { .type = NLA_STRING,
+				    .len = NFT_TABLE_MAXNAMELEN - 1 },
 	[NFTA_RULE_CHAIN]	= { .type = NLA_STRING,
 				    .len = NFT_CHAIN_MAXNAMELEN - 1 },
 	[NFTA_RULE_HANDLE]	= { .type = NLA_U64 },
@@ -2443,7 +2445,8 @@ nft_select_set_ops(const struct nlattr * const nla[],
 }
 
 static const struct nla_policy nft_set_policy[NFTA_SET_MAX + 1] = {
-	[NFTA_SET_TABLE]		= { .type = NLA_STRING },
+	[NFTA_SET_TABLE]		= { .type = NLA_STRING,
+					    .len = NFT_TABLE_MAXNAMELEN - 1 },
 	[NFTA_SET_NAME]			= { .type = NLA_STRING,
 					    .len = NFT_SET_MAXNAMELEN - 1 },
 	[NFTA_SET_FLAGS]		= { .type = NLA_U32 },
@@ -3192,8 +3195,10 @@ static const struct nla_policy nft_set_elem_policy[NFTA_SET_ELEM_MAX + 1] = {
 };
 
 static const struct nla_policy nft_set_elem_list_policy[NFTA_SET_ELEM_LIST_MAX + 1] = {
-	[NFTA_SET_ELEM_LIST_TABLE]	= { .type = NLA_STRING },
-	[NFTA_SET_ELEM_LIST_SET]	= { .type = NLA_STRING },
+	[NFTA_SET_ELEM_LIST_TABLE]	= { .type = NLA_STRING,
+					    .len = NFT_TABLE_MAXNAMELEN - 1 },
+	[NFTA_SET_ELEM_LIST_SET]	= { .type = NLA_STRING,
+					    .len = NFT_SET_MAXNAMELEN - 1 },
 	[NFTA_SET_ELEM_LIST_ELEMENTS]	= { .type = NLA_NESTED },
 	[NFTA_SET_ELEM_LIST_SET_ID]	= { .type = NLA_U32 },
 };
@@ -4032,8 +4037,10 @@ struct nft_object *nf_tables_obj_lookup(const struct nft_table *table,
 EXPORT_SYMBOL_GPL(nf_tables_obj_lookup);
 
 static const struct nla_policy nft_obj_policy[NFTA_OBJ_MAX + 1] = {
-	[NFTA_OBJ_TABLE]	= { .type = NLA_STRING },
-	[NFTA_OBJ_NAME]		= { .type = NLA_STRING },
+	[NFTA_OBJ_TABLE]	= { .type = NLA_STRING,
+				    .len = NFT_TABLE_MAXNAMELEN - 1 },
+	[NFTA_OBJ_NAME]		= { .type = NLA_STRING,
+				    .len = NFT_OBJ_MAXNAMELEN - 1 },
 	[NFTA_OBJ_TYPE]		= { .type = NLA_U32 },
 	[NFTA_OBJ_DATA]		= { .type = NLA_NESTED },
 };
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 7de2f46734a4..049ad2d9ee66 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -98,7 +98,8 @@ static void nft_dynset_eval(const struct nft_expr *expr,
 }
 
 static const struct nla_policy nft_dynset_policy[NFTA_DYNSET_MAX + 1] = {
-	[NFTA_DYNSET_SET_NAME]	= { .type = NLA_STRING },
+	[NFTA_DYNSET_SET_NAME]	= { .type = NLA_STRING,
+				    .len = NFT_SET_MAXNAMELEN - 1 },
 	[NFTA_DYNSET_SET_ID]	= { .type = NLA_U32 },
 	[NFTA_DYNSET_OP]	= { .type = NLA_U32 },
 	[NFTA_DYNSET_SREG_KEY]	= { .type = NLA_U32 },
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index d4f97fa7e21d..e21aea7e5ec8 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -49,7 +49,8 @@ static void nft_lookup_eval(const struct nft_expr *expr,
 }
 
 static const struct nla_policy nft_lookup_policy[NFTA_LOOKUP_MAX + 1] = {
-	[NFTA_LOOKUP_SET]	= { .type = NLA_STRING },
+	[NFTA_LOOKUP_SET]	= { .type = NLA_STRING,
+				    .len = NFT_SET_MAXNAMELEN - 1 },
 	[NFTA_LOOKUP_SET_ID]	= { .type = NLA_U32 },
 	[NFTA_LOOKUP_SREG]	= { .type = NLA_U32 },
 	[NFTA_LOOKUP_DREG]	= { .type = NLA_U32 },
diff --git a/net/netfilter/nft_objref.c b/net/netfilter/nft_objref.c
index 415a65ba2b85..1ae8c49ca4a1 100644
--- a/net/netfilter/nft_objref.c
+++ b/net/netfilter/nft_objref.c
@@ -193,10 +193,12 @@ nft_objref_select_ops(const struct nft_ctx *ctx,
 }
 
 static const struct nla_policy nft_objref_policy[NFTA_OBJREF_MAX + 1] = {
-	[NFTA_OBJREF_IMM_NAME]	= { .type = NLA_STRING },
+	[NFTA_OBJREF_IMM_NAME]	= { .type = NLA_STRING,
+				    .len = NFT_OBJ_MAXNAMELEN - 1 },
 	[NFTA_OBJREF_IMM_TYPE]	= { .type = NLA_U32 },
 	[NFTA_OBJREF_SET_SREG]	= { .type = NLA_U32 },
-	[NFTA_OBJREF_SET_NAME]	= { .type = NLA_STRING },
+	[NFTA_OBJREF_SET_NAME]	= { .type = NLA_STRING,
+				    .len = NFT_SET_MAXNAMELEN - 1 },
 	[NFTA_OBJREF_SET_ID]	= { .type = NLA_U32 },
 };
 
-- 
2.1.4


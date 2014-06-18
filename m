From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/13] netfilter: nf_tables: use u32 for chain use counter
Date: Wed, 18 Jun 2014 11:44:31 +0200
Message-ID: <1403084679-11227-6-git-send-email-pablo@netfilter.org>
References: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since 4fefee5 ("netfilter: nf_tables: allow to delete several objects
from a batch"), every new rule bumps the chain use counter. However,
this is limited to 16 bits, which means that it will overrun after
2^16 rules.

Use a u32 chain counter and check for overflows (just like we do for
table objects).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    6 +++---
 net/netfilter/nf_tables_api.c     |    3 +++
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 7ee6ce6..713b0b8 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -503,9 +503,9 @@ enum nft_chain_flags {
  *	@net: net namespace that this chain belongs to
  *	@table: table that this chain belongs to
  *	@handle: chain handle
- *	@flags: bitmask of enum nft_chain_flags
  *	@use: number of jump references to this chain
  *	@level: length of longest path to this chain
+ *	@flags: bitmask of enum nft_chain_flags
  *	@name: name of the chain
  */
 struct nft_chain {
@@ -514,9 +514,9 @@ struct nft_chain {
 	struct net			*net;
 	struct nft_table		*table;
 	u64				handle;
-	u8				flags;
-	u16				use;
+	u32				use;
 	u16				level;
+	u8				flags;
 	char				name[NFT_CHAIN_MAXNAMELEN];
 };
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index ba37c10..5586426 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1730,6 +1730,9 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 		if (!create || nlh->nlmsg_flags & NLM_F_REPLACE)
 			return -EINVAL;
 		handle = nf_tables_alloc_handle(table);
+
+		if (chain->use == UINT_MAX)
+			return -EOVERFLOW;
 	}
 
 	if (nla[NFTA_RULE_POSITION]) {
-- 
1.7.10.4


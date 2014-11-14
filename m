From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/8] netfilter: nft_compat: relax chain type validation
Date: Fri, 14 Nov 2014 17:58:46 +0100
Message-ID: <1415984329-5569-7-git-send-email-pablo@netfilter.org>
References: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check for nat chain dependency only, which is the one that can
actually crash the kernel. Don't care if mangle, filter and security
specific match and targets are used out of their scope, they are
harmless.

This restores iptables-compat with mangle specific match/target when
used out of the OUTPUT chain, that are actually emulated through filter
chains, which broke when performing strict validation.

Fixes: f3f5dde ("netfilter: nft_compat: validate chain type in match/target")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |   32 ++------------------------------
 1 file changed, 2 insertions(+), 30 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index b92f129..70dc965 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -21,45 +21,17 @@
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/netfilter/nf_tables.h>
 
-static const struct {
-       const char	*name;
-       u8		type;
-} table_to_chaintype[] = {
-       { "filter",     NFT_CHAIN_T_DEFAULT },
-       { "raw",        NFT_CHAIN_T_DEFAULT },
-       { "security",   NFT_CHAIN_T_DEFAULT },
-       { "mangle",     NFT_CHAIN_T_ROUTE },
-       { "nat",        NFT_CHAIN_T_NAT },
-       { },
-};
-
-static int nft_compat_table_to_chaintype(const char *table)
-{
-	int i;
-
-	for (i = 0; table_to_chaintype[i].name != NULL; i++) {
-		if (strcmp(table_to_chaintype[i].name, table) == 0)
-			return table_to_chaintype[i].type;
-	}
-
-	return -1;
-}
-
 static int nft_compat_chain_validate_dependency(const char *tablename,
 						const struct nft_chain *chain)
 {
-	enum nft_chain_type type;
 	const struct nft_base_chain *basechain;
 
 	if (!tablename || !(chain->flags & NFT_BASE_CHAIN))
 		return 0;
 
-	type = nft_compat_table_to_chaintype(tablename);
-	if (type < 0)
-		return -EINVAL;
-
 	basechain = nft_base_chain(chain);
-	if (basechain->type->type != type)
+	if (strcmp(tablename, "nat") == 0 &&
+	    basechain->type->type != NFT_CHAIN_T_NAT)
 		return -EINVAL;
 
 	return 0;
-- 
1.7.10.4


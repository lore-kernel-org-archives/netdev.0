From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/23] netfilter: nf_tables: replay request after dropping locks to load chain type
Date: Fri, 10 Jan 2014 01:35:35 +0100
Message-ID: <1389314142-17969-17-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51564 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756162AbaAJAgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:13 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

To avoid races, we need to replay to request after dropping the nfnl_mutex
to auto-load the chain type module.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index d913fb0..7d6a226 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -147,16 +147,20 @@ nf_tables_chain_type_lookup(const struct nft_af_info *afi,
 	struct nf_chain_type *type;
 
 	type = __nf_tables_chain_type_lookup(afi->family, nla);
+	if (type != NULL)
+		return type;
 #ifdef CONFIG_MODULES
-	if (type == NULL && autoload) {
+	if (autoload) {
 		nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 		request_module("nft-chain-%u-%*.s", afi->family,
 			       nla_len(nla)-1, (const char *)nla_data(nla));
 		nfnl_lock(NFNL_SUBSYS_NFTABLES);
 		type = __nf_tables_chain_type_lookup(afi->family, nla);
+		if (type != NULL)
+			return ERR_PTR(-EAGAIN);
 	}
 #endif
-	return type;
+	return ERR_PTR(-ENOENT);
 }
 
 static const struct nla_policy nft_table_policy[NFTA_TABLE_MAX + 1] = {
@@ -906,8 +910,8 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 			type = nf_tables_chain_type_lookup(afi,
 							   nla[NFTA_CHAIN_TYPE],
 							   create);
-			if (type == NULL)
-				return -ENOENT;
+			if (IS_ERR(type))
+				return PTR_ERR(type);
 		}
 
 		err = nla_parse_nested(ha, NFTA_HOOK_MAX, nla[NFTA_CHAIN_HOOK],
-- 
1.7.10.4

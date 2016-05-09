From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/36] netfilter: nf_tables: introduce nft_setelem_parse_flags() helper
Date: Mon,  9 May 2016 20:46:25 +0200
Message-ID: <1462819614-5402-8-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45683 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961AbcEISrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:10 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 4216BE8E8E
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:09 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 33EF3134714
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:09 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 309F913470B
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:07 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function parses the set element flags, thus, we can reuse the same
handling when deleting elements.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 7a85a9d..1b3210b 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3375,6 +3375,22 @@ void nft_set_elem_destroy(const struct nft_set *set, void *elem)
 }
 EXPORT_SYMBOL_GPL(nft_set_elem_destroy);
 
+static int nft_setelem_parse_flags(const struct nft_set *set,
+				   const struct nlattr *attr, u32 *flags)
+{
+	if (attr == NULL)
+		return 0;
+
+	*flags = ntohl(nla_get_be32(attr));
+	if (*flags & ~NFT_SET_ELEM_INTERVAL_END)
+		return -EINVAL;
+	if (!(set->flags & NFT_SET_INTERVAL) &&
+	    *flags & NFT_SET_ELEM_INTERVAL_END)
+		return -EINVAL;
+
+	return 0;
+}
+
 static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 			    const struct nlattr *attr)
 {
@@ -3388,8 +3404,8 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	struct nft_data data;
 	enum nft_registers dreg;
 	struct nft_trans *trans;
+	u32 flags = 0;
 	u64 timeout;
-	u32 flags;
 	u8 ulen;
 	int err;
 
@@ -3403,17 +3419,11 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 
 	nft_set_ext_prepare(&tmpl);
 
-	flags = 0;
-	if (nla[NFTA_SET_ELEM_FLAGS] != NULL) {
-		flags = ntohl(nla_get_be32(nla[NFTA_SET_ELEM_FLAGS]));
-		if (flags & ~NFT_SET_ELEM_INTERVAL_END)
-			return -EINVAL;
-		if (!(set->flags & NFT_SET_INTERVAL) &&
-		    flags & NFT_SET_ELEM_INTERVAL_END)
-			return -EINVAL;
-		if (flags != 0)
-			nft_set_ext_add(&tmpl, NFT_SET_EXT_FLAGS);
-	}
+	err = nft_setelem_parse_flags(set, nla[NFTA_SET_ELEM_FLAGS], &flags);
+	if (err < 0)
+		return err;
+	if (flags != 0)
+		nft_set_ext_add(&tmpl, NFT_SET_EXT_FLAGS);
 
 	if (set->flags & NFT_SET_MAP) {
 		if (nla[NFTA_SET_ELEM_DATA] == NULL &&
-- 
2.1.4

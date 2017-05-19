From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/12] netfilter: nf_tables: missing sanitization in data from userspace
Date: Fri, 19 May 2017 10:33:50 +0200
Message-ID: <1495182833-2272-10-git-send-email-pablo@netfilter.org>
References: <1495182833-2272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44050 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755717AbdESIei (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 04:34:38 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 5B36B1DA0A7
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3994CFF2E1
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DDB4C10078A
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:13 +0200 (CEST)
In-Reply-To: <1495182833-2272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not assume userspace always sends us NFT_DATA_VALUE for bitwise and
cmp expressions. Although NFT_DATA_VERDICT does not make any sense, it
is still possible to handcraft a netlink message using this incorrect
data type.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_bitwise.c | 19 ++++++++++++++-----
 net/netfilter/nft_cmp.c     | 12 ++++++++++--
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nft_bitwise.c b/net/netfilter/nft_bitwise.c
index 877d9acd91ef..96bd4f325b0f 100644
--- a/net/netfilter/nft_bitwise.c
+++ b/net/netfilter/nft_bitwise.c
@@ -83,17 +83,26 @@ static int nft_bitwise_init(const struct nft_ctx *ctx,
 			    tb[NFTA_BITWISE_MASK]);
 	if (err < 0)
 		return err;
-	if (d1.len != priv->len)
-		return -EINVAL;
+	if (d1.len != priv->len) {
+		err = -EINVAL;
+		goto err1;
+	}
 
 	err = nft_data_init(NULL, &priv->xor, sizeof(priv->xor), &d2,
 			    tb[NFTA_BITWISE_XOR]);
 	if (err < 0)
-		return err;
-	if (d2.len != priv->len)
-		return -EINVAL;
+		goto err1;
+	if (d2.len != priv->len) {
+		err = -EINVAL;
+		goto err2;
+	}
 
 	return 0;
+err2:
+	nft_data_uninit(&priv->xor, d2.type);
+err1:
+	nft_data_uninit(&priv->mask, d1.type);
+	return err;
 }
 
 static int nft_bitwise_dump(struct sk_buff *skb, const struct nft_expr *expr)
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 2b96effeadc1..8c9d0fb19118 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -201,10 +201,18 @@ nft_cmp_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 	if (err < 0)
 		return ERR_PTR(err);
 
+	if (desc.type != NFT_DATA_VALUE) {
+		err = -EINVAL;
+		goto err1;
+	}
+
 	if (desc.len <= sizeof(u32) && op == NFT_CMP_EQ)
 		return &nft_cmp_fast_ops;
-	else
-		return &nft_cmp_ops;
+
+	return &nft_cmp_ops;
+err1:
+	nft_data_uninit(&data, desc.type);
+	return ERR_PTR(-EINVAL);
 }
 
 struct nft_expr_type nft_cmp_type __read_mostly = {
-- 
2.1.4

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/22] netfilter: nft_exthdr: Allow checking TCP option presence, too
Date: Mon, 20 Mar 2017 11:08:29 +0100
Message-ID: <1490004530-9128-2-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51724 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753969AbdCTKJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:28 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 3D8D4523E5
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2C3FEDA7F7
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EC574DA87B
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:08:58 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>

Honor NFT_EXTHDR_F_PRESENT flag so we check if the TCP option is
present.

Signed-off-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_exthdr.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index c308920b194c..d212a85d2f33 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -98,14 +98,21 @@ static void nft_exthdr_tcp_eval(const struct nft_expr *expr,
 			goto err;
 
 		offset = i + priv->offset;
-		dest[priv->len / NFT_REG32_SIZE] = 0;
-		memcpy(dest, opt + offset, priv->len);
+		if (priv->flags & NFT_EXTHDR_F_PRESENT) {
+			*dest = 1;
+		} else {
+			dest[priv->len / NFT_REG32_SIZE] = 0;
+			memcpy(dest, opt + offset, priv->len);
+		}
 
 		return;
 	}
 
 err:
-	regs->verdict.code = NFT_BREAK;
+	if (priv->flags & NFT_EXTHDR_F_PRESENT)
+		*dest = 0;
+	else
+		regs->verdict.code = NFT_BREAK;
 }
 
 static const struct nla_policy nft_exthdr_policy[NFTA_EXTHDR_MAX + 1] = {
-- 
2.1.4

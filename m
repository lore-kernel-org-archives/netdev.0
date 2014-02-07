From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/18] netfilter: nft_ct: fix unconditional dump of 'dir' attr
Date: Fri,  7 Feb 2014 18:41:28 +0100
Message-ID: <1391794904-4017-3-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

We want to make sure that the information that we get from the kernel can
be reinjected without troubles. The kernel shouldn't return an attribute
that is not required, or even prohibited.

Dumping unconditionally NFTA_CT_DIRECTION could lead an application in
userspace to interpret that the attribute was originally set, while it
was not.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 917052e..feaf0f3 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -311,8 +311,19 @@ static int nft_ct_get_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 	if (nla_put_be32(skb, NFTA_CT_KEY, htonl(priv->key)))
 		goto nla_put_failure;
-	if (nla_put_u8(skb, NFTA_CT_DIRECTION, priv->dir))
-		goto nla_put_failure;
+
+	switch (priv->key) {
+	case NFT_CT_PROTOCOL:
+	case NFT_CT_SRC:
+	case NFT_CT_DST:
+	case NFT_CT_PROTO_SRC:
+	case NFT_CT_PROTO_DST:
+		if (nla_put_u8(skb, NFTA_CT_DIRECTION, priv->dir))
+			goto nla_put_failure;
+	default:
+		break;
+	}
+
 	return 0;
 
 nla_put_failure:
-- 
1.7.10.4


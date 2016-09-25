From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 45/53] netfilter: nft_ct: unnecessary to require dir when use ct l3proto/protocol
Date: Mon, 26 Sep 2016 01:06:55 +0200
Message-ID: <1474844823-2026-46-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

Currently, if the user want to match ct l3proto, we must specify the
direction, for example:
  # nft add rule filter input ct original l3proto ipv4
                                 ^^^^^^^^
Otherwise, error message will be reported:
  # nft add rule filter input ct l3proto ipv4
  nft add rule filter input ct l3proto ipv4
  <cmdline>:1:1-38: Error: Could not process rule: Invalid argument
  add rule filter input ct l3proto ipv4
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Actually, there's no need to require NFTA_CT_DIRECTION attr, because
ct l3proto and protocol are unrelated to direction.

And for compatibility, even if the user specify the NFTA_CT_DIRECTION
attr, do not report error, just skip it.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 51e180f2a003..825fbbc62f48 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -128,15 +128,18 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 		memcpy(dest, &count, sizeof(count));
 		return;
 	}
+	case NFT_CT_L3PROTOCOL:
+		*dest = nf_ct_l3num(ct);
+		return;
+	case NFT_CT_PROTOCOL:
+		*dest = nf_ct_protonum(ct);
+		return;
 	default:
 		break;
 	}
 
 	tuple = &ct->tuplehash[priv->dir].tuple;
 	switch (priv->key) {
-	case NFT_CT_L3PROTOCOL:
-		*dest = nf_ct_l3num(ct);
-		return;
 	case NFT_CT_SRC:
 		memcpy(dest, tuple->src.u3.all,
 		       nf_ct_l3num(ct) == NFPROTO_IPV4 ? 4 : 16);
@@ -145,9 +148,6 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 		memcpy(dest, tuple->dst.u3.all,
 		       nf_ct_l3num(ct) == NFPROTO_IPV4 ? 4 : 16);
 		return;
-	case NFT_CT_PROTOCOL:
-		*dest = nf_ct_protonum(ct);
-		return;
 	case NFT_CT_PROTO_SRC:
 		*dest = (__force __u16)tuple->src.u.all;
 		return;
@@ -283,8 +283,9 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 
 	case NFT_CT_L3PROTOCOL:
 	case NFT_CT_PROTOCOL:
-		if (tb[NFTA_CT_DIRECTION] == NULL)
-			return -EINVAL;
+		/* For compatibility, do not report error if NFTA_CT_DIRECTION
+		 * attribute is specified.
+		 */
 		len = sizeof(u8);
 		break;
 	case NFT_CT_SRC:
@@ -432,8 +433,6 @@ static int nft_ct_get_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 
 	switch (priv->key) {
-	case NFT_CT_L3PROTOCOL:
-	case NFT_CT_PROTOCOL:
 	case NFT_CT_SRC:
 	case NFT_CT_DST:
 	case NFT_CT_PROTO_SRC:
-- 
2.1.4


From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: nft_reject_bridge: restrict reject to prerouting and input
Date: Fri, 31 Oct 2014 13:18:32 +0100
Message-ID: <1414757912-29150-7-git-send-email-pablo@netfilter.org>
References: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Restrict the reject expression to the prerouting and input bridge
hooks. If we allow this to be used from forward or any other later
bridge hook, if the frame is flooded to several ports, we'll end up
sending several reject packets, one per cloned packet.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nft_reject_bridge.c |   33 +++++++++++++++++++++++++++++-
 1 file changed, 32 insertions(+), 1 deletion(-)

diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 31b27e1..654c901 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -18,6 +18,7 @@
 #include <net/netfilter/ipv6/nf_reject.h>
 #include <linux/ip.h>
 #include <net/ip.h>
+#include <linux/netfilter_bridge.h>
 #include "../br_private.h"
 
 static void nft_reject_br_push_etherhdr(struct sk_buff *oldskb,
@@ -305,12 +306,34 @@ out:
 	data[NFT_REG_VERDICT].verdict = NF_DROP;
 }
 
+static int nft_reject_bridge_validate_hooks(const struct nft_chain *chain)
+{
+	struct nft_base_chain *basechain;
+
+	if (chain->flags & NFT_BASE_CHAIN) {
+		basechain = nft_base_chain(chain);
+
+		switch (basechain->ops[0].hooknum) {
+		case NF_BR_PRE_ROUTING:
+		case NF_BR_LOCAL_IN:
+			break;
+		default:
+			return -EOPNOTSUPP;
+		}
+	}
+	return 0;
+}
+
 static int nft_reject_bridge_init(const struct nft_ctx *ctx,
 				  const struct nft_expr *expr,
 				  const struct nlattr * const tb[])
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
-	int icmp_code;
+	int icmp_code, err;
+
+	err = nft_reject_bridge_validate_hooks(ctx->chain);
+	if (err < 0)
+		return err;
 
 	if (tb[NFTA_REJECT_TYPE] == NULL)
 		return -EINVAL;
@@ -359,6 +382,13 @@ nla_put_failure:
 	return -1;
 }
 
+static int nft_reject_bridge_validate(const struct nft_ctx *ctx,
+				      const struct nft_expr *expr,
+				      const struct nft_data **data)
+{
+	return nft_reject_bridge_validate_hooks(ctx->chain);
+}
+
 static struct nft_expr_type nft_reject_bridge_type;
 static const struct nft_expr_ops nft_reject_bridge_ops = {
 	.type		= &nft_reject_bridge_type,
@@ -366,6 +396,7 @@ static const struct nft_expr_ops nft_reject_bridge_ops = {
 	.eval		= nft_reject_bridge_eval,
 	.init		= nft_reject_bridge_init,
 	.dump		= nft_reject_bridge_dump,
+	.validate	= nft_reject_bridge_validate,
 };
 
 static struct nft_expr_type nft_reject_bridge_type __read_mostly = {
-- 
1.7.10.4


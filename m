From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/18] netfilter: nf_tables: fix log/queue expressions for NFPROTO_INET
Date: Fri,  7 Feb 2014 18:41:39 +0100
Message-ID: <1391794904-4017-14-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41455 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753091AbaBGRmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 12:42:13 -0500
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The log and queue expressions both store the family during ->init() and
use it to deliver packets. This is wrong when used in NFPROTO_INET since
they should both deliver to the actual AF of the packet, not the dummy
NFPROTO_INET.

Use the family from the hook ops to fix this.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_log.c   |    5 +----
 net/netfilter/nft_queue.c |    4 +---
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index 5af7901..26c5154 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -23,7 +23,6 @@ static const char *nft_log_null_prefix = "";
 struct nft_log {
 	struct nf_loginfo	loginfo;
 	char			*prefix;
-	int			family;
 };
 
 static void nft_log_eval(const struct nft_expr *expr,
@@ -33,7 +32,7 @@ static void nft_log_eval(const struct nft_expr *expr,
 	const struct nft_log *priv = nft_expr_priv(expr);
 	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 
-	nf_log_packet(net, priv->family, pkt->ops->hooknum, pkt->skb, pkt->in,
+	nf_log_packet(net, pkt->ops->pf, pkt->ops->hooknum, pkt->skb, pkt->in,
 		      pkt->out, &priv->loginfo, "%s", priv->prefix);
 }
 
@@ -52,8 +51,6 @@ static int nft_log_init(const struct nft_ctx *ctx,
 	struct nf_loginfo *li = &priv->loginfo;
 	const struct nlattr *nla;
 
-	priv->family = ctx->afi->family;
-
 	nla = tb[NFTA_LOG_PREFIX];
 	if (nla != NULL) {
 		priv->prefix = kmalloc(nla_len(nla) + 1, GFP_KERNEL);
diff --git a/net/netfilter/nft_queue.c b/net/netfilter/nft_queue.c
index cbea473..e8ae2f6 100644
--- a/net/netfilter/nft_queue.c
+++ b/net/netfilter/nft_queue.c
@@ -25,7 +25,6 @@ struct nft_queue {
 	u16	queuenum;
 	u16	queues_total;
 	u16	flags;
-	u8	family;
 };
 
 static void nft_queue_eval(const struct nft_expr *expr,
@@ -43,7 +42,7 @@ static void nft_queue_eval(const struct nft_expr *expr,
 			queue = priv->queuenum + cpu % priv->queues_total;
 		} else {
 			queue = nfqueue_hash(pkt->skb, queue,
-					     priv->queues_total, priv->family,
+					     priv->queues_total, pkt->ops->pf,
 					     jhash_initval);
 		}
 	}
@@ -71,7 +70,6 @@ static int nft_queue_init(const struct nft_ctx *ctx,
 		return -EINVAL;
 
 	init_hashrandom(&jhash_initval);
-	priv->family = ctx->afi->family;
 	priv->queuenum = ntohs(nla_get_be16(tb[NFTA_QUEUE_NUM]));
 
 	if (tb[NFTA_QUEUE_TOTAL] != NULL)
-- 
1.7.10.4

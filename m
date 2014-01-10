From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/23] netfilter: nf_tables: add hook ops to struct nft_pktinfo
Date: Fri, 10 Jan 2014 01:35:22 +0100
Message-ID: <1389314142-17969-4-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51510 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756871AbaAJAgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:03 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Multi-family tables need the AF from the hook ops. Add a pointer to the
hook ops and replace usage of the hooknum member in struct nft_pktinfo.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    5 +++--
 net/netfilter/nf_tables_core.c    |    2 +-
 net/netfilter/nft_log.c           |    2 +-
 net/netfilter/nft_reject.c        |    6 +++---
 4 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 5a91abf..c9e6316 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -13,7 +13,7 @@ struct nft_pktinfo {
 	struct sk_buff			*skb;
 	const struct net_device		*in;
 	const struct net_device		*out;
-	u8				hooknum;
+	const struct nf_hook_ops	*ops;
 	u8				nhoff;
 	u8				thoff;
 	/* for x_tables compatibility */
@@ -29,7 +29,8 @@ static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
 	pkt->skb = skb;
 	pkt->in = pkt->xt.in = in;
 	pkt->out = pkt->xt.out = out;
-	pkt->hooknum = pkt->xt.hooknum = ops->hooknum;
+	pkt->ops = ops;
+	pkt->xt.hooknum = ops->hooknum;
 	pkt->xt.family = ops->pf;
 }
 
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index e8fcc34..5aae317 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -109,7 +109,7 @@ static inline void nft_trace_packet(const struct nft_pktinfo *pkt,
 {
 	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 
-	nf_log_packet(net, pkt->xt.family, pkt->hooknum, pkt->skb, pkt->in,
+	nf_log_packet(net, pkt->xt.family, pkt->ops->hooknum, pkt->skb, pkt->in,
 		      pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
 		      chain->table->name, chain->name, comments[type],
 		      rulenum);
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index 57cad07..5af7901 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -33,7 +33,7 @@ static void nft_log_eval(const struct nft_expr *expr,
 	const struct nft_log *priv = nft_expr_priv(expr);
 	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 
-	nf_log_packet(net, priv->family, pkt->hooknum, pkt->skb, pkt->in,
+	nf_log_packet(net, priv->family, pkt->ops->hooknum, pkt->skb, pkt->in,
 		      pkt->out, &priv->loginfo, "%s", priv->prefix);
 }
 
diff --git a/net/netfilter/nft_reject.c b/net/netfilter/nft_reject.c
index 7ae63cd..5e204711 100644
--- a/net/netfilter/nft_reject.c
+++ b/net/netfilter/nft_reject.c
@@ -44,15 +44,15 @@ static void nft_reject_eval(const struct nft_expr *expr,
 #if IS_ENABLED(CONFIG_NF_TABLES_IPV6)
 		else if (priv->family == NFPROTO_IPV6)
 			nf_send_unreach6(net, pkt->skb, priv->icmp_code,
-				      pkt->hooknum);
+				      pkt->ops->hooknum);
 #endif
 		break;
 	case NFT_REJECT_TCP_RST:
 		if (priv->family == NFPROTO_IPV4)
-			nf_send_reset(pkt->skb, pkt->hooknum);
+			nf_send_reset(pkt->skb, pkt->ops->hooknum);
 #if IS_ENABLED(CONFIG_NF_TABLES_IPV6)
 		else if (priv->family == NFPROTO_IPV6)
-			nf_send_reset6(net, pkt->skb, pkt->hooknum);
+			nf_send_reset6(net, pkt->skb, pkt->ops->hooknum);
 #endif
 		break;
 	}
-- 
1.7.10.4

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/23] netfilter: meta: add support for setting skb->pkttype
Date: Fri, 18 Dec 2015 21:26:49 +0100
Message-ID: <1450470409-31427-24-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58150 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932736AbbLRUeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:34:17 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 6CB36102297
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2D5F4DA862
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C4791DA865
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:08 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This allows to redirect bridged packets to local machine:

ether type ip ether daddr set aa:53:08:12:34:56 meta pkttype set unicast
Without 'set unicast', ip stack discards PACKET_OTHERHOST skbs.

It is also useful to add support for a '-m cluster like' nft rule
(where switch floods packets to several nodes, and each cluster node
 node processes a subset of packets for load distribution).

Mangling is restricted to HOST/OTHER/BROAD/MULTICAST, i.e. you cannot set
skb->pkt_type to PACKET_KERNEL or change PACKET_LOOPBACK to PACKET_HOST.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_meta.c | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 5bcd1b0..fe885bf 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -26,6 +26,8 @@
 #include <net/netfilter/nf_tables_core.h>
 #include <net/netfilter/nft_meta.h>
 
+#include <uapi/linux/netfilter_bridge.h> /* NF_BR_PRE_ROUTING */
+
 void nft_meta_get_eval(const struct nft_expr *expr,
 		       struct nft_regs *regs,
 		       const struct nft_pktinfo *pkt)
@@ -190,6 +192,13 @@ err:
 }
 EXPORT_SYMBOL_GPL(nft_meta_get_eval);
 
+/* don't change or set _LOOPBACK, _USER, etc. */
+static bool pkt_type_ok(u32 p)
+{
+	return p == PACKET_HOST || p == PACKET_BROADCAST ||
+	       p == PACKET_MULTICAST || p == PACKET_OTHERHOST;
+}
+
 void nft_meta_set_eval(const struct nft_expr *expr,
 		       struct nft_regs *regs,
 		       const struct nft_pktinfo *pkt)
@@ -205,6 +214,11 @@ void nft_meta_set_eval(const struct nft_expr *expr,
 	case NFT_META_PRIORITY:
 		skb->priority = value;
 		break;
+	case NFT_META_PKTTYPE:
+		if (skb->pkt_type != value &&
+		    pkt_type_ok(value) && pkt_type_ok(skb->pkt_type))
+			skb->pkt_type = value;
+		break;
 	case NFT_META_NFTRACE:
 		skb->nf_trace = 1;
 		break;
@@ -273,6 +287,24 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 }
 EXPORT_SYMBOL_GPL(nft_meta_get_init);
 
+static int nft_meta_set_init_pkttype(const struct nft_ctx *ctx)
+{
+	unsigned int hooks;
+
+	switch (ctx->afi->family) {
+	case NFPROTO_BRIDGE:
+		hooks = 1 << NF_BR_PRE_ROUTING;
+		break;
+	case NFPROTO_NETDEV:
+		hooks = 1 << NF_NETDEV_INGRESS;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return nft_chain_validate_hooks(ctx->chain, hooks);
+}
+
 int nft_meta_set_init(const struct nft_ctx *ctx,
 		      const struct nft_expr *expr,
 		      const struct nlattr * const tb[])
@@ -290,6 +322,12 @@ int nft_meta_set_init(const struct nft_ctx *ctx,
 	case NFT_META_NFTRACE:
 		len = sizeof(u8);
 		break;
+	case NFT_META_PKTTYPE:
+		err = nft_meta_set_init_pkttype(ctx);
+		if (err)
+			return err;
+		len = sizeof(u8);
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.1.4

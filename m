From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/53] netfilter: nf_tables: ensure proper initialization of nft_pktinfo fields
Date: Mon, 26 Sep 2016 01:06:25 +0200
Message-ID: <1474844823-2026-16-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54574 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034427AbcIYXHg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:36 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D7CDEC0B43
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:34 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C47C7DA849
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:34 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8C096DA816
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:32 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces nft_set_pktinfo_unspec() that ensures proper
initialization all of pktinfo fields for non-IP traffic. This is used
by the bridge, netdev and arp families.

This new function relies on nft_set_pktinfo_proto_unspec() to set a new
tprot_set field that indicates if transport protocol information is
available. Remain fields are zeroed.

The meta expression has been also updated to check to tprot_set in first
place given that zero is a valid tprot value. Even a handcrafted packet
may come with the IPPROTO_RAW (255) protocol number so we can't rely on
this value as tprot unset.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h       | 18 ++++++++++++++++++
 include/net/netfilter/nf_tables_ipv4.h  |  1 +
 include/net/netfilter/nf_tables_ipv6.h  |  1 +
 net/bridge/netfilter/nf_tables_bridge.c |  6 +++---
 net/ipv4/netfilter/nf_tables_arp.c      |  2 +-
 net/netfilter/nf_tables_netdev.c        |  4 +++-
 net/netfilter/nft_meta.c                |  2 ++
 7 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 8972468bc94b..a7a7cebc8d07 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -19,6 +19,7 @@ struct nft_pktinfo {
 	const struct net_device		*out;
 	u8				pf;
 	u8				hook;
+	bool				tprot_set;
 	u8				tprot;
 	/* for x_tables compatibility */
 	struct xt_action_param		xt;
@@ -36,6 +37,23 @@ static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
 	pkt->pf = pkt->xt.family = state->pf;
 }
 
+static inline void nft_set_pktinfo_proto_unspec(struct nft_pktinfo *pkt,
+						struct sk_buff *skb)
+{
+	pkt->tprot_set = false;
+	pkt->tprot = 0;
+	pkt->xt.thoff = 0;
+	pkt->xt.fragoff = 0;
+}
+
+static inline void nft_set_pktinfo_unspec(struct nft_pktinfo *pkt,
+					  struct sk_buff *skb,
+					  const struct nf_hook_state *state)
+{
+	nft_set_pktinfo(pkt, skb, state);
+	nft_set_pktinfo_proto_unspec(pkt, skb);
+}
+
 /**
  * 	struct nft_verdict - nf_tables verdict
  *
diff --git a/include/net/netfilter/nf_tables_ipv4.h b/include/net/netfilter/nf_tables_ipv4.h
index ca6ef6bf775e..af952f7843ee 100644
--- a/include/net/netfilter/nf_tables_ipv4.h
+++ b/include/net/netfilter/nf_tables_ipv4.h
@@ -14,6 +14,7 @@ nft_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
 	nft_set_pktinfo(pkt, skb, state);
 
 	ip = ip_hdr(pkt->skb);
+	pkt->tprot_set = true;
 	pkt->tprot = ip->protocol;
 	pkt->xt.thoff = ip_hdrlen(pkt->skb);
 	pkt->xt.fragoff = ntohs(ip->frag_off) & IP_OFFSET;
diff --git a/include/net/netfilter/nf_tables_ipv6.h b/include/net/netfilter/nf_tables_ipv6.h
index 8ad39a6a5fe1..6aeee47b1b5e 100644
--- a/include/net/netfilter/nf_tables_ipv6.h
+++ b/include/net/netfilter/nf_tables_ipv6.h
@@ -19,6 +19,7 @@ nft_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 	if (protohdr < 0)
 		return -1;
 
+	pkt->tprot_set = true;
 	pkt->tprot = protohdr;
 	pkt->xt.thoff = thoff;
 	pkt->xt.fragoff = frag_off;
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index a78c4e2826e5..29899887163e 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -71,7 +71,7 @@ static inline void nft_bridge_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
 	if (nft_bridge_iphdr_validate(skb))
 		nft_set_pktinfo_ipv4(pkt, skb, state);
 	else
-		nft_set_pktinfo(pkt, skb, state);
+		nft_set_pktinfo_unspec(pkt, skb, state);
 }
 
 static inline void nft_bridge_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
@@ -83,7 +83,7 @@ static inline void nft_bridge_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 	    nft_set_pktinfo_ipv6(pkt, skb, state) == 0)
 		return;
 #endif
-	nft_set_pktinfo(pkt, skb, state);
+	nft_set_pktinfo_unspec(pkt, skb, state);
 }
 
 static unsigned int
@@ -101,7 +101,7 @@ nft_do_chain_bridge(void *priv,
 		nft_bridge_set_pktinfo_ipv6(&pkt, skb, state);
 		break;
 	default:
-		nft_set_pktinfo(&pkt, skb, state);
+		nft_set_pktinfo_unspec(&pkt, skb, state);
 		break;
 	}
 
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index cd84d4295a20..058c034be376 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -21,7 +21,7 @@ nft_do_chain_arp(void *priv,
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo(&pkt, skb, state);
+	nft_set_pktinfo_unspec(&pkt, skb, state);
 
 	return nft_do_chain(&pkt, priv);
 }
diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index 5eefe4a355c6..8de502b0c37b 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -41,6 +41,7 @@ nft_netdev_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
 	else if (len < thoff)
 		return;
 
+	pkt->tprot_set = true;
 	pkt->tprot = iph->protocol;
 	pkt->xt.thoff = thoff;
 	pkt->xt.fragoff = ntohs(iph->frag_off) & IP_OFFSET;
@@ -74,6 +75,7 @@ __nft_netdev_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 	if (protohdr < 0)
                 return;
 
+	pkt->tprot_set = true;
 	pkt->tprot = protohdr;
 	pkt->xt.thoff = thoff;
 	pkt->xt.fragoff = frag_off;
@@ -102,7 +104,7 @@ nft_do_chain_netdev(void *priv, struct sk_buff *skb,
 		nft_netdev_set_pktinfo_ipv6(&pkt, skb, state);
 		break;
 	default:
-		nft_set_pktinfo(&pkt, skb, state);
+		nft_set_pktinfo_unspec(&pkt, skb, state);
 		break;
 	}
 
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 2863f3493038..14264edf2d77 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -52,6 +52,8 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		*dest = pkt->pf;
 		break;
 	case NFT_META_L4PROTO:
+		if (!pkt->tprot_set)
+			goto err;
 		*dest = pkt->tprot;
 		break;
 	case NFT_META_PRIORITY:
-- 
2.1.4

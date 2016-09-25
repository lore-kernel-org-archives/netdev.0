From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/53] netfilter: nf_tables_bridge: use nft_set_pktinfo_ipv{4, 6}_validate
Date: Mon, 26 Sep 2016 01:06:28 +0200
Message-ID: <1474844823-2026-19-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54542 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034635AbcIYXHj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:39 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BD6C5C0B3D
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:37 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A38A3DA81F
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:37 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7CB41DA847
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:35 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate pktinfo setup and validation by using the new generic
functions so we converge to the netdev family codebase.

We only need a linear IPv4 and IPv6 header from the reject expression,
so move nft_bridge_iphdr_validate() and nft_bridge_ip6hdr_validate()
to net/bridge/netfilter/nft_reject_bridge.c.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_bridge.h |  7 ----
 net/bridge/netfilter/nf_tables_bridge.c  | 72 +-------------------------------
 net/bridge/netfilter/nft_reject_bridge.c | 44 ++++++++++++++++++-
 3 files changed, 45 insertions(+), 78 deletions(-)
 delete mode 100644 include/net/netfilter/nf_tables_bridge.h

diff --git a/include/net/netfilter/nf_tables_bridge.h b/include/net/netfilter/nf_tables_bridge.h
deleted file mode 100644
index 511fb79f6dad..000000000000
--- a/include/net/netfilter/nf_tables_bridge.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _NET_NF_TABLES_BRIDGE_H
-#define _NET_NF_TABLES_BRIDGE_H
-
-int nft_bridge_iphdr_validate(struct sk_buff *skb);
-int nft_bridge_ip6hdr_validate(struct sk_buff *skb);
-
-#endif /* _NET_NF_TABLES_BRIDGE_H */
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 29899887163e..06f0f81456a0 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -13,79 +13,11 @@
 #include <linux/module.h>
 #include <linux/netfilter_bridge.h>
 #include <net/netfilter/nf_tables.h>
-#include <net/netfilter/nf_tables_bridge.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <net/netfilter/nf_tables_ipv4.h>
 #include <net/netfilter/nf_tables_ipv6.h>
 
-int nft_bridge_iphdr_validate(struct sk_buff *skb)
-{
-	struct iphdr *iph;
-	u32 len;
-
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-		return 0;
-
-	iph = ip_hdr(skb);
-	if (iph->ihl < 5 || iph->version != 4)
-		return 0;
-
-	len = ntohs(iph->tot_len);
-	if (skb->len < len)
-		return 0;
-	else if (len < (iph->ihl*4))
-		return 0;
-
-	if (!pskb_may_pull(skb, iph->ihl*4))
-		return 0;
-
-	return 1;
-}
-EXPORT_SYMBOL_GPL(nft_bridge_iphdr_validate);
-
-int nft_bridge_ip6hdr_validate(struct sk_buff *skb)
-{
-	struct ipv6hdr *hdr;
-	u32 pkt_len;
-
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-		return 0;
-
-	hdr = ipv6_hdr(skb);
-	if (hdr->version != 6)
-		return 0;
-
-	pkt_len = ntohs(hdr->payload_len);
-	if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
-		return 0;
-
-	return 1;
-}
-EXPORT_SYMBOL_GPL(nft_bridge_ip6hdr_validate);
-
-static inline void nft_bridge_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
-					       struct sk_buff *skb,
-					       const struct nf_hook_state *state)
-{
-	if (nft_bridge_iphdr_validate(skb))
-		nft_set_pktinfo_ipv4(pkt, skb, state);
-	else
-		nft_set_pktinfo_unspec(pkt, skb, state);
-}
-
-static inline void nft_bridge_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
-					       struct sk_buff *skb,
-					       const struct nf_hook_state *state)
-{
-#if IS_ENABLED(CONFIG_IPV6)
-	if (nft_bridge_ip6hdr_validate(skb) &&
-	    nft_set_pktinfo_ipv6(pkt, skb, state) == 0)
-		return;
-#endif
-	nft_set_pktinfo_unspec(pkt, skb, state);
-}
-
 static unsigned int
 nft_do_chain_bridge(void *priv,
 		    struct sk_buff *skb,
@@ -95,10 +27,10 @@ nft_do_chain_bridge(void *priv,
 
 	switch (eth_hdr(skb)->h_proto) {
 	case htons(ETH_P_IP):
-		nft_bridge_set_pktinfo_ipv4(&pkt, skb, state);
+		nft_set_pktinfo_ipv4_validate(&pkt, skb, state);
 		break;
 	case htons(ETH_P_IPV6):
-		nft_bridge_set_pktinfo_ipv6(&pkt, skb, state);
+		nft_set_pktinfo_ipv6_validate(&pkt, skb, state);
 		break;
 	default:
 		nft_set_pktinfo_unspec(&pkt, skb, state);
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 0b77ffbc27d6..4b3df6b0e3b9 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -14,7 +14,6 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
 #include <net/netfilter/nft_reject.h>
-#include <net/netfilter/nf_tables_bridge.h>
 #include <net/netfilter/ipv4/nf_reject.h>
 #include <net/netfilter/ipv6/nf_reject.h>
 #include <linux/ip.h>
@@ -37,6 +36,30 @@ static void nft_reject_br_push_etherhdr(struct sk_buff *oldskb,
 	skb_pull(nskb, ETH_HLEN);
 }
 
+static int nft_bridge_iphdr_validate(struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	u32 len;
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		return 0;
+
+	iph = ip_hdr(skb);
+	if (iph->ihl < 5 || iph->version != 4)
+		return 0;
+
+	len = ntohs(iph->tot_len);
+	if (skb->len < len)
+		return 0;
+	else if (len < (iph->ihl*4))
+		return 0;
+
+	if (!pskb_may_pull(skb, iph->ihl*4))
+		return 0;
+
+	return 1;
+}
+
 /* We cannot use oldskb->dev, it can be either bridge device (NF_BRIDGE INPUT)
  * or the bridge port (NF_BRIDGE PREROUTING).
  */
@@ -143,6 +166,25 @@ static void nft_reject_br_send_v4_unreach(struct net *net,
 	br_forward(br_port_get_rcu(dev), nskb, false, true);
 }
 
+static int nft_bridge_ip6hdr_validate(struct sk_buff *skb)
+{
+	struct ipv6hdr *hdr;
+	u32 pkt_len;
+
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+		return 0;
+
+	hdr = ipv6_hdr(skb);
+	if (hdr->version != 6)
+		return 0;
+
+	pkt_len = ntohs(hdr->payload_len);
+	if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
+		return 0;
+
+	return 1;
+}
+
 static void nft_reject_br_send_v6_tcp_reset(struct net *net,
 					    struct sk_buff *oldskb,
 					    const struct net_device *dev,
-- 
2.1.4

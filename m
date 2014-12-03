From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/12] netfilter: nf_tables_bridge: set the pktinfo for IPv4/IPv6 traffic
Date: Wed,  3 Dec 2014 13:55:34 +0100
Message-ID: <1417611342-25257-5-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48612 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443AbaLCMxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 07:53:32 -0500
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alvaro Neira <alvaroneay@gmail.com>

This patch adds the missing bits to allow to match per meta l4proto from
the bridge. Example:

  nft add rule bridge filter input ether type {ip, ip6} meta l4proto udp counter

Signed-off-by: Alvaro Neira Ayuso <alvaroneay@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nf_tables_bridge.c |   40 ++++++++++++++++++++++++++++++-
 1 file changed, 39 insertions(+), 1 deletion(-)

diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index d468c19..19473a9 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -16,6 +16,8 @@
 #include <net/netfilter/nf_tables_bridge.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <net/netfilter/nf_tables_ipv4.h>
+#include <net/netfilter/nf_tables_ipv6.h>
 
 int nft_bridge_iphdr_validate(struct sk_buff *skb)
 {
@@ -62,6 +64,32 @@ int nft_bridge_ip6hdr_validate(struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(nft_bridge_ip6hdr_validate);
 
+static inline void nft_bridge_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
+					       const struct nf_hook_ops *ops,
+					       struct sk_buff *skb,
+					       const struct net_device *in,
+					       const struct net_device *out)
+{
+	if (nft_bridge_iphdr_validate(skb))
+		nft_set_pktinfo_ipv4(pkt, ops, skb, in, out);
+	else
+		nft_set_pktinfo(pkt, ops, skb, in, out);
+}
+
+static inline void nft_bridge_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
+					      const struct nf_hook_ops *ops,
+					      struct sk_buff *skb,
+					      const struct net_device *in,
+					      const struct net_device *out)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (nft_bridge_ip6hdr_validate(skb) &&
+	    nft_set_pktinfo_ipv6(pkt, ops, skb, in, out) == 0)
+		return;
+#endif
+	nft_set_pktinfo(pkt, ops, skb, in, out);
+}
+
 static unsigned int
 nft_do_chain_bridge(const struct nf_hook_ops *ops,
 		    struct sk_buff *skb,
@@ -71,7 +99,17 @@ nft_do_chain_bridge(const struct nf_hook_ops *ops,
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo(&pkt, ops, skb, in, out);
+	switch (eth_hdr(skb)->h_proto) {
+	case htons(ETH_P_IP):
+		nft_bridge_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
+		break;
+	case htons(ETH_P_IPV6):
+		nft_bridge_set_pktinfo_ipv6(&pkt, ops, skb, in, out);
+		break;
+	default:
+		nft_set_pktinfo(&pkt, ops, skb, in, out);
+		break;
+	}
 
 	return nft_do_chain(&pkt, ops);
 }
-- 
1.7.10.4

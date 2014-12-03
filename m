From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/12] netfilter: nf_tables_bridge: export nft_reject_ip*hdr_validate functions
Date: Wed,  3 Dec 2014 13:55:33 +0100
Message-ID: <1417611342-25257-4-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48607 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343AbaLCMxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 07:53:31 -0500
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alvaro Neira <alvaroneay@gmail.com>

This patch exports the functions nft_reject_iphdr_validate and
nft_reject_ip6hdr_validate to use it in follow up patches.
These functions check if the IPv4/IPv6 header is correct.

Signed-off-by: Alvaro Neira Ayuso <alvaroneay@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_bridge.h |    7 ++++
 net/bridge/netfilter/nf_tables_bridge.c  |   48 +++++++++++++++++++++++++++
 net/bridge/netfilter/nft_reject_bridge.c |   52 +++---------------------------
 3 files changed, 60 insertions(+), 47 deletions(-)
 create mode 100644 include/net/netfilter/nf_tables_bridge.h

diff --git a/include/net/netfilter/nf_tables_bridge.h b/include/net/netfilter/nf_tables_bridge.h
new file mode 100644
index 0000000..511fb79
--- /dev/null
+++ b/include/net/netfilter/nf_tables_bridge.h
@@ -0,0 +1,7 @@
+#ifndef _NET_NF_TABLES_BRIDGE_H
+#define _NET_NF_TABLES_BRIDGE_H
+
+int nft_bridge_iphdr_validate(struct sk_buff *skb);
+int nft_bridge_ip6hdr_validate(struct sk_buff *skb);
+
+#endif /* _NET_NF_TABLES_BRIDGE_H */
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 074c557..d468c19 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -13,6 +13,54 @@
 #include <linux/module.h>
 #include <linux/netfilter_bridge.h>
 #include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_bridge.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+
+int nft_bridge_iphdr_validate(struct sk_buff *skb)
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
+EXPORT_SYMBOL_GPL(nft_bridge_iphdr_validate);
+
+int nft_bridge_ip6hdr_validate(struct sk_buff *skb)
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
+EXPORT_SYMBOL_GPL(nft_bridge_ip6hdr_validate);
 
 static unsigned int
 nft_do_chain_bridge(const struct nf_hook_ops *ops,
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 48da2c5..b0330ae 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -14,6 +14,7 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
 #include <net/netfilter/nft_reject.h>
+#include <net/netfilter/nf_tables_bridge.h>
 #include <net/netfilter/ipv4/nf_reject.h>
 #include <net/netfilter/ipv6/nf_reject.h>
 #include <linux/ip.h>
@@ -35,30 +36,6 @@ static void nft_reject_br_push_etherhdr(struct sk_buff *oldskb,
 	skb_pull(nskb, ETH_HLEN);
 }
 
-static int nft_reject_iphdr_validate(struct sk_buff *oldskb)
-{
-	struct iphdr *iph;
-	u32 len;
-
-	if (!pskb_may_pull(oldskb, sizeof(struct iphdr)))
-		return 0;
-
-	iph = ip_hdr(oldskb);
-	if (iph->ihl < 5 || iph->version != 4)
-		return 0;
-
-	len = ntohs(iph->tot_len);
-	if (oldskb->len < len)
-		return 0;
-	else if (len < (iph->ihl*4))
-		return 0;
-
-	if (!pskb_may_pull(oldskb, iph->ihl*4))
-		return 0;
-
-	return 1;
-}
-
 static void nft_reject_br_send_v4_tcp_reset(struct sk_buff *oldskb, int hook)
 {
 	struct sk_buff *nskb;
@@ -66,7 +43,7 @@ static void nft_reject_br_send_v4_tcp_reset(struct sk_buff *oldskb, int hook)
 	const struct tcphdr *oth;
 	struct tcphdr _oth;
 
-	if (!nft_reject_iphdr_validate(oldskb))
+	if (!nft_bridge_iphdr_validate(oldskb))
 		return;
 
 	oth = nf_reject_ip_tcphdr_get(oldskb, &_oth, hook);
@@ -101,7 +78,7 @@ static void nft_reject_br_send_v4_unreach(struct sk_buff *oldskb, int hook,
 	void *payload;
 	__wsum csum;
 
-	if (!nft_reject_iphdr_validate(oldskb))
+	if (!nft_bridge_iphdr_validate(oldskb))
 		return;
 
 	/* IP header checks: fragment. */
@@ -146,25 +123,6 @@ static void nft_reject_br_send_v4_unreach(struct sk_buff *oldskb, int hook,
 	br_deliver(br_port_get_rcu(oldskb->dev), nskb);
 }
 
-static int nft_reject_ip6hdr_validate(struct sk_buff *oldskb)
-{
-	struct ipv6hdr *hdr;
-	u32 pkt_len;
-
-	if (!pskb_may_pull(oldskb, sizeof(struct ipv6hdr)))
-		return 0;
-
-	hdr = ipv6_hdr(oldskb);
-	if (hdr->version != 6)
-		return 0;
-
-	pkt_len = ntohs(hdr->payload_len);
-	if (pkt_len + sizeof(struct ipv6hdr) > oldskb->len)
-		return 0;
-
-	return 1;
-}
-
 static void nft_reject_br_send_v6_tcp_reset(struct net *net,
 					    struct sk_buff *oldskb, int hook)
 {
@@ -174,7 +132,7 @@ static void nft_reject_br_send_v6_tcp_reset(struct net *net,
 	unsigned int otcplen;
 	struct ipv6hdr *nip6h;
 
-	if (!nft_reject_ip6hdr_validate(oldskb))
+	if (!nft_bridge_ip6hdr_validate(oldskb))
 		return;
 
 	oth = nf_reject_ip6_tcphdr_get(oldskb, &_oth, &otcplen, hook);
@@ -207,7 +165,7 @@ static void nft_reject_br_send_v6_unreach(struct net *net,
 	unsigned int len;
 	void *payload;
 
-	if (!nft_reject_ip6hdr_validate(oldskb))
+	if (!nft_bridge_ip6hdr_validate(oldskb))
 		return;
 
 	/* Include "As much of invoking packet as possible without the ICMPv6
-- 
1.7.10.4

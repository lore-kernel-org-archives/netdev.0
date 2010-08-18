From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 6/8 v2] netfilter: ipt_CLUSTERIP: use proto_ports_offset() to support AH message
Date: Wed, 18 Aug 2010 14:34:40 +0800
Message-ID: <1282113280-16169-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:53926 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832Ab0HRGe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 02:34:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v2: remove the fragment check
 net/ipv4/netfilter/ipt_CLUSTERIP.c |   31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 3a43cf3..1e26a48 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -29,6 +29,7 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <net/net_namespace.h>
 #include <net/checksum.h>
+#include <net/ip.h>
 
 #define CLUSTERIP_VERSION "0.8"
 
@@ -231,24 +232,22 @@ clusterip_hashfn(const struct sk_buff *skb,
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	unsigned long hashval;
-	u_int16_t sport, dport;
-	const u_int16_t *ports;
-
-	switch (iph->protocol) {
-	case IPPROTO_TCP:
-	case IPPROTO_UDP:
-	case IPPROTO_UDPLITE:
-	case IPPROTO_SCTP:
-	case IPPROTO_DCCP:
-	case IPPROTO_ICMP:
-		ports = (const void *)iph+iph->ihl*4;
-		sport = ports[0];
-		dport = ports[1];
-		break;
-	default:
+	u_int16_t sport = 0, dport = 0;
+	int poff;
+
+	poff = proto_ports_offset(iph->protocol);
+	if (poff >= 0) {
+		const u_int16_t *ports;
+		u16 _ports[2];
+
+		ports = skb_header_pointer(skb, iph->ihl * 4 + poff, 4, _ports);
+		if (ports) {
+			sport = ports[0];
+			dport = ports[1];
+		}
+	} else {
 		if (net_ratelimit())
 			pr_info("unknown protocol %u\n", iph->protocol);
-		sport = dport = 0;
 	}
 
 	switch (config->hash_mode) {

From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 6/8] netfilter: ipt_CLUSTERIP: use proto_ports_offset() to support AH message
Date: Wed, 18 Aug 2010 13:05:52 +0800
Message-ID: <1282107952-3624-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |   34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 3a43cf3..11c3534 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -29,6 +29,7 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <net/net_namespace.h>
 #include <net/checksum.h>
+#include <net/ip.h>
 
 #define CLUSTERIP_VERSION "0.8"
 
@@ -231,24 +232,25 @@ clusterip_hashfn(const struct sk_buff *skb,
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	unsigned long hashval;
-	u_int16_t sport, dport;
+	u_int16_t sport = 0, dport = 0;
 	const u_int16_t *ports;
 
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
-		if (net_ratelimit())
-			pr_info("unknown protocol %u\n", iph->protocol);
-		sport = dport = 0;
+	if (!(iph->frag_off & htons(IP_MF|IP_OFFSET))) {
+		int poff;
+
+		poff = proto_ports_offset(iph->protocol);
+		if (poff >= 0) {
+			u16 _ports[2];
+			ports = skb_header_pointer(skb, iph->ihl * 4 + poff,
+						   4, _ports);
+			if (ports) {
+				sport = ports[0];
+				dport = ports[1];
+			}
+		} else {
+			if (net_ratelimit())
+				pr_info("unknown protocol %u\n", iph->protocol);
+		}
 	}
 
 	switch (config->hash_mode) {

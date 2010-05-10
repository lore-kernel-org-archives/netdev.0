From: kaber@trash.net
Subject: [PATCH 55/84] IPVS: fix potential stack overflow with overly long protocol names
Date: Mon, 10 May 2010 22:18:26 +0200
Message-ID: <1273522735-24672-56-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

When protocols use very long names, the sprintf calls might overflow
the on-stack buffer. No protocol in the kernel does this however.

Print the protocol name in the pr_debug statement directly to avoid
this.

Based on patch by Zhitong Wang <zhitong.wangzt@alibaba-inc.com>
Acked-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipvs/ip_vs_proto.c        |   28 ++++++++++++----------------
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   14 ++++++--------
 2 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 0e58455..27add97 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -166,26 +166,24 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		sprintf(buf, "TRUNCATED");
 	else if (ih->frag_off & htons(IP_OFFSET))
-		sprintf(buf, "%s %pI4->%pI4 frag",
-			pp->name, &ih->saddr, &ih->daddr);
+		sprintf(buf, "%pI4->%pI4 frag", &ih->saddr, &ih->daddr);
 	else {
 		__be16 _ports[2], *pptr
 ;
 		pptr = skb_header_pointer(skb, offset + ih->ihl*4,
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
-			sprintf(buf, "%s TRUNCATED %pI4->%pI4",
-				pp->name, &ih->saddr, &ih->daddr);
+			sprintf(buf, "TRUNCATED %pI4->%pI4",
+				&ih->saddr, &ih->daddr);
 		else
-			sprintf(buf, "%s %pI4:%u->%pI4:%u",
-				pp->name,
+			sprintf(buf, "%pI4:%u->%pI4:%u",
 				&ih->saddr, ntohs(pptr[0]),
 				&ih->daddr, ntohs(pptr[1]));
 	}
 
-	pr_debug("%s: %s\n", msg, buf);
+	pr_debug("%s: %s %s\n", msg, pp->name, buf);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -200,26 +198,24 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		sprintf(buf, "TRUNCATED");
 	else if (ih->nexthdr == IPPROTO_FRAGMENT)
-		sprintf(buf, "%s %pI6->%pI6 frag",
-			pp->name, &ih->saddr, &ih->daddr);
+		sprintf(buf, "%pI6->%pI6 frag",	&ih->saddr, &ih->daddr);
 	else {
 		__be16 _ports[2], *pptr;
 
 		pptr = skb_header_pointer(skb, offset + sizeof(struct ipv6hdr),
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
-			sprintf(buf, "%s TRUNCATED %pI6->%pI6",
-				pp->name, &ih->saddr, &ih->daddr);
+			sprintf(buf, "TRUNCATED %pI6->%pI6",
+				&ih->saddr, &ih->daddr);
 		else
-			sprintf(buf, "%s %pI6:%u->%pI6:%u",
-				pp->name,
+			sprintf(buf, "%pI6:%u->%pI6:%u",
 				&ih->saddr, ntohs(pptr[0]),
 				&ih->daddr, ntohs(pptr[1]));
 	}
 
-	pr_debug("%s: %s\n", msg, buf);
+	pr_debug("%s: %s %s\n", msg, pp->name, buf);
 }
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index c30b43c..1892dfc 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -136,12 +136,11 @@ ah_esp_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		sprintf(buf, "TRUNCATED");
 	else
-		sprintf(buf, "%s %pI4->%pI4",
-			pp->name, &ih->saddr, &ih->daddr);
+		sprintf(buf, "%pI4->%pI4", &ih->saddr, &ih->daddr);
 
-	pr_debug("%s: %s\n", msg, buf);
+	pr_debug("%s: %s %s\n", msg, pp->name, buf);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -154,12 +153,11 @@ ah_esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		sprintf(buf, "TRUNCATED");
 	else
-		sprintf(buf, "%s %pI6->%pI6",
-			pp->name, &ih->saddr, &ih->daddr);
+		sprintf(buf, "%pI6->%pI6", &ih->saddr, &ih->daddr);
 
-	pr_debug("%s: %s\n", msg, buf);
+	pr_debug("%s: %s %s\n", msg, pp->name, buf);
 }
 #endif
 
-- 
1.7.0.4


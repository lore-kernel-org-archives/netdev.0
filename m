From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 08/26] IPVS: Add IPv6 handler functions to ESP protocol handler.
Date: Wed, 11 Jun 2008 19:11:51 +0200
Message-ID: <1213204329-10973-9-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com,
	"Julius R. Volz" <juliusv@google.com>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:14474 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754252AbYFKRMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 13:12:38 -0400
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define new IPv6-specific handler functions in ESP protocol handler. Set new
function pointers in ip_vs_protocol struct to point to these functions.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 86 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_esp.c b/net/netfilter/ipvs/ip_vs_proto_esp.c
index db6a6b7..5113df4 100644
--- a/net/netfilter/ipvs/ip_vs_proto_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_esp.c
@@ -79,6 +79,47 @@ esp_conn_in_get(const struct sk_buff *skb,
 	return cp;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct ip_vs_conn *
+esp_conn_in_get_v6(const struct sk_buff *skb,
+		   struct ip_vs_protocol *pp,
+		   const struct ipv6hdr *iph,
+		   unsigned int proto_off,
+		   int inverse)
+{
+	struct ip_vs_conn *cp;
+
+	if (likely(!inverse)) {
+		cp = ip_vs_conn_in_get_v6(IPPROTO_UDP,
+				          &iph->saddr,
+				          htons(PORT_ISAKMP),
+				          &iph->daddr,
+				          htons(PORT_ISAKMP));
+	} else {
+		cp = ip_vs_conn_in_get_v6(IPPROTO_UDP,
+				          &iph->daddr,
+				          htons(PORT_ISAKMP),
+				          &iph->saddr,
+				          htons(PORT_ISAKMP));
+	}
+
+	if (!cp) {
+		/*
+		 * We are not sure if the packet is from our
+		 * service, so our conn_schedule hook should return NF_ACCEPT
+		 */
+		IP_VS_DBG(12, "Unknown ISAKMP entry for outin packet "
+			  "%s%s " NIP6_FMT "->" NIP6_FMT "\n",
+			  inverse ? "ICMP+" : "",
+			  pp->name,
+			  NIP6(iph->saddr),
+			  NIP6(iph->daddr));
+	}
+
+	return cp;
+}
+#endif
+
 
 static struct ip_vs_conn *
 esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
@@ -112,6 +153,40 @@ esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	return cp;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct ip_vs_conn *
+esp_conn_out_get_v6(const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		    const struct ipv6hdr *iph, unsigned int proto_off, int inverse)
+{
+	struct ip_vs_conn *cp;
+
+	if (likely(!inverse)) {
+		cp = ip_vs_conn_out_get_v6(IPPROTO_UDP,
+					   &iph->saddr,
+					   htons(PORT_ISAKMP),
+					   &iph->daddr,
+					   htons(PORT_ISAKMP));
+	} else {
+		cp = ip_vs_conn_out_get_v6(IPPROTO_UDP,
+					   &iph->daddr,
+					   htons(PORT_ISAKMP),
+					   &iph->saddr,
+					   htons(PORT_ISAKMP));
+	}
+
+	if (!cp) {
+		IP_VS_DBG(12, "Unknown ISAKMP entry for inout packet "
+			  "%s%s " NIP6_FMT "->" NIP6_FMT "\n",
+			  inverse ? "ICMP+" : "",
+			  pp->name,
+			  NIP6(iph->saddr),
+			  NIP6(iph->daddr));
+	}
+
+	return cp;
+}
+#endif
+
 
 static int
 esp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
@@ -164,10 +239,21 @@ struct ip_vs_protocol ip_vs_protocol_esp = {
 	.init =			esp_init,
 	.exit =			esp_exit,
 	.conn_schedule =	esp_conn_schedule,
+#ifdef CONFIG_IP_VS_IPV6
+	.conn_schedule_v6 =	esp_conn_schedule,
+#endif
 	.conn_in_get =		esp_conn_in_get,
 	.conn_out_get =		esp_conn_out_get,
+#ifdef CONFIG_IP_VS_IPV6
+	.conn_in_get_v6 =	esp_conn_in_get_v6,
+	.conn_out_get_v6 =	esp_conn_out_get_v6,
+#endif
 	.snat_handler =		NULL,
 	.dnat_handler =		NULL,
+#ifdef CONFIG_IP_VS_IPV6
+	.snat_handler_v6 =	NULL,
+	.dnat_handler_v6 =	NULL,
+#endif
 	.csum_check =		NULL,
 	.state_transition =	NULL,
 	.register_app =		NULL,
-- 
1.5.3.6


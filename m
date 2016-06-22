From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 4/5] qede: Add support to handle GRE hardware GRO packets
Date: Wed, 22 Jun 2016 04:25:25 -0400
Message-ID: <1466583926-27762-5-git-send-email-manish.chopra@qlogic.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43053 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751109AbcFVJJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 05:09:39 -0400
In-Reply-To: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to do necessary processing
for hardware assisted GRE tunnel GRO packets before
driver delivers them upto the stack.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 54 +++++++++++++++++++++++-----
 1 file changed, 46 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index a4b445f..787aef0 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -38,6 +38,7 @@
 #include <linux/bitops.h>
 #include <net/vxlan.h>
 #include <net/geneve.h>
+#include <net/gre.h>
 
 #include "qede.h"
 
@@ -1152,10 +1153,7 @@ cons_buf: /* We still need to handle bd_len_list to consume buffers */
 static void qede_gro_ip_csum(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	struct tcphdr *th;
-
-	skb_set_transport_header(skb, sizeof(struct iphdr));
-	th = tcp_hdr(skb);
+	struct tcphdr *th = tcp_hdr(skb);
 
 	th->check = ~tcp_v4_check(skb->len - skb_transport_offset(skb),
 				  iph->saddr, iph->daddr, 0);
@@ -1166,10 +1164,7 @@ static void qede_gro_ip_csum(struct sk_buff *skb)
 static void qede_gro_ipv6_csum(struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct tcphdr *th;
-
-	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
-	th = tcp_hdr(skb);
+	struct tcphdr *th = tcp_hdr(skb);
 
 	th->check = ~tcp_v6_check(skb->len - skb_transport_offset(skb),
 				  &iph->saddr, &iph->daddr, 0);
@@ -1232,6 +1227,44 @@ static void qede_handle_geneve_tunnel_gro(struct sk_buff *skb)
 	}
 }
 
+static void qede_handle_gre_tunnel_gro(struct sk_buff *skb)
+{
+	unsigned int grehlen, gre_headroom;
+	struct gre_base_hdr *greh;
+	int nhoff = 0;
+
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		nhoff = sizeof(struct iphdr);
+		break;
+	case htons(ETH_P_IPV6):
+		nhoff = sizeof(struct ipv6hdr);
+		break;
+	default:
+		WARN_ONCE(1, "Unsupported GRE tunnel GRO, proto=0x%x\n",
+			  skb->protocol);
+	}
+
+	greh = (struct gre_base_hdr *)(skb->data + nhoff);
+	grehlen = sizeof(*greh);
+
+	if (greh->flags & GRE_KEY)
+		grehlen += GRE_HEADER_SECTION;
+
+	if (greh->flags & GRE_CSUM)
+		grehlen += GRE_HEADER_SECTION;
+
+	gre_headroom = nhoff + grehlen;
+
+	/* L2 GRE */
+	if (greh->protocol == htons(ETH_P_TEB))
+		gre_headroom += ETH_HLEN;
+
+	qede_set_nh_th_offset(skb, gre_headroom);
+
+	gre_gro_complete(skb, nhoff);
+}
+
 static void qede_handle_tunnel_gro(struct qede_dev *edev,
 				   struct sk_buff *skb, u8 tunnel_type)
 {
@@ -1242,6 +1275,9 @@ static void qede_handle_tunnel_gro(struct qede_dev *edev,
 	case ETH_RX_TUNN_GENEVE:
 		qede_handle_geneve_tunnel_gro(skb);
 		break;
+	case ETH_RX_TUNN_GRE:
+		qede_handle_gre_tunnel_gro(skb);
+		break;
 	default:
 		WARN_ONCE(1, "Unsupported tunnel GRO, tunnel type=0x%x\n",
 			  tunnel_type);
@@ -1277,9 +1313,11 @@ static void qede_gro_receive(struct qede_dev *edev,
 
 		switch (skb->protocol) {
 		case htons(ETH_P_IP):
+			skb_set_transport_header(skb, sizeof(struct iphdr));
 			qede_gro_ip_csum(skb);
 			break;
 		case htons(ETH_P_IPV6):
+			skb_set_transport_header(skb, sizeof(struct ipv6hdr));
 			qede_gro_ipv6_csum(skb);
 			break;
 		default:
-- 
2.7.2

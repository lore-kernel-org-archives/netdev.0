From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 3/5] qede: Add support to handle GENEVE hardware GRO packets
Date: Wed, 22 Jun 2016 04:25:24 -0400
Message-ID: <1466583926-27762-4-git-send-email-manish.chopra@qlogic.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43049 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750957AbcFVJJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 05:09:38 -0400
In-Reply-To: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to do necessary processing
for hardware assisted GENEVE tunnel GRO packets before
driver delivers them upto the stack.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 30 ++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index f94ea16..a4b445f 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -37,6 +37,7 @@
 #include <net/ip6_checksum.h>
 #include <linux/bitops.h>
 #include <net/vxlan.h>
+#include <net/geneve.h>
 
 #include "qede.h"
 
@@ -1205,6 +1206,32 @@ static void qede_handle_vxlan_tunnel_gro(struct sk_buff *skb)
 	}
 }
 
+static inline struct genevehdr *
+qede_geneve_hdr(struct sk_buff *skb, int off) {
+	return (struct genevehdr *)(skb->data + off + sizeof(struct udphdr));
+}
+
+static void qede_handle_geneve_tunnel_gro(struct sk_buff *skb)
+{
+	struct genevehdr *gh;
+
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		gh = qede_geneve_hdr(skb, sizeof(struct iphdr));
+		qede_set_nh_th_offset(skb, VXLAN_HEADROOM + (gh->opt_len * 4));
+		udp4_gro_complete(skb, sizeof(struct iphdr));
+		break;
+	case htons(ETH_P_IPV6):
+		gh = qede_geneve_hdr(skb, sizeof(struct ipv6hdr));
+		qede_set_nh_th_offset(skb, VXLAN6_HEADROOM + (gh->opt_len * 4));
+		udp6_gro_complete(skb, sizeof(struct ipv6hdr));
+		break;
+	default:
+		WARN_ONCE(1, "Unsupported GENEVE tunnel GRO proto=0x%x\n",
+			  skb->protocol);
+	}
+}
+
 static void qede_handle_tunnel_gro(struct qede_dev *edev,
 				   struct sk_buff *skb, u8 tunnel_type)
 {
@@ -1212,6 +1239,9 @@ static void qede_handle_tunnel_gro(struct qede_dev *edev,
 	case ETH_RX_TUNN_VXLAN:
 		qede_handle_vxlan_tunnel_gro(skb);
 		break;
+	case ETH_RX_TUNN_GENEVE:
+		qede_handle_geneve_tunnel_gro(skb);
+		break;
 	default:
 		WARN_ONCE(1, "Unsupported tunnel GRO, tunnel type=0x%x\n",
 			  tunnel_type);
-- 
2.7.2

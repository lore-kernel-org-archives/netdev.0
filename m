From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 2/5] qede: Add support to handle VXLAN hardware GRO packets
Date: Wed, 22 Jun 2016 04:25:23 -0400
Message-ID: <1466583926-27762-3-git-send-email-manish.chopra@qlogic.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43052 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750970AbcFVJJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 05:09:38 -0400
In-Reply-To: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to do necessary processing
for hardware assisted VXLAN tunnel GRO packets before
driver delivers them upto the stack.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h      |  1 +
 drivers/net/ethernet/qlogic/qede/qede_main.c | 79 ++++++++++++++++++++++++----
 2 files changed, 70 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 1441c8f..d8ec269 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -213,6 +213,7 @@ struct qede_agg_info {
 	struct sk_buff *skb;
 	int frag_id;
 	u16 vlan_tag;
+	u8 tunnel_type;
 };
 
 struct qede_rx_queue {
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 2972742..f94ea16 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -36,6 +36,7 @@
 #include <linux/random.h>
 #include <net/ip6_checksum.h>
 #include <linux/bitops.h>
+#include <net/vxlan.h>
 
 #include "qede.h"
 
@@ -1048,6 +1049,12 @@ out:
 	return -ENOMEM;
 }
 
+static bool qede_tunn_exist(u16 flag)
+{
+	return !!(flag & (PARSING_AND_ERR_FLAGS_TUNNELEXIST_MASK <<
+			  PARSING_AND_ERR_FLAGS_TUNNELEXIST_SHIFT));
+}
+
 static void qede_tpa_start(struct qede_dev *edev,
 			   struct qede_rx_queue *rxq,
 			   struct eth_fast_path_rx_tpa_start_cqe *cqe)
@@ -1065,6 +1072,14 @@ static void qede_tpa_start(struct qede_dev *edev,
 	sw_rx_data_cons = &rxq->sw_rx_ring[rxq->sw_rx_cons & NUM_RX_BDS_MAX];
 	sw_rx_data_prod = &rxq->sw_rx_ring[rxq->sw_rx_prod & NUM_RX_BDS_MAX];
 
+	if (qede_tunn_exist(le16_to_cpu(cqe->pars_flags.flags))) {
+		u8 flags = cqe->tunnel_pars_flags.flags, shift;
+
+		shift = ETH_TUNNEL_PARSING_FLAGS_TYPE_SHIFT;
+		tpa_info->tunnel_type = (flags >> shift) &
+					 ETH_TUNNEL_PARSING_FLAGS_TYPE_MASK;
+	}
+
 	/* Use pre-allocated replacement buffer - we can't release the agg.
 	 * start until its over and we don't want to risk allocation failing
 	 * here, so re-allocate when aggregation will be over.
@@ -1159,12 +1174,55 @@ static void qede_gro_ipv6_csum(struct sk_buff *skb)
 				  &iph->saddr, &iph->daddr, 0);
 	tcp_gro_complete(skb);
 }
+
+static void qede_set_nh_th_offset(struct sk_buff *skb, int off)
+{
+	skb_set_network_header(skb, off);
+
+	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
+		off += sizeof(struct iphdr);
+		skb_set_transport_header(skb, off);
+	} else {
+		off += sizeof(struct ipv6hdr);
+		skb_set_transport_header(skb, off);
+	}
+}
+
+static void qede_handle_vxlan_tunnel_gro(struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		qede_set_nh_th_offset(skb, VXLAN_HEADROOM);
+		udp4_gro_complete(skb, sizeof(struct iphdr));
+		break;
+	case htons(ETH_P_IPV6):
+		qede_set_nh_th_offset(skb, VXLAN6_HEADROOM);
+		udp6_gro_complete(skb, sizeof(struct ipv6hdr));
+		break;
+	default:
+		WARN_ONCE(1, "Unsupported VXLAN tunnel GRO proto=0x%x\n",
+			  skb->protocol);
+	}
+}
+
+static void qede_handle_tunnel_gro(struct qede_dev *edev,
+				   struct sk_buff *skb, u8 tunnel_type)
+{
+	switch (tunnel_type) {
+	case ETH_RX_TUNN_VXLAN:
+		qede_handle_vxlan_tunnel_gro(skb);
+		break;
+	default:
+		WARN_ONCE(1, "Unsupported tunnel GRO, tunnel type=0x%x\n",
+			  tunnel_type);
+	}
+}
 #endif
 
 static void qede_gro_receive(struct qede_dev *edev,
 			     struct qede_fastpath *fp,
 			     struct sk_buff *skb,
-			     u16 vlan_tag)
+			     struct qede_agg_info *tpa_info)
 {
 	/* FW can send a single MTU sized packet from gro flow
 	 * due to aggregation timeout/last segment etc. which
@@ -1179,6 +1237,12 @@ static void qede_gro_receive(struct qede_dev *edev,
 
 #ifdef CONFIG_INET
 	if (skb_shinfo(skb)->gso_size) {
+		if (tpa_info->tunnel_type) {
+			qede_handle_tunnel_gro(edev, skb,
+					       tpa_info->tunnel_type);
+			goto send_skb;
+		}
+
 		skb_set_network_header(skb, 0);
 
 		switch (skb->protocol) {
@@ -1198,7 +1262,7 @@ static void qede_gro_receive(struct qede_dev *edev,
 
 send_skb:
 	skb_record_rx_queue(skb, fp->rss_id);
-	qede_skb_receive(edev, fp, skb, vlan_tag);
+	qede_skb_receive(edev, fp, skb, tpa_info->vlan_tag);
 }
 
 static inline void qede_tpa_cont(struct qede_dev *edev,
@@ -1267,10 +1331,10 @@ static void qede_tpa_end(struct qede_dev *edev,
 	 */
 	NAPI_GRO_CB(skb)->count = le16_to_cpu(cqe->num_of_coalesced_segs);
 
-	qede_gro_receive(edev, fp, skb, tpa_info->vlan_tag);
+	qede_gro_receive(edev, fp, skb, tpa_info);
 
 	tpa_info->agg_state = QEDE_AGG_STATE_NONE;
-
+	tpa_info->tunnel_type = 0;
 	return;
 err:
 	/* The BD starting the aggregation is still mapped; Re-use it for
@@ -1283,12 +1347,7 @@ err:
 	tpa_info->agg_state = QEDE_AGG_STATE_NONE;
 	dev_kfree_skb_any(tpa_info->skb);
 	tpa_info->skb = NULL;
-}
-
-static bool qede_tunn_exist(u16 flag)
-{
-	return !!(flag & (PARSING_AND_ERR_FLAGS_TUNNELEXIST_MASK <<
-			  PARSING_AND_ERR_FLAGS_TUNNELEXIST_SHIFT));
+	tpa_info->tunnel_type = 0;
 }
 
 static u8 qede_check_tunn_csum(u16 flag)
-- 
2.7.2

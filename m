From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net-next 3/7] qede: Prevent GSO on long Geneve headers
Date: Thu, 13 Oct 2016 07:22:47 -0400
Message-ID: <1476357771-1578-4-git-send-email-manish.chopra@qlogic.com>
References: <1476357771-1578-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
        Manish Chopra <manish.chopra@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:33199 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754340AbcJMMIz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 08:08:55 -0400
In-Reply-To: <1476357771-1578-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@caviumnetworks.com>

Due to hardware limitation, when transmitting a geneve-encapsulated
packet with more than 32 bytes worth of geneve options the hardware
would not be able to crack the packet and consider it a regular UDP
packet.

This implements the ndo_features_check() in qede in order to prevent
GSO on said transmitted packets.

Signed-off-by: Manish Chopra <manish.chopra@caviumnetworks.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 35 ++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 7d5dc1e..6c2b09c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2240,6 +2240,40 @@ static void qede_udp_tunnel_del(struct net_device *dev,
 	schedule_delayed_work(&edev->sp_task, 0);
 }
 
+/* 8B udp header + 8B base tunnel header + 32B option length */
+#define QEDE_MAX_TUN_HDR_LEN 48
+
+static netdev_features_t qede_features_check(struct sk_buff *skb,
+					     struct net_device *dev,
+					     netdev_features_t features)
+{
+	if (skb->encapsulation) {
+		u8 l4_proto = 0;
+
+		switch (vlan_get_protocol(skb)) {
+		case htons(ETH_P_IP):
+			l4_proto = ip_hdr(skb)->protocol;
+			break;
+		case htons(ETH_P_IPV6):
+			l4_proto = ipv6_hdr(skb)->nexthdr;
+			break;
+		default:
+			return features;
+		}
+
+		/* Disable offloads for geneve tunnels, as HW can't parse
+		 * the geneve header which has option length greater than 32B.
+		 */
+		if ((l4_proto == IPPROTO_UDP) &&
+		    ((skb_inner_mac_header(skb) -
+		      skb_transport_header(skb)) > QEDE_MAX_TUN_HDR_LEN))
+			return features & ~(NETIF_F_CSUM_MASK |
+					    NETIF_F_GSO_MASK);
+	}
+
+	return features;
+}
+
 static const struct net_device_ops qede_netdev_ops = {
 	.ndo_open = qede_open,
 	.ndo_stop = qede_close,
@@ -2264,6 +2298,7 @@ static const struct net_device_ops qede_netdev_ops = {
 #endif
 	.ndo_udp_tunnel_add = qede_udp_tunnel_add,
 	.ndo_udp_tunnel_del = qede_udp_tunnel_del,
+	.ndo_features_check = qede_features_check,
 };
 
 /* -------------------------------------------------------------------------
-- 
2.7.2

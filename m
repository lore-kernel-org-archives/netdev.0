From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v3 net-next 2/7] qede: GSO support for tunnels with outer csum
Date: Fri, 14 Oct 2016 05:19:18 -0400
Message-ID: <1476436763-5274-3-git-send-email-manish.chopra@qlogic.com>
References: <1476436763-5274-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
        Manish Chopra <manish.chopra@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:41647 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753603AbcJNKEx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 06:04:53 -0400
In-Reply-To: <1476436763-5274-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@caviumnetworks.com>

This patch adds GSO support for GRE and UDP tunnels
where outer checksums are enabled.

Signed-off-by: Manish Chopra <manish.chopra@caviumnetworks.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h      |  1 +
 drivers/net/ethernet/qlogic/qede/qede_main.c | 26 +++++++++++++++++++++++---
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 28c0e9f..f50e527 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -320,6 +320,7 @@ struct qede_fastpath {
 #define XMIT_L4_CSUM		BIT(0)
 #define XMIT_LSO		BIT(1)
 #define XMIT_ENC		BIT(2)
+#define XMIT_ENC_GSO_L4_CSUM	BIT(3)
 
 #define QEDE_CSUM_ERROR			BIT(0)
 #define QEDE_CSUM_UNNECESSARY		BIT(1)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 9866d95..7d5dc1e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -400,8 +400,19 @@ static u32 qede_xmit_type(struct qede_dev *edev,
 	    (ipv6_hdr(skb)->nexthdr == NEXTHDR_IPV6))
 		*ipv6_ext = 1;
 
-	if (skb->encapsulation)
+	if (skb->encapsulation) {
 		rc |= XMIT_ENC;
+		if (skb_is_gso(skb)) {
+			unsigned short gso_type = skb_shinfo(skb)->gso_type;
+
+			if ((gso_type & SKB_GSO_UDP_TUNNEL_CSUM) ||
+			    (gso_type & SKB_GSO_GRE_CSUM))
+				rc |= XMIT_ENC_GSO_L4_CSUM;
+
+			rc |= XMIT_LSO;
+			return rc;
+		}
+	}
 
 	if (skb_is_gso(skb))
 		rc |= XMIT_LSO;
@@ -637,6 +648,12 @@ static netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 		if (unlikely(xmit_type & XMIT_ENC)) {
 			first_bd->data.bd_flags.bitfields |=
 				1 << ETH_TX_1ST_BD_FLAGS_TUNN_IP_CSUM_SHIFT;
+
+			if (xmit_type & XMIT_ENC_GSO_L4_CSUM) {
+				u8 tmp = ETH_TX_1ST_BD_FLAGS_TUNN_L4_CSUM_SHIFT;
+
+				first_bd->data.bd_flags.bitfields |= 1 << tmp;
+			}
 			hlen = qede_get_skb_hlen(skb, true);
 		} else {
 			first_bd->data.bd_flags.bitfields |=
@@ -2320,11 +2337,14 @@ static void qede_init_ndev(struct qede_dev *edev)
 
 	/* Encap features*/
 	hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
-		       NETIF_F_TSO_ECN;
+		       NETIF_F_TSO_ECN | NETIF_F_GSO_UDP_TUNNEL_CSUM |
+		       NETIF_F_GSO_GRE_CSUM;
 	ndev->hw_enc_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 				NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO_ECN |
 				NETIF_F_TSO6 | NETIF_F_GSO_GRE |
-				NETIF_F_GSO_UDP_TUNNEL | NETIF_F_RXCSUM;
+				NETIF_F_GSO_UDP_TUNNEL | NETIF_F_RXCSUM |
+				NETIF_F_GSO_UDP_TUNNEL_CSUM |
+				NETIF_F_GSO_GRE_CSUM;
 
 	ndev->vlan_features = hw_features | NETIF_F_RXHASH | NETIF_F_RXCSUM |
 			      NETIF_F_HIGHDMA;
-- 
2.7.2

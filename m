From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net-next 5/5] qede: Add fastpath support for tunneling
Date: Thu, 14 Apr 2016 01:38:33 -0400
Message-ID: <1460612313-20323-6-git-send-email-manish.chopra@qlogic.com>
References: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:63242 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752034AbcDNGUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 02:20:13 -0400
In-Reply-To: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables netdev tunneling features and adds
TX/RX fastpath support for tunneling in driver.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h      |   1 +
 drivers/net/ethernet/qlogic/qede/qede_main.c | 101 ++++++++++++++++++++++++---
 2 files changed, 92 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 8521fee..16df159 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -290,6 +290,7 @@ struct qede_fastpath {
 
 #define QEDE_CSUM_ERROR			BIT(0)
 #define QEDE_CSUM_UNNECESSARY		BIT(1)
+#define QEDE_TUNN_CSUM_UNNECESSARY	BIT(2)
 
 #define QEDE_SP_RX_MODE			1
 #define QEDE_SP_VXLAN_PORT_CONFIG	2
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 6c40316..e5dc35a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -315,6 +315,9 @@ static u32 qede_xmit_type(struct qede_dev *edev,
 	    (ipv6_hdr(skb)->nexthdr == NEXTHDR_IPV6))
 		*ipv6_ext = 1;
 
+	if (skb->encapsulation)
+		rc |= XMIT_ENC;
+
 	if (skb_is_gso(skb))
 		rc |= XMIT_LSO;
 
@@ -376,6 +379,16 @@ static int map_frag_to_bd(struct qede_dev *edev,
 	return 0;
 }
 
+static u16 qede_get_skb_hlen(struct sk_buff *skb, bool is_encap_pkt)
+{
+	if (is_encap_pkt)
+		return (skb_inner_transport_header(skb) +
+			inner_tcp_hdrlen(skb) - skb->data);
+	else
+		return (skb_transport_header(skb) +
+			tcp_hdrlen(skb) - skb->data);
+}
+
 /* +2 for 1st BD for headers and 2nd BD for headlen (if required) */
 #if ((MAX_SKB_FRAGS + 2) > ETH_TX_MAX_BDS_PER_NON_LSO_PACKET)
 static bool qede_pkt_req_lin(struct qede_dev *edev, struct sk_buff *skb,
@@ -386,8 +399,7 @@ static bool qede_pkt_req_lin(struct qede_dev *edev, struct sk_buff *skb,
 	if (xmit_type & XMIT_LSO) {
 		int hlen;
 
-		hlen = skb_transport_header(skb) +
-		       tcp_hdrlen(skb) - skb->data;
+		hlen = qede_get_skb_hlen(skb, xmit_type & XMIT_ENC);
 
 		/* linear payload would require its own BD */
 		if (skb_headlen(skb) > hlen)
@@ -495,7 +507,18 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 		first_bd->data.bd_flags.bitfields |=
 			1 << ETH_TX_1ST_BD_FLAGS_L4_CSUM_SHIFT;
 
-		first_bd->data.bitfields |= cpu_to_le16(temp);
+		if (xmit_type & XMIT_ENC) {
+			first_bd->data.bd_flags.bitfields |=
+				1 << ETH_TX_1ST_BD_FLAGS_IP_CSUM_SHIFT;
+		} else {
+			/* In cases when OS doesn't indicate for inner offloads
+			 * when packet is tunnelled, we need to override the HW
+			 * tunnel configuration so that packets are treated as
+			 * regular non tunnelled packets and no inner offloads
+			 * are done by the hardware.
+			 */
+			first_bd->data.bitfields |= cpu_to_le16(temp);
+		}
 
 		/* If the packet is IPv6 with extension header, indicate that
 		 * to FW and pass few params, since the device cracker doesn't
@@ -511,10 +534,15 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 		third_bd->data.lso_mss =
 			cpu_to_le16(skb_shinfo(skb)->gso_size);
 
-		first_bd->data.bd_flags.bitfields |=
-		1 << ETH_TX_1ST_BD_FLAGS_IP_CSUM_SHIFT;
-		hlen = skb_transport_header(skb) +
-		       tcp_hdrlen(skb) - skb->data;
+		if (unlikely(xmit_type & XMIT_ENC)) {
+			first_bd->data.bd_flags.bitfields |=
+				1 << ETH_TX_1ST_BD_FLAGS_TUNN_IP_CSUM_SHIFT;
+			hlen = qede_get_skb_hlen(skb, true);
+		} else {
+			first_bd->data.bd_flags.bitfields |=
+				1 << ETH_TX_1ST_BD_FLAGS_IP_CSUM_SHIFT;
+			hlen = qede_get_skb_hlen(skb, false);
+		}
 
 		/* @@@TBD - if will not be removed need to check */
 		third_bd->data.bitfields |=
@@ -848,6 +876,9 @@ static void qede_set_skb_csum(struct sk_buff *skb, u8 csum_flag)
 
 	if (csum_flag & QEDE_CSUM_UNNECESSARY)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	if (csum_flag & QEDE_TUNN_CSUM_UNNECESSARY)
+		skb->csum_level = 1;
 }
 
 static inline void qede_skb_receive(struct qede_dev *edev,
@@ -1137,13 +1168,47 @@ err:
 	tpa_info->skb = NULL;
 }
 
-static u8 qede_check_csum(u16 flag)
+static bool qede_tunn_exist(u16 flag)
+{
+	return !!(flag & (PARSING_AND_ERR_FLAGS_TUNNELEXIST_MASK <<
+			  PARSING_AND_ERR_FLAGS_TUNNELEXIST_SHIFT));
+}
+
+static u8 qede_check_tunn_csum(u16 flag)
+{
+	u16 csum_flag = 0;
+	u8 tcsum = 0;
+
+	if (flag & (PARSING_AND_ERR_FLAGS_TUNNELL4CHKSMWASCALCULATED_MASK <<
+		    PARSING_AND_ERR_FLAGS_TUNNELL4CHKSMWASCALCULATED_SHIFT))
+		csum_flag |= PARSING_AND_ERR_FLAGS_TUNNELL4CHKSMERROR_MASK <<
+			     PARSING_AND_ERR_FLAGS_TUNNELL4CHKSMERROR_SHIFT;
+
+	if (flag & (PARSING_AND_ERR_FLAGS_L4CHKSMWASCALCULATED_MASK <<
+		    PARSING_AND_ERR_FLAGS_L4CHKSMWASCALCULATED_SHIFT)) {
+		csum_flag |= PARSING_AND_ERR_FLAGS_L4CHKSMERROR_MASK <<
+			     PARSING_AND_ERR_FLAGS_L4CHKSMERROR_SHIFT;
+		tcsum = QEDE_TUNN_CSUM_UNNECESSARY;
+	}
+
+	csum_flag |= PARSING_AND_ERR_FLAGS_TUNNELIPHDRERROR_MASK <<
+		     PARSING_AND_ERR_FLAGS_TUNNELIPHDRERROR_SHIFT |
+		     PARSING_AND_ERR_FLAGS_IPHDRERROR_MASK <<
+		     PARSING_AND_ERR_FLAGS_IPHDRERROR_SHIFT;
+
+	if (csum_flag & flag)
+		return QEDE_CSUM_ERROR;
+
+	return QEDE_CSUM_UNNECESSARY | tcsum;
+}
+
+static u8 qede_check_notunn_csum(u16 flag)
 {
 	u16 csum_flag = 0;
 	u8 csum = 0;
 
-	if ((PARSING_AND_ERR_FLAGS_L4CHKSMWASCALCULATED_MASK <<
-	     PARSING_AND_ERR_FLAGS_L4CHKSMWASCALCULATED_SHIFT) & flag) {
+	if (flag & (PARSING_AND_ERR_FLAGS_L4CHKSMWASCALCULATED_MASK <<
+		    PARSING_AND_ERR_FLAGS_L4CHKSMWASCALCULATED_SHIFT)) {
 		csum_flag |= PARSING_AND_ERR_FLAGS_L4CHKSMERROR_MASK <<
 			     PARSING_AND_ERR_FLAGS_L4CHKSMERROR_SHIFT;
 		csum = QEDE_CSUM_UNNECESSARY;
@@ -1158,6 +1223,14 @@ static u8 qede_check_csum(u16 flag)
 	return csum;
 }
 
+static u8 qede_check_csum(u16 flag)
+{
+	if (!qede_tunn_exist(flag))
+		return qede_check_notunn_csum(flag);
+	else
+		return qede_check_tunn_csum(flag);
+}
+
 static int qede_rx_int(struct qede_fastpath *fp, int budget)
 {
 	struct qede_dev *edev = fp->edev;
@@ -1987,6 +2060,14 @@ static void qede_init_ndev(struct qede_dev *edev)
 		      NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		      NETIF_F_TSO | NETIF_F_TSO6;
 
+	/* Encap features*/
+	hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
+		       NETIF_F_TSO_ECN;
+	ndev->hw_enc_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+				NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO_ECN |
+				NETIF_F_TSO6 | NETIF_F_GSO_GRE |
+				NETIF_F_GSO_UDP_TUNNEL | NETIF_F_RXCSUM;
+
 	ndev->vlan_features = hw_features | NETIF_F_RXHASH | NETIF_F_RXCSUM |
 			      NETIF_F_HIGHDMA;
 	ndev->features = hw_features | NETIF_F_RXHASH | NETIF_F_RXCSUM |
-- 
2.7.2

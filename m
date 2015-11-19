From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 10/15] bnxt: Convert to advertise NETIF_F_HW_CSUM
Date: Thu, 19 Nov 2015 11:55:56 -0800
Message-ID: <1447962961-2106059-11-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35903 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934429AbbKST4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:19 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAJJsV0w001062
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:19 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y8r6veehe-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:19 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 992c33088ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:18 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_csum_offload_chk is used to resolve checksums that are unable
to be offloaded to the device.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f2d0dc9..eebc9a0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -161,6 +161,16 @@ static const u16 bnxt_lhint_arr[] = {
 	TX_BD_FLAGS_LHINT_2048_AND_LARGER,
 };
 
+static const struct skb_csum_offl_spec csum_offl_spec = {
+	.ipv4_okay = 1,
+	.ip_options_okay = 1,
+	.ipv6_okay = 1,
+	.encap_okay = 1,
+	.vlan_okay = 1,
+	.tcp_okay = 1,
+	.udp_okay = 1,
+};
+
 static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bnxt *bp = netdev_priv(dev);
@@ -176,6 +186,7 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct bnxt_napi *bnapi;
 	struct bnxt_tx_ring_info *txr;
 	struct bnxt_sw_tx_bd *tx_buf;
+	bool csum_encapped;
 
 	i = skb_get_queue_mapping(skb);
 	if (unlikely(i >= bp->tx_nr_rings)) {
@@ -234,7 +245,8 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 					TX_BD_FLAGS_PACKET_END |
 					(2 << TX_BD_FLAGS_BD_CNT_SHIFT));
 
-		if (skb->ip_summed == CHECKSUM_PARTIAL)
+		if (skb_csum_offload_chk(skb, &csum_offl_spec,
+					 &csum_encapped, true))
 			tx_push1->tx_bd_hsize_lflags =
 					cpu_to_le32(TX_BD_FLAGS_TCP_UDP_CHKSUM);
 		else
@@ -323,7 +335,8 @@ normal_tx:
 		length = skb_shinfo(skb)->gso_size;
 		txbd1->tx_bd_mss = cpu_to_le32(length);
 		length += hdr_len;
-	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+	} else if (skb_csum_offload_chk(skb, &csum_offl_spec,
+					&csum_encapped, true)) {
 		txbd1->tx_bd_hsize_lflags =
 			cpu_to_le32(TX_BD_FLAGS_TCP_UDP_CHKSUM);
 		txbd1->tx_bd_mss = 0;
@@ -5629,7 +5642,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
-	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
+	dev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG |
 			   NETIF_F_TSO | NETIF_F_TSO6 |
 			   NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
 			   NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
@@ -5640,7 +5653,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->hw_features |= NETIF_F_NTUPLE;
 
 	dev->hw_enc_features =
-			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
+			NETIF_F_HW_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_TSO6 |
 			NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
 			NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT;
-- 
2.4.6

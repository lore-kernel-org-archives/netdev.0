From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 09/15] bnx2x: Convert to advertise NETIF_F_HW_CSUM
Date: Thu, 19 Nov 2015 11:55:55 -0800
Message-ID: <1447962961-2106059-10-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43739 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934417AbbKST4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:19 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tAJJsZN5018143
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:19 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 1y8rt9ehej-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:19 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 98ba941e8ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:17 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_csum_offload_chk is used to resolve checksums that are unable
to be offloaded to the device.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 15 +++++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  6 +++---
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index d9add7c..f239d34 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3337,13 +3337,24 @@ static __le16 bnx2x_csum_fix(unsigned char *t_header, u16 csum, s8 fix)
 	return bswab16(tsum);
 }
 
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
 static u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 {
 	u32 rc;
 	__u8 prot = 0;
 	__be16 protocol;
+	bool csum_encapped;
 
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
+	if (!skb_csum_offload_chk(skb, &csum_offl_spec, &csum_encapped, true))
 		return XMIT_PLAIN;
 
 	protocol = vlan_get_protocol(skb);
@@ -3355,7 +3366,7 @@ static u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 		prot = ip_hdr(skb)->protocol;
 	}
 
-	if (!CHIP_IS_E1x(bp) && skb->encapsulation) {
+	if (!CHIP_IS_E1x(bp) && csum_encapped) {
 		if (inner_ip_hdr(skb)->version == 6) {
 			rc |= XMIT_CSUM_ENC_V6;
 			if (inner_ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2273576..c3c3d5d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13184,7 +13184,7 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 
 	dev->priv_flags |= IFF_UNICAST_FLT;
 
-	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
 		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO |
 		NETIF_F_RXHASH | NETIF_F_HW_VLAN_CTAG_TX;
@@ -13192,14 +13192,14 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 		dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
 				    NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT;
 		dev->hw_enc_features =
-			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
+			NETIF_F_HW_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
 			NETIF_F_GSO_IPIP |
 			NETIF_F_GSO_SIT |
 			NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL;
 	}
 
-	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+	dev->vlan_features = NETIF_F_SG | NETIF_F_HW_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
 
 	/* VF with OLD Hypervisor or old PF do not support filtering */
-- 
2.4.6

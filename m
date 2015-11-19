From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 13/15] ixgbe: Convert to advertise NETIF_F_HW_CSUM
Date: Thu, 19 Nov 2015 11:55:59 -0800
Message-ID: <1447962961-2106059-14-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54169 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964791AbbKST4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:21 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAJJsGT7022572
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:21 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y8r6u7868-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:21 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 9a7aa1368ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:20 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_csum_offload_chk is used to resolve checksums that are unable
to be offloaded to the device.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 41 +++++++++++++++++++--------
 1 file changed, 29 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 80823f5..26c1633 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6999,15 +6999,28 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 	return 1;
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
 static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
-			  struct ixgbe_tx_buffer *first)
+			  struct ixgbe_tx_buffer *first,
+			  struct ixgbe_adapter *adapter)
 {
 	struct sk_buff *skb = first->skb;
 	u32 vlan_macip_lens = 0;
 	u32 mss_l4len_idx = 0;
 	u32 type_tucmd = 0;
+	bool csum_encapped;
 
-	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+	if (!skb_csum_offload_chk(skb, &csum_offl_spec, &csum_encapped, true)) {
+no_csum:
 		if (!(first->tx_flags & IXGBE_TX_FLAGS_HW_VLAN) &&
 		    !(first->tx_flags & IXGBE_TX_FLAGS_CC))
 			return;
@@ -7025,7 +7038,15 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 			u8 *raw;
 		} transport_hdr;
 
-		if (skb->encapsulation) {
+		if (csum_encapped) {
+			switch (adapter->hw.mac.type) {
+			case ixgbe_mac_X550:
+			case ixgbe_mac_X550EM_x:
+				break;
+			default:
+				skb_checksum_help(skb);
+				goto no_csum;
+			}
 			network_hdr.raw = skb_inner_network_header(skb);
 			transport_hdr.raw = skb_inner_transport_header(skb);
 			vlan_macip_lens = skb_inner_network_offset(skb) <<
@@ -7602,7 +7623,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	if (tso < 0)
 		goto out_drop;
 	else if (!tso)
-		ixgbe_tx_csum(tx_ring, first);
+		ixgbe_tx_csum(tx_ring, first, adapter);
 
 	/* add the ATR filter if ATR is on */
 	if (test_bit(__IXGBE_TX_FDIR_INIT_DONE, &tx_ring->state))
@@ -8765,8 +8786,7 @@ skip_sriov:
 
 #endif
 	netdev->features = NETIF_F_SG |
-			   NETIF_F_IP_CSUM |
-			   NETIF_F_IPV6_CSUM |
+			   NETIF_F_HW_CSUM |
 			   NETIF_F_HW_VLAN_CTAG_TX |
 			   NETIF_F_HW_VLAN_CTAG_RX |
 			   NETIF_F_TSO |
@@ -8794,12 +8814,10 @@ skip_sriov:
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
-	netdev->vlan_features |= NETIF_F_IP_CSUM;
-	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
+	netdev->vlan_features |= NETIF_F_HW_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
-	netdev->hw_enc_features |= NETIF_F_SG | NETIF_F_IP_CSUM |
-				   NETIF_F_IPV6_CSUM;
+	netdev->hw_enc_features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
@@ -8809,8 +8827,7 @@ skip_sriov:
 	case ixgbe_mac_X550:
 	case ixgbe_mac_X550EM_x:
 		netdev->hw_enc_features |= NETIF_F_RXCSUM |
-					   NETIF_F_IP_CSUM |
-					   NETIF_F_IPV6_CSUM;
+					   NETIF_F_HW_CSUM;
 		break;
 	default:
 		break;
-- 
2.4.6

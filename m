From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 15/15] qlogic: Convert to advertise NETIF_F_HW_CSUM
Date: Thu, 19 Nov 2015 11:56:01 -0800
Message-ID: <1447962961-2106059-16-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38835 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964812AbbKST4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:23 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tAJJrA8S032534
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:23 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1y8rtt6ncu-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:23 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 9b57a0228ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:21 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_csum_offload_chk is used to resolve checksums that are unable
to be offloaded to the device.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c   | 10 +++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c   | 16 ++++++++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 10 ++++------
 3 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 509b596..380b621 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -1044,8 +1044,7 @@ static netdev_features_t qlcnic_process_flags(struct qlcnic_adapter *adapter,
 	u32 offload_flags = adapter->offload_flags;
 
 	if (offload_flags & BIT_0) {
-		features |= NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
-			    NETIF_F_IPV6_CSUM;
+		features |= NETIF_F_RXCSUM | NETIF_F_HW_CSUM;
 		adapter->rx_csum = 1;
 		if (QLCNIC_IS_TSO_CAPABLE(adapter)) {
 			if (!(offload_flags & BIT_1))
@@ -1059,9 +1058,7 @@ static netdev_features_t qlcnic_process_flags(struct qlcnic_adapter *adapter,
 				features |= NETIF_F_TSO6;
 		}
 	} else {
-		features &= ~(NETIF_F_RXCSUM |
-			      NETIF_F_IP_CSUM |
-			      NETIF_F_IPV6_CSUM);
+		features &= ~(NETIF_F_RXCSUM | NETIF_F_HW_CSUM);
 
 		if (QLCNIC_IS_TSO_CAPABLE(adapter))
 			features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
@@ -1084,8 +1081,7 @@ netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 		} else {
 			changed = features ^ netdev->features;
 			features ^= changed & (NETIF_F_RXCSUM |
-					       NETIF_F_IP_CSUM |
-					       NETIF_F_IPV6_CSUM |
+					       NETIF_F_HW_CSUM |
 					       NETIF_F_TSO |
 					       NETIF_F_TSO6);
 		}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 7bd6f25..1165ac2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -368,6 +368,16 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 #define QLCNIC_ENCAP_DO_L3_CSUM		BIT_4
 #define QLCNIC_ENCAP_DO_L4_CSUM		BIT_5
 
+static const struct skb_csum_offl_spec csum_offl_encap_spec = {
+	.ipv4_okay = 1,
+	.ip_options_okay = 1,
+	.vlan_okay = 1,
+	.tcp_okay = 1,
+	.udp_okay = 1,
+	.encap_okay = 1,
+	.no_not_encapped = 1,
+};
+
 static int qlcnic_tx_encap_pkt(struct qlcnic_adapter *adapter,
 			       struct cmd_desc_type0 *first_desc,
 			       struct sk_buff *skb,
@@ -378,6 +388,7 @@ static int qlcnic_tx_encap_pkt(struct qlcnic_adapter *adapter,
 	u32 producer = tx_ring->producer;
 	struct cmd_desc_type0 *hwdesc;
 	u16 flags = 0, encap_descr = 0;
+	bool csum_encapped;
 
 	opcode = QLCNIC_TX_ETHER_PKT;
 	encap_descr = QLCNIC_ENCAP_VXLAN_PKT;
@@ -423,7 +434,8 @@ static int qlcnic_tx_encap_pkt(struct qlcnic_adapter *adapter,
 		adapter->stats.encap_lso_frames++;
 
 		opcode = QLCNIC_TX_ENCAP_LSO;
-	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+	} else if (skb_csum_offload_chk(skb, &csum_offl_encap_spec,
+					&csum_encapped, true)) {
 		if (inner_ip_hdr(skb)->version == 6) {
 			if (inner_ipv6_hdr(skb)->nexthdr == IPPROTO_UDP)
 				encap_descr |= QLCNIC_ENCAP_INNER_L4_UDP;
@@ -552,7 +564,7 @@ set_flags:
 		smp_mb();
 		adapter->stats.lso_frames++;
 
-	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+	} else if (skb_csum_off_chk_help_cmn(skb)) {
 		if (protocol == ETH_P_IP) {
 			l4proto = ip_hdr(skb)->protocol;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1205f6f..301ee8f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2301,11 +2301,9 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 	netdev->ethtool_ops = (qlcnic_sriov_vf_check(adapter)) ?
 		&qlcnic_sriov_vf_ethtool_ops : &qlcnic_ethtool_ops;
 
-	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-			     NETIF_F_IPV6_CSUM | NETIF_F_GRO |
-			     NETIF_F_HW_VLAN_CTAG_RX);
-	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
-				  NETIF_F_IPV6_CSUM);
+	netdev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
+			     NETIF_F_GRO | NETIF_F_HW_VLAN_CTAG_RX);
+	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_HW_CSUM);
 
 	if (QLCNIC_IS_TSO_CAPABLE(adapter)) {
 		netdev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
@@ -2330,7 +2328,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 		netdev->features |= NETIF_F_GSO_UDP_TUNNEL;
 
 		/* encapsulation Tx offload supported by Adapter */
-		netdev->hw_enc_features = NETIF_F_IP_CSUM        |
+		netdev->hw_enc_features = NETIF_F_HW_CSUM        |
 					  NETIF_F_GSO_UDP_TUNNEL |
 					  NETIF_F_TSO            |
 					  NETIF_F_TSO6;
-- 
2.4.6

From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 11/15] emulex: Convert to advertise NETIF_F_HW_CSUM
Date: Thu, 19 Nov 2015 11:55:57 -0800
Message-ID: <1447962961-2106059-12-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41455 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161019AbbKST4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:20 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tAJJrA8P032534
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:20 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1y8rtt6nch-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:20 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 99ae85108ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:19 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_csum_offload_chk is used to resolve checksums that are unable
to be offloaded to the device.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_main.c | 30 +++++++++++++++++++++--------
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index d463563..7f7344e 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -480,6 +480,7 @@ struct be_wrb_params {
 	u32 features;	/* Feature bits */
 	u16 vlan_tag;	/* VLAN tag */
 	u16 lso_mss;	/* MSS for LSO */
+	u32 encapped_csum : 1;
 };
 
 struct be_adapter {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 34e324f..01a8642 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -678,7 +678,8 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
 	netdev_info(netdev, "Link is %s\n", link_status ? "Up" : "Down");
 }
 
-static void be_tx_stats_update(struct be_tx_obj *txo, struct sk_buff *skb)
+static void be_tx_stats_update(struct be_tx_obj *txo, struct sk_buff *skb,
+			       bool encapped_csum)
 {
 	struct be_tx_stats *stats = tx_stats(txo);
 	u64 tx_pkts = skb_shinfo(skb)->gso_segs ? : 1;
@@ -687,7 +688,7 @@ static void be_tx_stats_update(struct be_tx_obj *txo, struct sk_buff *skb)
 	stats->tx_reqs++;
 	stats->tx_bytes += skb->len;
 	stats->tx_pkts += tx_pkts;
-	if (skb->encapsulation && skb->ip_summed == CHECKSUM_PARTIAL)
+	if (encapped_csum)
 		stats->tx_vxlan_offload_pkts += tx_pkts;
 	u64_stats_update_end(&stats->sync);
 }
@@ -762,19 +763,32 @@ static inline bool be_is_tx_compl_pending(struct be_tx_obj *txo)
 	return atomic_read(&txo->q.used) > txo->pend_wrb_cnt;
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
 static void be_get_wrb_params_from_skb(struct be_adapter *adapter,
 				       struct sk_buff *skb,
 				       struct be_wrb_params *wrb_params)
 {
 	u16 proto;
+	bool csum_encapped;
 
 	if (skb_is_gso(skb)) {
 		BE_WRB_F_SET(wrb_params->features, LSO, 1);
 		wrb_params->lso_mss = skb_shinfo(skb)->gso_size;
 		if (skb_is_gso_v6(skb) && !lancer_chip(adapter))
 			BE_WRB_F_SET(wrb_params->features, LSO6, 1);
-	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		if (skb->encapsulation) {
+	} else if (skb_csum_offload_chk(skb, &csum_offl_spec,
+					&csum_encapped, true)) {
+		wrb_params->encapped_csum = csum_encapped;
+		if (csum_encapped) {
 			BE_WRB_F_SET(wrb_params->features, IPCS, 1);
 			proto = skb_inner_ip_proto(skb);
 		} else {
@@ -960,7 +974,7 @@ static u32 be_xmit_enqueue(struct be_adapter *adapter, struct be_tx_obj *txo,
 
 	be_tx_setup_wrb_hdr(adapter, txo, wrb_params, skb, head);
 
-	be_tx_stats_update(txo, skb);
+	be_tx_stats_update(txo, skb, !!wrb_params->encapped_csum);
 	return wrb_cnt;
 
 dma_err:
@@ -5215,7 +5229,7 @@ static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 	adapter->flags |= BE_FLAGS_VXLAN_OFFLOADS;
 	adapter->vxlan_port = port;
 
-	netdev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+	netdev->hw_enc_features |= NETIF_F_HW_CSUM |
 				   NETIF_F_TSO | NETIF_F_TSO6 |
 				   NETIF_F_GSO_UDP_TUNNEL;
 	netdev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
@@ -5354,7 +5368,7 @@ static void be_netdev_init(struct net_device *netdev)
 	struct be_adapter *adapter = netdev_priv(netdev);
 
 	netdev->hw_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
-		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM |
+		NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
 		NETIF_F_HW_VLAN_CTAG_TX;
 	if (be_multi_rxq(adapter))
 		netdev->hw_features |= NETIF_F_RXHASH;
@@ -5363,7 +5377,7 @@ static void be_netdev_init(struct net_device *netdev)
 		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	netdev->vlan_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
-		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+		NETIF_F_HW_CSUM;
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
-- 
2.4.6

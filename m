From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 10/11] ixgbe/ixgbevf: Add support for GSO partial
Date: Thu, 07 Apr 2016 18:32:55 -0400
Message-ID: <20160407223255.11142.35250.stgit@ahduyck-xeon-server>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35397 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932303AbcDGWc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:32:59 -0400
Received: by mail-pa0-f48.google.com with SMTP id td3so62601695pab.2
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 15:32:59 -0700 (PDT)
In-Reply-To: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for partial GSO segmentation in the case of
encapsulated frames.  Specifically with this change the driver can perform
segmentation as long as the type is either SKB_GSO_TCP_FIXEDID or
SKB_GSO_TCPV6.  If neither of these gso types are specified then tunnel
segmentation is not supported and we will default back to GSO.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  115 +++++++++++++++-----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  122 ++++++++++++++++-----
 2 files changed, 180 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c6bd3ae5f986..57e083f6c8a9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7195,9 +7195,18 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 		     struct ixgbe_tx_buffer *first,
 		     u8 *hdr_len)
 {
+	u32 vlan_macip_lens, type_tucmd, mss_l4len_idx;
 	struct sk_buff *skb = first->skb;
-	u32 vlan_macip_lens, type_tucmd;
-	u32 mss_l4len_idx, l4len;
+	union {
+		struct iphdr *v4;
+		struct ipv6hdr *v6;
+		unsigned char *hdr;
+	} ip;
+	union {
+		struct tcphdr *tcp;
+		unsigned char *hdr;
+	} l4;
+	u32 paylen, l4_offset;
 	int err;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
@@ -7210,46 +7219,52 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 	if (err < 0)
 		return err;
 
+	ip.hdr = skb_network_header(skb);
+	l4.hdr = skb_checksum_start(skb);
+
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_TCP;
 
-	if (first->protocol == htons(ETH_P_IP)) {
-		struct iphdr *iph = ip_hdr(skb);
-		iph->tot_len = 0;
-		iph->check = 0;
-		tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-							 iph->daddr, 0,
-							 IPPROTO_TCP,
-							 0);
+	/* initialize outer IP header fields */
+	if (ip.v4->version == 4) {
+		/* IP header will have to cancel out any data that
+		 * is not a part of the outer IP header
+		 */
+		ip.v4->check = csum_fold(csum_add(lco_csum(skb),
+						  csum_unfold(l4.tcp->check)));
 		type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
+
+		ip.v4->tot_len = 0;
 		first->tx_flags |= IXGBE_TX_FLAGS_TSO |
 				   IXGBE_TX_FLAGS_CSUM |
 				   IXGBE_TX_FLAGS_IPV4;
-	} else if (skb_is_gso_v6(skb)) {
-		ipv6_hdr(skb)->payload_len = 0;
-		tcp_hdr(skb)->check =
-		    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-				     &ipv6_hdr(skb)->daddr,
-				     0, IPPROTO_TCP, 0);
+	} else {
+		ip.v6->payload_len = 0;
 		first->tx_flags |= IXGBE_TX_FLAGS_TSO |
 				   IXGBE_TX_FLAGS_CSUM;
 	}
 
-	/* compute header lengths */
-	l4len = tcp_hdrlen(skb);
-	*hdr_len = skb_transport_offset(skb) + l4len;
+	/* determine offset of inner transport header */
+	l4_offset = l4.hdr - skb->data;
+
+	/* compute length of segmentation header */
+	*hdr_len = (l4.tcp->doff * 4) + l4_offset;
+
+	/* remove payload length from inner checksum */
+	paylen = skb->len - l4_offset;
+	csum_replace_by_diff(&l4.tcp->check, htonl(paylen));
 
 	/* update gso size and bytecount with header size */
 	first->gso_segs = skb_shinfo(skb)->gso_segs;
 	first->bytecount += (first->gso_segs - 1) * *hdr_len;
 
 	/* mss_l4len_id: use 0 as index for TSO */
-	mss_l4len_idx = l4len << IXGBE_ADVTXD_L4LEN_SHIFT;
+	mss_l4len_idx = (*hdr_len - l4_offset) << IXGBE_ADVTXD_L4LEN_SHIFT;
 	mss_l4len_idx |= skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT;
 
 	/* vlan_macip_lens: HEADLEN, MACLEN, VLAN tag */
-	vlan_macip_lens = skb_network_header_len(skb);
-	vlan_macip_lens |= skb_network_offset(skb) << IXGBE_ADVTXD_MACLEN_SHIFT;
+	vlan_macip_lens = l4.hdr - ip.hdr;
+	vlan_macip_lens |= (ip.hdr - skb->data) << IXGBE_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
 
 	ixgbe_tx_ctxtdesc(tx_ring, vlan_macip_lens, 0, type_tucmd,
@@ -8906,17 +8921,49 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	kfree(fwd_adapter);
 }
 
-#define IXGBE_MAX_TUNNEL_HDR_LEN 80
+#define IXGBE_MAX_MAC_HDR_LEN		127
+#define IXGBE_MAX_NETWORK_HDR_LEN	511
+#define IXGBE_GSO_PARTIAL_FEATURES (NETIF_F_TSO_FIXEDID | \
+				    NETIF_F_GSO_GRE | \
+				    NETIF_F_GSO_GRE_CSUM | \
+				    NETIF_F_GSO_IPIP | \
+				    NETIF_F_GSO_SIT | \
+				    NETIF_F_GSO_UDP_TUNNEL | \
+				    NETIF_F_GSO_UDP_TUNNEL_CSUM)
+
 static netdev_features_t
 ixgbe_features_check(struct sk_buff *skb, struct net_device *dev,
 		     netdev_features_t features)
 {
-	if (!skb->encapsulation)
-		return features;
-
-	if (unlikely(skb_inner_mac_header(skb) - skb_transport_header(skb) >
-		     IXGBE_MAX_TUNNEL_HDR_LEN))
-		return features & ~NETIF_F_CSUM_MASK;
+	unsigned int network_hdr_len, mac_hdr_len;
+
+	/* Make certain the headers can be described by a context descriptor */
+	mac_hdr_len = skb_network_header(skb) - skb->data;
+	network_hdr_len = skb_checksum_start(skb) - skb_network_header(skb);
+	if (unlikely((mac_hdr_len > IXGBE_MAX_MAC_HDR_LEN) ||
+		     (network_hdr_len >  IXGBE_MAX_NETWORK_HDR_LEN)))
+		return features & ~(NETIF_F_HW_CSUM |
+				    NETIF_F_SCTP_CRC |
+				    NETIF_F_HW_VLAN_CTAG_TX |
+				    NETIF_F_TSO |
+				    NETIF_F_TSO_FIXEDID |
+				    NETIF_F_TSO6);
+
+	/* We can only support a fixed IPv4 ID or IPv6 header for TSO
+	 * with tunnels.  So if we aren't using a tunnel, or we aren't
+	 * performing TSO with a fixed ID we must strip the partial
+	 * features.
+	 */
+	if (!(skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
+					   SKB_GSO_GRE_CSUM |
+					   SKB_GSO_IPIP |
+					   SKB_GSO_SIT |
+					   SKB_GSO_UDP_TUNNEL |
+					   SKB_GSO_UDP_TUNNEL_CSUM)) ||
+	    !(skb_shinfo(skb)->gso_type & (SKB_GSO_TCP_FIXEDID |
+					   SKB_GSO_TCPV6)))
+		return features & ~(NETIF_F_GSO_PARTIAL |
+				    IXGBE_GSO_PARTIAL_FEATURES);
 
 	return features;
 }
@@ -9288,6 +9335,10 @@ skip_sriov:
 			   NETIF_F_HW_VLAN_CTAG_RX |
 			   NETIF_F_HW_VLAN_CTAG_FILTER;
 
+	netdev->gso_partial_features = IXGBE_GSO_PARTIAL_FEATURES;
+	netdev->features |= NETIF_F_GSO_PARTIAL |
+			    IXGBE_GSO_PARTIAL_FEATURES;
+
 	if (hw->mac.type >= ixgbe_mac_82599EB)
 		netdev->features |= NETIF_F_SCTP_CRC;
 
@@ -9307,7 +9358,11 @@ skip_sriov:
 				 NETIF_F_SCTP_CRC;
 
 	netdev->mpls_features |= NETIF_F_HW_CSUM;
-	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
+	netdev->hw_enc_features |= NETIF_F_HW_CSUM |
+				   NETIF_F_TSO |
+				   NETIF_F_TSO6 |
+				   NETIF_F_GSO_PARTIAL |
+				   IXGBE_GSO_PARTIAL_FEATURES;
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 007cbe094990..9c8ff4f69463 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3272,9 +3272,18 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 		       struct ixgbevf_tx_buffer *first,
 		       u8 *hdr_len)
 {
+	u32 vlan_macip_lens, type_tucmd, mss_l4len_idx;
 	struct sk_buff *skb = first->skb;
-	u32 vlan_macip_lens, type_tucmd;
-	u32 mss_l4len_idx, l4len;
+	union {
+		struct iphdr *v4;
+		struct ipv6hdr *v6;
+		unsigned char *hdr;
+	} ip;
+	union {
+		struct tcphdr *tcp;
+		unsigned char *hdr;
+	} l4;
+	u32 paylen, l4_offset;
 	int err;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
@@ -3287,49 +3296,53 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 	if (err < 0)
 		return err;
 
+	ip.hdr = skb_network_header(skb);
+	l4.hdr = skb_checksum_start(skb);
+
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_TCP;
 
-	if (first->protocol == htons(ETH_P_IP)) {
-		struct iphdr *iph = ip_hdr(skb);
-
-		iph->tot_len = 0;
-		iph->check = 0;
-		tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-							 iph->daddr, 0,
-							 IPPROTO_TCP,
-							 0);
+	/* initialize outer IP header fields */
+	if (ip.v4->version == 4) {
+		/* IP header will have to cancel out any data that
+		 * is not a part of the outer IP header
+		 */
+		ip.v4->check = csum_fold(csum_add(lco_csum(skb),
+						  csum_unfold(l4.tcp->check)));
 		type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
+
+		ip.v4->tot_len = 0;
 		first->tx_flags |= IXGBE_TX_FLAGS_TSO |
 				   IXGBE_TX_FLAGS_CSUM |
 				   IXGBE_TX_FLAGS_IPV4;
-	} else if (skb_is_gso_v6(skb)) {
-		ipv6_hdr(skb)->payload_len = 0;
-		tcp_hdr(skb)->check =
-		    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-				     &ipv6_hdr(skb)->daddr,
-				     0, IPPROTO_TCP, 0);
+	} else {
+		ip.v6->payload_len = 0;
 		first->tx_flags |= IXGBE_TX_FLAGS_TSO |
 				   IXGBE_TX_FLAGS_CSUM;
 	}
 
-	/* compute header lengths */
-	l4len = tcp_hdrlen(skb);
-	*hdr_len += l4len;
-	*hdr_len = skb_transport_offset(skb) + l4len;
+	/* determine offset of inner transport header */
+	l4_offset = l4.hdr - skb->data;
+
+	/* compute length of segmentation header */
+	*hdr_len = (l4.tcp->doff * 4) + l4_offset;
+
+	/* remove payload length from inner checksum */
+	paylen = skb->len - l4_offset;
+	csum_replace_by_diff(&l4.tcp->check, htonl(paylen));
 
-	/* update GSO size and bytecount with header size */
+	/* update gso size and bytecount with header size */
 	first->gso_segs = skb_shinfo(skb)->gso_segs;
 	first->bytecount += (first->gso_segs - 1) * *hdr_len;
 
 	/* mss_l4len_id: use 1 as index for TSO */
-	mss_l4len_idx = l4len << IXGBE_ADVTXD_L4LEN_SHIFT;
+	mss_l4len_idx = (*hdr_len - l4_offset) << IXGBE_ADVTXD_L4LEN_SHIFT;
 	mss_l4len_idx |= skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT;
 	mss_l4len_idx |= 1 << IXGBE_ADVTXD_IDX_SHIFT;
 
 	/* vlan_macip_lens: HEADLEN, MACLEN, VLAN tag */
-	vlan_macip_lens = skb_network_header_len(skb);
-	vlan_macip_lens |= skb_network_offset(skb) << IXGBE_ADVTXD_MACLEN_SHIFT;
+	vlan_macip_lens = l4.hdr - ip.hdr;
+	vlan_macip_lens |= (ip.hdr - skb->data) << IXGBE_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
 
 	ixgbevf_tx_ctxtdesc(tx_ring, vlan_macip_lens,
@@ -3870,6 +3883,53 @@ static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
 	return stats;
 }
 
+#define IXGBEVF_MAX_MAC_HDR_LEN		127
+#define IXGBEVF_MAX_NETWORK_HDR_LEN	511
+#define IXGBEVF_GSO_PARTIAL_FEATURES (NETIF_F_TSO_FIXEDID | \
+				      NETIF_F_GSO_GRE | \
+				      NETIF_F_GSO_GRE_CSUM | \
+				      NETIF_F_GSO_IPIP | \
+				      NETIF_F_GSO_SIT | \
+				      NETIF_F_GSO_UDP_TUNNEL | \
+				      NETIF_F_GSO_UDP_TUNNEL_CSUM)
+
+static netdev_features_t
+ixgbevf_features_check(struct sk_buff *skb, struct net_device *dev,
+		       netdev_features_t features)
+{
+	unsigned int network_hdr_len, mac_hdr_len;
+
+	/* Make certain the headers can be described by a context descriptor */
+	mac_hdr_len = skb_network_header(skb) - skb->data;
+	network_hdr_len = skb_checksum_start(skb) - skb_network_header(skb);
+	if (unlikely((mac_hdr_len > IXGBEVF_MAX_MAC_HDR_LEN) ||
+		     (network_hdr_len >  IXGBEVF_MAX_NETWORK_HDR_LEN)))
+		return features & ~(NETIF_F_HW_CSUM |
+				    NETIF_F_SCTP_CRC |
+				    NETIF_F_HW_VLAN_CTAG_TX |
+				    NETIF_F_TSO |
+				    NETIF_F_TSO_FIXEDID |
+				    NETIF_F_TSO6);
+
+	/* We can only support a fixed IPv4 ID or IPv6 header for TSO
+	 * with tunnels.  So if we aren't using a tunnel, or we aren't
+	 * performing TSO with a fixed ID we must strip the partial
+	 * features.
+	 */
+	if (!(skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
+					   SKB_GSO_GRE_CSUM |
+					   SKB_GSO_IPIP |
+					   SKB_GSO_SIT |
+					   SKB_GSO_UDP_TUNNEL |
+					   SKB_GSO_UDP_TUNNEL_CSUM)) ||
+	    !(skb_shinfo(skb)->gso_type & (SKB_GSO_TCP_FIXEDID |
+					   SKB_GSO_TCPV6)))
+		return features & ~(NETIF_F_GSO_PARTIAL |
+				    IXGBEVF_GSO_PARTIAL_FEATURES);
+
+	return features;
+}
+
 static const struct net_device_ops ixgbevf_netdev_ops = {
 	.ndo_open		= ixgbevf_open,
 	.ndo_stop		= ixgbevf_close,
@@ -3888,7 +3948,7 @@ static const struct net_device_ops ixgbevf_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbevf_netpoll,
 #endif
-	.ndo_features_check	= passthru_features_check,
+	.ndo_features_check	= ixgbevf_features_check,
 };
 
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
@@ -3999,6 +4059,10 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			      NETIF_F_HW_CSUM |
 			      NETIF_F_SCTP_CRC;
 
+	netdev->gso_partial_features = IXGBEVF_GSO_PARTIAL_FEATURES;
+	netdev->hw_features |= NETIF_F_GSO_PARTIAL |
+			       IXGBEVF_GSO_PARTIAL_FEATURES;
+
 	netdev->features = netdev->hw_features |
 			   NETIF_F_HW_VLAN_CTAG_TX |
 			   NETIF_F_HW_VLAN_CTAG_RX |
@@ -4011,7 +4075,11 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				 NETIF_F_SCTP_CRC;
 
 	netdev->mpls_features |= NETIF_F_HW_CSUM;
-	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
+	netdev->hw_enc_features |= NETIF_F_HW_CSUM |
+				   NETIF_F_TSO |
+				   NETIF_F_TSO6 |
+				   NETIF_F_GSO_PARTIAL |
+				   IXGBEVF_GSO_PARTIAL_FEATURES;
 
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;

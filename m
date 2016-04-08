From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next-queue PATCH 2/3] ixgbe/ixgbevf: Add support for GSO partial
Date: Fri, 08 Apr 2016 17:06:48 -0400
Message-ID: <20160408210647.13096.55323.stgit@ahduyck-xeon-server>
References: <20160408210103.13096.77973.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36388 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758920AbcDHVGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 17:06:52 -0400
Received: by mail-pf0-f180.google.com with SMTP id e128so82469581pfe.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 14:06:52 -0700 (PDT)
In-Reply-To: <20160408210103.13096.77973.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for partial GSO segmentation in the case of
tunnels.  Specifically with this change the driver an perform segmenation
as long as the frame either has IPv6 inner headers, or we are allowed to
mangle the IP IDs on the inner header.  This is needed because we will not
be modifying any fields from the start of the start of the outer transport
header to the start of the inner transport header as we are treating them
like they are just a block of IP options.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  105 +++++++++++++-----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  123 ++++++++++++++++-----
 2 files changed, 172 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 974aa7ca7a12..5134cb97f33c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7216,9 +7216,18 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
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
@@ -7231,46 +7240,52 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
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
@@ -8614,6 +8629,14 @@ static int ixgbe_set_features(struct net_device *netdev,
 	if (changed & NETIF_F_RXALL)
 		need_reset = true;
 
+	/* We can only support IPV4 TSO in tunnels if we can mangle the
+	 * inner IP ID field, so strip TSO if MANGLEID is not supported.
+	 */
+	if (features & NETIF_F_TSO_MANGLEID)
+		netdev->hw_enc_features |= NETIF_F_TSO;
+	else
+		netdev->hw_enc_features &= ~NETIF_F_TSO;
+
 	netdev->features = features;
 
 #ifdef CONFIG_IXGBE_VXLAN
@@ -8927,17 +8950,25 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	kfree(fwd_adapter);
 }
 
-#define IXGBE_MAX_TUNNEL_HDR_LEN 80
+#define IXGBE_MAX_MAC_HDR_LEN		127
+#define IXGBE_MAX_NETWORK_HDR_LEN	511
+
 static netdev_features_t
 ixgbe_features_check(struct sk_buff *skb, struct net_device *dev,
 		     netdev_features_t features)
 {
-	if (!skb->encapsulation)
-		return features;
+	unsigned int network_hdr_len, mac_hdr_len;
 
-	if (unlikely(skb_inner_mac_header(skb) - skb_transport_header(skb) >
-		     IXGBE_MAX_TUNNEL_HDR_LEN))
-		return features & ~NETIF_F_CSUM_MASK;
+	/* Make certain the headers can be described by a context descriptor */
+	mac_hdr_len = skb_network_header(skb) - skb->data;
+	network_hdr_len = skb_checksum_start(skb) - skb_network_header(skb);
+	if (unlikely((mac_hdr_len > IXGBE_MAX_MAC_HDR_LEN) ||
+		     (network_hdr_len >  IXGBE_MAX_NETWORK_HDR_LEN)))
+		return features & ~(NETIF_F_HW_CSUM |
+				    NETIF_F_SCTP_CRC |
+				    NETIF_F_HW_VLAN_CTAG_TX |
+				    NETIF_F_TSO |
+				    NETIF_F_TSO6);
 
 	return features;
 }
@@ -9309,6 +9340,17 @@ skip_sriov:
 			   NETIF_F_HW_VLAN_CTAG_RX |
 			   NETIF_F_HW_VLAN_CTAG_FILTER;
 
+#define IXGBE_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
+				    NETIF_F_GSO_GRE_CSUM | \
+				    NETIF_F_GSO_IPIP | \
+				    NETIF_F_GSO_SIT | \
+				    NETIF_F_GSO_UDP_TUNNEL | \
+				    NETIF_F_GSO_UDP_TUNNEL_CSUM)
+
+	netdev->gso_partial_features = IXGBE_GSO_PARTIAL_FEATURES;
+	netdev->features |= NETIF_F_GSO_PARTIAL |
+			    IXGBE_GSO_PARTIAL_FEATURES;
+
 	if (hw->mac.type >= ixgbe_mac_82599EB)
 		netdev->features |= NETIF_F_SCTP_CRC;
 
@@ -9323,12 +9365,17 @@ skip_sriov:
 
 	netdev->vlan_features |= NETIF_F_SG |
 				 NETIF_F_TSO |
+				 NETIF_F_TSO_MANGLEID |
 				 NETIF_F_TSO6 |
 				 NETIF_F_HW_CSUM |
 				 NETIF_F_SCTP_CRC;
 
 	netdev->mpls_features |= NETIF_F_HW_CSUM;
-	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
+	netdev->hw_enc_features |= NETIF_F_HW_CSUM |
+				   NETIF_F_TSO_MANGLEID |
+				   NETIF_F_TSO6 |
+				   NETIF_F_GSO_PARTIAL |
+				   IXGBE_GSO_PARTIAL_FEATURES;
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 007cbe094990..e4f471787dd4 100644
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
 
-	/* update GSO size and bytecount with header size */
+	/* remove payload length from inner checksum */
+	paylen = skb->len - l4_offset;
+	csum_replace_by_diff(&l4.tcp->check, htonl(paylen));
+
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
@@ -3870,6 +3883,45 @@ static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
 	return stats;
 }
 
+static int ixgbevf_set_features(struct net_device *netdev,
+				netdev_features_t features)
+{
+	/* We can only support IPV4 TSO in tunnels if we can mangle the
+	 * inner IP ID field, so strip TSO if MANGLEID is not supported.
+	 */
+	if (features & NETIF_F_TSO_MANGLEID)
+		netdev->hw_enc_features |= NETIF_F_TSO;
+	else
+		netdev->hw_enc_features &= ~NETIF_F_TSO;
+
+	netdev->features = features;
+
+	return 0;
+}
+
+#define IXGBEVF_MAX_MAC_HDR_LEN		127
+#define IXGBEVF_MAX_NETWORK_HDR_LEN	511
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
+				    NETIF_F_TSO6);
+
+	return features;
+}
+
 static const struct net_device_ops ixgbevf_netdev_ops = {
 	.ndo_open		= ixgbevf_open,
 	.ndo_stop		= ixgbevf_close,
@@ -3888,7 +3940,8 @@ static const struct net_device_ops ixgbevf_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbevf_netpoll,
 #endif
-	.ndo_features_check	= passthru_features_check,
+	.ndo_set_features	= ixgbevf_set_features,
+	.ndo_features_check	= ixgbevf_features_check,
 };
 
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
@@ -3999,6 +4052,17 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			      NETIF_F_HW_CSUM |
 			      NETIF_F_SCTP_CRC;
 
+#define IXGBEVF_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
+				      NETIF_F_GSO_GRE_CSUM | \
+				      NETIF_F_GSO_IPIP | \
+				      NETIF_F_GSO_SIT | \
+				      NETIF_F_GSO_UDP_TUNNEL | \
+				      NETIF_F_GSO_UDP_TUNNEL_CSUM)
+
+	netdev->gso_partial_features = IXGBEVF_GSO_PARTIAL_FEATURES;
+	netdev->hw_features |= NETIF_F_GSO_PARTIAL |
+			       IXGBEVF_GSO_PARTIAL_FEATURES;
+
 	netdev->features = netdev->hw_features |
 			   NETIF_F_HW_VLAN_CTAG_TX |
 			   NETIF_F_HW_VLAN_CTAG_RX |
@@ -4006,12 +4070,17 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->vlan_features |= NETIF_F_SG |
 				 NETIF_F_TSO |
+				 NETIF_F_TSO_MANGLEID |
 				 NETIF_F_TSO6 |
 				 NETIF_F_HW_CSUM |
 				 NETIF_F_SCTP_CRC;
 
 	netdev->mpls_features |= NETIF_F_HW_CSUM;
-	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
+	netdev->hw_enc_features |= NETIF_F_HW_CSUM |
+				   NETIF_F_TSO_MANGLEID |
+				   NETIF_F_TSO6 |
+				   NETIF_F_GSO_PARTIAL |
+				   IXGBEVF_GSO_PARTIAL_FEATURES;
 
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;

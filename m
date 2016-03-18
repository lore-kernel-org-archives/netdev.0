From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 9/9] ixgbe/ixgbevf: Add support for GSO partial
Date: Fri, 18 Mar 2016 16:25:35 -0700
Message-ID: <20160318232535.14955.19028.stgit@localhost.localdomain>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: ecree@solarflare.com, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35742 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbcCRXZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 19:25:37 -0400
Received: by mail-pf0-f178.google.com with SMTP id n5so186154302pfn.2
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 16:25:37 -0700 (PDT)
In-Reply-To: <20160318230945.14955.63211.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for partial GSO segmentation in the case of GRE or
UDP encapsulated frames.

The one bit in this patch that is a bit controversial is the fact that we
are leaving the inner IPv4 IP ID as a static value in the case of
segmentation.  As per RFC6864 this should be acceptable as TCP frames set
the DF bit so the IP ID should be ignored.  However this is not always the
case as header compression schemes for PPP and SLIP can end up taking a
performance hit as they have to record the fact that the ID didn't change
as expected.

In addition GRO was examining the IP ID field as well.  As such on older
GRO implementations TSO frames from this driver may end up blocking GRO on
the other end which will likely hurt performance instead of helping it.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   72 +++++++++++++-------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   77 ++++++++++++++-------
 2 files changed, 99 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 59b43ce200be..bef69306fb65 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7178,9 +7178,18 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
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
@@ -7193,46 +7202,52 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
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
@@ -9201,6 +9216,14 @@ skip_sriov:
 			   NETIF_F_HW_VLAN_CTAG_RX |
 			   NETIF_F_HW_VLAN_CTAG_FILTER;
 
+	netdev->gso_partial_features = NETIF_F_GSO_GRE |
+				       NETIF_F_GSO_GRE_CSUM |
+				       NETIF_F_GSO_UDP_TUNNEL |
+				       NETIF_F_GSO_UDP_TUNNEL_CSUM;
+
+	netdev->features |= NETIF_F_GSO_PARTIAL |
+			    netdev->gso_partial_features;
+
 	if (hw->mac.type >= ixgbe_mac_82599EB)
 		netdev->features |= NETIF_F_SCTP_CRC;
 
@@ -9219,7 +9242,10 @@ skip_sriov:
 				 NETIF_F_SCTP_CRC;
 
 	netdev->mpls_features |= NETIF_F_HW_CSUM;
-	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
+	netdev->hw_enc_features |= NETIF_F_TSO |
+				   NETIF_F_TSO6 |
+				   NETIF_F_HW_CSUM |
+				   netdev->gso_partial_features;
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 0c3e29b55b45..1ece15ee9834 100644
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
 
-	/* update GSO size and bytecount with header size */
+	/* compute length of segmentation header */
+	*hdr_len = (l4.tcp->doff * 4) + l4_offset;
+
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
@@ -3992,12 +4005,19 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_sw_init;
 	}
 
+	netdev->gso_partial_features = NETIF_F_GSO_GRE |
+				       NETIF_F_GSO_GRE_CSUM |
+				       NETIF_F_GSO_UDP_TUNNEL |
+				       NETIF_F_GSO_UDP_TUNNEL_CSUM;
+
 	netdev->hw_features = NETIF_F_SG |
 			      NETIF_F_TSO |
 			      NETIF_F_TSO6 |
 			      NETIF_F_RXCSUM |
 			      NETIF_F_HW_CSUM |
-			      NETIF_F_SCTP_CRC;
+			      NETIF_F_SCTP_CRC |
+			      NETIF_F_GSO_PARTIAL |
+			      netdev->gso_partial_features;
 
 	netdev->features = netdev->hw_features |
 			   NETIF_F_HW_VLAN_CTAG_TX |
@@ -4011,7 +4031,10 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				 NETIF_F_SCTP_CRC;
 
 	netdev->mpls_features |= NETIF_F_HW_CSUM;
-	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
+	netdev->hw_enc_features |= NETIF_F_TSO |
+				   NETIF_F_TSO6 |
+				   NETIF_F_HW_CSUM |
+				   netdev->gso_partial_features;
 
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;

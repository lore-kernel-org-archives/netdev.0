From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next-queue PATCH 3/3] igb/igbvf: Add support for GSO partial
Date: Fri, 08 Apr 2016 17:06:54 -0400
Message-ID: <20160408210654.13096.11127.stgit@ahduyck-xeon-server>
References: <20160408210103.13096.77973.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33328 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753964AbcDHVG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 17:06:59 -0400
Received: by mail-pf0-f181.google.com with SMTP id 184so82674437pff.0
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 14:06:58 -0700 (PDT)
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
 drivers/net/ethernet/intel/igb/igb_main.c |  112 ++++++++++++++-----
 drivers/net/ethernet/intel/igbvf/netdev.c |  173 ++++++++++++++++++-----------
 2 files changed, 191 insertions(+), 94 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8e96c35307fb..998a24611246 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2055,6 +2055,14 @@ static int igb_set_features(struct net_device *netdev,
 	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		igb_vlan_mode(netdev, features);
 
+	/* We can only support IPV4 TSO in tunnels if we can mangle the
+	 * inner IP ID field, so strip TSO if MANGLEID is not supported.
+	 */
+	if (features & NETIF_F_TSO_MANGLEID)
+		netdev->hw_enc_features |= NETIF_F_TSO;
+	else
+		netdev->hw_enc_features &= ~NETIF_F_TSO;
+
 	if (!(changed & (NETIF_F_RXALL | NETIF_F_NTUPLE)))
 		return 0;
 
@@ -2087,6 +2095,29 @@ static int igb_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return ndo_dflt_fdb_add(ndm, tb, dev, addr, vid, flags);
 }
 
+#define IGB_MAX_MAC_HDR_LEN	127
+#define IGB_MAX_NETWORK_HDR_LEN	511
+
+static netdev_features_t
+igb_features_check(struct sk_buff *skb, struct net_device *dev,
+		   netdev_features_t features)
+{
+	unsigned int network_hdr_len, mac_hdr_len;
+
+	/* Make certain the headers can be described by a context descriptor */
+	mac_hdr_len = skb_network_header(skb) - skb->data;
+	network_hdr_len = skb_checksum_start(skb) - skb_network_header(skb);
+	if (unlikely((mac_hdr_len > IGB_MAX_MAC_HDR_LEN) ||
+		     (network_hdr_len >  IGB_MAX_NETWORK_HDR_LEN)))
+		return features & ~(NETIF_F_HW_CSUM |
+				    NETIF_F_SCTP_CRC |
+				    NETIF_F_HW_VLAN_CTAG_TX |
+				    NETIF_F_TSO |
+				    NETIF_F_TSO6);
+
+	return features;
+}
+
 static const struct net_device_ops igb_netdev_ops = {
 	.ndo_open		= igb_open,
 	.ndo_stop		= igb_close,
@@ -2111,7 +2142,7 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_fix_features	= igb_fix_features,
 	.ndo_set_features	= igb_set_features,
 	.ndo_fdb_add		= igb_ndo_fdb_add,
-	.ndo_features_check	= passthru_features_check,
+	.ndo_features_check	= igb_features_check,
 };
 
 /**
@@ -2384,6 +2415,16 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (hw->mac.type >= e1000_82576)
 		netdev->features |= NETIF_F_SCTP_CRC;
 
+#define IGB_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
+				  NETIF_F_GSO_GRE_CSUM | \
+				  NETIF_F_GSO_IPIP | \
+				  NETIF_F_GSO_SIT | \
+				  NETIF_F_GSO_UDP_TUNNEL | \
+				  NETIF_F_GSO_UDP_TUNNEL_CSUM)
+
+	netdev->gso_partial_features = IGB_GSO_PARTIAL_FEATURES;
+	netdev->features |= NETIF_F_GSO_PARTIAL | IGB_GSO_PARTIAL_FEATURES;
+
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features;
 	netdev->hw_features |= NETIF_F_RXALL;
@@ -2396,19 +2437,22 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
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
+				   IGB_GSO_PARTIAL_FEATURES;
 
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
-	if (pci_using_dac) {
+	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
-		netdev->vlan_features |= NETIF_F_HIGHDMA;
-	}
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
@@ -4842,9 +4886,18 @@ static int igb_tso(struct igb_ring *tx_ring,
 		   struct igb_tx_buffer *first,
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
@@ -4857,45 +4910,52 @@ static int igb_tso(struct igb_ring *tx_ring,
 	if (err < 0)
 		return err;
 
+	ip.hdr = skb_network_header(skb);
+	l4.hdr = skb_checksum_start(skb);
+
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = E1000_ADVTXD_TUCMD_L4T_TCP;
 
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
 		type_tucmd |= E1000_ADVTXD_TUCMD_IPV4;
+
+		ip.v4->tot_len = 0;
 		first->tx_flags |= IGB_TX_FLAGS_TSO |
 				   IGB_TX_FLAGS_CSUM |
 				   IGB_TX_FLAGS_IPV4;
-	} else if (skb_is_gso_v6(skb)) {
-		ipv6_hdr(skb)->payload_len = 0;
-		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-						       &ipv6_hdr(skb)->daddr,
-						       0, IPPROTO_TCP, 0);
+	} else {
+		ip.v6->payload_len = 0;
 		first->tx_flags |= IGB_TX_FLAGS_TSO |
 				   IGB_TX_FLAGS_CSUM;
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
 
 	/* MSS L4LEN IDX */
-	mss_l4len_idx = l4len << E1000_ADVTXD_L4LEN_SHIFT;
+	mss_l4len_idx = (*hdr_len - l4_offset) << E1000_ADVTXD_L4LEN_SHIFT;
 	mss_l4len_idx |= skb_shinfo(skb)->gso_size << E1000_ADVTXD_MSS_SHIFT;
 
 	/* VLAN MACLEN IPLEN */
-	vlan_macip_lens = skb_network_header_len(skb);
-	vlan_macip_lens |= skb_network_offset(skb) << E1000_ADVTXD_MACLEN_SHIFT;
+	vlan_macip_lens = l4.hdr - ip.hdr;
+	vlan_macip_lens |= (ip.hdr - skb->data) << E1000_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IGB_TX_FLAGS_VLAN_MASK;
 
 	igb_tx_ctxtdesc(tx_ring, vlan_macip_lens, type_tucmd, mss_l4len_idx);
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index c12442252adb..cd759c5e09f8 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1933,83 +1933,74 @@ static void igbvf_tx_ctxtdesc(struct igbvf_ring *tx_ring, u32 vlan_macip_lens,
 	buffer_info->dma = 0;
 }
 
-static int igbvf_tso(struct igbvf_adapter *adapter,
-		     struct igbvf_ring *tx_ring,
-		     struct sk_buff *skb, u32 tx_flags, u8 *hdr_len,
-		     __be16 protocol)
-{
-	struct e1000_adv_tx_context_desc *context_desc;
-	struct igbvf_buffer *buffer_info;
-	u32 info = 0, tu_cmd = 0;
-	u32 mss_l4len_idx, l4len;
-	unsigned int i;
+static int igbvf_tso(struct igbvf_ring *tx_ring,
+		     struct sk_buff *skb, u32 tx_flags, u8 *hdr_len)
+{
+	u32 vlan_macip_lens, type_tucmd, mss_l4len_idx;
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
 
-	*hdr_len = 0;
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
+	if (!skb_is_gso(skb))
+		return 0;
 
 	err = skb_cow_head(skb, 0);
-	if (err < 0) {
-		dev_err(&adapter->pdev->dev, "igbvf_tso returning an error\n");
+	if (err < 0)
 		return err;
-	}
 
-	l4len = tcp_hdrlen(skb);
-	*hdr_len += l4len;
-
-	if (protocol == htons(ETH_P_IP)) {
-		struct iphdr *iph = ip_hdr(skb);
-
-		iph->tot_len = 0;
-		iph->check = 0;
-		tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-							 iph->daddr, 0,
-							 IPPROTO_TCP,
-							 0);
-	} else if (skb_is_gso_v6(skb)) {
-		ipv6_hdr(skb)->payload_len = 0;
-		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-						       &ipv6_hdr(skb)->daddr,
-						       0, IPPROTO_TCP, 0);
-	}
+	ip.hdr = skb_network_header(skb);
+	l4.hdr = skb_checksum_start(skb);
 
-	i = tx_ring->next_to_use;
+	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
+	type_tucmd = E1000_ADVTXD_TUCMD_L4T_TCP;
 
-	buffer_info = &tx_ring->buffer_info[i];
-	context_desc = IGBVF_TX_CTXTDESC_ADV(*tx_ring, i);
-	/* VLAN MACLEN IPLEN */
-	if (tx_flags & IGBVF_TX_FLAGS_VLAN)
-		info |= (tx_flags & IGBVF_TX_FLAGS_VLAN_MASK);
-	info |= (skb_network_offset(skb) << E1000_ADVTXD_MACLEN_SHIFT);
-	*hdr_len += skb_network_offset(skb);
-	info |= (skb_transport_header(skb) - skb_network_header(skb));
-	*hdr_len += (skb_transport_header(skb) - skb_network_header(skb));
-	context_desc->vlan_macip_lens = cpu_to_le32(info);
+	/* initialize outer IP header fields */
+	if (ip.v4->version == 4) {
+		/* IP header will have to cancel out any data that
+		 * is not a part of the outer IP header
+		 */
+		ip.v4->check = csum_fold(csum_add(lco_csum(skb),
+						  csum_unfold(l4.tcp->check)));
+		type_tucmd |= E1000_ADVTXD_TUCMD_IPV4;
 
-	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
-	tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
+		ip.v4->tot_len = 0;
+	} else {
+		ip.v6->payload_len = 0;
+	}
 
-	if (protocol == htons(ETH_P_IP))
-		tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
-	tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+	/* determine offset of inner transport header */
+	l4_offset = l4.hdr - skb->data;
 
-	context_desc->type_tucmd_mlhl = cpu_to_le32(tu_cmd);
+	/* compute length of segmentation header */
+	*hdr_len = (l4.tcp->doff * 4) + l4_offset;
 
-	/* MSS L4LEN IDX */
-	mss_l4len_idx = (skb_shinfo(skb)->gso_size << E1000_ADVTXD_MSS_SHIFT);
-	mss_l4len_idx |= (l4len << E1000_ADVTXD_L4LEN_SHIFT);
+	/* remove payload length from inner checksum */
+	paylen = skb->len - l4_offset;
+	csum_replace_by_diff(&l4.tcp->check, htonl(paylen));
 
-	context_desc->mss_l4len_idx = cpu_to_le32(mss_l4len_idx);
-	context_desc->seqnum_seed = 0;
+	/* MSS L4LEN IDX */
+	mss_l4len_idx = (*hdr_len - l4_offset) << E1000_ADVTXD_L4LEN_SHIFT;
+	mss_l4len_idx |= skb_shinfo(skb)->gso_size << E1000_ADVTXD_MSS_SHIFT;
 
-	buffer_info->time_stamp = jiffies;
-	buffer_info->dma = 0;
-	i++;
-	if (i == tx_ring->count)
-		i = 0;
+	/* VLAN MACLEN IPLEN */
+	vlan_macip_lens = l4.hdr - ip.hdr;
+	vlan_macip_lens |= (ip.hdr - skb->data) << E1000_ADVTXD_MACLEN_SHIFT;
+	vlan_macip_lens |= tx_flags & IGBVF_TX_FLAGS_VLAN_MASK;
 
-	tx_ring->next_to_use = i;
+	igbvf_tx_ctxtdesc(tx_ring, vlan_macip_lens, type_tucmd, mss_l4len_idx);
 
-	return true;
+	return 1;
 }
 
 static inline bool igbvf_ipv6_csum_is_sctp(struct sk_buff *skb)
@@ -2271,8 +2262,7 @@ static netdev_tx_t igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
 
 	first = tx_ring->next_to_use;
 
-	tso = skb_is_gso(skb) ?
-		igbvf_tso(adapter, tx_ring, skb, tx_flags, &hdr_len, protocol) : 0;
+	tso = igbvf_tso(tx_ring, skb, tx_flags, &hdr_len);
 	if (unlikely(tso < 0)) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
@@ -2612,9 +2602,40 @@ static int igbvf_set_features(struct net_device *netdev,
 	else
 		adapter->flags |= IGBVF_FLAG_RX_CSUM_DISABLED;
 
+	/* We can only support IPV4 TSO in tunnels if we can mangle the
+	 * inner IP ID field, so strip TSO if MANGLEID is not supported.
+	 */
+	if (features & NETIF_F_TSO_MANGLEID)
+		netdev->hw_enc_features |= NETIF_F_TSO;
+	else
+		netdev->hw_enc_features &= ~NETIF_F_TSO;
+
 	return 0;
 }
 
+#define IGBVF_MAX_MAC_HDR_LEN		127
+#define IGBVF_MAX_NETWORK_HDR_LEN	511
+
+static netdev_features_t
+igbvf_features_check(struct sk_buff *skb, struct net_device *dev,
+		     netdev_features_t features)
+{
+	unsigned int network_hdr_len, mac_hdr_len;
+
+	/* Make certain the headers can be described by a context descriptor */
+	mac_hdr_len = skb_network_header(skb) - skb->data;
+	network_hdr_len = skb_checksum_start(skb) - skb_network_header(skb);
+	if (unlikely((mac_hdr_len > IGBVF_MAX_MAC_HDR_LEN) ||
+		     (network_hdr_len >  IGBVF_MAX_NETWORK_HDR_LEN)))
+		return features & ~(NETIF_F_HW_CSUM |
+				    NETIF_F_SCTP_CRC |
+				    NETIF_F_HW_VLAN_CTAG_TX |
+				    NETIF_F_TSO |
+				    NETIF_F_TSO6);
+
+	return features;
+}
+
 static const struct net_device_ops igbvf_netdev_ops = {
 	.ndo_open		= igbvf_open,
 	.ndo_stop		= igbvf_close,
@@ -2631,7 +2652,7 @@ static const struct net_device_ops igbvf_netdev_ops = {
 	.ndo_poll_controller	= igbvf_netpoll,
 #endif
 	.ndo_set_features	= igbvf_set_features,
-	.ndo_features_check	= passthru_features_check,
+	.ndo_features_check	= igbvf_features_check,
 };
 
 /**
@@ -2739,22 +2760,38 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			      NETIF_F_HW_CSUM |
 			      NETIF_F_SCTP_CRC;
 
+#define IGBVF_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
+				    NETIF_F_GSO_GRE_CSUM | \
+				    NETIF_F_GSO_IPIP | \
+				    NETIF_F_GSO_SIT | \
+				    NETIF_F_GSO_UDP_TUNNEL | \
+				    NETIF_F_GSO_UDP_TUNNEL_CSUM)
+
+	netdev->gso_partial_features = IGBVF_GSO_PARTIAL_FEATURES;
+	netdev->hw_features |= NETIF_F_GSO_PARTIAL |
+			       IGBVF_GSO_PARTIAL_FEATURES;
+
 	netdev->features = netdev->hw_features |
 			   NETIF_F_HW_VLAN_CTAG_TX |
 			   NETIF_F_HW_VLAN_CTAG_RX |
 			   NETIF_F_HW_VLAN_CTAG_FILTER;
 
-	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
-
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
+				   IGBVF_GSO_PARTIAL_FEATURES;
+
+	if (pci_using_dac)
+		netdev->features |= NETIF_F_HIGHDMA;
 
 	/*reset the controller to put the device in a known good state */
 	err = hw->mac.ops.reset_hw(hw);

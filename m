From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: [PATCH 3/3 v2 net-next] enic: add vxlan offload on tx path
Date: Wed,  8 Feb 2017 16:43:09 -0800
Message-ID: <20170209004309.1225-4-gvaradar@cisco.com>
References: <20170209004309.1225-1-gvaradar@cisco.com>
Cc: benve@cisco.com, Govindarajulu Varadarajan <gvaradar@cisco.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-8.cisco.com ([173.37.86.79]:34675 "EHLO
        rcdn-iport-8.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbdBIBY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 20:24:58 -0500
In-Reply-To: <20170209004309.1225-1-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define ndo_features_check. Hw supports offload only for ipv4 inner and
ipv4 outer pkt.

Code refactor for setting inner tcp pseudo csum.

Signed-off-by: Govindarajulu Varadarajan <gvaradar@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 126 +++++++++++++++++++++++++---
 1 file changed, 114 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 7e56bf95cfc7..4b87beeabce1 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -263,6 +263,48 @@ static void enic_udp_tunnel_del(struct net_device *netdev,
 	spin_unlock_bh(&enic->devcmd_lock);
 }
 
+static netdev_features_t enic_features_check(struct sk_buff *skb,
+					     struct net_device *dev,
+					     netdev_features_t features)
+{
+	const struct ethhdr *eth = (struct ethhdr *)skb_inner_mac_header(skb);
+	struct enic *enic = netdev_priv(dev);
+	struct udphdr *udph;
+	u16 port = 0;
+	u16 proto;
+
+	if (!skb->encapsulation)
+		return features;
+
+	features = vxlan_features_check(skb, features);
+
+	/* hardware only supports IPv4 vxlan tunnel */
+	if (vlan_get_protocol(skb) != htons(ETH_P_IP))
+		goto out;
+
+	/* hardware does not support offload of ipv6 inner pkt */
+	if (eth->h_proto != ntohs(ETH_P_IP))
+		goto out;
+
+	proto = ip_hdr(skb)->protocol;
+
+	if (proto == IPPROTO_UDP) {
+		udph = udp_hdr(skb);
+		port = be16_to_cpu(udph->dest);
+	}
+
+	/* HW supports offload of only one UDP port. Remove CSUM and GSO MASK
+	 * for other UDP port tunnels
+	 */
+	if (port  != enic->vxlan.vxlan_udp_port_number)
+		goto out;
+
+	return features;
+
+out:
+	return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
+}
+
 int enic_is_dynamic(struct enic *enic)
 {
 	return enic->pdev->device == PCI_DEVICE_ID_CISCO_VIC_ENET_DYN;
@@ -591,20 +633,19 @@ static int enic_queue_wq_skb_csum_l4(struct enic *enic, struct vnic_wq *wq,
 	return err;
 }
 
-static int enic_queue_wq_skb_tso(struct enic *enic, struct vnic_wq *wq,
-				 struct sk_buff *skb, unsigned int mss,
-				 int vlan_tag_insert, unsigned int vlan_tag,
-				 int loopback)
+static void enic_preload_tcp_csum_encap(struct sk_buff *skb)
 {
-	unsigned int frag_len_left = skb_headlen(skb);
-	unsigned int len_left = skb->len - frag_len_left;
-	unsigned int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-	int eop = (len_left == 0);
-	unsigned int len;
-	dma_addr_t dma_addr;
-	unsigned int offset = 0;
-	skb_frag_t *frag;
+	if (skb->protocol == cpu_to_be16(ETH_P_IP)) {
+		inner_ip_hdr(skb)->check = 0;
+		inner_tcp_hdr(skb)->check =
+			~csum_tcpudp_magic(inner_ip_hdr(skb)->saddr,
+					   inner_ip_hdr(skb)->daddr, 0,
+					   IPPROTO_TCP, 0);
+	}
+}
 
+static void enic_preload_tcp_csum(struct sk_buff *skb)
+{
 	/* Preload TCP csum field with IP pseudo hdr calculated
 	 * with IP length set to zero.  HW will later add in length
 	 * to each TCP segment resulting from the TSO.
@@ -618,6 +659,30 @@ static int enic_queue_wq_skb_tso(struct enic *enic, struct vnic_wq *wq,
 		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 			&ipv6_hdr(skb)->daddr, 0, IPPROTO_TCP, 0);
 	}
+}
+
+static int enic_queue_wq_skb_tso(struct enic *enic, struct vnic_wq *wq,
+				 struct sk_buff *skb, unsigned int mss,
+				 int vlan_tag_insert, unsigned int vlan_tag,
+				 int loopback)
+{
+	unsigned int frag_len_left = skb_headlen(skb);
+	unsigned int len_left = skb->len - frag_len_left;
+	int eop = (len_left == 0);
+	unsigned int offset = 0;
+	unsigned int hdr_len;
+	dma_addr_t dma_addr;
+	unsigned int len;
+	skb_frag_t *frag;
+
+	if (skb->encapsulation) {
+		hdr_len = skb_inner_transport_header(skb) - skb->data;
+		hdr_len += inner_tcp_hdrlen(skb);
+		enic_preload_tcp_csum_encap(skb);
+	} else {
+		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		enic_preload_tcp_csum(skb);
+	}
 
 	/* Queue WQ_ENET_MAX_DESC_LEN length descriptors
 	 * for the main skb fragment
@@ -666,6 +731,38 @@ static int enic_queue_wq_skb_tso(struct enic *enic, struct vnic_wq *wq,
 	return 0;
 }
 
+static inline int enic_queue_wq_skb_encap(struct enic *enic, struct vnic_wq *wq,
+					  struct sk_buff *skb,
+					  int vlan_tag_insert,
+					  unsigned int vlan_tag, int loopback)
+{
+	unsigned int head_len = skb_headlen(skb);
+	unsigned int len_left = skb->len - head_len;
+	/* Hardware will overwrite the checksum fields, calculating from
+	 * scratch and ignoring the value placed by software.
+	 * Offload mode = 00
+	 * mss[2], mss[1], mss[0] bits are set
+	 */
+	unsigned int mss_or_csum = 7;
+	int eop = (len_left == 0);
+	dma_addr_t dma_addr;
+	int err = 0;
+
+	dma_addr = pci_map_single(enic->pdev, skb->data, head_len,
+				  PCI_DMA_TODEVICE);
+	if (unlikely(enic_dma_map_check(enic, dma_addr)))
+		return -ENOMEM;
+
+	enic_queue_wq_desc_ex(wq, skb, dma_addr, head_len, mss_or_csum, 0,
+			      vlan_tag_insert, vlan_tag,
+			      WQ_ENET_OFFLOAD_MODE_CSUM, eop, 1 /* SOP */, eop,
+			      loopback);
+	if (!eop)
+		err = enic_queue_wq_skb_cont(enic, wq, skb, len_left, loopback);
+
+	return err;
+}
+
 static inline void enic_queue_wq_skb(struct enic *enic,
 	struct vnic_wq *wq, struct sk_buff *skb)
 {
@@ -688,6 +785,9 @@ static inline void enic_queue_wq_skb(struct enic *enic,
 		err = enic_queue_wq_skb_tso(enic, wq, skb, mss,
 					    vlan_tag_insert, vlan_tag,
 					    loopback);
+	else if (skb->encapsulation)
+		err = enic_queue_wq_skb_encap(enic, wq, skb, vlan_tag_insert,
+					      vlan_tag, loopback);
 	else if	(skb->ip_summed == CHECKSUM_PARTIAL)
 		err = enic_queue_wq_skb_csum_l4(enic, wq, skb, vlan_tag_insert,
 						vlan_tag, loopback);
@@ -2400,6 +2500,7 @@ static const struct net_device_ops enic_netdev_dynamic_ops = {
 #endif
 	.ndo_udp_tunnel_add	= enic_udp_tunnel_add,
 	.ndo_udp_tunnel_del	= enic_udp_tunnel_del,
+	.ndo_features_check	= enic_features_check,
 };
 
 static const struct net_device_ops enic_netdev_ops = {
@@ -2425,6 +2526,7 @@ static const struct net_device_ops enic_netdev_ops = {
 #endif
 	.ndo_udp_tunnel_add	= enic_udp_tunnel_add,
 	.ndo_udp_tunnel_del	= enic_udp_tunnel_del,
+	.ndo_features_check	= enic_features_check,
 };
 
 static void enic_dev_deinit(struct enic *enic)
-- 
2.11.0

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 20/29] fm10k: Add support for netdev offloads
Date: Tue, 23 Sep 2014 04:16:48 -0700
Message-ID: <1411471017-28213-21-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33801 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755517AbaIWLRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:22 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for basic offloads including TSO, Tx checksum, Rx
checksum, Rx hash, and the same features applied to VXLAN/NVGRE tunnels.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   | 307 +++++++++++++++++++++++-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 155 +++++++++++-
 2 files changed, 459 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index dae82d2..ac39e50 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -342,6 +342,59 @@ static struct sk_buff *fm10k_fetch_rx_buffer(struct fm10k_ring *rx_ring,
 	return skb;
 }
 
+static inline void fm10k_rx_checksum(struct fm10k_ring *ring,
+				     union fm10k_rx_desc *rx_desc,
+				     struct sk_buff *skb)
+{
+	skb_checksum_none_assert(skb);
+
+	/* Rx checksum disabled via ethtool */
+	if (!(ring->netdev->features & NETIF_F_RXCSUM))
+		return;
+
+	/* TCP/UDP checksum error bit is set */
+	if (fm10k_test_staterr(rx_desc,
+			       FM10K_RXD_STATUS_L4E |
+			       FM10K_RXD_STATUS_L4E2 |
+			       FM10K_RXD_STATUS_IPE |
+			       FM10K_RXD_STATUS_IPE2)) {
+		ring->rx_stats.csum_err++;
+		return;
+	}
+
+	/* It must be a TCP or UDP packet with a valid checksum */
+	if (fm10k_test_staterr(rx_desc, FM10K_RXD_STATUS_L4CS2))
+		skb->encapsulation = true;
+	else if (!fm10k_test_staterr(rx_desc, FM10K_RXD_STATUS_L4CS))
+		return;
+
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+}
+
+#define FM10K_RSS_L4_TYPES_MASK \
+	((1ul << FM10K_RSSTYPE_IPV4_TCP) | \
+	 (1ul << FM10K_RSSTYPE_IPV4_UDP) | \
+	 (1ul << FM10K_RSSTYPE_IPV6_TCP) | \
+	 (1ul << FM10K_RSSTYPE_IPV6_UDP))
+
+static inline void fm10k_rx_hash(struct fm10k_ring *ring,
+				 union fm10k_rx_desc *rx_desc,
+				 struct sk_buff *skb)
+{
+	u16 rss_type;
+
+	if (!(ring->netdev->features & NETIF_F_RXHASH))
+		return;
+
+	rss_type = le16_to_cpu(rx_desc->w.pkt_info) & FM10K_RXD_RSSTYPE_MASK;
+	if (!rss_type)
+		return;
+
+	skb_set_hash(skb, le32_to_cpu(rx_desc->d.rss),
+		     (FM10K_RSS_L4_TYPES_MASK & (1ul << rss_type)) ?
+		     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
+}
+
 /**
  * fm10k_process_skb_fields - Populate skb header fields from Rx descriptor
  * @rx_ring: rx descriptor ring packet is being transacted on
@@ -358,6 +411,10 @@ static unsigned int fm10k_process_skb_fields(struct fm10k_ring *rx_ring,
 {
 	unsigned int len = skb->len;
 
+	fm10k_rx_hash(rx_ring, rx_desc, skb);
+
+	fm10k_rx_checksum(rx_ring, rx_desc, skb);
+
 	FM10K_CB(skb)->fi.w.vlan = rx_desc->w.vlan;
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
@@ -569,6 +626,240 @@ static bool fm10k_clean_rx_irq(struct fm10k_q_vector *q_vector,
 	return total_packets < budget;
 }
 
+#define VXLAN_HLEN (sizeof(struct udphdr) + 8)
+static struct ethhdr *fm10k_port_is_vxlan(struct sk_buff *skb)
+{
+	struct fm10k_intfc *interface = netdev_priv(skb->dev);
+	struct fm10k_vxlan_port *vxlan_port;
+
+	/* we can only offload a vxlan if we recognize it as such */
+	vxlan_port = list_first_entry_or_null(&interface->vxlan_port,
+					      struct fm10k_vxlan_port, list);
+
+	if (!vxlan_port)
+		return NULL;
+	if (vxlan_port->port != udp_hdr(skb)->dest)
+		return NULL;
+
+	/* return offset of udp_hdr plus 8 bytes for VXLAN header */
+	return (struct ethhdr *)(skb_transport_header(skb) + VXLAN_HLEN);
+}
+
+#define FM10K_NVGRE_RESERVED0_FLAGS htons(0x9FFF)
+#define NVGRE_TNI htons(0x2000)
+struct fm10k_nvgre_hdr {
+	__be16 flags;
+	__be16 proto;
+	__be32 tni;
+};
+
+static struct ethhdr *fm10k_gre_is_nvgre(struct sk_buff *skb)
+{
+	struct fm10k_nvgre_hdr *nvgre_hdr;
+	int hlen = ip_hdrlen(skb);
+
+	/* currently only IPv4 is supported due to hlen above */
+	if (vlan_get_protocol(skb) != htons(ETH_P_IP))
+		return NULL;
+
+	/* our transport header should be NVGRE */
+	nvgre_hdr = (struct fm10k_nvgre_hdr *)(skb_network_header(skb) + hlen);
+
+	/* verify all reserved flags are 0 */
+	if (nvgre_hdr->flags & FM10K_NVGRE_RESERVED0_FLAGS)
+		return NULL;
+
+	/* verify protocol is transparent Ethernet bridging */
+	if (nvgre_hdr->proto != htons(ETH_P_TEB))
+		return NULL;
+
+	/* report start of ethernet header */
+	if (nvgre_hdr->flags & NVGRE_TNI)
+		return (struct ethhdr *)(nvgre_hdr + 1);
+
+	return (struct ethhdr *)(&nvgre_hdr->tni);
+}
+
+static __be16 fm10k_tx_encap_offload(struct sk_buff *skb)
+{
+	struct ethhdr *eth_hdr;
+	u8 l4_hdr = 0;
+
+	switch (vlan_get_protocol(skb)) {
+	case htons(ETH_P_IP):
+		l4_hdr = ip_hdr(skb)->protocol;
+		break;
+	case htons(ETH_P_IPV6):
+		l4_hdr = ipv6_hdr(skb)->nexthdr;
+		break;
+	default:
+		return 0;
+	}
+
+	switch (l4_hdr) {
+	case IPPROTO_UDP:
+		eth_hdr = fm10k_port_is_vxlan(skb);
+		break;
+	case IPPROTO_GRE:
+		eth_hdr = fm10k_gre_is_nvgre(skb);
+		break;
+	default:
+		return 0;
+	}
+
+	if (!eth_hdr)
+		return 0;
+
+	switch (eth_hdr->h_proto) {
+	case htons(ETH_P_IP):
+	case htons(ETH_P_IPV6):
+		break;
+	default:
+		return 0;
+	}
+
+	return eth_hdr->h_proto;
+}
+
+static int fm10k_tso(struct fm10k_ring *tx_ring,
+		     struct fm10k_tx_buffer *first)
+{
+	struct sk_buff *skb = first->skb;
+	struct fm10k_tx_desc *tx_desc;
+	unsigned char *th;
+	u8 hdrlen;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
+	if (!skb_is_gso(skb))
+		return 0;
+
+	/* compute header lengths */
+	if (skb->encapsulation) {
+		if (!fm10k_tx_encap_offload(skb))
+			goto err_vxlan;
+		th = skb_inner_transport_header(skb);
+	} else {
+		th = skb_transport_header(skb);
+	}
+
+	/* compute offset from SOF to transport header and add header len */
+	hdrlen = (th - skb->data) + (((struct tcphdr *)th)->doff << 2);
+
+	first->tx_flags |= FM10K_TX_FLAGS_CSUM;
+
+	/* update gso size and bytecount with header size */
+	first->gso_segs = skb_shinfo(skb)->gso_segs;
+	first->bytecount += (first->gso_segs - 1) * hdrlen;
+
+	/* populate Tx descriptor header size and mss */
+	tx_desc = FM10K_TX_DESC(tx_ring, tx_ring->next_to_use);
+	tx_desc->hdrlen = hdrlen;
+	tx_desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
+
+	return 1;
+err_vxlan:
+	tx_ring->netdev->features &= ~NETIF_F_GSO_UDP_TUNNEL;
+	if (!net_ratelimit())
+		netdev_err(tx_ring->netdev,
+			   "TSO requested for unsupported tunnel, disabling offload\n");
+	return -1;
+}
+
+static void fm10k_tx_csum(struct fm10k_ring *tx_ring,
+			  struct fm10k_tx_buffer *first)
+{
+	struct sk_buff *skb = first->skb;
+	struct fm10k_tx_desc *tx_desc;
+	union {
+		struct iphdr *ipv4;
+		struct ipv6hdr *ipv6;
+		u8 *raw;
+	} network_hdr;
+	__be16 protocol;
+	u8 l4_hdr = 0;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		goto no_csum;
+
+	if (skb->encapsulation) {
+		protocol = fm10k_tx_encap_offload(skb);
+		if (!protocol) {
+			if (skb_checksum_help(skb)) {
+				dev_warn(tx_ring->dev,
+					 "failed to offload encap csum!\n");
+				tx_ring->tx_stats.csum_err++;
+			}
+			goto no_csum;
+		}
+		network_hdr.raw = skb_inner_network_header(skb);
+	} else {
+		protocol = vlan_get_protocol(skb);
+		network_hdr.raw = skb_network_header(skb);
+	}
+
+	switch (protocol) {
+	case htons(ETH_P_IP):
+		l4_hdr = network_hdr.ipv4->protocol;
+		break;
+	case htons(ETH_P_IPV6):
+		l4_hdr = network_hdr.ipv6->nexthdr;
+		break;
+	default:
+		if (unlikely(net_ratelimit())) {
+			dev_warn(tx_ring->dev,
+				 "partial checksum but ip version=%x!\n",
+				 protocol);
+		}
+		tx_ring->tx_stats.csum_err++;
+		goto no_csum;
+	}
+
+	switch (l4_hdr) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+		break;
+	case IPPROTO_GRE:
+		if (skb->encapsulation)
+			break;
+	default:
+		if (unlikely(net_ratelimit())) {
+			dev_warn(tx_ring->dev,
+				 "partial checksum but l4 proto=%x!\n",
+				 l4_hdr);
+		}
+		tx_ring->tx_stats.csum_err++;
+		goto no_csum;
+	}
+
+	/* update TX checksum flag */
+	first->tx_flags |= FM10K_TX_FLAGS_CSUM;
+
+no_csum:
+	/* populate Tx descriptor header size and mss */
+	tx_desc = FM10K_TX_DESC(tx_ring, tx_ring->next_to_use);
+	tx_desc->hdrlen = 0;
+	tx_desc->mss = 0;
+}
+
+#define FM10K_SET_FLAG(_input, _flag, _result) \
+	((_flag <= _result) ? \
+	 ((u32)(_input & _flag) * (_result / _flag)) : \
+	 ((u32)(_input & _flag) / (_flag / _result)))
+
+static u8 fm10k_tx_desc_flags(struct sk_buff *skb, u32 tx_flags)
+{
+	/* set type for advanced descriptor with frame checksum insertion */
+	u32 desc_flags = 0;
+
+	/* set checksum offload bits */
+	desc_flags |= FM10K_SET_FLAG(tx_flags, FM10K_TX_FLAGS_CSUM,
+				     FM10K_TXD_FLAG_CSUM);
+
+	return desc_flags;
+}
+
 static bool fm10k_tx_desc_push(struct fm10k_ring *tx_ring,
 			       struct fm10k_tx_desc *tx_desc, u16 i,
 			       dma_addr_t dma, unsigned int size, u8 desc_flags)
@@ -596,8 +887,9 @@ static void fm10k_tx_map(struct fm10k_ring *tx_ring,
 	unsigned char *data;
 	dma_addr_t dma;
 	unsigned int data_len, size;
+	u32 tx_flags = first->tx_flags;
 	u16 i = tx_ring->next_to_use;
-	u8 flags = 0;
+	u8 flags = fm10k_tx_desc_flags(skb, tx_flags);
 
 	tx_desc = FM10K_TX_DESC(tx_ring, i);
 
@@ -732,6 +1024,7 @@ netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 				  struct fm10k_ring *tx_ring)
 {
 	struct fm10k_tx_buffer *first;
+	int tso;
 	u32 tx_flags = 0;
 #if PAGE_SIZE > FM10K_MAX_DATA_PER_TXD
 	unsigned short f;
@@ -763,11 +1056,23 @@ netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 	/* record initial flags and protocol */
 	first->tx_flags = tx_flags;
 
+	tso = fm10k_tso(tx_ring, first);
+	if (tso < 0)
+		goto out_drop;
+	else if (!tso)
+		fm10k_tx_csum(tx_ring, first);
+
 	fm10k_tx_map(tx_ring, first);
 
 	fm10k_maybe_stop_tx(tx_ring, DESC_NEEDED);
 
 	return NETDEV_TX_OK;
+
+out_drop:
+	dev_kfree_skb_any(first->skb);
+	first->skb = NULL;
+
+	return NETDEV_TX_OK;
 }
 
 static u64 fm10k_get_tx_completed(struct fm10k_ring *ring)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 2cda9f9..5dbb4d7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -20,6 +20,9 @@
 
 #include "fm10k.h"
 #include <linux/vmalloc.h>
+#if IS_ENABLED(CONFIG_VXLAN)
+#include <net/vxlan.h>
+#endif /* CONFIG_VXLAN */
 
 /**
  * fm10k_setup_tx_resources - allocate Tx resources (Descriptors)
@@ -369,6 +372,128 @@ static void fm10k_request_glort_range(struct fm10k_intfc *interface)
 }
 
 /**
+ * fm10k_del_vxlan_port_all
+ * @interface: board private structure
+ *
+ * This function frees the entire vxlan_port list
+ **/
+static void fm10k_del_vxlan_port_all(struct fm10k_intfc *interface)
+{
+	struct fm10k_vxlan_port *vxlan_port;
+
+	/* flush all entries from list */
+	vxlan_port = list_first_entry_or_null(&interface->vxlan_port,
+					      struct fm10k_vxlan_port, list);
+	while (vxlan_port) {
+		list_del(&vxlan_port->list);
+		kfree(vxlan_port);
+		vxlan_port = list_first_entry_or_null(&interface->vxlan_port,
+						      struct fm10k_vxlan_port,
+						      list);
+	}
+}
+
+/**
+ * fm10k_restore_vxlan_port
+ * @interface: board private structure
+ *
+ * This function restores the value in the tunnel_cfg register after reset
+ **/
+static void fm10k_restore_vxlan_port(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_vxlan_port *vxlan_port;
+
+	/* only the PF supports configuring tunnels */
+	if (hw->mac.type != fm10k_mac_pf)
+		return;
+
+	vxlan_port = list_first_entry_or_null(&interface->vxlan_port,
+					      struct fm10k_vxlan_port, list);
+
+	/* restore tunnel configuration register */
+	fm10k_write_reg(hw, FM10K_TUNNEL_CFG,
+			(vxlan_port ? ntohs(vxlan_port->port) : 0) |
+			(ETH_P_TEB << FM10K_TUNNEL_CFG_NVGRE_SHIFT));
+}
+
+/**
+ * fm10k_add_vxlan_port
+ * @netdev: network interface device structure
+ * @sa_family: Address family of new port
+ * @port: port number used for VXLAN
+ *
+ * This funciton is called when a new VXLAN interface has added a new port
+ * number to the range that is currently in use for VXLAN.  The new port
+ * number is always added to the tail so that the port number list should
+ * match the order in which the ports were allocated.  The head of the list
+ * is always used as the VXLAN port number for offloads.
+ **/
+static void fm10k_add_vxlan_port(struct net_device *dev,
+				 sa_family_t sa_family, __be16 port) {
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_vxlan_port *vxlan_port;
+
+	/* only the PF supports configuring tunnels */
+	if (interface->hw.mac.type != fm10k_mac_pf)
+		return;
+
+	/* existing ports are pulled out so our new entry is always last */
+	fm10k_vxlan_port_for_each(vxlan_port, interface) {
+		if ((vxlan_port->port == port) &&
+		    (vxlan_port->sa_family == sa_family)) {
+			list_del(&vxlan_port->list);
+			goto insert_tail;
+		}
+	}
+
+	/* allocate memory to track ports */
+	vxlan_port = kmalloc(sizeof(*vxlan_port), GFP_ATOMIC);
+	if (!vxlan_port)
+		return;
+	vxlan_port->port = port;
+	vxlan_port->sa_family = sa_family;
+
+insert_tail:
+	/* add new port value to list */
+	list_add_tail(&vxlan_port->list, &interface->vxlan_port);
+
+	fm10k_restore_vxlan_port(interface);
+}
+
+/**
+ * fm10k_del_vxlan_port
+ * @netdev: network interface device structure
+ * @sa_family: Address family of freed port
+ * @port: port number used for VXLAN
+ *
+ * This funciton is called when a new VXLAN interface has freed a port
+ * number from the range that is currently in use for VXLAN.  The freed
+ * port is removed from the list and the new head is used to determine
+ * the port number for offloads.
+ **/
+static void fm10k_del_vxlan_port(struct net_device *dev,
+				 sa_family_t sa_family, __be16 port) {
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_vxlan_port *vxlan_port;
+
+	if (interface->hw.mac.type != fm10k_mac_pf)
+		return;
+
+	/* find the port in the list and free it */
+	fm10k_vxlan_port_for_each(vxlan_port, interface) {
+		if ((vxlan_port->port == port) &&
+		    (vxlan_port->sa_family == sa_family)) {
+			list_del(&vxlan_port->list);
+			kfree(vxlan_port);
+			break;
+		}
+	}
+
+	fm10k_restore_vxlan_port(interface);
+}
+
+/**
  * fm10k_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
@@ -410,6 +535,11 @@ int fm10k_open(struct net_device *netdev)
 	if (err)
 		goto err_set_queues;
 
+#if IS_ENABLED(CONFIG_VXLAN)
+	/* update VXLAN port configuration */
+	vxlan_get_rx_port(netdev);
+
+#endif
 	fm10k_up(interface);
 
 	return 0;
@@ -443,6 +573,8 @@ int fm10k_close(struct net_device *netdev)
 
 	fm10k_qv_free_irq(interface);
 
+	fm10k_del_vxlan_port_all(interface);
+
 	fm10k_free_all_tx_resources(interface);
 	fm10k_free_all_rx_resources(interface);
 
@@ -892,6 +1024,9 @@ void fm10k_restore_rx_state(struct fm10k_intfc *interface)
 
 	/* record updated xcast mode state */
 	interface->xcast_mode = xcast_mode;
+
+	/* Restore tunnel configuration */
+	fm10k_restore_vxlan_port(interface);
 }
 
 void fm10k_reset_rx_state(struct fm10k_intfc *interface)
@@ -1026,6 +1161,8 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_set_rx_mode	= fm10k_set_rx_mode,
 	.ndo_get_stats64	= fm10k_get_stats64,
 	.ndo_setup_tc		= fm10k_setup_tc,
+	.ndo_add_vxlan_port	= fm10k_add_vxlan_port,
+	.ndo_del_vxlan_port	= fm10k_del_vxlan_port,
 };
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
@@ -1048,7 +1185,15 @@ struct net_device *fm10k_alloc_netdev(void)
 	interface->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
 
 	/* configure default features */
-	dev->features |= NETIF_F_SG;
+	dev->features |= NETIF_F_IP_CSUM |
+			 NETIF_F_IPV6_CSUM |
+			 NETIF_F_SG |
+			 NETIF_F_TSO |
+			 NETIF_F_TSO6 |
+			 NETIF_F_TSO_ECN |
+			 NETIF_F_GSO_UDP_TUNNEL |
+			 NETIF_F_RXHASH |
+			 NETIF_F_RXCSUM;
 
 	/* all features defined to this point should be changeable */
 	dev->hw_features |= dev->features;
@@ -1057,7 +1202,13 @@ struct net_device *fm10k_alloc_netdev(void)
 	dev->vlan_features |= dev->features;
 
 	/* configure tunnel offloads */
-	dev->hw_enc_features = NETIF_F_SG;
+	dev->hw_enc_features = NETIF_F_IP_CSUM |
+			       NETIF_F_TSO |
+			       NETIF_F_TSO6 |
+			       NETIF_F_TSO_ECN |
+			       NETIF_F_GSO_UDP_TUNNEL |
+			       NETIF_F_IPV6_CSUM |
+			       NETIF_F_SG;
 
 	/* we want to leave these both on as we cannot disable VLAN tag
 	 * insertion or stripping on the hardware since it is contained
-- 
1.9.3

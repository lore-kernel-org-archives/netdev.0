From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/7] ixgbe: Address fact that RSC was not setting GSO size for incoming frames
Date: Fri, 10 Feb 2012 16:08:19 -0800
Message-ID: <1328918904-11511-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8635 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760778Ab2BKAI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 19:08:28 -0500
In-Reply-To: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is meant to address the fact that RSC has not been setting the
gso_size value on the skb.  As a result performance on lossy TCP
connections was negatively impacted.  This change resolves the issue by
setting gso_size to the average size for incoming packets.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  130 ++++++++++++++++++++++++-
 1 files changed, 125 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 18e474c..762f3377 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1276,6 +1276,104 @@ static inline bool ixgbe_close_active_frag_list(struct sk_buff *head)
 	return true;
 }
 
+/**
+ * ixgbe_get_headlen - determine size of header for RSC/LRO/GRO/FCOE
+ * @data: pointer to the start of the headers
+ * @max_len: total length of section to find headers in
+ *
+ * This function is meant to determine the length of headers that will
+ * be recognized by hardware for LRO, GRO, and RSC offloads.  The main
+ * motivation of doing this is to only perform one pull for IPv4 TCP
+ * packets so that we can do basic things like calculating the gso_size
+ * based on the average data per packet.
+ **/
+static unsigned int ixgbe_get_headlen(unsigned char *data,
+				      unsigned int max_len)
+{
+	union {
+		unsigned char *network;
+		/* l2 headers */
+		struct ethhdr *eth;
+		struct vlan_hdr *vlan;
+		/* l3 headers */
+		struct iphdr *ipv4;
+	} hdr;
+	__be16 protocol;
+	u8 nexthdr = 0;	/* default to not TCP */
+	u8 hlen;
+
+	/* this should never happen, but better safe than sorry */
+	if (max_len < ETH_HLEN)
+		return max_len;
+
+	/* initialize network frame pointer */
+	hdr.network = data;
+
+	/* set first protocol and move network header forward */
+	protocol = hdr.eth->h_proto;
+	hdr.network += ETH_HLEN;
+
+	/* handle any vlan tag if present */
+	if (protocol == __constant_htons(ETH_P_8021Q)) {
+		if ((hdr.network - data) > (max_len - VLAN_HLEN))
+			return max_len;
+
+		protocol = hdr.vlan->h_vlan_encapsulated_proto;
+		hdr.network += VLAN_HLEN;
+	}
+
+	/* handle L3 protocols */
+	if (protocol == __constant_htons(ETH_P_IP)) {
+		if ((hdr.network - data) > (max_len - sizeof(struct iphdr)))
+			return max_len;
+
+		/* access ihl as a u8 to avoid unaligned access on ia64 */
+		hlen = (hdr.network[0] & 0x0F) << 2;
+
+		/* verify hlen meets minimum size requirements */
+		if (hlen < sizeof(struct iphdr))
+			return hdr.network - data;
+
+		/* record next protocol */
+		nexthdr = hdr.ipv4->protocol;
+		hdr.network += hlen;
+#ifdef CONFIG_FCOE
+	} else if (protocol == __constant_htons(ETH_P_FCOE)) {
+		if ((hdr.network - data) > (max_len - FCOE_HEADER_LEN))
+			return max_len;
+		hdr.network += FCOE_HEADER_LEN;
+#endif
+	} else {
+		return hdr.network - data;
+	}
+
+	/* finally sort out TCP */
+	if (nexthdr == IPPROTO_TCP) {
+		if ((hdr.network - data) > (max_len - sizeof(struct tcphdr)))
+			return max_len;
+
+		/* access doff as a u8 to avoid unaligned access on ia64 */
+		hlen = (hdr.network[12] & 0xF0) >> 2;
+
+		/* verify hlen meets minimum size requirements */
+		if (hlen < sizeof(struct tcphdr))
+			return hdr.network - data;
+
+		hdr.network += hlen;
+	}
+
+	/*
+	 * If everything has gone correctly hdr.network should be the
+	 * data section of the packet and will be the end of the header.
+	 * If not then it probably represents the end of the last recognized
+	 * header.
+	 */
+	if ((hdr.network - data) < max_len)
+		return hdr.network - data;
+	else
+		return max_len;
+}
+
 static void ixgbe_get_rsc_cnt(struct ixgbe_ring *rx_ring,
 			      union ixgbe_adv_rx_desc *rx_desc,
 			      struct sk_buff *skb)
@@ -1299,6 +1397,32 @@ static void ixgbe_get_rsc_cnt(struct ixgbe_ring *rx_ring,
 	IXGBE_CB(skb)->append_cnt += rsc_cnt - 1;
 }
 
+static void ixgbe_set_rsc_gso_size(struct ixgbe_ring *ring,
+				   struct sk_buff *skb)
+{
+	u16 hdr_len = ixgbe_get_headlen(skb->data, skb_headlen(skb));
+
+	/* set gso_size to avoid messing up TCP MSS */
+	skb_shinfo(skb)->gso_size = DIV_ROUND_UP((skb->len - hdr_len),
+						 IXGBE_CB(skb)->append_cnt);
+}
+
+static void ixgbe_update_rsc_stats(struct ixgbe_ring *rx_ring,
+				   struct sk_buff *skb)
+{
+	/* if append_cnt is 0 then frame is not RSC */
+	if (!IXGBE_CB(skb)->append_cnt)
+		return;
+
+	rx_ring->rx_stats.rsc_count += IXGBE_CB(skb)->append_cnt;
+	rx_ring->rx_stats.rsc_flush++;
+
+	ixgbe_set_rsc_gso_size(rx_ring, skb);
+
+	/* gso_size is computed using append_cnt so always clear it last */
+	IXGBE_CB(skb)->append_cnt = 0;
+}
+
 static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			       struct ixgbe_ring *rx_ring,
 			       int budget)
@@ -1437,11 +1561,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			goto next_desc;
 		}
 
-		if (IXGBE_CB(skb)->append_cnt) {
-			rx_ring->rx_stats.rsc_count +=
-					IXGBE_CB(skb)->append_cnt;
-			rx_ring->rx_stats.rsc_flush++;
-		}
+		ixgbe_update_rsc_stats(rx_ring, skb);
 
 		/* ERR_MASK will only have valid bits if EOP set */
 		if (unlikely(staterr & IXGBE_RXDADV_ERR_FRAME_ERR_MASK)) {
-- 
1.7.7.6

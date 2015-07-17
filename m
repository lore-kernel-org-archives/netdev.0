From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] ixgbevf: Set Rx hash type for ingress packets
Date: Fri, 17 Jul 2015 07:25:21 -0700
Message-ID: <1437143123-5031-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Fan Du <fan.du@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42955 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757792AbbGQOZf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:35 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>

Set hash type for ingress packets according to NIC
advanced receive descriptors RSS type part.

Signed-off-by: Fan Du <fan.du@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/defines.h      | 12 ++++++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 27 +++++++++++++++++++++++
 2 files changed, 39 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index 770e21a..5843458 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -161,6 +161,18 @@ typedef u32 ixgbe_link_speed;
 #define IXGBE_RXDADV_SPLITHEADER_EN	0x00001000
 #define IXGBE_RXDADV_SPH		0x8000
 
+/* RSS Hash results */
+#define IXGBE_RXDADV_RSSTYPE_NONE		0x00000000
+#define IXGBE_RXDADV_RSSTYPE_IPV4_TCP		0x00000001
+#define IXGBE_RXDADV_RSSTYPE_IPV4		0x00000002
+#define IXGBE_RXDADV_RSSTYPE_IPV6_TCP		0x00000003
+#define IXGBE_RXDADV_RSSTYPE_IPV6_EX		0x00000004
+#define IXGBE_RXDADV_RSSTYPE_IPV6		0x00000005
+#define IXGBE_RXDADV_RSSTYPE_IPV6_TCP_EX	0x00000006
+#define IXGBE_RXDADV_RSSTYPE_IPV4_UDP		0x00000007
+#define IXGBE_RXDADV_RSSTYPE_IPV6_UDP		0x00000008
+#define IXGBE_RXDADV_RSSTYPE_IPV6_UDP_EX	0x00000009
+
 #define IXGBE_RXD_ERR_FRAME_ERR_MASK ( \
 				      IXGBE_RXD_ERR_CE |  \
 				      IXGBE_RXD_ERR_LE |  \
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index acfa051..b2c86f1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -457,6 +457,32 @@ static void ixgbevf_rx_skb(struct ixgbevf_q_vector *q_vector,
 	napi_gro_receive(&q_vector->napi, skb);
 }
 
+#define IXGBE_RSS_L4_TYPES_MASK \
+	((1ul << IXGBE_RXDADV_RSSTYPE_IPV4_TCP) | \
+	 (1ul << IXGBE_RXDADV_RSSTYPE_IPV4_UDP) | \
+	 (1ul << IXGBE_RXDADV_RSSTYPE_IPV6_TCP) | \
+	 (1ul << IXGBE_RXDADV_RSSTYPE_IPV6_UDP))
+
+static inline void ixgbevf_rx_hash(struct ixgbevf_ring *ring,
+				   union ixgbe_adv_rx_desc *rx_desc,
+				   struct sk_buff *skb)
+{
+	u16 rss_type;
+
+	if (!(ring->netdev->features & NETIF_F_RXHASH))
+		return;
+
+	rss_type = le16_to_cpu(rx_desc->wb.lower.lo_dword.hs_rss.pkt_info) &
+		   IXGBE_RXDADV_RSSTYPE_MASK;
+
+	if (!rss_type)
+		return;
+
+	skb_set_hash(skb, le32_to_cpu(rx_desc->wb.lower.hi_dword.rss),
+		     (IXGBE_RSS_L4_TYPES_MASK & (1ul << rss_type)) ?
+		     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
+}
+
 /**
  * ixgbevf_rx_checksum - indicate in skb if hw indicated a good cksum
  * @ring: structure containig ring specific data
@@ -506,6 +532,7 @@ static void ixgbevf_process_skb_fields(struct ixgbevf_ring *rx_ring,
 				       union ixgbe_adv_rx_desc *rx_desc,
 				       struct sk_buff *skb)
 {
+	ixgbevf_rx_hash(rx_ring, rx_desc, skb);
 	ixgbevf_rx_checksum(rx_ring, rx_desc, skb);
 
 	if (ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {
-- 
2.4.3

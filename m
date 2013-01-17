From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] igb: Report L4 Rx hash via skb->l4_rxhash
Date: Thu, 17 Jan 2013 03:35:14 -0800
Message-ID: <1358422519-20981-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6810 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756530Ab3AQLfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 06:35:43 -0500
In-Reply-To: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we report when the Rx hash data is based on L4
protocol inputs, specifically TCP or UDP port numbers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.h |  9 +++++++++
 drivers/net/ethernet/intel/igb/igb_main.c    | 21 +++++++++++++++++++--
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index 444f6f5..fa13e70 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -112,11 +112,20 @@ union e1000_adv_rx_desc {
 	} wb;  /* writeback */
 };
 
+#define E1000_RXDADV_RSSTYPE_MASK	0x0000000F
 #define E1000_RXDADV_HDRBUFLEN_MASK      0x7FE0
 #define E1000_RXDADV_HDRBUFLEN_SHIFT     5
 #define E1000_RXDADV_STAT_TS             0x10000 /* Pkt was time stamped */
 #define E1000_RXDADV_STAT_TSIP           0x08000 /* timestamp in packet */
 
+/* RSS Hash results */
+#define E1000_RXDADV_RSSTYPE_IPV4_TCP	0x00000001
+#define E1000_RXDADV_RSSTYPE_IPV6_TCP	0x00000003
+#define E1000_RXDADV_RSSTYPE_IPV6_TCP_EX 0x00000006
+#define E1000_RXDADV_RSSTYPE_IPV4_UDP	0x00000007
+#define E1000_RXDADV_RSSTYPE_IPV6_UDP	0x00000008
+#define E1000_RXDADV_RSSTYPE_IPV6_UDP_EX 0x00000009
+
 /* Transmit Descriptor - Advanced */
 union e1000_adv_tx_desc {
 	struct {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a9cb84a..2c66ec8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6280,12 +6280,29 @@ static inline void igb_rx_checksum(struct igb_ring *ring,
 		le32_to_cpu(rx_desc->wb.upper.status_error));
 }
 
+#define IGB_RSS_L4TYPES \
+	(((u16)1 << E1000_RXDADV_RSSTYPE_IPV4_TCP) | \
+	 ((u16)1 << E1000_RXDADV_RSSTYPE_IPV4_UDP) | \
+	 ((u16)1 << E1000_RXDADV_RSSTYPE_IPV6_TCP) | \
+	 ((u16)1 << E1000_RXDADV_RSSTYPE_IPV6_UDP) | \
+	 ((u16)1 << E1000_RXDADV_RSSTYPE_IPV6_TCP_EX) | \
+	 ((u16)1 << E1000_RXDADV_RSSTYPE_IPV6_UDP_EX))
+
 static inline void igb_rx_hash(struct igb_ring *ring,
 			       union e1000_adv_rx_desc *rx_desc,
 			       struct sk_buff *skb)
 {
-	if (ring->netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+	u16 rss_type;
+
+	if (!(ring->netdev->features & NETIF_F_RXHASH))
+		return;
+
+	skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+
+	rss_type = le16_to_cpu(rx_desc->wb.lower.lo_dword.pkt_info) &
+		   E1000_RXDADV_RSSTYPE_MASK;
+
+	skb->l4_rxhash = (IGB_RSS_L4TYPES >> rss_type) & 0x1;
 }
 
 /**
-- 
1.7.11.7

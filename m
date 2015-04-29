From: Fan Du <fan.du@intel.com>
Subject: [PATCH v2 1/3] ixgbe: Specify rx hash type wrt rx desc RSS type
Date: Wed, 29 Apr 2015 10:57:39 +0800
Message-ID: <1430276261-29821-2-git-send-email-fan.du@intel.com>
References: <1430276261-29821-1-git-send-email-fan.du@intel.com>
Cc: alexander.h.duyck@redhat.com, emil.s.tantilov@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Fan Du <fan.du@intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39991 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031389AbbD2DEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 23:04:08 -0400
In-Reply-To: <1430276261-29821-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RSS could be leveraged by taking account L4 src/dst ports
as ingredients, thus ingress skb rx hash type should honor
such the real configuration.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   25 +++++++++++++++++++++----
 1 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d3f4b0c..5df896b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1357,14 +1357,31 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 }
 
 #endif /* CONFIG_IXGBE_DCA */
+
+#define IXGBE_RSS_L4_TYPES_MASK \
+	((1ul << IXGBE_RXDADV_RSSTYPE_IPV4_TCP) | \
+	 (1ul << IXGBE_RXDADV_RSSTYPE_IPV4_UDP) | \
+	 (1ul << IXGBE_RXDADV_RSSTYPE_IPV6_TCP) | \
+	 (1ul << IXGBE_RXDADV_RSSTYPE_IPV6_UDP))
+
 static inline void ixgbe_rx_hash(struct ixgbe_ring *ring,
 				 union ixgbe_adv_rx_desc *rx_desc,
 				 struct sk_buff *skb)
 {
-	if (ring->netdev->features & NETIF_F_RXHASH)
-		skb_set_hash(skb,
-			     le32_to_cpu(rx_desc->wb.lower.hi_dword.rss),
-			     PKT_HASH_TYPE_L3);
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
 }
 
 #ifdef IXGBE_FCOE
-- 
1.7.1

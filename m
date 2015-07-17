From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] ixgbe: Specify Rx hash type WRT Rx desc RSS type
Date: Fri, 17 Jul 2015 07:25:20 -0700
Message-ID: <1437143123-5031-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Fan Du <fan.du@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1269 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757898AbbGQOZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:36 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>

RSS could be leveraged by taking account L4 src/dst ports
as ingredients, thus ingress skb Rx hash type should honor
such the real configuration.

Signed-off-by: Fan Du <fan.du@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9aa6104..3e6a931 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1360,14 +1360,31 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
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
2.4.3

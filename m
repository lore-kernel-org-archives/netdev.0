From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: [PATCH net-next] enic: set skb->hash type properly
Date: Tue,  1 Nov 2016 17:58:50 -0700
Message-ID: <20161102005850.9904-1-gvaradar@cisco.com>
Cc: Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, benve@cisco.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-5.cisco.com ([173.37.142.92]:27655 "EHLO
        alln-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755090AbcKBA7D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 20:59:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>

Driver sets the skb l4/l3 hash based on NIC_CFG_RSS_HASH_TYPE_*,
which is bit mask. This is wrong. Hw actually provides us enum.
Use CQ_ENET_RQ_DESC_RSS_TYPE_* to set l3 and l4 hash type.

Fixes: bf751ba802fe ("driver/net: enic: record q_number and rss_hash for skb")
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |  2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c | 18 ++++++++++++------
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 130f910..9023c85 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -33,7 +33,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.3.0.20"
+#define DRV_VERSION		"2.3.0.31"
 #define DRV_COPYRIGHT		"Copyright 2008-2013 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index f514faf..cdd7a1a 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1166,12 +1166,18 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		skb->protocol = eth_type_trans(skb, netdev);
 		skb_record_rx_queue(skb, q_number);
 		if (netdev->features & NETIF_F_RXHASH) {
-			skb_set_hash(skb, rss_hash,
-				     (rss_type &
-				      (NIC_CFG_RSS_HASH_TYPE_TCP_IPV6_EX |
-				       NIC_CFG_RSS_HASH_TYPE_TCP_IPV6 |
-				       NIC_CFG_RSS_HASH_TYPE_TCP_IPV4)) ?
-				     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
+			switch (rss_type) {
+			case CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv4:
+			case CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv6:
+			case CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv6_EX:
+				skb_set_hash(skb, rss_hash, PKT_HASH_TYPE_L4);
+				break;
+			case CQ_ENET_RQ_DESC_RSS_TYPE_IPv4:
+			case CQ_ENET_RQ_DESC_RSS_TYPE_IPv6:
+			case CQ_ENET_RQ_DESC_RSS_TYPE_IPv6_EX:
+				skb_set_hash(skb, rss_hash, PKT_HASH_TYPE_L3);
+				break;
+			}
 		}
 
 		/* Hardware does not provide whole packet checksum. It only
-- 
2.10.2

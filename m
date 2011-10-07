From: Ashish Sharma <ashishsharma@google.com>
Subject: [PATCH] bridge: Have tx_bytes count headers like rx_bytes.
Date: Fri,  7 Oct 2011 13:47:41 -0700
Message-ID: <1318020461-14494-1-git-send-email-ashishsharma@google.com>
Cc: ashishsharma@google.com, jpa@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:30875 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754550Ab1JGUrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 16:47:47 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p97KlkGR011329
	for <netdev@vger.kernel.org>; Fri, 7 Oct 2011 13:47:46 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since rx_bytes accounting does not include Ethernet Headers in
br_input.c, excluding ETH_HLEN on the transmit path for consistent
measurement of packet length on both the Tx and Rx chains.

Signed-off-by: Ashish Sharma <ashishsharma@google.com>
Signed-off-by: JP Abgrall <jpa@google.com>
---
:100644 100644 32b8f9f... a9dd166... M	net/bridge/br_device.c
 net/bridge/br_device.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 32b8f9f..a9dd166 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -38,16 +38,17 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 #endif
 
-	u64_stats_update_begin(&brstats->syncp);
-	brstats->tx_packets++;
-	brstats->tx_bytes += skb->len;
-	u64_stats_update_end(&brstats->syncp);
-
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
+	u64_stats_update_begin(&brstats->syncp);
+	brstats->tx_packets++;
+	/* Exclude ETH_HLEN from byte stats for consistency with Rx chain */
+	brstats->tx_bytes += skb->len;
+	u64_stats_update_end(&brstats->syncp);
+
 	rcu_read_lock();
 	if (is_broadcast_ether_addr(dest))
 		br_flood_deliver(br, skb);
-- 
1.7.3.1

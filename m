From: Ben Greear <greearb@candelatech.com>
Subject: [net-next 2/2] macvlan:  Enable qdisc backoff logic.
Date: Wed, 25 Aug 2010 12:00:51 -0700
Message-ID: <1282762851-3612-2-git-send-email-greearb@candelatech.com>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43805 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab0HYTBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 15:01:02 -0400
In-Reply-To: <1282762851-3612-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows macvlans to apply backpressure to calling code
in the transmit path when the underlying qdisc cannot accept
additional packets.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 0ef0eb0... 43c7096... M	drivers/net/macvlan.c
 drivers/net/macvlan.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0ef0eb0..43c7096 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -237,7 +237,7 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 
 xmit_world:
 	skb_set_dev(skb, vlan->lowerdev);
-	return dev_queue_xmit(skb);
+	return try_dev_queue_xmit(skb, 1);
 }
 
 netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
@@ -252,6 +252,10 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
 		txq->tx_packets++;
 		txq->tx_bytes += len;
+	} else if (ret == NET_XMIT_BUSY) {
+		/* Calling code should retry, skb was NOT freed. */
+		dev->stats.collisions++; /* sort of a collision, at least */
+		return NETDEV_TX_BUSY;
 	} else
 		txq->tx_dropped++;
 
-- 
1.6.2.5


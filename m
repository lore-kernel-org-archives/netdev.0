From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: validate_xmit_skb() changes
Date: Tue, 12 Apr 2016 21:50:07 -0700
Message-ID: <1460523007.32504.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:32835 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757810AbcDMEuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 00:50:09 -0400
Received: by mail-pf0-f170.google.com with SMTP id 184so27056707pff.0
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 21:50:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skbs given to validate_xmit_skb() should not have a next
pointer anymore.

Also if a packet is dropped, increment dev->tx_dropped
__dev_queue_xmit() no longer has to change tx_dropped in this case.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d51343a821ed..85e808f977f5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2915,9 +2915,6 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 {
 	netdev_features_t features;
 
-	if (skb->next)
-		return skb;
-
 	features = netif_skb_features(skb);
 	skb = validate_xmit_vlan(skb, features);
 	if (unlikely(!skb))
@@ -2960,6 +2957,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 out_kfree_skb:
 	kfree_skb(skb);
 out_null:
+	atomic_long_inc(&dev->tx_dropped);
 	return NULL;
 }
 
@@ -3349,7 +3347,7 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 			skb = validate_xmit_skb(skb, dev);
 			if (!skb)
-				goto drop;
+				goto out;
 
 			HARD_TX_LOCK(dev, txq, cpu);
 
@@ -3376,7 +3374,6 @@ recursion_alert:
 	}
 
 	rc = -ENETDOWN;
-drop:
 	rcu_read_unlock_bh();
 
 	atomic_long_inc(&dev->tx_dropped);

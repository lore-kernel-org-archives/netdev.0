From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 6/6] kaweth: use skb_cow_head() to deal with cloned skbs
Date: Wed, 19 Apr 2017 09:59:26 -0700
Message-ID: <20170419165926.30631-7-edumazet@google.com>
References: <20170419165926.30631-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f174.google.com ([209.85.213.174]:33742 "EHLO
        mail-yb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967313AbdDSRCI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 13:02:08 -0400
Received: by mail-yb0-f174.google.com with SMTP id 81so8939783ybp.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 10:02:08 -0700 (PDT)
In-Reply-To: <20170419165926.30631-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use skb_cow_head() to properly deal with clones,
especially the ones coming from TCP stack that allow their head being
modified. This avoids a copy.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Hughes <james.hughes@raspberrypi.org>
---
 drivers/net/usb/kaweth.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 876f02f4945eafdc2fb5cfa0f9dcb54d9b498af4..2a2c3edb6bad0b3bd257c3a101d100ad3b00cc59 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -803,18 +803,12 @@ static netdev_tx_t kaweth_start_xmit(struct sk_buff *skb,
 	}
 
 	/* We now decide whether we can put our special header into the sk_buff */
-	if (skb_cloned(skb) || skb_headroom(skb) < 2) {
-		/* no such luck - we make our own */
-		struct sk_buff *copied_skb;
-		copied_skb = skb_copy_expand(skb, 2, 0, GFP_ATOMIC);
-		dev_kfree_skb_irq(skb);
-		skb = copied_skb;
-		if (!copied_skb) {
-			kaweth->stats.tx_errors++;
-			netif_start_queue(net);
-			spin_unlock_irq(&kaweth->device_lock);
-			return NETDEV_TX_OK;
-		}
+	if (skb_cow_head(skb, 2)) {
+		kaweth->stats.tx_errors++;
+		netif_start_queue(net);
+		spin_unlock_irq(&kaweth->device_lock);
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
 
 	private_header = (__le16 *)__skb_push(skb, 2);
-- 
2.12.2.816.g2cccc81164-goog

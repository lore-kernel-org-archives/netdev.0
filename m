From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 4/6] lan78xx: use skb_cow_head() to deal with cloned skbs
Date: Wed, 19 Apr 2017 09:59:24 -0700
Message-ID: <20170419165926.30631-5-edumazet@google.com>
References: <20170419165926.30631-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Woojung Huh <woojung.huh@microchip.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f182.google.com ([209.85.213.182]:35653 "EHLO
        mail-yb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967463AbdDSQ7v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:59:51 -0400
Received: by mail-yb0-f182.google.com with SMTP id 6so7397392ybq.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:59:45 -0700 (PDT)
In-Reply-To: <20170419165926.30631-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to ensure there is enough headroom to push extra header,
but we also need to check if we are allowed to change headers.

skb_cow_head() is the proper helper to deal with this.

Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to 10/100/1000 Ethernet device driver")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Hughes <james.hughes@raspberrypi.org>
Cc: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 9889a70ff4f6fece5bfabbfb45a3470f721a5a32..636f48f19d1eacae67c050de4fc3e651bffdf825 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2607,14 +2607,9 @@ static struct sk_buff *lan78xx_tx_prep(struct lan78xx_net *dev,
 {
 	u32 tx_cmd_a, tx_cmd_b;
 
-	if (skb_headroom(skb) < TX_OVERHEAD) {
-		struct sk_buff *skb2;
-
-		skb2 = skb_copy_expand(skb, TX_OVERHEAD, 0, flags);
+	if (skb_cow_head(skb, TX_OVERHEAD)) {
 		dev_kfree_skb_any(skb);
-		skb = skb2;
-		if (!skb)
-			return NULL;
+		return NULL;
 	}
 
 	if (lan78xx_linearize(skb) < 0)
-- 
2.12.2.816.g2cccc81164-goog

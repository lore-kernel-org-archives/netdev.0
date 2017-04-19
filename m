From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 3/6] sr9700: use skb_cow_head() to deal with cloned skbs
Date: Wed, 19 Apr 2017 09:59:23 -0700
Message-ID: <20170419165926.30631-4-edumazet@google.com>
References: <20170419165926.30631-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f179.google.com ([209.85.213.179]:35625 "EHLO
        mail-yb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967454AbdDSQ7o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:59:44 -0400
Received: by mail-yb0-f179.google.com with SMTP id 6so7396167ybq.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:59:44 -0700 (PDT)
In-Reply-To: <20170419165926.30631-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to ensure there is enough headroom to push extra header,
but we also need to check if we are allowed to change headers.

skb_cow_head() is the proper helper to deal with this.

Fixes: c9b37458e956 ("USB2NET : SR9700 : One chip USB 1.1 USB2NET SR9700Device Driver Support")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Hughes <james.hughes@raspberrypi.org>
---
 drivers/net/usb/sr9700.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
index 4a1e9c489f1f455388ffee289d65e1d6b36cba42..aadfe1d1c37ee67e2a7d17c759db12dad248c41d 100644
--- a/drivers/net/usb/sr9700.c
+++ b/drivers/net/usb/sr9700.c
@@ -456,14 +456,9 @@ static struct sk_buff *sr9700_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 
 	len = skb->len;
 
-	if (skb_headroom(skb) < SR_TX_OVERHEAD) {
-		struct sk_buff *skb2;
-
-		skb2 = skb_copy_expand(skb, SR_TX_OVERHEAD, 0, flags);
+	if (skb_cow_head(skb, SR_TX_OVERHEAD)) {
 		dev_kfree_skb_any(skb);
-		skb = skb2;
-		if (!skb)
-			return NULL;
+		return NULL;
 	}
 
 	__skb_push(skb, SR_TX_OVERHEAD);
-- 
2.12.2.816.g2cccc81164-goog

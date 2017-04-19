From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 5/6] ch9200: use skb_cow_head() to deal with cloned skbs
Date: Wed, 19 Apr 2017 09:59:25 -0700
Message-ID: <20170419165926.30631-6-edumazet@google.com>
References: <20170419165926.30631-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Matthew Garrett <mjg59@srcf.ucam.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f173.google.com ([209.85.213.173]:35956 "EHLO
        mail-yb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967453AbdDSQ7n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:59:43 -0400
Received: by mail-yb0-f173.google.com with SMTP id s22so9067026ybe.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:59:43 -0700 (PDT)
In-Reply-To: <20170419165926.30631-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to ensure there is enough headroom to push extra header,
but we also need to check if we are allowed to change headers.

skb_cow_head() is the proper helper to deal with this.

Fixes: 4a476bd6d1d9 ("usbnet: New driver for QinHeng CH9200 devices")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Hughes <james.hughes@raspberrypi.org>
Cc: Matthew Garrett <mjg59@srcf.ucam.org>
---
 drivers/net/usb/ch9200.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/ch9200.c b/drivers/net/usb/ch9200.c
index 8a40202c0a1732850da1b2eb64af21470b9c85b4..c4f1c363e24b89404c6834312074f8a4451ded50 100644
--- a/drivers/net/usb/ch9200.c
+++ b/drivers/net/usb/ch9200.c
@@ -254,14 +254,9 @@ static struct sk_buff *ch9200_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 	tx_overhead = 0x40;
 
 	len = skb->len;
-	if (skb_headroom(skb) < tx_overhead) {
-		struct sk_buff *skb2;
-
-		skb2 = skb_copy_expand(skb, tx_overhead, 0, flags);
+	if (skb_cow_head(skb, tx_overhead)) {
 		dev_kfree_skb_any(skb);
-		skb = skb2;
-		if (!skb)
-			return NULL;
+		return NULL;
 	}
 
 	__skb_push(skb, tx_overhead);
-- 
2.12.2.816.g2cccc81164-goog

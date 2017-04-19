From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 2/6] cx82310_eth: use skb_cow_head() to deal with cloned skbs
Date: Wed, 19 Apr 2017 09:59:22 -0700
Message-ID: <20170419165926.30631-3-edumazet@google.com>
References: <20170419165926.30631-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f180.google.com ([209.85.213.180]:32799 "EHLO
        mail-yb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752788AbdDSQ7w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:59:52 -0400
Received: by mail-yb0-f180.google.com with SMTP id 81so8846520ybp.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:59:46 -0700 (PDT)
In-Reply-To: <20170419165926.30631-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to ensure there is enough headroom to push extra header,
but we also need to check if we are allowed to change headers.

skb_cow_head() is the proper helper to deal with this.

Fixes: cc28a20e77b2 ("introduce cx82310_eth: Conexant CX82310-based ADSL router USB ethernet driver")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Hughes <james.hughes@raspberrypi.org>
---
 drivers/net/usb/cx82310_eth.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/cx82310_eth.c b/drivers/net/usb/cx82310_eth.c
index e221bfcee76b40a3ad7ba60ec4d348f4b8f4cc73..947bea81d924124c3827e87f75e732e35adb2acd 100644
--- a/drivers/net/usb/cx82310_eth.c
+++ b/drivers/net/usb/cx82310_eth.c
@@ -293,12 +293,9 @@ static struct sk_buff *cx82310_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 {
 	int len = skb->len;
 
-	if (skb_headroom(skb) < 2) {
-		struct sk_buff *skb2 = skb_copy_expand(skb, 2, 0, flags);
+	if (skb_cow_head(skb, 2)) {
 		dev_kfree_skb_any(skb);
-		skb = skb2;
-		if (!skb)
-			return NULL;
+		return NULL;
 	}
 	skb_push(skb, 2);
 
-- 
2.12.2.816.g2cccc81164-goog

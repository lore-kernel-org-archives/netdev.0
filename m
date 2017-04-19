From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 1/6] smsc75xx: use skb_cow_head() to deal with cloned skbs
Date: Wed, 19 Apr 2017 09:59:21 -0700
Message-ID: <20170419165926.30631-2-edumazet@google.com>
References: <20170419165926.30631-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f172.google.com ([209.85.213.172]:35856 "EHLO
        mail-yb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967455AbdDSQ7o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:59:44 -0400
Received: by mail-yb0-f172.google.com with SMTP id s22so9062278ybe.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:59:44 -0700 (PDT)
In-Reply-To: <20170419165926.30631-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to ensure there is enough headroom to push extra header,
but we also need to check if we are allowed to change headers.

skb_cow_head() is the proper helper to deal with this.

Fixes: d0cad871703b ("smsc75xx: SMSC LAN75xx USB gigabit ethernet adapter driver")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Hughes <james.hughes@raspberrypi.org>
---
 drivers/net/usb/smsc75xx.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 0b17b40d7a4fa2653caf21406c4a6b3b45d868b0..190de9a90f7387c5070c7f589aa18bb7d05ac5d7 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -2203,13 +2203,9 @@ static struct sk_buff *smsc75xx_tx_fixup(struct usbnet *dev,
 {
 	u32 tx_cmd_a, tx_cmd_b;
 
-	if (skb_headroom(skb) < SMSC75XX_TX_OVERHEAD) {
-		struct sk_buff *skb2 =
-			skb_copy_expand(skb, SMSC75XX_TX_OVERHEAD, 0, flags);
+	if (skb_cow_head(skb, SMSC75XX_TX_OVERHEAD)) {
 		dev_kfree_skb_any(skb);
-		skb = skb2;
-		if (!skb)
-			return NULL;
+		return NULL;
 	}
 
 	tx_cmd_a = (u32)(skb->len & TX_CMD_A_LEN) | TX_CMD_A_FCS;
-- 
2.12.2.816.g2cccc81164-goog

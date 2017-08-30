From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] xen-netfront: be more drop monitor friendly
Date: Wed, 30 Aug 2017 10:32:58 -0700
Message-ID: <1504114378.11498.124.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33069 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752016AbdH3RdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:33:01 -0400
Received: by mail-pg0-f68.google.com with SMTP id m15so5545854pgc.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 10:33:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

xennet_start_xmit() might copy skb with inappropriate layout
into a fresh one.

Old skb is freed, and at this point it is not a drop, but
a consume. New skb will then be either consumed or dropped. 

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/xen-netfront.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 7b61adb6270c..523387e71a80 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -611,7 +611,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		nskb = skb_copy(skb, GFP_ATOMIC);
 		if (!nskb)
 			goto drop;
-		dev_kfree_skb_any(skb);
+		dev_consume_skb_any(skb);
 		skb = nskb;
 		page = virt_to_page(skb->data);
 		offset = offset_in_page(skb->data);

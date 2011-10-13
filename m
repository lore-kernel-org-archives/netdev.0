From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ftmac100: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 23:20:08 +0200
Message-ID: <1318540808.2533.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36860 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346Ab1JMVUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 17:20:12 -0400
Received: by wyg34 with SMTP id 34so2360245wyg.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 14:20:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ftmac100 allocates a page per skb fragment. We must account
PAGE_SIZE increments on skb->truesize, not the actual frag length.

If frame is under 64 bytes, page is freed, so increase truesize only for
bigger frames.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Po-Yu Chuang <ratbert@faraday-tech.com>
---
 drivers/net/ethernet/faraday/ftmac100.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index 9bd7746..a127cb2 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -439,7 +439,10 @@ static bool ftmac100_rx_packet(struct ftmac100 *priv, int *processed)
 	skb_fill_page_desc(skb, 0, page, 0, length);
 	skb->len += length;
 	skb->data_len += length;
-	skb->truesize += length;
+
+	/* page might be freed in __pskb_pull_tail() */
+	if (length > 64)
+		skb->truesize += PAGE_SIZE;
 	__pskb_pull_tail(skb, min(length, 64));
 
 	ftmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);

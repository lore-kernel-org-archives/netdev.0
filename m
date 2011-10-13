From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ftgmac100: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 23:30:52 +0200
Message-ID: <1318541452.2533.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44122 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754595Ab1JMVa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 17:30:57 -0400
Received: by wwf22 with SMTP id 22so2470274wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 14:30:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ftgmac100 allocates a page per skb fragment. We must account
PAGE_SIZE increments on skb->truesize, not the actual frag length.

If frame is under 64 bytes, page is freed, and truesize adjusted.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Po-Yu Chuang <ratbert@faraday-tech.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 54709af..fb5579a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -467,7 +467,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 
 		skb->len += size;
 		skb->data_len += size;
-		skb->truesize += size;
+		skb->truesize += PAGE_SIZE;
 
 		if (ftgmac100_rxdes_last_segment(rxdes))
 			done = true;
@@ -478,6 +478,8 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 		rxdes = ftgmac100_current_rxdes(priv);
 	} while (!done);
 
+	if (skb->len <= 64)
+		skb->truesize -= PAGE_SIZE;
 	__pskb_pull_tail(skb, min(skb->len, 64U));
 	skb->protocol = eth_type_trans(skb, netdev);
 

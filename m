From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: ftgmac100/ftmac100: dont pull too much data
Date: Thu, 12 Jul 2012 16:19:38 +0200
Message-ID: <1342102778.3265.8272.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46571 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933801Ab2GLOTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:19:43 -0400
Received: by bkwj10 with SMTP id j10so2190951bkw.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 07:19:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Drivers should pull only ethernet header from page frag
to skb->head.

Pulling 64 bytes is too much for TCP (without options) on IPv4.

However, it makes sense to pull all the frame if it fits the
128 bytes bloc allocated for skb->head, to free one page per
small incoming frame.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Po-Yu Chuang <ratbert@faraday-tech.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c |    9 +++++++--
 drivers/net/ethernet/faraday/ftmac100.c  |   11 +++++++----
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 16b0704..74d749e 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -479,9 +479,14 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 		rxdes = ftgmac100_current_rxdes(priv);
 	} while (!done);
 
-	if (skb->len <= 64)
+	/* Small frames are copied into linear part of skb to free one page */
+	if (skb->len <= 128) {
 		skb->truesize -= PAGE_SIZE;
-	__pskb_pull_tail(skb, min(skb->len, 64U));
+		__pskb_pull_tail(skb, skb->len);
+	} else {
+		/* We pull the minimum amount into linear part */
+		__pskb_pull_tail(skb, ETH_HLEN);
+	}
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	netdev->stats.rx_packets++;
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index 829b109..b901a01 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -441,11 +441,14 @@ static bool ftmac100_rx_packet(struct ftmac100 *priv, int *processed)
 	skb->len += length;
 	skb->data_len += length;
 
-	/* page might be freed in __pskb_pull_tail() */
-	if (length > 64)
+	if (length > 128) {
 		skb->truesize += PAGE_SIZE;
-	__pskb_pull_tail(skb, min(length, 64));
-
+		/* We pull the minimum amount into linear part */
+		__pskb_pull_tail(skb, ETH_HLEN);
+	} else {
+		/* Small frames are copied into linear part to free one page */
+		__pskb_pull_tail(skb, length);
+	}
 	ftmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
 
 	ftmac100_rx_pointer_advance(priv);

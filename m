From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sky2: use GFP_KERNEL allocations at device setup
Date: Thu, 07 Jul 2011 15:11:28 +0200
Message-ID: <1310044288.2127.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40204 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755577Ab1GGNLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 09:11:41 -0400
Received: by wwe5 with SMTP id 5so942886wwe.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 06:11:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In process and sleep allowed context, favor GFP_KERNEL allocations over
GFP_ATOMIC ones.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/sky2.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index e14b86e..c91513e 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1362,13 +1362,14 @@ static inline unsigned sky2_rx_pad(const struct sky2_hw *hw)
  * Allocate an skb for receiving. If the MTU is large enough
  * make the skb non-linear with a fragment list of pages.
  */
-static struct sk_buff *sky2_rx_alloc(struct sky2_port *sky2)
+static struct sk_buff *sky2_rx_alloc(struct sky2_port *sky2, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	int i;
 
-	skb = netdev_alloc_skb(sky2->netdev,
-			       sky2->rx_data_size + sky2_rx_pad(sky2->hw));
+	skb = __netdev_alloc_skb(sky2->netdev,
+				 sky2->rx_data_size + sky2_rx_pad(sky2->hw),
+				 gfp);
 	if (!skb)
 		goto nomem;
 
@@ -1386,7 +1387,7 @@ static struct sk_buff *sky2_rx_alloc(struct sky2_port *sky2)
 		skb_reserve(skb, NET_IP_ALIGN);
 
 	for (i = 0; i < sky2->rx_nfrags; i++) {
-		struct page *page = alloc_page(GFP_ATOMIC);
+		struct page *page = alloc_page(gfp);
 
 		if (!page)
 			goto free_partial;
@@ -1416,7 +1417,7 @@ static int sky2_alloc_rx_skbs(struct sky2_port *sky2)
 	for (i = 0; i < sky2->rx_pending; i++) {
 		struct rx_ring_info *re = sky2->rx_ring + i;
 
-		re->skb = sky2_rx_alloc(sky2);
+		re->skb = sky2_rx_alloc(sky2, GFP_KERNEL);
 		if (!re->skb)
 			return -ENOMEM;
 
@@ -2384,7 +2385,7 @@ static struct sk_buff *receive_new(struct sky2_port *sky2,
 	struct rx_ring_info nre;
 	unsigned hdr_space = sky2->rx_data_size;
 
-	nre.skb = sky2_rx_alloc(sky2);
+	nre.skb = sky2_rx_alloc(sky2, GFP_ATOMIC);
 	if (unlikely(!nre.skb))
 		goto nobuf;
 



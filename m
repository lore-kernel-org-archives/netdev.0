From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] myri10ge: fix truesize underestimation
Date: Thu, 20 Oct 2011 22:10:03 +0200
Message-ID: <1319141403.2854.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jon Mason <mason@myri.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37869 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727Ab1JTUKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 16:10:09 -0400
Received: by wyg36 with SMTP id 36so3282737wyg.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 13:10:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->truesize must account for allocated memory, not the used part of
it. Doing this work is important to avoid unexpected OOM situations.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jon Mason <mason@myri.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index c970a48..0778edc 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1210,7 +1210,6 @@ myri10ge_rx_skb_build(struct sk_buff *skb, u8 * va,
 	struct skb_frag_struct *skb_frags;
 
 	skb->len = skb->data_len = len;
-	skb->truesize = len + sizeof(struct sk_buff);
 	/* attach the page(s) */
 
 	skb_frags = skb_shinfo(skb)->frags;
@@ -1385,6 +1384,8 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
 	if (skb_frag_size(&skb_shinfo(skb)->frags[0]) <= 0) {
 		skb_frag_unref(skb, 0);
 		skb_shinfo(skb)->nr_frags = 0;
+	} else {
+		skb->truesize += bytes * skb_shinfo(skb)->nr_frags;
 	}
 	skb->protocol = eth_type_trans(skb, dev);
 	skb_record_rx_queue(skb, ss - &mgp->ss[0]);

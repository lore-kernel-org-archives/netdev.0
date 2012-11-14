From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH net-next 3/3] myri10ge: Use skb_fill_page_desc().
Date: Wed, 14 Nov 2012 08:06:42 -0500
Message-ID: <50A39762.1070707@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:37840 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422804Ab2KNNGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 08:06:45 -0500
Received: by mail-gg0-f174.google.com with SMTP id k2so45932ggd.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 05:06:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that LRO is gone, the receive routine is much simpler, and
we are able to use the standard skb_fill_page_desc() in myri10ge.

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
  drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   11 ++++-------
  1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c 
b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index b9b6dfd..82e9dcc 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1347,17 +1347,14 @@ myri10ge_rx_done(struct myri10ge_slice_state 
*ss, int len, __wsum csum)
  	/* Fill skb_frag_struct(s) with data from our receive */
  	for (i = 0, remainder = len; remainder > 0; i++) {
  		myri10ge_unmap_rx_page(pdev, &rx->info[idx], bytes);
-		__skb_frag_set_page(&rx_frags[i], rx->info[idx].page);
-		rx_frags[i].page_offset = rx->info[idx].page_offset;
-		if (remainder < MYRI10GE_ALLOC_SIZE)
-			skb_frag_size_set(&rx_frags[i], remainder);
-		else
-			skb_frag_size_set(&rx_frags[i], MYRI10GE_ALLOC_SIZE);
+		skb_fill_page_desc(skb, i, rx->info[idx].page,
+				   rx->info[idx].page_offset,
+				   remainder < MYRI10GE_ALLOC_SIZE ?
+				   remainder : MYRI10GE_ALLOC_SIZE);
  		rx->cnt++;
  		idx = rx->cnt & rx->mask;
  		remainder -= MYRI10GE_ALLOC_SIZE;
  	}
-	skb_shinfo(skb)->nr_frags = i;

  	/* remove padding */
  	rx_frags[0].page_offset += MXGEFW_PAD;
-- 
1.7.9.5

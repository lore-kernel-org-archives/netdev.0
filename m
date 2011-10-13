From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] niu: fix skb truesize underestimation
Date: Fri, 14 Oct 2011 00:39:27 +0200
Message-ID: <1318545567.2533.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63573 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473Ab1JMWjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 18:39:31 -0400
Received: by wwf22 with SMTP id 22so2542018wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 15:39:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a 'truesize' argument to niu_rx_skb_append(), filled with rcr_size
by the caller to properly account frag sizes in skb->truesize

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Please David double check this one as I am not very familiar with NIU
code. Thanks !

 drivers/net/ethernet/sun/niu.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index d133888..23740e8 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3287,17 +3287,13 @@ static u16 tcam_get_valid_entry_cnt(struct niu *np)
 }
 
 static void niu_rx_skb_append(struct sk_buff *skb, struct page *page,
-			      u32 offset, u32 size)
+			      u32 offset, u32 size, u32 truesize)
 {
-	int i = skb_shinfo(skb)->nr_frags;
-
-	__skb_fill_page_desc(skb, i, page, offset, size);
+	skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags, page, offset, size);
 
 	skb->len += size;
 	skb->data_len += size;
-	skb->truesize += size;
-
-	skb_shinfo(skb)->nr_frags = i + 1;
+	skb->truesize += truesize;
 }
 
 static unsigned int niu_hash_rxaddr(struct rx_ring_info *rp, u64 a)
@@ -3480,7 +3476,7 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 		} else if (!(val & RCR_ENTRY_MULTI))
 			append_size = len - skb->len;
 
-		niu_rx_skb_append(skb, page, off, append_size);
+		niu_rx_skb_append(skb, page, off, append_size, rcr_size);
 		if ((page->index + rp->rbr_block_size) - rcr_size == addr) {
 			*link = (struct page *) page->mapping;
 			np->ops->unmap_page(np->device, page->index,

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] bna: fix skb->truesize underestimation
Date: Fri, 17 Oct 2014 12:45:55 -0700
Message-ID: <1413575155.27176.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:59264 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753677AbaJQTp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 15:45:57 -0400
Received: by mail-pa0-f54.google.com with SMTP id ey11so1416003pad.13
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 12:45:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb->truesize is not meant to be tracking amount of used bytes
in an skb, but amount of reserved/consumed bytes in memory.

For instance, if we use a single byte in last page fragment,
we have to account the full size of the fragment.

skb->truesize can be very different from skb->len, that has
a very specific safety purpose.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Rasesh Mody <rasesh.mody@qlogic.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 153cafac323c..c3861de9dc81 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -552,6 +552,7 @@ bnad_cq_setup_skb_frags(struct bna_rcb *rcb, struct sk_buff *skb,
 
 		len = (vec == nvecs) ?
 			last_fraglen : unmap->vector.len;
+		skb->truesize += unmap->vector.len;
 		totlen += len;
 
 		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
@@ -563,7 +564,6 @@ bnad_cq_setup_skb_frags(struct bna_rcb *rcb, struct sk_buff *skb,
 
 	skb->len += totlen;
 	skb->data_len += totlen;
-	skb->truesize += totlen;
 }
 
 static inline void

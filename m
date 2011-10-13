From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] vmxnet3: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 23:38:17 +0200
Message-ID: <1318541897.2533.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51409 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037Ab1JMViW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 17:38:22 -0400
Received: by wwf22 with SMTP id 22so2478256wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 14:38:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vmxnet3 allocates a page per skb fragment. We must account
PAGE_SIZE increments on skb->truesize, not the actual frag length.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Shreyas Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 1694038..902f284 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -658,6 +658,7 @@ vmxnet3_append_frag(struct sk_buff *skb, struct Vmxnet3_RxCompDesc *rcd,
 	frag->page_offset = 0;
 	frag->size = rcd->len;
 	skb->data_len += frag->size;
+	skb->truesize += PAGE_SIZE;
 	skb_shinfo(skb)->nr_frags++;
 }
 
@@ -1277,7 +1278,6 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 		skb = ctx->skb;
 		if (rcd->eop) {
 			skb->len += skb->data_len;
-			skb->truesize += skb->data_len;
 
 			vmxnet3_rx_csum(adapter, skb,
 					(union Vmxnet3_GenericDesc *)rcd);

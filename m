From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: gro: allow to build full sized skb
Date: Tue, 08 Oct 2013 09:02:23 -0700
Message-ID: <1381248143.12191.53.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:54383 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab3JHQC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 12:02:26 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so9126409pab.27
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 09:02:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb_gro_receive() is currently limited to 16 or 17 MSS per GRO skb,
typically 24616 bytes, because it fills up to MAX_SKB_FRAGS frags.

It's relatively easy to extend the skb using frag_list to allow
more frags to be appended into the last sk_buff.

This still builds very efficient skbs, and allows reaching 45 MSS per
skb.

(45 MSS GRO packet uses one skb plus a frag_list containing 2 additional
sk_buff)

High speed TCP flows benefit from this extension by lowering TCP stack
cpu usage (less packets stored in receive queue, less ACK packets
processed)

Forwarding setups could be hurt, as such skbs will need to be
linearized, although its not a new problem, as GRO could already
provide skbs with a frag_list.

We could make the 65536 bytes threshold a tunable to mitigate this.

(First time we need to linearize skb in skb_needs_linearize(), we could
lower the tunable to ~16*1460 so that following skb_gro_receive() calls
build smaller skbs)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   43 ++++++++++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 17 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d81cff1..8ead744 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2936,32 +2936,30 @@ EXPORT_SYMBOL_GPL(skb_segment);
 
 int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
-	struct sk_buff *p = *head;
-	struct sk_buff *nskb;
-	struct skb_shared_info *skbinfo = skb_shinfo(skb);
-	struct skb_shared_info *pinfo = skb_shinfo(p);
-	unsigned int headroom;
-	unsigned int len = skb_gro_len(skb);
+	struct skb_shared_info *pinfo, *skbinfo = skb_shinfo(skb);
 	unsigned int offset = skb_gro_offset(skb);
 	unsigned int headlen = skb_headlen(skb);
+	struct sk_buff *nskb, *lp, *p = *head;
+	unsigned int len = skb_gro_len(skb);
 	unsigned int delta_truesize;
+	unsigned int headroom;
 
-	if (p->len + len >= 65536)
+	if (unlikely(p->len + len >= 65536))
 		return -E2BIG;
 
-	if (pinfo->frag_list)
-		goto merge;
-	else if (headlen <= offset) {
+	lp = NAPI_GRO_CB(p)->last ?: p;
+	pinfo = skb_shinfo(lp);
+
+	if (headlen <= offset) {
 		skb_frag_t *frag;
 		skb_frag_t *frag2;
 		int i = skbinfo->nr_frags;
 		int nr_frags = pinfo->nr_frags + i;
 
-		offset -= headlen;
-
 		if (nr_frags > MAX_SKB_FRAGS)
-			return -E2BIG;
+			goto merge;
 
+		offset -= headlen;
 		pinfo->nr_frags = nr_frags;
 		skbinfo->nr_frags = 0;
 
@@ -2992,7 +2990,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		unsigned int first_offset;
 
 		if (nr_frags + 1 + skbinfo->nr_frags > MAX_SKB_FRAGS)
-			return -E2BIG;
+			goto merge;
 
 		first_offset = skb->data -
 			       (unsigned char *)page_address(page) +
@@ -3010,7 +3008,10 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		delta_truesize = skb->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
 		NAPI_GRO_CB(skb)->free = NAPI_GRO_FREE_STOLEN_HEAD;
 		goto done;
-	} else if (skb_gro_len(p) != pinfo->gso_size)
+	}
+	if (pinfo->frag_list)
+		goto merge;
+	if (skb_gro_len(p) != pinfo->gso_size)
 		return -E2BIG;
 
 	headroom = skb_headroom(p);
@@ -3062,16 +3063,24 @@ merge:
 
 	__skb_pull(skb, offset);
 
-	NAPI_GRO_CB(p)->last->next = skb;
+	if (!NAPI_GRO_CB(p)->last)
+		skb_shinfo(p)->frag_list = skb;
+	else
+		NAPI_GRO_CB(p)->last->next = skb;
 	NAPI_GRO_CB(p)->last = skb;
 	skb_header_release(skb);
+	lp = p;
 
 done:
 	NAPI_GRO_CB(p)->count++;
 	p->data_len += len;
 	p->truesize += delta_truesize;
 	p->len += len;
-
+	if (lp != p) {
+		lp->data_len += len;
+		lp->truesize += delta_truesize;
+		lp->len += len;
+	}
 	NAPI_GRO_CB(skb)->same_flow = 1;
 	return 0;
 }

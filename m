From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] gro: fix truesize underestimation
Date: Mon, 13 Feb 2012 15:09:20 +0100
Message-ID: <1329142160.2494.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49469 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106Ab2BMOJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 09:09:24 -0500
Received: by wics10 with SMTP id s10so3483369wic.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 06:09:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_gro_receive() doesnt update truesize properly when adding one skb to
frag_list.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/core/skbuff.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index da0c97f..f3a5307 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2906,7 +2906,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	nskb->prev = p;
 
 	nskb->data_len += p->len;
-	nskb->truesize += p->len;
+	nskb->truesize += p->truesize;
 	nskb->len += p->len;
 
 	*head = nskb;
@@ -2916,6 +2916,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	p = nskb;
 
 merge:
+	p->truesize += skb->truesize - len;
 	if (offset > headlen) {
 		unsigned int eat = offset - headlen;
 

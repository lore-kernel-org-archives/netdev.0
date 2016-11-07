From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net-gro: avoid reorders
Date: Mon, 07 Nov 2016 11:12:27 -0800
Message-ID: <1478545947.17367.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36777 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932795AbcKGTNk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 14:13:40 -0500
Received: by mail-pf0-f194.google.com with SMTP id n85so16848232pfi.3
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 11:12:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Receiving a GSO packet in dev_gro_receive() is not uncommon
in stacked devices, or devices partially implementing LRO/GRO
like bnx2x. GRO is implementing the aggregation the device
was not able to do itself.

Current code causes reorders, like in following case :

For a given flow where sender sent 3 packets P1,P2,P3,P4

Receiver might receive P1 as a single packet, stored in GRO engine.

Then P2-P4 are received as a single GSO packet, immediately given to
upper stack, while P1 is held in GRO engine.

This patch will make sure P1 is given to upper stack, then P2-P4
immediately after.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f23e28668f32..b77cde68967c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4482,7 +4482,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
 
-	if (skb_is_gso(skb) || skb_has_frag_list(skb) || skb->csum_bad)
+	if (skb->csum_bad)
 		goto normal;
 
 	gro_list_prepare(napi, skb);
@@ -4495,7 +4495,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		skb_set_network_header(skb, skb_gro_offset(skb));
 		skb_reset_mac_len(skb);
 		NAPI_GRO_CB(skb)->same_flow = 0;
-		NAPI_GRO_CB(skb)->flush = 0;
+		NAPI_GRO_CB(skb)->flush = skb_is_gso(skb) || skb_has_frag_list(skb);
 		NAPI_GRO_CB(skb)->free = 0;
 		NAPI_GRO_CB(skb)->encap_mark = 0;
 		NAPI_GRO_CB(skb)->recursion_counter = 0;

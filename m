From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH] ip_gre: include route header_len in max_headroom calculation
Date: Sat, 20 Mar 2010 14:27:58 +0200
Message-ID: <1269088078-7343-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:53265 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965Ab0CTM2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 08:28:04 -0400
Received: by ey-out-2122.google.com with SMTP id d26so359442eyd.19
        for <netdev@vger.kernel.org>; Sat, 20 Mar 2010 05:28:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taking route's header_len into account, and updating gre device
needed_headroom will give better hints on upper bound of required
headroom. This is useful if the gre traffic is xfrm'ed.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/ipv4/ip_gre.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

This was earlier discussed in netdev thread:
  http://marc.info/?t=124470870200004&r=1&w=2

I just never got to writing the patch until now.

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f47c9f7..f78402d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -810,11 +810,13 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			tunnel->err_count = 0;
 	}
 
-	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen;
+	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + rt->u.dst.header_len;
 
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
 	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
+		if (max_headroom > dev->needed_headroom)
+			dev->needed_headroom = max_headroom;
 		if (!new_skb) {
 			ip_rt_put(rt);
 			txq->tx_dropped++;
-- 
1.6.3.3


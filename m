From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/13] bridge: Do br_pass_frame_up after other ports
Date: Fri, 26 Feb 2010 23:35:05 +0800
Message-ID: <E1Nl2DZ-0006uq-SS@gondolin.me.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52503 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965046Ab0BZPfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 10:35:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Do br_pass_frame_up after other ports

At the moment we deliver to the local bridge port via the function
br_pass_frame_up before all other ports.  There is no requirement
for this.

For the purpose of IGMP snooping, it would be more convenient if
we did the local port last.  Therefore this patch rearranges the
bridge input processing so that the local bridge port gets to see
the packet last (if at all).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_input.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 5ee1a36..9589937 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -73,9 +73,6 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	if (skb2 == skb)
 		skb2 = skb_clone(skb, GFP_ATOMIC);
 
-	if (skb2)
-		br_pass_frame_up(br, skb2);
-
 	if (skb) {
 		if (dst)
 			br_forward(dst->dst, skb);
@@ -83,6 +80,9 @@ int br_handle_frame_finish(struct sk_buff *skb)
 			br_flood_forward(br, skb);
 	}
 
+	if (skb2)
+		br_pass_frame_up(br, skb2);
+
 out:
 	return 0;
 drop:

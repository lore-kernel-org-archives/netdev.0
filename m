From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: macvlan: Move skb_clone check closer to call
Date: Sat, 7 Sep 2013 12:27:11 +1000
Message-ID: <20130907022711.GA22613@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50803 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751060Ab3IGC1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 22:27:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently macvlan calls skb_clone in macvlan_broadcast but checks
for a NULL return in macvlan_broadcast_one instead.  This is
needlessly confusing and may lead to bugs introduced later.

This patch moves the error check to where the skb_clone call is.

The only other caller of macvlan_broadcast_one never passes in a
NULL value so it doesn't need the check either.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 64dfaa3..9bf46bd 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -118,8 +118,6 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
 				 const struct ethhdr *eth, bool local)
 {
 	struct net_device *dev = vlan->dev;
-	if (!skb)
-		return NET_RX_DROP;
 
 	if (local)
 		return vlan->forward(dev, skb);
@@ -171,9 +169,13 @@ static void macvlan_broadcast(struct sk_buff *skb,
 			hash = mc_hash(vlan, eth->h_dest);
 			if (!test_bit(hash, vlan->mc_filter))
 				continue;
+
+			err = NET_RX_DROP;
 			nskb = skb_clone(skb, GFP_ATOMIC);
-			err = macvlan_broadcast_one(nskb, vlan, eth,
-					 mode == MACVLAN_MODE_BRIDGE);
+			if (likely(nskb))
+				err = macvlan_broadcast_one(
+					nskb, vlan, eth,
+					mode == MACVLAN_MODE_BRIDGE);
 			macvlan_count_rx(vlan, skb->len + ETH_HLEN,
 					 err == NET_RX_SUCCESS, 1);
 		}

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: skb_tx_hash() fix relative to skb_orphan_try()
Date: Tue, 13 Jul 2010 17:24:20 +0200
Message-ID: <1279034660.2634.439.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53349 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965Ab0GMPax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 11:30:53 -0400
Received: by wwi17 with SMTP id 17so1144747wwi.1
        for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 08:30:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fc6055a5ba31e2 (net: Introduce skb_orphan_try()) added early
orphaning of skbs.

This unfortunately added a performance regression in skb_tx_hash() in
case of stacked devices (bonding, vlans, ...)

Since skb->sk is now NULL, we cannot access sk->sk_hash anymore to
spread tx packets to multiple NIC queues on multiqueue devices.

skb_tx_hash() in this case only uses skb->protocol, same value for all
flows.

skb_orphan_try() can copy sk->sk_hash into skb->rxhash and skb_tx_hash()
can use this saved sk_hash value to compute its internal hash value.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 723a347..70a900a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1911,8 +1911,16 @@ static int dev_gso_segment(struct sk_buff *skb)
  */
 static inline void skb_orphan_try(struct sk_buff *skb)
 {
-	if (!skb_tx(skb)->flags)
+	struct sock *sk = skb->sk;
+
+	if (sk && !skb_tx(skb)->flags) {
+		/* skb_tx_hash() wont be able to get sk.
+		 * We copy sk_hash into skb->rxhash
+		 */ 
+		if (!skb->rxhash)
+			skb->rxhash = sk->sk_hash;
 		skb_orphan(skb);
+	}
 }
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
@@ -1998,8 +2006,7 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 	if (skb->sk && skb->sk->sk_hash)
 		hash = skb->sk->sk_hash;
 	else
-		hash = (__force u16) skb->protocol;
-
+		hash = (__force u16) skb->protocol ^ skb->rxhash;
 	hash = jhash_1word(hash, hashrnd);
 
 	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);




From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Thu, 22 Apr 2010 00:54:21 -0700 (PDT)
Message-ID: <20100422.005421.155629785.davem@davemloft.net>
References: <1271921637.7895.4791.camel@edumazet-laptop>
	<20100422.004136.151480121.davem@davemloft.net>
	<1271922423.7895.4819.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35654
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752576Ab0DVHyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:54:18 -0400
In-Reply-To: <1271922423.7895.4819.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Apr 2010 09:47:03 +0200

> You could have one skb_orphan_try() call before the
> 
> if (netif_needs_gso(dev, skb)) {
> 
> and remove it from dev_gso_segment() ?

Yes, that's much more concise.  This should be ready to go:

net: Orphan and de-dst skbs earlier in xmit path.

This way GSO packets don't get handled differently.

With help from Eric Dumazet.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 3ba774b..a4a7c36 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1902,13 +1902,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
 
-		if (netif_needs_gso(dev, skb)) {
-			if (unlikely(dev_gso_segment(skb)))
-				goto out_kfree_skb;
-			if (skb->next)
-				goto gso;
-		}
-
 		/*
 		 * If device doesnt need skb->dst, release it right now while
 		 * its hot in this cpu cache
@@ -1917,6 +1910,14 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			skb_dst_drop(skb);
 
 		skb_orphan_try(skb);
+
+		if (netif_needs_gso(dev, skb)) {
+			if (unlikely(dev_gso_segment(skb)))
+				goto out_kfree_skb;
+			if (skb->next)
+				goto gso;
+		}
+
 		rc = ops->ndo_start_xmit(skb, dev);
 		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);

From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH v3 2/2] net/core: dev_forward_skb() should clear skb_iif
Date: Tue, 27 Mar 2012 21:55:44 -0400
Message-ID: <20120328015544.GA11104@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:56835 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755483Ab2C1Bzo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 21:55:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While investigating another bug, I found that the code on the incoming path
in __netif_receive_skb will only set skb->skb_iif if it is already 0.  When
dev_forward_skb() is used in the case of interfaces like veth, skb_iif may
already have been set.  Making dev_forward_skb() cause the packet to look
like a newly received packet would seem to the the correct behaviour here,
as otherwise the wrong incoming interface can be reported for such a packet.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 net/core/dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 452db70..723a406 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1597,6 +1597,7 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
+	skb->skb_iif = 0;
 	skb_set_dev(skb, dev);
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
-- 
1.7.4.1


-- 
"Thought is the essence of where you are now."

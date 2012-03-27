From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH net/core] dev_forward_skb() should clear skb_iif
Date: Tue, 27 Mar 2012 12:29:20 -0400
Message-ID: <20120327162920.GB2367@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:55075 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827Ab2C0Q3U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 12:29:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While investigating another bug, I found that the code on the incoming path
in __netif_receive_skb will only set skb->skb_iif if it is already 0.  When
dev_forward_skb() is used in the case of interfaces like veth, skb_iif may
already have been set.  Making dev_forward_skb() cause the packet to look
more like a newly received packet would seem to the the correct behaviour
here, as otherwise the wrong incoming interface can be reported for such a
packet.
---
 net/core/dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0090809..8751f6a 100644
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

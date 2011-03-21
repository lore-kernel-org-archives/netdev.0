From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Handle gso packets in dev_forward_skb
Date: Mon, 21 Mar 2011 14:25:16 -0700
Message-ID: <m1wrjsi2tf.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:55316 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754631Ab1CUVZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 17:25:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Today when gso packets reach dev_forward_skb through the macvlan driver
we drop them on the floor because they exceed the device mtu.  Ouch!

I don't undersand the subtelties of gso but I think it is sufficient to
simply relax the checks and let gso packets through without an mtu
check, and it works in my test case.

If needed we can split the gso packets into multiple packets here but
that just seems like a wast of memory and time.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/core/dev.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0b88eba..2e26606 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1527,17 +1527,21 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	skb_orphan(skb);
 	nf_reset(skb);
 
-	if (unlikely(!(dev->flags & IFF_UP) ||
-		     (skb->len > (dev->mtu + dev->hard_header_len + VLAN_HLEN)))) {
-		atomic_long_inc(&dev->rx_dropped);
-		kfree_skb(skb);
-		return NET_RX_DROP;
-	}
+	if (unlikely(!(dev->flags & IFF_UP)))
+		goto kfree_skb;
+	/* Don't check mtu on gso packets... */
+	if (unlikely(!skb_is_gso(skb) &&
+		     (skb->len > (dev->mtu + dev->hard_header_len + VLAN_HLEN))))
+		goto kfree_skb;
 	skb_set_dev(skb, dev);
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, dev);
 	return netif_rx(skb);
+kfree_skb:
+	atomic_long_inc(&dev->rx_dropped);
+	kfree_skb(skb);
+	return NET_RX_DROP;
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
 
-- 
1.7.4


From: Daniel Lezcano <daniel@free.fr>
Subject: [V4] dev : fix mtu check when TSO is enabled
Date: Wed, 30 Mar 2011 11:40:35 +0200
Message-ID: <1301478035-324-1-git-send-email-daniel@free.fr>
Cc: ebiederm@xmission.com, eric.dumazet@gmail.com, kaber@trash.net,
	nightnord@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:43633 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296Ab1C3Jk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 05:40:56 -0400
Received: from d06nrmr1507.portsmouth.uk.ibm.com (d06nrmr1507.portsmouth.uk.ibm.com [9.149.38.233])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p2U9etTU030045
	for <netdev@vger.kernel.org>; Wed, 30 Mar 2011 09:40:55 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2U9fTA81499346
	for <netdev@vger.kernel.org>; Wed, 30 Mar 2011 10:41:29 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2U9esBN025959
	for <netdev@vger.kernel.org>; Wed, 30 Mar 2011 03:40:54 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <daniel.lezcano@free.fr>

In case the device where is coming from the packet has TSO enabled,
we should not check the mtu size value as this one could be bigger
than the expected value.

This is the case for the macvlan driver when the lower device has
TSO enabled. The macvlan inherit this feature and forward the packets
without fragmenting them. Then the packets go through dev_forward_skb
and are dropped. This patch fix this by checking TSO is not enabled
when we want to check the mtu size.

Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Andrian Nord <nightnord@gmail.com>
---
 net/core/dev.c |   24 ++++++++++++++++++++++--
 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 563ddc2..3da9fb0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1454,6 +1454,27 @@ static inline void net_timestamp_check(struct sk_buff *skb)
 		__net_timestamp(skb);
 }
 
+static inline bool is_skb_forwardable(struct net_device *dev,
+				      struct sk_buff *skb)
+{
+	unsigned int len;
+
+	if (!(dev->flags & IFF_UP))
+		return false;
+
+	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
+	if (skb->len <= len)
+		return true;
+
+	/* if TSO is enabled, we don't care about the length as the packet
+	 * could be forwarded without being segmented before
+	 */
+	if (skb_is_gso(skb))
+		return true;
+
+	return false;
+}
+
 /**
  * dev_forward_skb - loopback an skb to another netif
  *
@@ -1477,8 +1498,7 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	skb_orphan(skb);
 	nf_reset(skb);
 
-	if (unlikely(!(dev->flags & IFF_UP) ||
-		     (skb->len > (dev->mtu + dev->hard_header_len + VLAN_HLEN)))) {
+	if (unlikely(!is_skb_forwardable(dev, skb))) {
 		atomic_long_inc(&dev->rx_dropped);
 		kfree_skb(skb);
 		return NET_RX_DROP;
-- 
1.7.1


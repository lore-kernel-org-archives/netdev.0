From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: [PATCH][v2] dev : fix mtu check when TSO is enabled
Date: Mon, 14 Mar 2011 20:10:59 +0100
Message-ID: <1300129859-9525-1-git-send-email-daniel.lezcano@free.fr>
Cc: eric.dumazet@gmail.com, kaber@trash.net, nightnord@gmail.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:53076 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560Ab1CNTLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 15:11:19 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate5.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p2EJBGp6030803
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 19:11:16 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EJBYN21794104
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 19:11:34 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost.localdomain [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EJBFjd016020
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 13:11:16 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the device where is coming from the packet has TSO enabled,
we should not check the mtu size value as this one could be bigger
than the expected value.

This is the case for the macvlan driver when the lower device has
TSO enabled. The macvlan inherit this feature and forward the packets
without fragmenting them. Then the packets go through dev_forward_skb
and are dropped. This patch fix this by checking TSO is not enabled
when we want to check the mtu size.

Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Andrian Nord <nightnord@gmail.com>
---
 net/core/dev.c |   24 ++++++++++++++++++++++--
 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6561021..f1607a0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1503,6 +1503,27 @@ static inline void net_timestamp_check(struct sk_buff *skb)
 		__net_timestamp(skb);
 }
 
+static inline bool is_skb_forwardable(struct net_device *dev,
+				      struct sk_buff *skb)
+{
+	unsigned int len;
+
+	if (!dev->flags & IFF_UP)
+		return false;
+
+	/* we should not check the mtu size if TSO is enabled otherwise
+	 * we may have a packet with a length bigger than the expected
+	 * one as it was not segmented before */
+	if (skb->dev && skb->dev->features & NETIF_F_TSO)
+		return true;
+
+	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
+	if (skb->len > len)
+		return false;
+
+	return true;
+}
+
 /**
  * dev_forward_skb - loopback an skb to another netif
  *
@@ -1526,8 +1547,7 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
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


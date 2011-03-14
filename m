From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: [PATCH 2/2] dev : fix mtu check when TSO is enabled
Date: Mon, 14 Mar 2011 17:08:08 +0100
Message-ID: <1300118888-2311-2-git-send-email-daniel.lezcano@free.fr>
References: <1300118888-2311-1-git-send-email-daniel.lezcano@free.fr>
Cc: kaber@trash.net, nightnord@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:55357 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753646Ab1CNQIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 12:08:19 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p2EG8I76015542
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 16:08:18 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EG8aSh1826892
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 16:08:36 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EG8H2w012975
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 10:08:18 -0600
In-Reply-To: <1300118888-2311-1-git-send-email-daniel.lezcano@free.fr>
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
Cc: Patrick McHardy <kaber@trash.net>
Cc: Andrian Nord <nightnord@gmail.com>
---
 net/core/dev.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6561021..010a0a9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1526,8 +1526,10 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	skb_orphan(skb);
 	nf_reset(skb);
 
-	if (unlikely(!(dev->flags & IFF_UP) ||
-		     (skb->len > (dev->mtu + dev->hard_header_len + VLAN_HLEN)))) {
+	if (unlikely(!(skb->dev->features & NETIF_F_TSO) &&
+		     (!(dev->flags & IFF_UP) ||
+		      (skb->len > (dev->mtu +
+				   dev->hard_header_len + VLAN_HLEN))))) {
 		atomic_long_inc(&dev->rx_dropped);
 		kfree_skb(skb);
 		return NET_RX_DROP;
-- 
1.7.1


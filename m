From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] arp: RCU change in arp_solicit()
Date: Tue, 22 Jun 2010 19:43:15 +0200
Message-ID: <1277228595.3057.730.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61739 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515Ab0FVRnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 13:43:21 -0400
Received: by wyi11 with SMTP id 11so68843wyi.19
        for <netdev@vger.kernel.org>; Tue, 22 Jun 2010 10:43:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid two atomic ops in arp_solicit()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/arp.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index cf78f41..09ead1b 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -333,11 +333,14 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	struct net_device *dev = neigh->dev;
 	__be32 target = *(__be32*)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
-	struct in_device *in_dev = in_dev_get(dev);
+	struct in_device *in_dev;
 
-	if (!in_dev)
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(dev);
+	if (!in_dev) {
+		rcu_read_unlock();
 		return;
-
+	}
 	switch (IN_DEV_ARP_ANNOUNCE(in_dev)) {
 	default:
 	case 0:		/* By default announce any local IP */
@@ -358,9 +361,8 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	case 2:		/* Avoid secondary IPs, get a primary/preferred one */
 		break;
 	}
+	rcu_read_unlock();
 
-	if (in_dev)
-		in_dev_put(in_dev);
 	if (!saddr)
 		saddr = inet_select_addr(dev, target, RT_SCOPE_LINK);
 



From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] netpoll: fix smatch warnings in netpoll core code
Date: Wed, 13 Feb 2013 11:32:42 -0500
Message-ID: <1360773162-11949-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37850 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759377Ab3BMQdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 11:33:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter contacted me with some notes regarding some smatch warnings in the
netpoll code, some of which I introduced with my recent netpoll locking fixes,
some which were there prior.   Specifically they were:

net-next/net/core/netpoll.c:243 netpoll_poll_dev() warn: inconsistent
  returns mutex:&ni->dev_lock: locked (213,217) unlocked (210,243)
net-next/net/core/netpoll.c:706 netpoll_neigh_reply() warn: potential
  pointer math issue ('skb_transport_header(send_skb)' is a 128 bit pointer)

This patch corrects the locking imbalance (the first error), and adds some
parenthesis to correct the second error.  Tested by myself. Applies to net-next

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Dan Carpenter <dan.carpenter@oracle.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 net/core/netpoll.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index bcfd4f4..fa32899 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -209,12 +209,16 @@ static void netpoll_poll_dev(struct net_device *dev)
 	if (!mutex_trylock(&ni->dev_lock))
 		return;
 
-	if (!dev || !netif_running(dev))
+	if (!netif_running(dev)) {
+		mutex_unlock(&ni->dev_lock);
 		return;
+	}
 
 	ops = dev->netdev_ops;
-	if (!ops->ndo_poll_controller)
+	if (!ops->ndo_poll_controller) {
+		mutex_unlock(&ni->dev_lock);
 		return;
+	}
 
 	/* Process pending work on NIC */
 	ops->ndo_poll_controller(dev);
@@ -703,7 +707,7 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 			icmp6h->icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT;
 			icmp6h->icmp6_router = 0;
 			icmp6h->icmp6_solicited = 1;
-			target = (struct in6_addr *)skb_transport_header(send_skb) + sizeof(struct icmp6hdr);
+			target = (struct in6_addr *)(skb_transport_header(send_skb) + sizeof(struct icmp6hdr));
 			*target = msg->target;
 			icmp6h->icmp6_cksum = csum_ipv6_magic(saddr, daddr, size,
 							      IPPROTO_ICMPV6,
-- 
1.7.11.7

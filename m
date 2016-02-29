From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 3/3] net: Use l3_dev instead of skb->dev for L3 processing
Date: Mon, 29 Feb 2016 14:08:24 -0800
Message-ID: <1456783704-18746-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33242 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbcB2WI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 17:08:28 -0500
Received: by mail-pa0-f68.google.com with SMTP id y7so9295812paa.0
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:08:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

netif_receive_skb_core() dispatcher uses skb->dev device to send it
to the packet-handlers (e.g. ip_rcv, ipv6_rcv etc). These packet
handlers intern use the device passed to determine the net-ns to
further process these packets.  Now with the nomination logic, the
dispatcher will call netif_get_l3_dev() helper to select the device
to be used for this processing. Since l3_dev is initialized to self,
normal packet processing should not change.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Tim Hockin <thockin@google.com>
CC: Alex Pollitt <alex.pollitt@metaswitch.com>
CC: Matthew Dupre <matthew.dupre@metaswitch.com>
---
 net/core/dev.c       | 9 ++++++---
 net/ipv4/ip_input.c  | 5 +++--
 net/ipv6/ip6_input.c | 5 +++--
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c4023a68cdc1..9252436ef11a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1811,7 +1811,8 @@ static inline int deliver_skb(struct sk_buff *skb,
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 		return -ENOMEM;
 	atomic_inc(&skb->users);
-	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+	return pt_prev->func(skb, netif_get_l3_dev(skb->dev), pt_prev,
+			     orig_dev);
 }
 
 static inline void deliver_ptype_list_skb(struct sk_buff *skb,
@@ -1904,7 +1905,8 @@ again:
 	}
 out_unlock:
 	if (pt_prev)
-		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
+		pt_prev->func(skb2, netif_get_l3_dev(skb->dev), pt_prev,
+			      skb->dev);
 	rcu_read_unlock();
 }
 
@@ -4157,7 +4159,8 @@ ncls:
 		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 			goto drop;
 		else
-			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+			ret = pt_prev->func(skb, netif_get_l3_dev(skb->dev),
+					    pt_prev, orig_dev);
 	} else {
 drop:
 		if (!deliver_exact)
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index e3d782746d9d..b47164e3e1c6 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -247,7 +247,8 @@ int ip_local_deliver(struct sk_buff *skb)
 	/*
 	 *	Reassemble IP fragments.
 	 */
-	struct net *net = dev_net(skb->dev);
+	struct net_device *dev = netif_get_l3_dev(skb->dev);
+	struct net *net = dev_net(dev);
 
 	if (ip_is_fragment(ip_hdr(skb))) {
 		if (ip_defrag(net, skb, IP_DEFRAG_LOCAL_DELIVER))
@@ -255,7 +256,7 @@ int ip_local_deliver(struct sk_buff *skb)
 	}
 
 	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN,
-		       net, NULL, skb, skb->dev, NULL,
+		       net, NULL, skb, dev, NULL,
 		       ip_local_deliver_finish);
 }
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index c05c425c2389..88443ac06402 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -287,9 +287,10 @@ discard:
 
 int ip6_input(struct sk_buff *skb)
 {
+	struct net_device *dev = netif_get_l3_dev(skb->dev);
+
 	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN,
-		       dev_net(skb->dev), NULL, skb, skb->dev, NULL,
-		       ip6_input_finish);
+		       dev_net(dev), NULL, skb, dev, NULL, ip6_input_finish);
 }
 
 int ip6_mc_input(struct sk_buff *skb)
-- 
2.7.0.rc3.207.g0ac5344

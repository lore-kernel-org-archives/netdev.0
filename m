From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v2 2/7] dev: Update packet dispatcher to pass l3_dev as an input device
Date: Wed,  9 Mar 2016 13:49:59 -0800
Message-ID: <1457560199-13007-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33917 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbcCIVuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 16:50:03 -0500
Received: by mail-pf0-f196.google.com with SMTP id 184so4419363pff.1
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 13:50:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

netif_receive_skb_core() dispatcher uses skb->dev device as an
input device to all packet-handlers (e.g. ip_rcv, ipv6_rcv etc)
These packet handlers use this device reference to start processing
L3 phase of the packet-processing. This includes IPT hooks, ingress
route-lookup, and xfrm policy lookups etc.

This patch passes l3_dev as an input device and shifts L3 processing
from skb->dev to l3_dev (skb->dev->l3_dev).

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Tim Hockin <thockin@google.com>
CC: Alex Pollitt <alex.pollitt@metaswitch.com>
CC: Matthew Dupre <matthew.dupre@metaswitch.com>
---
 net/core/dev.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

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
-- 
2.7.0.rc3.207.g0ac5344

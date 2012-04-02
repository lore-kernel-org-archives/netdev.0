From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 09/51] nfnetlink_queue: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:57:59 -0400
Message-ID: <1333335521-1348-10-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149Ab2DBC7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:17 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nfnetlink_queue.c |   59 +++++++++++++++++++++++----------------
 1 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index a80b0cb..8d6bcf3 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -288,58 +288,67 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	indev = entry->indev;
 	if (indev) {
 #ifndef CONFIG_BRIDGE_NETFILTER
-		NLA_PUT_BE32(skb, NFQA_IFINDEX_INDEV, htonl(indev->ifindex));
+		if (nla_put_be32(skb, NFQA_IFINDEX_INDEV, htonl(indev->ifindex)))
+			goto nla_put_failure;
 #else
 		if (entry->pf == PF_BRIDGE) {
 			/* Case 1: indev is physical input device, we need to
 			 * look for bridge group (when called from
 			 * netfilter_bridge) */
-			NLA_PUT_BE32(skb, NFQA_IFINDEX_PHYSINDEV,
-				     htonl(indev->ifindex));
+			if (nla_put_be32(skb, NFQA_IFINDEX_PHYSINDEV,
+					 htonl(indev->ifindex)) ||
 			/* this is the bridge group "brX" */
 			/* rcu_read_lock()ed by __nf_queue */
-			NLA_PUT_BE32(skb, NFQA_IFINDEX_INDEV,
-				     htonl(br_port_get_rcu(indev)->br->dev->ifindex));
+			    nla_put_be32(skb, NFQA_IFINDEX_INDEV,
+					 htonl(br_port_get_rcu(indev)->br->dev->ifindex)))
+				goto nla_put_failure;
 		} else {
 			/* Case 2: indev is bridge group, we need to look for
 			 * physical device (when called from ipv4) */
-			NLA_PUT_BE32(skb, NFQA_IFINDEX_INDEV,
-				     htonl(indev->ifindex));
-			if (entskb->nf_bridge && entskb->nf_bridge->physindev)
-				NLA_PUT_BE32(skb, NFQA_IFINDEX_PHYSINDEV,
-					     htonl(entskb->nf_bridge->physindev->ifindex));
+			if (nla_put_be32(skb, NFQA_IFINDEX_INDEV,
+					 htonl(indev->ifindex)))
+				goto nla_put_failure;
+			if (entskb->nf_bridge && entskb->nf_bridge->physindev &&
+			    nla_put_be32(skb, NFQA_IFINDEX_PHYSINDEV,
+					 htonl(entskb->nf_bridge->physindev->ifindex)))
+				goto nla_put_failure;
 		}
 #endif
 	}
 
 	if (outdev) {
 #ifndef CONFIG_BRIDGE_NETFILTER
-		NLA_PUT_BE32(skb, NFQA_IFINDEX_OUTDEV, htonl(outdev->ifindex));
+		if (nla_put_be32(skb, NFQA_IFINDEX_OUTDEV, htonl(outdev->ifindex)))
+			goto nla_put_failure;
 #else
 		if (entry->pf == PF_BRIDGE) {
 			/* Case 1: outdev is physical output device, we need to
 			 * look for bridge group (when called from
 			 * netfilter_bridge) */
-			NLA_PUT_BE32(skb, NFQA_IFINDEX_PHYSOUTDEV,
-				     htonl(outdev->ifindex));
+			if (nla_put_be32(skb, NFQA_IFINDEX_PHYSOUTDEV,
+					 htonl(outdev->ifindex)) ||
 			/* this is the bridge group "brX" */
 			/* rcu_read_lock()ed by __nf_queue */
-			NLA_PUT_BE32(skb, NFQA_IFINDEX_OUTDEV,
-				     htonl(br_port_get_rcu(outdev)->br->dev->ifindex));
+			    nla_put_be32(skb, NFQA_IFINDEX_OUTDEV,
+					 htonl(br_port_get_rcu(outdev)->br->dev->ifindex)))
+				goto nla_put_failure;
 		} else {
 			/* Case 2: outdev is bridge group, we need to look for
 			 * physical output device (when called from ipv4) */
-			NLA_PUT_BE32(skb, NFQA_IFINDEX_OUTDEV,
-				     htonl(outdev->ifindex));
-			if (entskb->nf_bridge && entskb->nf_bridge->physoutdev)
-				NLA_PUT_BE32(skb, NFQA_IFINDEX_PHYSOUTDEV,
-					     htonl(entskb->nf_bridge->physoutdev->ifindex));
+			if (nla_put_be32(skb, NFQA_IFINDEX_OUTDEV,
+					 htonl(outdev->ifindex)))
+				goto nla_put_failure;
+			if (entskb->nf_bridge && entskb->nf_bridge->physoutdev &&
+			    nla_put_be32(skb, NFQA_IFINDEX_PHYSOUTDEV,
+					 htonl(entskb->nf_bridge->physoutdev->ifindex)))
+				goto nla_put_failure;
 		}
 #endif
 	}
 
-	if (entskb->mark)
-		NLA_PUT_BE32(skb, NFQA_MARK, htonl(entskb->mark));
+	if (entskb->mark &&
+	    nla_put_be32(skb, NFQA_MARK, htonl(entskb->mark)))
+		goto nla_put_failure;
 
 	if (indev && entskb->dev &&
 	    entskb->mac_header != entskb->network_header) {
@@ -347,7 +356,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		int len = dev_parse_header(entskb, phw.hw_addr);
 		if (len) {
 			phw.hw_addrlen = htons(len);
-			NLA_PUT(skb, NFQA_HWADDR, sizeof(phw), &phw);
+			if (nla_put(skb, NFQA_HWADDR, sizeof(phw), &phw))
+				goto nla_put_failure;
 		}
 	}
 
@@ -357,7 +367,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		ts.sec = cpu_to_be64(tv.tv_sec);
 		ts.usec = cpu_to_be64(tv.tv_usec);
 
-		NLA_PUT(skb, NFQA_TIMESTAMP, sizeof(ts), &ts);
+		if (nla_put(skb, NFQA_TIMESTAMP, sizeof(ts), &ts))
+			goto nla_put_failure;
 	}
 
 	if (data_len) {
-- 
1.7.7.6

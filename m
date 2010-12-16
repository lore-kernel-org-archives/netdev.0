From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 13:57:25 +0800
Message-ID: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:60489 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab0LPF5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 00:57:50 -0500
Received: by pwj3 with SMTP id 3so370708pwj.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 21:57:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dev_queue_xmit_nit(), we have to clone skbs as we need to mangle skbs,
however, we don't need to clone skbs for all the packet_types.

Except for the first packet_type, we increase skb->users instead of
skb_clone().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |   30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index bf5ced5..888cb74 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1496,6 +1496,14 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
 
+static inline int deliver_skb(struct sk_buff *skb,
+			      struct packet_type *pt_prev,
+			      struct net_device *orig_dev)
+{
+	atomic_inc(&skb->users);
+	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+}
+
 /*
  *	Support routine. Sends outgoing frames to any network
  *	taps currently in use.
@@ -1504,6 +1512,8 @@ EXPORT_SYMBOL_GPL(dev_forward_skb);
 static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct packet_type *ptype;
+	struct sk_buff *skb2 = NULL;
+	struct packet_type *pt_prev = NULL;
 
 #ifdef CONFIG_NET_CLS_ACT
 	if (!(skb->tstamp.tv64 && (G_TC_FROM(skb->tc_verd) & AT_INGRESS)))
@@ -1520,7 +1530,13 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		if ((ptype->dev == dev || !ptype->dev) &&
 		    (ptype->af_packet_priv == NULL ||
 		     (struct sock *)ptype->af_packet_priv != skb->sk)) {
-			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
+			if (pt_prev) {
+				deliver_skb(skb2, pt_prev, skb->dev);
+				pt_prev = ptype;
+				continue;
+			}
+
+			skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (!skb2)
 				break;
 
@@ -1542,9 +1558,11 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 
 			skb2->transport_header = skb2->network_header;
 			skb2->pkt_type = PACKET_OUTGOING;
-			ptype->func(skb2, skb->dev, ptype, skb->dev);
+			pt_prev = ptype;
 		}
 	}
+	if (pt_prev)
+		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
 	rcu_read_unlock();
 }
 
@@ -2788,14 +2806,6 @@ static void net_tx_action(struct softirq_action *h)
 	}
 }
 
-static inline int deliver_skb(struct sk_buff *skb,
-			      struct packet_type *pt_prev,
-			      struct net_device *orig_dev)
-{
-	atomic_inc(&skb->users);
-	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
-}
-
 #if (defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)) && \
     (defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE))
 /* This hook is defined here for ATM LANE */

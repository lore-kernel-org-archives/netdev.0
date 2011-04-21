From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 1/2] net: Export dev_queue_xmit_nit for use by macvlan driver
Date: Thu, 21 Apr 2011 09:31:32 -0400
Message-ID: <1303392693-1350-2-git-send-email-david.ward@ll.mit.edu>
References: <1303392693-1350-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:39521 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981Ab1DUNnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 09:43:16 -0400
In-Reply-To: <1303392693-1350-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export dev_queue_xmit_nit for use by the macvlan virtual network device
driver. Also, use 'dev' instead of 'skb->dev' in this function.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |   14 +++++++++-----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb8178a..b63e517 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2099,6 +2099,8 @@ extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct netdev_queue *txq);
 extern int		dev_forward_skb(struct net_device *dev,
 					struct sk_buff *skb);
+extern void		dev_queue_xmit_nit(struct sk_buff *skb,
+					   struct net_device *dev);
 
 extern int		netdev_budget;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 3871bf6..e851227 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1520,11 +1520,13 @@ static inline int deliver_skb(struct sk_buff *skb,
 }
 
 /*
- *	Support routine. Sends outgoing frames to any network
- *	taps currently in use.
+ * dev_queue_xmit_nit - send outgoing frame to AF_PACKET sockets
+ *
+ * @skb: buffer to send
+ * @dev: network device that AF_PACKET sockets are attached to (if any)
  */
 
-static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
+void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct packet_type *ptype;
 	struct sk_buff *skb2 = NULL;
@@ -1539,7 +1541,8 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		    (ptype->af_packet_priv == NULL ||
 		     (struct sock *)ptype->af_packet_priv != skb->sk)) {
 			if (pt_prev) {
-				deliver_skb(skb2, pt_prev, skb->dev);
+				atomic_inc(&skb2->users);
+				pt_prev->func(skb2, dev, pt_prev, dev);
 				pt_prev = ptype;
 				continue;
 			}
@@ -1572,9 +1575,10 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 	if (pt_prev)
-		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
+		pt_prev->func(skb2, dev, pt_prev, dev);
 	rcu_read_unlock();
 }
+EXPORT_SYMBOL(dev_queue_xmit_nit);
 
 /* netif_setup_tc - Handle tc mappings on real_num_tx_queues change
  * @dev: Network device
-- 
1.7.4


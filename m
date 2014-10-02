From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: better IFF_XMIT_DST_RELEASE support
Date: Thu, 02 Oct 2014 09:34:07 -0700
Message-ID: <1412267647.22242.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36539 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbaJBQeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 12:34:09 -0400
Received: by mail-pa0-f50.google.com with SMTP id kx10so2781344pab.23
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 09:34:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Testing xmit_more support with netperf and connected UDP sockets,
I found strange dst refcount false sharing.

Current handling of IFF_XMIT_DST_RELEASE is not optimal.

dropping dst in validate_xmit_skb() is certainly too late in case
packet was queued by cpu X but dequeued by cpu Y

The logical point to take care of drop/force is in __dev_queue_xmit()
before even taking qdisc lock.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    3 +--
 net/core/dev.c            |   16 ++++++++--------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9b7fbacb6296..ea8b23510c9e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1168,8 +1168,7 @@ struct net_device_ops {
  * @IFF_ISATAP: ISATAP interface (RFC4214)
  * @IFF_MASTER_ARPMON: bonding master, ARP mon in use
  * @IFF_WAN_HDLC: WAN HDLC device
- * @IFF_XMIT_DST_RELEASE: dev_hard_start_xmit() is allowed to
- *	release skb->dst
+ * @IFF_XMIT_DST_RELEASE: dev_queue_xmit() is allowed to release skb->dst
  * @IFF_DONT_BRIDGE: disallow bridging this ether dev
  * @IFF_DISABLE_NETPOLL: disable netpoll at run-time
  * @IFF_MACVLAN_PORT: device used as macvlan port
diff --git a/net/core/dev.c b/net/core/dev.c
index e55c546717d4..e178b16b2e53 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2662,11 +2662,6 @@ struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
 	if (skb->next)
 		return skb;
 
-	/* If device doesn't need skb->dst, release it right now while
-	 * its hot in this cpu cache
-	 */
-	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
-		skb_dst_drop(skb);
 
 	features = netif_skb_features(skb);
 	skb = validate_xmit_vlan(skb, features);
@@ -2781,8 +2776,6 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		 * waiting to be sent out; and the qdisc is not running -
 		 * xmit the skb directly.
 		 */
-		if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE))
-			skb_dst_force(skb);
 
 		qdisc_bstats_update(q, skb);
 
@@ -2798,7 +2791,6 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 
 		rc = NET_XMIT_SUCCESS;
 	} else {
-		skb_dst_force(skb);
 		rc = q->enqueue(skb, q) & NET_XMIT_MASK;
 		if (qdisc_run_begin(q)) {
 			if (unlikely(contended)) {
@@ -2895,6 +2887,14 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 	skb_update_prio(skb);
 
+	/* If device doesn't need skb->dst, release it right now while
+	 * its hot in this cpu cache
+	 */
+	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
+		skb_dst_drop(skb);
+	else
+		skb_dst_force(skb);
+
 	txq = netdev_pick_tx(dev, skb, accel_priv);
 	q = rcu_dereference_bh(txq->qdisc);
 

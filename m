From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] netpoll: call ->ndo_select_queue() in tx path
Date: Tue, 18 Sep 2012 14:16:31 +0800
Message-ID: <1347948991-20860-1-git-send-email-amwang@redhat.com>
Cc: Sylvain Munaut <s.munaut@whatever-company.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755817Ab2IRGQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 02:16:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In netpoll tx path, we miss the chance of calling ->ndo_select_queue(),
thus could cause problems when bonding is involved.

This patch makes dev_pick_tx() extern (and rename it to netdev_pick_tx())
to let netpoll call it in netpoll_send_skb_on_dev().

Reported-by: Sylvain Munaut <s.munaut@whatever-company.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
Tested-by: Sylvain Munaut <s.munaut@whatever-company.com>

---
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ae3153c0..72661f6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1403,6 +1403,9 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 		f(dev, &dev->_tx[i], arg);
 }
 
+extern struct netdev_queue *netdev_pick_tx(struct net_device *dev,
+					   struct sk_buff *skb);
+
 /*
  * Net namespace inlines
  */
diff --git a/net/core/dev.c b/net/core/dev.c
index dcc673d..b13317a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2381,8 +2381,8 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 #endif
 }
 
-static struct netdev_queue *dev_pick_tx(struct net_device *dev,
-					struct sk_buff *skb)
+struct netdev_queue *netdev_pick_tx(struct net_device *dev,
+				    struct sk_buff *skb)
 {
 	int queue_index;
 	const struct net_device_ops *ops = dev->netdev_ops;
@@ -2556,7 +2556,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 
 	skb_update_prio(skb);
 
-	txq = dev_pick_tx(dev, skb);
+	txq = netdev_pick_tx(dev, skb);
 	q = rcu_dereference_bh(txq->qdisc);
 
 #ifdef CONFIG_NET_CLS_ACT
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index dd67818..77a0388 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -328,7 +328,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 	if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
 		struct netdev_queue *txq;
 
-		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+		txq = netdev_pick_tx(dev, skb);
 
 		/* try until next clock tick */
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;

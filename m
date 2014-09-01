From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/9] net: Validate xmit SKBs right when we pull them out of
 the qdisc.
Date: Mon, 01 Sep 2014 15:25:08 -0700 (PDT)
Message-ID: <20140901.152508.1567495400745751943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaIAWZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:25:09 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 0AF81590920
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:25:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h | 1 +
 net/core/dev.c            | 6 +-----
 net/sched/sch_generic.c   | 5 ++++-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5050218..47c49ba 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2827,6 +2827,7 @@ int dev_set_mac_address(struct net_device *, struct sockaddr *);
 int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_port_id *ppid);
+struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev);
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq);
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 704a543..75bc5b0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2656,7 +2656,7 @@ struct sk_buff *validate_xmit_vlan(struct sk_buff *skb, netdev_features_t featur
 	return skb;
 }
 
-static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
+struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
 {
 	netdev_features_t features;
 
@@ -2719,10 +2719,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 {
 	int rc = NETDEV_TX_OK;
 
-	skb = validate_xmit_skb(skb, dev);
-	if (!skb)
-		return rc;
-
 	if (likely(!skb->next))
 		return xmit_one(skb, dev, txq, false);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 05b3f5d..f178798 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -70,8 +70,11 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 		} else
 			skb = NULL;
 	} else {
-		if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq))
+		if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq)) {
 			skb = q->dequeue(q);
+			if (skb)
+				skb = validate_xmit_skb(skb, qdisc_dev(q));
+		}
 	}
 
 	return skb;
-- 
1.7.11.7

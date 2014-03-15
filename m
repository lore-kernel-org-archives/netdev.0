From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 06/10] netpoll: Don't drop all received packets.
Date: Fri, 14 Mar 2014 20:48:28 -0700
Message-ID: <878uscp1f7.fsf_-_@xmission.com>
References: <87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
	<87eh24uu3d.fsf_-_@xmission.com>
	<20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:54616 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755570AbaCODse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 23:48:34 -0400
In-Reply-To: <877g7wqg8e.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 20:43:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Change the strategy of netpoll from dropping all packets received
during netpoll_poll_dev to calling napi poll with a budget of 0
(to avoid processing drivers rx queue), and to ignore packets received
with netif_rx (those will safely be placed on the backlog queue).

All of the netpoll supporting drivers have been reviewed to ensure
either thay use netif_rx or that a budget of 0 is supported by their
napi poll routine and that a budget of 0 will not process the drivers
rx queues.

Not dropping packets makes NETPOLL_RX_DROP unnecesary so it is removed.

npinfo->rx_flags is removed  as rx_flags with just the NETPOLL_RX_ENABLED
flag becomes just a redundant mirror of list_empty(&npinfo->rx_np).

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netpoll.h |    3 +--
 net/core/netpoll.c      |   17 ++++++-----------
 2 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 479d15c97770..154f9776056c 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -39,7 +39,6 @@ struct netpoll {
 struct netpoll_info {
 	atomic_t refcnt;
 
-	unsigned long rx_flags;
 	spinlock_t rx_lock;
 	struct semaphore dev_lock;
 	struct list_head rx_np; /* netpolls that registered an rx_skb_hook */
@@ -99,7 +98,7 @@ static inline bool netpoll_rx_on(struct sk_buff *skb)
 {
 	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
 
-	return npinfo && (netpoll_rx_processing(npinfo) || npinfo->rx_flags);
+	return npinfo && netpoll_rx_processing(npinfo);
 }
 
 static inline bool netpoll_rx(struct sk_buff *skb)
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index ef83a2530e98..793dc04d2f19 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -51,8 +51,6 @@ static atomic_t trapped;
 DEFINE_STATIC_SRCU(netpoll_srcu);
 
 #define USEC_PER_POLL	50
-#define NETPOLL_RX_ENABLED  1
-#define NETPOLL_RX_DROP     2
 
 #define MAX_SKB_SIZE							\
 	(sizeof(struct ethhdr) +					\
@@ -193,7 +191,8 @@ static void netpoll_poll_dev(struct net_device *dev)
 {
 	const struct net_device_ops *ops;
 	struct netpoll_info *ni = rcu_dereference_bh(dev->npinfo);
-	int budget = 16;
+	bool rx_processing = netpoll_rx_processing(ni);
+	int budget = rx_processing? 16 : 0;
 
 	/* Don't do any rx activity if the dev_lock mutex is held
 	 * the dev_open/close paths use this to block netpoll activity
@@ -207,8 +206,8 @@ static void netpoll_poll_dev(struct net_device *dev)
 		return;
 	}
 
-	ni->rx_flags |= NETPOLL_RX_DROP;
-	atomic_inc(&trapped);
+	if (rx_processing)
+		atomic_inc(&trapped);
 
 	ops = dev->netdev_ops;
 	if (!ops->ndo_poll_controller) {
@@ -221,8 +220,8 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	poll_napi(dev, budget);
 
-	atomic_dec(&trapped);
-	ni->rx_flags &= ~NETPOLL_RX_DROP;
+	if (rx_processing)
+		atomic_dec(&trapped);
 
 	up(&ni->dev_lock);
 
@@ -1050,7 +1049,6 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 			goto out;
 		}
 
-		npinfo->rx_flags = 0;
 		INIT_LIST_HEAD(&npinfo->rx_np);
 
 		spin_lock_init(&npinfo->rx_lock);
@@ -1076,7 +1074,6 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 
 	if (np->rx_skb_hook) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
 		list_add_tail(&np->rx, &npinfo->rx_np);
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
@@ -1258,8 +1255,6 @@ void __netpoll_cleanup(struct netpoll *np)
 	if (!list_empty(&npinfo->rx_np)) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_del(&np->rx);
-		if (list_empty(&npinfo->rx_np))
-			npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
 
-- 
1.7.5.4

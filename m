From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v4] netpoll: protect napi_poll and poll_controller during dev_[open|close]
Date: Sat,  2 Feb 2013 13:51:16 -0500
Message-ID: <1359831076-32476-1-git-send-email-nhorman@tuxdriver.com>
References: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Ivan Vecera <ivecera@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59233 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758053Ab3BBSvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 13:51:41 -0500
In-Reply-To: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vercera was recently backporting commit
9c13cb8bb477a83b9a3c9e5a5478a4e21294a760 to a RHEL kernel, and I noticed that,
while this patch protects the tg3 driver from having its ndo_poll_controller
routine called during device initalization, it does nothing for the driver
during shutdown. I.e. it would be entirely possible to have the
ndo_poll_controller method (or subsequently the ndo_poll) routine called for a
driver in the netpoll path on CPU A while in parallel on CPU B, the ndo_close or
ndo_open routine could be called.  Given that the two latter routines tend to
initizlize and free many data structures that the former two rely on, the result
can easily be data corruption or various other crashes.  Furthermore, it seems
that this is potentially a problem with all net drivers that support netpoll,
and so this should ideally be fixed in a common path.

As Ben H Pointed out to me, we can't preform dev_open/dev_close in atomic
context, so I've come up with this solution.  I've modified the npinfo->rx_flags
to make use of bitops, so that we can atomically set/clear individual bits.
We use one of these bits to provide mutual exclusion between the netpoll polling
path and the dev_open/close paths.  I can't say Im a huge fan of returning
-EBUSY in open/close, but I like it better than busy waiting while the poll path
completes.

I've tested this here by flooding netconsole with messages on a system whos nic
driver I modfied to periodically return NETDEV_TX_BUSY, so that the netpoll tx
workqueue would be forced to send frames and poll the device.  While this was
going on I rapidly ifdown/up'ed the interface and watched for any problems.
I've not found any.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Ivan Vecera <ivecera@redhat.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Ben Hutchings <bhutchings@solarflare.com>
CC: Francois Romieu <romieu@fr.zoreil.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>

---
Change notes

v3)
Updated netpoll_info to remove hole in struct on 64 bit arches (Eric D)

v4)
Fixed build break that occurs when CONFIG_NETPOLL not enabled (Fracois R)
---
 include/linux/netpoll.h | 41 +++++++++++++++++++++++++++++++++++++----
 net/core/dev.c          | 29 ++++++++++++++++++++++++++++-
 net/core/netpoll.c      | 23 ++++++++++++++++-------
 3 files changed, 81 insertions(+), 12 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index f54c3bb..305f754 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -35,10 +35,14 @@ struct netpoll {
 	struct rcu_head rcu;
 };
 
+#define NETPOLL_RX_ENABLED  1
+#define NETPOLL_RX_DROP     2
+#define NETPOLL_RX_ACTIVE   3
+
 struct netpoll_info {
 	atomic_t refcnt;
 
-	int rx_flags;
+	unsigned long flags;
 	spinlock_t rx_lock;
 	struct list_head rx_np; /* netpolls that registered an rx_hook */
 
@@ -51,6 +55,33 @@ struct netpoll_info {
 	struct rcu_head rcu;
 };
 
+static inline int netpoll_rx_disable(struct net_device *dev)
+{
+	int rc = 0;
+#ifdef CONFIG_NETPOLL
+	struct netpoll_info *ni;
+	rcu_read_lock();
+	ni = rcu_dereference(dev->npinfo);
+	if (ni && test_and_set_bit(NETPOLL_RX_ACTIVE, &ni->flags))
+		rc = -EBUSY;
+	rcu_read_unlock();
+
+#endif
+	return rc;
+}
+
+static inline void netpoll_rx_enable(struct net_device *dev)
+{
+#ifdef CONFIG_NETPOLL
+	struct netpoll_info *ni;
+	rcu_read_lock();
+	ni = rcu_dereference(dev->npinfo);
+	if (ni)
+		clear_bit(NETPOLL_RX_ACTIVE, &ni->flags);
+	rcu_read_unlock();
+#endif
+}
+
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
@@ -79,7 +110,8 @@ static inline bool netpoll_rx_on(struct sk_buff *skb)
 {
 	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
 
-	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
+	return npinfo && (!list_empty(&npinfo->rx_np) ||
+			   test_bit(NETPOLL_RX_ENABLED, &npinfo->flags));
 }
 
 static inline bool netpoll_rx(struct sk_buff *skb)
@@ -95,8 +127,9 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 
 	npinfo = rcu_dereference_bh(skb->dev->npinfo);
 	spin_lock(&npinfo->rx_lock);
-	/* check rx_flags again with the lock held */
-	if (npinfo->rx_flags && __netpoll_rx(skb, npinfo))
+	/* check flags again with the lock held */
+	if (test_bit(NETPOLL_RX_ENABLED, &npinfo->flags) &&
+	    __netpoll_rx(skb, npinfo))
 		ret = true;
 	spin_unlock(&npinfo->rx_lock);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index a87bc74..05b7116 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1259,6 +1259,7 @@ EXPORT_SYMBOL(dev_load);
 static int __dev_open(struct net_device *dev)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+
 	int ret;
 
 	ASSERT_RTNL();
@@ -1266,6 +1267,15 @@ static int __dev_open(struct net_device *dev)
 	if (!netif_device_present(dev))
 		return -ENODEV;
 
+	/*
+	 * Block netpoll from trying to do any rx path servicing
+	 * If we don't do this there is a chance ndo_poll_controller
+	 * or ndo_poll may be running while we open the device
+	 */
+	ret = netpoll_rx_disable(dev);
+	if (ret)
+		return ret;
+
 	ret = call_netdevice_notifiers(NETDEV_PRE_UP, dev);
 	ret = notifier_to_errno(ret);
 	if (ret)
@@ -1279,6 +1289,8 @@ static int __dev_open(struct net_device *dev)
 	if (!ret && ops->ndo_open)
 		ret = ops->ndo_open(dev);
 
+	netpoll_rx_enable(dev);
+
 	if (ret)
 		clear_bit(__LINK_STATE_START, &dev->state);
 	else {
@@ -1370,9 +1382,16 @@ static int __dev_close(struct net_device *dev)
 	int retval;
 	LIST_HEAD(single);
 
+	/* Temporarily disable netpoll until the interface is down */
+	retval = netpoll_rx_disable(dev);
+	if (retval)
+		return retval;
+
 	list_add(&dev->unreg_list, &single);
 	retval = __dev_close_many(&single);
 	list_del(&single);
+
+	netpoll_rx_enable(dev);
 	return retval;
 }
 
@@ -1408,14 +1427,22 @@ static int dev_close_many(struct list_head *head)
  */
 int dev_close(struct net_device *dev)
 {
+	int ret = 0;
 	if (dev->flags & IFF_UP) {
 		LIST_HEAD(single);
 
+		/* Block netpoll rx while the interface is going down*/
+		ret = netpoll_rx_disable(dev);
+		if (ret)
+			return ret;
+
 		list_add(&dev->unreg_list, &single);
 		dev_close_many(&single);
 		list_del(&single);
+
+		netpoll_rx_enable(dev);
 	}
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL(dev_close);
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 331ccb9..96c5bc5 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -48,8 +48,6 @@ static struct sk_buff_head skb_pool;
 static atomic_t trapped;
 
 #define USEC_PER_POLL	50
-#define NETPOLL_RX_ENABLED  1
-#define NETPOLL_RX_DROP     2
 
 #define MAX_SKB_SIZE							\
 	(sizeof(struct ethhdr) +					\
@@ -152,7 +150,7 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
 		return budget;
 
-	npinfo->rx_flags |= NETPOLL_RX_DROP;
+	set_bit(NETPOLL_RX_DROP, &npinfo->flags);
 	atomic_inc(&trapped);
 	set_bit(NAPI_STATE_NPSVC, &napi->state);
 
@@ -161,7 +159,7 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
 	atomic_dec(&trapped);
-	npinfo->rx_flags &= ~NETPOLL_RX_DROP;
+	clear_bit(NETPOLL_RX_DROP, &npinfo->flags);
 
 	return budget - work;
 }
@@ -199,6 +197,14 @@ static void netpoll_poll_dev(struct net_device *dev)
 	const struct net_device_ops *ops;
 	struct netpoll_info *ni = rcu_dereference_bh(dev->npinfo);
 
+	/*
+	 * Don't do any rx activity unless NETPOLL_RX_ACTIVE is clear
+	 * the dev_open/close paths use this to block netpoll activity
+	 * while changing device state
+	 */
+	if (test_and_set_bit(NETPOLL_RX_ACTIVE, &dev->npinfo->flags))
+		return;
+
 	if (!dev || !netif_running(dev))
 		return;
 
@@ -211,6 +217,8 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	poll_napi(dev);
 
+	clear_bit(NETPOLL_RX_ACTIVE, &dev->npinfo->flags);
+
 	if (dev->flags & IFF_SLAVE) {
 		if (ni) {
 			struct net_device *bond_dev;
@@ -229,6 +237,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 	service_neigh_queue(ni);
 
 	zap_completion_queue();
+
 }
 
 static void refill_skbs(void)
@@ -1000,7 +1009,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 			goto out;
 		}
 
-		npinfo->rx_flags = 0;
+		npinfo->flags = 0;
 		INIT_LIST_HEAD(&npinfo->rx_np);
 
 		spin_lock_init(&npinfo->rx_lock);
@@ -1025,7 +1034,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 
 	if (np->rx_hook) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
+		set_bit(NETPOLL_RX_ENABLED, &npinfo->flags);
 		list_add_tail(&np->rx, &npinfo->rx_np);
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
@@ -1204,7 +1213,7 @@ void __netpoll_cleanup(struct netpoll *np)
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_del(&np->rx);
 		if (list_empty(&npinfo->rx_np))
-			npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
+			clear_bit(NETPOLL_RX_ENABLED, &npinfo->flags);
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
 
-- 
1.7.11.7

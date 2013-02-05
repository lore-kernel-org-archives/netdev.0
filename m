From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v6] netpoll: protect napi_poll and poll_controller during dev_[open|close]
Date: Tue,  5 Feb 2013 13:05:43 -0500
Message-ID: <1360087543-16049-1-git-send-email-nhorman@tuxdriver.com>
References: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Ivan Vecera <ivecera@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39841 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754995Ab3BESF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 13:05:59 -0500
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
context, so I've come up with this solution.  We can use a mutex to sleep in
open/close paths and just do a mutex_trylock in the napi poll path and abandon
the poll attempt if we're locked, as we'll just retry the poll on the next send
anyway.

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

v5) Davem pointed out that wile the bit flag approach works, its really ugly to
have to return -EBUSY because of a transient event that should quickly clear.
Since we are in process context in the dev_open/close paths, I've switched to
using a mutex, and allowing the open/close paths to sleep if netpoll is active.
Since the netpoll path itself may execute in any context, we just do a
mutex_trylock there, and abandon the poll if its already held.  Either the
interface is going down, and the poll doesn't matter, or it'll just succede on
the next poll cycle anyway.  Note, I left Erics change in, as we can still save
some space by rearranging the netpoll_info structure.

v6) Fix comment and indentation sillyness from my previous rushing
---
 include/linux/netpoll.h | 11 ++++++++++-
 net/core/dev.c          | 27 ++++++++++++++++++++++++++-
 net/core/netpoll.c      | 40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 76 insertions(+), 2 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index f54c3bb..ab856d5 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -38,8 +38,9 @@ struct netpoll {
 struct netpoll_info {
 	atomic_t refcnt;
 
-	int rx_flags;
+	unsigned long rx_flags;
 	spinlock_t rx_lock;
+	struct mutex dev_lock;
 	struct list_head rx_np; /* netpolls that registered an rx_hook */
 
 	struct sk_buff_head neigh_tx; /* list of neigh requests to reply to */
@@ -51,6 +52,14 @@ struct netpoll_info {
 	struct rcu_head rcu;
 };
 
+#ifdef CONFIG_NETPOLL
+extern int netpoll_rx_disable(struct net_device *dev);
+extern void netpoll_rx_enable(struct net_device *dev);
+#else
+static inline int netpoll_rx_disable(struct net_device *dev) { return 0; }
+static inline void netpoll_rx_enable(struct net_device *dev) { return; }
+#endif
+
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
diff --git a/net/core/dev.c b/net/core/dev.c
index a87bc74..ac08c1c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1266,6 +1266,14 @@ static int __dev_open(struct net_device *dev)
 	if (!netif_device_present(dev))
 		return -ENODEV;
 
+	/* Block netpoll from trying to do any rx path servicing.
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
@@ -1279,6 +1287,8 @@ static int __dev_open(struct net_device *dev)
 	if (!ret && ops->ndo_open)
 		ret = ops->ndo_open(dev);
 
+	netpoll_rx_enable(dev);
+
 	if (ret)
 		clear_bit(__LINK_STATE_START, &dev->state);
 	else {
@@ -1370,9 +1380,16 @@ static int __dev_close(struct net_device *dev)
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
 
@@ -1408,14 +1425,22 @@ static int dev_close_many(struct list_head *head)
  */
 int dev_close(struct net_device *dev)
 {
+	int ret = 0;
 	if (dev->flags & IFF_UP) {
 		LIST_HEAD(single);
 
+		/* Block netpoll rx while the interface is going down */
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
index 331ccb9..edcd9ad 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -47,6 +47,8 @@ static struct sk_buff_head skb_pool;
 
 static atomic_t trapped;
 
+static struct srcu_struct netpoll_srcu;
+
 #define USEC_PER_POLL	50
 #define NETPOLL_RX_ENABLED  1
 #define NETPOLL_RX_DROP     2
@@ -199,6 +201,13 @@ static void netpoll_poll_dev(struct net_device *dev)
 	const struct net_device_ops *ops;
 	struct netpoll_info *ni = rcu_dereference_bh(dev->npinfo);
 
+	/* Don't do any rx activity if the dev_lock mutex is held
+	 * the dev_open/close paths use this to block netpoll activity
+	 * while changing device state
+	 */
+	if (!mutex_trylock(&dev->npinfo->dev_lock))
+		return;
+
 	if (!dev || !netif_running(dev))
 		return;
 
@@ -211,6 +220,8 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	poll_napi(dev);
 
+	mutex_unlock(&dev->npinfo->dev_lock);
+
 	if (dev->flags & IFF_SLAVE) {
 		if (ni) {
 			struct net_device *bond_dev;
@@ -231,6 +242,31 @@ static void netpoll_poll_dev(struct net_device *dev)
 	zap_completion_queue();
 }
 
+int netpoll_rx_disable(struct net_device *dev)
+{
+	struct netpoll_info *ni;
+	int idx;
+	might_sleep();
+	idx = srcu_read_lock(&netpoll_srcu);
+	ni = srcu_dereference(dev->npinfo, &netpoll_srcu);
+	if (ni)
+		mutex_lock(&ni->dev_lock);
+	srcu_read_unlock(&netpoll_srcu, idx);
+	return 0;
+}
+EXPORT_SYMBOL(netpoll_rx_disable);
+
+void netpoll_rx_enable(struct net_device *dev)
+{
+	struct netpoll_info *ni;
+	rcu_read_lock();
+	ni = rcu_dereference(dev->npinfo);
+	if (ni)
+		mutex_unlock(&ni->dev_lock);
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(netpoll_rx_enable);
+
 static void refill_skbs(void)
 {
 	struct sk_buff *skb;
@@ -1004,6 +1040,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 		INIT_LIST_HEAD(&npinfo->rx_np);
 
 		spin_lock_init(&npinfo->rx_lock);
+		mutex_init(&npinfo->dev_lock);
 		skb_queue_head_init(&npinfo->neigh_tx);
 		skb_queue_head_init(&npinfo->txq);
 		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
@@ -1169,6 +1206,7 @@ EXPORT_SYMBOL(netpoll_setup);
 static int __init netpoll_init(void)
 {
 	skb_queue_head_init(&skb_pool);
+	init_srcu_struct(&netpoll_srcu);
 	return 0;
 }
 core_initcall(netpoll_init);
@@ -1208,6 +1246,8 @@ void __netpoll_cleanup(struct netpoll *np)
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
 
+	synchronize_srcu(&netpoll_srcu);
+
 	if (atomic_dec_and_test(&npinfo->refcnt)) {
 		const struct net_device_ops *ops;
 
-- 
1.7.11.7

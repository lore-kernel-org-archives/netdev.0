From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 1/2] net: implement threaded-able napi poll loop support
Date: Tue, 10 May 2016 16:11:53 +0200
Message-ID: <5b4dd23c7cebb677abb61f211fde3de4a83441f7.1462886866.git.pabeni@redhat.com>
References: <cover.1462886866.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1462886866.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows running each napi poll loop inside its
own kernel thread.
The rx mode can be enabled per napi instance via the
newly addded napi_set_threaded() api; the requested kthread
will be created on demand and shut down on device stop.

Once that threaded mode is enabled and the kthread is
started, napi_schedule() will wake-up such thread instead
of scheduling the softirq.

The threaded poll loop behaves quite likely the net_rx_action,
but it does not have to manipulate local irqs and uses
an explicit scheduling point based on netdev_budget.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/netdevice.h |   4 ++
 net/core/dev.c            | 113 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 117 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 63580e6..0722ed5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -323,6 +323,7 @@ struct napi_struct {
 	struct list_head	dev_list;
 	struct hlist_node	napi_hash_node;
 	unsigned int		napi_id;
+	struct task_struct	*thread;
 };
 
 enum {
@@ -331,6 +332,7 @@ enum {
 	NAPI_STATE_NPSVC,	/* Netpoll - don't dequeue from poll_list */
 	NAPI_STATE_HASHED,	/* In NAPI hash (busy polling possible) */
 	NAPI_STATE_NO_BUSY_POLL,/* Do not add in napi_hash, no busy polling */
+	NAPI_STATE_THREADED,	/* The poll is performed inside its own thread*/
 };
 
 enum gro_result {
@@ -475,6 +477,8 @@ static inline void napi_complete(struct napi_struct *n)
  */
 void napi_hash_add(struct napi_struct *napi);
 
+int napi_set_threaded(struct napi_struct *n, bool threded);
+
 /**
  *	napi_hash_del - remove a NAPI from global table
  *	@napi: NAPI context
diff --git a/net/core/dev.c b/net/core/dev.c
index c749033..0de286b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -94,6 +94,7 @@
 #include <linux/ethtool.h>
 #include <linux/notifier.h>
 #include <linux/skbuff.h>
+#include <linux/kthread.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <net/busy_poll.h>
@@ -1305,9 +1306,19 @@ void netdev_notify_peers(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_notify_peers);
 
+static int napi_threaded_poll(void *data);
+
+static inline void napi_thread_start(struct napi_struct *n)
+{
+	if (test_bit(NAPI_STATE_THREADED, &n->state) && !n->thread)
+		n->thread = kthread_create(napi_threaded_poll, n, "%s-%d",
+					   n->dev->name, n->napi_id);
+}
+
 static int __dev_open(struct net_device *dev)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	struct napi_struct *n;
 	int ret;
 
 	ASSERT_RTNL();
@@ -1334,6 +1345,9 @@ static int __dev_open(struct net_device *dev)
 	if (!ret && ops->ndo_open)
 		ret = ops->ndo_open(dev);
 
+	list_for_each_entry(n, &dev->napi_list, dev_list)
+		napi_thread_start(n);
+
 	netpoll_poll_enable(dev);
 
 	if (ret)
@@ -1378,6 +1392,14 @@ int dev_open(struct net_device *dev)
 }
 EXPORT_SYMBOL(dev_open);
 
+static inline void napi_thread_stop(struct napi_struct *n)
+{
+	if (!n->thread)
+		return;
+	kthread_stop(n->thread);
+	n->thread = NULL;
+}
+
 static int __dev_close_many(struct list_head *head)
 {
 	struct net_device *dev;
@@ -1406,6 +1428,7 @@ static int __dev_close_many(struct list_head *head)
 
 	list_for_each_entry(dev, head, close_list) {
 		const struct net_device_ops *ops = dev->netdev_ops;
+		struct napi_struct *n;
 
 		/*
 		 *	Call the device specific close. This cannot fail.
@@ -1417,6 +1440,9 @@ static int __dev_close_many(struct list_head *head)
 		if (ops->ndo_stop)
 			ops->ndo_stop(dev);
 
+		list_for_each_entry(n, &dev->napi_list, dev_list)
+			napi_thread_stop(n);
+
 		dev->flags &= ~IFF_UP;
 		netpoll_poll_enable(dev);
 	}
@@ -3456,6 +3482,11 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
 static inline void ____napi_schedule(struct softnet_data *sd,
 				     struct napi_struct *napi)
 {
+	if (napi->thread) {
+		wake_up_process(napi->thread);
+		return;
+	}
+
 	list_add_tail(&napi->poll_list, &sd->poll_list);
 	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 }
@@ -5174,6 +5205,88 @@ out_unlock:
 	return work;
 }
 
+static int napi_thread_wait(struct napi_struct *napi)
+{
+	set_current_state(TASK_INTERRUPTIBLE);
+
+	while (!kthread_should_stop() && !napi_disable_pending(napi)) {
+		if (test_bit(NAPI_STATE_SCHED, &napi->state)) {
+			__set_current_state(TASK_RUNNING);
+			return 0;
+		}
+
+		schedule();
+		set_current_state(TASK_INTERRUPTIBLE);
+	}
+	__set_current_state(TASK_RUNNING);
+	return -1;
+}
+
+static int napi_threaded_poll(void *data)
+{
+	struct napi_struct *napi = data;
+
+	while (!napi_thread_wait(napi)) {
+		struct list_head dummy_repoll;
+		int budget = netdev_budget;
+		unsigned long time_limit;
+		bool again = true;
+
+		INIT_LIST_HEAD(&dummy_repoll);
+		local_bh_disable();
+		time_limit = jiffies + 2;
+		do {
+			/* ensure that the poll list is not empty */
+			if (list_empty(&dummy_repoll))
+				list_add(&napi->poll_list, &dummy_repoll);
+
+			budget -= napi_poll(napi, &dummy_repoll);
+			if (unlikely(budget <= 0 ||
+				     time_after_eq(jiffies, time_limit))) {
+				cond_resched_softirq();
+
+				/* refresh the budget */
+				budget = netdev_budget;
+				__kfree_skb_flush();
+				time_limit = jiffies + 2;
+			}
+
+			if (napi_disable_pending(napi))
+				again = false;
+			else if (!test_bit(NAPI_STATE_SCHED, &napi->state))
+				again = false;
+		} while (again);
+
+		__kfree_skb_flush();
+		local_bh_enable();
+	}
+	return 0;
+}
+
+int napi_set_threaded(struct napi_struct *n, bool threaded)
+{
+	ASSERT_RTNL();
+
+	if (n->dev->flags & IFF_UP)
+		return -EBUSY;
+
+	if (threaded == !!test_bit(NAPI_STATE_THREADED, &n->state))
+		return 0;
+	if (threaded)
+		set_bit(NAPI_STATE_THREADED, &n->state);
+	else
+		clear_bit(NAPI_STATE_THREADED, &n->state);
+
+	/* if the device is initializing, nothing todo */
+	if (test_bit(__LINK_STATE_START, &n->dev->state))
+		return 0;
+
+	napi_thread_stop(n);
+	napi_thread_start(n);
+	return 0;
+}
+EXPORT_SYMBOL(napi_set_threaded);
+
 static void net_rx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
-- 
1.8.3.1

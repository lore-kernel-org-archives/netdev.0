From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next 1/2] net: gro: add a per device gro flush timer
Date: Thu, 06 Nov 2014 21:09:44 -0800
Message-ID: <1415336984.13896.102.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141106.162516.1083429539800319166.davem@davemloft.net>
	 <1415311880.13896.85.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141106.223603.678182467467024928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, willemb@google.com,
	Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:63757 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbaKGFJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 00:09:47 -0500
Received: by mail-ie0-f169.google.com with SMTP id tr6so4525854ieb.14
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 21:09:46 -0800 (PST)
In-Reply-To: <20141106.223603.678182467467024928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Tuning coalescing parameters on NIC can be really hard.

Servers can handle both bulk and RPC like traffic, with conflicting
goals : bulk flows want as big GRO packets as possible, RPC want minimal
latencies.

To reach big GRO packets on 10Gbe NIC, one can use :

ethtool -C eth0 rx-usecs 4 rx-frames 44

But this penalizes rpc sessions, with an increase of latencies, up to
50% in some cases, as NICs generally do not force an interrupt when
a packet with TCP Push flag is received.

Some NICs do not have an absolute timer, only a timer rearmed for every
incoming packet.

This patch uses a different strategy : Let GRO stack decides what do do,
based on traffic pattern.

Packets with Push flag wont be delayed.
Packets without Push flag might be held in GRO engine, if we keep
receiving data.

This new mechanism is off by default, and shall be enabled by setting
/sys/class/net/ethX/gro_flush_timeout to a value in nanosecond.

To fully enable this mechanism, drivers should use napi_complete_done()
instead of napi_complete().

Tested:
 Ran 200 netperf TCP_STREAM from A to B (10Gbe mlx4 link, 8 RX queues)

Without this feature, we send back about 305,000 ACK per second.

GRO aggregation ratio is low (811/305 = 2.65 segments per GRO packet)

Setting a timer of 2000 nsec is enough to increase GRO packet sizes
and reduce number of ACK packets. (811/19.2 = 42)

Receiver performs less calls to upper stacks, less wakes up.
This also reduces cpu usage on the sender, as it receives less ACK
packets.

Note that reducing number of wakes up increases cpu efficiency, but can
decrease QPS, as applications wont have the chance to warmup cpu caches
doing a partial read of RPC requests/answers if they fit in one skb.

B:~# sar -n DEV 1 10 | grep eth0 | tail -1
Average:         eth0 811269.80 305732.30 1199462.57  19705.72      0.00
0.00      0.50

B:~# echo 2000 >/sys/class/net/eth0/gro_flush_timeout

B:~# sar -n DEV 1 10 | grep eth0 | tail -1
Average:         eth0 811577.30  19230.80 1199916.51   1239.80      0.00
0.00      0.50

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: As requested by David, drivers should use napi_complete_done()
    instead of napi_complete() so that we do not have to track if
    a packet was received during last NAPI poll.

 include/linux/netdevice.h |   20 ++++++++--------
 net/core/dev.c            |   45 ++++++++++++++++++++++++++++++++----
 net/core/net-sysfs.c      |   18 ++++++++++++++
 3 files changed, 69 insertions(+), 14 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 90ac95900a11..888d5513fa4a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -314,6 +314,7 @@ struct napi_struct {
 	struct net_device	*dev;
 	struct sk_buff		*gro_list;
 	struct sk_buff		*skb;
+	struct hrtimer		timer;
 	struct list_head	dev_list;
 	struct hlist_node	napi_hash_node;
 	unsigned int		napi_id;
@@ -443,14 +444,19 @@ static inline bool napi_reschedule(struct napi_struct *napi)
 	return false;
 }
 
+void __napi_complete(struct napi_struct *n);
+void napi_complete_done(struct napi_struct *n, int work_done);
 /**
  *	napi_complete - NAPI processing complete
  *	@n: napi context
  *
  * Mark NAPI processing as complete.
+ * Consider using napi_complete_done() instead.
  */
-void __napi_complete(struct napi_struct *n);
-void napi_complete(struct napi_struct *n);
+static inline void napi_complete(struct napi_struct *n)
+{
+	return napi_complete_done(n, 0);
+}
 
 /**
  *	napi_by_id - lookup a NAPI by napi_id
@@ -485,14 +491,7 @@ void napi_hash_del(struct napi_struct *napi);
  * Stop NAPI from being scheduled on this context.
  * Waits till any outstanding processing completes.
  */
-static inline void napi_disable(struct napi_struct *n)
-{
-	might_sleep();
-	set_bit(NAPI_STATE_DISABLE, &n->state);
-	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
-		msleep(1);
-	clear_bit(NAPI_STATE_DISABLE, &n->state);
-}
+void napi_disable(struct napi_struct *n);
 
 /**
  *	napi_enable - enable NAPI scheduling
@@ -1603,6 +1602,7 @@ struct net_device {
 
 #endif
 
+	unsigned long		gro_flush_timeout;
 	rx_handler_func_t __rcu	*rx_handler;
 	void __rcu		*rx_handler_data;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 70bb609c283d..bb09b0364619 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -134,6 +134,7 @@
 #include <linux/vmalloc.h>
 #include <linux/if_macvlan.h>
 #include <linux/errqueue.h>
+#include <linux/hrtimer.h>
 
 #include "net-sysfs.h"
 
@@ -4412,7 +4413,6 @@ EXPORT_SYMBOL(__napi_schedule_irqoff);
 void __napi_complete(struct napi_struct *n)
 {
 	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
-	BUG_ON(n->gro_list);
 
 	list_del_init(&n->poll_list);
 	smp_mb__before_atomic();
@@ -4420,7 +4420,7 @@ void __napi_complete(struct napi_struct *n)
 }
 EXPORT_SYMBOL(__napi_complete);
 
-void napi_complete(struct napi_struct *n)
+void napi_complete_done(struct napi_struct *n, int work_done)
 {
 	unsigned long flags;
 
@@ -4431,8 +4431,18 @@ void napi_complete(struct napi_struct *n)
 	if (unlikely(test_bit(NAPI_STATE_NPSVC, &n->state)))
 		return;
 
-	napi_gro_flush(n, false);
+	if (n->gro_list) {
+		unsigned long timeout = 0;
 
+		if (work_done)
+			timeout = n->dev->gro_flush_timeout;
+
+		if (timeout)
+			hrtimer_start(&n->timer, ns_to_ktime(timeout),
+				      HRTIMER_MODE_REL_PINNED);
+		else
+			napi_gro_flush(n, false);
+	}
 	if (likely(list_empty(&n->poll_list))) {
 		WARN_ON_ONCE(!test_and_clear_bit(NAPI_STATE_SCHED, &n->state));
 	} else {
@@ -4442,7 +4452,7 @@ void napi_complete(struct napi_struct *n)
 		local_irq_restore(flags);
 	}
 }
-EXPORT_SYMBOL(napi_complete);
+EXPORT_SYMBOL(napi_complete_done);
 
 /* must be called under rcu_read_lock(), as we dont take a reference */
 struct napi_struct *napi_by_id(unsigned int napi_id)
@@ -4496,10 +4506,23 @@ void napi_hash_del(struct napi_struct *napi)
 }
 EXPORT_SYMBOL_GPL(napi_hash_del);
 
+static enum hrtimer_restart napi_watchdog(struct hrtimer *timer)
+{
+	struct napi_struct *napi;
+
+	napi = container_of(timer, struct napi_struct, timer);
+	if (napi->gro_list)
+		napi_schedule(napi);
+
+	return HRTIMER_NORESTART;
+}
+
 void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 		    int (*poll)(struct napi_struct *, int), int weight)
 {
 	INIT_LIST_HEAD(&napi->poll_list);
+	hrtimer_init(&napi->timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL_PINNED);
+	napi->timer.function = napi_watchdog;
 	napi->gro_count = 0;
 	napi->gro_list = NULL;
 	napi->skb = NULL;
@@ -4518,6 +4541,20 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 }
 EXPORT_SYMBOL(netif_napi_add);
 
+void napi_disable(struct napi_struct *n)
+{
+	might_sleep();
+	set_bit(NAPI_STATE_DISABLE, &n->state);
+
+	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
+		msleep(1);
+
+	hrtimer_cancel(&n->timer);
+
+	clear_bit(NAPI_STATE_DISABLE, &n->state);
+}
+EXPORT_SYMBOL(napi_disable);
+
 void netif_napi_del(struct napi_struct *napi)
 {
 	list_del_init(&napi->dev_list);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 9dd06699b09c..1a24602cd54e 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -325,6 +325,23 @@ static ssize_t tx_queue_len_store(struct device *dev,
 }
 NETDEVICE_SHOW_RW(tx_queue_len, fmt_ulong);
 
+static int change_gro_flush_timeout(struct net_device *dev, unsigned long val)
+{
+	dev->gro_flush_timeout = val;
+	return 0;
+}
+
+static ssize_t gro_flush_timeout_store(struct device *dev,
+				  struct device_attribute *attr,
+				  const char *buf, size_t len)
+{
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	return netdev_store(dev, attr, buf, len, change_gro_flush_timeout);
+}
+NETDEVICE_SHOW_RW(gro_flush_timeout, fmt_ulong);
+
 static ssize_t ifalias_store(struct device *dev, struct device_attribute *attr,
 			     const char *buf, size_t len)
 {
@@ -422,6 +439,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_mtu.attr,
 	&dev_attr_flags.attr,
 	&dev_attr_tx_queue_len.attr,
+	&dev_attr_gro_flush_timeout.attr,
 	&dev_attr_phys_port_id.attr,
 	NULL,
 };

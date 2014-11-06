From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: gro: add a per device gro flush timer
Date: Wed, 05 Nov 2014 16:55:20 -0800
Message-ID: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:43183 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaKFAzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 19:55:22 -0500
Received: by mail-ig0-f177.google.com with SMTP id hl2so2489375igb.10
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 16:55:21 -0800 (PST)
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
/sys/class/net/eth0/gro_flush_timeout to a value in nanosecond.

Tested:
 Ran 200 netperf TCP_STREAM from A to B (10Gbe link, 8 RX queues)

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
Average:         eth0 811269.80 305732.30 1199462.57  19705.72      0.00      0.00      0.50

B:~# echo 2000 >/sys/class/net/eth0/gro_flush_timeout

lpaa6:~# sar -n DEV 1 10 | grep eth0 | tail -1
Average:         eth0 811577.30  19230.80 1199916.51   1239.80      0.00      0.00      0.50

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |   12 +++------
 net/core/dev.c            |   44 ++++++++++++++++++++++++++++++++++--
 net/core/net-sysfs.c      |   18 ++++++++++++++
 3 files changed, 64 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4767f546d7c0..8474fcfadc7c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -314,6 +314,8 @@ struct napi_struct {
 	struct net_device	*dev;
 	struct sk_buff		*gro_list;
 	struct sk_buff		*skb;
+	unsigned long		napi_rx_count;
+	struct hrtimer		timer;
 	struct list_head	dev_list;
 	struct hlist_node	napi_hash_node;
 	unsigned int		napi_id;
@@ -485,14 +487,7 @@ void napi_hash_del(struct napi_struct *napi);
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
@@ -1603,6 +1598,7 @@ struct net_device {
 
 #endif
 
+	unsigned long		gro_flush_timeout;
 	rx_handler_func_t __rcu	*rx_handler;
 	void __rcu		*rx_handler_data;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 40be481268de..c88651bd8ada 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -133,6 +133,7 @@
 #include <linux/vmalloc.h>
 #include <linux/if_macvlan.h>
 #include <linux/errqueue.h>
+#include <linux/hrtimer.h>
 
 #include "net-sysfs.h"
 
@@ -4000,6 +4001,8 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	if (skb_is_gso(skb) || skb_has_frag_list(skb) || skb->csum_bad)
 		goto normal;
 
+	napi->napi_rx_count++;
+
 	gro_list_prepare(napi, skb);
 
 	rcu_read_lock();
@@ -4411,7 +4414,6 @@ EXPORT_SYMBOL(__napi_schedule_irqoff);
 void __napi_complete(struct napi_struct *n)
 {
 	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
-	BUG_ON(n->gro_list);
 
 	list_del_init(&n->poll_list);
 	smp_mb__before_atomic();
@@ -4430,8 +4432,19 @@ void napi_complete(struct napi_struct *n)
 	if (unlikely(test_bit(NAPI_STATE_NPSVC, &n->state)))
 		return;
 
-	napi_gro_flush(n, false);
+	if (n->gro_list) {
+		unsigned long timeout = 0;
+
+		if (n->napi_rx_count)
+			timeout = n->dev->gro_flush_timeout;
 
+		if (timeout)
+			hrtimer_start(&n->timer, ns_to_ktime(timeout),
+				      HRTIMER_MODE_REL_PINNED);
+		else
+			napi_gro_flush(n, false);
+	}
+	n->napi_rx_count = 0;
 	if (likely(list_empty(&n->poll_list))) {
 		WARN_ON_ONCE(!test_and_clear_bit(NAPI_STATE_SCHED, &n->state));
 	} else {
@@ -4495,10 +4508,23 @@ void napi_hash_del(struct napi_struct *napi)
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
@@ -4517,6 +4543,20 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
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

From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH v3 1/2] core: Factor out flow calculation from get_rps_cpu
Date: Tue, 03 Aug 2010 08:32:56 +0530
Message-ID: <20100803030256.8486.82622.sendpatchset@krkumar2.in.ibm.com>
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	therbert@google.com, Krishna Kumar <krkumar2@in.ibm.com>,
	mst@redhat.com
To: davem@davemloft.net, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:56181 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559Ab0HCDDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 23:03:02 -0400
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id o732wdXv001815
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 12:58:39 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o73330pY1613836
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 13:03:00 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7332xjK032197
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 13:03:00 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Factor out flow calculation code from get_rps_cpu, since macvtap
driver can use the same code.

Revisions:

v2 - Ben: Separate flow calcuation out and use in select queue
v3 - Arnd: Don't re-implement MIN

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/netdevice.h |    1 
 net/core/dev.c            |   94 ++++++++++++++++++++++--------------
 2 files changed, 59 insertions(+), 36 deletions(-)

diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
--- org/include/linux/netdevice.h	2010-08-03 08:19:57.000000000 +0530
+++ new/include/linux/netdevice.h	2010-08-03 08:19:57.000000000 +0530
@@ -2253,6 +2253,7 @@ static inline const char *netdev_name(co
 	return dev->name;
 }
 
+extern int skb_calculate_flow(struct net_device *dev, struct sk_buff *skb);
 extern int netdev_printk(const char *level, const struct net_device *dev,
 			 const char *format, ...)
 	__attribute__ ((format (printf, 3, 4)));
diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2010-08-03 08:19:57.000000000 +0530
+++ new/net/core/dev.c	2010-08-03 08:19:57.000000000 +0530
@@ -2263,51 +2263,24 @@ static inline void ____napi_schedule(str
 	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 }
 
-#ifdef CONFIG_RPS
-
-/* One global table that all flow-based protocols share. */
-struct rps_sock_flow_table *rps_sock_flow_table __read_mostly;
-EXPORT_SYMBOL(rps_sock_flow_table);
-
 /*
- * get_rps_cpu is called from netif_receive_skb and returns the target
- * CPU from the RPS map of the receiving queue for a given skb.
- * rcu_read_lock must be held on entry.
+ * skb_calculate_flow: calculate a flow hash based on src/dst addresses
+ * and src/dst port numbers. On success, returns a hash number (> 0),
+ * otherwise -1.
  */
-static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
-		       struct rps_dev_flow **rflowp)
+int skb_calculate_flow(struct net_device *dev, struct sk_buff *skb)
 {
+	int hash = skb->rxhash;
 	struct ipv6hdr *ip6;
 	struct iphdr *ip;
-	struct netdev_rx_queue *rxqueue;
-	struct rps_map *map;
-	struct rps_dev_flow_table *flow_table;
-	struct rps_sock_flow_table *sock_flow_table;
-	int cpu = -1;
 	u8 ip_proto;
-	u16 tcpu;
 	u32 addr1, addr2, ihl;
 	union {
 		u32 v32;
 		u16 v16[2];
 	} ports;
 
-	if (skb_rx_queue_recorded(skb)) {
-		u16 index = skb_get_rx_queue(skb);
-		if (unlikely(index >= dev->num_rx_queues)) {
-			WARN_ONCE(dev->num_rx_queues > 1, "%s received packet "
-				"on queue %u, but number of RX queues is %u\n",
-				dev->name, index, dev->num_rx_queues);
-			goto done;
-		}
-		rxqueue = dev->_rx + index;
-	} else
-		rxqueue = dev->_rx;
-
-	if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
-		goto done;
-
-	if (skb->rxhash)
+	if (hash)
 		goto got_hash; /* Skip hash computation on packet header */
 
 	switch (skb->protocol) {
@@ -2334,6 +2307,7 @@ static int get_rps_cpu(struct net_device
 	default:
 		goto done;
 	}
+
 	switch (ip_proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
@@ -2356,11 +2330,59 @@ static int get_rps_cpu(struct net_device
 	/* get a consistent hash (same value on both flow directions) */
 	if (addr2 < addr1)
 		swap(addr1, addr2);
-	skb->rxhash = jhash_3words(addr1, addr2, ports.v32, hashrnd);
-	if (!skb->rxhash)
-		skb->rxhash = 1;
+
+	hash = jhash_3words(addr1, addr2, ports.v32, hashrnd);
+	if (!hash)
+		hash = 1;
 
 got_hash:
+	return hash;
+
+done:
+	return -1;
+}
+EXPORT_SYMBOL(skb_calculate_flow);
+
+#ifdef CONFIG_RPS
+
+/* One global table that all flow-based protocols share. */
+struct rps_sock_flow_table *rps_sock_flow_table __read_mostly;
+EXPORT_SYMBOL(rps_sock_flow_table);
+
+/*
+ * get_rps_cpu is called from netif_receive_skb and returns the target
+ * CPU from the RPS map of the receiving queue for a given skb.
+ * rcu_read_lock must be held on entry.
+ */
+static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
+		       struct rps_dev_flow **rflowp)
+{
+	struct netdev_rx_queue *rxqueue;
+	struct rps_map *map;
+	struct rps_dev_flow_table *flow_table;
+	struct rps_sock_flow_table *sock_flow_table;
+	int cpu = -1;
+	u16 tcpu;
+
+	if (skb_rx_queue_recorded(skb)) {
+		u16 index = skb_get_rx_queue(skb);
+		if (unlikely(index >= dev->num_rx_queues)) {
+			WARN_ONCE(dev->num_rx_queues > 1, "%s received packet "
+				"on queue %u, but number of RX queues is %u\n",
+				dev->name, index, dev->num_rx_queues);
+			goto done;
+		}
+		rxqueue = dev->_rx + index;
+	} else
+		rxqueue = dev->_rx;
+
+	if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
+		goto done;
+
+	skb->rxhash = skb_calculate_flow(dev, skb);
+	if (skb->rxhash < 0)
+		goto done;
+
 	flow_table = rcu_dereference(rxqueue->rps_flow_table);
 	sock_flow_table = rcu_dereference(rps_sock_flow_table);
 	if (flow_table && sock_flow_table) {

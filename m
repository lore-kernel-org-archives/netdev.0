From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH v5 1/2] core: Factor out flow calculation from get_rps_cpu
Date: Wed, 04 Aug 2010 21:45:52 +0530
Message-ID: <20100804161552.3814.56839.sendpatchset@krkumar2.in.ibm.com>
Cc: mst@redhat.com, netdev@vger.kernel.org, xiaosuo@gmail.com,
	bhutchings@solarflare.com, Krishna Kumar <krkumar2@in.ibm.com>,
	therbert@google.com
To: davem@davemloft.net, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:50097 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755958Ab0HDQP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 12:15:59 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id o74GFtmJ027594
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 21:45:55 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o74GFtGS3891418
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 21:45:55 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o74GFsOo006357
	for <netdev@vger.kernel.org>; Thu, 5 Aug 2010 02:15:55 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Factor out flow calculation code from get_rps_cpu, since other
functions can use the same code.

Revisions:

v2 (Ben): Separate flow calcuation out and use in select queue.
v3 (Arnd): Don't re-implement MIN.
v4 (Changli): skb->data points to ethernet header in macvtap, and
	make a fast path. Tested macvtap with this patch.
v5 (Changli):
	- Cache skb->rxhash in skb_get_rxhash
	- macvtap may not have pow(2) queues, so change code for
	  queue selection.
    (Arnd):
	- Use first available queue if all fails.


Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/skbuff.h |    9 +++
 net/core/dev.c         |  106 ++++++++++++++++++++++-----------------
 2 files changed, 71 insertions(+), 44 deletions(-)

diff -ruNp org/include/linux/skbuff.h new/include/linux/skbuff.h
--- org/include/linux/skbuff.h	2010-08-04 20:45:19.000000000 +0530
+++ new/include/linux/skbuff.h	2010-08-04 20:47:02.000000000 +0530
@@ -558,6 +558,15 @@ extern unsigned int   skb_find_text(stru
 				    unsigned int to, struct ts_config *config,
 				    struct ts_state *state);
 
+extern __u32 __skb_get_rxhash(struct sk_buff *skb);
+static inline __u32 skb_get_rxhash(struct sk_buff *skb)
+{
+	if (!skb->rxhash)
+		skb->rxhash = __skb_get_rxhash(skb);
+
+	return skb->rxhash;
+}
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
 {
diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2010-08-04 20:45:19.000000000 +0530
+++ new/net/core/dev.c	2010-08-04 21:13:37.000000000 +0530
@@ -2259,69 +2259,41 @@ static inline void ____napi_schedule(str
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
+ * __skb_get_rxhash: calculate a flow hash based on src/dst addresses
+ * and src/dst port numbers. Returns a non-zero hash number on success
+ * and 0 on failure.
  */
-static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
-		       struct rps_dev_flow **rflowp)
+__u32 __skb_get_rxhash(struct sk_buff *skb)
 {
+	int nhoff, hash = 0;
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
-		goto got_hash; /* Skip hash computation on packet header */
+	nhoff = skb_network_offset(skb);
 
 	switch (skb->protocol) {
 	case __constant_htons(ETH_P_IP):
-		if (!pskb_may_pull(skb, sizeof(*ip)))
+		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
 			goto done;
 
-		ip = (struct iphdr *) skb->data;
+		ip = (struct iphdr *) skb->data + nhoff;
 		ip_proto = ip->protocol;
 		addr1 = (__force u32) ip->saddr;
 		addr2 = (__force u32) ip->daddr;
 		ihl = ip->ihl;
 		break;
 	case __constant_htons(ETH_P_IPV6):
-		if (!pskb_may_pull(skb, sizeof(*ip6)))
+		if (!pskb_may_pull(skb, sizeof(*ip6) + nhoff))
 			goto done;
 
-		ip6 = (struct ipv6hdr *) skb->data;
+		ip6 = (struct ipv6hdr *) skb->data + nhoff;
 		ip_proto = ip6->nexthdr;
 		addr1 = (__force u32) ip6->saddr.s6_addr32[3];
 		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
@@ -2330,6 +2302,7 @@ static int get_rps_cpu(struct net_device
 	default:
 		goto done;
 	}
+
 	switch (ip_proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
@@ -2338,8 +2311,9 @@ static int get_rps_cpu(struct net_device
 	case IPPROTO_AH:
 	case IPPROTO_SCTP:
 	case IPPROTO_UDPLITE:
-		if (pskb_may_pull(skb, (ihl * 4) + 4)) {
-			ports.v32 = * (__force u32 *) (skb->data + (ihl * 4));
+		if (pskb_may_pull(skb, (ihl * 4) + 4 + nhoff)) {
+			ports.v32 = * (__force u32 *) (skb->data + nhoff +
+						       (ihl * 4));
 			if (ports.v16[1] < ports.v16[0])
 				swap(ports.v16[0], ports.v16[1]);
 			break;
@@ -2352,11 +2326,55 @@ static int get_rps_cpu(struct net_device
 	/* get a consistent hash (same value on both flow directions) */
 	if (addr2 < addr1)
 		swap(addr1, addr2);
-	skb->rxhash = jhash_3words(addr1, addr2, ports.v32, hashrnd);
-	if (!skb->rxhash)
-		skb->rxhash = 1;
 
-got_hash:
+	hash = jhash_3words(addr1, addr2, ports.v32, hashrnd);
+	if (!hash)
+		hash = 1;
+
+done:
+	return hash;
+}
+EXPORT_SYMBOL(__skb_get_rxhash);
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
+	if (!skb_get_rxhash(skb))
+		goto done;
+
 	flow_table = rcu_dereference(rxqueue->rps_flow_table);
 	sock_flow_table = rcu_dereference(rps_sock_flow_table);
 	if (flow_table && sock_flow_table) {

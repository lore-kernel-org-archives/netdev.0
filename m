From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] loopback: optimization
Date: Mon, 3 Nov 2008 21:37:58 -0800
Message-ID: <20081103213758.59a8361d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33681 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751224AbYKDFiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 00:38:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is something I was trying out to try improving loopback performance.
It moves loopback processing from the generic backlog per-cpu queues,
to its own set of queues. I thought this might help the cache locality
and the loopback doesn't have to do relatively expensive local_irq_disable()
operations.

BUT it didn't seem to help with tbench, but it might help others who
want to go farther with it. Code runs but treat it ASIS at this point.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/loopback.c	2008-11-03 10:13:31.000000000 -0800
+++ b/drivers/net/loopback.c	2008-11-03 11:05:52.000000000 -0800
@@ -59,51 +59,79 @@
 #include <linux/percpu.h>
 #include <net/net_namespace.h>
 
-struct pcpu_lstats {
+struct loopback_per_cpu {
+	struct sk_buff_head rxq;
+	struct napi_struct napi;
+
 	unsigned long packets;
 	unsigned long bytes;
 };
 
+
 /*
  * The higher levels take care of making this non-reentrant (it's
  * called with bh's disabled).
  */
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct pcpu_lstats *pcpu_lstats, *lb_stats;
+	struct loopback_per_cpu *lo = dev->ml_priv, *pcpu;
 
 	skb_orphan(skb);
 
-	skb->protocol = eth_type_trans(skb,dev);
+	skb->protocol = eth_type_trans(skb, dev);
 
 	dev->last_rx = jiffies;
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
-	pcpu_lstats = dev->ml_priv;
-	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
-	lb_stats->bytes += skb->len;
-	lb_stats->packets++;
+	pcpu = per_cpu_ptr(lo, smp_processor_id());
 
-	netif_rx(skb);
+	if (likely(pcpu->rxq.qlen < netdev_max_backlog)) {
+		if (pcpu->rxq.qlen == 0)
+			__napi_schedule(&lo->napi);
+
+		__skb_queue_tail(&pcpu->rxq, skb);
+		pcpu->bytes += skb->len;
+		pcpu->packets++;
+
+		return NET_XMIT_SUCCESS;
+	} else {
+		dev->stats.rx_dropped++;
+		dev_kfree_skb_any(skb);
+		return NET_XMIT_DROP;
+	}
+}
 
-	return 0;
+static int loopback_poll(struct napi_struct *napi, int work_limit)
+{
+	struct loopback_per_cpu *pcpu
+		= container_of(napi, struct loopback_per_cpu, napi);
+	struct sk_buff *skb;
+	int work_done = 0;
+
+	while ( (skb = __skb_dequeue(&pcpu->rxq)) ) {
+		netif_receive_skb(skb);
+
+		if (++work_done >= work_limit)
+			goto done;
+	}
+
+	__napi_complete(napi);
+done:
+	return work_done;
 }
 
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	const struct pcpu_lstats *pcpu_lstats;
+	const struct loopback_per_cpu *lo = dev->ml_priv;
 	struct net_device_stats *stats = &dev->stats;
 	unsigned long bytes = 0;
 	unsigned long packets = 0;
 	int i;
 
-	pcpu_lstats = dev->ml_priv;
 	for_each_possible_cpu(i) {
-		const struct pcpu_lstats *lb_stats;
-
-		lb_stats = per_cpu_ptr(pcpu_lstats, i);
-		bytes   += lb_stats->bytes;
-		packets += lb_stats->packets;
+		const struct loopback_per_cpu *pcpu = per_cpu_ptr(lo, i);
+		bytes   += pcpu->bytes;
+		packets += pcpu->packets;
 	}
 	stats->rx_packets = packets;
 	stats->tx_packets = packets;
@@ -127,21 +155,43 @@ static const struct ethtool_ops loopback
 
 static int loopback_dev_init(struct net_device *dev)
 {
-	struct pcpu_lstats *lstats;
+	struct loopback_per_cpu *lo;
+	int i;
 
-	lstats = alloc_percpu(struct pcpu_lstats);
-	if (!lstats)
+	lo = alloc_percpu(struct loopback_per_cpu);
+	if (!lo)
 		return -ENOMEM;
 
-	dev->ml_priv = lstats;
+	dev->ml_priv = lo;
+
+	for_each_possible_cpu(i) {
+		struct loopback_per_cpu *pcpu = per_cpu_ptr(lo, i);
+		skb_queue_head_init(&pcpu->rxq);
+		netif_napi_add(dev, &pcpu->napi, loopback_poll, 64);
+	}
+
+	return 0;
+}
+
+static int loopback_dev_stop(struct net_device *dev)
+{
+	struct loopback_per_cpu *lo = dev->ml_priv;
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct loopback_per_cpu *pcpu = per_cpu_ptr(lo, i);
+
+		napi_synchronize(&pcpu->napi);
+		__skb_queue_purge(&pcpu->rxq);
+	}
 	return 0;
 }
 
 static void loopback_dev_free(struct net_device *dev)
 {
-	struct pcpu_lstats *lstats = dev->ml_priv;
+	struct loopback_per_cpu *lo = dev->ml_priv;
 
-	free_percpu(lstats);
+	free_percpu(lo);
 	free_netdev(dev);
 }
 
@@ -169,6 +219,7 @@ static void loopback_setup(struct net_de
 	dev->header_ops		= &eth_header_ops;
 	dev->init = loopback_dev_init;
 	dev->destructor = loopback_dev_free;
+	dev->stop = loopback_dev_stop;
 }
 

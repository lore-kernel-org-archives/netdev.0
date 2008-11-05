From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] loopback: optimization
Date: Wed, 5 Nov 2008 12:36:59 -0800
Message-ID: <20081105123659.6045b216@extreme>
References: <20081103213758.59a8361d@extreme>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/FKBt/jd0/ekIvnnGyae1rGk"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47706 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756593AbYKEUhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 15:37:01 -0500
In-Reply-To: <20081103213758.59a8361d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/FKBt/jd0/ekIvnnGyae1rGk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Convert loopback device from using common network queues to a per-cpu
receive queue with NAPI. This gives a small 1% performance gain when
measured over 5 runs of tbench. Not sure if it's worth bothering
though.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/loopback.c	2008-11-04 15:36:29.000000000 -0800
+++ b/drivers/net/loopback.c	2008-11-05 10:00:20.000000000 -0800
@@ -59,7 +59,10 @@
 #include <linux/percpu.h>
 #include <net/net_namespace.h>
 
-struct pcpu_lstats {
+struct loopback_queue {
+	struct sk_buff_head rxq;
+	struct napi_struct napi;
+
 	unsigned long packets;
 	unsigned long bytes;
 };
@@ -70,36 +73,60 @@ struct pcpu_lstats {
  */
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct pcpu_lstats *pcpu_lstats, *lb_stats;
+	struct loopback_queue *pcpu;
 
 	skb_orphan(skb);
 
 	skb->protocol = eth_type_trans(skb,dev);
 
-	/* it's OK to use per_cpu_ptr() because BHs are off */
-	pcpu_lstats = dev->ml_priv;
-	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
-	lb_stats->bytes += skb->len;
-	lb_stats->packets++;
-
-	netif_rx(skb);
+	pcpu = per_cpu_ptr(dev->ml_priv, smp_processor_id());
+	if (likely(pcpu->rxq.qlen <= netdev_max_backlog)) {
+		__skb_queue_tail(&pcpu->rxq, skb);
+		pcpu->bytes += skb->len;
+		pcpu->packets++;
+		napi_schedule_irq(&pcpu->napi);
+
+		return NET_XMIT_SUCCESS;
+	} else {
+		dev->stats.rx_dropped++;
+		dev_kfree_skb_any(skb);
+		return NET_XMIT_DROP;
+	}
 
 	return 0;
 }
 
+static int loopback_poll(struct napi_struct *arg, int quota)
+{
+	struct loopback_queue *pcpu = container_of(arg, struct loopback_queue, napi);
+	int work = 0;
+
+	do {
+		struct sk_buff *skb = __skb_dequeue(&pcpu->rxq);
+
+		if (!skb) {
+			__napi_complete(arg);
+			break;
+		}
+
+		netif_receive_skb(skb);
+	} while (++work < quota);
+
+	return work;
+}
+
+
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	const struct pcpu_lstats *pcpu_lstats;
 	struct net_device_stats *stats = &dev->stats;
 	unsigned long bytes = 0;
 	unsigned long packets = 0;
 	int i;
 
-	pcpu_lstats = dev->ml_priv;
 	for_each_possible_cpu(i) {
-		const struct pcpu_lstats *lb_stats;
+		const struct loopback_queue *lb_stats;
 
-		lb_stats = per_cpu_ptr(pcpu_lstats, i);
+		lb_stats = per_cpu_ptr(dev->ml_priv, i);
 		bytes   += lb_stats->bytes;
 		packets += lb_stats->packets;
 	}
@@ -125,21 +152,57 @@ static const struct ethtool_ops loopback
 
 static int loopback_dev_init(struct net_device *dev)
 {
-	struct pcpu_lstats *lstats;
+	void *p;
+	int i;
 
-	lstats = alloc_percpu(struct pcpu_lstats);
-	if (!lstats)
+	p = alloc_percpu(struct loopback_queue);
+	if (!p)
 		return -ENOMEM;
 
-	dev->ml_priv = lstats;
+	for_each_possible_cpu(i) {
+		struct loopback_queue *pcpu = per_cpu_ptr(p, i);
+		skb_queue_head_init(&pcpu->rxq);
+		netif_napi_add(dev, &pcpu->napi, loopback_poll, 64);
+	}
+
+	dev->ml_priv = p;
+
+	return 0;
+}
+
+static int loopback_dev_start(struct net_device *dev)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct loopback_queue *pcpu = per_cpu_ptr(dev->ml_priv, i);
+		napi_enable(&pcpu->napi);
+	}
+	return 0;
+}
+
+static int loopback_dev_stop(struct net_device *dev)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct loopback_queue *pcpu = per_cpu_ptr(dev->ml_priv, i);
+		napi_disable(&pcpu->napi);
+		__skb_queue_purge(&pcpu->rxq);
+	}
 	return 0;
 }
 
 static void loopback_dev_free(struct net_device *dev)
 {
-	struct pcpu_lstats *lstats = dev->ml_priv;
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct loopback_queue *pcpu = per_cpu_ptr(dev->ml_priv, i);
+		napi_disable(&pcpu->napi);
+	}
 
-	free_percpu(lstats);
+	free_percpu(dev->ml_priv);
 	free_netdev(dev);
 }
 
@@ -166,6 +229,8 @@ static void loopback_setup(struct net_de
 	dev->ethtool_ops	= &loopback_ethtool_ops;
 	dev->header_ops		= &eth_header_ops;
 	dev->init = loopback_dev_init;
+	dev->open = loopback_dev_start;
+	dev->stop = loopback_dev_stop;
 	dev->destructor = loopback_dev_free;
 }
 
--- a/include/linux/netdevice.h	2008-11-05 08:18:01.000000000 -0800
+++ b/include/linux/netdevice.h	2008-11-05 08:18:19.000000000 -0800
@@ -366,6 +366,8 @@ static inline int napi_reschedule(struct
 	return 0;
 }
 
+extern void napi_schedule_irq(struct napi_struct *n);
+
 /**
  *	napi_complete - NAPI processing complete
  *	@n: napi context
--- a/net/core/dev.c	2008-11-05 08:17:32.000000000 -0800
+++ b/net/core/dev.c	2008-11-05 09:54:36.000000000 -0800
@@ -2369,6 +2369,15 @@ void __napi_schedule(struct napi_struct 
 }
 EXPORT_SYMBOL(__napi_schedule);
 
+/* Special case version of napi_schedule since loopback device has no hard irq */
+void napi_schedule_irq(struct napi_struct *n)
+{
+	if (napi_schedule_prep(n)) {
+		list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
+		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+	}
+}
+
 
 static void net_rx_action(struct softirq_action *h)
 {

--MP_/FKBt/jd0/ekIvnnGyae1rGk
Content-Type: text/x-patch; name=loopback-napi.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=loopback-napi.patch

Convert loopback device from using common network queues to a per-cpu
receive queue with NAPI. This gives a small 1% performance gain when
measured over 5 runs of tbench. It does make the code larger and more space
needs to be allocated as well.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/loopback.c	2008-11-04 15:36:29.000000000 -0800
+++ b/drivers/net/loopback.c	2008-11-05 10:00:20.000000000 -0800
@@ -59,7 +59,10 @@
 #include <linux/percpu.h>
 #include <net/net_namespace.h>
 
-struct pcpu_lstats {
+struct loopback_queue {
+	struct sk_buff_head rxq;
+	struct napi_struct napi;
+
 	unsigned long packets;
 	unsigned long bytes;
 };
@@ -70,36 +73,60 @@ struct pcpu_lstats {
  */
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct pcpu_lstats *pcpu_lstats, *lb_stats;
+	struct loopback_queue *pcpu;
 
 	skb_orphan(skb);
 
 	skb->protocol = eth_type_trans(skb,dev);
 
-	/* it's OK to use per_cpu_ptr() because BHs are off */
-	pcpu_lstats = dev->ml_priv;
-	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
-	lb_stats->bytes += skb->len;
-	lb_stats->packets++;
-
-	netif_rx(skb);
+	pcpu = per_cpu_ptr(dev->ml_priv, smp_processor_id());
+	if (likely(pcpu->rxq.qlen <= netdev_max_backlog)) {
+		__skb_queue_tail(&pcpu->rxq, skb);
+		pcpu->bytes += skb->len;
+		pcpu->packets++;
+		napi_schedule_irq(&pcpu->napi);
+
+		return NET_XMIT_SUCCESS;
+	} else {
+		dev->stats.rx_dropped++;
+		dev_kfree_skb_any(skb);
+		return NET_XMIT_DROP;
+	}
 
 	return 0;
 }
 
+static int loopback_poll(struct napi_struct *arg, int quota)
+{
+	struct loopback_queue *pcpu = container_of(arg, struct loopback_queue, napi);
+	int work = 0;
+
+	do {
+		struct sk_buff *skb = __skb_dequeue(&pcpu->rxq);
+
+		if (!skb) {
+			__napi_complete(arg);
+			break;
+		}
+
+		netif_receive_skb(skb);
+	} while (++work < quota);
+
+	return work;
+}
+
+
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	const struct pcpu_lstats *pcpu_lstats;
 	struct net_device_stats *stats = &dev->stats;
 	unsigned long bytes = 0;
 	unsigned long packets = 0;
 	int i;
 
-	pcpu_lstats = dev->ml_priv;
 	for_each_possible_cpu(i) {
-		const struct pcpu_lstats *lb_stats;
+		const struct loopback_queue *lb_stats;
 
-		lb_stats = per_cpu_ptr(pcpu_lstats, i);
+		lb_stats = per_cpu_ptr(dev->ml_priv, i);
 		bytes   += lb_stats->bytes;
 		packets += lb_stats->packets;
 	}
@@ -125,21 +152,57 @@ static const struct ethtool_ops loopback
 
 static int loopback_dev_init(struct net_device *dev)
 {
-	struct pcpu_lstats *lstats;
+	void *p;
+	int i;
 
-	lstats = alloc_percpu(struct pcpu_lstats);
-	if (!lstats)
+	p = alloc_percpu(struct loopback_queue);
+	if (!p)
 		return -ENOMEM;
 
-	dev->ml_priv = lstats;
+	for_each_possible_cpu(i) {
+		struct loopback_queue *pcpu = per_cpu_ptr(p, i);
+		skb_queue_head_init(&pcpu->rxq);
+		netif_napi_add(dev, &pcpu->napi, loopback_poll, 64);
+	}
+
+	dev->ml_priv = p;
+
+	return 0;
+}
+
+static int loopback_dev_start(struct net_device *dev)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct loopback_queue *pcpu = per_cpu_ptr(dev->ml_priv, i);
+		napi_enable(&pcpu->napi);
+	}
+	return 0;
+}
+
+static int loopback_dev_stop(struct net_device *dev)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct loopback_queue *pcpu = per_cpu_ptr(dev->ml_priv, i);
+		napi_disable(&pcpu->napi);
+		__skb_queue_purge(&pcpu->rxq);
+	}
 	return 0;
 }
 
 static void loopback_dev_free(struct net_device *dev)
 {
-	struct pcpu_lstats *lstats = dev->ml_priv;
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct loopback_queue *pcpu = per_cpu_ptr(dev->ml_priv, i);
+		napi_disable(&pcpu->napi);
+	}
 
-	free_percpu(lstats);
+	free_percpu(dev->ml_priv);
 	free_netdev(dev);
 }
 
@@ -166,6 +229,8 @@ static void loopback_setup(struct net_de
 	dev->ethtool_ops	= &loopback_ethtool_ops;
 	dev->header_ops		= &eth_header_ops;
 	dev->init = loopback_dev_init;
+	dev->open = loopback_dev_start;
+	dev->stop = loopback_dev_stop;
 	dev->destructor = loopback_dev_free;
 }
 
--- a/include/linux/netdevice.h	2008-11-05 08:18:01.000000000 -0800
+++ b/include/linux/netdevice.h	2008-11-05 08:18:19.000000000 -0800
@@ -366,6 +366,8 @@ static inline int napi_reschedule(struct
 	return 0;
 }
 
+extern void napi_schedule_irq(struct napi_struct *n);
+
 /**
  *	napi_complete - NAPI processing complete
  *	@n: napi context
--- a/net/core/dev.c	2008-11-05 08:17:32.000000000 -0800
+++ b/net/core/dev.c	2008-11-05 09:54:36.000000000 -0800
@@ -2369,6 +2369,15 @@ void __napi_schedule(struct napi_struct 
 }
 EXPORT_SYMBOL(__napi_schedule);
 
+/* Special case version of napi_schedule since loopback device has no hard irq */
+void napi_schedule_irq(struct napi_struct *n)
+{
+	if (napi_schedule_prep(n)) {
+		list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
+		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+	}
+}
+
 
 static void net_rx_action(struct softirq_action *h)
 {

--MP_/FKBt/jd0/ekIvnnGyae1rGk--

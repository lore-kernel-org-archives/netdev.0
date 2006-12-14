From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/4] net: move softnet_data
Date: Thu, 14 Dec 2006 12:48:17 -0800
Message-ID: <20061214204900.958451000@osdl.org>
References: <20061214204814.631279000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:56857 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbWLNUwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 15:52:38 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netpoll-zap.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make softnet_data local to dev.c.  

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.20-rc1.orig/include/linux/netdevice.h
+++ linux-2.6.20-rc1/include/linux/netdevice.h
@@ -600,6 +600,9 @@ extern int		dev_restart(struct net_devic
 #ifdef CONFIG_NETPOLL_TRAP
 extern int		netpoll_trap(void);
 #endif
+#ifdef CONFIG_NETPOLL
+extern void		netpoll_do_completion(void);
+#endif
 
 typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
 extern int		register_gifconf(unsigned int family, gifconf_func_t * gifconf);
@@ -608,26 +611,6 @@ static inline int unregister_gifconf(uns
 	return register_gifconf(family, NULL);
 }
 
-/*
- * Incoming packets are placed on per-cpu queues so that
- * no locking is needed.
- */
-
-struct softnet_data
-{
-	struct net_device	*output_queue;
-	struct sk_buff_head	input_pkt_queue;
-	struct list_head	poll_list;
-	struct sk_buff		*completion_queue;
-
-	struct net_device	backlog_dev;	/* Sorry. 8) */
-#ifdef CONFIG_NET_DMA
-	struct dma_chan		*net_dma;
-#endif
-};
-
-DECLARE_PER_CPU(struct softnet_data,softnet_data);
-
 #define HAVE_NETIF_QUEUE
 
 extern void __netif_schedule(struct net_device *dev);
--- linux-2.6.20-rc1.orig/net/core/dev.c
+++ linux-2.6.20-rc1/net/core/dev.c
@@ -203,10 +203,23 @@ static inline struct hlist_head *dev_ind
 static RAW_NOTIFIER_HEAD(netdev_chain);
 
 /*
- *	Device drivers call our routines to queue packets here. We empty the
- *	queue in the local softnet handler.
+ * Incoming packets are placed on per-cpu queues so that
+ * no locking is needed.
  */
-DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL };
+struct softnet_data
+{
+	struct net_device	*output_queue;
+	struct sk_buff_head	input_pkt_queue;
+	struct list_head	poll_list;
+	struct sk_buff		*completion_queue;
+
+	struct net_device	backlog_dev;	/* Sorry. 8) */
+#ifdef CONFIG_NET_DMA
+	struct dma_chan		*net_dma;
+#endif
+};
+
+static DEFINE_PER_CPU(struct softnet_data, softnet_data);
 
 #ifdef CONFIG_SYSFS
 extern int netdev_sysfs_init(void);
@@ -1673,6 +1686,34 @@ static inline struct net_device *skb_bon
 	return dev;
 }
 
+#ifdef CONFIG_NETPOLL
+void netpoll_do_completion(void)
+{
+	unsigned long flags;
+	struct softnet_data *sd = &get_cpu_var(softnet_data);
+
+	if (sd->completion_queue) {
+		struct sk_buff *clist;
+
+		local_irq_save(flags);
+		clist = sd->completion_queue;
+		sd->completion_queue = NULL;
+		local_irq_restore(flags);
+
+		while (clist != NULL) {
+			struct sk_buff *skb = clist;
+			clist = clist->next;
+			if (skb->destructor)
+				dev_kfree_skb_any(skb); /* put this one back */
+			else
+				__kfree_skb(skb);
+		}
+	}
+
+	put_cpu_var(softnet_data);
+}
+#endif
+
 static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
--- linux-2.6.20-rc1.orig/net/core/netpoll.c
+++ linux-2.6.20-rc1/net/core/netpoll.c
@@ -47,7 +47,6 @@ static atomic_t trapped;
 		(MAX_UDP_CHUNK + sizeof(struct udphdr) + \
 				sizeof(struct iphdr) + sizeof(struct ethhdr))
 
-static void zap_completion_queue(void);
 static void arp_reply(struct sk_buff *skb);
 
 static void queue_process(struct work_struct *work)
@@ -162,7 +161,7 @@ void netpoll_poll(struct netpoll *np)
 
 	service_arp_queue(np->dev->npinfo);
 
-	zap_completion_queue();
+	netpoll_do_completion();
 }
 
 static void refill_skbs(void)
@@ -181,7 +180,7 @@ static void refill_skbs(void)
 	spin_unlock_irqrestore(&skb_pool.lock, flags);
 }
 
-static void zap_completion_queue(void)
+static void netpoll_do_completion(void)
 {
 	unsigned long flags;
 	struct softnet_data *sd = &get_cpu_var(softnet_data);
@@ -212,7 +211,7 @@ static struct sk_buff *find_skb(struct n
 	int count = 0;
 	struct sk_buff *skb;
 
-	zap_completion_queue();
+	netpoll_do_completion();
 	refill_skbs();
 repeat:
 

-- 


From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 01/17] net: Allow changing number of RX queues
 after device allocation
Date: Mon, 27 Sep 2010 19:24:33 +0100
Message-ID: <1285611873.2263.291.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51009 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759971Ab0I0SYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:24:36 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RPS, we create a kobject for each RX queue based on the number of
queues passed to alloc_netdev_mq().  However, drivers generally do not
determine the numbers of hardware queues to use until much later, so
this usually represents the maximum number the driver may use and not
the actual number in use.

For TX queues, drivers can update the actual number using
netif_set_real_num_tx_queues().  Add a corresponding function for RX
queues, netif_set_real_num_rx_queues().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h |   16 +++++++++++++++-
 net/core/dev.c            |   45 +++++++++++++++++++++++++++++++++++++++++----
 net/core/net-sysfs.c      |   34 +++++++++++++++++++---------------
 net/core/net-sysfs.h      |    4 ++++
 4 files changed, 79 insertions(+), 20 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 01bd4c8..cf3d5a3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -976,8 +976,11 @@ struct net_device {
 
 	struct netdev_rx_queue	*_rx;
 
-	/* Number of RX queues allocated at alloc_netdev_mq() time  */
+	/* Number of RX queues allocated at register_netdev() time */
 	unsigned int		num_rx_queues;
+
+	/* Number of RX queues currently active in device */
+	unsigned int		real_num_rx_queues;
 #endif
 
 	rx_handler_func_t	*rx_handler;
@@ -1684,6 +1687,17 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
 extern void netif_set_real_num_tx_queues(struct net_device *dev,
 					 unsigned int txq);
 
+#ifdef CONFIG_RPS
+extern int netif_set_real_num_rx_queues(struct net_device *dev,
+					unsigned int rxq);
+#else
+static inline int netif_set_real_num_rx_queues(struct net_device *dev,
+						unsigned int rxq)
+{
+	return 0;
+}
+#endif
+
 /* Use this variant when it is known for sure that it
  * is executing from hardware interrupt context or with hardware interrupts
  * disabled.
diff --git a/net/core/dev.c b/net/core/dev.c
index 42b200f..48ad47f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1567,6 +1567,41 @@ void netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
 }
 EXPORT_SYMBOL(netif_set_real_num_tx_queues);
 
+#ifdef CONFIG_RPS
+/**
+ *	netif_set_real_num_rx_queues - set actual number of RX queues used
+ *	@dev: Network device
+ *	@rxq: Actual number of RX queues
+ *
+ *	This must be called either with the rtnl_lock held or before
+ *	registration of the net device.  Returns 0 on success, or a
+ *	negative error code.  If called before registration, it also
+ *	sets the maximum number of queues, and always succeeds.
+ */
+int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq)
+{
+	int rc;
+
+	if (dev->reg_state == NETREG_REGISTERED) {
+		ASSERT_RTNL();
+
+		if (rxq > dev->num_rx_queues)
+			return -EINVAL;
+
+		rc = net_rx_queue_update_kobjects(dev, dev->real_num_rx_queues,
+						  rxq);
+		if (rc)
+			return rc;
+	} else {
+		dev->num_rx_queues = rxq;
+	}
+
+	dev->real_num_rx_queues = rxq;
+	return 0;
+}
+EXPORT_SYMBOL(netif_set_real_num_rx_queues);
+#endif
+
 static inline void __netif_reschedule(struct Qdisc *q)
 {
 	struct softnet_data *sd;
@@ -2352,10 +2387,11 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index = skb_get_rx_queue(skb);
-		if (unlikely(index >= dev->num_rx_queues)) {
-			WARN_ONCE(dev->num_rx_queues > 1, "%s received packet "
-				"on queue %u, but number of RX queues is %u\n",
-				dev->name, index, dev->num_rx_queues);
+		if (unlikely(index >= dev->real_num_rx_queues)) {
+			WARN_ONCE(dev->real_num_rx_queues > 1,
+				  "%s received packet on queue %u, but number "
+				  "of RX queues is %u\n",
+				  dev->name, index, dev->real_num_rx_queues);
 			goto done;
 		}
 		rxqueue = dev->_rx + index;
@@ -5472,6 +5508,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 #ifdef CONFIG_RPS
 	dev->num_rx_queues = queue_count;
+	dev->real_num_rx_queues = queue_count;
 #endif
 
 	dev->gso_max_size = GSO_MAX_SIZE;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 76485a3..4791cfc 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -742,34 +742,38 @@ static int rx_queue_add_kobject(struct net_device *net, int index)
 	return error;
 }
 
-static int rx_queue_register_kobjects(struct net_device *net)
+int
+net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 {
 	int i;
 	int error = 0;
-
-	net->queues_kset = kset_create_and_add("queues",
-	    NULL, &net->dev.kobj);
-	if (!net->queues_kset)
-		return -ENOMEM;
-	for (i = 0; i < net->num_rx_queues; i++) {
+	
+	for (i = old_num; i < new_num; i++) {
 		error = rx_queue_add_kobject(net, i);
-		if (error)
+		if (error) {
+			new_num = old_num;
 			break;
+		}
 	}
 
-	if (error)
-		while (--i >= 0)
-			kobject_put(&net->_rx[i].kobj);
+	while (--i >= new_num)
+		kobject_put(&net->_rx[i].kobj);
 
 	return error;
 }
 
-static void rx_queue_remove_kobjects(struct net_device *net)
+static int rx_queue_register_kobjects(struct net_device *net)
 {
-	int i;
+	net->queues_kset = kset_create_and_add("queues",
+	    NULL, &net->dev.kobj);
+	if (!net->queues_kset)
+		return -ENOMEM;
+	return net_rx_queue_update_kobjects(net, 0, net->real_num_rx_queues);
+}
 
-	for (i = 0; i < net->num_rx_queues; i++)
-		kobject_put(&net->_rx[i].kobj);
+static void rx_queue_remove_kobjects(struct net_device *net)
+{
+	net_rx_queue_update_kobjects(net, net->real_num_rx_queues, 0);
 	kset_unregister(net->queues_kset);
 }
 #endif /* CONFIG_RPS */
diff --git a/net/core/net-sysfs.h b/net/core/net-sysfs.h
index 805555e..778e157 100644
--- a/net/core/net-sysfs.h
+++ b/net/core/net-sysfs.h
@@ -4,4 +4,8 @@
 int netdev_kobject_init(void);
 int netdev_register_kobject(struct net_device *);
 void netdev_unregister_kobject(struct net_device *);
+#ifdef CONFIG_RPS
+int net_rx_queue_update_kobjects(struct net_device *, int old_num, int new_num);
+#endif
+
 #endif
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


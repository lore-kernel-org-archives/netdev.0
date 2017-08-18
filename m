From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 08/10] net: make queue attributes ro_after_init
Date: Fri, 18 Aug 2017 13:46:26 -0700
Message-ID: <20170818204628.17147-9-sthemmin@microsoft.com>
References: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35398 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752085AbdHRUqp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:45 -0400
Received: by mail-pg0-f50.google.com with SMTP id v189so70889230pgd.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:45 -0700 (PDT)
In-Reply-To: <20170818204628.17147-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The XPS queue attributes can be ro_after_init.
Also use __ATTR_RX macros to simplify initialization.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/core/net-sysfs.c | 40 +++++++++++++++++++---------------------
 1 file changed, 19 insertions(+), 21 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index a4af5e2ff398..808fbb837f25 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1010,8 +1010,7 @@ static const struct sysfs_ops netdev_queue_sysfs_ops = {
 	.store = netdev_queue_attr_store,
 };
 
-static ssize_t show_trans_timeout(struct netdev_queue *queue,
-				  char *buf)
+static ssize_t tx_timeout_show(struct netdev_queue *queue, char *buf)
 {
 	unsigned long trans_timeout;
 
@@ -1033,7 +1032,7 @@ static unsigned int get_netdev_queue_index(struct netdev_queue *queue)
 	return i;
 }
 
-static ssize_t show_traffic_class(struct netdev_queue *queue,
+static ssize_t traffic_class_show(struct netdev_queue *queue,
 				  char *buf)
 {
 	struct net_device *dev = queue->dev;
@@ -1047,14 +1046,14 @@ static ssize_t show_traffic_class(struct netdev_queue *queue,
 }
 
 #ifdef CONFIG_XPS
-static ssize_t show_tx_maxrate(struct netdev_queue *queue,
+static ssize_t tx_maxrate_show(struct netdev_queue *queue,
 			       char *buf)
 {
 	return sprintf(buf, "%lu\n", queue->tx_maxrate);
 }
 
-static ssize_t set_tx_maxrate(struct netdev_queue *queue,
-			      const char *buf, size_t len)
+static ssize_t tx_maxrate_store(struct netdev_queue *queue,
+				const char *buf, size_t len)
 {
 	struct net_device *dev = queue->dev;
 	int err, index = get_netdev_queue_index(queue);
@@ -1079,16 +1078,15 @@ static ssize_t set_tx_maxrate(struct netdev_queue *queue,
 	return err;
 }
 
-static struct netdev_queue_attribute queue_tx_maxrate =
-	__ATTR(tx_maxrate, S_IRUGO | S_IWUSR,
-	       show_tx_maxrate, set_tx_maxrate);
+static struct netdev_queue_attribute queue_tx_maxrate __ro_after_init
+	= __ATTR_RW(tx_maxrate);
 #endif
 
-static struct netdev_queue_attribute queue_trans_timeout =
-	__ATTR(tx_timeout, S_IRUGO, show_trans_timeout, NULL);
+static struct netdev_queue_attribute queue_trans_timeout __ro_after_init
+	= __ATTR_RO(tx_timeout);
 
-static struct netdev_queue_attribute queue_traffic_class =
-	__ATTR(traffic_class, S_IRUGO, show_traffic_class, NULL);
+static struct netdev_queue_attribute queue_traffic_class __ro_after_init
+	= __ATTR_RO(traffic_class);
 
 #ifdef CONFIG_BQL
 /*
@@ -1196,8 +1194,8 @@ static const struct attribute_group dql_group = {
 #endif /* CONFIG_BQL */
 
 #ifdef CONFIG_XPS
-static ssize_t show_xps_map(struct netdev_queue *queue,
-			    char *buf)
+static ssize_t xps_cpus_show(struct netdev_queue *queue,
+			     char *buf)
 {
 	struct net_device *dev = queue->dev;
 	int cpu, len, num_tc = 1, tc = 0;
@@ -1243,8 +1241,8 @@ static ssize_t show_xps_map(struct netdev_queue *queue,
 	return len < PAGE_SIZE ? len : -EINVAL;
 }
 
-static ssize_t store_xps_map(struct netdev_queue *queue,
-			     const char *buf, size_t len)
+static ssize_t xps_cpus_store(struct netdev_queue *queue,
+			      const char *buf, size_t len)
 {
 	struct net_device *dev = queue->dev;
 	unsigned long index;
@@ -1272,11 +1270,11 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 	return err ? : len;
 }
 
-static struct netdev_queue_attribute xps_cpus_attribute =
-    __ATTR(xps_cpus, S_IRUGO | S_IWUSR, show_xps_map, store_xps_map);
+static struct netdev_queue_attribute xps_cpus_attribute __ro_after_init
+	= __ATTR_RW(xps_cpus);
 #endif /* CONFIG_XPS */
 
-static struct attribute *netdev_queue_default_attrs[] = {
+static struct attribute *netdev_queue_default_attrs[] __ro_after_init = {
 	&queue_trans_timeout.attr,
 	&queue_traffic_class.attr,
 #ifdef CONFIG_XPS
@@ -1306,7 +1304,7 @@ static const void *netdev_queue_namespace(struct kobject *kobj)
 	return ns;
 }
 
-static struct kobj_type netdev_queue_ktype = {
+static struct kobj_type netdev_queue_ktype __ro_after_init = {
 	.sysfs_ops = &netdev_queue_sysfs_ops,
 	.release = netdev_queue_release,
 	.default_attrs = netdev_queue_default_attrs,
-- 
2.11.0

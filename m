From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH] net: fix "queues" uevent between network namespaces
Date: Thu, 16 Jan 2014 17:24:31 +0800
Message-ID: <1389864271-24212-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:38263 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbaAPJ0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 04:26:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

When I create a new namespace with 'ip netns add net0', or add/remove
new links in a namespace with 'ip link add/delete type veth', rx/tx
queues events can be got in all namespaces. That is because rx/tx queue
ktypes do not have namespace support, and their kobj parents are setted to
NULL. This patch is to fix it.

Reported-by: Libo Chen <chenlibo@huawei.com>
Signed-off-by: Libo Chen <chenlibo@huawei.com>
Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 lib/kobject_uevent.c | 10 ++++++++--
 net/core/net-sysfs.c | 26 ++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 52e5abb..5f72767 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -88,11 +88,17 @@ out:
 #ifdef CONFIG_NET
 static int kobj_bcast_filter(struct sock *dsk, struct sk_buff *skb, void *data)
 {
-	struct kobject *kobj = data;
+	struct kobject *kobj = data, *ksobj;
 	const struct kobj_ns_type_operations *ops;
 
 	ops = kobj_ns_ops(kobj);
-	if (ops) {
+	if (!ops && kobj->kset) {
+		ksobj = &kobj->kset->kobj;
+		if (ksobj->parent != NULL)
+			ops = kobj_ns_ops(ksobj->parent);
+	}
+
+	if (ops && ops->netlink_ns && kobj->ktype->namespace) {
 		const void *sock_ns, *ns;
 		ns = kobj->ktype->namespace(kobj);
 		sock_ns = ops->netlink_ns(dsk);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 49843bf..0cabe7c 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -748,10 +748,23 @@ static void rx_queue_release(struct kobject *kobj)
 	dev_put(queue->dev);
 }
 
+static const void *rx_queue_namespace(struct kobject *kobj)
+{
+	struct netdev_rx_queue *queue = to_rx_queue(kobj);
+	struct device *dev = &queue->dev->dev;
+	const void *ns = NULL;
+
+	if (dev->class && dev->class->ns_type)
+		ns = dev->class->namespace(dev);
+
+	return ns;
+}
+
 static struct kobj_type rx_queue_ktype = {
 	.sysfs_ops = &rx_queue_sysfs_ops,
 	.release = rx_queue_release,
 	.default_attrs = rx_queue_default_attrs,
+	.namespace = rx_queue_namespace
 };
 
 static int rx_queue_add_kobject(struct net_device *net, int index)
@@ -1082,10 +1095,23 @@ static void netdev_queue_release(struct kobject *kobj)
 	dev_put(queue->dev);
 }
 
+static const void *netdev_queue_namespace(struct kobject *kobj)
+{
+	struct netdev_queue *queue = to_netdev_queue(kobj);
+	struct device *dev = &queue->dev->dev;
+	const void *ns = NULL;
+
+	if (dev->class && dev->class->ns_type)
+		ns = dev->class->namespace(dev);
+
+	return ns;
+}
+
 static struct kobj_type netdev_queue_ktype = {
 	.sysfs_ops = &netdev_queue_sysfs_ops,
 	.release = netdev_queue_release,
 	.default_attrs = netdev_queue_default_attrs,
+	.namespace = netdev_queue_namespace,
 };
 
 static int netdev_queue_add_kobject(struct net_device *net, int index)
-- 
1.7.12

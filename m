From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] vrf: remove slave queue and private slave struct
Date: Tue, 24 Nov 2015 14:29:16 +0100
Message-ID: <1448371756-32188-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, davem@davemloft.net,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38526 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876AbbKXN3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 08:29:25 -0500
Received: by wmec201 with SMTP id c201so26577082wme.1
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 05:29:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

The private slave queue and slave struct haven't been used for anything
and aren't needed, this allows to reduce memory usage and simplify
enslave/release. We can use netdev_for_each_lower_dev() to free the vrf
ports when deleting a vrf device. Also if in the future a private struct
is needed for each slave, it can be implemented via lower devices'
private member (similar to how bonding does it).

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
I've run some simple tests - enslave/release/module load/unload.

 drivers/net/vrf.c | 68 ++++---------------------------------------------------
 1 file changed, 5 insertions(+), 63 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 92fa3e1ea65c..c2d54c4ed556 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -46,17 +46,7 @@
 #define vrf_master_get_rcu(dev) \
 	((struct net_device *)rcu_dereference(dev->rx_handler_data))
 
-struct slave {
-	struct list_head        list;
-	struct net_device       *dev;
-};
-
-struct slave_queue {
-	struct list_head        all_slaves;
-};
-
 struct net_vrf {
-	struct slave_queue      queue;
 	struct rtable           *rth;
 	struct rt6_info		*rt6;
 	u32                     tb_id;
@@ -621,42 +611,9 @@ static void cycle_netdev(struct net_device *dev)
 	}
 }
 
-static struct slave *__vrf_find_slave_dev(struct slave_queue *queue,
-					  struct net_device *dev)
-{
-	struct list_head *head = &queue->all_slaves;
-	struct slave *slave;
-
-	list_for_each_entry(slave, head, list) {
-		if (slave->dev == dev)
-			return slave;
-	}
-
-	return NULL;
-}
-
-/* inverse of __vrf_insert_slave */
-static void __vrf_remove_slave(struct slave_queue *queue, struct slave *slave)
-{
-	list_del(&slave->list);
-}
-
-static void __vrf_insert_slave(struct slave_queue *queue, struct slave *slave)
-{
-	list_add(&slave->list, &queue->all_slaves);
-}
-
 static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
-	struct slave *slave = kzalloc(sizeof(*slave), GFP_KERNEL);
-	struct net_vrf *vrf = netdev_priv(dev);
-	struct slave_queue *queue = &vrf->queue;
-	int ret = -ENOMEM;
-
-	if (!slave)
-		goto out_fail;
-
-	slave->dev = port_dev;
+	int ret;
 
 	/* register the packet handler for slave ports */
 	ret = netdev_rx_handler_register(port_dev, vrf_handle_frame, dev);
@@ -672,7 +629,6 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 		goto out_unregister;
 
 	port_dev->priv_flags |= IFF_L3MDEV_SLAVE;
-	__vrf_insert_slave(queue, slave);
 	cycle_netdev(port_dev);
 
 	return 0;
@@ -680,7 +636,6 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 out_unregister:
 	netdev_rx_handler_unregister(port_dev);
 out_fail:
-	kfree(slave);
 	return ret;
 }
 
@@ -695,10 +650,6 @@ static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 /* inverse of do_vrf_add_slave */
 static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
 {
-	struct net_vrf *vrf = netdev_priv(dev);
-	struct slave_queue *queue = &vrf->queue;
-	struct slave *slave;
-
 	netdev_upper_dev_unlink(port_dev, dev);
 	port_dev->priv_flags &= ~IFF_L3MDEV_SLAVE;
 
@@ -706,12 +657,6 @@ static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
 
 	cycle_netdev(port_dev);
 
-	slave = __vrf_find_slave_dev(queue, port_dev);
-	if (slave)
-		__vrf_remove_slave(queue, slave);
-
-	kfree(slave);
-
 	return 0;
 }
 
@@ -723,15 +668,14 @@ static int vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
 static void vrf_dev_uninit(struct net_device *dev)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
-	struct slave_queue *queue = &vrf->queue;
-	struct list_head *head = &queue->all_slaves;
-	struct slave *slave, *next;
+	struct net_device *port_dev;
+	struct list_head *iter;
 
 	vrf_rtable_destroy(vrf);
 	vrf_rt6_destroy(vrf);
 
-	list_for_each_entry_safe(slave, next, head, list)
-		vrf_del_slave(dev, slave->dev);
+	netdev_for_each_lower_dev(dev, port_dev, iter)
+		vrf_del_slave(dev, port_dev);
 
 	free_percpu(dev->dstats);
 	dev->dstats = NULL;
@@ -741,8 +685,6 @@ static int vrf_dev_init(struct net_device *dev)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
 
-	INIT_LIST_HEAD(&vrf->queue.all_slaves);
-
 	dev->dstats = netdev_alloc_pcpu_stats(struct pcpu_dstats);
 	if (!dev->dstats)
 		goto out_nomem;
-- 
2.4.3

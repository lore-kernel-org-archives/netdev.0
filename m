From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a refcnt
 on port.
Date: Wed, 1 Oct 2014 14:56:22 -0400
Message-ID: <20141001185622.GI17706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, raghuram.kothakota@oracle.com,
	sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23079 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbaJAS42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 14:56:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A vnet_port_remove could be triggered as a result of an ldm-unbind operation
by the peer, or a module unload, or other changes to the inter-vnet-link
configuration.  When this is concurrent with vnet_start_xmit(),
the following sequence could occur

  thread 1                                    thread 2
vnet_start_xmit
 -> tx_port_find
    spin_lock_irqsave(&vp->lock..)
    ret = __tx_port_find(..)
    spin_lock_irqrestore(&vp->lock..)
                                           vio_remove -> ..
                                               ->vnet_port_remove
                                           spin_lock_irqsave(&vp->lock..)
                                           cleanup
                                           spin_lock_irqrestore(&vp->lock..)
                                           kfree(port)
 /* attempt to use ret will bomb */

This patch avoids the problem by holding/releasing a refcnt on
the vnet_port.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>

---
 drivers/net/ethernet/sun/sunvnet.c | 61 +++++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/sun/sunvnet.h |  2 ++
 2 files changed, 55 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index e2aacf5..dca4397 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -47,6 +47,42 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 
 static int __vnet_tx_trigger(struct vnet_port *port, u32 start);
 
+static inline int vnet_refcnt_read(const struct vnet_port *port)
+{
+	return atomic_read(&port->refcnt);
+}
+
+static inline void vnet_hold(struct vnet_port *port)
+{
+	atomic_inc(&port->refcnt);
+	BUG_ON(vnet_refcnt_read(port) == 0);
+}
+
+static void vnet_put(struct vnet_port *port)
+{
+	atomic_dec(&port->refcnt);
+}
+
+static void vnet_wait_allrefs(struct vnet_port *port)
+{
+	unsigned long warning_time;
+	int refcnt = vnet_refcnt_read(port);
+
+	warning_time = jiffies;
+	while (refcnt != 0) {
+		msleep(250);
+		refcnt = vnet_refcnt_read(port);
+		if (time_after(jiffies, warning_time + 10 * HZ)) {
+			pr_emerg("vnet_wait_allrefs: waiting for port to "
+				 "%x:%x:%x:%x:%x:%x. Usage count = %d\n",
+				port->raddr[0], port->raddr[1],
+				port->raddr[2], port->raddr[3],
+				port->raddr[4], port->raddr[5], refcnt);
+			warning_time = jiffies;
+		}
+	}
+}
+
 /* Ordered from largest major to lowest */
 static struct vio_version vnet_versions[] = {
 	{ .major = 1, .minor = 6 },
@@ -773,14 +809,14 @@ struct vnet_port *__tx_port_find(struct vnet *vp, struct sk_buff *skb)
 	hlist_for_each_entry(port, hp, hash) {
 		if (!port_is_up(port))
 			continue;
-		if (ether_addr_equal(port->raddr, skb->data))
+		if (ether_addr_equal(port->raddr, skb->data)) {
+			vnet_hold(port);
 			return port;
+		}
 	}
-	list_for_each_entry(port, &vp->port_list, list) {
-		if (!port->switch_port)
-			continue;
-		if (!port_is_up(port))
-			continue;
+	port = vp->switch_port;
+	if (port != NULL && port_is_up(port)) {
+		vnet_hold(port);
 		return port;
 	}
 	return NULL;
@@ -974,6 +1010,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev->stats.tx_errors++;
 		}
 		spin_unlock_irqrestore(&port->vio.lock, flags);
+		vnet_put(port);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1071,6 +1108,7 @@ ldc_start_done:
 	vnet_free_skbs(freeskbs);
 
 	(void)mod_timer(&port->clean_timer, jiffies + VNET_CLEAN_TIMEOUT);
+	vnet_put(port);
 
 	return NETDEV_TX_OK;
 
@@ -1087,6 +1125,8 @@ out_dropped:
 	else
 		del_timer(&port->clean_timer);
 	dev->stats.tx_dropped++;
+	if (port)
+		vnet_put(port);
 	return NETDEV_TX_OK;
 }
 
@@ -1581,10 +1621,12 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	port->switch_port = switch_port;
 
 	spin_lock_irqsave(&vp->lock, flags);
-	if (switch_port)
+	if (switch_port) {
+		vp->switch_port = port;
 		list_add(&port->list, &vp->port_list);
-	else
+	} else {
 		list_add_tail(&port->list, &vp->port_list);
+	}
 	hlist_add_head(&port->hash, &vp->port_hash[vnet_hashfn(port->raddr)]);
 	spin_unlock_irqrestore(&vp->lock, flags);
 
@@ -1631,11 +1673,14 @@ static int vnet_port_remove(struct vio_dev *vdev)
 		 */
 		spin_lock_irqsave(&vp->lock, flags);
 		port->flags |= VNET_PORT_DEAD;
+		if (port->switch_port)
+			vp->switch_port = NULL;
 		list_del(&port->list);
 		hlist_del(&port->hash);
 		spin_unlock_irqrestore(&vp->lock, flags);
 
 		vnet_workq_disable(port);
+		vnet_wait_allrefs(port);
 
 		vnet_port_free_tx_bufs(port);
 		vio_ldc_free(&port->vio);
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index 1182ec6..6f62ea5 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -53,6 +53,7 @@ struct vnet_port {
 	u32			stop_rx_idx;
 	bool			stop_rx;
 	bool			start_cons;
+	atomic_t		refcnt;
 
 	struct timer_list	clean_timer;
 
@@ -104,6 +105,7 @@ struct vnet {
 	u64			local_mac;
 
 	struct tasklet_struct	vnet_tx_wakeup;
+	struct vnet_port	*switch_port;
 };
 
 #endif /* _SUNVNET_H */
-- 
1.8.4.2

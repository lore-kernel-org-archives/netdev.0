From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv5 net-next 2/4] sunvnet: Use RCU to synchronize port usage
 with vnet_port_remove()
Date: Wed, 22 Oct 2014 18:12:34 -0400
Message-ID: <20141022221234.GD17252@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, bob.picco@oracle.com,
	sowmini.varadhan@oracle.com, dwight.engen@oracle.com,
	david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51952 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933196AbaJVWMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 18:12:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A vnet_port_remove could be triggered as a result of an ldm-unbind
operation by the peer, module unload, or other changes to the
inter-vnet-link configuration.  When this is concurrent with
vnet_start_xmit(), there are several race sequences possible,
such as

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

This patch adds RCU locking for port access so that vnet_port_remove
will correctly clean up port-related state.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Dwight Engen <dwight.engen@oracle.com>
Acked-by: Bob Picco <bob.picco@oracle.com>
---
changes since v2: use RCU.
changes since v3: incorporate David Stevens feedback

 drivers/net/ethernet/sun/sunvnet.c | 62 ++++++++++++++++++++------------------
 1 file changed, 33 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 8827fef..097ea5f 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -619,7 +619,8 @@ static void maybe_tx_wakeup(struct vnet *vp)
 		struct vnet_port *port;
 		int wake = 1;
 
-		list_for_each_entry(port, &vp->port_list, list) {
+		rcu_read_lock();
+		list_for_each_entry_rcu(port, &vp->port_list, list) {
 			struct vio_dring_state *dr;
 
 			dr = &port->vio.drings[VIO_DRIVER_TX_RING];
@@ -629,6 +630,7 @@ static void maybe_tx_wakeup(struct vnet *vp)
 				break;
 			}
 		}
+		rcu_read_unlock();
 		if (wake)
 			netif_wake_queue(dev);
 	}
@@ -826,13 +828,13 @@ struct vnet_port *__tx_port_find(struct vnet *vp, struct sk_buff *skb)
 	struct hlist_head *hp = &vp->port_hash[hash];
 	struct vnet_port *port;
 
-	hlist_for_each_entry(port, hp, hash) {
+	hlist_for_each_entry_rcu(port, hp, hash) {
 		if (!port_is_up(port))
 			continue;
 		if (ether_addr_equal(port->raddr, skb->data))
 			return port;
 	}
-	list_for_each_entry(port, &vp->port_list, list) {
+	list_for_each_entry_rcu(port, &vp->port_list, list) {
 		if (!port->switch_port)
 			continue;
 		if (!port_is_up(port))
@@ -968,7 +970,7 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, void **pstart,
 static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vnet *vp = netdev_priv(dev);
-	struct vnet_port *port = tx_port_find(vp, skb);
+	struct vnet_port *port = NULL;
 	struct vio_dring_state *dr;
 	struct vio_net_desc *d;
 	unsigned long flags;
@@ -979,14 +981,15 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int nlen = 0;
 	unsigned pending = 0;
 
-	if (unlikely(!port))
-		goto out_dropped;
-
 	skb = vnet_skb_shape(skb, &start, &nlen);
-
 	if (unlikely(!skb))
 		goto out_dropped;
 
+	rcu_read_lock();
+	port = tx_port_find(vp, skb);
+	if (unlikely(!port))
+		goto out_dropped;
+
 	if (skb->len > port->rmtu) {
 		unsigned long localmtu = port->rmtu - ETH_HLEN;
 
@@ -1004,6 +1007,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			fl4.saddr = ip_hdr(skb)->saddr;
 
 			rt = ip_route_output_key(dev_net(dev), &fl4);
+			rcu_read_unlock();
 			if (!IS_ERR(rt)) {
 				skb_dst_set(skb, &rt->dst);
 				icmp_send(skb, ICMP_DEST_UNREACH,
@@ -1029,7 +1033,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
 			dev->stats.tx_errors++;
 		}
-		spin_unlock_irqrestore(&port->vio.lock, flags);
+		rcu_read_unlock();
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1123,25 +1127,27 @@ ldc_start_done:
 	}
 
 	spin_unlock_irqrestore(&port->vio.lock, flags);
+	(void)mod_timer(&port->clean_timer, jiffies + VNET_CLEAN_TIMEOUT);
+	rcu_read_unlock();
 
 	vnet_free_skbs(freeskbs);
 
-	(void)mod_timer(&port->clean_timer, jiffies + VNET_CLEAN_TIMEOUT);
-
 	return NETDEV_TX_OK;
 
 out_dropped_unlock:
 	spin_unlock_irqrestore(&port->vio.lock, flags);
 
 out_dropped:
-	if (skb)
-		dev_kfree_skb(skb);
-	vnet_free_skbs(freeskbs);
 	if (pending)
 		(void)mod_timer(&port->clean_timer,
 				jiffies + VNET_CLEAN_TIMEOUT);
 	else if (port)
 		del_timer(&port->clean_timer);
+	if (port)
+		rcu_read_unlock();
+	if (skb)
+		dev_kfree_skb(skb);
+	vnet_free_skbs(freeskbs);
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
 }
@@ -1271,18 +1277,17 @@ static void vnet_set_rx_mode(struct net_device *dev)
 {
 	struct vnet *vp = netdev_priv(dev);
 	struct vnet_port *port;
-	unsigned long flags;
 
-	spin_lock_irqsave(&vp->lock, flags);
-	if (!list_empty(&vp->port_list)) {
-		port = list_entry(vp->port_list.next, struct vnet_port, list);
+	rcu_read_lock();
+	list_for_each_entry_rcu(port, &vp->port_list, list) {
 
 		if (port->switch_port) {
 			__update_mc_list(vp, dev);
 			__send_mc_list(vp, port);
+			break;
 		}
 	}
-	spin_unlock_irqrestore(&vp->lock, flags);
+	rcu_read_unlock();
 }
 
 static int vnet_change_mtu(struct net_device *dev, int new_mtu)
@@ -1635,10 +1640,11 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 
 	spin_lock_irqsave(&vp->lock, flags);
 	if (switch_port)
-		list_add(&port->list, &vp->port_list);
+		list_add_rcu(&port->list, &vp->port_list);
 	else
-		list_add_tail(&port->list, &vp->port_list);
-	hlist_add_head(&port->hash, &vp->port_hash[vnet_hashfn(port->raddr)]);
+		list_add_tail_rcu(&port->list, &vp->port_list);
+	hlist_add_head_rcu(&port->hash,
+			   &vp->port_hash[vnet_hashfn(port->raddr)]);
 	spin_unlock_irqrestore(&vp->lock, flags);
 
 	dev_set_drvdata(&vdev->dev, port);
@@ -1673,18 +1679,16 @@ static int vnet_port_remove(struct vio_dev *vdev)
 	struct vnet_port *port = dev_get_drvdata(&vdev->dev);
 
 	if (port) {
-		struct vnet *vp = port->vp;
-		unsigned long flags;
 
 		del_timer_sync(&port->vio.timer);
-		del_timer_sync(&port->clean_timer);
 
 		napi_disable(&port->napi);
-		spin_lock_irqsave(&vp->lock, flags);
-		list_del(&port->list);
-		hlist_del(&port->hash);
-		spin_unlock_irqrestore(&vp->lock, flags);
 
+		list_del_rcu(&port->list);
+		hlist_del_rcu(&port->hash);
+
+		synchronize_rcu();
+		del_timer_sync(&port->clean_timer);
 		netif_napi_del(&port->napi);
 		vnet_port_free_tx_bufs(port);
 		vio_ldc_free(&port->vio);
-- 
1.8.4.2

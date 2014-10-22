From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv5 net-next 4/4] sunvnet: Remove irqsave/irqrestore on vio.lock
Date: Wed, 22 Oct 2014 18:12:52 -0400
Message-ID: <20141022221252.GF17252@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16444 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933196AbaJVWMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 18:12:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After the  NAPIfication of sunvnet, we no longer need to
synchronize by doing irqsave/restore on vio.lock in the
I/O fastpath.

NAPI ->poll() is non-reentrant, so all RX processing occurs
strictly in a serialized environment. TX reclaim is done in NAPI
context, so the netif_tx_lock can be used to serialize
critical sections between Tx and Rx paths.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c | 30 +++++-------------------------
 1 file changed, 5 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 097ea5f..ac5cfc0 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -844,18 +844,6 @@ struct vnet_port *__tx_port_find(struct vnet *vp, struct sk_buff *skb)
 	return NULL;
 }
 
-struct vnet_port *tx_port_find(struct vnet *vp, struct sk_buff *skb)
-{
-	struct vnet_port *ret;
-	unsigned long flags;
-
-	spin_lock_irqsave(&vp->lock, flags);
-	ret = __tx_port_find(vp, skb);
-	spin_unlock_irqrestore(&vp->lock, flags);
-
-	return ret;
-}
-
 static struct sk_buff *vnet_clean_tx_ring(struct vnet_port *port,
 					  unsigned *pending)
 {
@@ -916,11 +904,10 @@ static void vnet_clean_timer_expire(unsigned long port0)
 	struct vnet_port *port = (struct vnet_port *)port0;
 	struct sk_buff *freeskbs;
 	unsigned pending;
-	unsigned long flags;
 
-	spin_lock_irqsave(&port->vio.lock, flags);
+	netif_tx_lock(port->vp->dev);
 	freeskbs = vnet_clean_tx_ring(port, &pending);
-	spin_unlock_irqrestore(&port->vio.lock, flags);
+	netif_tx_unlock(port->vp->dev);
 
 	vnet_free_skbs(freeskbs);
 
@@ -973,7 +960,6 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct vnet_port *port = NULL;
 	struct vio_dring_state *dr;
 	struct vio_net_desc *d;
-	unsigned long flags;
 	unsigned int len;
 	struct sk_buff *freeskbs = NULL;
 	int i, err, txi;
@@ -986,7 +972,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out_dropped;
 
 	rcu_read_lock();
-	port = tx_port_find(vp, skb);
+	port = __tx_port_find(vp, skb);
 	if (unlikely(!port))
 		goto out_dropped;
 
@@ -1022,8 +1008,6 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out_dropped;
 	}
 
-	spin_lock_irqsave(&port->vio.lock, flags);
-
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 	if (unlikely(vnet_tx_dring_avail(dr) < 1)) {
 		if (!netif_queue_stopped(dev)) {
@@ -1057,7 +1041,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			     (LDC_MAP_SHADOW | LDC_MAP_DIRECT | LDC_MAP_RW));
 	if (err < 0) {
 		netdev_info(dev, "tx buffer map error %d\n", err);
-		goto out_dropped_unlock;
+		goto out_dropped;
 	}
 	port->tx_bufs[txi].ncookies = err;
 
@@ -1110,7 +1094,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netdev_info(dev, "TX trigger error %d\n", err);
 		d->hdr.state = VIO_DESC_FREE;
 		dev->stats.tx_carrier_errors++;
-		goto out_dropped_unlock;
+		goto out_dropped;
 	}
 
 ldc_start_done:
@@ -1126,7 +1110,6 @@ ldc_start_done:
 			netif_wake_queue(dev);
 	}
 
-	spin_unlock_irqrestore(&port->vio.lock, flags);
 	(void)mod_timer(&port->clean_timer, jiffies + VNET_CLEAN_TIMEOUT);
 	rcu_read_unlock();
 
@@ -1134,9 +1117,6 @@ ldc_start_done:
 
 	return NETDEV_TX_OK;
 
-out_dropped_unlock:
-	spin_unlock_irqrestore(&port->vio.lock, flags);
-
 out_dropped:
 	if (pending)
 		(void)mod_timer(&port->clean_timer,
-- 
1.8.4.2

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] sunvnet: Fixes to avoid soft lockup in sunvnet
Date: Sun, 10 Aug 2014 15:48:07 -0400
Message-ID: <20140810194807.GB5222@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com, davem@davemloft.net,
	raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23237 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaHJTsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 15:48:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1. ldc_rx -> vnet_rx -> .. -> vnet_walk_rx->vnet_send_ack should not
   spin into an infinite loop waiting  EAGAIN to lift.

   The sender could have sent us a burst, and gone to lunch without
   doing any more ldc_read()'s. That should not cause the receiver to
   loop infinitely till soft-lockup kicks in.

2. Similarly __vnet_tx_trigger should only loop on EAGAIN a finite
   number of times. The caller (vnet_start_xmit()) already has code
   to reset the dring state and bail on errors from __vnet_tx_trigger()

3. No need to ask for an ack with every vnet_start_xmit()- the single
   ACK with DRING_STOPPED is sufficient for the protocol, and we free
   the sk_buff in vnet_start_xmit itself, so we dont need an ACK back.

4. At the tail of vnet_event(), if we hit the maybe_tx_wakeup()
   condition, we try to take the netif_tx_lock() in the
   recv-interrupt-context and can deadlock with dev_watchdog().
   Two changes to fix this:
   (a) The contents of maybe_tx_wakeup() should be moved into
       vnet_tx_timeout
   (b) vnet_event() should kick off a tasklet that triggers
       netif_wake_queue()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c | 82 ++++++++++++++++++++++++++++----------
 drivers/net/ethernet/sun/sunvnet.h |  4 ++
 2 files changed, 65 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index d813bfb..c2dea35 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -32,6 +32,14 @@ MODULE_DESCRIPTION("Sun LDOM virtual network driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
+static void vnet_tx_timeout(struct net_device *dev);
+
+/*
+ * Heuristic for the number of times to exponentially backoff and
+ * retry sending an LDC trigger when EAGAIN is encountered
+ */
+#define	VNET_MAX_RETRIES	10
+
 /* Ordered from largest major to lowest */
 static struct vio_version vnet_versions[] = {
 	{ .major = 1, .minor = 0 },
@@ -260,6 +268,7 @@ static int vnet_send_ack(struct vnet_port *port, struct vio_dring_state *dr,
 		.state			= vio_dring_state,
 	};
 	int err, delay;
+	int retries = 0;
 
 	hdr.seq = dr->snd_nxt;
 	delay = 1;
@@ -272,6 +281,14 @@ static int vnet_send_ack(struct vnet_port *port, struct vio_dring_state *dr,
 		udelay(delay);
 		if ((delay <<= 1) > 128)
 			delay = 128;
+		if (retries++ > VNET_MAX_RETRIES) {
+			printk(KERN_INFO 
+			    "ECONNRESET %x:%x:%x:%x:%x:%x\n",
+			    port->raddr[0], port->raddr[1],
+			    port->raddr[2], port->raddr[3],
+			    port->raddr[4], port->raddr[5]);
+			err = -ECONNRESET;
+		}
 	} while (err == -EAGAIN);
 
 	return err;
@@ -475,28 +492,13 @@ static int handle_mcast(struct vnet_port *port, void *msgbuf)
 	return 0;
 }
 
-static void maybe_tx_wakeup(struct vnet *vp)
+static void maybe_tx_wakeup(unsigned long param)
 {
+	struct vnet *vp = (struct vnet *)param;
 	struct net_device *dev = vp->dev;
 
 	netif_tx_lock(dev);
-	if (likely(netif_queue_stopped(dev))) {
-		struct vnet_port *port;
-		int wake = 1;
-
-		list_for_each_entry(port, &vp->port_list, list) {
-			struct vio_dring_state *dr;
-
-			dr = &port->vio.drings[VIO_DRIVER_TX_RING];
-			if (vnet_tx_dring_avail(dr) <
-			    VNET_TX_WAKEUP_THRESH(dr)) {
-				wake = 0;
-				break;
-			}
-		}
-		if (wake)
-			netif_wake_queue(dev);
-	}
+	vnet_tx_timeout(dev);
 	netif_tx_unlock(dev);
 }
 
@@ -573,8 +575,14 @@ static void vnet_event(void *arg, int event)
 			break;
 	}
 	spin_unlock(&vio->lock);
+	/*
+	 * Kick off a tasklet to wake the queue.  We cannot call 
+	 * maybe_tx_wakeup directly here because we could deadlock on
+	 * netif_tx_lock() with dev_watchdog()
+	 */
 	if (unlikely(tx_wakeup && err != -ECONNRESET))
-		maybe_tx_wakeup(port->vp);
+		tasklet_schedule(&port->vp->vnet_tx_wakeup);
+	
 	local_irq_restore(flags);
 }
 
@@ -593,6 +601,7 @@ static int __vnet_tx_trigger(struct vnet_port *port)
 		.end_idx		= (u32) -1,
 	};
 	int err, delay;
+	int retries = 0;
 
 	hdr.seq = dr->snd_nxt;
 	delay = 1;
@@ -605,6 +614,8 @@ static int __vnet_tx_trigger(struct vnet_port *port)
 		udelay(delay);
 		if ((delay <<= 1) > 128)
 			delay = 128;
+		if (retries++ > VNET_MAX_RETRIES)
+			break;
 	} while (err == -EAGAIN);
 
 	return err;
@@ -691,7 +702,16 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		memset(tx_buf+VNET_PACKET_SKIP+skb->len, 0, len - skb->len);
 	}
 
-	d->hdr.ack = VIO_ACK_ENABLE;
+	/*
+	 * We don't rely on the ACKs to free the skb in vnet_start_xmit(),
+	 * thus it is safe to not set VIO_ACK_ENABLE for each transmission:
+	 * the protocol itself does not require it as long as the peer
+	 * sends a VIO_SUBTYPE_ACK for VIO_DRING_STOPPED. 
+	 *
+	 * An ACK for every packet in the ring is expensive as the
+	 * sending of LDC messages is slow and affects performance.
+	 */
+	d->hdr.ack = VIO_ACK_DISABLE;
 	d->size = len;
 	d->ncookies = port->tx_bufs[dr->prod].ncookies;
 	for (i = 0; i < d->ncookies; i++)
@@ -739,7 +759,25 @@ out_dropped:
 
 static void vnet_tx_timeout(struct net_device *dev)
 {
-	/* XXX Implement me XXX */
+	struct vnet *vp = netdev_priv(dev);
+
+	if (likely(netif_queue_stopped(dev))) {
+		struct vnet_port *port;
+		int wake = 1;
+
+		list_for_each_entry(port, &vp->port_list, list) {
+			struct vio_dring_state *dr;
+
+			dr = &port->vio.drings[VIO_DRIVER_TX_RING];
+			if (vnet_tx_dring_avail(dr) <
+			    VNET_TX_WAKEUP_THRESH(dr)) {
+				wake = 0;
+				break;
+			}
+		}
+		if (wake)
+			netif_wake_queue(dev);
+	}
 }
 
 static int vnet_open(struct net_device *dev)
@@ -1046,6 +1084,7 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	vp = netdev_priv(dev);
 
 	spin_lock_init(&vp->lock);
+	tasklet_init(&vp->vnet_tx_wakeup, maybe_tx_wakeup, (unsigned long)vp);
 	vp->dev = dev;
 
 	INIT_LIST_HEAD(&vp->port_list);
@@ -1105,6 +1144,7 @@ static void vnet_cleanup(void)
 		vp = list_first_entry(&vnet_list, struct vnet, list);
 		list_del(&vp->list);
 		dev = vp->dev;
+		tasklet_kill(&vp->vnet_tx_wakeup);
 		/* vio_unregister_driver() should have cleaned up port_list */
 		BUG_ON(!list_empty(&vp->port_list));
 		unregister_netdev(dev);
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index d347a5b..0e872aa 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -1,6 +1,8 @@
 #ifndef _SUNVNET_H
 #define _SUNVNET_H
 
+#include <linux/interrupt.h> 
+
 #define DESC_NCOOKIES(entry_size)	\
 	((entry_size) - sizeof(struct vio_net_desc))
 
@@ -78,6 +80,8 @@ struct vnet {
 
 	struct list_head	list;
 	u64			local_mac;
+
+	struct tasklet_struct	vnet_tx_wakeup;
 };
 
 #endif /* _SUNVNET_H */
-- 
1.8.4.2

From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 1/6] vxge: Remove queue_state references
Date: Thu, 15 Jul 2010 13:47:23 -0500
Message-ID: <1279219648-10345-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51128 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934215Ab0GOSrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 14:47:25 -0400
Received: by pvc7 with SMTP id 7so400928pvc.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 11:47:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove queue_state references, as they are no longer necessary.

Also, The driver needs to start/stop the queue regardless of which type
of steering is enabled.  Remove checks for TX_MULTIQ_STEERING only and
start/stop for all steering types.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
---
 drivers/net/vxge/vxge-main.c |  118 +++++++++++++++---------------------------
 drivers/net/vxge/vxge-main.h |   10 +---
 2 files changed, 42 insertions(+), 86 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index ed17865..e78703d 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -133,75 +133,48 @@ static inline void VXGE_COMPLETE_ALL_RX(struct vxgedev *vdev)
 /*
  * MultiQ manipulation helper functions
  */
-void vxge_stop_all_tx_queue(struct vxgedev *vdev)
+static inline int vxge_netif_queue_stopped(struct vxge_fifo *fifo)
 {
-	int i;
-	struct net_device *dev = vdev->ndev;
+	struct net_device *dev = fifo->ndev;
+	struct netdev_queue *txq = NULL;
+	int vpath_no = fifo->driver_id;
+	int ret = 0;
 
-	if (vdev->config.tx_steering_type != TX_MULTIQ_STEERING) {
-		for (i = 0; i < vdev->no_of_vpath; i++)
-			vdev->vpaths[i].fifo.queue_state = VPATH_QUEUE_STOP;
-	}
-	netif_tx_stop_all_queues(dev);
+	if (fifo->tx_steering_type)
+		txq = netdev_get_tx_queue(dev, vpath_no);
+	else
+		txq = netdev_get_tx_queue(dev, 0);
+
+	ret = netif_tx_queue_stopped(txq);
+	return ret;
 }
 
 void vxge_stop_tx_queue(struct vxge_fifo *fifo)
 {
 	struct net_device *dev = fifo->ndev;
-
 	struct netdev_queue *txq = NULL;
-	if (fifo->tx_steering_type == TX_MULTIQ_STEERING)
+
+	if (fifo->tx_steering_type)
 		txq = netdev_get_tx_queue(dev, fifo->driver_id);
-	else {
+	else
 		txq = netdev_get_tx_queue(dev, 0);
-		fifo->queue_state = VPATH_QUEUE_STOP;
-	}
 
 	netif_tx_stop_queue(txq);
 }
 
-void vxge_start_all_tx_queue(struct vxgedev *vdev)
-{
-	int i;
-	struct net_device *dev = vdev->ndev;
-
-	if (vdev->config.tx_steering_type != TX_MULTIQ_STEERING) {
-		for (i = 0; i < vdev->no_of_vpath; i++)
-			vdev->vpaths[i].fifo.queue_state = VPATH_QUEUE_START;
-	}
-	netif_tx_start_all_queues(dev);
-}
-
-static void vxge_wake_all_tx_queue(struct vxgedev *vdev)
-{
-	int i;
-	struct net_device *dev = vdev->ndev;
-
-	if (vdev->config.tx_steering_type != TX_MULTIQ_STEERING) {
-		for (i = 0; i < vdev->no_of_vpath; i++)
-			vdev->vpaths[i].fifo.queue_state = VPATH_QUEUE_START;
-	}
-	netif_tx_wake_all_queues(dev);
-}
-
-void vxge_wake_tx_queue(struct vxge_fifo *fifo, struct sk_buff *skb)
+void vxge_wake_tx_queue(struct vxge_fifo *fifo)
 {
 	struct net_device *dev = fifo->ndev;
-
-	int vpath_no = fifo->driver_id;
 	struct netdev_queue *txq = NULL;
-	if (fifo->tx_steering_type == TX_MULTIQ_STEERING) {
+	int vpath_no = fifo->driver_id;
+
+	if (fifo->tx_steering_type)
 		txq = netdev_get_tx_queue(dev, vpath_no);
-		if (netif_tx_queue_stopped(txq))
-			netif_tx_wake_queue(txq);
-	} else {
+	else
 		txq = netdev_get_tx_queue(dev, 0);
-		if (fifo->queue_state == VPATH_QUEUE_STOP)
-			if (netif_tx_queue_stopped(txq)) {
-				fifo->queue_state = VPATH_QUEUE_START;
-				netif_tx_wake_queue(txq);
-			}
-	}
+
+	if (netif_tx_queue_stopped(txq))
+		netif_tx_wake_queue(txq);
 }
 
 /*
@@ -222,7 +195,7 @@ vxge_callback_link_up(struct __vxge_hw_device *hldev)
 	vdev->stats.link_up++;
 
 	netif_carrier_on(vdev->ndev);
-	vxge_wake_all_tx_queue(vdev);
+	netif_tx_wake_all_queues(vdev->ndev);
 
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s: %s:%d Exiting...", vdev->ndev->name, __func__, __LINE__);
@@ -246,7 +219,7 @@ vxge_callback_link_down(struct __vxge_hw_device *hldev)
 
 	vdev->stats.link_down++;
 	netif_carrier_off(vdev->ndev);
-	vxge_stop_all_tx_queue(vdev);
+	netif_tx_stop_all_queues(vdev->ndev);
 
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s: %s:%d Exiting...", vdev->ndev->name, __func__, __LINE__);
@@ -677,7 +650,7 @@ vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
 				&dtr, &t_code) == VXGE_HW_OK);
 
 	*skb_ptr = done_skb;
-	vxge_wake_tx_queue(fifo, skb);
+	vxge_wake_tx_queue(fifo);
 
 	vxge_debug_entryexit(VXGE_TRACE,
 				"%s: %s:%d  Exiting...",
@@ -881,17 +854,11 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 			return NETDEV_TX_LOCKED;
 	}
 
-	if (vdev->config.tx_steering_type == TX_MULTIQ_STEERING) {
-		if (netif_subqueue_stopped(dev, skb)) {
-			spin_unlock_irqrestore(&fifo->tx_lock, flags);
-			return NETDEV_TX_BUSY;
-		}
-	} else if (unlikely(fifo->queue_state == VPATH_QUEUE_STOP)) {
-		if (netif_queue_stopped(dev)) {
-			spin_unlock_irqrestore(&fifo->tx_lock, flags);
-			return NETDEV_TX_BUSY;
-		}
+	if (vxge_netif_queue_stopped(fifo)) {
+		spin_unlock_irqrestore(&fifo->tx_lock, flags);
+		return NETDEV_TX_BUSY;
 	}
+
 	avail = vxge_hw_fifo_free_txdl_count_get(fifo_hw);
 	if (avail == 0) {
 		vxge_debug_tx(VXGE_ERR,
@@ -1478,7 +1445,7 @@ static int vxge_reset_vpath(struct vxgedev *vdev, int vp_id)
 	clear_bit(vp_id, &vdev->vp_reset);
 
 	/* Start the vpath queue */
-	vxge_wake_tx_queue(&vdev->vpaths[vp_id].fifo, NULL);
+	vxge_wake_tx_queue(&vdev->vpaths[vp_id].fifo);
 
 	return ret;
 }
@@ -1513,7 +1480,7 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 				"%s: execution mode is debug, returning..",
 				vdev->ndev->name);
 		clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
-		vxge_stop_all_tx_queue(vdev);
+		netif_tx_stop_all_queues(vdev->ndev);
 		return 0;
 		}
 	}
@@ -1523,7 +1490,7 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 
 		switch (vdev->cric_err_event) {
 		case VXGE_HW_EVENT_UNKNOWN:
-			vxge_stop_all_tx_queue(vdev);
+			netif_tx_stop_all_queues(vdev->ndev);
 			vxge_debug_init(VXGE_ERR,
 				"fatal: %s: Disabling device due to"
 				"unknown error",
@@ -1544,7 +1511,7 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 		case VXGE_HW_EVENT_VPATH_ERR:
 			break;
 		case VXGE_HW_EVENT_CRITICAL_ERR:
-			vxge_stop_all_tx_queue(vdev);
+			netif_tx_stop_all_queues(vdev->ndev);
 			vxge_debug_init(VXGE_ERR,
 				"fatal: %s: Disabling device due to"
 				"serious error",
@@ -1554,7 +1521,7 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 			ret = -EPERM;
 			goto out;
 		case VXGE_HW_EVENT_SERR:
-			vxge_stop_all_tx_queue(vdev);
+			netif_tx_stop_all_queues(vdev->ndev);
 			vxge_debug_init(VXGE_ERR,
 				"fatal: %s: Disabling device due to"
 				"serious error",
@@ -1566,7 +1533,7 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 			ret = -EPERM;
 			goto out;
 		case VXGE_HW_EVENT_SLOT_FREEZE:
-			vxge_stop_all_tx_queue(vdev);
+			netif_tx_stop_all_queues(vdev->ndev);
 			vxge_debug_init(VXGE_ERR,
 				"fatal: %s: Disabling device due to"
 				"slot freeze",
@@ -1580,7 +1547,7 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 	}
 
 	if ((event == VXGE_LL_FULL_RESET) || (event == VXGE_LL_START_RESET))
-		vxge_stop_all_tx_queue(vdev);
+		netif_tx_stop_all_queues(vdev->ndev);
 
 	if (event == VXGE_LL_FULL_RESET) {
 		status = vxge_reset_all_vpaths(vdev);
@@ -1640,7 +1607,7 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 			vxge_hw_vpath_rx_doorbell_init(vdev->vpaths[i].handle);
 		}
 
-		vxge_wake_all_tx_queue(vdev);
+		netif_tx_wake_all_queues(vdev->ndev);
 	}
 
 out:
@@ -2779,7 +2746,7 @@ vxge_open(struct net_device *dev)
 		vxge_hw_vpath_rx_doorbell_init(vdev->vpaths[i].handle);
 	}
 
-	vxge_start_all_tx_queue(vdev);
+	netif_tx_start_all_queues(vdev->ndev);
 	goto out0;
 
 out2:
@@ -2902,7 +2869,7 @@ int do_vxge_close(struct net_device *dev, int do_io)
 
 	netif_carrier_off(vdev->ndev);
 	printk(KERN_NOTICE "%s: Link Down\n", vdev->ndev->name);
-	vxge_stop_all_tx_queue(vdev);
+	netif_tx_stop_all_queues(vdev->ndev);
 
 	/* Note that at this point xmit() is stopped by upper layer */
 	if (do_io)
@@ -3215,7 +3182,7 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	u64 stat;
 
 	*vdev_out = NULL;
-	if (config->tx_steering_type == TX_MULTIQ_STEERING)
+	if (config->tx_steering_type)
 		no_of_queue = no_of_vpath;
 
 	ndev = alloc_etherdev_mq(sizeof(struct vxgedev),
@@ -3284,9 +3251,6 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	if (vdev->config.gro_enable)
 		ndev->features |= NETIF_F_GRO;
 
-	if (vdev->config.tx_steering_type == TX_MULTIQ_STEERING)
-		ndev->real_num_tx_queues = no_of_vpath;
-
 #ifdef NETIF_F_LLTX
 	ndev->features |= NETIF_F_LLTX;
 #endif
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 60276b2..a384582 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -228,10 +228,6 @@ struct vxge_fifo {
 	int tx_steering_type;
 	int indicate_max_pkts;
 	spinlock_t tx_lock;
-	/* flag used to maintain queue state when MULTIQ is not enabled */
-#define VPATH_QUEUE_START       0
-#define VPATH_QUEUE_STOP        1
-	int queue_state;
 
 	/* Tx stats */
 	struct vxge_fifo_stats stats;
@@ -447,13 +443,9 @@ int vxge_open_vpaths(struct vxgedev *vdev);
 
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
 
-void vxge_stop_all_tx_queue(struct vxgedev *vdev);
-
 void vxge_stop_tx_queue(struct vxge_fifo *fifo);
 
-void vxge_start_all_tx_queue(struct vxgedev *vdev);
-
-void vxge_wake_tx_queue(struct vxge_fifo *fifo, struct sk_buff *skb);
+void vxge_wake_tx_queue(struct vxge_fifo *fifo);
 
 enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
 	struct macInfo *mac);
-- 
1.7.0.4


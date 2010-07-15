From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 3/6] vxge: NETIF_F_LLTX removal
Date: Thu, 15 Jul 2010 13:47:25 -0500
Message-ID: <1279219648-10345-3-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org, Ramkrishna Vepa <ramkrishna.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:56046 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934255Ab0GOSre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 14:47:34 -0400
Received: by pxi14 with SMTP id 14so527635pxi.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 11:47:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_LLTX and it's usage of local transmit locks are depricated in
favor of using the netdev queue's transmit lock.  Remove the local
lock and all references to it, and use the netdev queue transmit lock
in the transmit completion handler.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
---
 drivers/net/vxge/vxge-main.c    |  149 +++++++++------------------------------
 drivers/net/vxge/vxge-main.h    |   15 +---
 drivers/net/vxge/vxge-traffic.c |    4 +-
 3 files changed, 39 insertions(+), 129 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 66d914c..48f1732 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -87,7 +87,6 @@ static inline int is_vxge_card_up(struct vxgedev *vdev)
 
 static inline void VXGE_COMPLETE_VPATH_TX(struct vxge_fifo *fifo)
 {
-	unsigned long flags = 0;
 	struct sk_buff **skb_ptr = NULL;
 	struct sk_buff **temp;
 #define NR_SKB_COMPLETED 128
@@ -98,15 +97,16 @@ static inline void VXGE_COMPLETE_VPATH_TX(struct vxge_fifo *fifo)
 		more = 0;
 		skb_ptr = completed;
 
-		if (spin_trylock_irqsave(&fifo->tx_lock, flags)) {
+		if (__netif_tx_trylock(fifo->txq)) {
 			vxge_hw_vpath_poll_tx(fifo->handle, &skb_ptr,
 						NR_SKB_COMPLETED, &more);
-			spin_unlock_irqrestore(&fifo->tx_lock, flags);
+			__netif_tx_unlock(fifo->txq);
 		}
+
 		/* free SKBs */
 		for (temp = completed; temp != skb_ptr; temp++)
 			dev_kfree_skb_irq(*temp);
-	} while (more) ;
+	} while (more);
 }
 
 static inline void VXGE_COMPLETE_ALL_TX(struct vxgedev *vdev)
@@ -131,53 +131,6 @@ static inline void VXGE_COMPLETE_ALL_RX(struct vxgedev *vdev)
 }
 
 /*
- * MultiQ manipulation helper functions
- */
-static inline int vxge_netif_queue_stopped(struct vxge_fifo *fifo)
-{
-	struct net_device *dev = fifo->ndev;
-	struct netdev_queue *txq = NULL;
-	int vpath_no = fifo->driver_id;
-	int ret = 0;
-
-	if (fifo->tx_steering_type)
-		txq = netdev_get_tx_queue(dev, vpath_no);
-	else
-		txq = netdev_get_tx_queue(dev, 0);
-
-	ret = netif_tx_queue_stopped(txq);
-	return ret;
-}
-
-void vxge_stop_tx_queue(struct vxge_fifo *fifo)
-{
-	struct net_device *dev = fifo->ndev;
-	struct netdev_queue *txq = NULL;
-
-	if (fifo->tx_steering_type)
-		txq = netdev_get_tx_queue(dev, fifo->driver_id);
-	else
-		txq = netdev_get_tx_queue(dev, 0);
-
-	netif_tx_stop_queue(txq);
-}
-
-void vxge_wake_tx_queue(struct vxge_fifo *fifo)
-{
-	struct net_device *dev = fifo->ndev;
-	struct netdev_queue *txq = NULL;
-	int vpath_no = fifo->driver_id;
-
-	if (fifo->tx_steering_type)
-		txq = netdev_get_tx_queue(dev, vpath_no);
-	else
-		txq = netdev_get_tx_queue(dev, 0);
-
-	if (netif_tx_queue_stopped(txq))
-		netif_tx_wake_queue(txq);
-}
-
-/*
  * vxge_callback_link_up
  *
  * This function is called during interrupt context to notify link up state
@@ -650,7 +603,8 @@ vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
 				&dtr, &t_code) == VXGE_HW_OK);
 
 	*skb_ptr = done_skb;
-	vxge_wake_tx_queue(fifo);
+	if (netif_tx_queue_stopped(fifo->txq))
+		netif_tx_wake_queue(fifo->txq);
 
 	vxge_debug_entryexit(VXGE_TRACE,
 				"%s: %s:%d  Exiting...",
@@ -659,8 +613,7 @@ vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
 }
 
 /* select a vpath to transmit the packet */
-static u32 vxge_get_vpath_no(struct vxgedev *vdev, struct sk_buff *skb,
-	int *do_lock)
+static u32 vxge_get_vpath_no(struct vxgedev *vdev, struct sk_buff *skb)
 {
 	u16 queue_len, counter = 0;
 	if (skb->protocol == htons(ETH_P_IP)) {
@@ -679,12 +632,6 @@ static u32 vxge_get_vpath_no(struct vxgedev *vdev, struct sk_buff *skb,
 				vdev->vpath_selector[queue_len - 1];
 			if (counter >= queue_len)
 				counter = queue_len - 1;
-
-			if (ip->protocol == IPPROTO_UDP) {
-#ifdef NETIF_F_LLTX
-				*do_lock = 0;
-#endif
-			}
 		}
 	}
 	return counter;
@@ -781,8 +728,6 @@ static int vxge_learn_mac(struct vxgedev *vdev, u8 *mac_header)
  *
  * This function is the Tx entry point of the driver. Neterion NIC supports
  * certain protocol assist features on Tx side, namely  CSO, S/G, LSO.
- * NOTE: when device cant queue the pkt, just the trans_start variable will
- * not be upadted.
 */
 static netdev_tx_t
 vxge_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -799,9 +744,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct vxge_tx_priv *txdl_priv = NULL;
 	struct __vxge_hw_fifo *fifo_hw;
 	int offload_type;
-	unsigned long flags = 0;
 	int vpath_no = 0;
-	int do_spin_tx_lock = 1;
 
 	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d",
 			dev->name, __func__, __LINE__);
@@ -837,7 +780,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (vdev->config.tx_steering_type == TX_MULTIQ_STEERING)
 		vpath_no = skb_get_queue_mapping(skb);
 	else if (vdev->config.tx_steering_type == TX_PORT_STEERING)
-		vpath_no = vxge_get_vpath_no(vdev, skb, &do_spin_tx_lock);
+		vpath_no = vxge_get_vpath_no(vdev, skb);
 
 	vxge_debug_tx(VXGE_TRACE, "%s: vpath_no= %d", dev->name, vpath_no);
 
@@ -847,40 +790,29 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 	fifo = &vdev->vpaths[vpath_no].fifo;
 	fifo_hw = fifo->handle;
 
-	if (do_spin_tx_lock)
-		spin_lock_irqsave(&fifo->tx_lock, flags);
-	else {
-		if (unlikely(!spin_trylock_irqsave(&fifo->tx_lock, flags)))
-			return NETDEV_TX_LOCKED;
-	}
-
-	if (vxge_netif_queue_stopped(fifo)) {
-		spin_unlock_irqrestore(&fifo->tx_lock, flags);
+	if (netif_tx_queue_stopped(fifo->txq))
 		return NETDEV_TX_BUSY;
-	}
 
 	avail = vxge_hw_fifo_free_txdl_count_get(fifo_hw);
 	if (avail == 0) {
 		vxge_debug_tx(VXGE_ERR,
 			"%s: No free TXDs available", dev->name);
 		fifo->stats.txd_not_free++;
-		vxge_stop_tx_queue(fifo);
-		goto _exit2;
+		goto _exit0;
 	}
 
 	/* Last TXD?  Stop tx queue to avoid dropping packets.  TX
 	 * completion will resume the queue.
 	 */
 	if (avail == 1)
-		vxge_stop_tx_queue(fifo);
+		netif_tx_stop_queue(fifo->txq);
 
 	status = vxge_hw_fifo_txdl_reserve(fifo_hw, &dtr, &dtr_priv);
 	if (unlikely(status != VXGE_HW_OK)) {
 		vxge_debug_tx(VXGE_ERR,
 		   "%s: Out of descriptors .", dev->name);
 		fifo->stats.txd_out_of_desc++;
-		vxge_stop_tx_queue(fifo);
-		goto _exit2;
+		goto _exit0;
 	}
 
 	vxge_debug_tx(VXGE_TRACE,
@@ -900,9 +832,8 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(pci_dma_mapping_error(fifo->pdev, dma_pointer))) {
 		vxge_hw_fifo_txdl_free(fifo_hw, dtr);
-		vxge_stop_tx_queue(fifo);
 		fifo->stats.pci_map_fail++;
-		goto _exit2;
+		goto _exit0;
 	}
 
 	txdl_priv = vxge_hw_fifo_txdl_private_get(dtr);
@@ -925,13 +856,12 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!frag->size)
 			continue;
 
-		dma_pointer =
-			(u64)pci_map_page(fifo->pdev, frag->page,
+		dma_pointer = (u64) pci_map_page(fifo->pdev, frag->page,
 				frag->page_offset, frag->size,
 				PCI_DMA_TODEVICE);
 
 		if (unlikely(pci_dma_mapping_error(fifo->pdev, dma_pointer)))
-			goto _exit0;
+			goto _exit2;
 		vxge_debug_tx(VXGE_TRACE,
 			"%s: %s:%d frag = %d dma_pointer = 0x%llx",
 				dev->name, __func__, __LINE__, i,
@@ -946,11 +876,9 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 	offload_type = vxge_offload_type(skb);
 
 	if (offload_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)) {
-
 		int mss = vxge_tcp_mss(skb);
 		if (mss) {
-			vxge_debug_tx(VXGE_TRACE,
-				"%s: %s:%d mss = %d",
+			vxge_debug_tx(VXGE_TRACE, "%s: %s:%d mss = %d",
 				dev->name, __func__, __LINE__, mss);
 			vxge_hw_fifo_txdl_mss_set(dtr, mss);
 		} else {
@@ -968,19 +896,13 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 					VXGE_HW_FIFO_TXD_TX_CKO_UDP_EN);
 
 	vxge_hw_fifo_txdl_post(fifo_hw, dtr);
-#ifdef NETIF_F_LLTX
-	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
-#endif
-	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 
-	VXGE_COMPLETE_VPATH_TX(fifo);
 	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d  Exiting...",
 		dev->name, __func__, __LINE__);
 	return NETDEV_TX_OK;
 
-_exit0:
+_exit2:
 	vxge_debug_tx(VXGE_TRACE, "%s: pci_map_page failed", dev->name);
-
 _exit1:
 	j = 0;
 	frag = &skb_shinfo(skb)->frags[0];
@@ -995,10 +917,9 @@ _exit1:
 	}
 
 	vxge_hw_fifo_txdl_free(fifo_hw, dtr);
-_exit2:
+_exit0:
+	netif_tx_stop_queue(fifo->txq);
 	dev_kfree_skb(skb);
-	spin_unlock_irqrestore(&fifo->tx_lock, flags);
-	VXGE_COMPLETE_VPATH_TX(fifo);
 
 	return NETDEV_TX_OK;
 }
@@ -1448,7 +1369,8 @@ static int vxge_reset_vpath(struct vxgedev *vdev, int vp_id)
 	clear_bit(vp_id, &vdev->vp_reset);
 
 	/* Start the vpath queue */
-	vxge_wake_tx_queue(&vpath->fifo);
+	if (netif_tx_queue_stopped(vpath->fifo.txq))
+		netif_tx_wake_queue(vpath->fifo.txq);
 
 	return ret;
 }
@@ -2078,6 +2000,12 @@ int vxge_open_vpaths(struct vxgedev *vdev)
 				vdev->config.tx_steering_type;
 			vpath->fifo.ndev = vdev->ndev;
 			vpath->fifo.pdev = vdev->pdev;
+			if (vdev->config.tx_steering_type)
+				vpath->fifo.txq =
+					netdev_get_tx_queue(vdev->ndev, i);
+			else
+				vpath->fifo.txq =
+					netdev_get_tx_queue(vdev->ndev, 0);
 			vpath->fifo.indicate_max_pkts =
 				vdev->config.fifo_indicate_max_pkts;
 			vpath->ring.rx_vector_no = 0;
@@ -2564,7 +2492,7 @@ static void vxge_poll_vp_lockup(unsigned long data)
 					vxge_vpath_intr_disable(vdev, i);
 
 					/* stop the queue for this vpath */
-					vxge_stop_tx_queue(&vpath->fifo);
+					netif_tx_stop_queue(vpath->fifo.txq);
 					continue;
 				}
 			}
@@ -2627,7 +2555,6 @@ vxge_open(struct net_device *dev)
 		goto out1;
 	}
 
-
 	if (vdev->config.intr_type != MSI_X) {
 		netif_napi_add(dev, &vdev->napi, vxge_poll_inta,
 			vdev->config.napi_weight);
@@ -3200,7 +3127,7 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	struct net_device *ndev;
 	enum vxge_hw_status status = VXGE_HW_OK;
 	struct vxgedev *vdev;
-	int i, ret = 0, no_of_queue = 1;
+	int ret = 0, no_of_queue = 1;
 	u64 stat;
 
 	*vdev_out = NULL;
@@ -3273,13 +3200,6 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	if (vdev->config.gro_enable)
 		ndev->features |= NETIF_F_GRO;
 
-#ifdef NETIF_F_LLTX
-	ndev->features |= NETIF_F_LLTX;
-#endif
-
-	for (i = 0; i < no_of_vpath; i++)
-		spin_lock_init(&vdev->vpaths[i].fifo.tx_lock);
-
 	if (register_netdev(ndev)) {
 		vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
 			"%s: %s : device registration failed!",
@@ -3379,6 +3299,7 @@ vxge_callback_crit_err(struct __vxge_hw_device *hldev,
 {
 	struct net_device *dev = hldev->ndev;
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	struct vxge_vpath *vpath = NULL;
 	int vpath_idx;
 
 	vxge_debug_entryexit(vdev->level_trace,
@@ -3389,9 +3310,11 @@ vxge_callback_crit_err(struct __vxge_hw_device *hldev,
 	 */
 	vdev->cric_err_event = type;
 
-	for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath; vpath_idx++)
-		if (vdev->vpaths[vpath_idx].device_id == vp_id)
+	for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath; vpath_idx++) {
+		vpath = &vdev->vpaths[vpath_idx];
+		if (vpath->device_id == vp_id)
 			break;
+	}
 
 	if (!test_bit(__VXGE_STATE_RESET_CARD, &vdev->state)) {
 		if (type == VXGE_HW_EVENT_SLOT_FREEZE) {
@@ -3428,8 +3351,7 @@ vxge_callback_crit_err(struct __vxge_hw_device *hldev,
 				vxge_vpath_intr_disable(vdev, vpath_idx);
 
 				/* stop the queue for this vpath */
-				vxge_stop_tx_queue(&vdev->vpaths[vpath_idx].
-							fifo);
+				netif_tx_stop_queue(vpath->fifo.txq);
 			}
 		}
 	}
@@ -4274,7 +4196,6 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 		vdev->vpaths[j].is_configured = 1;
 		vdev->vpaths[j].device_id = i;
-		vdev->vpaths[j].fifo.driver_id = j;
 		vdev->vpaths[j].ring.driver_id = j;
 		vdev->vpaths[j].vdev = vdev;
 		vdev->vpaths[j].max_mac_addr_cnt = max_mac_vpath;
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index a384582..5982396 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -217,17 +217,13 @@ struct vxge_fifo_stats {
 };
 
 struct vxge_fifo {
-	struct net_device	*ndev;
-	struct pci_dev		*pdev;
+	struct net_device *ndev;
+	struct pci_dev *pdev;
 	struct __vxge_hw_fifo *handle;
+	struct netdev_queue *txq;
 
-	/* The vpath id maintained in the driver -
-	 * 0 to 'maximum_vpaths_in_function - 1'
-	 */
-	int driver_id;
 	int tx_steering_type;
 	int indicate_max_pkts;
-	spinlock_t tx_lock;
 
 	/* Tx stats */
 	struct vxge_fifo_stats stats;
@@ -275,7 +271,6 @@ struct vxge_ring {
 } ____cacheline_aligned;
 
 struct vxge_vpath {
-
 	struct vxge_fifo fifo;
 	struct vxge_ring ring;
 
@@ -443,10 +438,6 @@ int vxge_open_vpaths(struct vxgedev *vdev);
 
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
 
-void vxge_stop_tx_queue(struct vxge_fifo *fifo);
-
-void vxge_wake_tx_queue(struct vxge_fifo *fifo);
-
 enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
 	struct macInfo *mac);
 
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 6cc1dd7..1a70783 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -2466,14 +2466,12 @@ enum vxge_hw_status vxge_hw_vpath_poll_rx(struct __vxge_hw_ring *ring)
  * the same.
  * @fifo: Handle to the fifo object used for non offload send
  *
- * The function	polls the Tx for the completed	descriptors and	calls
+ * The function polls the Tx for the completed descriptors and calls
  * the driver via supplied completion callback.
  *
  * Returns: VXGE_HW_OK, if the polling is completed successful.
  * VXGE_HW_COMPLETIONS_REMAIN: There are still more completed
  * descriptors available which are yet to be processed.
- *
- * See also: vxge_hw_vpath_poll_tx().
  */
 enum vxge_hw_status vxge_hw_vpath_poll_tx(struct __vxge_hw_fifo *fifo,
 					struct sk_buff ***skb_ptr, int nr_skb,
-- 
1.7.0.4


From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 8/10] Neterion: New driver: Main entry points
Date: 14 Mar 2009 00:21:57 -0800
Message-ID: <1237018906.4966.435.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
To: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:60412 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbZCNHxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 03:53:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch takes care of implementing all driver entry point functions.
- Definition of all module loadable paramters.
- Implementation of all driver entry point functions.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_7/drivers/net/vxge/vxge-main.c patch_8/drivers/net/vxge/vxge-main.c
--- patch_7/drivers/net/vxge/vxge-main.c	1969-12-31 16:00:00.000000000 -0800
+++ patch_8/drivers/net/vxge/vxge-main.c	2009-03-13 00:14:28.000000000 -0700
@@ -0,0 +1,5204 @@
+/******************************************************************************
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License (GPL), incorporated herein by reference.
+ * Drivers based on or derived from this code fall under the GPL and must
+ * retain the authorship, copyright and license notice.  This file is not
+ * a complete program and may only be used when the entire operating
+ * system is licensed under the GPL.
+ * See the file COPYING in this distribution for more information.
+ ******************************************************************************/
+/*******************************************************************************
+ * vxge-main.c: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ *              Virtualized Server Adapter.
+ * Copyright(c) 2002-2009 Neterion Inc.
+ ******************************************************************************/
+/*
+* The module loadable parameters that are supported by the driver and a brief
+* explanation of all the variables:
+* vlan_tag_strip:
+*	Strip VLAN Tag enable/disable. Instructs the device to remove
+*	the VLAN tag from all received tagged frames that are not
+*	replicated at the internal L2 switch.
+*		0 - Do not strip the VLAN tag.
+*		1 - Strip the VLAN tag.
+*
+* addr_learn_en:
+*	Enable Receive Traffic Steering using MAC destination address.
+*		0 - DISABLE
+*		1 - ENABLE
+*
+* lro:
+*	Enable Large Receive Offload (LRO)
+*		0 - DISABLE
+*		1 - ENABLE
+*
+* ring_blocks:
+*	Numbers of RxD blocks in the ring
+*		MIN - 1 and MAX - 128
+*
+* max_config_port:
+*	Maximum number of port to be supported.
+*		MIN -1 and MAX - 2
+*
+* fifo_indicate_max_pkts:
+*	Sets the maximum number of transmit frames to be processed within
+*	single interrupt.
+*		MIN - 1 and MAX - 65536
+*
+* ring_indicate_max_pkts:
+*	Sets the maximum number of received frames to be processed within
+*	single interrupt.
+*		MIN - 1 and MAX - 65536
+*
+* max_config_vpath:
+*	This configures the maximum no of VPATH configures for each
+* 	device function.
+*		MIN - 1 and MAX - 17
+*
+* max_config_dev:
+*	This configures maximum no of Device function to be enabled.
+*		MIN - 1 and MAX - 17
+*
+* intr_type:
+*	This configures the type of interrupt.
+*		0 - INTA
+*		1 - Reserved
+*		2 - MSIX
+*		3 - EMULATED_INTA
+*
+* exec_mode:
+*	This is set make enable the debug mode by default.
+*		0 - DISABLE
+*		1 - ENABLE
+*
+* rx_steering_type:
+*	This parameter is for configuring the receive side steering.
+*		0 - No steering
+*		1 - Reserved
+*		2 - RTH steering (default)
+*
+* tx_steering_type:
+* 	This parameter is for configuring the transmit steering.
+*		0 - No steering
+*		1 - Priority steering
+*		2 - Vlan steering
+*		3 - Multiqueue steering
+*		4 - Port steering (default)
+*
+* tx_pause_enable:
+*	This parameter enables pause frame generation.
+*		0 - Disable
+*		1 - Enable
+*
+* rx_pause_enable:
+*	This parameter enables response to received pause frames
+*		0 - Disable
+*		1 - Enable.
+*
+*/
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/if_vlan.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/string.h>
+#include <linux/init.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/etherdevice.h>
+
+#include <net/sock.h>
+#include <net/ip.h>
+
+#include <linux/ip.h>
+#include <linux/tcp.h>
+
+#include "vxge-main.h"
+#include "vxge-reg.h"
+
+#define VXGE_DRIVER_VERSION_MAJOR 0
+
+static u16 vpath_selector[VXGE_HW_MAX_VIRTUAL_PATHS] =
+		{0, 1, 3, 3, 7, 7, 7, 7, 15, 15, 15, 15, 15, 15, 15, 15, 31};
+static int vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre);
+static void vxge_remove(struct pci_dev *pdev);
+
+static pci_ers_result_t vxge_io_error_detected(struct pci_dev *pdev,
+						pci_channel_state_t state);
+static pci_ers_result_t vxge_io_slot_reset(struct pci_dev *pdev);
+static void vxge_io_resume(struct pci_dev *pdev);
+
+#ifdef CONFIG_PM
+static int vxge_pm_suspend(struct pci_dev *pdev, pm_message_t state);
+static int vxge_pm_resume(struct pci_dev *pdev);
+#endif
+
+#define VXGE_PCI_DEVICE_ID_TITAN_3	0x66f3
+
+static struct pci_device_id vxge_id_table[] __devinitdata = {
+	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_TITAN_WIN, PCI_ANY_ID,
+	PCI_ANY_ID},
+	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_TITAN_UNI, PCI_ANY_ID,
+	PCI_ANY_ID},
+	{0}
+};
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_DESCRIPTION("Titan family network driver");
+
+MODULE_DEVICE_TABLE(pci, vxge_id_table);
+
+static struct pci_error_handlers vxge_err_handler = {
+	.error_detected = vxge_io_error_detected,
+	.slot_reset = vxge_io_slot_reset,
+	.resume = vxge_io_resume,
+};
+
+static struct pci_driver vxge_driver = {
+	.name = VXGE_DRIVER_NAME,
+	.id_table = vxge_id_table,
+	.probe = vxge_probe,
+	.remove = __devexit_p(vxge_remove),
+#ifdef CONFIG_PM
+	.suspend = vxge_pm_suspend,
+	.resume = vxge_pm_resume,
+#endif
+
+	.err_handler = &vxge_err_handler,
+
+};
+
+VXGE_MODULE_PARAM_INT(vlan_tag_strip,
+	VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE);
+
+#if defined(CONFIG_XEN)
+VXGE_MODULE_PARAM_INT(addr_learn_en, VXGE_HW_RTS_MAC_ENABLE);
+#else
+VXGE_MODULE_PARAM_INT(addr_learn_en, VXGE_HW_RTS_MAC_DISABLE);
+#endif
+
+VXGE_MODULE_PARAM_INT(ring_indicate_max_pkts,
+	VXGE_HW_DEF_RING_INDICATE_MAX_PKTS);
+VXGE_MODULE_PARAM_INT(fifo_indicate_max_pkts, VXGE_FIFO_INDICATE_MAX_PKTS);
+VXGE_MODULE_PARAM_INT(ring_blocks, VXGE_HW_DEF_RING_BLOCKS);
+VXGE_MODULE_PARAM_INT(fifo_length, VXGE_DEF_FIFO_LENGTH);
+VXGE_MODULE_PARAM_INT(max_config_port, VXGE_MAX_CONFIG_PORT);
+
+#if defined(HAVE_NETDEV_POLL)
+
+VXGE_MODULE_PARAM_INT(napi, VXGE_ENABLE_NAPI);
+
+#endif
+
+int netq = VXGE_NETQ_DISABLE;
+VXGE_MODULE_PARAM_INT(lro, VXGE_HW_LRO_DONT_AGGR_FWD_PKTS);
+VXGE_MODULE_PARAM_INT(rx_steering_type, RTH_STEERING);
+
+VXGE_MODULE_PARAM_INT(tx_steering_type, TX_MULTIQ_STEERING);
+
+VXGE_MODULE_PARAM_INT(lro_max_bytes, VXGE_LRO_MAX_BYTES);
+
+VXGE_MODULE_PARAM_INT(max_config_vpath, VXGE_USE_DEFAULT);
+VXGE_MODULE_PARAM_INT(max_mac_vpath, VXGE_MAX_MAC_ADDR_COUNT);
+VXGE_MODULE_PARAM_INT(max_config_dev, VXGE_MAX_CONFIG_DEV);
+
+VXGE_MODULE_PARAM_INT(intr_type, MSI_X);
+
+VXGE_MODULE_PARAM_INT(exec_mode, VXGE_EXEC_MODE_DISABLE);
+
+VXGE_MODULE_PARAM_INT(tx_pause_enable, VXGE_PAUSE_FRM_ENABLE);
+VXGE_MODULE_PARAM_INT(rx_pause_enable, VXGE_PAUSE_FRM_ENABLE);
+
+static unsigned int bw_percentage[VXGE_HW_MAX_VIRTUAL_PATHS] =
+	{[0 ...(VXGE_HW_MAX_VIRTUAL_PATHS - 1)] = 0xFF};
+
+module_param_array(bw_percentage, uint, NULL, 0);
+
+int config_dev_cnt = 0, total_dev_cnt = 0;
+int g_no_cpus;
+char g_serial_num[VXGE_HW_VPD_LENGTH + 1];
+char g_product_name[VXGE_HW_VPD_LENGTH + 1];
+unsigned int vpath_per_dev;
+
+#define VXGE_LL_MAX_FRAME_SIZE(dev) ((dev)->mtu + VXGE_HW_MAC_HEADER_MAX_SIZE)
+
+struct vxge_dma_async_data *async_data;
+
+static inline int is_vxge_card_up(struct vxgedev *vdev)
+{
+	return test_bit(__VXGE_STATE_CARD_UP,
+			(unsigned long *) &vdev->state);
+}
+
+static inline void VXGE_COMPLETE_VPATH_TX(struct vxge_fifo *fifo)
+{
+	unsigned long flags = 0;
+	unsigned int got_tx;
+	struct sk_buff *skb_ptr = NULL;
+	struct sk_buff **temp, *head, *skb;
+
+	if (spin_trylock_irqsave(&fifo->tx_lock, flags)) {
+		vxge_hw_vpath_poll_tx(fifo->handle, &got_tx,
+				(void **)&skb_ptr);
+		spin_unlock_irqrestore(&fifo->tx_lock, flags);
+	}
+	/* free SKBs */
+	head = skb_ptr;
+	while (head) {
+		skb = head;
+		temp = (struct sk_buff **)&skb->cb;
+		head = *temp;
+		*temp = NULL;
+		dev_kfree_skb_irq(skb);
+	}
+}
+
+static inline void VXGE_COMPLETE_ALL_TX(struct vxgedev *vdev)
+{
+	int i;
+
+	/* Complete all transmits */
+	for (i = 0; i < vdev->no_of_vpath; i++)
+		VXGE_COMPLETE_VPATH_TX(&vdev->vpaths[i].fifo);
+}
+
+static inline void VXGE_COMPLETE_VPATH_RX(struct vxge_ring *ring)
+{
+	unsigned int got_rx;
+
+	vxge_hw_vpath_poll_rx(ring->handle, &got_rx);
+}
+
+static inline void VXGE_COMPLETE_ALL_RX(struct vxgedev *vdev)
+{
+	int i;
+
+	/* Complete all receives*/
+	for (i = 0; i < vdev->no_of_vpath; i++)
+		VXGE_COMPLETE_VPATH_RX(&vdev->vpaths[i].ring);
+}
+
+/*
+ * MultiQ manipulation helper functions
+ */
+void vxge_stop_all_tx_queue(struct vxgedev *vdev)
+{
+	int i;
+	struct net_device *dev = (struct net_device *) vdev->ndev;
+
+	if (vdev->config.tx_steering_type != TX_MULTIQ_STEERING) {
+		for (i = 0; i < vdev->no_of_vpath; i++)
+			vdev->vpaths[i].fifo.queue_state = VPATH_QUEUE_STOP;
+	}
+	netif_tx_stop_all_queues(dev);
+
+}
+
+void vxge_stop_tx_queue(struct vxge_fifo *fifo)
+{
+	struct net_device *dev = fifo->ndev;
+
+	struct netdev_queue *txq = NULL;
+	if (fifo->tx_steering_type == TX_MULTIQ_STEERING)
+		txq = netdev_get_tx_queue(dev, fifo->driver_id);
+	else {
+		txq = netdev_get_tx_queue(dev, 0);
+		fifo->queue_state = VPATH_QUEUE_STOP;
+	}
+
+	netif_tx_stop_queue(txq);
+
+}
+
+void vxge_start_all_tx_queue(struct vxgedev *vdev)
+{
+	int i;
+	struct net_device *dev = (struct net_device *) vdev->ndev;
+
+	if (vdev->config.tx_steering_type != TX_MULTIQ_STEERING) {
+		for (i = 0; i < vdev->no_of_vpath; i++)
+			vdev->vpaths[i].fifo.queue_state = VPATH_QUEUE_START;
+	}
+	netif_tx_start_all_queues(dev);
+
+}
+
+void vxge_wake_all_tx_queue(struct vxgedev *vdev)
+{
+	int i;
+	struct net_device *dev = (struct net_device *) vdev->ndev;
+
+	if (vdev->config.tx_steering_type != TX_MULTIQ_STEERING) {
+		for (i = 0; i < vdev->no_of_vpath; i++)
+			vdev->vpaths[i].fifo.queue_state = VPATH_QUEUE_START;
+	}
+	netif_tx_wake_all_queues(dev);
+
+}
+
+void vxge_wake_tx_queue(struct vxge_fifo *fifo, struct sk_buff *skb)
+{
+	struct net_device *dev = fifo->ndev;
+
+	int vpath_no = fifo->driver_id;
+	struct netdev_queue *txq = NULL;
+	if (fifo->tx_steering_type == TX_MULTIQ_STEERING) {
+		txq = netdev_get_tx_queue(dev, vpath_no);
+		if (netif_tx_queue_stopped(txq))
+			netif_tx_wake_queue(txq);
+	} else {
+		txq = netdev_get_tx_queue(dev, 0);
+		if (fifo->queue_state == VPATH_QUEUE_STOP)
+			if (netif_tx_queue_stopped(txq)) {
+				fifo->queue_state = VPATH_QUEUE_START;
+				netif_tx_wake_queue(txq);
+			}
+	}
+
+}
+
+/*
+ * vxge_callback_link_up
+ *
+ * This function called during interrupt context to notify link up state
+ * change.
+ */
+void
+vxge_callback_link_up(struct __hw_device *devh, void *userdata)
+{
+	struct net_device *dev = (struct net_device *)userdata;
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+		vdev->ndev->name, __func__, __LINE__);
+	printk(KERN_NOTICE "%s: Link Up\n", vdev->ndev->name);
+	vdev->stats.link_up++;
+
+	netif_carrier_on(vdev->ndev);
+	vxge_wake_all_tx_queue(vdev);
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\n", vdev->ndev->name,
+		__func__, __LINE__);
+}
+
+/*
+ * vxge_callback_link_down
+ *
+ * This function called during interrupt context to notify link down state
+ * change.
+ */
+void
+vxge_callback_link_down(struct __hw_device *devh, void *userdata)
+{
+	struct net_device *dev = (struct net_device *)userdata;
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d\n", vdev->ndev->name, __func__,
+		__LINE__);
+	printk(KERN_NOTICE "%s: Link Down\n", vdev->ndev->name);
+
+	vdev->stats.link_down++;
+	netif_carrier_off(vdev->ndev);
+	vxge_stop_all_tx_queue(vdev);
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\n", vdev->ndev->name,
+		__func__, __LINE__);
+}
+
+/*
+ * vxge_rx_alloc
+ *
+ * Allocate SKB.
+ */
+struct sk_buff*
+vxge_rx_alloc(void *dtrh, struct vxge_ring *ring,
+	const int skb_size)
+{
+	struct net_device    *dev;
+	struct sk_buff       *skb;
+	struct vxge_rx_priv *rx_priv;
+
+	dev = ring->ndev;
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+		ring->ndev->name, __func__, __LINE__);
+
+	rx_priv = vxge_hw_ring_rxd_private_get(dtrh);
+
+	/* try to allocate skb first. this one may fail */
+	skb = netdev_alloc_skb(dev, skb_size +
+	VXGE_HW_HEADER_ETHERNET_II_802_3_ALIGN);
+	if (skb == NULL) {
+		vxge_debug_mem(VXGE_ERR,
+			"%s: out of memory to allocate SKB",
+			dev->name);
+		ring->stats.skb_alloc_fail++;
+		return NULL;
+	}
+
+	vxge_debug_mem(VXGE_TRACE,
+		"%s: %s:%d  Skb : 0x%llx\n", ring->ndev->name,
+		__func__, __LINE__, (u64)skb);
+
+	skb_reserve(skb, VXGE_HW_HEADER_ETHERNET_II_802_3_ALIGN);
+
+	rx_priv->skb = skb;
+	rx_priv->data_size = skb_size;
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d   Exiting...\n", ring->ndev->name,
+		__func__, __LINE__);
+
+	return skb;
+}
+
+/*
+ * vxge_rx_free
+ */
+void
+vxge_rx_free(void *dtrh)
+{
+	struct vxge_rx_priv *rx_priv;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+	rx_priv = vxge_hw_ring_rxd_private_get(dtrh);
+	dev_kfree_skb(rx_priv->skb);
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+}
+
+/*
+ * vxge_rx_map
+ */
+int
+vxge_rx_map(void *dtrh, struct vxge_ring *ring)
+{
+	struct vxge_rx_priv *rx_priv;
+	dma_addr_t dma_addr;
+
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+		ring->ndev->name, __func__, __LINE__);
+	rx_priv = vxge_hw_ring_rxd_private_get(dtrh);
+
+	dma_addr =
+
+		pci_map_single(ring->pdev, rx_priv->skb->data,
+				rx_priv->data_size, PCI_DMA_FROMDEVICE);
+
+	if (dma_addr == 0) {
+		ring->stats.pci_map_fail++;
+		return -EIO;
+	}
+	vxge_debug_mem(VXGE_TRACE,
+		"%s: %s:%d  1 buffer mode dma_addr = 0x%llx\n",
+		ring->ndev->name, __func__, __LINE__, (u64)dma_addr);
+	vxge_hw_ring_rxd_1b_set(dtrh, dma_addr, rx_priv->data_size);
+
+	rx_priv->data_dma = dma_addr;
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\n",
+		ring->ndev->name, __func__, __LINE__);
+
+	return 0;
+}
+
+/*
+ * vxge_rx_unmap
+ */
+
+void
+vxge_rx_unmap(struct vxge_ring *ring, dma_addr_t data_dma,
+		dma_addr_t data_size)
+{
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+		ring->ndev->name, __func__, __LINE__);
+
+	pci_unmap_single(ring->pdev, data_dma, data_size, PCI_DMA_FROMDEVICE);
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\n",
+		ring->ndev->name, __func__, __LINE__);
+}
+
+#define RX_FOR_DEVICE	1
+#define RX_FOR_CPU	2
+
+/*
+ * vxge_rx_sync
+ */
+void
+vxge_rx_sync(dma_addr_t data_dma, dma_addr_t data_size,
+	struct vxge_ring *ring, int flags)
+{
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+		ring->ndev->name, __func__, __LINE__);
+
+	if (flags == RX_FOR_CPU) {
+		pci_dma_sync_single_for_cpu(ring->pdev,
+		    data_dma, data_size, PCI_DMA_FROMDEVICE);
+	} else if (flags == RX_FOR_DEVICE) {
+		pci_dma_sync_single_for_device(ring->pdev,
+			data_dma, data_size, PCI_DMA_FROMDEVICE);
+	}
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\n",
+		ring->ndev->name, __func__, __LINE__);
+}
+
+/*
+ * vxge_rx_initial_replenish
+ * @dtrh: DTR handle to operate
+ * @userdata: channel's userdata, points to vdev usually
+ *
+ * Allocation of RxD as an initial replenish procedure.
+ */
+enum vxge_hw_status
+vxge_rx_initial_replenish(void *dtrh, u32 index,
+	void *userdata, enum vxge_hw_reopen reopen)
+{
+	struct vxge_ring *ring = (struct vxge_ring *)userdata;
+
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+		ring->ndev->name, __func__, __LINE__);
+	if (vxge_rx_alloc(dtrh, ring,
+			  VXGE_LL_MAX_FRAME_SIZE(ring->ndev)) == NULL)
+		return VXGE_HW_FAIL;
+
+	if (vxge_rx_map(dtrh, ring)) {
+		vxge_rx_free(dtrh);
+		return VXGE_HW_FAIL;
+	}
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\n",
+		ring->ndev->name, __func__, __LINE__);
+
+	return VXGE_HW_OK;
+}
+
+static inline void
+vxge_rx_complete(struct vxge_ring *ring, struct sk_buff *skb, u16 vlan,
+	int pkt_length, struct vxge_hw_ring_rxd_info *ext_info)
+{
+
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+			ring->ndev->name, __func__, __LINE__);
+
+	skb->protocol = eth_type_trans(skb, ring->ndev);
+
+	ring->stats.rx_frms++;
+	ring->stats.rx_bytes += pkt_length;
+
+	if (skb->pkt_type == PACKET_MULTICAST)
+		ring->stats.rx_mcast++;
+
+	vxge_debug_rx(VXGE_TRACE,
+		"%s: %s:%d  skb protocol = %d\n",
+		ring->ndev->name, __func__, __LINE__,
+		skb->protocol);
+
+	if (ring->lro_enable) {
+
+		if (ring->vlgrp && ext_info->vlan &&
+			(ring->vlan_tag_strip ==
+				VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE))
+			lro_vlan_hwaccel_receive_skb(&ring->lro_mgr, skb,
+				ring->vlgrp, ext_info->vlan, ext_info);
+		else
+			lro_receive_skb(&ring->lro_mgr, skb,
+				(void *)ext_info);
+
+	} else {
+
+		if (ring->vlgrp && vlan &&
+			(ring->vlan_tag_strip ==
+				VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE)) {
+			if (ring->napi_enable)
+				vlan_hwaccel_receive_skb(skb, ring->vlgrp,
+							vlan);
+			else
+				vlan_hwaccel_rx(skb, ring->vlgrp, vlan);
+		} else {
+
+			{
+				/* It is an ARP packet, send it to
+				 * the Linux stack */
+				memset(skb->cb, 0, sizeof(skb->cb));
+
+				if (ring->napi_enable)
+					netif_receive_skb(skb);
+				else
+					netif_rx(skb);
+			}
+		}
+	}
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\n",
+		ring->ndev->name, __func__, __LINE__);
+}
+
+static inline void vxge_re_pre_post(void *dtr,
+	struct vxge_ring *ring, struct vxge_rx_priv *rx_priv)
+{
+	vxge_rx_sync(rx_priv->data_dma, rx_priv->data_size,
+		ring, RX_FOR_DEVICE);
+	vxge_hw_ring_rxd_1b_set(dtr, rx_priv->data_dma, rx_priv->data_size);
+	vxge_hw_ring_rxd_pre_post(ring->handle, dtr);
+}
+
+static inline void vxge_post(int *dtr_cnt, void **first_dtr,
+	void *post_dtr, struct __hw_ring *ringh)
+{
+	int dtr_count = *dtr_cnt;
+	if ((*dtr_cnt % XGE_HW_RXSYNC_FREQ_CNT) == 0) {
+		if (*first_dtr) {
+			vxge_hw_ring_rxd_post_post_wmb(ringh, *first_dtr);
+			    *first_dtr = NULL;
+		}
+		*first_dtr = post_dtr;
+	} else
+		vxge_hw_ring_rxd_post_post(ringh, post_dtr);
+	dtr_count++;
+	*dtr_cnt = dtr_count;
+}
+
+#ifdef VXGE_RX_ERR_DBG
+void vxge_dump_packet(struct sk_buff *skb, int pkt_length)
+{
+	int i = 0, j;
+	u8 *ptr = skb->data;
+
+	printk(KERN_CRIT "\n Packet contents : Length = %d\n", pkt_length);
+	for (j = 0; j < pkt_length; j += 2, i += 2) {
+		printk(KERN_CRIT "%02x%02x  ", *(ptr + j), *(ptr + j + 1));
+		if (!((i + 2) % 16))
+			printk("\n");
+	}
+
+}
+#endif
+
+/*
+ * vxge_rx_1b_compl
+ * @channel:
+ * @userdata:
+ *
+ * If the interrupt is because of a received frame or if the receive ring
+ * contains fresh as yet un-processed frames, this function is called.
+ */
+enum vxge_hw_status
+vxge_rx_1b_compl(struct __hw_ring *ringh, void *dtr,
+	u8 t_code, void *userdata)
+{
+	struct vxge_ring *ring = (struct vxge_ring *)userdata;
+	struct  net_device *dev = ring->ndev;
+	unsigned int dma_sizes;
+	void *first_dtr = NULL;
+	int dtr_cnt = 0;
+	int data_size;
+	dma_addr_t data_dma;
+	int pkt_length;
+	struct sk_buff *skb;
+	struct vxge_rx_priv *rx_priv;
+	struct vxge_hw_ring_rxd_info ext_info;
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+		ring->ndev->name, __func__, __LINE__);
+	ring->pkts_processed = 0;
+
+	vxge_hw_ring_replenish(ringh, VXGE_HW_OPEN_NORMAL, 0);
+
+	do {
+		rx_priv = vxge_hw_ring_rxd_private_get(dtr);
+		skb = rx_priv->skb;
+		data_size = rx_priv->data_size;
+		data_dma = rx_priv->data_dma;
+
+		vxge_debug_rx(VXGE_TRACE,
+			"%s: %s:%d  skb = 0x%llx\n",
+			ring->ndev->name, __func__,
+			__LINE__, (u64)skb);
+
+		vxge_hw_ring_rxd_1b_get(ringh, dtr, &dma_sizes);
+		pkt_length = dma_sizes;
+
+		vxge_debug_rx(VXGE_TRACE,
+			"%s: %s:%d  Packet Length = %d\n",
+			ring->ndev->name, __func__,
+			__LINE__, pkt_length);
+
+		vxge_hw_ring_rxd_1b_info_get(ringh, dtr, &ext_info);
+
+		/* check skb validity */
+		vxge_assert(skb);
+
+		prefetch((char *)skb + L1_CACHE_BYTES);
+		if (unlikely(t_code)) {
+
+#ifdef VXGE_RX_ERR_DBG
+			if (t_code == VXGE_HW_RING_T_CODE_L2_FRM_ERR)
+				vxge_dump_packet(skb, pkt_length);
+#endif
+
+			if (vxge_hw_ring_handle_tcode(ringh, dtr, t_code) !=
+				VXGE_HW_OK) {
+
+				ring->stats.rx_errors++;
+				vxge_debug_rx(VXGE_TRACE,
+					"%s: %s :%d Rx T_code is %d \n",
+					ring->ndev->name, __func__,
+					__LINE__, t_code);
+
+				/* If the t_code is not supported and if the
+				 * t_code is other than 0x5 (unparseable packet
+				 * such as unknown UPV6 header), Drop it !!!
+				 */
+				vxge_re_pre_post(dtr, ring, rx_priv);
+
+				vxge_post(&dtr_cnt, &first_dtr, dtr,
+					ringh);
+				ring->stats.rx_dropped++;
+				continue;
+			}
+		}
+
+		if (pkt_length > VXGE_LL_RX_COPY_THRESHOLD) {
+
+			if (vxge_rx_alloc(dtr, ring, data_size) != NULL) {
+
+				if (!vxge_rx_map(dtr, ring)) {
+					skb_put(skb, pkt_length);
+					vxge_rx_unmap(ring,
+						data_dma, data_size);
+					vxge_hw_ring_rxd_pre_post(ringh,
+						dtr);
+					vxge_post(&dtr_cnt, &first_dtr, dtr,
+						ringh);
+				} else {
+					vxge_rx_free(dtr);
+					rx_priv->skb = skb;
+					rx_priv->data_size = data_size;
+					vxge_re_pre_post(dtr, ring, rx_priv);
+
+					vxge_post(&dtr_cnt, &first_dtr, dtr,
+						ringh);
+					ring->stats.rx_dropped++;
+					break;
+				}
+			} else {
+				vxge_re_pre_post(dtr, ring, rx_priv);
+
+				vxge_post(&dtr_cnt, &first_dtr, dtr,
+					ringh);
+				ring->stats.rx_dropped++;
+				break;
+			}
+		} else {
+			struct sk_buff *skb_up;
+
+			skb_up = netdev_alloc_skb(dev, pkt_length +
+				VXGE_HW_HEADER_ETHERNET_II_802_3_ALIGN);
+			if (skb_up != NULL) {
+				skb_reserve(skb_up,
+				    VXGE_HW_HEADER_ETHERNET_II_802_3_ALIGN);
+
+				vxge_rx_sync(data_dma, data_size,
+					ring, RX_FOR_CPU);
+
+				vxge_debug_mem(VXGE_TRACE,
+					"%s: %s:%d  skb_up = 0x%llx\n",
+					ring->ndev->name, __func__,
+					__LINE__, (u64)skb);
+				memcpy(skb_up->data, skb->data, pkt_length);
+
+				vxge_re_pre_post(dtr, ring, rx_priv);
+
+				vxge_post(&dtr_cnt, &first_dtr, dtr,
+					ringh);
+				/* will netif_rx small SKB instead */
+				skb = skb_up;
+				skb_put(skb, pkt_length);
+			} else {
+				vxge_re_pre_post(dtr, ring, rx_priv);
+
+				vxge_post(&dtr_cnt, &first_dtr, dtr,
+					ringh);
+				vxge_debug_rx(VXGE_ERR,
+					"%s: vxge_rx_1b_compl: out of "
+					"memory",
+					dev->name);
+				ring->stats.skb_alloc_fail++;
+				break;
+			}
+		}
+
+		if ((ext_info.proto & VXGE_HW_FRAME_PROTO_TCP_OR_UDP) &&
+		    !(ext_info.proto & VXGE_HW_FRAME_PROTO_IP_FRAG) &&
+		    ring->rx_csum && /* Offload Rx side CSUM */
+		    ext_info.l3_cksum == VXGE_HW_L3_CKSUM_OK &&
+		    ext_info.l4_cksum == VXGE_HW_L4_CKSUM_OK) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		} else
+			skb->ip_summed = CHECKSUM_NONE;
+
+		vxge_rx_complete(ring, skb, ext_info.vlan,
+			pkt_length, &ext_info);
+
+		if (ring->napi_enable) {
+
+			/* NEW NAPI */
+			ring->budget--;
+			ring->pkts_processed++;
+			if (!ring->budget)
+				break;
+
+		}
+	} while (vxge_hw_ring_rxd_next_completed(ringh, &dtr,
+		&t_code) == VXGE_HW_OK);
+
+	if (first_dtr)
+		vxge_hw_ring_rxd_post_post_wmb(ringh, first_dtr);
+
+	dev->last_rx = jiffies;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+				"%s:%d  Exiting...\n",
+				__func__, __LINE__);
+	if (ring->lro_enable)
+
+		lro_flush_all(&ring->lro_mgr);
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * vxge_xmit_compl
+ * @channel:
+ * @userdata:
+ *
+ * If an interrupt was raised to indicate DMA complete of the Tx packet,
+ * this function is called. It identifies the last TxD whose buffer was
+ * freed and frees all skbs whose data have already DMA'ed into the NICs
+ * internal memory.
+ */
+enum vxge_hw_status
+vxge_xmit_compl(struct __hw_fifo *fifo_hw, void *dtr,
+	void *dtr_priv, enum vxge_hw_fifo_tcode t_code, void *userdata,
+	void **skb_ptr)
+{
+	struct vxge_fifo *fifo = (struct vxge_fifo *)userdata;
+	struct sk_buff *skb, *head = NULL;
+	struct sk_buff **temp;
+	int pkt_cnt = 0;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d Entered....\n", __func__,
+		__LINE__);
+
+	do {
+		int frg_cnt;
+		skb_frag_t *frag;
+		int i = 0, j;
+		struct vxge_tx_priv *txd_priv =
+			vxge_hw_fifo_txdl_private_get(dtr);
+
+		skb = txd_priv->skb;
+		frg_cnt = skb_shinfo(skb)->nr_frags;
+		frag = &skb_shinfo(skb)->frags[0];
+
+		vxge_debug_tx(VXGE_TRACE,
+				"%s: %s:%d fifo_hw = 0x%llx dtr = 0x%llx \
+				dtr_priv = 0x%llx tcode = 0x%x\n",
+				fifo->ndev->name, __func__, __LINE__,
+				(u64)fifo_hw, (u64)dtr, (u64)dtr_priv, t_code);
+		/* check skb validity */
+		vxge_assert(skb);
+		vxge_debug_tx(VXGE_TRACE,
+			"%s: %s:%d skb = 0x%llx itxd_priv = 0x%llx \
+			frg_cnt = %d\n",
+			fifo->ndev->name, __func__, __LINE__,
+			(u64)skb, (u64)txd_priv, frg_cnt);
+		if (unlikely(t_code)) {
+			fifo->stats.tx_errors++;
+			vxge_debug_tx(VXGE_ERR,
+				"%s: tx: dtr 0x%llx completed due to "
+				"error t_code %01x",
+				fifo->ndev->name, (unsigned long long)
+				(ulong_t)dtr, t_code);
+
+			vxge_hw_fifo_handle_tcode(fifo_hw, dtr, t_code);
+		}
+
+		/*  for unfragmented skb */
+		pci_unmap_single(fifo->pdev, txd_priv->dma_buffers[i++],
+				skb_headlen(skb), PCI_DMA_TODEVICE);
+
+		for (j = 0; j < frg_cnt; j++) {
+			pci_unmap_page(fifo->pdev,
+					txd_priv->dma_buffers[i++],
+					frag->size, PCI_DMA_TODEVICE);
+			frag += 1;
+		}
+
+		vxge_hw_fifo_txdl_free(fifo_hw, dtr);
+
+		/* Updating the statistics block */
+		fifo->stats.tx_frms++;
+		fifo->stats.tx_bytes += skb->len;
+
+		temp = (struct sk_buff **)&skb->cb;
+		*temp = head;
+		head = skb;
+
+		pkt_cnt++;
+		if (pkt_cnt > fifo->indicate_max_pkts)
+			break;
+
+	} while (vxge_hw_fifo_txdl_next_completed(fifo_hw,
+				&dtr, &dtr_priv, &t_code) == VXGE_HW_OK);
+
+	vxge_wake_tx_queue(fifo, skb);
+
+	if (skb_ptr)
+		*skb_ptr = (void *) head;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+				"%s: %s:%d  Exiting...\n",
+				fifo->ndev->name, __func__, __LINE__);
+	return VXGE_HW_OK;
+}
+
+/* select a vpath to trasmit the packet */
+u32 vxge_get_vpath_no(struct vxgedev *vdev, struct sk_buff *skb,
+	int *do_lock)
+{
+	u16 queue_len, counter = 0;
+	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *ip;
+		struct tcphdr *th;
+
+		ip = ip_hdr(skb);
+
+		if ((ip->frag_off & htons(IP_OFFSET|IP_MF)) == 0) {
+			th = (struct tcphdr *)(((unsigned char *)ip) +
+					ip->ihl*4);
+
+			queue_len = vdev->no_of_vpath;
+			counter = (ntohs(th->source) +
+				ntohs(th->dest)) &
+				vdev->vpath_selector[queue_len - 1];
+			if (counter >= queue_len)
+				counter = queue_len - 1;
+
+			if (ip->protocol == IPPROTO_UDP) {
+#ifdef NETIF_F_LLTX
+				*do_lock = 0;
+#endif
+			}
+		}
+	}
+	return counter;
+}
+
+#if defined(CONFIG_XEN)
+
+enum vxge_hw_status vxge_search_mac_addr_in_list(struct vxge_vpath *vpath,
+					u64 del_mac)
+{
+	struct vxge_list *entry, *next;
+	vxge_list_for_each_safe(entry, next, &vpath->mac_addr_list) {
+		if (((struct vxge_mac_addrs *)entry)->macaddr == del_mac)
+			return TRUE;
+	}
+	return FALSE;
+}
+
+int vxge_learn_mac(struct vxgedev *vdev, u8 *mac_header)
+{
+	struct macInfo mac_info;
+	u8 *mac_address = NULL;
+	u64 mac_addr = 0, vpath_vector = 0;
+	int vpath_idx = 0;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_vpath *vpath = NULL;
+	struct __hw_device *hldev;
+
+	hldev = (struct __hw_device *) pci_get_drvdata(vdev->pdev);
+
+	mac_address = (u8 *)&mac_addr;
+	memcpy(mac_address, mac_header, ETH_ALEN);
+
+	/* Is this mac address already in the list? */
+	for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath; vpath_idx++) {
+		vpath = &vdev->vpaths[vpath_idx];
+		if (vxge_search_mac_addr_in_list(vpath, mac_addr))
+			return vpath_idx;
+	}
+
+	memset(&mac_info, 0, sizeof(struct macInfo));
+	memcpy(mac_info.macaddr, mac_header, ETH_ALEN);
+
+	/* Any vpath has room to add mac address to its da table? */
+	for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath; vpath_idx++) {
+		vpath = &vdev->vpaths[vpath_idx];
+		if (vpath->mac_addr_cnt < vpath->max_mac_addr_cnt) {
+			/* Add this mac address to this vpath */
+			mac_info.vpath_no = vpath_idx;
+			mac_info.state = VXGE_LL_MAC_ADDR_IN_DA_TABLE;
+			status = vxge_add_mac_addr(vdev, &mac_info);
+			if (status != VXGE_HW_OK)
+				return -EPERM;
+			return vpath_idx;
+		}
+	}
+
+	mac_info.state = VXGE_LL_MAC_ADDR_IN_LIST;
+	vpath_idx = 0;
+	mac_info.vpath_no = vpath_idx;
+	/* Is the first vpath already selected as catch-basin ? */
+	vpath = &vdev->vpaths[vpath_idx];
+	if (vpath->mac_addr_cnt > vpath->max_mac_addr_cnt) {
+		/* Add this mac address to this vpath */
+		if (FALSE == vxge_mac_list_add(vpath, &mac_info))
+			return -EPERM;
+		return vpath_idx;
+	}
+
+	/* Select first vpath as catch-basin */
+	vpath_vector = vxge_mBIT(vpath->device_id);
+	status = vxge_hw_mgmt_reg_write(vpath->vdev->devh,
+				vxge_hw_mgmt_reg_type_mrpcim,
+				0,
+				(ulong_t)vxge_offsetof(
+					struct vxge_hw_mrpcim_reg,
+					rts_mgr_cbasin_cfg),
+				vpath_vector);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_tx(VXGE_ERR,
+			"%s: Unable to set the vpath-%d in catch-basin mode",
+			VXGE_DRIVER_NAME, vpath->device_id);
+		return -EPERM;
+	}
+
+	if (FALSE == vxge_mac_list_add(vpath, &mac_info))
+		return -EPERM;
+
+	return vpath_idx;
+}
+#endif
+
+/*
+ * vxge_xmit
+ * @skb : the socket buffer containing the Tx data.
+ * @dev : device pointer.
+ *
+ * This function is the Tx entry point of the driver. Neterion NIC supports
+ * certain protocol assist features on Tx side, namely  CSO, S/G, LSO.
+ * NOTE: when device cant queue the pkt, just the trans_start variable will
+ * not be upadted.
+*/
+static int
+vxge_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct vxge_fifo *fifo = NULL;
+	void *dtr_priv;
+	void *dtr = NULL;
+	struct vxgedev *vdev = NULL;
+	enum vxge_hw_status status;
+	int frg_cnt, first_frg_len;
+	skb_frag_t *frag;
+	int i = 0, j = 0, avail;
+	u64 dma_pointer;
+	struct vxge_tx_priv *txdl_priv = NULL;
+	struct __hw_fifo *fifo_hw;
+
+	u32 max_mss = 0x0;
+
+	int offload_type;
+	unsigned long flags = 0;
+	int vpath_no = 0;
+	int do_spin_tx_lock = 1;
+
+	vxge_assert(dev);
+	vxge_assert(netdev_priv(dev));
+
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+			dev->name, __func__, __LINE__);
+
+	/* A buffer with no data will be dropped */
+	if (unlikely(skb->len <= 0)) {
+		vxge_debug_tx(VXGE_ERR,
+			"%s: Buffer has no data..\n", dev->name);
+		goto _exit2;
+	}
+
+	vdev = (struct vxgedev *)netdev_priv(dev);
+
+	if (unlikely(!is_vxge_card_up(vdev))) {
+		vxge_debug_tx(VXGE_ERR,
+			"%s: vdev not initialized\n", dev->name);
+		goto _exit2;
+	}
+
+#if defined(CONFIG_XEN)
+	if (vdev->config.addr_learn_en) {
+		vpath_no = vxge_learn_mac(vdev, skb->data +
+						ETH_ALEN);
+		if (vpath_no == -EPERM) {
+			vxge_debug_tx(VXGE_ERR,
+				"%s: Failed to store the mac address..\n",
+				dev->name);
+			goto _exit2;
+		}
+	}
+#endif
+
+	if (vdev->config.tx_steering_type == TX_MULTIQ_STEERING)
+		vpath_no = skb_get_queue_mapping(skb);
+	else if (vdev->config.tx_steering_type == TX_PORT_STEERING)
+		vpath_no = vxge_get_vpath_no(vdev, skb, &do_spin_tx_lock);
+
+	vxge_debug_tx(VXGE_TRACE,
+		"%s: vpath_no= %d\n", dev->name, vpath_no);
+
+	if (vpath_no >= vdev->no_of_vpath)
+		vpath_no = 0;
+
+	fifo = &vdev->vpaths[vpath_no].fifo;
+	fifo_hw = fifo->handle;
+
+	if (do_spin_tx_lock)
+		spin_lock_irqsave(&fifo->tx_lock, flags);
+	else {
+		if (unlikely(!spin_trylock_irqsave(&fifo->tx_lock, flags)))
+			return NETDEV_TX_LOCKED;
+	}
+
+	if (vdev->config.tx_steering_type == TX_MULTIQ_STEERING) {
+		if (netif_subqueue_stopped(dev, skb)) {
+			spin_unlock_irqrestore(&fifo->tx_lock, flags);
+			return NETDEV_TX_BUSY;
+		}
+	} else if (unlikely(fifo->queue_state == VPATH_QUEUE_STOP)) {
+		if (netif_queue_stopped(dev)) {
+			spin_unlock_irqrestore(&fifo->tx_lock, flags);
+			return NETDEV_TX_BUSY;
+		}
+	}
+	avail = vxge_hw_fifo_free_txdl_count_get(fifo_hw);
+	if (avail == 0) {
+		vxge_debug_tx(VXGE_ERR,
+				"%s: No free TXDs available\n", dev->name);
+		fifo->stats.txd_not_free++;
+		vxge_stop_tx_queue(fifo);
+		goto _exit2;
+	}
+
+	status = vxge_hw_fifo_txdl_reserve(fifo_hw, &dtr, &dtr_priv);
+	if (unlikely(status != VXGE_HW_OK)) {
+		vxge_debug_tx(VXGE_ERR,
+		   "%s: Out of descriptors .", dev->name);
+		fifo->stats.txd_out_of_desc++;
+		vxge_stop_tx_queue(fifo);
+		goto _exit2;
+	}
+
+	vxge_debug_tx(VXGE_TRACE,
+		"%s: %s:%d fifo_hw = 0x%llx dtr = 0x%llx dtr_priv = 0x%llx\n",
+		dev->name, __func__, __LINE__,
+		(u64)fifo_hw, (u64)dtr, (u64)dtr_priv);
+
+	if (vdev->vlgrp && vlan_tx_tag_present(skb)) {
+		u16 vlan_tag = vlan_tx_tag_get(skb);
+		vxge_hw_fifo_txdl_vlan_set(dtr, vlan_tag);
+	}
+
+	first_frg_len = skb_headlen(skb);
+
+	dma_pointer =
+
+		pci_map_single(fifo->pdev,
+			skb->data, first_frg_len, PCI_DMA_TODEVICE);
+
+	if (unlikely(vxge_do_pci_dma_mapping_error(fifo->pdev, dma_pointer))) {
+		vxge_hw_fifo_txdl_free(fifo_hw, dtr);
+		vxge_stop_tx_queue(fifo);
+		fifo->stats.pci_map_fail++;
+		goto _exit2;
+	}
+
+	txdl_priv = vxge_hw_fifo_txdl_private_get(dtr);
+	txdl_priv->skb = skb;
+	txdl_priv->dma_buffers[j] = dma_pointer;
+
+	frg_cnt = skb_shinfo(skb)->nr_frags;
+	vxge_debug_tx(VXGE_TRACE,
+			"%s: %s:%d skb = 0x%llx txdl_priv = 0x%llx \
+			frag_cnt = %d dma_pointer = 0x%llx\n", dev->name,
+			__func__, __LINE__, (u64)skb, (u64)txdl_priv,
+			frg_cnt, dma_pointer);
+
+	vxge_hw_fifo_txdl_buffer_set(fifo_hw, dtr, j++, dma_pointer,
+		first_frg_len);
+
+	frag = &skb_shinfo(skb)->frags[0];
+	for (i = 0; i < frg_cnt; i++) {
+		/* ignore 0 length fragment */
+		if (!frag->size)
+			continue;
+
+		dma_pointer =
+
+			(u64)pci_map_page(
+				fifo->pdev, frag->page,
+				frag->page_offset, frag->size,
+				PCI_DMA_TODEVICE);
+
+		if (unlikely(vxge_do_pci_dma_mapping_error(
+				fifo->pdev,
+				dma_pointer)))
+			goto _exit0;
+		vxge_debug_tx(VXGE_TRACE,
+				"%s: %s:%d frag = %d dma_pointer = 0x%llx\n",
+				dev->name, __func__, __LINE__, i,
+				dma_pointer);
+
+		txdl_priv->dma_buffers[j] = dma_pointer;
+		vxge_hw_fifo_txdl_buffer_set(fifo_hw, dtr,
+			j++, dma_pointer, frag->size);
+		frag += 1;
+	}
+
+	offload_type = vxge_offload_type(skb);
+
+	if (offload_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)) {
+
+		int mss = vxge_tcp_mss(skb);
+		if (mss) {
+			max_mss = dev->mtu + ETH_HLEN -
+				VXGE_HW_TCPIP_HEADER_MAX_SIZE;
+			if (mss > max_mss)
+				mss = max_mss;
+			vxge_debug_tx(VXGE_TRACE,
+					"%s: %s:%d mss = %d\n",
+					dev->name, __func__,
+					__LINE__, mss);
+			vxge_hw_fifo_txdl_mss_set(dtr, mss);
+		} else {
+			vxge_assert(skb->len <=
+				dev->mtu + VXGE_HW_MAC_HEADER_MAX_SIZE);
+			vxge_assert(0);
+			goto _exit1;
+		}
+	}
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		vxge_hw_fifo_txdl_cksum_set_bits(dtr,
+					VXGE_HW_FIFO_TXD_TX_CKO_IPV4_EN |
+					VXGE_HW_FIFO_TXD_TX_CKO_TCP_EN |
+					VXGE_HW_FIFO_TXD_TX_CKO_UDP_EN);
+
+	vxge_hw_fifo_txdl_post(fifo_hw, dtr);
+	dev->trans_start = jiffies;
+	spin_unlock_irqrestore(&fifo->tx_lock, flags);
+
+	VXGE_COMPLETE_VPATH_TX(fifo);
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\n",
+		dev->name, __func__, __LINE__);
+	return 0;
+
+_exit0:
+	vxge_debug_tx(VXGE_TRACE,
+		"%s: pci_map_page failed",
+		dev->name);
+
+_exit1:
+	j = 0;
+	frag = &skb_shinfo(skb)->frags[0];
+
+	pci_unmap_single(fifo->pdev, txdl_priv->dma_buffers[j++],
+			skb_headlen(skb), PCI_DMA_TODEVICE);
+
+	for (; j < i; j++) {
+		pci_unmap_page(fifo->pdev,
+			txdl_priv->dma_buffers[j],
+			frag->size,
+			PCI_DMA_TODEVICE);
+		frag += 1;
+	}
+
+	vxge_hw_fifo_txdl_free(fifo_hw, dtr);
+_exit2:
+	dev_kfree_skb(skb);
+	if (fifo) {
+		spin_unlock_irqrestore(&fifo->tx_lock, flags);
+		VXGE_COMPLETE_VPATH_TX(fifo);
+	}
+
+	return 0;
+}
+
+/*
+ * vxge_rx_term
+ *
+ * Function will be called by hw function to abort all outstanding receive
+ * descriptors.
+ */
+static void
+vxge_rx_term(void *dtrh,
+	enum vxge_hw_rxd_state state, void *userdata,
+	enum vxge_hw_reopen reopen)
+{
+	struct vxge_ring *ring = (struct vxge_ring *)userdata;
+	struct vxge_rx_priv *rx_priv =
+		vxge_hw_ring_rxd_private_get(dtrh);
+
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+			ring->ndev->name, __func__, __LINE__);
+	if (state != VXGE_HW_RXD_STATE_POSTED)
+		return;
+
+	vxge_rx_unmap(ring, rx_priv->data_dma, rx_priv->data_size);
+	vxge_rx_free(dtrh);
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\n",
+		ring->ndev->name, __func__, __LINE__);
+}
+
+/*
+ * vxge_tx_term
+ *
+ * Function will be called to abort all outstanding tx descriptors
+ */
+static void
+vxge_tx_term(void *dtrh, void *dtr_priv,
+	enum vxge_hw_txdl_state state, void *userdata,
+	enum vxge_hw_reopen reopen)
+{
+	struct vxge_fifo *fifo = (struct vxge_fifo *)userdata;
+	skb_frag_t *frag;
+	int i = 0, j, frg_cnt;
+	struct vxge_tx_priv *txd_priv = vxge_hw_fifo_txdl_private_get(dtrh);
+	struct sk_buff *skb = txd_priv->skb;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+
+	if (state != VXGE_HW_TXDL_STATE_POSTED)
+		return;
+
+	/* check skb validity */
+	vxge_assert(skb);
+	frg_cnt = skb_shinfo(skb)->nr_frags;
+	frag = &skb_shinfo(skb)->frags[0];
+
+	/*  for unfragmented skb */
+	pci_unmap_single(fifo->pdev, txd_priv->dma_buffers[i++],
+		skb_headlen(skb), PCI_DMA_TODEVICE);
+
+	for (j = 0; j < frg_cnt; j++) {
+		pci_unmap_page(fifo->pdev, txd_priv->dma_buffers[i++],
+			       frag->size, PCI_DMA_TODEVICE);
+		frag += 1;
+	}
+
+	dev_kfree_skb(skb);
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+}
+
+/*
+ * vxge_set_multicast
+ * @dev: pointer to the device structure
+ *
+ * Entry point for multicast address enable/disable
+ * This function is a driver entry point which gets called by the kernel
+ * whenever multicast addresses must be enabled/disabled. This also gets
+ * called to set/reset promiscuous mode. Depending on the deivce flag, we
+ * determine, if multicast address must be enabled or if promiscuous mode
+ * is to be disabled etc.
+ */
+static void vxge_set_multicast(struct net_device *dev)
+{
+	struct dev_mc_list *mclist;
+	struct vxgedev *vdev;
+	int i, mcast_cnt = 0;
+	struct __hw_device  *hldev;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct macInfo mac_info;
+	int vpath_idx = 0;
+	struct vxge_mac_addrs *mac_entry;
+	struct vxge_list *list_head;
+	struct vxge_list *entry, *next;
+	u8 *mac_address = NULL;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+	vxge_assert(dev);
+	vxge_assert(netdev_priv(dev));
+
+	vdev = (struct vxgedev *)netdev_priv(dev);
+	hldev = (struct __hw_device  *)vdev->devh;
+
+	if (unlikely(!is_vxge_card_up(vdev)))
+		return;
+
+	if ((dev->flags & IFF_ALLMULTI) && (!vdev->all_multi_flg)) {
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+			vxge_assert(vdev->vpaths[i].is_open);
+			status = vxge_hw_vpath_mcast_enable(
+						vdev->vpaths[i].handle);
+			vdev->all_multi_flg = 1;
+		}
+	} else if ((dev->flags & IFF_ALLMULTI) && (vdev->all_multi_flg)) {
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+			vxge_assert(vdev->vpaths[i].is_open);
+			status = vxge_hw_vpath_mcast_disable(
+						vdev->vpaths[i].handle);
+			vdev->all_multi_flg = 1;
+		}
+	}
+
+	if (status != VXGE_HW_OK)
+		vxge_debug_init(VXGE_ERR,
+			"failed to %s multicast, status %d",
+			dev->flags & IFF_ALLMULTI ?
+			"enable" : "disable", status);
+
+	if (!vdev->config.addr_learn_en) {
+		if (dev->flags & IFF_PROMISC) {
+			for (i = 0; i < vdev->no_of_vpath; i++) {
+				vxge_assert(vdev->vpaths[i].is_open);
+				status = vxge_hw_vpath_promisc_enable(
+						vdev->vpaths[i].handle);
+			}
+		} else {
+			for (i = 0; i < vdev->no_of_vpath; i++) {
+				vxge_assert(vdev->vpaths[i].is_open);
+				status = vxge_hw_vpath_promisc_disable(
+						vdev->vpaths[i].handle);
+			}
+		}
+	}
+
+	memset(&mac_info, 0, sizeof(struct macInfo));
+	/* Update individual M_CAST address list */
+	if ((!vdev->all_multi_flg) && dev->mc_count) {
+
+		mcast_cnt = vdev->vpaths[0].mcast_addr_cnt;
+		list_head = &vdev->vpaths[0].mac_addr_list;
+		if ((dev->mc_count +
+			(vdev->vpaths[0].mac_addr_cnt - mcast_cnt)) >
+				vdev->vpaths[0].max_mac_addr_cnt)
+			goto _set_all_mcast;
+
+		/* Delete previous MC's */
+		for (i = 0; i < mcast_cnt; i++) {
+			mac_entry = (struct vxge_mac_addrs *)
+					vxge_list_first_get(list_head);
+
+			vxge_list_for_each_safe(entry, next, list_head) {
+
+				mac_entry = (struct vxge_mac_addrs *) entry;
+				/* Copy the mac address to delete */
+				mac_address = (u8 *)&mac_entry->macaddr;
+				memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
+
+				/* Is this a multicast address */
+				if (0x01 & mac_info.macaddr[0]) {
+					for (vpath_idx = 0; vpath_idx <
+						vdev->no_of_vpath;
+						vpath_idx++) {
+						mac_info.vpath_no = vpath_idx;
+						status = vxge_del_mac_addr(
+								vdev,
+								&mac_info);
+					}
+				}
+
+			}
+		}
+
+		/* Add new ones */
+		for (i = 0, mclist = dev->mc_list; i < dev->mc_count;
+			i++, mclist = mclist->next) {
+
+			memcpy(mac_info.macaddr, mclist->dmi_addr, ETH_ALEN);
+			for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath;
+					vpath_idx++) {
+				mac_info.vpath_no = vpath_idx;
+				mac_info.state = VXGE_LL_MAC_ADDR_IN_DA_TABLE;
+				status = vxge_add_mac_addr(vdev, &mac_info);
+				if (status != VXGE_HW_OK) {
+					vxge_debug_init(VXGE_ERR,
+						"%s:%d Setting individual \
+						multicast address failed",
+						__func__, __LINE__);
+					goto _set_all_mcast;
+				}
+			}
+		}
+
+		return;
+_set_all_mcast:
+		mcast_cnt = vdev->vpaths[0].mcast_addr_cnt;
+		/* Delete previous MC's */
+		for (i = 0; i < mcast_cnt; i++) {
+
+			vxge_list_for_each_safe(entry, next, list_head) {
+
+				mac_entry = (struct vxge_mac_addrs *) entry;
+				/* Copy the mac address to delete */
+				mac_address = (u8 *)&mac_entry->macaddr;
+				memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
+
+				/* Is this a multicast address */
+				if (0x01 & mac_info.macaddr[0])
+					break;
+			}
+
+			for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath;
+					vpath_idx++) {
+				mac_info.vpath_no = vpath_idx;
+				status = vxge_del_mac_addr(vdev, &mac_info);
+			}
+		}
+
+		/* Enable all multicast */
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+			vxge_assert(vdev->vpaths[i].is_open);
+			status = vxge_hw_vpath_mcast_enable(
+						vdev->vpaths[i].handle);
+			if (status != VXGE_HW_OK) {
+				vxge_debug_init(VXGE_ERR,
+					"%s:%d Enabling all multicasts failed",
+					 __func__, __LINE__);
+			}
+			vdev->all_multi_flg = 1;
+		}
+		dev->flags |= IFF_ALLMULTI;
+	}
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+}
+
+/*
+ * vxge_set_mac_addr
+ * @dev: pointer to the device structure
+ *
+ * Update entry "0" (default MAC addr)
+ */
+static int vxge_set_mac_addr(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct vxgedev *vdev;
+	struct __hw_device  *hldev;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct macInfo mac_info_new, mac_info_old;
+	int vpath_idx = 0;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+	vxge_assert(dev);
+	vxge_assert(netdev_priv(dev));
+
+	vdev = (struct vxgedev *)netdev_priv(dev);
+	hldev = (struct __hw_device  *)vdev->devh;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memset(&mac_info_new, 0, sizeof(struct macInfo));
+	memset(&mac_info_old, 0, sizeof(struct macInfo));
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d  Exiting...\n",
+		__func__, __LINE__);
+
+	/* Get the old address */
+	memcpy(mac_info_old.macaddr, dev->dev_addr, dev->addr_len);
+
+	/* Copy the new address */
+	memcpy(mac_info_new.macaddr, addr->sa_data, dev->addr_len);
+
+	/* First delete the old mac address from all the vpaths
+	as we can't specify the index while adding new mac address */
+	for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath; vpath_idx++) {
+		struct vxge_vpath *vpath = &vdev->vpaths[vpath_idx];
+		if (!vpath->is_open) {
+			/* This can happen when this interface is added/removed
+			to the bonding interface. Delete this station address
+			from the linked list */
+			vxge_mac_list_del(vpath, &mac_info_old);
+
+			/* Add this new address to the linked list
+			for later restoring */
+			vxge_mac_list_add(vpath, &mac_info_new);
+
+			continue;
+		}
+		/* Delete the station address */
+		mac_info_old.vpath_no = vpath_idx;
+		status = vxge_del_mac_addr(vdev, &mac_info_old);
+	}
+
+	if (unlikely(!is_vxge_card_up(vdev))) {
+		memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+		return VXGE_HW_OK;
+	}
+
+	/* Set this mac address to all the vpaths */
+	for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath; vpath_idx++) {
+		mac_info_new.vpath_no = vpath_idx;
+		mac_info_new.state = VXGE_LL_MAC_ADDR_IN_DA_TABLE;
+		status = vxge_add_mac_addr(vdev, &mac_info_new);
+		if (status != VXGE_HW_OK)
+			return -EINVAL;
+	}
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	return status;
+}
+
+/*
+ * vxge_vpath_intr_enable
+ * @vdev: pointer to vdev
+ * @vp_id: vpath for which to enable the interrupts
+ *
+ * Enables the interrupts for the vpath
+*/
+void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id)
+{
+	struct vxge_vpath *vpath = &vdev->vpaths[vp_id];
+	int msix_id, alarm_msix_id;
+	int tim_msix_id[4] = {[0 ...3] = 0};
+
+	vxge_hw_vpath_intr_enable(vpath->handle);
+
+	if (vdev->config.intr_type == INTA)
+		vxge_hw_vpath_inta_unmask_tx_rx(vpath->handle);
+	else {
+		msix_id = vp_id * VXGE_HW_VPATH_MSIX_ACTIVE;
+		alarm_msix_id =
+			VXGE_HW_VPATH_MSIX_ACTIVE * vdev->no_of_vpath - 2;
+
+		tim_msix_id[0] = msix_id;
+		tim_msix_id[1] = msix_id + 1;
+		vxge_hw_vpath_msix_set(vpath->handle, tim_msix_id,
+			alarm_msix_id);
+
+		vxge_hw_vpath_msix_unmask(vpath->handle, msix_id);
+		vxge_hw_vpath_msix_unmask(vpath->handle, msix_id + 1);
+
+		/* enable the alarm vector */
+		vxge_hw_vpath_msix_unmask(vpath->handle, alarm_msix_id);
+	}
+}
+
+/*
+ * vxge_vpath_intr_disable
+ * @vdev: pointer to vdev
+ * @vp_id: vpath for which to disable the interrupts
+ *
+ * Disables the interrupts for the vpath
+*/
+void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
+{
+	struct vxge_vpath *vpath = &vdev->vpaths[vp_id];
+	int msix_id;
+
+	vxge_hw_vpath_intr_disable(vpath->handle);
+
+	if (vdev->config.intr_type == INTA)
+		vxge_hw_vpath_inta_mask_tx_rx(vpath->handle);
+	else {
+		msix_id = vp_id * VXGE_HW_VPATH_MSIX_ACTIVE;
+		vxge_hw_vpath_msix_mask(vpath->handle, msix_id);
+		vxge_hw_vpath_msix_mask(vpath->handle, msix_id + 1);
+
+		/* disable the alarm vector */
+		msix_id = VXGE_HW_VPATH_MSIX_ACTIVE * vdev->no_of_vpath - 2;
+		vxge_hw_vpath_msix_mask(vpath->handle, msix_id);
+	}
+}
+
+/*
+ * vxge_reset_vpath
+ * @vdev: pointer to vdev
+ * @vp_id: vpath to reset
+ *
+ * Resets the vpath
+*/
+int vxge_reset_vpath(struct vxgedev *vdev, int vp_id)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	int ret = 0;
+
+	/* check if device is down already */
+	if (unlikely(!is_vxge_card_up(vdev)))
+		return 0;
+
+	/* is device reset already scheduled */
+	if (test_bit(__VXGE_STATE_RESET_CARD, &vdev->state))
+		return 0;
+
+	if (vdev->vpaths[vp_id].handle) {
+		if (vxge_hw_vpath_reset(vdev->vpaths[vp_id].handle)
+				== VXGE_HW_OK) {
+			if (is_vxge_card_up(vdev) &&
+				vxge_hw_vpath_recover_from_reset(
+					vdev->vpaths[vp_id].handle)
+					!= VXGE_HW_OK) {
+				vxge_debug_init(VXGE_ERR,
+					"vxge_hw_vpath_recover_from_reset \
+					failed for vpath:%d\n", vp_id);
+				return status;
+			}
+		} else {
+			vxge_debug_init(VXGE_ERR,
+				"vxge_hw_vpath_reset failed for \
+				vpath:%d\n", vp_id);
+				return status;
+		}
+	} else
+		return VXGE_HW_FAIL;
+
+	vxge_restore_vpath_mac_addr(&vdev->vpaths[vp_id]);
+	vxge_restore_vpath_vid_table(&vdev->vpaths[vp_id]);
+
+	/* Enable all broadcast */
+	vxge_hw_vpath_bcast_enable(vdev->vpaths[vp_id].handle);
+
+	/* Enable the interrupts */
+	vxge_vpath_intr_enable(vdev, vp_id);
+
+	smp_wmb();
+
+	/* Enable the flow of traffic through the vpath */
+	vxge_hw_vpath_enable(vdev->vpaths[vp_id].handle);
+
+	/* Vpath reset done */
+	clear_bit(vp_id, &vdev->vp_reset);
+
+	/* Start the vpath queue */
+	vxge_wake_tx_queue(&vdev->vpaths[vp_id].fifo, NULL);
+
+	return ret;
+}
+
+int do_vxge_reset(struct vxgedev *vdev, int event)
+{
+	enum vxge_hw_status status;
+	int ret = 0, vp_id, i;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+
+	if ((event == VXGE_LL_FULL_RESET) || (event == VXGE_LL_START_RESET)) {
+		/* check if device is down already */
+		if (unlikely(!is_vxge_card_up(vdev)))
+			return 0;
+
+		/* is reset already scheduled */
+		if (test_and_set_bit(__VXGE_STATE_RESET_CARD, &vdev->state))
+			return 0;
+	}
+
+	if (event == VXGE_LL_FULL_RESET) {
+		/* wait for all the vpath reset to complete */
+		for (vp_id = 0; vp_id < vdev->no_of_vpath; vp_id++) {
+			while (test_bit(vp_id, &vdev->vp_reset))
+				msleep(50);
+		}
+
+		/* if execution mode is set to debug, don't reset the adapter */
+		if (unlikely(vdev->exec_mode)) {
+			vxge_debug_init(VXGE_ERR,
+				"%s: execution mode is debug, returning..",
+				vdev->ndev->name);
+		clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
+		vxge_stop_all_tx_queue(vdev);
+		return 0;
+		}
+	}
+
+	printk(KERN_NOTICE "%s: reseting the chip\n",
+		vdev->ndev->name);
+
+	if (event == VXGE_LL_FULL_RESET) {
+		vxge_hw_device_intr_disable(vdev->devh);
+
+		switch (vdev->cric_err_event.type) {
+		case VXGE_HW_EVENT_UNKNOWN:
+			vxge_stop_all_tx_queue(vdev);
+			vxge_debug_init(VXGE_ERR,
+				"fatal: %s: Disabling device due to"
+				"unknown error",
+				vdev->ndev->name);
+			ret = -EPERM;
+			goto out;
+		case VXGE_HW_EVENT_RESET_START:
+			break;
+		case VXGE_HW_EVENT_RESET_COMPLETE:
+		case VXGE_HW_EVENT_LINK_DOWN:
+		case VXGE_HW_EVENT_LINK_UP:
+		case VXGE_HW_EVENT_ALARM_CLEARED:
+		case VXGE_HW_EVENT_ECCERR:
+		case VXGE_HW_EVENT_MRPCIM_ECCERR:
+			ret = -EPERM;
+			goto out;
+		case VXGE_HW_EVENT_FIFO_ERR:
+		case VXGE_HW_EVENT_VPATH_ERR:
+			break;
+		case VXGE_HW_EVENT_CRITICAL_ERR:
+			vxge_stop_all_tx_queue(vdev);
+			vxge_debug_init(VXGE_ERR,
+				"fatal: %s: Disabling device due to"
+				"serious error",
+				vdev->ndev->name);
+			/* SOP or device reset required */
+			/* This event is not currently used */
+			ret = -EPERM;
+			goto out;
+		case VXGE_HW_EVENT_SERR:
+			vxge_stop_all_tx_queue(vdev);
+			vxge_debug_init(VXGE_ERR,
+				"fatal: %s: Disabling device due to"
+				"serious error",
+				vdev->ndev->name);
+			ret = -EPERM;
+			goto out;
+		case VXGE_HW_EVENT_SRPCIM_SERR:
+		case VXGE_HW_EVENT_MRPCIM_SERR:
+			ret = -EPERM;
+			goto out;
+		case VXGE_HW_EVENT_SLOT_FREEZE:
+			vxge_stop_all_tx_queue(vdev);
+			vxge_debug_init(VXGE_ERR,
+				"fatal: %s: Disabling device due to"
+				"slot freeze",
+				vdev->ndev->name);
+			ret = -EPERM;
+			goto out;
+		default:
+			break;
+
+		}
+	}
+
+	if ((event == VXGE_LL_FULL_RESET) || (event == VXGE_LL_START_RESET))
+		vxge_stop_all_tx_queue(vdev);
+
+	if (event == VXGE_LL_FULL_RESET) {
+		status = vxge_reset_all_vpaths(vdev);
+		if (status != VXGE_HW_OK) {
+			vxge_debug_init(VXGE_ERR,
+				"fatal: %s: can not reset vpaths",
+				vdev->ndev->name);
+			ret = -EPERM;
+			goto out;
+		}
+	}
+
+	if (event == VXGE_LL_COMPL_RESET) {
+		for (i = 0; i < vdev->no_of_vpath; i++)
+			if (vdev->vpaths[i].handle) {
+				if (vxge_hw_vpath_recover_from_reset(
+					vdev->vpaths[i].handle)
+						!= VXGE_HW_OK) {
+					vxge_debug_init(VXGE_ERR,
+						"vxge_hw_vpath_recover_"
+						"from_reset failed for vpath: \
+						%d\n", i);
+					ret = -EPERM;
+					goto out;
+				}
+				} else {
+					vxge_debug_init(VXGE_ERR,
+					"vxge_hw_vpath_reset failed for \
+						vpath:%d\n", i);
+					ret = -EPERM;
+					goto out;
+				}
+	}
+
+	if ((event == VXGE_LL_FULL_RESET) || (event == VXGE_LL_COMPL_RESET)) {
+		/* Reprogram the DA table with populated mac addresses */
+		for (vp_id = 0; vp_id < vdev->no_of_vpath; vp_id++) {
+			vxge_restore_vpath_mac_addr(&vdev->vpaths[vp_id]);
+			vxge_restore_vpath_vid_table(&vdev->vpaths[vp_id]);
+		}
+
+		/* enable vpath interrupts */
+		for (i = 0; i < vdev->no_of_vpath; i++)
+			vxge_vpath_intr_enable(vdev, i);
+
+		vxge_hw_device_intr_enable(vdev->devh);
+
+		smp_wmb();
+
+		/* Indicate card up */
+		set_bit(__VXGE_STATE_CARD_UP, &vdev->state);
+
+		/* Get the traffic to flow through the vpaths */
+		for (i = 0; i < vdev->no_of_vpath; i++)
+			vxge_hw_vpath_enable(vdev->vpaths[i].handle);
+
+		vxge_wake_all_tx_queue(vdev);
+	}
+
+out:
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+
+	/* Indicate reset done */
+	if ((event == VXGE_LL_FULL_RESET) || (event == VXGE_LL_COMPL_RESET))
+		clear_bit(__VXGE_STATE_RESET_CARD, &vdev->state);
+	return ret;
+}
+
+/*
+ * vxge_reset
+ * @vdev: pointer to ll device
+ *
+ * driver may reset the chip on events of serr, eccerr, etc
+ */
+int vxge_reset(struct vxgedev *vdev)
+{
+	do_vxge_reset(vdev, VXGE_LL_FULL_RESET);
+	return 0;
+}
+
+/**
+ * vxge_poll - Receive handler when Receive Polling is used.
+ * @dev: pointer to the device structure.
+ * @budget: Number of packets budgeted to be processed in this iteration.
+ *
+ * This function comes into picture only if Receive side is being handled
+ * through polling (called NAPI in linux). It mostly does what the normal
+ * Rx interrupt handler does in terms of descriptor and packet processing
+ * but not in an interrupt context. Also it will process a specified number
+ * of packets at most in one iteration. This value is passed down by the
+ * kernel as the function argument 'budget'.
+ */
+#if defined(HAVE_NETDEV_POLL)
+
+static int vxge_poll_msix(struct napi_struct *napi, int budget)
+{
+	struct vxge_ring *ring =
+		container_of(napi, struct vxge_ring, napi);
+	int budget_org = budget;
+	ring->budget = budget;
+
+	VXGE_COMPLETE_VPATH_RX(ring);
+
+	if (ring->pkts_processed < budget_org) {
+		napi_complete(napi);
+		/* Re enable the Rx interrupts for the vpath */
+		vxge_hw_channel_msix_unmask((struct __hw_channel *)ring->handle,
+						ring->rx_vector_no);
+	}
+
+	return ring->pkts_processed;
+}
+
+static int vxge_poll_inta(struct napi_struct *napi, int budget)
+{
+	struct vxgedev *vdev = container_of(napi, struct vxgedev, napi);
+	int pkts_processed = 0;
+	int i;
+	int budget_org = budget;
+	struct vxge_ring *ring;
+
+	struct __hw_device  *hldev = (struct __hw_device  *)
+		pci_get_drvdata(vdev->pdev);
+
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		ring = &vdev->vpaths[i].ring;
+		ring->budget = budget;
+		VXGE_COMPLETE_VPATH_RX(ring);
+		pkts_processed += ring->pkts_processed;
+		budget -= ring->pkts_processed;
+		if (budget <= 0)
+			break;
+	}
+
+	VXGE_COMPLETE_ALL_TX(vdev);
+
+	if (pkts_processed < budget_org) {
+		napi_complete(napi);
+		/* Re enable the Rx interrupts for the ring */
+
+			vxge_hw_device_unmask_all(hldev);
+			vxge_hw_device_flush_io(hldev);
+
+	}
+
+	return pkts_processed;
+}
+
+#endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/**
+ * vxge_netpoll - netpoll event handler entry point
+ * @dev : pointer to the device structure.
+ * Description:
+ *      This function will be called by upper layer to check for events on the
+ * interface in situations where interrupts are disabled. It is used for
+ * specific in-kernel networking tasks, such as remote consoles and kernel
+ * debugging over the network (example netdump in RedHat).
+ */
+static void vxge_netpoll(struct net_device *dev)
+{
+	struct __hw_device  *hldev;
+	struct vxgedev *vdev;
+
+	vdev = (struct vxgedev *)netdev_priv(dev);
+	hldev = (struct __hw_device  *)pci_get_drvdata(vdev->pdev);
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+
+	if (pci_channel_offline(vdev->pdev))
+		return;
+
+	disable_irq(dev->irq);
+	vxge_hw_device_clear_tx_rx(hldev);
+
+	vxge_hw_device_clear_tx_rx(hldev);
+	VXGE_COMPLETE_ALL_RX(vdev);
+	VXGE_COMPLETE_ALL_TX(vdev);
+
+	enable_irq(dev->irq);
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+	return;
+}
+#endif
+
+/* RTH configuration */
+enum vxge_hw_status vxge_rth_configure(struct vxgedev *vdev)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_hw_rth_hash_types hash_types;
+	u8 itable[256] = {0}; /* indirection table */
+	u8 mtable[256] = {0}; /* CPU to vpath mapping  */
+	int index;
+
+	/*
+	 * Filling
+	 * 	- itable with bucket numbers
+	 * 	- mtable with bucket-to-vpath mapping
+	 */
+	for (index = 0; index < (1 << vdev->config.rth_bkt_sz); index++) {
+		itable[index] = index;
+		mtable[index] = index % vdev->no_of_vpath;
+	}
+
+	/* Fill RTH hash types */
+	hash_types.hash_type_tcpipv4_en   = vdev->config.rth_hash_type_tcpipv4;
+	hash_types.hash_type_ipv4_en      = vdev->config.rth_hash_type_ipv4;
+	hash_types.hash_type_tcpipv6_en   = vdev->config.rth_hash_type_tcpipv6;
+	hash_types.hash_type_ipv6_en      = vdev->config.rth_hash_type_ipv6;
+	hash_types.hash_type_tcpipv6ex_en =
+					vdev->config.rth_hash_type_tcpipv6ex;
+	hash_types.hash_type_ipv6ex_en    = vdev->config.rth_hash_type_ipv6ex;
+
+	/* set indirection table, bucket-to-vpath mapping */
+	status = vxge_hw_vpath_rts_rth_itable_set(vdev->vp_handles,
+						vdev->no_of_vpath,
+						mtable,
+						itable,
+						vdev->config.rth_bkt_sz);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"RTH indirection table configuration failed \
+			for vpath:%d:\n",
+			vdev->vpaths[0].device_id);
+		return status;
+	}
+
+	/*
+	* Because the itable_set() method uses the active_table field
+	* for the target virtual path the RTH config should be updated
+	* for all VPATHs. The h/w only uses the lowest numbered VPATH
+	* when steering frames.
+	*/
+	 for (index = 0; index < vdev->no_of_vpath; index++) {
+		status = vxge_hw_vpath_rts_rth_set(
+				vdev->vpaths[index].handle,
+				vdev->config.rth_algorithm,
+				&hash_types,
+				vdev->config.rth_bkt_sz);
+
+		 if (status != VXGE_HW_OK) {
+			vxge_debug_init(VXGE_ERR,
+				"RTH configuration failed for vpath:%d",
+				vdev->vpaths[index].device_id);
+			return status;
+		 }
+	 }
+
+	return status;
+}
+
+int vxge_mac_list_add(struct vxge_vpath *vpath,
+				struct macInfo *mac)
+{
+	struct vxge_mac_addrs *new_mac_entry;
+	u8 *mac_address = NULL;
+
+	if (vpath->mac_addr_cnt >= VXGE_MAX_LEARN_MAC_ADDR_CNT)
+		return TRUE;
+
+	new_mac_entry = kzalloc(sizeof(struct vxge_mac_addrs), GFP_ATOMIC);
+	if (!new_mac_entry) {
+		vxge_debug_mem(VXGE_ERR,
+			"%s: memory allocation failed",
+			VXGE_DRIVER_NAME);
+		return FALSE;
+	}
+
+	vxge_list_insert(&new_mac_entry->item, &vpath->mac_addr_list);
+
+	/* Copy the new mac address to the list */
+	mac_address = (u8 *)&new_mac_entry->macaddr;
+	memcpy(mac_address, mac->macaddr, ETH_ALEN);
+
+	new_mac_entry->state = mac->state;
+	vpath->mac_addr_cnt++;
+
+	/* Is this a multicast address */
+	if (0x01 & mac->macaddr[0])
+		vpath->mcast_addr_cnt++;
+
+	return TRUE;
+}
+
+/* Add a mac address to DA table */
+enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
+	struct macInfo *mac)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_vpath *vpath;
+	enum vxge_hw_vpath_mac_addr_add_mode duplicate_mode;
+
+	if (0x01 & mac->macaddr[0]) /* multicast address */
+		duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE;
+	else
+		duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_REPLACE_DUPLICATE;
+
+	vpath = &vdev->vpaths[mac->vpath_no];
+	status = vxge_hw_vpath_mac_addr_add(vpath->handle, mac->macaddr,
+						mac->macmask,
+						duplicate_mode);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"DA config add entry failed for vpath:%d",
+			vpath->device_id);
+	} else
+		if (FALSE == vxge_mac_list_add(vpath, mac))
+			status = -EPERM;
+
+	return status;
+}
+
+int vxge_mac_list_del(struct vxge_vpath *vpath,
+					struct macInfo *mac)
+{
+	struct vxge_list *entry, *next;
+	u64 del_mac = 0;
+	u8 *mac_address = (u8 *) (&del_mac);
+
+	/* Copy the mac address to delete from the list */
+	memcpy(mac_address, mac->macaddr, ETH_ALEN);
+
+	vxge_list_for_each_safe(entry, next, &vpath->mac_addr_list) {
+		if (((struct vxge_mac_addrs *)entry)->macaddr == del_mac) {
+			vxge_list_remove(entry);
+			kfree((struct vxge_mac_addrs *)entry);
+			vpath->mac_addr_cnt--;
+
+			/* Is this a multicast address */
+			if (0x01 & mac->macaddr[0])
+				vpath->mcast_addr_cnt--;
+			return TRUE;
+		}
+	}
+
+	return FALSE;
+}
+/* delete a mac address from DA table */
+enum vxge_hw_status vxge_del_mac_addr(struct vxgedev *vdev,
+					struct macInfo *mac)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_vpath *vpath;
+
+	vpath = &vdev->vpaths[mac->vpath_no];
+	status = vxge_hw_vpath_mac_addr_delete(vpath->handle, mac->macaddr,
+						mac->macmask);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"DA config delete entry failed for vpath:%d",
+			vpath->device_id);
+	} else
+		vxge_mac_list_del(vpath, mac);
+	return status;
+}
+
+/* list all mac addresses from DA table */
+enum vxge_hw_status
+vxge_search_mac_addr_in_da_table(struct vxge_vpath *vpath,
+					struct macInfo *mac)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	unsigned char macmask[ETH_ALEN];
+	unsigned char macaddr[ETH_ALEN];
+
+	/* get first entry */
+	status = vxge_hw_vpath_mac_addr_get(vpath->handle,
+				macaddr, macmask);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"DA config list entry failed for vpath:%d",
+			vpath->device_id);
+		return status;
+	}
+
+	if (!compare_ether_addr(mac->macaddr, macaddr))
+		return status;
+
+	while (status == VXGE_HW_OK) {
+		/* Get next entries */
+		status = vxge_hw_vpath_mac_addr_get_next(vpath->handle,
+				macaddr, macmask);
+
+		if (status != VXGE_HW_OK)
+			return status;
+
+		/* Is it already present? */
+		if (!compare_ether_addr(mac->macaddr, macaddr))
+			return status;
+	}
+
+	return status;
+}
+
+/* Store all vlan ids from the list to the vid table */
+enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxgedev *vdev = vpath->vdev;
+	u16 vid;
+
+	if (vdev->vlgrp && vpath->is_open) {
+
+		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+			if (!vlan_group_get_device(vdev->vlgrp, vid))
+				continue;
+			/* Add these vlan to the vid table */
+			status = vxge_hw_vpath_vid_add(vpath->handle, vid);
+		}
+	}
+
+	return status;
+}
+
+/* Store all mac addresses from the list to the DA table */
+enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct macInfo mac_info;
+	u8 *mac_address = NULL;
+	struct vxge_list *entry, *next;
+
+	memset(&mac_info, 0, sizeof(struct macInfo));
+
+	if (vpath->is_open) {
+
+		vxge_list_for_each_safe(entry, next, &vpath->mac_addr_list) {
+			mac_address =
+				(u8 *)&
+				((struct vxge_mac_addrs *)entry)->macaddr;
+			memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
+			((struct vxge_mac_addrs *)entry)->state =
+				VXGE_LL_MAC_ADDR_IN_DA_TABLE;
+			/* does this mac address already exist in da table? */
+			status = vxge_search_mac_addr_in_da_table(vpath,
+				&mac_info);
+			if (status != VXGE_HW_OK) {
+				/* Add this mac address to the DA table */
+				status = vxge_hw_vpath_mac_addr_add(
+					vpath->handle, mac_info.macaddr,
+					mac_info.macmask,
+				    VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE);
+				if (status != VXGE_HW_OK) {
+					vxge_debug_init(VXGE_ERR,
+					    "DA add entry failed for vpath:%d",
+					    vpath->device_id);
+					((struct vxge_mac_addrs *)entry)->state
+						= VXGE_LL_MAC_ADDR_IN_LIST;
+				}
+			}
+		}
+	}
+
+	return status;
+}
+
+/* reset vpaths */
+enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
+{
+	int i;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	for (i = 0; i < vdev->no_of_vpath; i++)
+		if (vdev->vpaths[i].handle) {
+			if (vxge_hw_vpath_reset(vdev->vpaths[i].handle)
+					== VXGE_HW_OK) {
+				if (is_vxge_card_up(vdev) &&
+					vxge_hw_vpath_recover_from_reset(
+						vdev->vpaths[i].handle)
+						!= VXGE_HW_OK) {
+					vxge_debug_init(VXGE_ERR,
+						"vxge_hw_vpath_recover_"
+						"from_reset failed for vpath: \
+						%d\n", i);
+					return status;
+				}
+			} else {
+				vxge_debug_init(VXGE_ERR,
+					"vxge_hw_vpath_reset failed for \
+					vpath:%d\n", i);
+					return status;
+			}
+		}
+	return status;
+}
+
+/* close vpaths */
+void vxge_close_vpaths(struct vxgedev *vdev, int index)
+{
+	int i;
+	for (i = index; i < vdev->no_of_vpath; i++) {
+		if (vdev->vpaths[i].handle && vdev->vpaths[i].is_open)
+			vxge_hw_vpath_close(vdev->vpaths[i].handle);
+		vdev->vpaths[i].is_open = 0;
+		vdev->vpaths[i].handle  = NULL;
+	}
+}
+
+static int
+vxge_get_skb_header(struct sk_buff *skb,
+	void **iphdr, void **tcphdr,
+	u64 *hdr_flags, void *priv)
+{
+	struct vxge_hw_ring_rxd_info *ext_info =
+		(struct vxge_hw_ring_rxd_info *)priv;
+
+	/* Verify that this is a valid IPv4 TCP packet */
+	if (!(ext_info->proto & (VXGE_HW_FRAME_PROTO_TCP |
+		VXGE_HW_FRAME_PROTO_IPV4)))
+		return -1;
+
+	/* Set network headers */
+	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, ip_hdrlen(skb));
+	*iphdr = ip_hdr(skb);
+	*tcphdr = tcp_hdr(skb);
+	*hdr_flags = LRO_IPV4 | LRO_TCP;
+
+	return 0;
+}
+
+/* open vpaths */
+int vxge_open_vpaths(struct vxgedev *vdev)
+{
+	enum vxge_hw_status status;
+	int i;
+	u32 vp_id = 0;
+	struct vxge_hw_vpath_attr attr;
+
+	struct net_lro_mgr *lro_mgr = NULL;
+
+	if (vdev->config.lro_enable) {
+		/* Initialize max aggregatable pkts per session based on MTU */
+		vdev->config.lro_max_aggr_per_sess =
+			(vdev->config.lro_max_bytes - 1) / vdev->mtu;
+
+		if (vdev->config.lro_max_aggr_per_sess < MIN_LRO_PACKETS)
+			vdev->config.lro_max_aggr_per_sess = MIN_LRO_PACKETS;
+
+		if (vdev->config.lro_max_aggr_per_sess > MAX_LRO_PACKETS)
+			vdev->config.lro_max_aggr_per_sess = MAX_LRO_PACKETS;
+	}
+
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		vxge_assert(vdev->vpaths[i].is_configured);
+		attr.vp_id = vdev->vpaths[i].device_id;
+		attr.fifo_attr.callback = vxge_xmit_compl;
+		attr.fifo_attr.txdl_init = NULL;
+		attr.fifo_attr.txdl_term = vxge_tx_term;
+		attr.fifo_attr.per_txdl_space = sizeof(struct vxge_tx_priv);
+		attr.fifo_attr.userdata = (void *)&vdev->vpaths[i].fifo;
+
+		attr.ring_attr.callback = vxge_rx_1b_compl;
+		attr.ring_attr.rxd_init = vxge_rx_initial_replenish;
+		attr.ring_attr.rxd_term = vxge_rx_term;
+		attr.ring_attr.per_rxd_space = sizeof(struct vxge_rx_priv);
+		attr.ring_attr.userdata = (void *)&vdev->vpaths[i].ring;
+
+		vdev->vpaths[i].ring.ndev = vdev->ndev;
+		vdev->vpaths[i].ring.pdev = vdev->pdev;
+		status = vxge_hw_vpath_open(vdev->devh, &attr,
+				NULL, &(vdev->vpaths[i].handle));
+		if (status == VXGE_HW_OK) {
+			vdev->vpaths[i].fifo.handle =
+				(struct __hw_fifo *)attr.fifo_attr.userdata;
+			vdev->vpaths[i].ring.handle =
+				(struct __hw_ring *)attr.ring_attr.userdata;
+			vdev->vpaths[i].fifo.tx_steering_type =
+				vdev->config.tx_steering_type;
+			vdev->vpaths[i].fifo.ndev = vdev->ndev;
+			vdev->vpaths[i].fifo.pdev = vdev->pdev;
+			vdev->vpaths[i].fifo.indicate_max_pkts =
+				vdev->config.fifo_indicate_max_pkts;
+			vdev->vpaths[i].ring.aggr_ack =
+				vdev->config.aggr_ack;
+			vdev->vpaths[i].ring.rx_vector_no = 0;
+			vdev->vpaths[i].ring.rx_csum = vdev->rx_csum;
+			vdev->vpaths[i].is_open = 1;
+			vdev->vp_handles[i] = vdev->vpaths[i].handle;
+			vdev->vpaths[i].ring.lro_enable =
+						vdev->config. lro_enable;
+			vdev->vpaths[i].ring.vlan_tag_strip =
+						vdev->vlan_tag_strip;
+			vdev->stats.vpaths_open++;
+		} else {
+			vdev->stats.vpath_open_fail++;
+			vxge_debug_init(VXGE_ERR,
+				"%s: vpath: %d failed to open"
+				"with status: %d",
+			    vdev->ndev->name, vdev->vpaths[i].device_id,
+				status);
+			vxge_close_vpaths(vdev, 0);
+			return -EPERM;
+		}
+
+		if (vdev->config.lro_enable) {
+
+			lro_mgr = &vdev->vpaths[i].ring.lro_mgr;
+			lro_mgr->dev = vdev->ndev;
+			if (vdev->config.napi_enable)
+				lro_mgr->features =
+					LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
+
+			if (vdev->vpaths[i].ring.vlan_tag_strip)
+				lro_mgr->features |= LRO_F_EXTRACT_VLAN_ID;
+
+			lro_mgr->ip_summed = CHECKSUM_UNNECESSARY;
+			lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
+			lro_mgr->max_desc = MAX_LRO_SESSIONS;
+			lro_mgr->lro_arr = vdev->vpaths[i].ring.lro_desc;
+			lro_mgr->get_skb_header = vxge_get_skb_header;
+			lro_mgr->max_aggr = vdev->config.lro_max_aggr_per_sess;
+
+		}
+
+		vp_id = vxge_hw_vpath_id(vdev->vpaths[i].handle);
+		vdev->vpaths_deployed |= vxge_mBIT(vp_id);
+	}
+	return VXGE_HW_OK;
+}
+
+/*
+ *  vxge_isr_napi
+ *  @irq: the irq of the device.
+ *  @dev_id: a void pointer to the hldev structure of the Titan device
+ *  @ptregs: pointer to the registers pushed on the stack.
+ *
+ *  This function is the ISR handler of the device when napi is enabled. It
+ *  identifies the reason for the interrupt and calls the relevant service
+ *  routines.
+ */
+irqreturn_t vxge_isr_napi(int irq, void *dev_id)
+{
+	struct __hw_device  *hldev = (struct __hw_device  *)dev_id;
+	struct vxgedev *vdev;
+	struct net_device *dev;
+	u64 reason;
+	enum vxge_hw_status status;
+
+	vxge_debug_intr(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+	dev = vxge_hw_device_private_get(hldev);
+	vdev = netdev_priv(dev);
+
+	VXGE_CHECK_PCI_CHANNEL_OFFLINE(vdev->pdev);
+
+	if (unlikely(!is_vxge_card_up(vdev)))
+		return IRQ_NONE;
+
+	dev = (struct net_device *)vdev->ndev;
+	status = vxge_hw_device_begin_irq(hldev, vdev->exec_mode,
+			&reason);
+	if (status == VXGE_HW_OK) {
+		vxge_hw_device_mask_all(hldev);
+
+		if (reason &
+			VXGE_HW_TITAN_GENERAL_INT_STATUS_VPATH_TRAFFIC_INT(
+			vdev->vpaths_deployed >>
+			(64 - VXGE_HW_MAX_VIRTUAL_PATHS))) {
+
+			vxge_hw_device_clear_tx_rx(hldev);
+			napi_schedule(&vdev->napi);
+			vxge_debug_intr(VXGE_TRACE,
+				"%s:%d  Exiting...\n", __func__, __LINE__);
+			return IRQ_HANDLED;
+		} else
+			vxge_hw_device_unmask_all(hldev);
+	} else if (unlikely((status == VXGE_HW_ERR_VPATH) ||
+		(status == VXGE_HW_ERR_CRITICAL) ||
+		(status == VXGE_HW_ERR_FIFO))) {
+		vxge_hw_device_mask_all(hldev);
+		vxge_hw_device_flush_io(hldev);
+		return IRQ_HANDLED;
+	} else if (unlikely(status == VXGE_HW_ERR_SLOT_FREEZE))
+		return IRQ_HANDLED;
+
+	vxge_debug_intr(VXGE_TRACE,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+	return IRQ_NONE;
+}
+
+/*
+ *  vxge_isr
+ *  @irq: the irq of the device.
+ *  @dev_id: a void pointer to the hldev structure of the Titan device
+ *  @ptregs: pointer to the registers pushed on the stack.
+ *
+ *  This function is the ISR handler of the device. It identifies the reason
+ *  for the interrupt and calls the relevant service routines.
+ */
+irqreturn_t vxge_isr(int irq, void *dev_id)
+{
+	struct __hw_device  *hldev = (struct __hw_device  *)dev_id;
+	struct vxgedev *vdev;
+	struct net_device *dev;
+	enum vxge_hw_status status;
+	u64 reason;
+
+	vxge_debug_intr(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+	dev = vxge_hw_device_private_get(hldev);
+	vdev = netdev_priv(dev);
+
+	VXGE_CHECK_PCI_CHANNEL_OFFLINE(vdev->pdev);
+
+	if (unlikely(!is_vxge_card_up(vdev)))
+		return IRQ_NONE;
+
+	status = vxge_hw_device_begin_irq(hldev, vdev->exec_mode,
+			&reason);
+	if (status == VXGE_HW_OK) {
+		vxge_hw_device_mask_all(hldev);
+
+		if (reason &
+			VXGE_HW_TITAN_GENERAL_INT_STATUS_VPATH_TRAFFIC_INT(
+			vdev->vpaths_deployed >>
+			(64 - VXGE_HW_MAX_VIRTUAL_PATHS))) {
+
+			vxge_hw_device_clear_tx_rx(hldev);
+			VXGE_COMPLETE_ALL_RX(vdev);
+			VXGE_COMPLETE_ALL_TX(vdev);
+			vxge_hw_device_unmask_all(hldev);
+			vxge_debug_intr(VXGE_TRACE,
+				"%s:%d  Exiting...\n", __func__, __LINE__);
+			return IRQ_HANDLED;
+		} else
+			vxge_hw_device_unmask_all(hldev);
+	} else if (unlikely((status == VXGE_HW_ERR_VPATH) ||
+		(status == VXGE_HW_ERR_CRITICAL) ||
+		(status == VXGE_HW_ERR_FIFO))) {
+		vxge_hw_device_mask_all(hldev);
+		vxge_hw_device_flush_io(hldev);
+		return IRQ_HANDLED;
+	} else if (unlikely(status == VXGE_HW_ERR_SLOT_FREEZE))
+		return IRQ_HANDLED;
+
+	vxge_debug_intr(VXGE_TRACE,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+	return IRQ_NONE;
+}
+
+#ifdef CONFIG_PCI_MSI
+
+irqreturn_t
+vxge_tx_msix_handle(int irq, void *dev_id)
+{
+	struct vxge_fifo *fifo = (struct vxge_fifo *)dev_id;
+
+	VXGE_COMPLETE_VPATH_TX(fifo);
+
+	return IRQ_HANDLED;
+}
+
+irqreturn_t
+vxge_rx_msix_napi_handle(int irq, void *dev_id)
+{
+	struct vxge_ring *ring = (struct vxge_ring *)dev_id;
+
+	/* MSIX_IDX for Rx is 1 */
+	vxge_hw_channel_msix_mask((struct __hw_channel *)ring->handle,
+					ring->rx_vector_no);
+
+	napi_schedule(&ring->napi);
+	return IRQ_HANDLED;
+}
+
+irqreturn_t
+vxge_rx_msix_handle(int irq, void *dev_id)
+{
+	struct vxge_ring *ring = (struct vxge_ring *)dev_id;
+
+	VXGE_COMPLETE_VPATH_RX(ring);
+
+	return IRQ_HANDLED;
+}
+
+irqreturn_t
+vxge_alarm_msix_handle(int irq, void *dev_id)
+{
+	int i;
+	enum vxge_hw_status status;
+	struct vxge_vpath *vpath = (struct vxge_vpath *)dev_id;
+	struct vxgedev *vdev = vpath->vdev;
+	int alarm_msix_id =
+		VXGE_HW_VPATH_MSIX_ACTIVE * vdev->no_of_vpath - 2;
+
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		vxge_hw_vpath_msix_mask(vdev->vpaths[i].handle,
+			alarm_msix_id);
+
+		status = vxge_hw_vpath_alarm_process(vdev->vpaths[i].handle,
+			vdev->exec_mode);
+		if (status == VXGE_HW_OK) {
+
+			vxge_hw_vpath_msix_unmask(vdev->vpaths[i].handle,
+				alarm_msix_id);
+
+			continue;
+		}
+		vxge_debug_intr(VXGE_ERR,
+			"%s: vxge_hw_vpath_alarm_process failed %x ",
+			VXGE_DRIVER_NAME, status);
+	}
+	return IRQ_HANDLED;
+}
+
+int vxge_alloc_msix(struct vxgedev *vdev)
+{
+	int j, i, ret = 0;
+	int intr_cnt = 0;
+	int alarm_msix_id = 0, msix_intr_vect = 0;;
+	vdev->intr_cnt = 0;
+
+	/* Tx/Rx MSIX Vectors count */
+	vdev->intr_cnt = vdev->no_of_vpath * 2;
+
+	/* Alarm MSIX Vectors count */
+	vdev->intr_cnt++;
+
+	intr_cnt = (vdev->max_vpath_supported * 2) + 1;
+	vdev->entries = kzalloc(intr_cnt * sizeof(struct msix_entry),
+						GFP_KERNEL);
+	if (!vdev->entries) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: memory allocation failed",
+			VXGE_DRIVER_NAME);
+		return  -ENOMEM;
+	}
+
+	vdev->vxge_entries = kmalloc(intr_cnt *
+					sizeof(struct vxge_msix_entry),
+					GFP_KERNEL);
+	if (!vdev->vxge_entries) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: memory allocation failed",
+			VXGE_DRIVER_NAME);
+		kfree(vdev->entries);
+		return -ENOMEM;
+	}
+
+	/* Last vector in the list is used for alarm */
+	alarm_msix_id = VXGE_HW_VPATH_MSIX_ACTIVE * vdev->no_of_vpath - 2;
+	for (i = 0, j = 0; i < vdev->max_vpath_supported; i++) {
+
+		msix_intr_vect = i * VXGE_HW_VPATH_MSIX_ACTIVE;
+
+		/* Initialize the fifo vector */
+		vdev->entries[j].entry = msix_intr_vect;
+		vdev->vxge_entries[j].entry = msix_intr_vect;
+		vdev->vxge_entries[j].in_use = 0;
+		j++;
+
+		/* Initialize the ring vector */
+		vdev->entries[j].entry = msix_intr_vect + 1;
+		vdev->vxge_entries[j].entry = msix_intr_vect + 1;
+		vdev->vxge_entries[j].in_use = 0;
+		j++;
+	}
+
+	/* Initialize the alarm vector */
+	vdev->entries[j].entry = alarm_msix_id;
+	vdev->vxge_entries[j].entry = alarm_msix_id;
+	vdev->vxge_entries[j].in_use = 0;
+
+	ret = pci_enable_msix(vdev->pdev, vdev->entries, intr_cnt);
+	/* if driver request exceeeds available irq's, request with a small
+	 * number.
+	*/
+	if (ret > 0) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: MSI-X enable failed for %d vectors, available: %d",
+			VXGE_DRIVER_NAME, intr_cnt, ret);
+		vdev->max_vpath_supported = vdev->no_of_vpath;
+		intr_cnt = (vdev->max_vpath_supported * 2) + 1;
+
+		/* Reset the alarm vector setting */
+		vdev->entries[j].entry = 0;
+		vdev->vxge_entries[j].entry = 0;
+
+		/* Initialize the alarm vector with new setting */
+		vdev->entries[intr_cnt - 1].entry = alarm_msix_id;
+		vdev->vxge_entries[intr_cnt - 1].entry = alarm_msix_id;
+		vdev->vxge_entries[intr_cnt - 1].in_use = 0;
+
+		ret = pci_enable_msix(vdev->pdev, vdev->entries, intr_cnt);
+		if (!ret)
+			vxge_debug_init(VXGE_ERR,
+				"%s: MSI-X enabled for %d vectors",
+				VXGE_DRIVER_NAME, intr_cnt);
+	}
+
+	if (ret) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: MSI-X enable failed for %d vectors, ret: %d",
+			VXGE_DRIVER_NAME, intr_cnt, ret);
+		kfree(vdev->entries);
+		kfree(vdev->vxge_entries);
+		vdev->entries = NULL;
+		vdev->vxge_entries = NULL;
+		return -ENODEV;
+	}
+	return 0;
+}
+
+static int vxge_enable_msix(struct vxgedev *vdev)
+{
+
+	int i, ret = 0;
+	enum vxge_hw_status status;
+	/* 0 - Tx, 1 - Rx  */
+	int tim_msix_id[4];
+	int alarm_msix_id = 0, msix_intr_vect = 0;;
+	vdev->intr_cnt = 0;
+
+	/* allocate msix vectors */
+	ret = vxge_alloc_msix(vdev);
+	if (!ret) {
+		/* Last vector in the list is used for alarm */
+		alarm_msix_id =
+			VXGE_HW_VPATH_MSIX_ACTIVE * vdev->no_of_vpath - 2;
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+
+			/* If fifo or ring are not enabled
+			   the MSIX vector for that should be set to 0
+			   Hence initializeing this array to all 0s.
+			*/
+			memset(tim_msix_id, 0, sizeof(tim_msix_id));
+			msix_intr_vect = i * VXGE_HW_VPATH_MSIX_ACTIVE;
+			tim_msix_id[0] = msix_intr_vect;
+
+			tim_msix_id[1] = msix_intr_vect + 1;
+			vdev->vpaths[i].ring.rx_vector_no = tim_msix_id[1];
+
+			status = vxge_hw_vpath_msix_set(
+						vdev->vpaths[i].handle,
+						tim_msix_id,
+						alarm_msix_id);
+			if (status != VXGE_HW_OK) {
+				vxge_debug_init(VXGE_ERR,
+					"vxge_hw_vpath_msix_set \
+					failed with status : %x \n", status);
+				kfree(vdev->entries);
+				kfree(vdev->vxge_entries);
+				pci_disable_msix(vdev->pdev);
+				return -ENODEV;
+			}
+		}
+	}
+
+	return ret;
+}
+
+static void vxge_rem_msix_isr(struct vxgedev *vdev)
+{
+	int intr_cnt;
+
+	for (intr_cnt = 0; intr_cnt < (vdev->max_vpath_supported * 2 + 1);
+		intr_cnt++) {
+		if (vdev->vxge_entries[intr_cnt].in_use) {
+			synchronize_irq(vdev->entries[intr_cnt].vector);
+			free_irq(vdev->entries[intr_cnt].vector,
+				vdev->vxge_entries[intr_cnt].arg);
+			vdev->vxge_entries[intr_cnt].in_use = 0;
+		}
+	}
+
+	kfree(vdev->entries);
+	kfree(vdev->vxge_entries);
+	vdev->entries = NULL;
+	vdev->vxge_entries = NULL;
+
+	if (vdev->config.intr_type == MSI_X)
+		pci_disable_msix(vdev->pdev);
+}
+#endif
+
+static void vxge_rem_isr(struct vxgedev *vdev)
+{
+	struct __hw_device  *hldev;
+	hldev = (struct __hw_device  *) pci_get_drvdata(vdev->pdev);
+
+#ifdef CONFIG_PCI_MSI
+	if (vdev->config.intr_type == MSI_X) {
+		vxge_rem_msix_isr(vdev);
+	} else
+#endif
+	if (
+
+		(vdev->config.intr_type == INTA)) {
+			synchronize_irq(vdev->pdev->irq);
+			free_irq(vdev->pdev->irq, hldev);
+	}
+}
+
+int vxge_add_isr(struct vxgedev *vdev)
+{
+	int ret = 0;
+	struct __hw_device  *hldev;
+#ifdef CONFIG_PCI_MSI
+	int vp_idx = 0, intr_idx = 0, intr_cnt = 0, msix_idx = 0, irq_req = 0;
+#endif
+	u64 function_mode = vdev->config.device_hw_info.function_mode;
+	int pci_fun = PCI_FUNC(vdev->pdev->devfn);
+	hldev = (struct __hw_device  *) pci_get_drvdata(vdev->pdev);
+
+#ifdef CONFIG_PCI_MSI
+	if (vdev->config.intr_type == MSI_X)
+		ret = vxge_enable_msix(vdev);
+
+	if (ret) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: Enabling MSI-X Failed, ", VXGE_DRIVER_NAME);
+		if (function_mode == VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION)
+			return VXGE_HW_FAIL;
+		else {
+			vxge_debug_init(VXGE_ERR,
+				"%s: Defaulting to INTA \n", VXGE_DRIVER_NAME);
+			vdev->config.intr_type = INTA;
+			vxge_hw_device_set_intr_type(vdev->devh,
+				VXGE_HW_INTR_MODE_IRQLINE);
+			vxge_close_vpaths(vdev, 1);
+			vdev->no_of_vpath = 1;
+			vdev->stats.vpaths_open = 1;
+		}
+	}
+
+	if (vdev->config.intr_type == MSI_X) {
+		for (intr_idx = 0;
+		     intr_idx < (vdev->no_of_vpath *
+			VXGE_HW_VPATH_MSIX_ACTIVE); intr_idx++) {
+
+			msix_idx = intr_idx % VXGE_HW_VPATH_MSIX_ACTIVE;
+			irq_req = 0;
+
+			switch (msix_idx) {
+			case 0:
+				sprintf(vdev->desc[intr_cnt],
+					"%s:vxge fn: %d vpath: %d Tx MSI-X: %d",
+					vdev->ndev->name, pci_fun, vp_idx,
+					vdev->entries[intr_cnt].entry);
+				ret = request_irq(
+				    vdev->entries[intr_cnt].vector,
+					vxge_tx_msix_handle, 0,
+					vdev->desc[intr_cnt],
+					&vdev->vpaths[vp_idx].fifo);
+					vdev->vxge_entries[intr_cnt].arg =
+						&vdev->vpaths[vp_idx].fifo;
+				irq_req = 1;
+				break;
+			case 1:
+				sprintf(vdev->desc[intr_cnt],
+					"%s:vxge fn: %d vpath: %d Rx MSI-X: %d",
+					vdev->ndev->name, pci_fun, vp_idx,
+					vdev->entries[intr_cnt].entry);
+				ret = request_irq(
+				    vdev->entries[intr_cnt].vector,
+					vdev->config.napi_enable ?
+					vxge_rx_msix_napi_handle :
+					vxge_rx_msix_handle, 0,
+					vdev->desc[intr_cnt],
+					&vdev->vpaths[vp_idx].ring);
+					vdev->vxge_entries[intr_cnt].arg =
+						&vdev->vpaths[vp_idx].ring;
+				irq_req = 1;
+				break;
+			}
+
+			if (ret) {
+				vxge_debug_init(VXGE_ERR,
+					"%s: MSIX - %d  Registration failed",
+					vdev->ndev->name, intr_cnt);
+				vxge_rem_msix_isr(vdev);
+				if (function_mode ==
+					VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION)
+					return VXGE_HW_FAIL;
+				else {
+					vxge_hw_device_set_intr_type(
+						vdev->devh,
+						VXGE_HW_INTR_MODE_IRQLINE);
+						vdev->config.intr_type = INTA;
+					vxge_debug_init(VXGE_ERR,
+						"%s: Defaulting to INTA"
+						, vdev->ndev->name);
+					vxge_close_vpaths(vdev, 1);
+					vdev->no_of_vpath = 1;
+					vdev->stats.vpaths_open = 1;
+					goto INTA_MODE;
+				}
+			}
+
+			if (irq_req) {
+				/* We requested for this msix interrupt */
+				vdev->vxge_entries[intr_cnt].in_use = 1;
+				vxge_hw_vpath_msix_unmask(
+					vdev->vpaths[vp_idx].handle,
+					intr_idx);
+				intr_cnt++;
+			}
+
+			/* Point to next vpath handler */
+			if (((intr_idx + 1) % VXGE_HW_VPATH_MSIX_ACTIVE
+				== 0) && (vp_idx < (vdev->no_of_vpath - 1)))
+					vp_idx++;
+		}
+
+		intr_cnt = vdev->max_vpath_supported * 2;
+		sprintf(vdev->desc[intr_cnt],
+			"%s:vxge Alarm fn: %d MSI-X: %d",
+			vdev->ndev->name, pci_fun,
+			vdev->entries[intr_cnt].entry);
+		/* For Alarm interrupts */
+		ret = request_irq(vdev->entries[intr_cnt].vector,
+					vxge_alarm_msix_handle, 0,
+					vdev->desc[intr_cnt],
+					&vdev->vpaths[vp_idx]);
+		if (ret) {
+			vxge_debug_init(VXGE_ERR,
+				"%s: MSIX - %d Registration failed",
+				vdev->ndev->name, intr_cnt);
+			vxge_rem_msix_isr(vdev);
+			if (function_mode ==
+				VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION)
+				return VXGE_HW_FAIL;
+			else {
+				vxge_hw_device_set_intr_type(vdev->devh,
+						VXGE_HW_INTR_MODE_IRQLINE);
+				vdev->config.intr_type = INTA;
+				vxge_debug_init(VXGE_ERR,
+					"%s: Defaulting to INTA",
+					vdev->ndev->name);
+				vxge_close_vpaths(vdev, 1);
+				vdev->no_of_vpath = 1;
+				vdev->stats.vpaths_open = 1;
+				goto INTA_MODE;
+			}
+		}
+
+		vxge_hw_vpath_msix_unmask(vdev->vpaths[vp_idx].handle,
+					intr_idx - 2);
+		vdev->vxge_entries[intr_cnt].in_use = 1;
+		vdev->vxge_entries[intr_cnt].arg =
+					&vdev->vpaths[vp_idx];
+	}
+INTA_MODE:
+#endif
+	sprintf(vdev->desc[0], "%s:vxge", vdev->ndev->name);
+
+	if (vdev->config.intr_type == INTA) {
+		ret = request_irq((int) vdev->pdev->irq,
+			vdev->config.napi_enable ? vxge_isr_napi : vxge_isr,
+			IRQF_SHARED, vdev->desc[0], hldev);
+		if (ret) {
+			vxge_debug_init(VXGE_ERR,
+				"%s %s-%d: ISR registration failed",
+				VXGE_DRIVER_NAME, "IRQ",
+				vdev->pdev->irq);
+			return -ENODEV;
+		}
+		vxge_debug_init(VXGE_TRACE,
+			"new %s-%d line allocated",
+			"IRQ", vdev->pdev->irq);
+	}
+
+	return VXGE_HW_OK;
+}
+
+static void vxge_poll_vp_reset(unsigned long data)
+{
+	struct vxgedev *vdev = (struct vxgedev *)data;
+	int i, j = 0;
+
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		if (test_bit(i, &vdev->vp_reset)) {
+			vxge_reset_vpath(vdev, i);
+			j++;
+		}
+	}
+	if (j && (vdev->config.intr_type != MSI_X)) {
+		vxge_hw_device_unmask_all(vdev->devh);
+		vxge_hw_device_flush_io(vdev->devh);
+	}
+
+	mod_timer(&vdev->vp_reset_timer, jiffies + HZ / 2);
+}
+
+/*
+ * vxge_open
+ * @dev: pointer to the device structure.
+ *
+ * This function is the open entry point of the driver. It mainly calls a
+ * function to allocate Rx buffers and inserts them into the buffer
+ * descriptors and then enables the Rx part of the NIC.
+ * Return value: '0' on success and an appropriate (-)ve integer as
+ * defined in errno.h file on failure.
+ */
+int
+vxge_open(struct net_device *dev)
+{
+	enum vxge_hw_status status;
+	struct vxgedev *vdev;
+	struct __hw_device *hldev;
+	int ret = 0;
+	int i;
+	u64 val64;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d\n", dev->name,
+		__func__, __LINE__);
+
+	vdev = (struct vxgedev *)netdev_priv(dev);
+	hldev = (struct __hw_device *) pci_get_drvdata(vdev->pdev);
+
+	/* make sure you have link off by default every time Nic is
+	 * initialized */
+	netif_carrier_off(dev);
+
+	/* Open VPATHs */
+	status = vxge_open_vpaths(vdev);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: fatal: Vpath open failed",
+			vdev->ndev->name);
+		ret = -EPERM;
+		goto out0;
+	}
+
+	vdev->mtu = dev->mtu;
+
+	status = vxge_add_isr(vdev);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: fatal: ISR add failed",
+			dev->name);
+		ret = -EPERM;
+		goto out1;
+	}
+
+#if defined(HAVE_NETDEV_POLL)
+	/* Initialize napi */
+	if (vdev->config.napi_enable) {
+
+		if (vdev->config.intr_type != MSI_X) {
+			netif_napi_add(dev, &vdev->napi, vxge_poll_inta,
+				vdev->config.napi_weight);
+			napi_enable(&vdev->napi);
+		} else {
+			for (i = 0; i < vdev->no_of_vpath; i++) {
+				netif_napi_add(dev, &vdev->vpaths[i].ring.napi,
+				    vxge_poll_msix, vdev->config.napi_weight);
+				napi_enable(&vdev->vpaths[i].ring.napi);
+			}
+		}
+
+	}
+#endif
+
+	/* configure RTH */
+	if (vdev->config.rth_steering) {
+		status = vxge_rth_configure(vdev);
+		if (status != VXGE_HW_OK) {
+			vxge_debug_init(VXGE_ERR,
+				"%s: fatal: RTH configuration failed",
+				dev->name);
+			ret = -EPERM;
+			goto out2;
+		}
+	}
+
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		/* set initial mtu before enabling the device */
+		status = vxge_hw_vpath_mtu_set(vdev->vpaths[i].handle,
+						vdev->mtu);
+		if (status != VXGE_HW_OK) {
+			vxge_debug_init(VXGE_ERR,
+				"%s: fatal: can not set new MTU",
+				dev->name);
+			ret = -EPERM;
+			goto out2;
+		}
+	}
+
+	VXGE_DEVICE_DEBUG_LEVEL_SET(VXGE_TRACE, VXGE_COMPONENT_LL, vdev);
+	vxge_debug_init(vdev->level_trace,
+		"%s: MTU is %d", vdev->ndev->name, vdev->mtu);
+	VXGE_DEVICE_DEBUG_LEVEL_SET(VXGE_ERR, VXGE_COMPONENT_LL, vdev);
+
+	/* Reprogram the DA table with populated mac addresses */
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		vxge_restore_vpath_mac_addr(&vdev->vpaths[i]);
+		vxge_restore_vpath_vid_table(&vdev->vpaths[i]);
+	}
+
+	/* Enable vpath to sniff all unicast/multicast traffic that not
+	 * addressed to them. We allow promiscous mode for PF only
+	 */
+
+	val64 = 0;
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++)
+		val64 |= VXGE_HW_RXMAC_AUTHORIZE_ALL_ADDR_VP(i);
+
+	vxge_hw_mgmt_reg_write(vdev->devh,
+		vxge_hw_mgmt_reg_type_mrpcim,
+		0,
+		(ulong_t)vxge_offsetof(struct vxge_hw_mrpcim_reg,
+			rxmac_authorize_all_addr),
+		val64);
+
+	vxge_hw_mgmt_reg_write(vdev->devh,
+		vxge_hw_mgmt_reg_type_mrpcim,
+		0,
+		(ulong_t)vxge_offsetof(struct vxge_hw_mrpcim_reg,
+			rxmac_authorize_all_vid),
+		val64);
+
+	vxge_set_multicast(dev);
+
+	/* Enabling Bcast and mcast for all vpath */
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+
+		status = vxge_hw_vpath_bcast_enable(vdev->vpaths[i].handle);
+		if (status != VXGE_HW_OK)
+			vxge_debug_init(VXGE_ERR,
+				"%s : Can not enable bcast for vpath \
+				id %d \n", dev->name, i);
+#if defined(CONFIG_XEN)
+		status = vxge_hw_vpath_mcast_enable(vdev->vpaths[i].handle);
+		if (status != VXGE_HW_OK)
+			vxge_debug_init(VXGE_ERR,
+				"%s : Can not enable mcast for vpath \
+				id %d \n", dev->name, i);
+#endif
+	}
+
+	vxge_hw_device_setpause_data(vdev->devh, 0,
+		vdev->config.tx_pause_enable,
+		vdev->config.rx_pause_enable);
+
+	if (vdev->vp_reset_timer.function == NULL)
+		vxge_os_timer(vdev->vp_reset_timer,
+			vxge_poll_vp_reset, vdev, (HZ/2));
+
+	set_bit(__VXGE_STATE_CARD_UP, &vdev->state);
+
+	smp_wmb();
+
+	if (vxge_hw_device_link_state_get(vdev->devh) == VXGE_HW_LINK_UP) {
+		netif_carrier_on(vdev->ndev);
+		printk(KERN_NOTICE "%s: Link Up \n", vdev->ndev->name);
+		vdev->stats.link_up++;
+	}
+
+	vxge_hw_device_intr_enable(vdev->devh);
+
+	smp_wmb();
+
+	for (i = 0; i < vdev->no_of_vpath; i++)
+		vxge_hw_vpath_enable(vdev->vpaths[i].handle);
+
+	vxge_start_all_tx_queue(vdev);
+
+	goto out0;
+
+out2:
+	vxge_rem_isr(vdev);
+
+	/* Disable napi */
+	if (vdev->config.napi_enable) {
+		if (vdev->config.intr_type != MSI_X)
+			napi_disable(&vdev->napi);
+		else {
+			for (i = 0; i < vdev->no_of_vpath; i++)
+				napi_disable(&vdev->vpaths[i].ring.napi);
+		}
+
+	}
+
+out1:
+	vxge_close_vpaths(vdev, 0);
+out0:
+	vxge_debug_entryexit(VXGE_TRACE,
+				"%s: %s:%d  Exiting...\n",
+				dev->name, __func__, __LINE__);
+	return ret;
+}
+
+/* Loop throught the mac address list and delete all the entries */
+void vxge_free_mac_add_list(struct vxge_vpath *vpath)
+{
+
+	struct vxge_list *entry, *next;
+	if (vxge_list_is_empty(&vpath->mac_addr_list))
+		return;
+
+	vxge_list_for_each_safe(entry, next, &vpath->mac_addr_list) {
+		vxge_list_remove(entry);
+		kfree((struct vxge_mac_addrs *)entry);
+	}
+}
+
+void vxge_napi_del_all(struct vxgedev *vdev)
+{
+	int i;
+	if (vdev->config.intr_type != MSI_X)
+		netif_napi_del(&vdev->napi);
+	else {
+		for (i = 0; i < vdev->no_of_vpath; i++)
+			netif_napi_del(&vdev->vpaths[i].ring.napi);
+	}
+	return;
+}
+
+int do_vxge_close(struct net_device *dev, int do_io)
+{
+	enum vxge_hw_status status;
+	struct vxgedev *vdev;
+	struct __hw_device *hldev;
+	int i;
+	u64 val64, vpath_vector;
+	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d\n",
+		dev->name, __func__, __LINE__);
+	vxge_assert(dev);
+	vxge_assert(netdev_priv(dev));
+
+	vdev = (struct vxgedev *)netdev_priv(dev);
+	hldev = (struct __hw_device *) pci_get_drvdata(vdev->pdev);
+
+	/* If vxge_handle_crit_err task is executing,
+	 * wait till it completes. */
+	while (test_and_set_bit(__VXGE_STATE_RESET_CARD, &vdev->state))
+		msleep(50);
+
+	clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
+	if (do_io) {
+		/* Put the vpath back in normal mode */
+		vpath_vector = vxge_mBIT(vdev->vpaths[0].device_id);
+		status = vxge_hw_mgmt_reg_read(vdev->devh,
+				vxge_hw_mgmt_reg_type_mrpcim,
+				0,
+				(ulong_t)vxge_offsetof(
+					struct vxge_hw_mrpcim_reg,
+					rts_mgr_cbasin_cfg),
+				&val64);
+
+		if (status == VXGE_HW_OK) {
+			val64 &= ~vpath_vector;
+			status = vxge_hw_mgmt_reg_write(vdev->devh,
+					vxge_hw_mgmt_reg_type_mrpcim,
+					0,
+					(ulong_t)vxge_offsetof(
+						struct vxge_hw_mrpcim_reg,
+						rts_mgr_cbasin_cfg),
+					val64);
+		}
+
+		/* Remove the function 0 from promiscous mode */
+		vxge_hw_mgmt_reg_write(vdev->devh,
+			vxge_hw_mgmt_reg_type_mrpcim,
+			0,
+			(ulong_t)vxge_offsetof(struct vxge_hw_mrpcim_reg,
+				rxmac_authorize_all_addr),
+			0);
+
+		vxge_hw_mgmt_reg_write(vdev->devh,
+			vxge_hw_mgmt_reg_type_mrpcim,
+			0,
+			(ulong_t)vxge_offsetof(struct vxge_hw_mrpcim_reg,
+				rxmac_authorize_all_vid),
+			0);
+
+		smp_wmb();
+	}
+
+	del_timer_sync(&vdev->vp_reset_timer);
+
+	/* Disable napi */
+	if (vdev->config.napi_enable) {
+		if (vdev->config.intr_type != MSI_X)
+			napi_disable(&vdev->napi);
+		else {
+			for (i = 0; i < vdev->no_of_vpath; i++)
+				napi_disable(
+						&vdev->vpaths[i].ring.napi);
+		}
+	}
+
+	netif_carrier_off(vdev->ndev);
+	printk(KERN_NOTICE "%s: Link Down\n", vdev->ndev->name);
+	vxge_stop_all_tx_queue(vdev);
+
+	/* Note that at this point xmit() is stopped by upper layer */
+	if (do_io)
+		vxge_hw_device_intr_disable(vdev->devh);
+
+	mdelay(1000);
+
+	vxge_rem_isr(vdev);
+
+	vxge_napi_del_all(vdev);
+
+	if (do_io)
+		vxge_reset_all_vpaths(vdev);
+
+	vxge_close_vpaths(vdev, 0);
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\n",
+		dev->name, __func__, __LINE__);
+
+	clear_bit(__VXGE_STATE_RESET_CARD, &vdev->state);
+
+	return 0;
+}
+
+/*
+ * vxge_close
+ * @dev: device pointer.
+ *
+ * This is the stop entry point of the driver. It needs to undo exactly
+ * whatever was done by the open entry point, thus it's usually referred to
+ * as the close function.Among other things this function mainly stops the
+ * Rx side of the NIC and frees all the Rx buffers in the Rx rings.
+ * Return value: '0' on success and an appropriate (-)ve integer as
+ * defined in errno.h file on failure.
+ */
+int
+vxge_close(struct net_device *dev)
+{
+	do_vxge_close(dev, 1);
+	return 0;
+}
+
+/*
+ * vxge_change_mtu
+ * @dev: net device pointer.
+ * @new_mtu :the new MTU size for the device.
+ *
+ * A driver entry point to change MTU size for the device. Before changing
+ * the MTU the device must be stopped.
+ */
+int vxge_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct vxgedev *vdev = netdev_priv(dev);
+
+	vxge_debug_entryexit(vdev->level_trace,
+		"%s:%d\n", __func__, __LINE__);
+	if ((new_mtu < MIN_MTU) || (new_mtu > MAX_PYLD_JUMBO)) {
+		vxge_debug_init(vdev->level_err,
+			"%s: mtu size is invalid", dev->name);
+		return -EPERM;
+	}
+
+	/* check if device is down already */
+	if (unlikely(!is_vxge_card_up(vdev))) {
+		/* just store new value, will use later on open() */
+		dev->mtu = new_mtu;
+		vxge_debug_init(vdev->level_err,
+			"%s", "device is down on MTU change");
+		return 0;
+	}
+
+	vxge_debug_init(vdev->level_trace,
+		"trying to apply new MTU %d\n", new_mtu);
+
+	if (vxge_close(dev))
+		return -EIO;
+
+	dev->mtu = new_mtu;
+	vdev->mtu = new_mtu;
+
+	if (vxge_open(dev))
+		return -EIO;
+
+	vxge_debug_init(vdev->level_trace,
+		"%s: MTU changed to %d\n", vdev->ndev->name, new_mtu);
+
+	vxge_debug_entryexit(vdev->level_trace,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+
+	return 0;
+}
+
+/*
+ * vxge_get_stats
+ * @dev: pointer to the device structure
+ *
+ * Updates the device statistics structure. This function updates the device
+ * statistics structure in the net_device structure and returns a pointer
+ * to the same.
+ */
+struct net_device_stats *
+vxge_get_stats(struct net_device *dev)
+{
+	struct vxgedev *vdev;
+	struct net_device_stats *net_stats;
+	int k;
+
+	vxge_assert(dev && netdev_priv(dev));
+	vdev = netdev_priv(dev);
+
+	net_stats = &vdev->stats.net_stats;
+
+	memset(net_stats, 0, sizeof(struct net_device_stats));
+
+	for (k = 0; k < vdev->no_of_vpath; k++) {
+		net_stats->rx_packets += vdev->vpaths[k].ring.stats.rx_frms;
+		net_stats->rx_bytes += vdev->vpaths[k].ring.stats.rx_bytes;
+		net_stats->rx_errors += vdev->vpaths[k].ring.stats.rx_errors;
+		net_stats->multicast += vdev->vpaths[k].ring.stats.rx_mcast;
+		net_stats->rx_dropped +=
+			vdev->vpaths[k].ring.stats.rx_dropped;
+
+		net_stats->tx_packets += vdev->vpaths[k].fifo.stats.tx_frms;
+		net_stats->tx_bytes += vdev->vpaths[k].fifo.stats.tx_bytes;
+		net_stats->tx_errors += vdev->vpaths[k].fifo.stats.tx_errors;
+	}
+
+	return net_stats;
+}
+
+/*
+ * vxge_ioctl
+ * @dev: Device pointer.
+ * @ifr: An IOCTL specefic structure, that can contain a pointer to
+ *       a proprietary structure used to pass information to the driver.
+ * @cmd: This is used to distinguish between the different commands that
+ *       can be passed to the IOCTL functions.
+ *
+ * Entry point for the Ioctl.
+ * This function has support for ethtool, adding multiple MAC addresses on
+ * the NIC and some DBG commands for the util tool.
+ */
+int vxge_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+
+		return -EOPNOTSUPP;
+
+}
+
+/*
+ * vxge_tx_watchdog
+ * @dev: pointer to net device structure
+ *
+ * Watchdog for transmit side.
+ * This function is triggered if the Tx Queue is stopped
+ * for a pre-defined amount of time when the Interface is still up.
+ */
+static void
+vxge_tx_watchdog(struct net_device *dev)
+{
+	struct vxgedev *vdev;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+	vxge_assert(dev);
+	vxge_assert(netdev_priv(dev));
+
+	vdev = (struct vxgedev *)netdev_priv(dev);
+
+	vdev->cric_err_event.type = VXGE_HW_EVENT_RESET_START;
+	vdev->cric_err_event.vp_id = 0;
+
+	vxge_reset(vdev);
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+}
+
+static void
+vxge_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
+{
+	struct vxgedev *vdev;
+	struct vxge_vpath *vpath;
+	int vp;
+	u64 vid;
+	enum vxge_hw_status status;
+	int i;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+	vxge_assert(dev);
+	vxge_assert(netdev_priv(dev));
+
+	vdev = (struct vxgedev *)netdev_priv(dev);
+
+	vpath = &vdev->vpaths[0];
+	if ((NULL == grp) && (vpath->is_open)) {
+		/* Get the first vlan */
+		status = vxge_hw_vpath_vid_get(vpath->handle, &vid);
+
+		while (status == VXGE_HW_OK) {
+
+			/* Delete this vlan from the vid table */
+			for (vp = 0; vp < vdev->no_of_vpath; vp++) {
+				vpath = &vdev->vpaths[vp];
+				if (!vpath->is_open)
+					continue;
+
+				vxge_hw_vpath_vid_delete(vpath->handle, vid);
+			}
+
+			/* Get the next vlan to be deleted */
+			vpath = &vdev->vpaths[0];
+			status = vxge_hw_vpath_vid_get(vpath->handle, &vid);
+		}
+	}
+
+	vdev->vlgrp = grp;
+
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		if (vdev->vpaths[i].is_configured)
+			vdev->vpaths[i].ring.vlgrp = grp;
+	}
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+}
+
+static void
+vxge_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+{
+	struct vxgedev *vdev;
+	struct vxge_vpath *vpath;
+	int vp_id;
+
+	vxge_assert(dev);
+	vxge_assert(netdev_priv(dev));
+
+	vdev = (struct vxgedev *)netdev_priv(dev);
+
+	/* Add these vlan to the vid table */
+	for (vp_id = 0; vp_id < vdev->no_of_vpath; vp_id++) {
+		vpath = &vdev->vpaths[vp_id];
+		if (!vpath->is_open)
+			continue;
+		vxge_hw_vpath_vid_add(vpath->handle, vid);
+	}
+}
+
+static void
+vxge_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+{
+	struct vxgedev *vdev;
+	struct vxge_vpath *vpath;
+	int vp_id;
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+	vxge_assert(dev);
+	vxge_assert(netdev_priv(dev));
+
+	vdev = (struct vxgedev *)netdev_priv(dev);
+
+	vlan_group_set_device(vdev->vlgrp, vid, NULL);
+
+	/* Delete this vlan from the vid table */
+	for (vp_id = 0; vp_id < vdev->no_of_vpath; vp_id++) {
+		vpath = &vdev->vpaths[vp_id];
+		if (!vpath->is_open)
+			continue;
+		vxge_hw_vpath_vid_delete(vpath->handle, vid);
+	}
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+}
+
+static const struct net_device_ops vxge_netdev_ops = {
+	.ndo_open               = vxge_open,
+	.ndo_stop               = vxge_close,
+	.ndo_get_stats          = vxge_get_stats,
+	.ndo_start_xmit         = vxge_xmit,
+	.ndo_validate_addr      = eth_validate_addr,
+	.ndo_set_multicast_list = vxge_set_multicast,
+
+	.ndo_do_ioctl           = vxge_ioctl,
+
+	.ndo_set_mac_address    = vxge_set_mac_addr,
+	.ndo_change_mtu         = vxge_change_mtu,
+	.ndo_vlan_rx_register   = vxge_vlan_rx_register,
+	.ndo_vlan_rx_kill_vid   = vxge_vlan_rx_kill_vid,
+	.ndo_vlan_rx_add_vid	= vxge_vlan_rx_add_vid,
+
+	.ndo_tx_timeout         = vxge_tx_watchdog,
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller    = vxge_netpoll,
+#endif
+};
+
+int vxge_device_register(struct __hw_device *devh,
+			struct vxge_config *config,
+			int high_dma, int no_of_vpath,
+			struct vxgedev **vdev_out)
+{
+	struct net_device *ndev;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_device  *hldev = (struct __hw_device  *)devh;
+	struct vxgedev *vdev;
+	int i, ret = 0;
+	*vdev_out = NULL;
+	ndev = vxge_alloc_etherdev(sizeof(struct vxgedev),
+			no_of_vpath, config->tx_steering_type);
+	if (ndev == NULL) {
+		vxge_debug_init(
+			vxge_hw_device_trace_level_get(hldev),
+		"%s : device allocation failed", __func__);
+		ret = -ENODEV;
+		goto _out0;
+	}
+
+	vxge_debug_entryexit(
+		vxge_hw_device_trace_level_get(hldev),
+		"%s: %s:%d  Entering...",
+		ndev->name, __func__, __LINE__);
+
+	vdev = netdev_priv(ndev);
+	memset(vdev, 0, sizeof(struct vxgedev));
+
+	vdev->ndev = ndev;
+	vdev->devh = devh;
+	vdev->pdev = hldev->pdev;
+	memcpy(&vdev->config, config, sizeof(struct vxge_config));
+	vdev->rx_csum = 1;	/* Enable Rx CSUM by default. */
+
+	SET_NETDEV_DEV(ndev, &vdev->pdev->dev);
+
+	ndev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
+				NETIF_F_HW_VLAN_FILTER;
+	/*  Driver entry points */
+	ndev->irq = vdev->pdev->irq;
+	ndev->base_addr = (unsigned long) hldev->bar0;
+
+	ndev->netdev_ops = &vxge_netdev_ops;
+
+	ndev->watchdog_timeo = VXGE_LL_WATCH_DOG_TIMEOUT;
+
+	initialize_ethtool_ops(ndev);
+
+	/* Allocate memory for vpath */
+	vdev->vpaths = kzalloc((sizeof(struct vxge_vpath)) *
+				no_of_vpath, GFP_KERNEL);
+	if (!vdev->vpaths) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: vpath memory allocation failed",
+			vdev->ndev->name);
+		ret = -ENODEV;
+		goto _out1;
+	}
+
+	ndev->features |= NETIF_F_SG;
+
+	if (vdev->config.cksum_offload_enable) {
+		ndev->features |= NETIF_F_HW_CSUM;
+		vxge_debug_init(
+			vxge_hw_device_trace_level_get(hldev),
+			"%s : checksuming enabled", __func__);
+	}
+
+	if (high_dma) {
+		ndev->features |= NETIF_F_HIGHDMA;
+		vxge_debug_init(
+			vxge_hw_device_trace_level_get(hldev),
+			"%s : using High DMA", __func__);
+	}
+
+	if (vdev->config.tso_enable)
+		ndev->features |= NETIF_F_TSO;
+
+	if (vdev->config.tso_enable)
+		ndev->features |= NETIF_F_TSO6;
+
+	if (vdev->config.lro_enable)
+		ndev->features |= NETIF_F_LRO;
+
+	if (vdev->config.tx_steering_type == TX_MULTIQ_STEERING)
+		ndev->real_num_tx_queues = no_of_vpath;
+
+#ifdef NETIF_F_LLTX
+	ndev->features |= NETIF_F_LLTX;
+#endif
+
+	for (i = 0; i < no_of_vpath; i++)
+		spin_lock_init(&vdev->vpaths[i].fifo.tx_lock);
+
+	if (register_netdev(ndev)) {
+		vxge_debug_init(
+			vxge_hw_device_trace_level_get(hldev),
+			"%s: %s : device registration failed!",
+			ndev->name, __func__);
+		ret = -ENODEV;
+		goto _out2;
+	}
+
+	/*  Set the factory defined MAC address initially */
+	ndev->addr_len = ETH_ALEN;
+
+	/* Make Link state as off at this point, when the Link change
+	 * interrupt comes the state will be automatically changed to
+	 * the right state.
+	 */
+	netif_carrier_off(ndev);
+
+	vxge_debug_init(
+		vxge_hw_device_trace_level_get(hldev),
+		"%s: Ethernet device registered",
+		ndev->name);
+
+	*vdev_out = vdev;
+	/* Resetting the Device stats */
+	status = vxge_hw_device_stats_clear(vdev->devh);
+	if (status == VXGE_HW_ERR_PRIVILAGED_OPEARATION)
+		vxge_debug_init(
+			vxge_hw_device_trace_level_get(hldev),
+			"%s: vxge_hw_device_stats_clear returns"\
+			"VXGE_HW_ERR_PRIVILAGED_OPEARATION", ndev->name);
+
+	vxge_debug_entryexit(
+		vxge_hw_device_trace_level_get(hldev),
+		"%s: %s:%d  Exiting...",
+		ndev->name, __func__, __LINE__);
+
+	return ret;
+_out2:
+	kfree(vdev->vpaths);
+_out1:
+	free_netdev(ndev);
+_out0:
+	return ret;
+}
+
+/*
+ * vxge_device_unregister
+ * @uld_info: pointer on private device info
+ *
+ * This function will unregister and free network device
+ */
+void
+vxge_device_unregister(struct __hw_device *devh)
+{
+	struct __hw_device  *hldev = (struct __hw_device  *)devh;
+	struct vxgedev *vdev;
+	struct net_device *dev;
+	char buf[IFNAMSIZ];
+#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
+	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
+	u32 level_trace;
+#endif
+
+	dev = vxge_hw_device_private_get(hldev);
+	vdev = netdev_priv(dev);
+#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
+	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
+	level_trace = vdev->level_trace;
+#endif
+	vxge_debug_entryexit(level_trace,
+		"%s: %s:%d\n", vdev->ndev->name,
+		__func__, __LINE__);
+
+	memcpy(buf, vdev->ndev->name, IFNAMSIZ);
+
+	/* in 2.6 will call stop() if device is up */
+	unregister_netdev(dev);
+
+	flush_scheduled_work();
+
+	vxge_debug_init(level_trace,
+		"%s: ethernet device unregistered", buf);
+	vxge_debug_entryexit(level_trace,
+		"%s: %s:%d  Exiting...\n",
+		buf, __func__, __LINE__);
+}
+
+/*
+ * vxge_callback_crit_err
+ *
+ * This function is called by the alarm handler in interrupt context.
+ * Driver must analyze it based on the event type.
+ */
+void
+vxge_callback_crit_err(struct __hw_device *devh, void *userdata,
+			enum vxge_hw_event type, u64 vp_id)
+{
+	struct net_device *dev = (struct net_device *)userdata;
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	int vpath_idx;
+
+	vxge_debug_entryexit(vdev->level_trace,
+		"%s: %s:%d\n",
+		vdev->ndev->name, __func__, __LINE__);
+
+	/* Note: This event type should be used for device wide
+	 * indications only - Serious errors, Slot freeze and critical errors
+	 */
+	vdev->cric_err_event.type = type;
+
+	/* FIX ME !!! Remove this variable */
+	vdev->cric_err_event.vp_id = vp_id;
+
+	for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath; vpath_idx++)
+		if (vdev->vpaths[vpath_idx].device_id == vp_id)
+			break;
+
+	if (!test_bit(__VXGE_STATE_RESET_CARD, &vdev->state)) {
+		if (type == VXGE_HW_EVENT_SLOT_FREEZE) {
+			vxge_debug_init(VXGE_ERR,
+				"%s: Slot is frozen\n", vdev->ndev->name);
+		} else if (type == VXGE_HW_EVENT_SERR) {
+			vxge_debug_init(VXGE_ERR,
+				"%s: Encountered Serious Error\n",
+				vdev->ndev->name);
+		} else if (type == VXGE_HW_EVENT_CRITICAL_ERR)
+			vxge_debug_init(VXGE_ERR,
+				"%s: Encountered Critical Error\n",
+				vdev->ndev->name);
+	}
+
+	if ((type == VXGE_HW_EVENT_SERR) ||
+		(type == VXGE_HW_EVENT_SLOT_FREEZE)) {
+		if (unlikely(vdev->exec_mode))
+			clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
+	} else if (type == VXGE_HW_EVENT_CRITICAL_ERR) {
+		vxge_hw_device_mask_all(devh);
+		if (unlikely(vdev->exec_mode))
+			clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
+	} else if ((type == VXGE_HW_EVENT_FIFO_ERR) ||
+		  (type == VXGE_HW_EVENT_VPATH_ERR)) {
+
+		if (unlikely(vdev->exec_mode))
+			clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
+		else {
+			/* check if this vpath is already set for reset */
+			if (!test_and_set_bit(vpath_idx, &vdev->vp_reset)) {
+
+				/* disable interrupts for this vpath */
+				vxge_vpath_intr_disable(vdev, vpath_idx);
+
+				/* stop the queue for this vpath */
+				vxge_stop_tx_queue(&vdev->vpaths[vpath_idx].
+							fifo);
+			}
+		}
+	}
+
+	vxge_debug_entryexit(vdev->level_trace,
+		"%s: %s:%d  Exiting...\n",
+		vdev->ndev->name, __func__, __LINE__);
+}
+
+void verify_bandwidth(void)
+{
+	int i, band_width, total = 0, equal_priority = 0;
+
+	/* 1. If user enters 0 for some fifo, give equal priority to all */
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		if (bw_percentage[i] == 0) {
+			equal_priority = 1;
+			break;
+		}
+	}
+
+	if (!equal_priority) {
+		/* 2. If sum exceeds 100, give equal priority to all */
+		for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+			if (bw_percentage[i] == 0xFF)
+				break;
+
+			total += bw_percentage[i];
+			if (total > VXGE_HW_VPATH_BANDWIDTH_MAX) {
+				equal_priority = 1;
+				break;
+			}
+		}
+	}
+
+	if (!equal_priority) {
+		/* Is all the bandwidth consumed? */
+		if (total < VXGE_HW_VPATH_BANDWIDTH_MAX) {
+			if (i < VXGE_HW_MAX_VIRTUAL_PATHS) {
+				/* Split rest of bw equally among next VPs*/
+				band_width =
+				  (VXGE_HW_VPATH_BANDWIDTH_MAX  - total) /
+					(VXGE_HW_MAX_VIRTUAL_PATHS - i);
+				if (band_width < 2)
+					equal_priority = 1;
+				else {
+					for (; i < VXGE_HW_MAX_VIRTUAL_PATHS;
+						i++)
+						bw_percentage[i] =
+							band_width;
+				}
+			}
+		} else if (i < VXGE_HW_MAX_VIRTUAL_PATHS)
+			equal_priority = 1;
+	}
+
+	if (equal_priority) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: Assigning equal bandwidth to all the vpaths",
+			VXGE_DRIVER_NAME);
+		bw_percentage[0] = 100 / VXGE_HW_MAX_VIRTUAL_PATHS;
+		for (i = 1; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++)
+			bw_percentage[i] = bw_percentage[0];
+	}
+
+	return;
+}
+
+/*
+ * Vpath configuration
+ */
+static int vxge_config_vpaths(struct vxge_hw_device_config *device_config,
+				u64 vpath_mask)
+{
+	int i, no_of_vpaths = 0, default_no_vpath = 0, temp;
+	u32 txdl_size, txdl_per_memblock;
+
+	temp = vpath_per_dev;
+	if ((vpath_per_dev == VXGE_USE_DEFAULT) &&
+		(max_config_dev == VXGE_MAX_CONFIG_DEV)) {
+		if (intr_type == MSI_X) {
+			if (netq)
+				vpath_per_dev = VXGE_HW_MAX_VIRTUAL_PATHS;
+			else {
+
+				/* No more CPU. Return vpath number as zero.*/
+				if (g_no_cpus == -1)
+					return 0;
+
+				if (!g_no_cpus)
+					g_no_cpus = num_online_cpus();
+
+				vpath_per_dev = g_no_cpus >> 1;
+				/* Uniprocessor system check? */
+				if (!vpath_per_dev)
+					vpath_per_dev = 1;
+
+				for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++)
+					if (!bVAL1(vpath_mask, i))
+						continue;
+					else
+						default_no_vpath++;
+				if (default_no_vpath < vpath_per_dev)
+					vpath_per_dev = default_no_vpath;
+
+				/* If both tx_steering and Rx_steering are
+				   disabled, enable only one Vpath */
+				if ((!tx_steering_type &&
+					(rx_steering_type != RTH_STEERING) &&
+					!addr_learn_en)) {
+					vpath_per_dev = 1;
+					vxge_debug_ll_config(VXGE_TRACE,
+						"%s: Configuring single vpath,\
+						as transmit ans receive \
+						steering is disabled",
+						VXGE_DRIVER_NAME);
+				}
+
+				g_no_cpus = g_no_cpus -  (vpath_per_dev * 2);
+				if (g_no_cpus <= 0)
+					g_no_cpus = -1;
+
+			}
+		} else if (
+
+		(intr_type == INTA))
+			vpath_per_dev = 1;
+		else
+			vxge_assert(0);
+	}
+
+	if (
+
+	(vpath_per_dev == 1)) {
+		vxge_debug_ll_config(VXGE_TRACE,
+			"%s: Disable transmit ans receive steering, \
+			as single vpath is configured", VXGE_DRIVER_NAME);
+		rx_steering_type = 0;
+		tx_steering_type = 0;
+		device_config->rth_en = 0;
+	}
+
+	/* configure bandwidth */
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++)
+		device_config->vp_config[i].min_bandwidth = bw_percentage[i];
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		device_config->vp_config[i].vp_id = i;
+		device_config->vp_config[i].mtu = VXGE_HW_DEFAULT_MTU;
+		if (no_of_vpaths < vpath_per_dev) {
+			if (!bVAL1(vpath_mask, i)) {
+				vxge_debug_ll_config(VXGE_TRACE,
+					"%s: vpath: %d is not available",
+					VXGE_DRIVER_NAME, i);
+				continue;
+			} else {
+				vxge_debug_ll_config(VXGE_TRACE,
+					"%s: vpath: %d available",
+					VXGE_DRIVER_NAME, i);
+				no_of_vpaths++;
+			}
+		} else {
+			vxge_debug_ll_config(VXGE_TRACE,
+				"%s: vpath: %d is not configured, \
+				max_config_vpath exceeded",
+				VXGE_DRIVER_NAME, i);
+			break;
+		}
+
+		/* Configure Tx fifo's */
+		device_config->vp_config[i].fifo.enable =
+						VXGE_HW_FIFO_ENABLE;
+		device_config->vp_config[i].fifo.max_frags =
+				MAX_SKB_FRAGS;
+		device_config->vp_config[i].fifo.memblock_size =
+			VXGE_HW_MIN_FIFO_MEMBLOCK_SIZE;
+
+		txdl_size = MAX_SKB_FRAGS * sizeof(struct vxge_hw_fifo_txd);
+		txdl_per_memblock = VXGE_HW_MIN_FIFO_MEMBLOCK_SIZE / txdl_size;
+
+		device_config->vp_config[i].fifo.fifo_blocks =
+			((fifo_length - 1) / txdl_per_memblock) + 1;
+
+		device_config->vp_config[i].fifo.intr =
+				VXGE_HW_FIFO_QUEUE_INTR_DISABLE;
+
+		/* Configure tti properties */
+		device_config->vp_config[i].tti.intr_enable =
+					VXGE_HW_TIM_INTR_ENABLE;
+
+		device_config->vp_config[i].tti.btimer_val =
+			(VXGE_TTI_BTIMER_VAL * 1000) / 272;
+
+		device_config->vp_config[i].tti.timer_ac_en =
+				VXGE_HW_TIM_TIMER_AC_ENABLE;
+
+		/* For Inta (with or without napi),
+		Set CI ON for only one vpath.
+		(Have only one free running timer)
+		*/
+		if (intr_type == INTA) {
+			if (i == 0)
+				device_config->vp_config[i].tti.timer_ci_en =
+					VXGE_HW_TIM_TIMER_CI_ENABLE;
+			else
+				device_config->vp_config[i].tti.timer_ci_en =
+					VXGE_HW_TIM_TIMER_CI_DISABLE;
+		} else {
+			if (napi) {
+				/* For msi-x with new napi (each vector
+				has a handler of its own) -
+				Set CI to OFF for all vpaths */
+				device_config->vp_config[i].tti.timer_ci_en =
+					VXGE_HW_TIM_TIMER_CI_DISABLE;
+
+				/* For msi-x with old napi, Set CI ON for
+				only one vpath (single free running timer) */
+
+			}
+		}
+
+		device_config->vp_config[i].tti.timer_ri_en =
+				VXGE_HW_TIM_TIMER_RI_DISABLE;
+
+		device_config->vp_config[i].tti.util_sel =
+			VXGE_HW_TIM_UTIL_SEL_LEGACY_TX_NET_UTIL;
+
+		device_config->vp_config[i].tti.ltimer_val =
+			(VXGE_TTI_LTIMER_VAL * 1000) / 272;
+
+		device_config->vp_config[i].tti.rtimer_val =
+			(VXGE_TTI_RTIMER_VAL * 1000) / 272;
+
+		device_config->vp_config[i].tti.urange_a = TTI_TX_URANGE_A;
+
+		device_config->vp_config[i].tti.urange_b = TTI_TX_URANGE_B;
+
+		device_config->vp_config[i].tti.urange_c = TTI_TX_URANGE_C;
+
+		device_config->vp_config[i].tti.uec_a = TTI_TX_UFC_A;
+
+		device_config->vp_config[i].tti.uec_b = TTI_TX_UFC_B;
+
+		device_config->vp_config[i].tti.uec_c = TTI_TX_UFC_C;
+
+		device_config->vp_config[i].tti.uec_d = TTI_TX_UFC_D;
+
+		/* Configure Rx rings */
+		device_config->vp_config[i].ring.enable  =
+						VXGE_HW_RING_ENABLE;
+
+		device_config->vp_config[i].ring.ring_blocks  = ring_blocks;
+		device_config->vp_config[i].ring.buffer_mode =
+			VXGE_HW_RING_RXD_BUFFER_MODE_1;
+
+		device_config->vp_config[i].ring.scatter_mode =
+					VXGE_HW_RING_SCATTER_MODE_A;
+
+		device_config->vp_config[i].ring.indicate_max_pkts =
+				ring_indicate_max_pkts;
+
+		/* Bounds check of indicate max packets */
+		if (device_config->vp_config[i].ring.indicate_max_pkts >
+			VXGE_HW_MAX_RING_INDICATE_MAX_PKTS) {
+			device_config->vp_config[i].ring.indicate_max_pkts =
+				VXGE_HW_MAX_RING_INDICATE_MAX_PKTS;
+			vxge_debug_ll_config(VXGE_TRACE,
+				"vxge_hw_device_initialize:\
+				indicate max packets = %d",
+				device_config->vp_config[i].ring.
+					indicate_max_pkts);
+		}
+
+		/* Configure rti properties */
+		device_config->vp_config[i].rti.intr_enable =
+					VXGE_HW_TIM_INTR_ENABLE;
+
+		device_config->vp_config[i].rti.btimer_val =
+			(VXGE_RTI_BTIMER_VAL * 1000)/272;
+
+		device_config->vp_config[i].rti.timer_ac_en =
+						VXGE_HW_TIM_TIMER_AC_ENABLE;
+
+		device_config->vp_config[i].rti.timer_ci_en =
+						VXGE_HW_TIM_TIMER_CI_DISABLE;
+
+		device_config->vp_config[i].rti.timer_ri_en =
+						VXGE_HW_TIM_TIMER_RI_DISABLE;
+
+		device_config->vp_config[i].rti.util_sel =
+				VXGE_HW_TIM_UTIL_SEL_LEGACY_RX_NET_UTIL;
+
+		device_config->vp_config[i].rti.urange_a =
+						RTI_RX_URANGE_A;
+
+		device_config->vp_config[i].rti.urange_b =
+						RTI_RX_URANGE_B;
+
+		device_config->vp_config[i].rti.urange_c =
+						RTI_RX_URANGE_C;
+
+		device_config->vp_config[i].rti.uec_a = RTI_RX_UFC_A;
+
+		device_config->vp_config[i].rti.uec_b = RTI_RX_UFC_B;
+
+		device_config->vp_config[i].rti.uec_c = RTI_RX_UFC_C;
+
+		device_config->vp_config[i].rti.uec_d = RTI_RX_UFC_D;
+
+		device_config->vp_config[i].rti.rtimer_val =
+			(VXGE_RTI_RTIMER_VAL * 1000) / 272;
+
+		device_config->vp_config[i].rti.ltimer_val =
+			(VXGE_RTI_LTIMER_VAL * 1000) / 272;
+
+		device_config->vp_config[i].rpa_strip_vlan_tag =
+			vlan_tag_strip;
+
+		/* Print the values */
+		vxge_debug_ll_config(VXGE_TRACE, "%s : Vpath cfg params",
+			__func__);
+
+		vxge_debug_ll_config(VXGE_TRACE, "vp_id : %d",
+			device_config->vp_config[i].vp_id);
+		vxge_debug_ll_config(VXGE_TRACE, "mtu : %d",
+			device_config->vp_config[i].mtu);
+		vxge_debug_ll_config(VXGE_TRACE, "fifo.enable : %d",
+			device_config->vp_config[i].fifo.enable);
+		vxge_debug_ll_config(VXGE_TRACE, "fifo.max_frags : %d",
+			device_config->vp_config[i].fifo.max_frags);
+		vxge_debug_ll_config(VXGE_TRACE, "fifo.memblk_sz : %d",
+			device_config->vp_config[i].fifo.memblock_size);
+		vxge_debug_ll_config(VXGE_TRACE, "fifo.fifo_blks : %d",
+			device_config->vp_config[i].fifo.fifo_blocks);
+		vxge_debug_ll_config(VXGE_TRACE, "fifo.intr : %d",
+			device_config->vp_config[i].fifo.intr);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.intr_enable : %d",
+			device_config->vp_config[i].tti.intr_enable);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.btimer_val : %d",
+			device_config->vp_config[i].tti.btimer_val);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.timer_ac_en: %d",
+			device_config->vp_config[i].tti.timer_ac_en);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.timer_ci_en : %d",
+			device_config->vp_config[i].tti.timer_ci_en);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.timer_ri_en : %d",
+			device_config->vp_config[i].tti.timer_ri_en);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.util_sel : %d",
+			device_config->vp_config[i].tti.util_sel);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.ltimer_val : %d",
+			device_config->vp_config[i].tti.ltimer_val);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.rtimer_val : %d",
+			device_config->vp_config[i].tti.rtimer_val);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.urange_a : %d",
+			device_config->vp_config[i].tti.urange_a);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.urange_b : %d",
+			device_config->vp_config[i].tti.urange_b);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.urange_c : %d",
+			device_config->vp_config[i].tti.urange_c);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.uec_a : %d",
+			device_config->vp_config[i].tti.uec_a);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.uec_b : %d",
+			device_config->vp_config[i].tti.uec_b);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.uec_c : %d",
+			device_config->vp_config[i].tti.uec_c);
+		vxge_debug_ll_config(VXGE_TRACE, "tti.uec_d : %d",
+			device_config->vp_config[i].tti.uec_d);
+		vxge_debug_ll_config(VXGE_TRACE, "ring.enable : %d",
+			device_config->vp_config[i].ring.enable);
+		vxge_debug_ll_config(VXGE_TRACE, "ring.sw_lro_sess:%d",
+			device_config->vp_config[i].ring.sw_lro_sessions);
+		vxge_debug_ll_config(VXGE_TRACE, "ring.sw_lro_sg_sz:%d",
+			device_config->vp_config[i].ring.sw_lro_sg_size);
+		vxge_debug_ll_config(VXGE_TRACE, "ring.swlro_frm_ln:%d",
+			device_config->vp_config[i].ring.sw_lro_frm_len);
+		vxge_debug_ll_config(VXGE_TRACE, "ring.ring_blks : %d",
+			device_config->vp_config[i].ring.ring_blocks);
+		vxge_debug_ll_config(VXGE_TRACE, "ring.buffer_mode:%d",
+			device_config->vp_config[i].ring.buffer_mode);
+
+		vxge_debug_ll_config(VXGE_TRACE, "ring.scatter_mode:%d",
+			device_config->vp_config[i].ring.scatter_mode);
+		vxge_debug_ll_config(VXGE_TRACE, "ring.indic_mx_pkt:%d",
+			device_config->vp_config[i].ring.indicate_max_pkts);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.intr_enable : %d",
+			device_config->vp_config[i].rti.intr_enable);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.btimer_val : %d",
+			device_config->vp_config[i].rti.btimer_val);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.timer_ac_en : %d",
+			device_config->vp_config[i].rti.timer_ac_en);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.timer_ci_en : %d",
+			device_config->vp_config[i].rti.timer_ci_en);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.timer_ri_en : %d",
+			device_config->vp_config[i].rti.timer_ri_en);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.util_sel : %d",
+			device_config->vp_config[i].rti.util_sel);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.urange_a : %d",
+			device_config->vp_config[i].rti.urange_a);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.urange_b : %d",
+			device_config->vp_config[i].rti.urange_b);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.urange_c : %d",
+			device_config->vp_config[i].rti.urange_c);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.uec_a : %d",
+			device_config->vp_config[i].rti.uec_a);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.uec_b : %d",
+			device_config->vp_config[i].rti.uec_b);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.uec_c : %d",
+			device_config->vp_config[i].rti.uec_c);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.uec_d : %d",
+			device_config->vp_config[i].rti.uec_d);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.rtimer_val : %d",
+			device_config->vp_config[i].rti.rtimer_val);
+		vxge_debug_ll_config(VXGE_TRACE, "rti.ltimer_val : %d",
+			device_config->vp_config[i].rti.ltimer_val);
+		vxge_debug_ll_config(VXGE_TRACE, "rpa_strip_vlan_tag:%d",
+			device_config->vp_config[i].rpa_strip_vlan_tag);
+
+	}  /* end VPATH */
+	vpath_per_dev = temp;
+	return no_of_vpaths;
+}
+
+/* initialize device configuratrions */
+static void vxge_device_config_init(struct vxge_hw_device_config *device_config)
+{
+	/* Used for CQRQ/SRQ. */
+	device_config->dma_blockpool_initial =
+			VXGE_HW_INITIAL_DMA_BLOCK_POOL_SIZE;
+
+	device_config->dma_blockpool_min =
+			VXGE_HW_MIN_DMA_BLOCK_POOL_SIZE;
+
+	device_config->dma_blockpool_max =
+			VXGE_HW_MAX_DMA_BLOCK_POOL_SIZE;
+
+	device_config->dma_blockpool_incr =
+			VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE;
+
+	/* Statistics Setting. */
+
+	device_config->stats_read_method = VXGE_HW_STATS_READ_METHOD_PIO;
+
+	if (max_mac_vpath > VXGE_MAX_MAC_ADDR_COUNT)
+		max_mac_vpath = VXGE_MAX_MAC_ADDR_COUNT;
+
+#ifndef CONFIG_PCI_MSI
+	if (intr_type != INTA) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: This Kernel does not support "\
+			"MSI-X. Defaulting to INTA", VXGE_DRIVER_NAME);
+		intr_type = INTA;
+	}
+#else
+	if (
+
+		(intr_type != INTA) && (intr_type != MSI_X)) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: Wrong intr_type requested. "
+			"Defaulting to INTA", VXGE_DRIVER_NAME);
+		intr_type = INTA;
+	}
+#endif
+
+	/* Configure whether MSI-X or IRQL. */
+	switch (intr_type) {
+	case INTA:
+		device_config->intr_mode = VXGE_HW_INTR_MODE_IRQLINE;
+		break;
+
+	case MSI_X:
+		device_config->intr_mode = VXGE_HW_INTR_MODE_MSIX;
+		break;
+	}
+	device_config->lro_enable = lro;
+	/* Timer period between device poll */
+	device_config->device_poll_millis = VXGE_TIMER_DELAY;
+
+	/* Configure mac based steering. */
+	device_config->rts_mac_en = addr_learn_en;
+
+	/* Configure Vpaths */
+	device_config->rth_it_type = VXGE_HW_RTH_IT_TYPE_MULTI_IT;
+
+	vxge_debug_ll_config(VXGE_TRACE, "%s : Device Config Params ",
+			__func__);
+	vxge_debug_ll_config(VXGE_TRACE, "dma_blockpool_initial : %d",
+			device_config->dma_blockpool_initial);
+	vxge_debug_ll_config(VXGE_TRACE, "dma_blockpool_min : %d",
+			device_config->dma_blockpool_min);
+	vxge_debug_ll_config(VXGE_TRACE, "dma_blockpool_max : %d",
+			device_config->dma_blockpool_max);
+	vxge_debug_ll_config(VXGE_TRACE, "dma_blockpool_incr : %d",
+			device_config->dma_blockpool_incr);
+	vxge_debug_ll_config(VXGE_TRACE, "stats_read_method : %d",
+			device_config->stats_read_method);
+	vxge_debug_ll_config(VXGE_TRACE, "intr_mode : %d",
+			device_config->intr_mode);
+	vxge_debug_ll_config(VXGE_TRACE, "lro_enable : %d",
+			device_config->lro_enable);
+	vxge_debug_ll_config(VXGE_TRACE, "device_poll_millis : %d",
+			device_config->device_poll_millis);
+	vxge_debug_ll_config(VXGE_TRACE, "rts_mac_en : %d",
+			device_config->rts_mac_en);
+	vxge_debug_ll_config(VXGE_TRACE, "rth_en : %d",
+			device_config->rth_en);
+	vxge_debug_ll_config(VXGE_TRACE, "rth_it_type : %d",
+			device_config->rth_it_type);
+}
+
+static void vxge_print_parm(struct vxgedev *vdev, u64 vpath_mask)
+{
+	int i;
+
+	vxge_debug_init(VXGE_TRACE,
+		"%s: %d Vpath(s) opened",
+		vdev->ndev->name, vdev->no_of_vpath);
+
+	switch (vdev->config.intr_type) {
+	case INTA:
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Interrupt type INTA", vdev->ndev->name);
+		break;
+
+	case MSI_X:
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Interrupt type MSI-X", vdev->ndev->name);
+		break;
+	}
+
+	if (vdev->config.rth_steering) {
+		vxge_debug_init(VXGE_TRACE,
+			"%s: RTH steering enabled for TCP_IPV4",
+			vdev->ndev->name);
+	} else {
+		vxge_debug_init(VXGE_TRACE,
+			"%s: RTH steering disabled", vdev->ndev->name);
+	}
+
+	switch (vdev->config.tx_steering_type) {
+	case NO_STEERING:
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Tx steering disabled", vdev->ndev->name);
+		break;
+	case TX_PRIORITY_STEERING:
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Unsupported tx steering option",
+			vdev->ndev->name);
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Tx steering disabled", vdev->ndev->name);
+		vdev->config.tx_steering_type = 0;
+		break;
+	case TX_VLAN_STEERING:
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Unsupported tx steering option",
+			vdev->ndev->name);
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Tx steering disabled", vdev->ndev->name);
+		vdev->config.tx_steering_type = 0;
+		break;
+	case TX_MULTIQ_STEERING:
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Tx multiqueue steering enabled",
+			vdev->ndev->name);
+		break;
+	case TX_PORT_STEERING:
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Tx port steering enabled",
+			vdev->ndev->name);
+		break;
+	default:
+		vxge_debug_init(VXGE_ERR,
+			"%s: Unsupported tx steering type",
+			vdev->ndev->name);
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Tx steering disabled", vdev->ndev->name);
+		vdev->config.tx_steering_type = 0;
+	}
+
+	if (vdev->config.lro_enable) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: Large receive offload enabled",
+			vdev->ndev->name);
+	} else
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Large receive offload disabled",
+			vdev->ndev->name);
+
+	if (vdev->config.napi_enable) {
+		vxge_debug_init(VXGE_TRACE,
+			"%s: NAPI enabled", vdev->ndev->name);
+	} else
+		vxge_debug_init(VXGE_TRACE,
+			"%s: NAPI disabled", vdev->ndev->name);
+
+#if defined(CONFIG_XEN)
+	if (vdev->config.addr_learn_en)
+		vxge_debug_init(VXGE_TRACE,
+			"%s: MAC Address learning enabled", vdev->ndev->name);
+#endif
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		if (!bVAL1(vpath_mask, i))
+			continue;
+		vxge_debug_ll_config(VXGE_TRACE,
+			"%s: MTU size - %d", vdev->ndev->name,
+			((struct __hw_device  *)(vdev->devh))->
+				config.vp_config[i].mtu);
+		vxge_debug_init(VXGE_TRACE,
+			"%s: VLAN tag stripping %s", vdev->ndev->name,
+			((struct __hw_device  *)(vdev->devh))->
+				config.vp_config[i].rpa_strip_vlan_tag
+			? "Enabled" : "Disabled");
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Ring blocks : %d", vdev->ndev->name,
+			((struct __hw_device  *)(vdev->devh))->
+				config.vp_config[i].ring.ring_blocks);
+		vxge_debug_init(VXGE_TRACE,
+			"%s: Fifo blocks : %d", vdev->ndev->name,
+			((struct __hw_device  *)(vdev->devh))->
+				config.vp_config[i].fifo.fifo_blocks);
+		vxge_debug_ll_config(VXGE_TRACE,
+			"%s: Max frags : %d", vdev->ndev->name,
+			((struct __hw_device  *)(vdev->devh))->
+				config.vp_config[i].fifo.max_frags);
+		break;
+	}
+}
+
+#ifdef CONFIG_PM
+/**
+ * vxge_pm_suspend - vxge power management suspend entry point
+ *
+ */
+static int vxge_pm_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	return -ENOSYS;
+}
+/**
+ * vxge_pm_resume - vxge power management resume entry point
+ *
+ */
+static int vxge_pm_resume(struct pci_dev *pdev)
+{
+	return -ENOSYS;
+}
+
+#endif
+
+/*
+* vxge_io_error_detected - called when PCI error is detected
+* @pdev: Pointer to PCI device
+* @state: The current pci connection state
+*
+* This function is called after a PCI bus error affecting
+* this device has been detected.
+*/
+static pci_ers_result_t vxge_io_error_detected(struct pci_dev *pdev,
+						pci_channel_state_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev)) {
+		/* Bring down the card, while avoiding PCI I/O */
+		do_vxge_close(netdev, 0);
+	}
+
+	pci_disable_device(pdev);
+
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/*
+* vxge_io_slot_reset - called after the pci bus has been reset.
+* @pdev: Pointer to PCI device
+*
+* Restart the card from scratch, as if from a cold-boot.
+* At this point, the card has exprienced a hard reset,
+* followed by fixups by BIOS, and has its config space
+* set up identically to what it was at cold boot.
+*/
+static pci_ers_result_t vxge_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct vxgedev *vdev = netdev_priv(netdev);
+
+	if (pci_enable_device(pdev)) {
+		printk(KERN_ERR "%s: "\
+			"Cannot re-enable PCI device after reset.\n",
+			VXGE_DRIVER_NAME);
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	pci_set_master(pdev);
+	vxge_reset(vdev);
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/*
+* vxge_io_resume - called when traffic can start flowing again.
+* @pdev: Pointer to PCI device
+*
+* This callback is called when the error recovery driver tells
+* us that its OK to resume normal operation.
+*/
+static void vxge_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+
+	if (netif_running(netdev)) {
+		if (vxge_open(netdev)) {
+			printk(KERN_ERR "%s: "
+				"Can't bring device back up after reset.\n",
+				VXGE_DRIVER_NAME);
+			return;
+		}
+	}
+
+	netif_device_attach(netdev);
+}
+
+/*
+ * vxge_probe
+ *
+ * Detect and initialize new PCI device. Linux will call us when new
+ * device gets hot-plugged, discovered or whatever reason.
+ */
+static int __devinit
+vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
+{
+	struct __hw_device  *hldev;
+	enum vxge_hw_status status;
+	int ret;
+	int high_dma = 0;
+	u64 vpath_mask = 0;
+	struct vxgedev *vdev;
+	struct vxge_config ll_config;
+	struct vxge_hw_device_config *device_config = NULL;
+	struct vxge_hw_device_attr attr;
+	int i, j, no_of_vpath = 0, max_vpath_supported = 0;
+	u8 *macaddr;
+	struct vxge_mac_addrs *entry;
+	static int bus = -1, device = -1;
+	u8 new_device = 0;
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s:%d\n", __func__, __LINE__);
+	attr.pdev = pdev;
+
+	if (bus != pdev->bus->number)
+		new_device = 1;
+	if (device != PCI_SLOT(pdev->devfn))
+		new_device = 1;
+
+	bus = pdev->bus->number;
+	device = PCI_SLOT(pdev->devfn);
+
+	if (new_device) {
+		if (config_dev_cnt && (config_dev_cnt != total_dev_cnt))
+			vxge_debug_init(VXGE_ERR,
+				"%s: Configured %d of %d devices",
+				VXGE_DRIVER_NAME,
+				config_dev_cnt, total_dev_cnt);
+		config_dev_cnt = 0;
+		total_dev_cnt = 0;
+		g_no_cpus = 0;
+		vpath_per_dev = max_config_vpath;
+	}
+
+	total_dev_cnt++;
+	if (++config_dev_cnt > max_config_dev) {
+
+		ret = 0;
+
+		goto _exit0;
+	}
+
+	if (intr_type == INTA) {
+		if (config_dev_cnt > 1) {
+			/* Interrupt can't be shared across functions */
+
+			ret = 0;
+
+			goto _exit0;
+		}
+	}
+
+	device_config = kzalloc(sizeof(struct vxge_hw_device_config),
+		GFP_KERNEL);
+	if (!device_config) {
+		ret = -ENOMEM;
+		vxge_debug_init(VXGE_ERR,
+			"device_config : malloc failed %s %d\n",
+			__FILE__, __LINE__);
+		goto _exit0;
+	}
+	memset(&ll_config, 0, sizeof(struct vxge_config));
+	ll_config.cksum_offload_enable = 1;
+
+	ll_config.tx_steering_type = tx_steering_type;
+
+	ll_config.intr_type = intr_type;
+	ll_config.tso_enable = VXGE_TSO_ENABLE;
+
+	ll_config.napi_weight = NEW_NAPI_WEIGHT;
+
+	/* get the default configuration parameters */
+	vxge_hw_device_config_default_get(device_config);
+
+	/* initialize configuration parameters */
+
+	vxge_device_config_init(device_config);
+
+	ret = pci_enable_device(pdev);
+	if (ret) {
+		vxge_debug_init(VXGE_ERR,
+			"%s : can not enable PCI device", __func__);
+		goto _exit0;
+	}
+
+	if (!pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {
+		vxge_debug_ll_config(VXGE_TRACE,
+			"%s : using 64bit DMA", __func__);
+
+		high_dma = 1;
+
+		/*
+		 * As of today, xge driver do not using any consistent
+		 * allocations. It might impact performance on such systems
+		 * as sparc64 where coherent memory access is benefitial
+		 * comparing to streaming for bi-directional access.
+		 * And since HW descriptors require r/w access, it is
+		 * better for performance to use consistent memory allocations.
+		 */
+		if (pci_set_consistent_dma_mask(pdev,
+						0xffffffffffffffffULL)) {
+			vxge_debug_init(VXGE_ERR,
+				"%s : unable to obtain 64bit DMA for \
+				consistent allocations", __func__);
+			ret = -ENOMEM;
+			goto _exit1;
+		}
+
+	} else if (!pci_set_dma_mask(pdev, 0xffffffffUL)) {
+		vxge_debug_ll_config(VXGE_TRACE,
+			"%s : using 32bit DMA", __func__);
+	} else {
+		ret = -ENOMEM;
+		goto _exit1;
+	}
+
+	if (pci_request_regions(pdev, VXGE_DRIVER_NAME)) {
+		vxge_debug_init(VXGE_ERR,
+			"%s : request regions failed", __func__);
+		ret = -ENODEV;
+		goto _exit1;
+	}
+
+	pci_set_master(pdev);
+
+	attr.bar0 = (caddr_t)ioremap(pci_resource_start(pdev, 0),
+				      pci_resource_len(pdev, 0));
+	if (!attr.bar0) {
+		vxge_debug_init(VXGE_ERR,
+			"%s : cannot remap io memory bar0",
+			__func__);
+		ret = -ENODEV;
+		goto _exit2;
+	}
+	vxge_debug_ll_config(VXGE_TRACE,
+		"ioremap bar0: 0x%llx:0x%llx",
+		(unsigned long long)(ulong_t)attr.bar0,
+		(unsigned long long)(ulong_t)pci_resource_start(pdev,
+		0));
+
+	attr.bar1 = (caddr_t) ioremap(pci_resource_start(pdev, 2),
+				      pci_resource_len(pdev, 2));
+	if (!attr.bar1) {
+		vxge_debug_init(VXGE_ERR,
+			"%s : cannot remap io memory bar2",
+			__func__);
+		ret = -ENODEV;
+		goto _exit3;
+	}
+	vxge_debug_ll_config(VXGE_TRACE,
+		"ioremap bar1: 0x%llx:0x%llx",
+		(unsigned long long)(ulong_t)attr.bar1,
+		(unsigned long long)(ulong_t)pci_resource_start(pdev,
+		2));
+
+	status = vxge_hw_device_hw_info_get(attr.bar0,
+				&ll_config.device_hw_info);
+
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"%s: reading of mac addr and mask failed ",
+			VXGE_DRIVER_NAME);
+		ret = -EINVAL;
+		goto _exit5;
+	}
+
+	if (ll_config.device_hw_info.fw_version.major !=
+		VXGE_DRIVER_VERSION_MAJOR) {
+		vxge_debug_init(VXGE_ERR,
+			"FW Ver.(maj): %d does not match driver ver.: %d",
+			ll_config.device_hw_info.fw_version.major,
+			VXGE_DRIVER_VERSION_MAJOR);
+		ret = -EINVAL;
+		goto _exit5;
+	}
+
+	vpath_mask = ll_config.device_hw_info.vpath_mask;
+
+	if (vpath_mask == 0) {
+		vxge_debug_ll_config(VXGE_TRACE,
+			"%s:  no more vpath, mask is zero",
+			VXGE_DRIVER_NAME);
+		ret = -EINVAL;
+		goto _exit5;
+	}
+
+	vxge_debug_ll_config(VXGE_TRACE,
+		"%s:%d  Vpath mask = %llx\n", __func__, __LINE__,
+		vpath_mask);
+
+	/* Maximum vpaths per function */
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		if (!((vpath_mask) & vxge_mBIT(i)))
+			continue;
+		max_vpath_supported++;
+	}
+
+	/*	Configure vpaths and get driver configured number of vpaths
+		which is less than or equal to the maximum vpaths per function.
+	*/
+	no_of_vpath = vxge_config_vpaths(device_config, vpath_mask);
+	if (!no_of_vpath) {
+		vxge_debug_ll_config(VXGE_ERR,
+			"%s:  no more vpath", VXGE_DRIVER_NAME);
+
+		ret = 0;
+
+		goto _exit5;
+	}
+
+	if ((no_of_vpath == 1) && (napi) && (lro))
+		for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++)
+			device_config->vp_config[i].aggr_ack =
+				VXGE_HW_VPATH_AGGR_ACK_ENABLE;
+
+	else if ((intr_type == MSI_X) && (napi) && (lro))
+		for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++)
+			device_config->vp_config[i].aggr_ack =
+				VXGE_HW_VPATH_AGGR_ACK_ENABLE;
+
+	if (intr_type == MSI_X) {
+		/* If NAPI is not enabled, set indicate max to high value */
+		if (!napi) {
+			for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++)
+				device_config->vp_config[i].
+					ring.indicate_max_pkts =
+					VXGE_HW_MAX_RING_INDICATE_MAX_PKTS;
+		} else {
+			/* User entered small count to indicate */
+			if (ring_indicate_max_pkts < ll_config.napi_weight)
+				ll_config.napi_weight = ring_indicate_max_pkts;
+		}
+	}
+
+	/* Setting driver Callback APIs */
+	attr.uld_callbacks.link_up = vxge_callback_link_up;
+	attr.uld_callbacks.link_down = vxge_callback_link_down;
+	attr.uld_callbacks.crit_err = vxge_callback_crit_err;
+	attr.uld_callbacks.sched_timer = NULL;
+
+	status = vxge_hw_device_initialize((struct __hw_device **)
+					&hldev, &attr,
+					device_config);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"can't initialize device (%d), resetting",
+			status);
+		/*
+		 * in case of some errors device_initialize() will reset
+		 * driver might want to try it one more time after small delay.
+		 */
+		mdelay(1000);
+		status = vxge_hw_device_initialize((struct __hw_device **)
+			&hldev, &attr, device_config);
+		if (status != VXGE_HW_OK) {
+			vxge_debug_init(VXGE_ERR,
+					"can't initialize device (%d), exiting",
+					status);
+			ret = -EINVAL;
+			goto _exit5;
+		}
+	}
+
+	vxge_hw_device_debug_set(hldev, VXGE_ERR, VXGE_COMPONENT_LL);
+
+	/* set private device info */
+	pci_set_drvdata(pdev, hldev);
+
+	ll_config.napi_enable = napi;
+
+	ll_config.lro_enable = lro;
+	ll_config.lro_max_bytes = lro_max_bytes;
+	ll_config.fifo_indicate_max_pkts = fifo_indicate_max_pkts;
+	ll_config.intr_type = intr_type;
+	ll_config.addr_learn_en = addr_learn_en;
+
+	ll_config.rth_steering = (rx_steering_type == RTH_STEERING) ? 1 : 0;
+	ll_config.rth_algorithm = RTH_ALG_JENKINS;
+	ll_config.rth_hash_type_tcpipv4 = VXGE_HW_RING_HASH_TYPE_TCP_IPV4;
+	ll_config.rth_hash_type_ipv4 = VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config.rth_hash_type_tcpipv6 = VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config.rth_hash_type_ipv6 = VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config.rth_hash_type_tcpipv6ex = VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config.rth_hash_type_ipv6ex = VXGE_HW_RING_HASH_TYPE_NONE;
+	ll_config.rth_bkt_sz = RTH_BUCKET_SIZE;
+	ll_config.rth_jhash_golden_ratio = RTH_JHASH_GOLDEN_RATIO;
+	ll_config.tx_steering_type = tx_steering_type;
+	ll_config.tx_pause_enable = tx_pause_enable;
+	ll_config.rx_pause_enable = rx_pause_enable;
+
+	if (vxge_device_register(hldev, &ll_config, high_dma, no_of_vpath,
+		&vdev)) {
+		ret = -EINVAL;
+		goto _exit6;
+	}
+
+	vxge_hw_device_debug_set(hldev, VXGE_TRACE, VXGE_COMPONENT_LL);
+	VXGE_COPY_DEBUG_INFO_TO_LL(vdev,
+		vxge_hw_device_error_level_get(hldev),
+		vxge_hw_device_trace_level_get(hldev));
+
+	/* set private HW device info */
+	vxge_hw_device_private_set(hldev, vdev->ndev);
+	vdev->mtu = VXGE_HW_DEFAULT_MTU;
+	vdev->bar0 = attr.bar0;
+	vdev->bar1 = attr.bar1;
+	vdev->max_vpath_supported = max_vpath_supported;
+	vdev->no_of_vpath = no_of_vpath;
+
+	/* Virtual Path count */
+	for (i = 0, j = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		if (!bVAL1(vpath_mask, i))
+			continue;
+		if (j >= vdev->no_of_vpath)
+			break;
+
+		vdev->vpaths[j].is_configured = 1;
+		vdev->vpaths[j].device_id = i;
+		vdev->vpaths[j].fifo.driver_id = j;
+		vdev->vpaths[j].ring.driver_id = j;
+		vdev->vpaths[j].vdev = vdev;
+		vdev->vpaths[j].max_mac_addr_cnt = max_mac_vpath;
+		memcpy((u8 *)vdev->vpaths[j].macaddr,
+				(u8 *)ll_config.device_hw_info.mac_addrs[i], 6);
+
+		/* Initialize the mac address list header */
+		vxge_list_init(&vdev->vpaths[j].mac_addr_list);
+
+		vdev->vpaths[j].mac_addr_cnt = 0;
+		vdev->vpaths[j].mcast_addr_cnt = 0;
+		j++;
+	}
+	vdev->exec_mode = exec_mode;
+	vdev->max_config_port = max_config_port;
+
+	vdev->vlan_tag_strip = vlan_tag_strip;
+
+	/* map the hashing selector table to the configured vpaths */
+	for (i = 0; i < vdev->no_of_vpath; i++)
+		vdev->vpath_selector[i] = vpath_selector[i];
+
+	macaddr = (u8 *)vdev->vpaths[0].macaddr;
+
+	vdev->serial_num = (char *) vxge_hw_device_serial_number_get(hldev);
+	*(vdev->serial_num + (VXGE_HW_VPD_LENGTH - 1)) = '\0';
+	if (strcmp(vdev->serial_num, "not supported") != 0)
+		strcpy(g_serial_num, vdev->serial_num);
+
+	vdev->product_name = (char *) vxge_hw_device_product_name_get(hldev);
+	*(vdev->product_name + (VXGE_HW_VPD_LENGTH - 1)) = '\0';
+	if (strcmp(vdev->product_name, "not supported") != 0)
+		strcpy(g_product_name, vdev->product_name);
+
+	vxge_debug_init(VXGE_TRACE, "%s: SERIAL NUMBER: %s",
+		vdev->ndev->name, g_serial_num);
+
+	vxge_debug_init(VXGE_TRACE, "%s: Neterion %s Server Adapter",
+		vdev->ndev->name, g_product_name);
+
+	vxge_debug_init(VXGE_TRACE,
+		"%s: MAC ADDR: %02X:%02X:%02X:%02X:%02X:%02X",
+		vdev->ndev->name,
+		macaddr[0], macaddr[1], macaddr[2], macaddr[3],
+		macaddr[4], macaddr[5]);
+
+	vxge_debug_init(VXGE_TRACE, "%s: Link Width x%d",
+		vdev->ndev->name, vxge_hw_device_link_width_get(hldev));
+
+	vxge_debug_init(VXGE_TRACE,
+		"%s: Firmware version : %s Date : %s", vdev->ndev->name,
+		ll_config.device_hw_info.fw_version.version,
+		ll_config.device_hw_info.fw_date.date);
+
+	vxge_print_parm(vdev, vpath_mask);
+
+	/* Store the fw version for ethttool option */
+	strcpy(vdev->fw_version, ll_config.device_hw_info.fw_version.version);
+
+	memcpy(vdev->ndev->dev_addr, (u8 *)vdev->vpaths[0].macaddr, ETH_ALEN);
+
+	memcpy(vdev->ndev->perm_addr, vdev->ndev->dev_addr, ETH_ALEN);
+
+	/* Copy the station mac address to the list */
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		entry =	(struct vxge_mac_addrs *)
+				kzalloc(sizeof(struct vxge_mac_addrs),
+					GFP_KERNEL);
+		if (NULL == entry) {
+			vxge_debug_init(VXGE_ERR,
+				"%s: mac_addr_list : memory allocation failed",
+				vdev->ndev->name);
+			ret = -EPERM;
+			goto _exit7;
+		}
+		macaddr = (u8 *)&entry->macaddr;
+		memcpy(macaddr, vdev->ndev->dev_addr, ETH_ALEN);
+
+		/* Adjust the doubly linked list pointers */
+		vxge_list_insert(&entry->item,
+				&vdev->vpaths[i].mac_addr_list);
+
+		vdev->vpaths[i].mac_addr_cnt = 1;
+	}
+
+	vxge_debug_entryexit(VXGE_TRACE,
+		"%s: %s:%d  Exiting...\\n",
+		vdev->ndev->name, __func__, __LINE__);
+
+	vxge_hw_device_debug_set(hldev, VXGE_ERR, VXGE_COMPONENT_LL);
+	VXGE_COPY_DEBUG_INFO_TO_LL(vdev,
+		vxge_hw_device_error_level_get(hldev),
+		vxge_hw_device_trace_level_get(hldev));
+
+	return 0;
+
+_exit7:
+	for (i = 0; i < vdev->no_of_vpath; i++)
+		vxge_free_mac_add_list(&vdev->vpaths[i]);
+
+	vxge_device_unregister(hldev);
+_exit6:
+	vxge_hw_device_terminate(hldev);
+_exit5:
+	iounmap(attr.bar1);
+_exit3:
+	iounmap(attr.bar0);
+_exit2:
+	pci_release_regions(pdev);
+_exit1:
+	pci_disable_device(pdev);
+_exit0:
+	kfree(device_config);
+	config_dev_cnt--;
+	pci_set_drvdata(pdev, NULL);
+	return ret;
+}
+
+static void __devexit
+vxge_remove(struct pci_dev *pdev)
+{
+	struct __hw_device  *hldev;
+	struct vxgedev *vdev = NULL;
+	struct net_device *dev;
+	int i = 0;
+#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
+	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
+	u32 level_trace;
+#endif
+
+	vxge_assert(pdev);
+
+	hldev = (struct __hw_device  *) pci_get_drvdata(pdev);
+
+	if (hldev == NULL)
+		return;
+
+	vxge_assert(hldev);
+
+	dev = vxge_hw_device_private_get(hldev);
+	vxge_assert(dev);
+
+	vdev = netdev_priv(dev);
+	vxge_assert(vdev);
+
+#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
+	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
+	level_trace = vdev->level_trace;
+#endif
+	vxge_debug_entryexit(level_trace,
+		"%s:%d\n", __func__, __LINE__);
+
+	vxge_debug_init(level_trace,
+		"%s : removing PCI device...", __func__);
+	vxge_device_unregister(hldev);
+
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		vxge_free_mac_add_list(&vdev->vpaths[i]);
+		vdev->vpaths[i].mcast_addr_cnt = 0;
+		vdev->vpaths[i].mac_addr_cnt = 0;
+	}
+
+	kfree(vdev->vpaths);
+
+	iounmap(vdev->bar0);
+	iounmap(vdev->bar1);
+
+	/* we are safe to free it now */
+	free_netdev(dev);
+
+	vxge_debug_init(level_trace,
+		"%s:%d  Device unregistered\n", __func__, __LINE__);
+
+	vxge_hw_device_terminate(hldev);
+
+	pci_disable_device(pdev);
+	pci_release_regions(pdev);
+	pci_set_drvdata(pdev, NULL);
+	vxge_debug_entryexit(level_trace,
+		"%s:%d  Exiting...\n", __func__, __LINE__);
+}
+
+int __init
+vxge_starter(void)
+{
+	int ret = 0;
+	char version[255];
+	sprintf(version, "%s", DRV_VERSION);
+
+	printk(KERN_CRIT "%s: Copyright(c) 2002-2009 Neterion Inc\n",
+		VXGE_DRIVER_NAME);
+	printk(KERN_CRIT "%s: Driver version: %s \n",
+			VXGE_DRIVER_NAME, version);
+
+	verify_bandwidth();
+
+	ret = pci_register_driver(&vxge_driver);
+
+	if (config_dev_cnt && (config_dev_cnt != total_dev_cnt))
+		vxge_debug_init(VXGE_ERR,
+			"%s: Configured %d of %d devices",
+			VXGE_DRIVER_NAME, config_dev_cnt, total_dev_cnt);
+	return ret;
+}
+
+void __exit
+vxge_closer(void)
+{
+	pci_unregister_driver(&vxge_driver);
+}
+module_init(vxge_starter);
+module_exit(vxge_closer);
diff -urpN patch_7/drivers/net/vxge/vxge-main.h patch_8/drivers/net/vxge/vxge-main.h
--- patch_7/drivers/net/vxge/vxge-main.h	1969-12-31 16:00:00.000000000 -0800
+++ patch_8/drivers/net/vxge/vxge-main.h	2009-03-13 00:14:32.000000000 -0700
@@ -0,0 +1,623 @@
+/******************************************************************************
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License (GPL), incorporated herein by reference.
+ * Drivers based on or derived from this code fall under the GPL and must
+ * retain the authorship, copyright and license notice.  This file is not
+ * a complete program and may only be used when the entire operating
+ * system is licensed under the GPL.
+ * See the file COPYING in this distribution for more information.
+ ******************************************************************************/
+/*******************************************************************************
+ * vxge-main.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ *              Virtualized Server Adapter.
+ * Copyright(c) 2002-2009 Neterion Inc.
+ ******************************************************************************/
+#ifndef VXGE_MAIN_H
+#define VXGE_MAIN_H
+
+#include "vxge-traffic.h"
+#include "vxge-config.h"
+#include "vxge-version.h"
+
+#include <linux/inet_lro.h>
+
+#define VXGE_DRIVER_NAME		"vxge"
+#define VXGE_DRIVER_VENDOR		"Neterion, Inc"
+
+#define DRV_VERSION	VXGE_VERSION_MAJOR"."VXGE_VERSION_MINOR"."\
+	VXGE_VERSION_FIX"."VXGE_VERSION_BUILD"-"\
+	VXGE_VERSION_FOR
+
+#define	VXGE_USE_DEFAULT		0xffffffff
+#define VXGE_HW_VPATH_MSIX_ACTIVE	4
+#define XGE_HW_RXSYNC_FREQ_CNT		4
+#define VXGE_LL_WATCH_DOG_TIMEOUT	(15 * HZ)
+#define VXGE_LL_RX_COPY_THRESHOLD	256
+#define VXGE_DEF_FIFO_LENGTH		84
+#define MAX_PYLD_JUMBO		9600
+#define	MIN_MTU			68
+
+#define NO_STEERING		0
+#define PORT_STEERING		0x1
+#define RTH_STEERING		0x2
+#define RX_TOS_STEERING		0x3
+#define RX_VLAN_STEERING	0x4
+#define RTH_BUCKET_SIZE		4
+#define RTH_JHASH_GOLDEN_RATIO	0x01020304
+
+#define	TX_PRIORITY_STEERING	1
+#define	TX_VLAN_STEERING	2
+#define	TX_PORT_STEERING	3
+#define	TX_MULTIQ_STEERING	4
+
+#define VXGE_TTI_BTIMER_VAL 250000
+
+#define VXGE_TTI_LTIMER_VAL 1000
+#define VXGE_TTI_RTIMER_VAL 0
+#define VXGE_RTI_BTIMER_VAL 250
+#define VXGE_RTI_LTIMER_VAL 100
+#define VXGE_RTI_RTIMER_VAL 0
+#define VXGE_FIFO_INDICATE_MAX_PKTS 32
+#define VXGE_ISR_POLLING_CNT 8
+#define VXGE_TSO_ENABLE 1
+#define VXGE_TSO_DISABLE 0
+#define VXGE_ENABLE_NAPI 1
+#define VXGE_DISABLE_NAPI 0
+#define VXGE_LRO_MAX_BYTES 0x4000
+#define VXGE_MAX_CONFIG_DEV 0xFF
+#define VXGE_EXEC_MODE_DISABLE 0
+#define VXGE_EXEC_MODE_ENABLE 1
+#define VXGE_MAX_CONFIG_PORT 1
+#define VXGE_NETQ_DISABLE 0
+#define VXGE_NETQ_ENABLE 1
+#define VXGE_ALL_VID_DISABLE 0
+#define VXGE_ALL_VID_ENABLE 1
+#define VXGE_PAUSE_FRM_DISABLE 0
+#define VXGE_PAUSE_FRM_ENABLE 1
+
+#define TTI_TX_URANGE_A	5
+#define TTI_TX_URANGE_B	15
+#define TTI_TX_URANGE_C	40
+#define TTI_TX_UFC_A	5
+#define TTI_TX_UFC_B	40
+#define TTI_TX_UFC_C	60
+#define TTI_TX_UFC_D	100
+
+#define RTI_RX_URANGE_A	5
+#define RTI_RX_URANGE_B	15
+#define RTI_RX_URANGE_C	40
+#define RTI_RX_UFC_A	1
+#define RTI_RX_UFC_B	5
+#define RTI_RX_UFC_C	10
+#define RTI_RX_UFC_D	15
+
+/*
+ * default the size of buffers allocated for dumping stats/buffers
+ * These are allocated via vmalloc
+ */
+#define VXGE_MRPCIM_STATS_BUFSIZE	65000
+#define VXGE_DEVCONF_BUFSIZE		(32 * 2048)
+#define VXGE_REG_DUMP_BUFSIZE		65000
+
+/* Milli secs timer period */
+#define VXGE_TIMER_DELAY		10000
+
+enum vxge_reset_event {
+	/* reset events */
+	VXGE_LL_VPATH_RESET	= 0,
+	VXGE_LL_DEVICE_RESET	= 1,
+	VXGE_LL_FULL_RESET	= 2,
+	VXGE_LL_START_RESET	= 3,
+	VXGE_LL_COMPL_RESET	= 4
+};
+
+/* These flags represent the devices temporary state */
+enum vxge_device_state_t {
+__VXGE_STATE_RESET_CARD = 0,
+__VXGE_STATE_CARD_UP
+};
+
+enum vxge_mac_addr_state {
+	/* mac address states */
+	VXGE_LL_MAC_ADDR_IN_LIST        = 0,
+	VXGE_LL_MAC_ADDR_IN_DA_TABLE    = 1
+};
+
+struct macInfo {
+	unsigned char macaddr[6];
+	unsigned char macmask[6];
+	unsigned int vpath_no;
+	enum vxge_mac_addr_state state;
+};
+
+struct macList {
+	unsigned int vpath_no;
+	unsigned int macaddr_no;
+	struct macInfo mac_info[128];
+};
+
+struct vxge_config {
+	int		cksum_offload_enable;
+	int		tso_enable;
+	int		napi_enable;
+	int		tx_pause_enable;
+	int		rx_pause_enable;
+
+#define	NEW_NAPI_WEIGHT	64
+	int		napi_weight;
+	int		aggr_ack;
+	int		lro_enable;
+#define MIN_LRO_PACKETS	1
+#define MAX_LRO_PACKETS	10
+	int		lro_max_aggr_per_sess;
+	int		lro_max_bytes;
+	int		intr_type;
+#define INTA	0
+#define MSI	1
+#define MSI_X	2
+
+	int		addr_learn_en;
+
+	int		rth_steering;
+	int		rth_algorithm;
+	int		rth_hash_type_tcpipv4;
+	int		rth_hash_type_ipv4;
+	int		rth_hash_type_tcpipv6;
+	int		rth_hash_type_ipv6;
+	int		rth_hash_type_tcpipv6ex;
+	int		rth_hash_type_ipv6ex;
+	int		rth_bkt_sz;
+	int		rth_jhash_golden_ratio;
+	int		tx_steering_type;
+	int 	fifo_indicate_max_pkts;
+	struct vxge_hw_device_hw_info device_hw_info;
+};
+
+struct vxge_msix_entry {
+	/* Mimicing the msix_entry struct of Kernel. */
+	u16 vector;
+	u16 entry;
+	u16 in_use;
+	void *arg;
+};
+
+/* Software Statistics */
+
+struct vxge_sw_stats {
+	/* Network Stats (interface stats) */
+	struct net_device_stats net_stats;
+
+	/* Errors */
+
+	/* Tx */
+	u64 tx_frms;
+	u64 tx_errors;
+	u64 tx_bytes;
+	u64 txd_not_free;
+	u64 txd_out_of_desc;
+
+	/* Virtual Path */
+	u64 vpaths_open;
+	u64 vpath_open_fail;
+
+	/* Rx */
+	u64 rx_frms;
+	u64 rx_errors;
+	u64 rx_bytes;
+	u64 rx_mcast;
+
+	/* Misc. */
+	u64 link_up;
+	u64 link_down;
+	u64 pci_map_fail;
+	u64 skb_alloc_fail;
+};
+
+struct vxge_mac_addrs {
+	struct vxge_list item;
+	u64 macaddr;
+	u64 macmask;
+	enum vxge_mac_addr_state state;
+};
+
+struct vxgedev;
+
+struct vxge_fifo_stats {
+	u64 tx_frms;
+	u64 tx_errors;
+	u64 tx_bytes;
+	u64 txd_not_free;
+	u64 txd_out_of_desc;
+	u64 pci_map_fail;
+};
+
+struct vxge_fifo {
+	struct net_device	*ndev;
+	struct pci_dev		*pdev;
+	struct __hw_fifo *handle;
+	/* The vpath id maintained in the driver -
+	 * 0 to 'maximum_vpaths_in_function - 1'
+	 */
+	int driver_id;
+	int tx_steering_type;
+	int indicate_max_pkts;
+	spinlock_t tx_lock;
+	int queue_state;
+	/* flag used to maintain queue state when MULTIQ is not enabled */
+#define VPATH_QUEUE_START       0
+#define VPATH_QUEUE_STOP        1
+
+	/* Tx stats */
+	struct vxge_fifo_stats stats;
+
+} ____cacheline_aligned;
+
+struct vxge_ring_stats {
+
+	u64 rx_frms;
+	u64 rx_errors;
+	u64 rx_dropped;
+	u64 rx_bytes;
+	u64 rx_mcast;
+	u64 pci_map_fail;
+	u64 skb_alloc_fail;
+};
+
+struct vxge_ring {
+	struct net_device	*ndev;
+	struct pci_dev		*pdev;
+	struct __hw_ring *handle;
+	/* The vpath id maintained in the driver -
+	 * 0 to 'maximum_vpaths_in_function - 1'
+	 */
+	int driver_id;
+
+	 /*
+	  * A copy of the flag indicating whether rx_csum is to be used
+		  */
+	u32 rx_csum;
+
+	int indicate_max_pkts;
+	int pkts_processed;
+	int budget;
+	int lro_enable;
+	int aggr_ack;
+
+	struct napi_struct napi;
+
+	int napi_enable;
+
+#define VXGE_MAX_MAC_ADDR_COUNT		30
+
+	int vlan_tag_strip;
+	struct vlan_group *vlgrp;
+	int rx_vector_no;
+
+#define MAX_LRO_SESSIONS        32
+
+	struct net_lro_mgr lro_mgr;
+	struct net_lro_desc lro_desc[MAX_LRO_SESSIONS];
+
+	/* Rx stats */
+	struct vxge_ring_stats stats;
+
+} ____cacheline_aligned;
+
+struct vxge_vpath {
+
+	struct vxge_fifo fifo;
+	struct vxge_ring ring;
+
+	struct __hw_vpath_handle *handle;
+
+	/* Actual vpath id for this vpath in the device - 0 to 16 */
+	int device_id;
+	int max_mac_addr_cnt;
+	int is_configured;
+	int is_open;
+	struct vxgedev *vdev;
+	u8 (macaddr)[ETH_ALEN];
+	u8 (macmask)[ETH_ALEN];
+
+#define VXGE_MAX_LEARN_MAC_ADDR_CNT	2048
+	/* mac addresses currently programmed into NIC */
+	u16 mac_addr_cnt;
+	u16 mcast_addr_cnt;
+	struct vxge_list mac_addr_list;
+
+	u32 level_err;
+	u32 level_trace;
+};
+#define VXGE_COPY_DEBUG_INFO_TO_LL(vdev, err, trace) {	\
+	int i;							\
+	for (i = 0; i < vdev->no_of_vpath; i++) {		\
+		vdev->vpaths[i].level_err = err;		\
+		vdev->vpaths[i].level_trace = trace;		\
+	}							\
+	vdev->level_err = err;					\
+	vdev->level_trace = trace;				\
+}
+
+struct vxge_error {
+	enum vxge_hw_event type;
+	u32 vp_id;
+};
+
+struct vxgedev {
+	struct net_device	*ndev;
+	struct pci_dev		*pdev;
+	struct __hw_device *devh;
+	struct vlan_group	*vlgrp;
+	int vlan_tag_strip;
+	struct vxge_config	config;
+	volatile unsigned long	state;
+	unsigned int	tx_per_list_intr_cnt;
+
+	/* ID timer used to blink  the NICs LED to ID it. */
+	struct		timer_list id_timer;
+
+	/* Indicates which vpath to reset */
+	volatile unsigned long  vp_reset;
+
+	/* Timer used for polling vpath resets */
+	struct timer_list vp_reset_timer;
+
+	/*
+	 * Flags to track whether device is in All Multicast
+	 * or in promiscuous mode.
+	 */
+	u16		all_multi_flg;
+
+	 /* A flag indicating whether rx_csum is to be used or not. */
+	u32	rx_csum;
+
+	struct vxge_msix_entry *vxge_entries;
+	struct msix_entry *entries;
+	/*
+	 * 4 for each vpath * 17;
+	 * total is 68
+	 */
+#define	VXGE_MAX_REQUESTED_MSIX	68
+	char desc[VXGE_MAX_REQUESTED_MSIX][80];
+
+	struct vxge_error cric_err_event;
+
+	int max_vpath_supported;
+	int no_of_vpath;
+
+	struct napi_struct napi;
+
+	int exec_mode;
+	int max_config_port;
+	struct vxge_vpath	*vpaths;
+
+	struct __hw_vpath_handle *vp_handles[VXGE_HW_MAX_VIRTUAL_PATHS];
+	u8 *bar0;
+	u8 *bar1;
+	struct vxge_sw_stats	stats;
+	int		mtu;
+	/* Below variables are used for vpath selection to transmit a packet */
+	u8 		vpath_mapping[VXGE_HW_MAX_VIRTUAL_PATHS];
+	u8 		vpath_selector[VXGE_HW_MAX_VIRTUAL_PATHS];
+	u64		vpaths_deployed;
+
+	u32 		intr_cnt;
+	u32 		level_err;
+	u32 		level_trace;
+	char		*serial_num;
+	char		*product_name;
+	char            fw_version[VXGE_HW_FW_VERSION_LEN];
+
+};
+
+struct vxge_rx_priv {
+	struct sk_buff		*skb;
+	dma_addr_t		data_dma;
+	dma_addr_t		data_size;
+};
+
+struct vxge_tx_priv {
+	struct sk_buff		*skb;
+	dma_addr_t		dma_buffers[MAX_SKB_FRAGS+1];
+};
+
+#define VXGE_MODULE_PARAM_INT(p, val) \
+	static int p = val; \
+	module_param(p, int, 0)
+
+static inline void vxge_os_timeout(int milliseconds)
+{
+	int delay;
+	delay = (HZ * milliseconds / 1000);
+	delay = (delay) ? delay : 1;
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(delay);
+}
+
+#define vxge_os_bug(fmt...)		{ printk(fmt); BUG(); }
+
+#define vxge_os_timer(timer, handle, arg, exp) do { \
+		init_timer(&timer); \
+		timer.function = handle; \
+		timer.data = (unsigned long) arg; \
+		mod_timer(&timer, (jiffies + exp)); \
+	} while (0);
+
+static inline struct net_device *vxge_alloc_etherdev(size_t size,
+			int no_of_vpath,
+			int tx_steering_type)
+{
+	struct net_device *ndev;
+
+	if (tx_steering_type == TX_MULTIQ_STEERING)
+		ndev = alloc_etherdev_mq(size, no_of_vpath);
+	else
+		ndev = alloc_etherdev(size);
+
+	return ndev;
+}
+
+#define VXGE_CHECK_PCI_CHANNEL_OFFLINE(pdev) { \
+	if (pci_channel_offline(pdev)) \
+		return IRQ_NONE; \
+}
+
+int vxge_device_register(struct __hw_device *devh,
+			struct vxge_config *config,
+			int high_dma, int no_of_vpath,
+			struct vxgedev **vdev);
+
+void vxge_device_unregister(struct __hw_device *devh);
+
+void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id);
+
+void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id);
+
+void vxge_callback_link_up(struct __hw_device *devh, void *userdata);
+
+void vxge_callback_link_down(struct __hw_device *devh, void *userdata);
+
+enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
+	struct macInfo *mac);
+
+int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac);
+
+int vxge_reset(struct vxgedev *vdev);
+
+enum vxge_hw_status
+vxge_rx_1b_compl(struct __hw_ring *ringh, void *dtr,
+	u8 t_code, void *userdata);
+
+enum vxge_hw_status
+vxge_xmit_compl(struct __hw_fifo *fifo_hw, void *dtr,
+	void *dtr_priv, enum vxge_hw_fifo_tcode t_code, void *userdata,
+	void **skb_ptr);
+
+int vxge_close(struct net_device *dev);
+
+int vxge_open(struct net_device *dev);
+
+void dma_alloc_task_cb(unsigned long *data);
+
+void vxge_close_vpaths(struct vxgedev *vdev, int index);
+
+int vxge_open_vpaths(struct vxgedev *vdev);
+
+enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
+
+void vxge_stop_all_tx_queue(struct vxgedev *vdev);
+
+void vxge_stop_tx_queue(struct vxge_fifo *fifo);
+
+void vxge_start_all_tx_queue(struct vxgedev *vdev);
+
+void vxge_wake_tx_queue(struct vxge_fifo *fifo, struct sk_buff *skb);
+
+enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
+	struct macInfo *mac);
+
+enum vxge_hw_status vxge_del_mac_addr(struct vxgedev *vdev,
+	struct macInfo *mac);
+
+int vxge_mac_list_add(struct vxge_vpath *vpath,
+	struct macInfo *mac);
+
+void vxge_free_mac_add_list(struct vxge_vpath *vpath);
+
+enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath);
+
+enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath);
+
+extern int vxge_ethtool(struct net_device *dev, struct ifreq *rq);
+int do_vxge_close(struct net_device *dev, int do_io);
+extern void initialize_ethtool_ops(struct net_device *ndev);
+/**
+ * #define VXGE_DEBUG_INIT: debug for initialization functions
+ * #define VXGE_DEBUG_TX	 : debug transmit related functions
+ * #define VXGE_DEBUG_RX  : debug recevice related functions
+ * #define VXGE_DEBUG_MEM : debug memory module
+ * #define VXGE_DEBUG_LOCK: debug locks
+ * #define VXGE_DEBUG_SEM : debug semaphore
+ * #define VXGE_DEBUG_ENTRYEXIT: debug functions by adding entry exit statements
+*/
+#define VXGE_DEBUG_INIT		0x00000001
+#define VXGE_DEBUG_TX		0x00000002
+#define VXGE_DEBUG_RX		0x00000004
+#define VXGE_DEBUG_MEM		0x00000008
+#define VXGE_DEBUG_LOCK		0x00000010
+#define VXGE_DEBUG_SEM		0x00000020
+#define VXGE_DEBUG_ENTRYEXIT	0x00000040
+#define VXGE_DEBUG_INTR		0x00000080
+#define VXGE_DEBUG_LL_CONFIG	0x00000100
+
+/* Debug tracing for VXGE driver */
+#ifndef VXGE_DEBUG_MASK
+#define VXGE_DEBUG_MASK	0x0
+#endif
+
+#if (VXGE_DEBUG_LL_CONFIG & VXGE_DEBUG_MASK)
+#define vxge_debug_ll_config(level, fmt, ...) \
+	vxge_debug_ll(level, VXGE_DEBUG_LL_CONFIG, fmt, __VA_ARGS__)
+#else
+#define vxge_debug_ll_config(level, fmt, ...)
+#endif
+
+#if (VXGE_DEBUG_INIT & VXGE_DEBUG_MASK)
+#define vxge_debug_init(level, fmt, ...) \
+	vxge_debug_ll(level, VXGE_DEBUG_INIT, fmt, __VA_ARGS__)
+#else
+#define vxge_debug_init(level, fmt, ...)
+#endif
+
+#if (VXGE_DEBUG_TX & VXGE_DEBUG_MASK)
+#define vxge_debug_tx(level, fmt, ...) \
+	vxge_debug_ll(level, VXGE_DEBUG_TX, fmt, __VA_ARGS__)
+#else
+#define vxge_debug_tx(level, fmt, ...)
+#endif
+
+#if (VXGE_DEBUG_RX & VXGE_DEBUG_MASK)
+#define vxge_debug_rx(level, fmt, ...) \
+	vxge_debug_ll(level, VXGE_DEBUG_RX, fmt, __VA_ARGS__)
+#else
+#define vxge_debug_rx(level, fmt, ...)
+#endif
+
+#if (VXGE_DEBUG_MEM & VXGE_DEBUG_MASK)
+#define vxge_debug_mem(level, fmt, ...) \
+	vxge_debug_ll(level, VXGE_DEBUG_MEM, fmt, __VA_ARGS__)
+#else
+#define vxge_debug_mem(level, fmt, ...)
+#endif
+
+#if (VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK)
+#define vxge_debug_entryexit(level, fmt, ...) \
+	vxge_debug_ll(level, VXGE_DEBUG_ENTRYEXIT, fmt, __VA_ARGS__)
+#else
+#define vxge_debug_entryexit(level, fmt, ...)
+#endif
+
+#if (VXGE_DEBUG_INTR & VXGE_DEBUG_MASK)
+#define vxge_debug_intr(level, fmt, ...) \
+	vxge_debug_ll(level, VXGE_DEBUG_INTR, fmt, __VA_ARGS__)
+#else
+#define vxge_debug_intr(level, fmt, ...)
+#endif
+
+#define VXGE_DEVICE_DEBUG_LEVEL_SET(level, mask, vdev) {\
+	vxge_hw_device_debug_set((struct __hw_device  *)vdev->devh, \
+		level, mask);\
+	VXGE_COPY_DEBUG_INFO_TO_LL(vdev, \
+		vxge_hw_device_error_level_get((struct __hw_device  *) \
+			vdev->devh), \
+		vxge_hw_device_trace_level_get((struct __hw_device  *) \
+			vdev->devh));\
+}
+
+#ifdef NETIF_F_GSO
+#define vxge_tcp_mss(skb) (skb_shinfo(skb)->gso_size)
+#define vxge_udp_mss(skb) (skb_shinfo(skb)->gso_size)
+#define vxge_offload_type(skb) (skb_shinfo(skb)->gso_type)
+#endif
+
+#endif




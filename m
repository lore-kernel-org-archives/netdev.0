From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 23 Nov 2009 19:51:01 -0800
Message-ID: <200911240351.nAO3p18H025624@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.82]:53783 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757878AbZKXDvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 22:51:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 1/6 which contains linux driver source for
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
Source is based against net-next-2.6.

We wish this patch to be considered for inclusion in net-next-2.6

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 bnad.c | 3548 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 bnad.h |  349 ++++++
 2 files changed, 3897 insertions(+)

diff -ruP net-next-2.6-orig/drivers/net/bna/bnad.c net-next-2.6-mod/drivers/net/bna/bnad.c
--- net-next-2.6-orig/drivers/net/bna/bnad.c	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6-mod/drivers/net/bna/bnad.c	2009-11-23 13:36:23.217870000 -0800
@@ -0,0 +1,3548 @@
+/*
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2006-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
+
+/**
+ *  bnad.c  Brocade 10G PCIe Ethernet driver.
+ */
+
+#include <linux/kernel.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/pci.h>
+#include <linux/bitops.h>
+#include <linux/etherdevice.h>
+#include <linux/in.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+#include <linux/delay.h>
+#include <linux/rtnetlink.h>
+#include <linux/if_ether.h>
+#include <linux/workqueue.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/pm.h>
+#include <linux/random.h>
+
+#include <net/checksum.h>
+
+#include "bnad.h"
+#include "cna.h"
+#include "bna_iocll.h"
+#include "bna_intr.h"
+#include "bnad_defs.h"
+
+#define BNAD_TXQ_WI_NEEDED(_vectors)	(((_vectors) + 3) >> 2)
+const static bool bnad_msix = 1;
+const static bool bnad_small_large_rxbufs = 1;
+static uint bnad_rxqsets_used;
+const static bool bnad_ipid_mode;
+const static bool bnad_vlan_strip = 1;
+const static uint bnad_txq_depth = BNAD_ENTRIES_PER_TXQ;
+const static uint bnad_rxq_depth = BNAD_ENTRIES_PER_RXQ;
+static uint bnad_log_level ;
+
+static uint bnad_ioc_auto_recover = 1;
+module_param(bnad_ioc_auto_recover, uint, 0444);
+MODULE_PARM_DESC(bnad_ioc_auto_recover, "Enable auto recovery");
+
+uint bnad_rxqs_per_cq = 2;
+
+const char *bnad_states[] = {
+	"START",
+	"INIT",
+	"INIT_DOWN",
+	"INIT_DISABLING",
+	"INIT_DISABLED",
+	"OPENING",
+	"OPEN",
+	"OPEN_DOWN",
+	"OPEN_DISABING",
+	"OPEN_DISABLED",
+	"CLOSING",
+	"UNLOADING"
+};
+
+static void bnad_disable_msix(struct bnad *bnad);
+static void bnad_free_ibs(struct bnad *bnad);
+static void bnad_set_rx_mode(struct net_device *netdev);
+static void bnad_set_rx_mode_locked(struct net_device *netdev);
+static void bnad_reconfig_vlans(struct bnad *bnad);
+static void bnad_q_num_init(struct bnad *bnad, uint rxqsets);
+static int bnad_set_mac_address(struct net_device *netdev, void *addr);
+static int bnad_set_mac_address_locked(struct net_device *netdev, void *addr);
+static int bnad_disable_locked(struct bnad *bnad);
+static int bnad_change_mtu(struct net_device *netdev, int new_mtu);
+static void
+bnad_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
+static void bnad_vlan_rx_add_vid(struct net_device *netdev, unsigned short vid);
+static void
+bnad_vlan_rx_kill_vid(struct net_device *netdev, unsigned short vid);
+static void bnad_netpoll(struct net_device *netdev);
+
+static const struct net_device_ops bnad_netdev_ops = {
+	.ndo_open			= bnad_open,
+	.ndo_stop			= bnad_stop,
+	.ndo_start_xmit			= bnad_start_xmit,
+	.ndo_get_stats			= bnad_get_stats,
+	.ndo_set_rx_mode		= &bnad_set_rx_mode,
+	.ndo_set_multicast_list		= bnad_set_rx_mode,
+	.ndo_set_mac_address		= bnad_set_mac_address,
+	.ndo_change_mtu			= bnad_change_mtu,
+
+	.ndo_vlan_rx_register		= bnad_vlan_rx_register,
+	.ndo_vlan_rx_add_vid		= bnad_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid		= bnad_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller		= bnad_netpoll,
+#endif
+};
+
+u32 bnad_get_msglevel(struct net_device *netdev)
+{
+	return bnad_log_level;
+}
+
+void bnad_set_msglevel(struct net_device *netdev, u32 msglevel)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	bnad_conf_lock();
+	bnad_log_level = msglevel;
+	bnad_conf_unlock();
+}
+
+static unsigned int bnad_free_txbufs(struct bnad_txq_info *txqinfo,
+	u16 updated_txq_cons)
+{
+	struct bnad *bnad = txqinfo->bnad;
+	unsigned int sent_packets = 0, sent_bytes = 0;
+	u16 wis, unmap_cons;
+	struct bnad_skb_unmap *unmap_array;
+	struct sk_buff *skb;
+	int i;
+
+	wis = BNAD_Q_INDEX_CHANGE(txqinfo->txq.q.consumer_index,
+				  updated_txq_cons, txqinfo->txq.q.q_depth);
+	BNA_ASSERT(wis <=
+		   BNA_QE_IN_USE_CNT(&txqinfo->txq.q, txqinfo->txq.q.q_depth));
+	unmap_array = txqinfo->skb_unmap_q.unmap_array;
+	unmap_cons = txqinfo->skb_unmap_q.consumer_index;
+	prefetch(&unmap_array[unmap_cons + 1]);
+	while (wis) {
+		skb = unmap_array[unmap_cons].skb;
+		BNA_ASSERT(skb);
+		unmap_array[unmap_cons].skb = NULL;
+		BNA_ASSERT(wis >=
+			   BNAD_TXQ_WI_NEEDED(1 + skb_shinfo(skb)->nr_frags));
+		BNA_ASSERT(((txqinfo->skb_unmap_q.producer_index -
+			     unmap_cons) & (txqinfo->skb_unmap_q.q_depth -
+					    1)) >=
+			   1 + skb_shinfo(skb)->nr_frags);
+
+		sent_packets++;
+		sent_bytes += skb->len;
+		wis -= BNAD_TXQ_WI_NEEDED(1 + skb_shinfo(skb)->nr_frags);
+
+		pci_unmap_single(bnad->pcidev,
+				 pci_unmap_addr(&unmap_array[unmap_cons],
+						dma_addr), skb_headlen(skb),
+				 PCI_DMA_TODEVICE);
+		pci_unmap_addr_set(&unmap_array[unmap_cons], dma_addr, 0);
+		BNA_QE_INDX_ADD(unmap_cons, 1, txqinfo->skb_unmap_q.q_depth);
+		prefetch(&unmap_array[unmap_cons + 1]);
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			pci_unmap_page(bnad->pcidev,
+				       pci_unmap_addr(&unmap_array[unmap_cons],
+						      dma_addr),
+				       skb_shinfo(skb)->frags[i].size,
+				       PCI_DMA_TODEVICE);
+			pci_unmap_addr_set(&unmap_array[unmap_cons], dma_addr,
+					   0);
+			BNA_QE_INDX_ADD(unmap_cons, 1,
+					txqinfo->skb_unmap_q.q_depth);
+			prefetch(&unmap_array[unmap_cons + 1]);
+		}
+		dev_kfree_skb_any(skb);
+	}
+
+	/* Update consumer pointers. */
+	txqinfo->txq.q.consumer_index = updated_txq_cons;
+	txqinfo->skb_unmap_q.consumer_index = unmap_cons;
+	txqinfo->tx_packets += sent_packets;
+	txqinfo->tx_bytes += sent_bytes;
+	return sent_packets;
+}
+
+static inline void bnad_disable_txrx_irqs(struct bnad *bnad)
+{
+	int i;
+
+	for (i = 0; i < bnad->txq_num; i++) {
+		bna_ib_coalescing_timer_set(bnad->priv, &bnad->txq_table[i].ib,
+					    0);
+		bna_ib_ack(bnad->priv, &bnad->txq_table[i].ib, 0);
+	}
+
+	for (i = 0; i < bnad->cq_num; i++) {
+		bna_ib_coalescing_timer_set(bnad->priv, &bnad->cq_table[i].ib,
+					    0);
+		bna_ib_ack(bnad->priv, &bnad->cq_table[i].ib, 0);
+	}
+}
+
+static inline void bnad_enable_txrx_irqs(struct bnad *bnad)
+{
+	int i;
+
+	spin_lock_irq(&bnad->priv_lock);
+	for (i = 0; i < bnad->txq_num; i++) {
+		bna_ib_coalescing_timer_set(bnad->priv, &bnad->txq_table[i].ib,
+					    bnad->tx_coalescing_timeo);
+		bna_ib_ack(bnad->priv, &bnad->txq_table[i].ib, 0);
+	}
+
+	for (i = 0; i < bnad->cq_num; i++) {
+		bna_ib_coalescing_timer_set(bnad->priv, &bnad->cq_table[i].ib,
+					    bnad->cq_table[i].
+					    rx_coalescing_timeo);
+		bna_ib_ack(bnad->priv, &bnad->cq_table[i].ib, 0);
+	}
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+static inline void bnad_disable_rx_irq(struct bnad *bnad,
+	struct bnad_cq_info *cqinfo)
+{
+	bna_ib_coalescing_timer_set(bnad->priv, &cqinfo->ib, 0);
+	bna_ib_ack(bnad->priv, &cqinfo->ib, 0);
+}
+static inline void bnad_enable_rx_irq(struct bnad *bnad,
+	struct bnad_cq_info *cqinfo)
+{
+	spin_lock_irq(&bnad->priv_lock);
+
+	bna_ib_coalescing_timer_set(bnad->priv, &cqinfo->ib,
+				    cqinfo->rx_coalescing_timeo);
+
+	bna_ib_ack(bnad->priv, &cqinfo->ib, 0);
+
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+static unsigned int bnad_tx(struct bnad *bnad, struct bnad_txq_info *txqinfo)
+{
+	struct net_device *netdev = bnad->netdev;
+	unsigned int sent;
+
+	if (test_and_set_bit(BNAD_TXQ_FREE_SENT, &txqinfo->flags))
+		return 0;
+
+	sent = bnad_free_txbufs(txqinfo,
+				(u16) (*txqinfo->hw_consumer_index));
+	if (sent) {
+		if (netif_queue_stopped(netdev) &&
+		    BNA_Q_FREE_COUNT(&txqinfo->txq) >=
+		    BNAD_NETIF_WAKE_THRESHOLD) {
+			netif_wake_queue(netdev);
+			bnad->stats.netif_queue_wakeup++;
+		}
+		bna_ib_ack(bnad->priv, &txqinfo->ib, sent);
+	} else {
+		bna_ib_ack(bnad->priv, &txqinfo->ib, 0);
+	}
+
+	smp_mb__before_clear_bit();
+	clear_bit(BNAD_TXQ_FREE_SENT, &txqinfo->flags);
+
+	return sent;
+}
+
+static irqreturn_t bnad_msix_tx(int irq, void *data)
+{
+	struct bnad_txq_info *txqinfo = (struct bnad_txq_info *)data;
+	struct bnad *bnad = txqinfo->bnad;
+
+	bnad_tx(bnad, txqinfo);
+
+	return IRQ_HANDLED;
+}
+
+static void bnad_alloc_rxbufs(struct bnad_rxq_info *rxqinfo)
+{
+	u16 to_alloc, alloced, unmap_prod, wi_range;
+	struct bnad_skb_unmap *unmap_array;
+	struct bna_rxq_entry *rxent;
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
+
+	alloced = 0;
+	to_alloc =
+		BNA_QE_FREE_CNT(&rxqinfo->skb_unmap_q,
+				rxqinfo->skb_unmap_q.q_depth);
+
+	unmap_array = rxqinfo->skb_unmap_q.unmap_array;
+	unmap_prod = rxqinfo->skb_unmap_q.producer_index;
+	BNA_RXQ_QPGE_PTR_GET(unmap_prod, &rxqinfo->rxq.q, rxent, wi_range);
+	BNA_ASSERT(wi_range && wi_range <= rxqinfo->rxq.q.q_depth);
+
+	while (to_alloc--) {
+		if (!wi_range) {
+			BNA_RXQ_QPGE_PTR_GET(unmap_prod, &rxqinfo->rxq.q, rxent,
+					     wi_range);
+			BNA_ASSERT(wi_range &&
+				   wi_range <= rxqinfo->rxq.q.q_depth);
+		}
+		skb = alloc_skb(rxqinfo->rxq_config.buffer_size + NET_IP_ALIGN,
+				GFP_ATOMIC);
+		if (unlikely(!skb)) {
+			rxqinfo->rxbuf_alloc_failed++;
+			goto finishing;
+		}
+		skb->dev = rxqinfo->bnad->netdev;
+		skb_reserve(skb, NET_IP_ALIGN);
+		unmap_array[unmap_prod].skb = skb;
+		dma_addr =
+			pci_map_single(rxqinfo->bnad->pcidev, skb->data,
+				       rxqinfo->rxq_config.buffer_size,
+				       PCI_DMA_FROMDEVICE);
+		pci_unmap_addr_set(&unmap_array[unmap_prod], dma_addr,
+				   dma_addr);
+		BNA_SET_DMA_ADDR(dma_addr, &rxent->host_addr);
+		BNA_QE_INDX_ADD(unmap_prod, 1, rxqinfo->skb_unmap_q.q_depth);
+
+		rxent++;
+		wi_range--;
+		alloced++;
+	}
+
+finishing:
+	if (likely(alloced)) {
+		rxqinfo->skb_unmap_q.producer_index = unmap_prod;
+		rxqinfo->rxq.q.producer_index = unmap_prod;
+		smp_mb();
+		bna_rxq_prod_indx_doorbell(&rxqinfo->rxq);
+	}
+}
+
+static inline void bnad_refill_rxq(struct bnad_rxq_info *rxqinfo)
+{
+	if (!test_and_set_bit(BNAD_RXQ_REFILL, &rxqinfo->flags)) {
+		if (BNA_QE_FREE_CNT
+		    (&rxqinfo->skb_unmap_q,
+		     rxqinfo->skb_unmap_q.
+		     q_depth) >> BNAD_RXQ_REFILL_THRESHOLD_SHIFT)
+			bnad_alloc_rxbufs(rxqinfo);
+		smp_mb__before_clear_bit();
+		clear_bit(BNAD_RXQ_REFILL, &rxqinfo->flags);
+	}
+}
+
+static unsigned int bnad_poll_cq(struct bnad *bnad,
+	struct bnad_cq_info *cqinfo, int budget)
+{
+	struct bna_cq_entry *cmpl, *next_cmpl;
+	unsigned int wi_range, packets = 0, wis = 0;
+	struct bnad_rxq_info *rxqinfo = NULL;
+	struct bnad_unmap_q *unmap_q;
+	struct sk_buff *skb;
+	u32 flags;
+	struct bna_pkt_rate *pkt_rt = &cqinfo->pkt_rate;
+
+	prefetch(bnad->netdev);
+	cmpl = bna_cq_pg_prod_ptr(&cqinfo->cq, &wi_range);
+	BNA_ASSERT(wi_range && wi_range <= cqinfo->cq.q.q_depth);
+	while (cmpl->valid && packets < budget) {
+		packets++;
+		BNA_UPDATE_PKT_CNT(pkt_rt, ntohs(cmpl->length));
+
+		rxqinfo = &bnad->rxq_table[cmpl->rxq_id];
+		unmap_q = &rxqinfo->skb_unmap_q;
+
+		skb = unmap_q->unmap_array[unmap_q->consumer_index].skb;
+		BNA_ASSERT(skb);
+		prefetch(skb->data - NET_IP_ALIGN);
+		unmap_q->unmap_array[unmap_q->consumer_index].skb = NULL;
+		pci_unmap_single(bnad->pcidev,
+				 pci_unmap_addr(&unmap_q->
+						unmap_array[unmap_q->
+							    consumer_index],
+						dma_addr),
+				 rxqinfo->rxq_config.buffer_size,
+				 PCI_DMA_FROMDEVICE);
+		BNA_QE_INDX_ADD(unmap_q->consumer_index, 1, unmap_q->q_depth);
+		/* XXX May be bad for performance. */
+		/* CATAPULT_BRINGUP : Should we add all the packets ? */
+		BNA_Q_CI_ADD(&rxqinfo->rxq, 1);
+
+		wis++;
+		if (likely(--wi_range))
+			next_cmpl = cmpl + 1;
+		else {
+			BNA_Q_PI_ADD(&cqinfo->cq, wis);
+			wis = 0;
+			next_cmpl = bna_cq_pg_prod_ptr(&cqinfo->cq, &wi_range);
+			BNA_ASSERT(wi_range &&
+				   wi_range <= cqinfo->cq.q.q_depth);
+		}
+		prefetch(next_cmpl);
+
+		flags = ntohl(cmpl->flags);
+		if (unlikely
+		    (flags &
+		     (BNA_CQ_EF_MAC_ERROR | BNA_CQ_EF_FCS_ERROR |
+		      BNA_CQ_EF_TOO_LONG))) {
+			dev_kfree_skb(skb);
+			rxqinfo->rx_packets_with_error++;
+			goto next;
+		}
+
+		skb_put(skb, ntohs(cmpl->length));
+		if (likely
+		    (bnad->rx_csum &&
+		     (((flags & BNA_CQ_EF_IPV4) &&
+		      (flags & BNA_CQ_EF_L3_CKSUM_OK)) ||
+		      (flags & BNA_CQ_EF_IPV6)) &&
+		      (flags & (BNA_CQ_EF_TCP | BNA_CQ_EF_UDP)) &&
+		      (flags & BNA_CQ_EF_L4_CKSUM_OK)))
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		else
+			skb->ip_summed = CHECKSUM_NONE;
+
+		rxqinfo->rx_packets++;
+		rxqinfo->rx_bytes += skb->len;
+		skb->protocol = eth_type_trans(skb, bnad->netdev);
+
+		if (bnad->vlangrp && (flags & BNA_CQ_EF_VLAN) &&
+		    bnad_vlan_strip) {
+			BNA_ASSERT(cmpl->vlan_tag);
+			vlan_hwaccel_receive_skb(skb, bnad->vlangrp,
+						 ntohs(cmpl->vlan_tag));
+		} else
+			netif_receive_skb(skb);
+next:
+		cmpl->valid = 0;
+		cmpl = next_cmpl;
+	}
+
+	BNA_Q_PI_ADD(&cqinfo->cq, wis);
+
+	if (likely(rxqinfo)) {
+		bna_ib_ack(bnad->priv, &cqinfo->ib, packets);
+		/* Check the current queue first. */
+		bnad_refill_rxq(rxqinfo);
+
+		/* XXX counters per queue for refill? */
+		if (likely(bnad_small_large_rxbufs)) {
+			/* There are 2 RxQs - small and large buffer queues */
+			unsigned int rxq_id = (rxqinfo->rxq_id ^ 1);
+			bnad_refill_rxq(&bnad->rxq_table[rxq_id]);
+		}
+	} else {
+		bna_ib_ack(bnad->priv, &cqinfo->ib, 0);
+	}
+
+	return packets;
+}
+
+static irqreturn_t bnad_msix_rx(int irq, void *data)
+{
+	struct bnad_cq_info *cqinfo = (struct bnad_cq_info *)data;
+	struct bnad *bnad = cqinfo->bnad;
+
+	if (likely(napi_schedule_prep(&cqinfo->napi))) {
+		bnad_disable_rx_irq(bnad, cqinfo);
+		__napi_schedule(&cqinfo->napi);
+	}
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t bnad_msix_err_mbox(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct bnad *bnad = netdev_priv(netdev);
+	u32 intr_status;
+
+	spin_lock(&bnad->priv_lock);
+
+	bna_intr_status_get(bnad->priv, &intr_status);
+	if (BNA_IS_MBOX_ERR_INTR(intr_status))
+		bna_mbox_err_handler(bnad->priv, intr_status);
+
+	spin_unlock(&bnad->priv_lock);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t bnad_isr(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct bnad *bnad = netdev_priv(netdev);
+	u32 intr_status;
+
+	spin_lock(&bnad->priv_lock);
+	bna_intr_status_get(bnad->priv, &intr_status);
+
+	if (!intr_status) {
+		spin_unlock(&bnad->priv_lock);
+		return IRQ_NONE;
+	}
+
+	if (BNA_IS_MBOX_ERR_INTR(intr_status)) {
+		bna_mbox_err_handler(bnad->priv, intr_status);
+		spin_unlock(&bnad->priv_lock);
+		if (BNA_IS_ERR_INTR(intr_status) ||
+		    !BNA_IS_INTX_DATA_INTR(intr_status))
+			goto exit_isr;
+	} else
+		spin_unlock(&bnad->priv_lock);
+
+	if (likely(napi_schedule_prep(&bnad->cq_table[0].napi))) {
+		bnad_disable_txrx_irqs(bnad);
+		__napi_schedule(&bnad->cq_table[0].napi);
+	}
+
+exit_isr:
+	return IRQ_HANDLED;
+}
+
+static int bnad_request_mbox_irq(struct bnad *bnad)
+{
+	int err;
+
+	if (bnad->config & BNAD_CF_MSIX) {
+		err = request_irq(bnad->msix_table[bnad->msix_num - 1].vector,
+				  &bnad_msix_err_mbox, 0,
+				  bnad->netdev->name, bnad->netdev);
+	} else {
+		err = request_irq(bnad->pcidev->irq, &bnad_isr,
+				  IRQF_SHARED, bnad->netdev->name,
+				  bnad->netdev);
+	}
+
+	if (err) {
+		dev_err(&bnad->pcidev->dev,
+			"Request irq for mailbox failed: %d\n", err);
+		return err;
+	}
+
+	if (bnad->config & BNAD_CF_MSIX)
+		bna_mbox_msix_idx_set(bnad->priv, bnad->msix_num - 1);
+
+	bna_mbox_intr_enable(bnad->priv);
+	return 0;
+}
+
+static void bnad_sync_mbox_irq(struct bnad *bnad)
+{
+	uint irq;
+
+	if (bnad->config & BNAD_CF_MSIX)
+		irq = bnad->msix_table[bnad->msix_num - 1].vector;
+	else
+		irq = bnad->pcidev->irq;
+	synchronize_irq(irq);
+}
+
+static void bnad_free_mbox_irq(struct bnad *bnad)
+{
+	uint irq;
+
+	if (bnad->config & BNAD_CF_MSIX)
+		irq = bnad->msix_table[bnad->msix_num - 1].vector;
+	else
+		irq = bnad->pcidev->irq;
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_mbox_intr_disable(bnad->priv);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	free_irq(irq, bnad->netdev);
+}
+
+static int bnad_request_txq_irq(struct bnad *bnad, uint txq_id)
+{
+	BNA_ASSERT(txq_id < bnad->txq_num);
+	if (!(bnad->config & BNAD_CF_MSIX))
+		return 0;
+	return request_irq(bnad->msix_table[txq_id].vector,
+			   &bnad_msix_tx, 0,
+			   bnad->txq_table[txq_id].name,
+			   &bnad->txq_table[txq_id]);
+}
+
+int bnad_request_cq_irq(struct bnad *bnad, uint cq_id)
+{
+	BNA_ASSERT(cq_id < bnad->cq_num);
+	if (!(bnad->config & BNAD_CF_MSIX))
+		return 0;
+	return request_irq(bnad->msix_table[bnad->txq_num + cq_id].vector,
+			   &bnad_msix_rx, 0,
+			   bnad->cq_table[cq_id].name, &bnad->cq_table[cq_id]);
+}
+
+static int bnad_request_txrx_irqs(struct bnad *bnad)
+{
+	struct msix_entry *entries;
+	int i;
+	int err;
+	char message[BNA_MESSAGE_SIZE];
+
+	if (!(bnad->config & BNAD_CF_MSIX)) {
+		u32 mask;
+		bna_intx_disable(bnad->priv, &mask);
+		mask &= ~0xffff;
+		bna_intx_enable(bnad->priv, mask);
+		for (i = 0; i < bnad->ib_num; i++)
+			bna_ib_ack(bnad->priv, bnad->ib_table[i].ib, 0);
+		return 0;
+	}
+
+	entries = bnad->msix_table;
+	for (i = 0; i < bnad->txq_num; i++) {
+		err = bnad_request_txq_irq(bnad, i);
+		if (err) {
+			sprintf(message, "%s request irq for TxQ %d failed %d",
+				bnad->netdev->name, i, err);
+			while (--i >= 0) {
+				free_irq(entries[i].vector,
+					 &bnad->txq_table[i]);
+			}
+			return err;
+		}
+	}
+
+	for (i = 0; i < bnad->cq_num; i++) {
+		err = bnad_request_cq_irq(bnad, i);
+		if (err) {
+			sprintf(message, "%s request irq for CQ %u failed %d",
+				bnad->netdev->name, i, err);
+			while (--i >= 0) {
+				free_irq(entries[bnad->txq_num + i].vector,
+					 &bnad->cq_table[i]);
+			}
+			goto free_txq_irqs;
+		}
+	}
+
+	return 0;
+
+free_txq_irqs:
+	for (i = 0; i < bnad->txq_num; i++)
+		free_irq(entries[i].vector, &bnad->txq_table[i]);
+
+	bnad_disable_msix(bnad);
+
+	return err;
+}
+
+static void bnad_free_txrx_irqs(struct bnad *bnad)
+{
+	struct msix_entry *entries;
+	uint i;
+
+	if (bnad->config & BNAD_CF_MSIX) {
+		entries = bnad->msix_table;
+		for (i = 0; i < bnad->txq_num; i++)
+			free_irq(entries[i].vector, &bnad->txq_table[i]);
+
+		for (i = 0; i < bnad->cq_num; i++) {
+			free_irq(entries[bnad->txq_num + i].vector,
+				 &bnad->cq_table[i]);
+		}
+	} else
+		synchronize_irq(bnad->pcidev->irq);
+}
+
+void bnad_setup_ib(struct bnad *bnad, uint ib_id)
+{
+	struct bnad_ib_entry *ib_entry;
+
+	BNA_ASSERT(ib_id < bnad->ib_num);
+	ib_entry = &bnad->ib_table[ib_id];
+	spin_lock_irq(&bnad->priv_lock);
+	bna_ib_config_set(bnad->priv, ib_entry->ib, ib_id,
+			  &ib_entry->ib_config);
+	/* Start the IB */
+	bna_ib_ack(bnad->priv, ib_entry->ib, 0);
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+static void bnad_setup_ibs(struct bnad *bnad)
+{
+	int i;
+
+	for (i = 0; i < bnad->txq_num; i++)
+		bnad_setup_ib(bnad, bnad->txq_table[i].txq_config.ib_id);
+
+	for (i = 0; i < bnad->cq_num; i++)
+		bnad_setup_ib(bnad, bnad->cq_table[i].cq_config.ib_id);
+}
+
+/* These functions are called back with priv_lock held. */
+
+static void bnad_lldp_get_cfg_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = arg;
+	bnad->lldp_comp_status = status;
+	complete(&bnad->lldp_comp);
+}
+
+static void bnad_cee_get_attr_cb(void *arg, bfa_status_t status)
+{
+	struct bnad *bnad = arg;
+	bnad->lldp_comp_status = status;
+	complete(&bnad->lldp_comp);
+}
+
+static void bnad_cee_get_stats_cb(void *arg, bfa_status_t status)
+{
+	struct bnad *bnad = arg;
+	bnad->cee_stats_comp_status = status;
+	complete(&bnad->cee_stats_comp);
+}
+
+static void bnad_cee_reset_stats_cb(void *arg, bfa_status_t status)
+{
+	struct bnad *bnad = arg;
+	bnad->cee_reset_stats_status = status;
+	complete(&bnad->cee_reset_stats_comp);
+}
+
+static void bnad_ucast_set_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = (struct bnad *)arg;
+
+	bnad->ucast_comp_status = status;
+	complete(&bnad->ucast_comp);
+}
+
+static void bnad_q_stop_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = arg;
+
+	bnad->qstop_comp_status = status;
+	complete(&bnad->qstop_comp);
+}
+
+static unsigned int bnad_get_priority(struct bnad *bnad, u8 prio_map)
+{
+	unsigned int i;
+
+	if (prio_map) {
+		for (i = 0; i < 8; i++) {
+			if ((prio_map >> i) & 0x1)
+				break;
+		}
+		return i;
+	}
+	return 0;
+}
+
+static void bnad_link_up_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = (struct bnad *)arg;
+	struct bfi_ll_aen *up_aen = (struct bfi_ll_aen *)
+		(&bnad->priv->mb_msg);
+
+	bnad->cee_linkup = up_aen->cee_linkup;
+	bnad->priority = bnad_get_priority(bnad, up_aen->prio_map);
+
+	bnad->link_state = BNAD_LS_UP;
+	bnad->work_flags |= BNAD_WF_LS_NOTIFY;
+
+	schedule_work(&bnad->work);
+}
+
+static void bnad_link_down_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = (struct bnad *)arg;
+
+	bnad->link_state = BNAD_LS_DOWN;
+	bnad->work_flags |= BNAD_WF_LS_NOTIFY;
+
+	schedule_work(&bnad->work);
+}
+
+static void bnad_stats_get_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = (struct bnad *)arg;
+
+	bnad->stats.hw_stats_updates++;
+	if (bnad->state == BNAD_S_OPEN)
+		mod_timer(&bnad->stats_timer, jiffies + HZ);
+}
+
+/* Called with bnad priv_lock held. */
+static void bnad_hw_error(struct bnad *bnad, u8 status)
+{
+	unsigned int irq;
+	char message[BNA_MESSAGE_SIZE];
+
+	set_bit(BNAD_F_HWERROR, &bnad->flags);
+
+	bna_mbox_intr_disable(bnad->priv);
+	if (bnad->config & BNAD_CF_MSIX) {
+		if (!test_and_set_bit(BNAD_F_MBOX_IRQ_DISABLED, &bnad->flags)) {
+			irq = bnad->msix_table[bnad->msix_num - 1].vector;
+			sprintf(message, "Disabling Mbox IRQ %d for port %d",
+				irq, bnad->bna_id);
+		DPRINTK(INFO, "%s",
+				message);
+			disable_irq_nosync(irq);
+		}
+	}
+
+	bna_cleanup(bnad->priv);
+
+	bnad->work_flags = BNAD_WF_ERROR;
+	if (bnad->state != BNAD_S_UNLOADING)
+		schedule_work(&bnad->work);
+}
+
+static void bnad_hw_error_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = (struct bnad *)arg;
+
+	bnad_hw_error(bnad, status);
+}
+
+int bnad_alloc_unmap_q(struct bnad_unmap_q *unmap_q, u32 q_depth)
+{
+	/* Q_depth must be power of 2 for macros to work. */
+	BNA_ASSERT(BNA_POWER_OF_2(q_depth));
+	unmap_q->q_depth = q_depth;
+	unmap_q->unmap_array = vmalloc(q_depth * sizeof(struct bnad_skb_unmap));
+	if (!unmap_q->unmap_array)
+		return -ENOMEM;
+	memset(unmap_q->unmap_array, 0,
+	       q_depth * sizeof(struct bnad_skb_unmap));
+	return 0;
+}
+
+static int bnad_alloc_unmap_queues(struct bnad *bnad)
+{
+	int i, err = 0;
+	struct bnad_txq_info *txqinfo;
+	struct bnad_rxq_info *rxqinfo;
+	char message[BNA_MESSAGE_SIZE];
+
+	for (i = 0; i < bnad->txq_num; i++) {
+		txqinfo = &bnad->txq_table[i];
+		err = bnad_alloc_unmap_q(&txqinfo->skb_unmap_q,
+					 txqinfo->txq.q.q_depth * 4);
+		if (err) {
+			sprintf(message,
+				"%s allocating Tx unmap Q %d failed: %d",
+				bnad->netdev->name, i, err);
+			return err;
+		}
+	}
+	for (i = 0; i < bnad->rxq_num; i++) {
+		rxqinfo = &bnad->rxq_table[i];
+		err = bnad_alloc_unmap_q(&rxqinfo->skb_unmap_q,
+					 rxqinfo->rxq.q.q_depth);
+		if (err) {
+			sprintf(message,
+				"%s allocating Rx unmap Q %d failed: %d",
+				bnad->netdev->name, i, err);
+			return err;
+		}
+	}
+	return 0;
+}
+
+static void bnad_reset_q(struct bnad *bnad, struct bna_q *q,
+	struct bnad_unmap_q *unmap_q)
+{
+	u32 _ui;
+
+	BNA_ASSERT(q->producer_index == q->consumer_index);
+	BNA_ASSERT(unmap_q->producer_index == unmap_q->consumer_index);
+
+	q->producer_index = 0;
+	q->consumer_index = 0;
+	unmap_q->producer_index = 0;
+	unmap_q->consumer_index = 0;
+
+	for (_ui = 0; _ui < unmap_q->q_depth; _ui++)
+		BNA_ASSERT(!unmap_q->unmap_array[_ui].skb);
+}
+
+static void bnad_flush_rxbufs(struct bnad_rxq_info *rxqinfo)
+{
+	struct bnad *bnad = rxqinfo->bnad;
+	struct bnad_unmap_q *unmap_q;
+	struct sk_buff *skb;
+	u32 cq_id;
+
+	unmap_q = &rxqinfo->skb_unmap_q;
+	while (BNA_QE_IN_USE_CNT(unmap_q, unmap_q->q_depth)) {
+		skb = unmap_q->unmap_array[unmap_q->consumer_index].skb;
+		BNA_ASSERT(skb);
+		unmap_q->unmap_array[unmap_q->consumer_index].skb = NULL;
+		pci_unmap_single(bnad->pcidev,
+				 pci_unmap_addr(&unmap_q->
+						unmap_array[unmap_q->
+							    consumer_index],
+						dma_addr),
+				 rxqinfo->rxq_config.buffer_size + NET_IP_ALIGN,
+				 PCI_DMA_FROMDEVICE);
+		dev_kfree_skb(skb);
+		BNA_QE_INDX_ADD(unmap_q->consumer_index, 1, unmap_q->q_depth);
+		BNA_Q_CI_ADD(&rxqinfo->rxq, 1);
+	}
+
+	bnad_reset_q(bnad, &rxqinfo->rxq.q, &rxqinfo->skb_unmap_q);
+	cq_id = rxqinfo->rxq_id / bnad_rxqs_per_cq;
+	*bnad->cq_table[cq_id].hw_producer_index = 0;
+}
+
+/* Should be called with conf_lock held. */
+static int bnad_disable_txq(struct bnad *bnad, u32 txq_id)
+{
+	int err;
+	char message[BNA_MESSAGE_SIZE];
+
+	WARN_ON(in_interrupt());
+
+	init_completion(&bnad->qstop_comp);
+	spin_lock_irq(&bnad->priv_lock);
+	err = bna_txq_stop(bnad->priv, txq_id);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	if (err) {
+		if (err == BNA_AGAIN)
+			err = 0;
+		goto txq_stop_exit;
+	}
+
+	if (BNAD_NOT_READY(bnad)) {
+		err = BNA_FAIL;
+		goto txq_stop_exit;
+	}
+	wait_for_completion(&bnad->qstop_comp);
+	err = bnad->qstop_comp_status;
+
+	if (err == BFI_LL_CMD_NOT_EXEC) {
+		if (bnad->state == BNAD_S_CLOSING)
+			err = 0;
+		else
+			err = BNA_FAIL;
+	}
+
+txq_stop_exit:
+	if (err) {
+		sprintf(message, "%s stop TxQ %u failed %d", bnad->netdev->name,
+			txq_id, err);
+		DPRINTK(INFO, "%s", message);
+	}
+
+	return err;
+}
+
+/* Should be called with conf_lock held. */
+int bnad_disable_rxqs(struct bnad *bnad, u64 rxq_id_mask)
+{
+	int err;
+	char message[BNA_MESSAGE_SIZE];
+
+	WARN_ON(in_interrupt());
+
+	init_completion(&bnad->qstop_comp);
+
+	spin_lock_irq(&bnad->priv_lock);
+	err = bna_multi_rxq_stop(bnad->priv, rxq_id_mask);
+	spin_unlock_irq(&bnad->priv_lock);
+	if (err) {
+		if (err == BNA_AGAIN)
+			err = 0;
+		goto rxq_stop_exit;
+	}
+
+	if (BNAD_NOT_READY(bnad)) {
+		err = BNA_FAIL;
+		goto rxq_stop_exit;
+	}
+	wait_for_completion(&bnad->qstop_comp);
+
+	err = bnad->qstop_comp_status;
+
+	if (err == BFI_LL_CMD_NOT_EXEC) {
+		if (bnad->state == BNAD_S_CLOSING)
+			err = 0;
+		else
+			err = BNA_FAIL;
+	}
+
+rxq_stop_exit:
+	if (err) {
+		sprintf(message, "%s stop RxQs(0x%llu) failed %d",
+			bnad->netdev->name, rxq_id_mask, err);
+		DPRINTK(INFO, "%s", message);
+	}
+
+	return err;
+}
+
+static int bnad_poll_rx(struct napi_struct *napi, int budget)
+{
+	struct bnad_cq_info *cqinfo =
+		container_of(napi, struct bnad_cq_info, napi);
+	struct bnad *bnad = cqinfo->bnad;
+	unsigned int rcvd;
+
+	rcvd = bnad_poll_cq(bnad, cqinfo, budget);
+	if (rcvd == budget)
+		return rcvd;
+	napi_complete(napi);
+	bnad->stats.napi_complete++;
+	bnad_enable_rx_irq(bnad, cqinfo);
+	return rcvd;
+}
+
+static int bnad_poll_txrx(struct napi_struct *napi, int budget)
+{
+	struct bnad_cq_info *cqinfo =
+		container_of(napi, struct bnad_cq_info, napi);
+	struct bnad *bnad = cqinfo->bnad;
+	unsigned int rcvd;
+
+	bnad_tx(bnad, &bnad->txq_table[0]);
+	rcvd = bnad_poll_cq(bnad, cqinfo, budget);
+	if (rcvd == budget)
+		return rcvd;
+	napi_complete(napi);
+	bnad->stats.napi_complete++;
+	bnad_enable_txrx_irqs(bnad);
+	return rcvd;
+}
+
+static void bnad_napi_init(struct bnad *bnad)
+{
+	int (*napi_poll) (struct napi_struct *, int);
+	int i;
+
+	if (bnad->config & BNAD_CF_MSIX)
+		napi_poll = bnad_poll_rx;
+	else
+		napi_poll = bnad_poll_txrx;
+
+	for (i = 0; i < bnad->cq_num; i++)
+		netif_napi_add(bnad->netdev, &bnad->cq_table[i].napi, napi_poll,
+			       64);
+}
+
+static void bnad_napi_enable(struct bnad *bnad)
+{
+	int i;
+
+	for (i = 0; i < bnad->cq_num; i++)
+		napi_enable(&bnad->cq_table[i].napi);
+}
+
+static void bnad_napi_disable(struct bnad *bnad)
+{
+	int i;
+
+	for (i = 0; i < bnad->cq_num; i++)
+		napi_disable(&bnad->cq_table[i].napi);
+}
+
+static void bnad_napi_uninit(struct bnad *bnad)
+{
+	int i;
+
+	for (i = 0; i < bnad->cq_num; i++)
+		netif_napi_del(&bnad->cq_table[i].napi);
+}
+
+static void bnad_stop_data_path(struct bnad *bnad, int on_error)
+{
+	int i;
+
+	spin_lock_irq(&bnad->priv_lock);
+	if (!on_error && !BNAD_NOT_READY(bnad)) {
+		bna_txf_disable(bnad->priv, BNAD_TX_FUNC_ID);
+		bna_multi_rxf_disable(bnad->priv, (1 << bnad->rxf_num) - 1);
+		for (i = 0; i < bnad->txq_num; i++)
+			bna_ib_disable(bnad->priv, &bnad->txq_table[i].ib);
+		for (i = 0; i < bnad->cq_num; i++)
+			bna_ib_disable(bnad->priv, &bnad->cq_table[i].ib);
+	}
+	spin_unlock_irq(&bnad->priv_lock);
+
+	/* Wait to make sure Tx and Rx are stopped. */
+	msleep(1000);
+	bnad_free_txrx_irqs(bnad);
+	bnad_sync_mbox_irq(bnad);
+
+	bnad_napi_disable(bnad);
+	bnad_napi_uninit(bnad);
+	/* Delete the stats timer after synchronize with mbox irq. */
+	del_timer_sync(&bnad->stats_timer);
+
+	netif_tx_disable(bnad->netdev);
+	netif_carrier_off(bnad->netdev);
+
+	/*
+	 * Remove tasklets if scheduled
+	 */
+	tasklet_kill(&bnad->tx_free_tasklet);
+}
+
+static void bnad_port_admin_locked(struct bnad *bnad, u8 up)
+{
+
+	spin_lock_irq(&bnad->priv_lock);
+	if (!BNAD_NOT_READY(bnad)) {
+		bna_port_admin(bnad->priv, up);
+		if (up)
+			mod_timer(&bnad->stats_timer, jiffies + HZ);
+		else
+			bnad->link_state = BNAD_LS_DOWN;
+	}
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+/* Should be called with conf_lock held */
+static int bnad_stop_locked_internal(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	char message[BNA_MESSAGE_SIZE];
+
+	switch (bnad->state) {
+	case BNAD_S_OPEN:
+		bnad->state = BNAD_S_CLOSING;
+		bnad_disable_locked(bnad);
+		bnad->state = BNAD_S_INIT;
+		sprintf(message, "%s is stopped", bnad->netdev->name);
+		DPRINTK(INFO, "%s", message);
+		break;
+	case BNAD_S_OPEN_DOWN:
+		bnad->state = BNAD_S_INIT_DOWN;
+		break;
+	case BNAD_S_OPEN_DISABLED:
+		bnad->state = BNAD_S_INIT_DISABLED;
+		break;
+	default:
+		break;
+	}
+
+	return 0;
+}
+
+/* Should be called with conf_lock held */
+int bnad_ioc_disabling_locked(struct bnad *bnad)
+{
+	switch (bnad->state) {
+	case BNAD_S_INIT:
+	case BNAD_S_INIT_DOWN:
+		bnad->state = BNAD_S_INIT_DISABLING;
+		break;
+	case BNAD_S_OPEN:
+		bnad->state = BNAD_S_OPEN_DISABLING;
+		bnad_port_admin_locked(bnad, BNA_DISABLE);
+		bnad_disable_locked(bnad);
+		break;
+	case BNAD_S_OPEN_DOWN:
+		bnad->state = BNAD_S_OPEN_DISABLING;
+		break;
+	default:
+		break;
+	}
+	return 0;
+}
+
+static int bnad_alloc_ib(struct bnad *bnad, uint ib_id)
+{
+	struct bnad_ib_entry *ib_entry;
+	dma_addr_t dma_addr;
+
+	BNA_ASSERT(bnad->ib_table && ib_id < bnad->ib_num);
+	ib_entry = &bnad->ib_table[ib_id];
+	ib_entry->ib_seg_addr =
+		pci_alloc_consistent(bnad->pcidev, L1_CACHE_BYTES, &dma_addr);
+	if (!ib_entry->ib_seg_addr)
+		return -ENOMEM;
+
+	BNA_SET_DMA_ADDR(dma_addr, &ib_entry->ib_config.ib_seg_addr);
+	return 0;
+}
+static int bnad_alloc_ibs(struct bnad *bnad)
+{
+	uint i;
+	int err;
+
+	bnad->ib_num = bnad->txq_num + bnad->cq_num;
+	bnad->ib_table =
+		kzalloc(bnad->ib_num * sizeof(struct bnad_ib_entry),
+			GFP_KERNEL);
+	if (!bnad->ib_table)
+		return -ENOMEM;
+
+	for (i = 0; i < bnad->ib_num; i++) {
+		err = bnad_alloc_ib(bnad, i);
+		if (err)
+			goto free_ibs;
+	}
+	return 0;
+
+free_ibs:
+	bnad_free_ibs(bnad);
+	return err;
+}
+
+void bnad_free_ib(struct bnad *bnad, uint ib_id)
+{
+	struct bnad_ib_entry *ib_entry;
+	dma_addr_t dma_addr;
+
+	BNA_ASSERT(bnad->ib_table && ib_id < bnad->ib_num);
+	ib_entry = &bnad->ib_table[ib_id];
+	if (ib_entry->ib_seg_addr) {
+		BNA_GET_DMA_ADDR(&ib_entry->ib_config.ib_seg_addr, dma_addr);
+		pci_free_consistent(bnad->pcidev, L1_CACHE_BYTES,
+				    ib_entry->ib_seg_addr, dma_addr);
+		ib_entry->ib_seg_addr = NULL;
+	}
+}
+
+static void bnad_free_ibs(struct bnad *bnad)
+{
+	uint i;
+
+	if (!bnad->ib_table)
+		return;
+	for (i = 0; i < bnad->ib_num; i++)
+		bnad_free_ib(bnad, i);
+	kfree(bnad->ib_table);
+	bnad->ib_table = NULL;
+}
+
+/* Let the caller deal with error - free memory. */
+static int bnad_alloc_q(struct bnad *bnad, struct bna_qpt *qpt,
+	struct bna_q *q, size_t qsize)
+{
+	size_t i;
+	dma_addr_t dma_addr;
+
+	qsize = ALIGN(qsize, PAGE_SIZE);
+	qpt->page_count = qsize >> PAGE_SHIFT;
+	qpt->page_size = PAGE_SIZE;
+
+	qpt->kv_qpt_ptr =
+		pci_alloc_consistent(bnad->pcidev,
+				     qpt->page_count *
+				     sizeof(struct bna_dma_addr), &dma_addr);
+	if (!qpt->kv_qpt_ptr)
+		return -ENOMEM;
+	BNA_SET_DMA_ADDR(dma_addr, &qpt->hw_qpt_ptr);
+
+	q->qpt_ptr = kzalloc(qpt->page_count * sizeof(void *), GFP_KERNEL);
+	if (!q->qpt_ptr)
+		return -ENOMEM;
+	qpt->qpt_ptr = q->qpt_ptr;
+	for (i = 0; i < qpt->page_count; i++) {
+		q->qpt_ptr[i] =
+			pci_alloc_consistent(bnad->pcidev, PAGE_SIZE,
+					     &dma_addr);
+		if (!q->qpt_ptr[i])
+			return -ENOMEM;
+		BNA_SET_DMA_ADDR(dma_addr,
+				 &((struct bna_dma_addr *)qpt->kv_qpt_ptr)[i]);
+
+	}
+
+	return 0;
+}
+
+static void bnad_free_q(struct bnad *bnad, struct bna_qpt *qpt,
+	struct bna_q *q)
+{
+	int i;
+	dma_addr_t dma_addr;
+
+	if (qpt->kv_qpt_ptr && q->qpt_ptr) {
+		for (i = 0; i < qpt->page_count; i++) {
+			if (q->qpt_ptr[i]) {
+				BNA_GET_DMA_ADDR(&
+						 ((struct bna_dma_addr *)qpt->
+						  kv_qpt_ptr)[i], dma_addr);
+				pci_free_consistent(bnad->pcidev, PAGE_SIZE,
+						    q->qpt_ptr[i], dma_addr);
+			}
+		}
+	}
+
+	kfree(q->qpt_ptr);
+	qpt->qpt_ptr = q->qpt_ptr = NULL;
+
+	if (qpt->kv_qpt_ptr) {
+		BNA_GET_DMA_ADDR(&qpt->hw_qpt_ptr, dma_addr);
+		pci_free_consistent(bnad->pcidev,
+				    qpt->page_count *
+				    sizeof(struct bna_dma_addr),
+				    qpt->kv_qpt_ptr, dma_addr);
+		qpt->kv_qpt_ptr = NULL;
+	}
+}
+
+static void bnad_free_txq(struct bnad *bnad, uint txq_id)
+{
+	struct bnad_txq_info *txqinfo;
+
+	BNA_ASSERT(bnad->txq_table && txq_id < bnad->txq_num);
+	txqinfo = &bnad->txq_table[txq_id];
+	bnad_free_q(bnad, &txqinfo->txq_config.qpt, &txqinfo->txq.q);
+	if (txqinfo->skb_unmap_q.unmap_array) {
+		bnad_free_txbufs(txqinfo, txqinfo->txq.q.producer_index);
+		vfree(txqinfo->skb_unmap_q.unmap_array);
+		txqinfo->skb_unmap_q.unmap_array = NULL;
+	}
+}
+
+void bnad_free_rxq(struct bnad *bnad, uint rxq_id)
+{
+	struct bnad_rxq_info *rxqinfo;
+
+	BNA_ASSERT(bnad->rxq_table && rxq_id < bnad->rxq_num);
+	rxqinfo = &bnad->rxq_table[rxq_id];
+	bnad_free_q(bnad, &rxqinfo->rxq_config.qpt, &rxqinfo->rxq.q);
+	if (rxqinfo->skb_unmap_q.unmap_array) {
+		bnad_flush_rxbufs(rxqinfo);
+		vfree(rxqinfo->skb_unmap_q.unmap_array);
+		rxqinfo->skb_unmap_q.unmap_array = NULL;
+	}
+}
+
+void bnad_free_cq(struct bnad *bnad, uint cq_id)
+{
+	struct bnad_cq_info *cqinfo = &bnad->cq_table[cq_id];
+
+	BNA_ASSERT(bnad->cq_table && cq_id < bnad->cq_num);
+	bnad_free_q(bnad, &cqinfo->cq_config.qpt, &cqinfo->cq.q);
+}
+
+static void bnad_free_queues(struct bnad *bnad)
+{
+	uint i;
+
+	if (bnad->txq_table) {
+		for (i = 0; i < bnad->txq_num; i++)
+			bnad_free_txq(bnad, i);
+		kfree(bnad->txq_table);
+		bnad->txq_table = NULL;
+	}
+
+	if (bnad->rxq_table) {
+		for (i = 0; i < bnad->rxq_num; i++)
+			bnad_free_rxq(bnad, i);
+		kfree(bnad->rxq_table);
+		bnad->rxq_table = NULL;
+	}
+
+	if (bnad->cq_table) {
+		for (i = 0; i < bnad->cq_num; i++)
+			bnad_free_cq(bnad, i);
+		kfree(bnad->cq_table);
+		bnad->cq_table = NULL;
+	}
+}
+
+static int bnad_txq_init(struct bnad *bnad, uint txq_id)
+{
+	struct bnad_txq_info *txqinfo;
+	int err;
+
+	BNA_ASSERT(bnad->txq_table && txq_id < bnad->txq_num);
+	txqinfo = &bnad->txq_table[txq_id];
+	err = bnad_alloc_q(bnad, &txqinfo->txq_config.qpt, &txqinfo->txq.q,
+			   bnad->txq_depth * sizeof(struct bna_txq_entry));
+	if (err) {
+		bnad_free_q(bnad, &txqinfo->txq_config.qpt, &txqinfo->txq.q);
+		return err;
+	}
+	txqinfo->txq.q.q_depth = bnad->txq_depth;
+	txqinfo->bnad = bnad;
+	txqinfo->txq_config.txf_id = BNAD_TX_FUNC_ID;
+	snprintf(txqinfo->name, sizeof(txqinfo->name), "%s TxQ %d",
+		 bnad->netdev->name, txq_id);
+	return 0;
+}
+
+static int bnad_txqs_init(struct bnad *bnad)
+{
+	int i, err = 0;
+
+	bnad->txq_table =
+		kzalloc(bnad->txq_num * sizeof(struct bnad_txq_info),
+			GFP_KERNEL);
+	if (!bnad->txq_table)
+		return -ENOMEM;
+
+	for (i = 0; i < bnad->txq_num; i++) {
+		err = bnad_txq_init(bnad, i);
+		if (err)
+			break;
+	}
+	return err;
+}
+
+int bnad_rxq_init(struct bnad *bnad, uint rxq_id)
+{
+	struct bnad_rxq_info *rxqinfo;
+	int err;
+
+	BNA_ASSERT(bnad->rxq_table && rxq_id < bnad->rxq_num);
+	rxqinfo = &bnad->rxq_table[rxq_id];
+	err = bnad_alloc_q(bnad, &rxqinfo->rxq_config.qpt, &rxqinfo->rxq.q,
+			   bnad->rxq_depth * sizeof(struct bna_rxq_entry));
+	if (err) {
+		bnad_free_q(bnad, &rxqinfo->rxq_config.qpt, &rxqinfo->rxq.q);
+		return err;
+	}
+	rxqinfo->rxq.q.q_depth = bnad->rxq_depth;
+	rxqinfo->bnad = bnad;
+	rxqinfo->rxq_id = rxq_id;
+	rxqinfo->rxq_config.cq_id = rxq_id / bnad_rxqs_per_cq;
+
+	return 0;
+}
+
+static int bnad_rxqs_init(struct bnad *bnad)
+{
+	int i, err = 0;
+
+	bnad->rxq_table =
+		kzalloc(bnad->rxq_num * sizeof(struct bnad_rxq_info),
+			GFP_KERNEL);
+	if (!bnad->rxq_table)
+		return -EINVAL;
+
+	for (i = 0; i < bnad->rxq_num; i++) {
+		err = bnad_rxq_init(bnad, i);
+		if (err)
+			break;
+	}
+	return err;
+}
+
+int bnad_cq_init(struct bnad *bnad, uint cq_id)
+{
+	struct bnad_cq_info *cqinfo;
+	int err;
+
+	BNA_ASSERT(bnad->cq_table && cq_id < bnad->cq_num);
+	cqinfo = &bnad->cq_table[cq_id];
+	err = bnad_alloc_q(bnad, &cqinfo->cq_config.qpt, &cqinfo->cq.q,
+			   bnad->rxq_depth * bnad_rxqs_per_cq *
+			   sizeof(struct bna_cq_entry));
+	if (err) {
+		bnad_free_q(bnad, &cqinfo->cq_config.qpt, &cqinfo->cq.q);
+		return err;
+	}
+
+	cqinfo->cq.q.q_depth = bnad->rxq_depth * bnad_rxqs_per_cq;
+	cqinfo->bnad = bnad;
+
+	cqinfo->rx_coalescing_timeo = bnad->rx_coalescing_timeo;
+
+	cqinfo->cq_id = cq_id;
+	snprintf(cqinfo->name, sizeof(cqinfo->name), "%s CQ %d",
+		 bnad->netdev->name, cq_id);
+
+	return 0;
+}
+
+static int bnad_cqs_init(struct bnad *bnad)
+{
+	int i, err = 0;
+
+	bnad->cq_table =
+		kzalloc(bnad->cq_num * sizeof(struct bnad_cq_info), GFP_KERNEL);
+	if (!bnad->cq_table)
+		return -ENOMEM;
+
+	for (i = 0; i < bnad->cq_num; i++) {
+		err = bnad_cq_init(bnad, i);
+		if (err)
+			break;
+	}
+	return err;
+}
+
+static uint bnad_get_qsize(uint qsize_conf, uint mtu)
+{
+	uint qsize;
+
+	if (mtu >= ETH_DATA_LEN) {
+		qsize = qsize_conf / (mtu / ETH_DATA_LEN);
+		if (!BNA_POWER_OF_2(qsize))
+			BNA_TO_POWER_OF_2_HIGH(qsize);
+		if (qsize < BNAD_MIN_Q_DEPTH)
+			qsize = BNAD_MIN_Q_DEPTH;
+	} else
+		qsize = bnad_txq_depth;
+
+	return qsize;
+}
+
+static int bnad_init_queues(struct bnad *bnad)
+{
+	int err;
+
+	if (!(bnad->config & BNAD_CF_TXQ_DEPTH))
+		bnad->txq_depth =
+			bnad_get_qsize(bnad_txq_depth, bnad->netdev->mtu);
+	if (!(bnad->config & BNAD_CF_RXQ_DEPTH))
+		bnad->rxq_depth =
+			bnad_get_qsize(bnad_rxq_depth, bnad->netdev->mtu);
+
+	err = bnad_txqs_init(bnad);
+	if (err)
+		return err;
+
+	err = bnad_rxqs_init(bnad);
+	if (err)
+		return err;
+
+	err = bnad_cqs_init(bnad);
+
+	return err;
+}
+
+void bnad_rxib_init(struct bnad *bnad, uint cq_id, uint ib_id)
+{
+	struct bnad_cq_info *cqinfo;
+	struct bnad_ib_entry *ib_entry;
+	struct bna_ib_config *ib_config;
+
+	BNA_ASSERT(cq_id < bnad->cq_num && ib_id < bnad->ib_num);
+	cqinfo = &bnad->cq_table[cq_id];
+	ib_entry = &bnad->ib_table[ib_id];
+
+	cqinfo->hw_producer_index = (u32 *) (ib_entry->ib_seg_addr);
+	cqinfo->cq_config.ib_id = ib_id;
+	cqinfo->cq_config.ib_seg_index = 0;
+
+	ib_entry->ib = &cqinfo->ib;
+	ib_config = &ib_entry->ib_config;
+	ib_config->coalescing_timer = bnad->rx_coalescing_timeo;
+	ib_config->control_flags =
+		BNA_IB_CF_INT_ENABLE | BNA_IB_CF_MASTER_ENABLE;
+	if (bnad->config & BNAD_CF_MSIX) {
+		ib_config->control_flags |= BNA_IB_CF_MSIX_MODE;
+		ib_config->msix_vector = ib_id;
+	} else
+		ib_config->msix_vector = 1 << ib_id;
+
+	/* Every CQ has its own IB. */
+	ib_config->seg_size = 1;
+	ib_config->index_table_offset = ib_id;
+}
+
+static void bnad_ibs_init(struct bnad *bnad)
+{
+	struct bnad_ib_entry *ib_entry;
+	struct bna_ib_config *ib_config;
+	struct bnad_txq_info *txqinfo;
+
+	int ib_id, i;
+
+	ib_id = 0;
+	for (i = 0; i < bnad->txq_num; i++) {
+		txqinfo = &bnad->txq_table[i];
+		ib_entry = &bnad->ib_table[ib_id];
+
+		txqinfo->hw_consumer_index = ib_entry->ib_seg_addr;
+		txqinfo->txq_config.ib_id = ib_id;
+		txqinfo->txq_config.ib_seg_index = 0;
+
+		ib_entry->ib = &txqinfo->ib;
+		ib_config = &ib_entry->ib_config;
+		ib_config->coalescing_timer = bnad->tx_coalescing_timeo;
+		ib_config->control_flags =
+			BNA_IB_CF_INTER_PKT_DMA | BNA_IB_CF_INT_ENABLE |
+			BNA_IB_CF_COALESCING_MODE | BNA_IB_CF_MASTER_ENABLE;
+		if (bnad->config & BNAD_CF_MSIX) {
+			ib_config->control_flags |= BNA_IB_CF_MSIX_MODE;
+			ib_config->msix_vector = ib_id;
+		} else
+			ib_config->msix_vector = 1 << ib_id;
+		ib_config->interpkt_count = bnad->tx_interpkt_count;
+
+		/* Every TxQ has its own IB. */
+		ib_config->seg_size = 1;
+		ib_config->index_table_offset = ib_id;
+		ib_id++;
+	}
+
+	for (i = 0; i < bnad->cq_num; i++, ib_id++)
+		bnad_rxib_init(bnad, i, ib_id);
+}
+
+static void bnad_txf_init(struct bnad *bnad, uint txf_id)
+{
+	struct bnad_txf_info *txf_info;
+
+	BNA_ASSERT(bnad->txf_table && txf_id < bnad->txf_num);
+	txf_info = &bnad->txf_table[txf_id];
+	txf_info->txf_id = txf_id;
+	txf_info->txf_config.flags =
+		BNA_TXF_CF_VLAN_WI_BASED | BNA_TXF_CF_ENABLE;
+}
+
+void bnad_rxf_init(struct bnad *bnad, uint rxf_id, u8 rit_offset, int rss)
+{
+	struct bnad_rxf_info *rxf_info;
+
+	BNA_ASSERT(bnad->rxf_table && rxf_id < bnad->rxf_num);
+	rxf_info = &bnad->rxf_table[rxf_id];
+	rxf_info->rxf_id = rxf_id;
+	rxf_info->rxf_config.rit_offset = rit_offset;
+	rxf_info->rxf_config.mcast_rxq_id = BNAD_MULTICAST_RXQ_ID;
+	if (bnad_small_large_rxbufs)
+		rxf_info->rxf_config.flags |= BNA_RXF_CF_SM_LG_RXQ;
+	if (bnad_vlan_strip)
+		rxf_info->rxf_config.flags |= BNA_RXF_CF_VLAN_STRIP;
+	if (rss) {
+		struct bna_rxf_rss *rxf_rss;
+
+		rxf_info->rxf_config.flags |= BNA_RXF_CF_RSS_ENABLE;
+		rxf_rss = &rxf_info->rxf_config.rss;
+		rxf_rss->type =
+			BNA_RSS_V4_TCP | BNA_RSS_V4_IP | BNA_RSS_V6_TCP |
+			BNA_RSS_V6_IP;
+		rxf_rss->hash_mask = bnad->cq_num - 1;
+		get_random_bytes(rxf_rss->toeplitz_hash_key,
+				 sizeof(rxf_rss->toeplitz_hash_key));
+	}
+}
+
+static int bnad_init_funcs(struct bnad *bnad)
+{
+	bnad->txf_table =
+		kzalloc(sizeof(struct bnad_txf_info) * bnad->txf_num,
+			GFP_KERNEL);
+	if (!bnad->txf_table)
+		return -ENOMEM;
+	bnad_txf_init(bnad, BNAD_TX_FUNC_ID);
+
+	bnad->rxf_table =
+		kzalloc(sizeof(struct bnad_rxf_info) * bnad->rxf_num,
+			GFP_KERNEL);
+	if (!bnad->rxf_table)
+		return -ENOMEM;
+	bnad_rxf_init(bnad, BNAD_RX_FUNC_ID, BNAD_RIT_OFFSET,
+		      (bnad->cq_num > 1) ? 1 : 0);
+	return 0;
+}
+
+static void bnad_setup_txq(struct bnad *bnad, uint txq_id)
+{
+	struct bnad_txq_info *txqinfo;
+
+	BNA_ASSERT(txq_id < bnad->txq_num);
+	txqinfo = &bnad->txq_table[txq_id];
+
+	/* CEE state should not change while we do this */
+	spin_lock_irq(&bnad->priv_lock);
+	if (!bnad->cee_linkup) {
+		txqinfo->txq_config.priority = bnad->curr_priority = txq_id;
+		clear_bit(BNAD_F_CEE_RUNNING, &bnad->flags);
+	} else {
+		txqinfo->txq_config.priority = bnad->curr_priority =
+			bnad->priority;
+		set_bit(BNAD_F_CEE_RUNNING, &bnad->flags);
+	}
+	/*  Set wrr_quota properly if multiple priorities/TxQs are enabled. */
+	txqinfo->txq_config.wrr_quota = BNAD_TX_MAX_WRR_QUOTA;
+	bna_txq_config(bnad->priv, &txqinfo->txq, txq_id, &txqinfo->txq_config);
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+void bnad_setup_rxq(struct bnad *bnad, uint rxq_id)
+{
+	struct bnad_rxq_info *rxqinfo;
+
+	BNA_ASSERT(rxq_id < bnad->rxq_num);
+	rxqinfo = &bnad->rxq_table[rxq_id];
+
+	/*
+	 * Every RxQ set has 2 RxQs: the first is large buffer RxQ,
+	 * the second is small buffer RxQ.
+	 */
+	if ((rxq_id % bnad_rxqs_per_cq) == 0)
+		rxqinfo->rxq_config.buffer_size =
+			(bnad_vlan_strip ? VLAN_ETH_HLEN : ETH_HLEN) +
+			bnad->netdev->mtu + ETH_FCS_LEN;
+	else
+		rxqinfo->rxq_config.buffer_size = BNAD_SMALL_RXBUF_SIZE;
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_rxq_config(bnad->priv, &rxqinfo->rxq, rxq_id, &rxqinfo->rxq_config);
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+void bnad_setup_cq(struct bnad *bnad, uint cq_id)
+{
+	struct bnad_cq_info *cqinfo;
+
+	BNA_ASSERT(cq_id < bnad->cq_num);
+	cqinfo = &bnad->cq_table[cq_id];
+	spin_lock_irq(&bnad->priv_lock);
+	bna_cq_config(bnad->priv, &cqinfo->cq, cq_id, &cqinfo->cq_config);
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+static void bnad_setup_queues(struct bnad *bnad)
+{
+	uint i;
+
+	for (i = 0; i < bnad->txq_num; i++)
+		bnad_setup_txq(bnad, i);
+
+	for (i = 0; i < bnad->rxq_num; i++)
+		bnad_setup_rxq(bnad, i);
+
+	for (i = 0; i < bnad->cq_num; i++)
+		bnad_setup_cq(bnad, i);
+}
+
+static void bnad_setup_rit(struct bnad *bnad)
+{
+	int i, size;
+
+	size = bnad->cq_num;
+	for (i = 0; i < size; i++) {
+		if (bnad_small_large_rxbufs) {
+			bnad->rit[i].large_rxq_id = (i << 1);
+			bnad->rit[i].small_rxq_id = (i << 1) + 1;
+		} else {
+			bnad->rit[i].large_rxq_id = i;
+		}
+	}
+	spin_lock_irq(&bnad->priv_lock);
+	bna_rit_config_set(bnad->priv, BNAD_RIT_OFFSET, bnad->rit, size);
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+void bnad_alloc_for_rxq(struct bnad *bnad, uint rxq_id)
+{
+	struct bnad_rxq_info *rxqinfo = &bnad->rxq_table[rxq_id];
+	u16 rxbufs;
+
+	BNA_ASSERT(bnad->rxq_table && rxq_id < bnad->rxq_num);
+	bnad_alloc_rxbufs(rxqinfo);
+	rxbufs = BNA_QE_IN_USE_CNT(&rxqinfo->skb_unmap_q,
+				   rxqinfo->skb_unmap_q.q_depth);
+}
+
+static int bnad_config_hw(struct bnad *bnad)
+{
+	int i, err = 0;
+	u64 rxq_id_mask = 0;
+	struct sockaddr sa;
+	struct net_device *netdev = bnad->netdev;
+
+	spin_lock_irq(&bnad->priv_lock);
+	if (BNAD_NOT_READY(bnad))
+		goto unlock_and_return;
+
+	/* Disable the RxF until later bringing port up. */
+	bna_multi_rxf_disable(bnad->priv, (1 << bnad->rxf_num) - 1);
+	for (i = 0; i < bnad->txq_num; i++) {
+		spin_unlock_irq(&bnad->priv_lock);
+		err = bnad_disable_txq(bnad, i);
+		spin_lock_irq(&bnad->priv_lock);
+		if (err || BNAD_NOT_READY(bnad))
+			goto unlock_and_return;
+	}
+	for (i = 0; i < bnad->rxq_num; i++)
+		rxq_id_mask |= (1 << i);
+	if (rxq_id_mask) {
+		spin_unlock_irq(&bnad->priv_lock);
+		err = bnad_disable_rxqs(bnad, rxq_id_mask);
+		spin_lock_irq(&bnad->priv_lock);
+		if (err || BNAD_NOT_READY(bnad))
+			goto unlock_and_return;
+	}
+	spin_unlock_irq(&bnad->priv_lock);
+
+	bnad_setup_queues(bnad);
+
+	bnad_setup_rit(bnad);
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_txf_config_set(bnad->priv, BNAD_TX_FUNC_ID,
+			   &bnad->txf_table->txf_config);
+	for (i = 0; i < bnad->rxf_num; i++) {
+		bna_rxf_config_set(bnad->priv, i,
+				   &bnad->rxf_table[i].rxf_config);
+		bna_rxf_vlan_filter(bnad->priv, i, BNA_ENABLE);
+	}
+
+	spin_unlock_irq(&bnad->priv_lock);
+	/* Mailbox should be enabled before this! */
+	memcpy(sa.sa_data, netdev->dev_addr, netdev->addr_len);
+	err = bnad_set_mac_address_locked(netdev, &sa);
+	spin_lock_irq(&bnad->priv_lock);
+	if (err || BNAD_NOT_READY(bnad))
+		goto unlock_and_return;
+
+	/* Receive broadcasts */
+	bna_rxf_broadcast(bnad->priv, BNAD_RX_FUNC_ID, BNA_ENABLE);
+
+	bna_mtu_info(bnad->priv, netdev->mtu, bnad);
+	bna_set_pause_config(bnad->priv, &bnad->pause_config, bnad);
+
+	bna_rxf_mcast_del_all(bnad->priv, BNAD_RX_FUNC_ID);
+	bna_mcast_mac_reset_list(bnad->priv);
+
+	bnad_set_rx_mode_locked(bnad->netdev);
+
+	bnad_reconfig_vlans(bnad);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	bnad_setup_ibs(bnad);
+	return 0;
+
+unlock_and_return:
+	if (BNAD_NOT_READY(bnad))
+		err = BNA_FAIL;
+	spin_unlock_irq(&bnad->priv_lock);
+	return err;
+}
+
+/* Note: bnad_cleanup doesn't free irqs */
+static void bnad_cleanup(struct bnad *bnad)
+{
+
+	kfree(bnad->rit);
+	bnad->rit = NULL;
+
+	kfree(bnad->txf_table);
+	bnad->txf_table = NULL;
+
+	kfree(bnad->rxf_table);
+	bnad->rxf_table = NULL;
+
+	bnad_free_ibs(bnad);
+	bnad_free_queues(bnad);
+}
+
+/* Should be called with rtnl_lock held. */
+static int bnad_init(struct bnad *bnad)
+{
+	int err;
+
+	err = bnad_alloc_ibs(bnad);
+	if (err)
+		goto finished;
+
+	err = bnad_init_queues(bnad);
+	if (err)
+		goto finished;
+
+	bnad_ibs_init(bnad);
+
+	err = bnad_init_funcs(bnad);
+	if (err)
+		goto finished;
+
+	err = bnad_alloc_unmap_queues(bnad);
+	if (err)
+		goto finished;
+
+	bnad->rit =
+		kzalloc(bnad->cq_num * sizeof(struct bna_rit_entry),
+			GFP_KERNEL);
+	if (!bnad->rit)
+		goto finished;
+
+	return 0;
+
+finished:
+	bnad_cleanup(bnad);
+	return err;
+}
+
+static int bnad_enable_locked(struct bnad *bnad)
+{
+	struct net_device *netdev = bnad->netdev;
+	int err = 0;
+	uint i;
+	char message[BNA_MESSAGE_SIZE];
+
+	bnad->state = BNAD_S_OPENING;
+
+	err = bnad_init(bnad);
+	if (err) {
+		sprintf(message, "%s init failed %d", netdev->name, err);
+		DPRINTK(INFO, "%s",
+			message);
+		bnad->state = BNAD_S_INIT;
+		return err;
+	}
+
+	err = bnad_config_hw(bnad);
+	if (err) {
+		sprintf(message, "%s config HW failed %d", netdev->name, err);
+		DPRINTK(INFO, "%s",
+			message);
+		goto init_failed;
+	}
+
+	err = bnad_request_txrx_irqs(bnad);
+	if (err) {
+		sprintf(message, "%s requests Tx/Rx irqs failed: %d",
+			bnad->netdev->name, err);
+		DPRINTK(INFO, "%s",
+			message);
+		goto init_failed;
+	}
+	bnad_napi_init(bnad);
+	bnad_napi_enable(bnad);
+	for (i = 0; i < bnad->rxq_num; i++)
+		bnad_alloc_for_rxq(bnad, i);
+
+	bnad->state = BNAD_S_OPEN;
+	sprintf(message, "%s is opened", bnad->netdev->name);
+		DPRINTK(INFO, "%s", message);
+
+	spin_lock_irq(&bnad->priv_lock);
+	if (BNAD_NOT_READY(bnad)) {
+		/* Let bnad_error take care of the error. */
+		spin_unlock_irq(&bnad->priv_lock);
+		return 0;
+	}
+
+	/* RxF was disabled earlier. */
+	bna_rxf_enable(bnad->priv, BNAD_RX_FUNC_ID);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	return 0;
+
+init_failed:
+	bnad_cleanup(bnad);
+	bnad->state = BNAD_S_INIT;
+	return err;
+}
+
+/* Should be called with conf_lock held */
+static int bnad_open_locked_internal(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err = 0;
+	char message[BNA_MESSAGE_SIZE];
+
+	switch (bnad->state) {
+	case BNAD_S_INIT:
+		err = bnad_enable_locked(bnad);
+		break;
+	case BNAD_S_INIT_DOWN:
+		bnad->state = BNAD_S_OPEN_DOWN;
+		sprintf(message, "%s is not ready yet: IOC down", netdev->name);
+		DPRINTK(INFO, "%s", message);
+		break;
+	case BNAD_S_INIT_DISABLED:
+		bnad->state = BNAD_S_OPEN_DISABLED;
+		sprintf(message, "%s is not ready yet: IOC disabled",
+			netdev->name);
+		DPRINTK(INFO, "%s", message);
+		break;
+	default:
+		BNA_ASSERT(0);
+		break;
+	}
+	return err;
+}
+
+int bnad_open_locked(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err;
+
+	err = bnad_open_locked_internal(netdev);
+
+	if (!err && (bnad->state == BNAD_S_OPEN))
+		bnad_port_admin_locked(bnad, BNA_ENABLE);
+
+	return err;
+}
+
+int bnad_open(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err = 0;
+	char message[BNA_MESSAGE_SIZE];
+
+	sprintf(message, "%s open", netdev->name);
+		DPRINTK(INFO, "%s", message);
+
+	bnad_conf_lock();
+
+	if (test_bit(BNAD_F_BCU_DISABLED, &bnad->flags)) {
+		sprintf(message, "%s is disabled", netdev->name);
+		DPRINTK(INFO, "%s", message);
+	} else
+		err = bnad_open_locked(netdev);
+
+	bnad_conf_unlock();
+
+	return err;
+}
+
+static int bnad_disable_locked(struct bnad *bnad)
+{
+	int err = 0, i;
+	u64 rxq_id_mask = 0;
+
+	bnad_stop_data_path(bnad, 0);
+
+	for (i = 0; i < bnad->txq_num; i++) {
+		err = bnad_disable_txq(bnad, i);
+		if (err)
+			goto cleanup;
+	}
+
+	for (i = 0; i < bnad->rxq_num; i++)
+		rxq_id_mask |= (1 << i);
+	if (rxq_id_mask) {
+		err = bnad_disable_rxqs(bnad, rxq_id_mask);
+		if (err)
+			goto cleanup;
+	}
+
+cleanup:
+	bnad_cleanup(bnad);
+	return err;
+}
+
+int bnad_stop_locked(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	if (bnad->state == BNAD_S_OPEN)
+		bnad_port_admin_locked(bnad, BNA_DISABLE);
+
+	return bnad_stop_locked_internal(netdev);
+}
+
+int bnad_stop(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err = 0;
+	char message[BNA_MESSAGE_SIZE];
+
+	sprintf(message, "%s stop", netdev->name);
+		DPRINTK(INFO, "%s", message);
+
+	bnad_conf_lock();
+
+	if (test_bit(BNAD_F_BCU_DISABLED, &bnad->flags)) {
+		sprintf(message, "%s port is disabled", netdev->name);
+		DPRINTK(INFO, "%s", message);
+	} else
+		err = bnad_stop_locked(netdev);
+
+	bnad_conf_unlock();
+
+	return err;
+}
+
+/* Should be called with conf_lock held. */
+int bnad_sw_reset_locked_internal(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err;
+	char message[BNA_MESSAGE_SIZE];
+
+	err = bnad_stop_locked_internal(netdev);
+	if (err) {
+		sprintf(message, "%s sw reset internal: stop failed %d",
+			bnad->netdev->name, err);
+		goto done;
+	}
+
+	err = bnad_open_locked_internal(netdev);
+
+	if (err) {
+		sprintf(message, "%s sw reset internal: open failed %d",
+			bnad->netdev->name, err);
+		goto done;
+	}
+	return 0;
+done:
+		DPRINTK(INFO, "%s", message);
+	return err;
+}
+
+/* Should be called with conf_lock held. */
+int bnad_sw_reset_locked(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err;
+	char message[BNA_MESSAGE_SIZE];
+
+	if (bnad->state != BNAD_S_OPEN)
+		return 0;
+
+	bnad_port_admin_locked(bnad, BNA_DISABLE);
+
+	err = bnad_sw_reset_locked_internal(netdev);
+
+	if (err) {
+		sprintf(message, "%s sw reset: failed %d", bnad->netdev->name,
+			err);
+		DPRINTK(INFO, "%s", message);
+		return err;
+	}
+
+	/* After the reset, make sure we are in the OPEN state) */
+	if (bnad->state == BNAD_S_OPEN)
+		bnad_port_admin_locked(bnad, BNA_ENABLE);
+
+	return 0;
+}
+
+static int bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
+{
+	int err;
+
+	BNA_ASSERT(skb_shinfo(skb)->gso_type == SKB_GSO_TCPV4 ||
+		   skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6);
+	if (skb_header_cloned(skb)) {
+		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		if (err) {
+			bnad->stats.tso_err++;
+			return err;
+		}
+	}
+
+	/*
+	 * For TSO, the TCP checksum field is seeded with pseudo-header sum
+	 * excluding the length field.
+	 */
+	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = ip_hdr(skb);
+
+		/* Do we really need these? */
+		iph->tot_len = 0;
+		iph->check = 0;
+
+		tcp_hdr(skb)->check =
+			~csum_tcpudp_magic(iph->saddr, iph->daddr, 0,
+					   IPPROTO_TCP, 0);
+		bnad->stats.tso4++;
+	} else {
+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+
+		BNA_ASSERT(skb->protocol == htons(ETH_P_IPV6));
+		ipv6h->payload_len = 0;
+		tcp_hdr(skb)->check =
+			~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, 0,
+					 IPPROTO_TCP, 0);
+		bnad->stats.tso6++;
+	}
+
+	return 0;
+}
+
+netdev_tx_t bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct bnad_txq_info *txqinfo;
+	struct bna_txq *txq;
+	struct bnad_unmap_q *unmap_q;
+	u16 txq_prod, vlan_tag = 0;
+	unsigned int unmap_prod, wis, wis_used, wi_range;
+	unsigned int vectors, vect_id, i, acked;
+	int err;
+	dma_addr_t dma_addr;
+	struct bna_txq_entry *txqent;
+	bna_txq_wi_ctrl_flag_t flags;
+
+	if (unlikely
+	    (skb->len <= ETH_HLEN || skb->len > BNAD_TX_MAX_DATA_PER_WI)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	txqinfo = &bnad->txq_table[0];
+	txq = &txqinfo->txq;
+	unmap_q = &txqinfo->skb_unmap_q;
+
+	vectors = 1 + skb_shinfo(skb)->nr_frags;
+	if (vectors > BNAD_TX_MAX_VECTORS) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+	wis = BNAD_TXQ_WI_NEEDED(vectors);	/* 4 vectors per work item */
+	acked = 0;
+	if (unlikely
+	    (wis > BNA_Q_FREE_COUNT(txq) ||
+	     vectors > BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth))) {
+		if ((u16) (*txqinfo->hw_consumer_index) !=
+		    txq->q.consumer_index &&
+		    !test_and_set_bit(BNAD_TXQ_FREE_SENT, &txqinfo->flags)) {
+			acked = bnad_free_txbufs(txqinfo,
+						 (u16)(*txqinfo->
+							    hw_consumer_index));
+			bna_ib_ack(bnad->priv, &txqinfo->ib, acked);
+
+			smp_mb__before_clear_bit();
+			clear_bit(BNAD_TXQ_FREE_SENT, &txqinfo->flags);
+		} else
+			netif_stop_queue(netdev);
+
+		smp_mb();
+		/*
+		 * Check again to deal with race condition between
+		 * netif_stop_queue here, and netif_wake_queue in
+		 * interrupt handler which is not inside netif tx lock.
+		 */
+		if (likely
+		    (wis > BNA_Q_FREE_COUNT(txq) ||
+		     vectors > BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth))) {
+			bnad->stats.netif_queue_stop++;
+			return NETDEV_TX_BUSY;
+		} else
+			netif_wake_queue(netdev);
+	}
+
+	unmap_prod = unmap_q->producer_index;
+	wis_used = 1;
+	vect_id = 0;
+	flags = 0;
+
+	txq_prod = txq->q.producer_index;
+	BNA_TXQ_QPGE_PTR_GET(txq_prod, &txq->q, txqent, wi_range);
+	BNA_ASSERT(wi_range && wi_range <= txq->q.q_depth);
+	txqent->hdr.wi.reserved = 0;
+	txqent->hdr.wi.num_vectors = vectors;
+	txqent->hdr.wi.opcode =
+		htons((skb_is_gso(skb) ? BNA_TXQ_WI_SEND_LSO :
+		       BNA_TXQ_WI_SEND));
+
+	if (bnad_ipid_mode)
+		flags |= BNA_TXQ_WI_CF_IPID_MODE;
+
+	if (bnad->vlangrp && vlan_tx_tag_present(skb)) {
+		vlan_tag = (u16) vlan_tx_tag_get(skb);
+		flags |= (BNA_TXQ_WI_CF_INS_PRIO | BNA_TXQ_WI_CF_INS_VLAN);
+	}
+	if (test_bit(BNAD_F_CEE_RUNNING, &bnad->flags)) {
+		vlan_tag =
+			(bnad->curr_priority & 0x7) << 13 | (vlan_tag & 0x1fff);
+		flags |= (BNA_TXQ_WI_CF_INS_PRIO | BNA_TXQ_WI_CF_INS_VLAN);
+	}
+
+	txqent->hdr.wi.vlan_tag = htons(vlan_tag);
+
+	if (skb_is_gso(skb)) {
+		err = bnad_tso_prepare(bnad, skb);
+		if (err) {
+			dev_kfree_skb(skb);
+			return NETDEV_TX_OK;
+		}
+		txqent->hdr.wi.lso_mss = htons(skb_is_gso(skb));
+		flags |= (BNA_TXQ_WI_CF_IP_CKSUM | BNA_TXQ_WI_CF_TCP_CKSUM);
+		txqent->hdr.wi.l4_hdr_size_n_offset =
+			htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
+			      (tcp_hdrlen(skb) >> 2,
+			       skb_transport_offset(skb)));
+
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		u8 proto = 0;
+
+		txqent->hdr.wi.lso_mss = 0;
+
+		if (skb->protocol == htons(ETH_P_IP))
+			proto = ip_hdr(skb)->protocol;
+		else if (skb->protocol == htons(ETH_P_IPV6)) {
+			/* XXX the nexthdr may not be TCP immediately. */
+			proto = ipv6_hdr(skb)->nexthdr;
+		}
+		if (proto == IPPROTO_TCP) {
+			flags |= BNA_TXQ_WI_CF_TCP_CKSUM;
+			txqent->hdr.wi.l4_hdr_size_n_offset =
+				htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
+				      (0, skb_transport_offset(skb)));
+			bnad->stats.tcpcsum_offload++;
+			BNA_ASSERT(skb_headlen(skb) >=
+				   skb_transport_offset(skb) + tcp_hdrlen(skb));
+		} else if (proto == IPPROTO_UDP) {
+			flags |= BNA_TXQ_WI_CF_UDP_CKSUM;
+			txqent->hdr.wi.l4_hdr_size_n_offset =
+				htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
+				      (0, skb_transport_offset(skb)));
+			bnad->stats.udpcsum_offload++;
+			BNA_ASSERT(skb_headlen(skb) >=
+				   skb_transport_offset(skb) +
+				   sizeof(struct udphdr));
+		} else {
+			err = skb_checksum_help(skb);
+			bnad->stats.csum_help++;
+			if (err) {
+				dev_kfree_skb(skb);
+				bnad->stats.csum_help_err++;
+				return NETDEV_TX_OK;
+			}
+		}
+	} else {
+		txqent->hdr.wi.lso_mss = 0;
+		txqent->hdr.wi.l4_hdr_size_n_offset = 0;
+	}
+
+	txqent->hdr.wi.flags = htons(flags);
+
+	txqent->hdr.wi.frame_length = htonl(skb->len);
+
+	unmap_q->unmap_array[unmap_prod].skb = skb;
+	BNA_ASSERT(skb_headlen(skb) <= BNAD_TX_MAX_DATA_PER_VECTOR);
+	txqent->vector[vect_id].length = htons(skb_headlen(skb));
+	dma_addr =
+		pci_map_single(bnad->pcidev, skb->data, skb_headlen(skb),
+			       PCI_DMA_TODEVICE);
+	pci_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
+			   dma_addr);
+
+	BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[vect_id].host_addr);
+	BNA_QE_INDX_ADD(unmap_prod, 1, unmap_q->q_depth);
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
+
+		if (++vect_id == BNAD_TX_MAX_VECTORS_PER_WI) {
+			vect_id = 0;
+			if (--wi_range)
+				txqent++;
+			else {
+				BNA_QE_INDX_ADD(txq_prod, wis_used,
+						txq->q.q_depth);
+				wis_used = 0;
+				BNA_TXQ_QPGE_PTR_GET(txq_prod, &txq->q, txqent,
+						     wi_range);
+				BNA_ASSERT(wi_range &&
+					   wi_range <= txq->q.q_depth);
+			}
+			wis_used++;
+			txqent->hdr.wi_ext.opcode = htons(BNA_TXQ_WI_EXTENSION);
+		}
+
+		BNA_ASSERT(frag->size <= BNAD_TX_MAX_DATA_PER_VECTOR);
+		txqent->vector[vect_id].length = htons(frag->size);
+		BNA_ASSERT(unmap_q->unmap_array[unmap_prod].skb == NULL);
+		dma_addr =
+			pci_map_page(bnad->pcidev, frag->page,
+				     frag->page_offset, frag->size,
+				     PCI_DMA_TODEVICE);
+		pci_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
+				   dma_addr);
+		BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[vect_id].host_addr);
+		BNA_QE_INDX_ADD(unmap_prod, 1, unmap_q->q_depth);
+	}
+
+	unmap_q->producer_index = unmap_prod;
+	BNA_QE_INDX_ADD(txq_prod, wis_used, txq->q.q_depth);
+	txq->q.producer_index = txq_prod;
+
+	smp_mb();
+	bna_txq_prod_indx_doorbell(txq);
+
+	if ((u16) (*txqinfo->hw_consumer_index) != txq->q.consumer_index)
+		tasklet_schedule(&bnad->tx_free_tasklet);
+
+	return NETDEV_TX_OK;
+}
+
+struct net_device_stats *bnad_get_stats(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct net_device_stats *net_stats = &bnad->net_stats;
+	struct cna_stats_mac_rx *rxstats = &bnad->hw_stats->mac_rx_stats;
+	struct cna_stats_mac_tx *txstats = &bnad->hw_stats->mac_tx_stats;
+	int i;
+
+	memset(net_stats, 0, sizeof(*net_stats));
+	if (bnad->rxq_table) {
+		for (i = 0; i < bnad->rxq_num; i++) {
+			net_stats->rx_packets += bnad->rxq_table[i].rx_packets;
+			net_stats->rx_bytes += bnad->rxq_table[i].rx_bytes;
+		}
+	}
+	if (bnad->txq_table) {
+		for (i = 0; i < bnad->txq_num; i++) {
+			net_stats->tx_packets += bnad->txq_table[i].tx_packets;
+			net_stats->tx_bytes += bnad->txq_table[i].tx_bytes;
+		}
+	}
+	net_stats->rx_errors =
+		rxstats->rx_fcs_error + rxstats->rx_alignment_error +
+		rxstats->rx_frame_length_error + rxstats->rx_code_error +
+		rxstats->rx_undersize;
+	net_stats->tx_errors = txstats->tx_fcs_error + txstats->tx_undersize;
+	net_stats->rx_dropped = rxstats->rx_drop;
+	net_stats->tx_dropped = txstats->tx_drop;
+	net_stats->multicast = rxstats->rx_multicast;
+	net_stats->collisions = txstats->tx_total_collision;
+
+	net_stats->rx_length_errors = rxstats->rx_frame_length_error;
+	net_stats->rx_crc_errors = rxstats->rx_fcs_error;
+	net_stats->rx_frame_errors = rxstats->rx_alignment_error;
+	/* recv'r fifo overrun */
+	net_stats->rx_fifo_errors = bnad->hw_stats->rxf_stats[0].frame_drops;
+
+	return net_stats;
+}
+
+/* Should be called with priv_lock held. */
+static void bnad_set_rx_mode_locked(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err;
+
+	if (netdev->flags & IFF_PROMISC) {
+		bna_rxf_promiscuous(bnad->priv, BNAD_RX_FUNC_ID, BNA_ENABLE);
+		bnad->config |= BNAD_CF_PROMISC;
+	} else {
+		bna_rxf_promiscuous(bnad->priv, BNAD_RX_FUNC_ID, BNA_DISABLE);
+		bnad->config &= ~BNAD_CF_PROMISC;
+	}
+
+	if (netdev->flags & IFF_ALLMULTI) {
+		if (!(bnad->config & BNAD_CF_ALLMULTI)) {
+			bna_rxf_mcast_filter(bnad->priv, BNAD_RX_FUNC_ID,
+					     BNA_DISABLE);
+			bnad->config |= BNAD_CF_ALLMULTI;
+		}
+	} else {
+		if (bnad->config & BNAD_CF_ALLMULTI) {
+			bna_rxf_mcast_filter(bnad->priv, BNAD_RX_FUNC_ID,
+					     BNA_ENABLE);
+			bnad->config &= ~BNAD_CF_ALLMULTI;
+		}
+	}
+
+	if (netdev->mc_count) {
+		struct mac *mcaddr_list;
+		struct dev_mc_list *mc;
+		int i;
+
+		mcaddr_list =
+			kzalloc((netdev->mc_count + 1) * sizeof(struct mac),
+				GFP_ATOMIC);
+		if (!mcaddr_list)
+			return;
+
+		mcaddr_list[0] = bna_bcast_addr;
+
+		mc = netdev->mc_list;
+		for (i = 1; mc && i < netdev->mc_count + 1; i++, mc = mc->next)
+			memcpy(&mcaddr_list[i], mc->dmi_addr,
+				sizeof(struct mac));
+
+		err = bna_rxf_mcast_mac_set_list(bnad->priv, BNAD_RX_FUNC_ID,
+			(const struct mac *)mcaddr_list,
+				 netdev->mc_count + 1);
+
+		/* XXX Should we enable BNAD_CF_ALLMULTI for err != 0 ? */
+
+		kfree(mcaddr_list);
+	}
+}
+
+static void bnad_set_rx_mode(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	spin_lock_irq(&bnad->priv_lock);
+	bnad_set_rx_mode_locked(netdev);
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+/* Should be called with conf_lock held. */
+int bnad_ucast_mac(struct bnad *bnad, unsigned int rxf_id, u8 * mac_ptr,
+	unsigned int cmd)
+{
+	int err = 0;
+	char message[BNA_MESSAGE_SIZE];
+	enum bna_status_e(*ucast_mac_func) (struct bna_dev *bna_dev,
+		unsigned int rxf_id, const struct mac *mac_addr_ptr) = NULL;
+
+	WARN_ON(in_interrupt());
+	if (!is_valid_ether_addr(mac_ptr))
+		return -EINVAL;
+
+	switch (cmd) {
+	case BNAD_UCAST_MAC_SET:
+		ucast_mac_func = bna_rxf_ucast_mac_set;
+		break;
+	case BNAD_UCAST_MAC_ADD:
+		ucast_mac_func = bna_rxf_ucast_mac_add;
+		break;
+	case BNAD_UCAST_MAC_DEL:
+		ucast_mac_func = bna_rxf_ucast_mac_del;
+		break;
+	}
+
+	init_completion(&bnad->ucast_comp);
+	spin_lock_irq(&bnad->priv_lock);
+	err = ucast_mac_func(bnad->priv, rxf_id, (const struct mac *)mac_ptr);
+	spin_unlock_irq(&bnad->priv_lock);
+	if (err) {
+		if (err == BNA_AGAIN)
+			err = 0;
+		goto ucast_mac_exit;
+	}
+	wait_for_completion(&bnad->ucast_comp);
+	err = bnad->ucast_comp_status;
+	if (err == BFI_LL_CMD_NOT_EXEC)
+		err = 0;
+
+ucast_mac_exit:
+	if (err) {
+		sprintf(message, "%s unicast MAC address command %d failed: %d",
+			bnad->netdev->name, cmd, err);
+		DPRINTK(INFO, "%s",
+			message);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/* Should be called with conf_lock held. */
+static int bnad_set_mac_address_locked(struct net_device *netdev, void *addr)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct sockaddr *sa = (struct sockaddr *)addr;
+	int err;
+
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EADDRNOTAVAIL;
+
+	err = bnad_ucast_mac(bnad, BNAD_RX_FUNC_ID, (u8 *) sa->sa_data,
+			     BNAD_UCAST_MAC_SET);
+	if (err)
+		return err;
+
+	memcpy(netdev->dev_addr, sa->sa_data, netdev->addr_len);
+	return 0;
+}
+
+static int bnad_set_mac_address(struct net_device *netdev, void *addr)
+{
+	int err = 0;
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_conf_lock();
+	err = bnad_set_mac_address_locked(netdev, addr);
+	bnad_conf_unlock();
+	return err;
+
+}
+
+static int bnad_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	int err = 0;
+	struct bnad *bnad = netdev_priv(netdev);
+
+	WARN_ON(in_interrupt());
+
+	if (new_mtu + ETH_HLEN < ETH_ZLEN || new_mtu > BNAD_JUMBO_MTU)
+		return -EINVAL;
+
+	bnad_conf_lock();
+	netdev->mtu = new_mtu;
+	err = bnad_sw_reset_locked(netdev);
+	bnad_conf_unlock();
+
+	return err;
+}
+
+static void bnad_vlan_rx_register(struct net_device *netdev,
+	struct vlan_group *grp)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_conf_lock();
+	bnad->vlangrp = grp;
+	bnad_conf_unlock();
+}
+
+static void bnad_vlan_rx_add_vid(struct net_device *netdev, unsigned short vid)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_conf_lock();
+	spin_lock_irq(&bnad->priv_lock);
+	if (bnad->state == BNAD_S_OPEN && !BNAD_NOT_READY(bnad))
+		bna_rxf_vlan_add(bnad->priv, BNAD_RX_FUNC_ID,
+				 (unsigned int)vid);
+	spin_unlock_irq(&bnad->priv_lock);
+	bnad_conf_unlock();
+}
+
+static void bnad_vlan_rx_kill_vid(struct net_device *netdev,
+	unsigned short vid)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_conf_lock();
+	spin_lock_irq(&bnad->priv_lock);
+	if (bnad->state == BNAD_S_OPEN && !BNAD_NOT_READY(bnad))
+		bna_rxf_vlan_del(bnad->priv, BNAD_RX_FUNC_ID,
+				 (unsigned int)vid);
+	spin_unlock_irq(&bnad->priv_lock);
+	bnad_conf_unlock();
+}
+
+/* Should be called with priv_lock held. */
+static void bnad_reconfig_vlans(struct bnad *bnad)
+{
+	u16 vlan_id;
+
+	bna_rxf_vlan_del_all(bnad->priv, BNAD_RX_FUNC_ID);
+	if (bnad->vlangrp) {
+		for (vlan_id = 0; vlan_id < VLAN_GROUP_ARRAY_LEN; vlan_id++) {
+			if (vlan_group_get_device(bnad->vlangrp, vlan_id))
+				bna_rxf_vlan_add(bnad->priv, BNAD_RX_FUNC_ID,
+						 (unsigned int)vlan_id);
+		}
+	}
+}
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void bnad_netpoll(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct bnad_cq_info *cqinfo;
+	int i;
+
+	if (!(bnad->config & BNAD_CF_MSIX)) {
+		disable_irq(bnad->pcidev->irq);
+		bnad_isr(bnad->pcidev->irq, netdev);
+		enable_irq(bnad->pcidev->irq);
+	} else {
+		for (i = 0; i < bnad->cq_num; i++) {
+			cqinfo = &bnad->cq_table[i];
+			if (likely(napi_schedule_prep(&cqinfo->napi))) {
+				bnad_disable_rx_irq(bnad, cqinfo);
+				__napi_schedule(&cqinfo->napi);
+			}
+		}
+	}
+}
+#endif
+
+static void bnad_q_num_init(struct bnad *bnad, uint rxqsets)
+{
+	bnad->txq_num = BNAD_TXQ_NUM;
+	bnad->txf_num = 1;
+
+	if (bnad->config & BNAD_CF_MSIX) {
+		if (rxqsets) {
+			bnad->cq_num = rxqsets;
+			if (bnad->cq_num > BNAD_MAX_CQS)
+				bnad->cq_num = BNAD_MAX_CQS;
+		} else
+			bnad->cq_num =
+				min((uint) num_online_cpus(),
+				    (uint) BNAD_MAX_RXQSETS_USED);
+		/* VMware does not use RSS like Linux driver */
+		if (!BNA_POWER_OF_2(bnad->cq_num))
+			BNA_TO_POWER_OF_2(bnad->cq_num);
+		bnad->rxq_num = bnad->cq_num * bnad_rxqs_per_cq;
+
+		bnad->rxf_num = 1;
+		bnad->msix_num =
+			bnad->txq_num + bnad->cq_num +
+			BNAD_MSIX_ERR_MAILBOX_NUM;
+	} else {
+		bnad->cq_num = 1;
+		bnad->rxq_num = bnad->cq_num * bnad_rxqs_per_cq;
+		bnad->rxf_num = 1;
+		bnad->msix_num = 0;
+	}
+}
+
+static void bnad_enable_msix(struct bnad *bnad)
+{
+	int i, ret;
+
+	if (!(bnad->config & BNAD_CF_MSIX) || bnad->msix_table)
+		return;
+
+	bnad->msix_table =
+		kzalloc(bnad->msix_num * sizeof(struct msix_entry), GFP_KERNEL);
+	if (!bnad->msix_table)
+		goto intx_mode;
+
+	for (i = 0; i < bnad->msix_num; i++)
+		bnad->msix_table[i].entry = i;
+
+	ret = pci_enable_msix(bnad->pcidev, bnad->msix_table, bnad->msix_num);
+	if (ret > 0) {
+		/* Not enough MSI-X vectors. */
+		int rxqsets = ret;
+
+		dev_err(&bnad->pcidev->dev,
+			"Tried to get %d MSI-X vectors, only got %d\n",
+			bnad->msix_num, ret);
+		BNA_TO_POWER_OF_2(rxqsets);
+		while (bnad->msix_num > ret && rxqsets) {
+			bnad_q_num_init(bnad, rxqsets);
+			rxqsets >>= 1;
+		}
+		if (bnad->msix_num <= ret) {
+			ret = pci_enable_msix(bnad->pcidev, bnad->msix_table,
+					      bnad->msix_num);
+			if (ret) {
+				dev_err(&bnad->pcidev->dev,
+					"Enabling MSI-X failed: %d\n", ret);
+				goto intx_mode;
+			}
+		} else {
+			dev_err(&bnad->pcidev->dev,
+				"Enabling MSI-X failed: limited (%d) vectors\n",
+				ret);
+			goto intx_mode;
+		}
+	} else if (ret < 0) {
+		dev_err(&bnad->pcidev->dev, "Enabling MSI-X failed: %d\n", ret);
+		goto intx_mode;
+	}
+
+	dev_info(&bnad->pcidev->dev,
+		 "Enabling MSI-X succeeded with %d vectors, %s\n",
+		 bnad->msix_num,
+		 (bnad->cq_num > 1) ? "RSS is enabled" : "RSS is not enabled");
+	return;
+
+intx_mode:
+	dev_warn(&bnad->pcidev->dev, "Switching to INTx mode with no RSS\n");
+
+	kfree(bnad->msix_table);
+	bnad->msix_table = NULL;
+
+	bnad->config &= ~BNAD_CF_MSIX;
+	bnad_q_num_init(bnad, 0);
+}
+
+static void bnad_disable_msix(struct bnad *bnad)
+{
+	if (bnad->config & BNAD_CF_MSIX) {
+		pci_disable_msix(bnad->pcidev);
+		kfree(bnad->msix_table);
+		bnad->msix_table = NULL;
+		bnad->config &= ~BNAD_CF_MSIX;
+	}
+}
+
+static void bnad_error(struct bnad *bnad)
+{
+
+	spin_lock_irq(&bnad->priv_lock);
+
+	if (!test_and_clear_bit(BNAD_F_HWERROR, &bnad->flags)) {
+		spin_unlock_irq(&bnad->priv_lock);
+		return;
+	}
+	spin_unlock_irq(&bnad->priv_lock);
+
+	switch (bnad->state) {
+	case BNAD_S_INIT:
+		bnad->state = BNAD_S_INIT_DOWN;
+		break;
+	case BNAD_S_OPEN:
+		bnad->state = BNAD_S_OPEN_DOWN;
+		bnad_stop_data_path(bnad, 1);
+		bnad_cleanup(bnad);
+		break;
+	case BNAD_S_START:
+	case BNAD_S_INIT_DISABLING:
+	case BNAD_S_OPENING:
+	case BNAD_S_OPEN_DISABLING:
+	case BNAD_S_CLOSING:
+		BNA_ASSERT(0);
+		/* fall through */
+	default:
+		break;
+	}
+}
+
+static void bnad_resume_after_reset(struct bnad *bnad)
+{
+	int err;
+	struct net_device *netdev = bnad->netdev;
+	char message[BNA_MESSAGE_SIZE];
+
+	switch (bnad->state) {
+	case BNAD_S_INIT_DOWN:
+		bnad->state = BNAD_S_INIT;
+
+		bna_port_mac_get(bnad->priv, (struct mac *)bnad->perm_addr);
+		BNA_ASSERT(netdev->addr_len == sizeof(bnad->perm_addr));
+		memcpy(netdev->perm_addr, bnad->perm_addr, netdev->addr_len);
+		if (is_zero_ether_addr(netdev->dev_addr))
+			memcpy(netdev->dev_addr, bnad->perm_addr,
+			       netdev->addr_len);
+		break;
+	case BNAD_S_OPEN_DOWN:
+		err = bnad_enable_locked(bnad);
+		if (err) {
+			sprintf(message,
+				"%s bnad_enable failed after reset: %d",
+				bnad->netdev->name, err);
+		DPRINTK(INFO, "%s",
+				message);
+		} else {
+			bnad_port_admin_locked(bnad, BNA_ENABLE);
+		}
+		break;
+	case BNAD_S_START:
+	case BNAD_S_INIT_DISABLING:
+	case BNAD_S_OPENING:
+	case BNAD_S_OPEN:
+	case BNAD_S_OPEN_DISABLING:
+	case BNAD_S_CLOSING:
+		BNA_ASSERT(0);
+		/* fall through */
+	default:
+		break;
+	}
+
+}
+
+static void bnad_tx_free_tasklet(unsigned long bnad_ptr)
+{
+	struct bnad *bnad = (struct bnad *)bnad_ptr;
+	struct bnad_txq_info *txqinfo;
+	struct bna_txq *txq;
+	unsigned int acked;
+
+	txqinfo = &bnad->txq_table[0];
+	txq = &txqinfo->txq;
+
+	if ((u16) (*txqinfo->hw_consumer_index) != txq->q.consumer_index &&
+	    !test_and_set_bit(BNAD_TXQ_FREE_SENT, &txqinfo->flags)) {
+		acked = bnad_free_txbufs(txqinfo,
+					 (u16) (*txqinfo->
+						     hw_consumer_index));
+		bna_ib_ack(bnad->priv, &txqinfo->ib, acked);
+		smp_mb__before_clear_bit();
+		clear_bit(BNAD_TXQ_FREE_SENT, &txqinfo->flags);
+	}
+}
+
+static void bnad_cee_reconfig_prio(struct bnad *bnad, u8 cee_linkup,
+	unsigned int prio)
+{
+
+	if (prio != bnad->curr_priority) {
+		bnad_sw_reset_locked_internal(bnad->netdev);
+	} else {
+		spin_lock_irq(&bnad->priv_lock);
+		if (!cee_linkup)
+			clear_bit(BNAD_F_CEE_RUNNING, &bnad->flags);
+		else
+			set_bit(BNAD_F_CEE_RUNNING, &bnad->flags);
+		spin_unlock_irq(&bnad->priv_lock);
+	}
+}
+
+static void bnad_link_state_notify(struct bnad *bnad)
+{
+	struct net_device *netdev = bnad->netdev;
+	enum bnad_link_state link_state;
+	u8 cee_linkup;
+	unsigned int prio = 0;
+	char message[BNA_MESSAGE_SIZE];
+
+	if (bnad->state != BNAD_S_OPEN) {
+		sprintf(message, "%s link up in state %d", netdev->name,
+			bnad->state);
+		DPRINTK(INFO, "%s", message);
+		return;
+	}
+
+	spin_lock_irq(&bnad->priv_lock);
+	link_state = bnad->link_state;
+	cee_linkup = bnad->cee_linkup;
+	if (cee_linkup)
+		prio = bnad->priority;
+	spin_unlock_irq(&bnad->priv_lock);
+
+	if (link_state == BNAD_LS_UP) {
+		bnad_cee_reconfig_prio(bnad, cee_linkup, prio);
+		if (!netif_carrier_ok(netdev)) {
+			netif_carrier_on(netdev);
+			netif_wake_queue(netdev);
+			bnad->stats.netif_queue_wakeup++;
+		}
+	} else {
+		if (netif_carrier_ok(netdev)) {
+			netif_carrier_off(netdev);
+			bnad->stats.netif_queue_stop++;
+		}
+	}
+}
+
+static void bnad_work(struct work_struct *work)
+{
+	struct bnad *bnad = container_of(work, struct bnad, work);
+	unsigned long work_flags;
+
+	bnad_conf_lock();
+
+	spin_lock_irq(&bnad->priv_lock);
+	work_flags = bnad->work_flags;
+	bnad->work_flags = 0;
+	spin_unlock_irq(&bnad->priv_lock);
+
+	if (work_flags & BNAD_WF_ERROR)
+		bnad_error(bnad);
+	if (work_flags & BNAD_WF_RESETDONE)
+		bnad_resume_after_reset(bnad);
+
+	if (work_flags & BNAD_WF_LS_NOTIFY)
+		bnad_link_state_notify(bnad);
+
+	bnad_conf_unlock();
+}
+
+static void bnad_stats_timeo(unsigned long data)
+{
+	struct bnad *bnad = (struct bnad *)data;
+	int i;
+	struct bnad_rxq_info *rxqinfo;
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_stats_get(bnad->priv);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	if (bnad->rx_dyn_coalesce_on) {
+		u8 cls_timer;
+		struct bnad_cq_info *cq;
+		for (i = 0; i < bnad->cq_num; i++) {
+			cq = &bnad->cq_table[i];
+
+			if ((cq->pkt_rate.small_pkt_cnt == 0) &&
+			    (cq->pkt_rate.large_pkt_cnt == 0))
+				continue;
+
+			cls_timer =
+				bna_calc_coalescing_timer(bnad->priv,
+							  &cq->pkt_rate);
+
+			/* For NAPI version, coalescing timer need to stored */
+			cq->rx_coalescing_timeo = cls_timer;
+
+			bna_ib_coalescing_timer_set(bnad->priv, &cq->ib,
+						    cls_timer);
+		}
+	}
+
+	for (i = 0; i < bnad->rxq_num; i++) {
+		rxqinfo = &bnad->rxq_table[i];
+		if (!
+		    (BNA_QE_IN_USE_CNT
+		     (&rxqinfo->skb_unmap_q,
+		      rxqinfo->skb_unmap_q.
+		      q_depth) >> BNAD_RXQ_REFILL_THRESHOLD_SHIFT)) {
+			if (test_and_set_bit(BNAD_RXQ_REFILL, &rxqinfo->flags))
+				continue;
+			bnad_alloc_rxbufs(rxqinfo);
+			smp_mb__before_clear_bit();
+			clear_bit(BNAD_RXQ_REFILL, &rxqinfo->flags);
+		}
+	}
+}
+
+static void bnad_free_ioc_mem(struct bnad *bnad)
+{
+	enum bna_dma_mem_type i;
+
+	for (i = 0; i < BNA_MEM_T_MAX; i++) {
+		if (!bnad->ioc_meminfo[i].len)
+			continue;
+		if (bnad->ioc_meminfo[i].kva && bnad->ioc_meminfo[i].dma)
+			pci_free_consistent(bnad->pcidev,
+					    bnad->ioc_meminfo[i].len,
+					    bnad->ioc_meminfo[i].kva,
+					    *(dma_addr_t *) &bnad->
+					    ioc_meminfo[i].dma);
+		else if (bnad->ioc_meminfo[i].kva)
+			vfree(bnad->ioc_meminfo[i].kva);
+		bnad->ioc_meminfo[i].kva = NULL;
+	}
+}
+
+/* The following IOC callback functions are called with priv_lock held. */
+
+void bna_iocll_enable_cbfn(void *arg, enum bfa_status error)
+{
+	struct bnad *bnad = arg;
+
+	if (!error) {
+		bnad->work_flags &= ~BNAD_WF_LS_NOTIFY;
+		bnad->work_flags |= BNAD_WF_RESETDONE;
+
+		if (bnad->state != BNAD_S_UNLOADING)
+			schedule_work(&bnad->work);
+	}
+
+	bnad->ioc_comp_status = error;
+	complete(&bnad->ioc_comp);
+}
+
+void bna_iocll_disable_cbfn(void *arg)
+{
+	struct bnad *bnad = arg;
+
+	complete(&bnad->ioc_comp);
+}
+
+void bna_iocll_hbfail_cbfn(void *arg)
+{
+	struct bnad *bnad = arg;
+
+	bnad_hw_error(bnad, BFA_STATUS_IOC_FAILURE);
+}
+
+void bna_iocll_reset_cbfn(void *arg)
+{
+	struct bnad *bnad = arg;
+	u32 int_status, int_mask;
+	unsigned int irq;
+
+	/* Clear the status */
+	bna_intr_status_get(bnad->priv, &int_status);
+
+	if (bnad->config & BNAD_CF_MSIX) {
+		if (test_and_clear_bit(BNAD_F_MBOX_IRQ_DISABLED,
+		    &bnad->flags)) {
+			irq = bnad->msix_table[bnad->msix_num - 1].vector;
+			enable_irq(irq);
+		}
+	}
+
+	int_mask = ~(__LPU2HOST_MBOX_MASK_BITS | __ERROR_MASK_BITS);
+	bna_intx_enable(bnad->priv, int_mask);
+}
+
+static void bnad_ioc_timeout(unsigned long data)
+{
+	struct bnad *bnad = (struct bnad *)data;
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_iocll_timer(bnad->priv);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	if (bnad->state != BNAD_S_UNLOADING)
+		mod_timer(&bnad->ioc_timer,
+			  jiffies + msecs_to_jiffies(BNA_IOC_TIMER_PERIOD));
+}
+
+s32 bnad_cee_attach(struct bnad *bnad)
+{
+	u8 *dma_kva;
+	dma_addr_t dma_pa;
+	struct bfa_cee *cee = &bnad->cee;
+
+	memset(cee, 0, sizeof(struct bfa_cee));
+
+	/* Allocate memory for dma */
+	dma_kva =
+		pci_alloc_consistent(bnad->pcidev, bfa_cee_meminfo(), &dma_pa);
+	if (dma_kva == NULL)
+		return -ENOMEM;
+
+	/* Ugly... need to remove once CAL is fixed. */
+	((struct bna_dev *) bnad->priv)->cee = cee;
+
+	bnad->cee_cbfn.get_attr_cbfn = bnad_cee_get_attr_cb;
+	bnad->cee_cbfn.get_stats_cbfn = bnad_cee_get_stats_cb;
+	bnad->cee_cbfn.reset_stats_cbfn = bnad_cee_reset_stats_cb;
+	bnad->cee_cbfn.reset_stats_cbfn = NULL;
+
+	/* Invoke cee attach function */
+	bfa_cee_attach(cee, &bnad->priv->ioc, bnad, bnad->trcmod, bnad->logmod);
+	bfa_cee_mem_claim(cee, dma_kva, dma_pa);
+	return 0;
+}
+
+static void bnad_cee_detach(struct bnad *bnad)
+{
+	struct bfa_cee *cee = &bnad->cee;
+
+	if (cee->attr_dma.kva) {
+		pci_free_consistent(bnad->pcidev, bfa_cee_meminfo(),
+				    cee->attr_dma.kva, cee->attr_dma.pa);
+	}
+	bfa_cee_detach(&bnad->cee);
+}
+
+static int bnad_priv_init(struct bnad *bnad)
+{
+	dma_addr_t dma_addr;
+	struct bna_dma_addr bna_dma_addr;
+	int err = 0, i;
+	struct bfa_pcidev pcidev_info;
+	u32 intr_mask;
+
+	if (bnad_msix)
+		bnad->config |= BNAD_CF_MSIX;
+	bnad_q_num_init(bnad, bnad_rxqsets_used);
+
+	bnad->work_flags = 0;
+	INIT_WORK(&bnad->work, bnad_work);
+
+	tasklet_init(&bnad->tx_free_tasklet, bnad_tx_free_tasklet,
+		     (unsigned long)bnad);
+
+	setup_timer(&bnad->stats_timer, bnad_stats_timeo,
+		    (unsigned long)bnad);
+
+	bnad->tx_coalescing_timeo = BNAD_TX_COALESCING_TIMEO;
+	bnad->tx_interpkt_count = BNAD_TX_INTERPKT_COUNT;
+
+	bnad->rx_coalescing_timeo = BNAD_RX_COALESCING_TIMEO;
+	bnad->rx_interpkt_count = BNAD_RX_INTERPKT_COUNT;
+	bnad->rx_interpkt_timeo = BNAD_RX_INTERPKT_TIMEO;
+
+	bnad->rx_dyn_coalesce_on = BNA_TRUE;
+
+	bnad->rx_csum = 1;
+	bnad->pause_config.tx_pause = 0;
+	bnad->pause_config.rx_pause = 0;
+
+	/* XXX could be vmalloc? */
+	bnad->trcmod = kzalloc(sizeof(struct bfa_trc_mod), GFP_KERNEL);
+	if (!bnad->trcmod) {
+		printk(KERN_ERR "port %u failed allocating trace buffer!\n",
+		       bnad->bna_id);
+		return -ENOMEM;
+	}
+
+	bfa_trc_init(bnad->trcmod);
+
+	bnad->logmod = NULL;
+
+	bnad->priv = kzalloc(bna_get_handle_size(), GFP_KERNEL);
+	if (!bnad->priv) {
+		printk(KERN_ERR "port %u failed allocating memory for bna\n",
+		       bnad->bna_id);
+		err = -ENOMEM;
+		goto free_trcmod;
+	}
+	bnad->priv_stats =
+		pci_alloc_consistent(bnad->pcidev, BNA_HW_STATS_SIZE,
+				     &dma_addr);
+	if (!bnad->priv_stats) {
+		printk(KERN_ERR
+		       "port %u failed allocating memory for bna stats\n",
+		       bnad->bna_id);
+		err = -ENOMEM;
+		goto free_priv_mem;
+	}
+	pci_unmap_addr_set(bnad, priv_stats_dma, dma_addr);
+
+	BNA_SET_DMA_ADDR(dma_addr, &bna_dma_addr);
+	bna_init(bnad->priv, (void *)bnad->bar0, bnad->priv_stats, bna_dma_addr,
+		 bnad->trcmod, bnad->logmod);
+	bna_all_stats_get(bnad->priv, &bnad->hw_stats);
+
+	spin_lock_init(&bnad->priv_lock);
+	init_MUTEX(&bnad->conf_sem);
+	bnad->priv_cbfn.ucast_set_cb = bnad_ucast_set_cb;
+	bnad->priv_cbfn.txq_stop_cb = bnad_q_stop_cb;
+	bnad->priv_cbfn.rxq_stop_cb = bnad_q_stop_cb;
+	bnad->priv_cbfn.link_up_cb = bnad_link_up_cb;
+	bnad->priv_cbfn.link_down_cb = bnad_link_down_cb;
+	bnad->priv_cbfn.stats_get_cb = bnad_stats_get_cb;
+	bnad->priv_cbfn.hw_error_cb = bnad_hw_error_cb;
+	bnad->priv_cbfn.lldp_get_cfg_cb = bnad_lldp_get_cfg_cb;
+
+	bna_register_callback(bnad->priv, &bnad->priv_cbfn, bnad);
+
+	bna_iocll_meminfo(bnad->priv, bnad->ioc_meminfo);
+	for (i = 0; i < BNA_MEM_T_MAX; i++) {
+		if (!bnad->ioc_meminfo[i].len)
+			continue;
+		switch (i) {
+		case BNA_KVA_MEM_T_FWTRC:
+			bnad->ioc_meminfo[i].kva =
+				vmalloc(bnad->ioc_meminfo[i].len);
+			break;
+		default:
+			bnad->ioc_meminfo[i].kva =
+				pci_alloc_consistent(bnad->pcidev,
+						     bnad->ioc_meminfo[i].len,
+						     (dma_addr_t *) &bnad->
+						     ioc_meminfo[i].dma);
+
+			break;
+		}
+		if (!bnad->ioc_meminfo[i].kva) {
+			printk(KERN_ERR
+			       "port %u failed allocating %u "
+			       "bytes memory for IOC\n",
+			       bnad->bna_id, bnad->ioc_meminfo[i].len);
+			err = -ENOMEM;
+			goto free_ioc_mem;
+		} else
+			memset(bnad->ioc_meminfo[i].kva, 0,
+			       bnad->ioc_meminfo[i].len);
+	}
+
+	pcidev_info.pci_slot = PCI_SLOT(bnad->pcidev->devfn);
+	pcidev_info.pci_func = PCI_FUNC(bnad->pcidev->devfn);
+	pcidev_info.device_id = bnad->pcidev->device;
+	pcidev_info.pci_bar_kva = bnad->bar0;
+	bna_iocll_attach(bnad->priv, bnad, bnad->ioc_meminfo, &pcidev_info,
+			 bnad->trcmod, NULL, bnad->logmod);
+
+	err = bnad_cee_attach(bnad);
+	if (err) {
+		printk(KERN_ERR "port %u cee_attach failed: %d\n", bnad->bna_id,
+		       err);
+		goto iocll_detach;
+	}
+
+	if (bnad->config & BNAD_CF_MSIX)
+		bnad_enable_msix(bnad);
+	else
+		dev_info(&bnad->pcidev->dev, "Working in INTx mode, no RSS\n");
+	bna_intx_disable(bnad->priv, &intr_mask);
+	err = bnad_request_mbox_irq(bnad);
+	if (err)
+		goto disable_msix;
+
+	setup_timer(&bnad->ioc_timer, bnad_ioc_timeout,
+		    (unsigned long)bnad);
+	mod_timer(&bnad->ioc_timer, jiffies +
+		  msecs_to_jiffies(BNA_IOC_TIMER_PERIOD));
+
+	bnad_conf_lock();
+	bnad->state = BNAD_S_START;
+
+	init_completion(&bnad->ioc_comp);
+	spin_lock_irq(&bnad->priv_lock);
+	bna_iocll_enable(bnad->priv);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	wait_for_completion(&bnad->ioc_comp);
+
+	if (!bnad->ioc_comp_status) {
+		bnad->state = BNAD_S_INIT;
+		bna_port_mac_get(bnad->priv, (struct mac *)bnad->perm_addr);
+	} else {
+		bnad->state = BNAD_S_INIT_DOWN;
+	}
+	bnad_conf_unlock();
+
+	return 0;
+
+disable_msix:
+	bnad_disable_msix(bnad);
+	bnad_cee_detach(bnad);
+iocll_detach:
+	bna_iocll_detach(bnad->priv);
+free_ioc_mem:
+	bnad_free_ioc_mem(bnad);
+	bna_uninit(bnad->priv);
+	pci_free_consistent(bnad->pcidev, BNA_HW_STATS_SIZE, bnad->priv_stats,
+			    pci_unmap_addr(bnad, priv_stats_dma));
+	bnad->priv_stats = NULL;
+free_priv_mem:
+	kfree(bnad->priv);
+	bnad->priv = NULL;
+free_trcmod:
+	kfree(bnad->trcmod);
+	bnad->trcmod = NULL;
+
+	return err;
+}
+
+static void bnad_priv_uninit(struct bnad *bnad)
+{
+	int i;
+	enum bna_status_e err;
+	char message[BNA_MESSAGE_SIZE];
+
+	if (bnad->priv) {
+
+		init_completion(&bnad->ioc_comp);
+
+		for (i = 0; i < 10; i++) {
+			spin_lock_irq(&bnad->priv_lock);
+			err = bna_iocll_disable(bnad->priv);
+			spin_unlock_irq(&bnad->priv_lock);
+			BNA_ASSERT(!err || err == BNA_BUSY);
+			if (!err)
+				break;
+			msleep(1000);
+		}
+		if (err) {
+			/* Probably firmware crashed. */
+			sprintf(message,
+				"bna_iocll_disable failed, "
+				"clean up and try again");
+		DPRINTK(INFO, "%s", message);
+			spin_lock_irq(&bnad->priv_lock);
+			bna_cleanup(bnad->priv);
+			err = bna_iocll_disable(bnad->priv);
+			spin_unlock_irq(&bnad->priv_lock);
+			BNA_ASSERT(!err);
+		}
+		wait_for_completion(&bnad->ioc_comp);
+
+		sprintf(message, "port %u IOC is disabled", bnad->bna_id);
+		DPRINTK(INFO, "%s", message);
+
+		bnad->state = BNAD_S_UNLOADING;
+
+		/* Stop the timer after disabling IOC. */
+		del_timer_sync(&bnad->ioc_timer);
+		bnad_free_ioc_mem(bnad);
+		bna_iocll_detach(bnad->priv);
+
+		flush_scheduled_work();
+		bnad_free_mbox_irq(bnad);
+
+		bnad_disable_msix(bnad);
+
+		bnad_cee_detach(bnad);
+
+		bna_uninit(bnad->priv);
+		if (bnad->priv_stats) {
+			pci_free_consistent(bnad->pcidev, BNA_HW_STATS_SIZE,
+					    bnad->priv_stats,
+					    pci_unmap_addr(bnad,
+							   priv_stats_dma));
+			bnad->priv_stats = NULL;
+		}
+		kfree(bnad->priv);
+		bnad->priv = NULL;
+	}
+	kfree(bnad->trcmod);
+	bnad->trcmod = NULL;
+}
+
+static struct pci_device_id bnad_pci_id_table[] = {
+	{
+	 .vendor = PCI_VENDOR_ID_BROCADE,
+	 .device = PCI_DEVICE_ID_BROCADE_CATAPULT,
+	 .subvendor = PCI_ANY_ID,
+	 .subdevice = PCI_ANY_ID,
+	 .class = PCI_CLASS_NETWORK_ETHERNET << 8,
+	 .class_mask = 0xffff00},
+	{0, 0}
+};
+
+MODULE_DEVICE_TABLE(pci, bnad_pci_id_table);
+
+static int __devinit bnad_pci_probe(struct pci_dev *pdev,
+	const struct pci_device_id *pcidev_id)
+{
+	int err, using_dac;
+	struct net_device *netdev;
+	struct bnad *bnad;
+	unsigned long mmio_start, mmio_len;
+	static u32 bna_id;
+
+	printk(KERN_INFO "bnad_pci_probe : (0x%p, 0x%p) PCI Func : (%d)\n",
+	       pdev, pcidev_id, PCI_FUNC(pdev->devfn));
+
+	if (!bfad_get_firmware_buf(pdev)) {
+		printk(KERN_WARNING "Failed to load Firmware Image!\n");
+		return -ENODEV;
+	}
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "pci_enable_device failed: %d\n", err);
+		return err;
+	}
+
+	err = pci_request_regions(pdev, BNAD_NAME);
+	if (err) {
+		dev_err(&pdev->dev, "pci_request_regions failed: %d\n", err);
+		goto disable_device;
+	}
+
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
+	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
+		using_dac = 1;
+	} else {
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (err) {
+			err = pci_set_consistent_dma_mask(pdev,
+				DMA_BIT_MASK(32));
+			if (err) {
+				dev_err(&pdev->dev,
+					"set 32bit consistent DMA mask failed: "
+					"%d\n", err);
+				goto release_regions;
+			}
+		}
+		using_dac = 0;
+	}
+
+	pci_set_master(pdev);
+
+	netdev = alloc_etherdev(sizeof(struct bnad));
+	if (!netdev) {
+		dev_err(&pdev->dev, "alloc_etherdev failed\n");
+		err = -ENOMEM;
+		goto release_regions;
+	}
+	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+	pci_set_drvdata(pdev, netdev);
+
+	bnad = netdev_priv(netdev);
+
+	memset(bnad, 0, sizeof(struct bnad));
+
+	bnad->netdev = netdev;
+	bnad->pcidev = pdev;
+	mmio_start = pci_resource_start(pdev, 0);
+	mmio_len = pci_resource_len(pdev, 0);
+	bnad->bar0 = ioremap_nocache(mmio_start, mmio_len);
+	if (!bnad->bar0) {
+		dev_err(&pdev->dev, "ioremap for bar0 failed\n");
+		err = -ENOMEM;
+		goto free_devices;
+	}
+	printk(KERN_INFO "bar0 mapped to %p, len %lu\n", bnad->bar0, mmio_len);
+
+	netdev->netdev_ops = &bnad_netdev_ops;
+
+	netdev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
+	netdev->features |= NETIF_F_IPV6_CSUM;
+	netdev->features |= NETIF_F_TSO;
+	netdev->features |= NETIF_F_TSO6;
+
+#ifdef BNAD_VLAN_FEATURES
+	netdev->vlan_features = netdev->features;
+#endif
+	if (using_dac)
+		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |=
+		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
+		NETIF_F_HW_VLAN_FILTER;
+
+	netdev->mem_start = mmio_start;
+	netdev->mem_end = mmio_start + mmio_len - 1;
+
+	bnad_set_ethtool_ops(netdev);
+
+	bnad->bna_id = bna_id;
+	err = bnad_priv_init(bnad);
+	if (err) {
+		printk(KERN_ERR "port %u init failed: %d\n", bnad->bna_id, err);
+		goto unmap_bar0;
+	}
+
+	BNA_ASSERT(netdev->addr_len == ETH_ALEN);
+	memcpy(netdev->perm_addr, bnad->perm_addr, netdev->addr_len);
+	memcpy(netdev->dev_addr, bnad->perm_addr, netdev->addr_len);
+
+	netif_carrier_off(netdev);
+	err = register_netdev(netdev);
+	if (err) {
+		printk(KERN_ERR "port %u register_netdev failed: %d\n",
+		       bnad->bna_id, err);
+		goto bnad_device_uninit;
+	}
+	bna_id++;
+	return 0;
+
+bnad_device_uninit:
+	bnad_priv_uninit(bnad);
+unmap_bar0:
+	iounmap(bnad->bar0);
+free_devices:
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(netdev);
+release_regions:
+	pci_release_regions(pdev);
+disable_device:
+	pci_disable_device(pdev);
+
+	return err;
+}
+
+static void __devexit bnad_pci_remove(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct bnad *bnad;
+
+	if (!netdev)
+		return;
+
+	printk(KERN_INFO "%s bnad_pci_remove\n", netdev->name);
+	bnad = netdev_priv(netdev);
+
+	unregister_netdev(netdev);
+
+	bnad_priv_uninit(bnad);
+	iounmap(bnad->bar0);
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(netdev);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+}
+
+static struct pci_driver bnad_pci_driver = {
+	.name = BNAD_NAME,
+	.id_table = bnad_pci_id_table,
+	.probe = bnad_pci_probe,
+	.remove = __devexit_p(bnad_pci_remove),
+};
+
+static int __init bnad_module_init(void)
+{
+
+	printk(KERN_INFO "Brocade 10G Ethernet driver\n");
+
+	bfa_ioc_auto_recover(bnad_ioc_auto_recover);
+
+	return pci_register_driver(&bnad_pci_driver);
+}
+
+static void __exit bnad_module_exit(void)
+{
+	pci_unregister_driver(&bnad_pci_driver);
+
+	if (bfi_image_ct_size && bfi_image_ct)
+		vfree(bfi_image_ct);
+}
+
+module_init(bnad_module_init);
+module_exit(bnad_module_exit);
+
+MODULE_AUTHOR("Brocade");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Brocade 10G PCIe Ethernet driver");
+MODULE_VERSION(BNAD_VERSION);
diff -ruP net-next-2.6-orig/drivers/net/bna/bnad.h net-next-2.6-mod/drivers/net/bna/bnad.h
--- net-next-2.6-orig/drivers/net/bna/bnad.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6-mod/drivers/net/bna/bnad.h	2009-11-23 13:36:23.225864000 -0800
@@ -0,0 +1,349 @@
+/*
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2006-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
+
+#ifndef _BNAD_H_
+#define _BNAD_H_
+
+#include "cee/bfa_cee.h"
+#include "bna.h"
+
+#include "bnad_compat.h"
+
+#define BNAD_MAX_Q_DEPTH	0x10000
+#define BNAD_MIN_Q_DEPTH	0x200
+
+#define BNAD_TXQ_NUM		1
+#define BNAD_TX_FUNC_ID		0
+#define BNAD_ENTRIES_PER_TXQ	2048
+
+#define BNAD_MAX_RXQS		64
+#define BNAD_MAX_RXQSETS_USED	16
+#define BNAD_RX_FUNC_ID		0
+#define BNAD_ENTRIES_PER_RXQ	2048
+
+#define BNAD_MAX_CQS		64
+#define BNAD_MAX_RXQS_PER_CQ	2
+
+#define BNAD_MSIX_ERR_MAILBOX_NUM	1
+
+#define BNAD_INTX_MAX_IB_NUM	16
+#define BNAD_INTX_IB_NUM	2	/* 1 for Tx, 1 for Rx */
+#define BNAD_INTX_TX_IB_ID	0
+#define BNAD_INTX_RX_IB_ID	1
+
+#define BNAD_QUEUE_NAME_SIZE	16
+
+#define BNAD_JUMBO_MTU		9000
+
+#define BNAD_COALESCING_TIMER_UNIT	5	/* 5us */
+#define BNAD_MAX_COALESCING_TIMEO	0xFF	/* in 5us units */
+#define BNAD_MAX_INTERPKT_COUNT		0xFF
+#define BNAD_MAX_INTERPKT_TIMEO		0xF	/* in 0.5us units */
+
+#define BNAD_TX_COALESCING_TIMEO	20	/* 20 * 5 = 100us */
+#define BNAD_TX_INTERPKT_COUNT		32
+
+#define BNAD_RX_COALESCING_TIMEO	12	/* 12 * 5 = 60us */
+#define BNAD_RX_INTERPKT_COUNT		6
+#define BNAD_RX_INTERPKT_TIMEO		3	/* 3 * 0.5 = 1.5us */
+
+#define BNAD_SMALL_RXBUF_SIZE	128
+
+#define BNAD_RIT_OFFSET		0
+#define BNAD_MULTICAST_RXQ_ID	0
+
+#define BNAD_NETIF_WAKE_THRESHOLD	8
+
+#define BNAD_TX_MAX_VECTORS		255
+#define BNAD_TX_MAX_VECTORS_PER_WI	4
+#define BNAD_TX_MAX_DATA_PER_WI		0xFFFFFF	/* 24 bits */
+#define BNAD_TX_MAX_DATA_PER_VECTOR	0x3FFF	/* 14 bits */
+#define BNAD_TX_MAX_WRR_QUOTA		0xFFF	/* 12 bits */
+
+#define BNAD_RXQ_REFILL_THRESHOLD_SHIFT	3
+
+#define BNAD_NOT_READY(_bnad)	test_bit(BNAD_F_HWERROR, &(_bnad)->flags)
+#define BNAD_ADMIN_DOWN(_bnad)	(!netif_running((_bnad)->netdev) ||	\
+	test_bit(BNAD_F_BCU_DISABLED, &(_bnad)->flags))
+
+#define BNAD_Q_INDEX_CHANGE(_old_idx, _updated_idx, _q_depth)	\
+	(((_updated_idx) - (_old_idx)) & ((_q_depth) - 1))
+
+#define bnad_conf_lock()	down(&bnad->conf_sem)
+#define bnad_conf_unlock()	up(&bnad->conf_sem)
+
+extern u32 bfi_image_ct_size;
+extern u32 *bfi_image_ct;
+extern u32 *bfad_get_firmware_buf(struct pci_dev *pdev);
+
+struct bnad_skb_unmap {
+	struct sk_buff *skb;
+	DECLARE_PCI_UNMAP_ADDR(dma_addr)
+};
+
+struct bnad_unmap_q {
+	u32 producer_index;
+	u32 consumer_index;
+	struct bnad_skb_unmap *unmap_array;
+	u32 q_depth;
+};
+
+struct bnad_ib_entry {
+	struct bna_ib *ib;
+	void *ib_seg_addr;
+	struct bna_ib_config ib_config;
+};
+
+struct bnad_txq_info {
+	unsigned long flags;
+#define BNAD_TXQ_FREE_SENT	0
+	struct bna_txq txq;
+	struct bna_ib ib;
+	struct bnad_unmap_q skb_unmap_q;
+	u64 tx_packets;
+	u64 tx_bytes;
+	struct bnad *bnad;
+	volatile u32 *hw_consumer_index;
+	struct bna_txq_config txq_config;
+	char name[BNAD_QUEUE_NAME_SIZE];
+} ____cacheline_aligned;
+
+struct bnad_rxq_info {
+	unsigned long flags;
+#define BNAD_RXQ_REFILL		0
+	struct bna_rxq rxq;
+	struct bnad_unmap_q skb_unmap_q;
+	u64 rx_packets;
+	u64 rx_bytes;
+	u64 rx_packets_with_error;
+	u64 rxbuf_alloc_failed;
+	struct bnad *bnad;
+	u32 rxq_id;
+	struct bna_rxq_config rxq_config;
+} ____cacheline_aligned;
+
+struct bnad_cq_info {
+	struct bna_cq cq;
+	struct bna_ib ib;
+	struct bnad *bnad;
+	struct bna_pkt_rate pkt_rate;
+	u8 rx_coalescing_timeo;	/* Unit is 5usec. */
+	volatile u32 *hw_producer_index;
+	struct napi_struct napi;
+	u32 cq_id;
+	struct bna_cq_config cq_config;
+	char name[BNAD_QUEUE_NAME_SIZE];
+} ____cacheline_aligned;
+
+struct bnad_txf_info {
+	u32 txf_id;
+	struct bna_txf_config txf_config;
+};
+
+struct bnad_rxf_info {
+	u32 rxf_id;
+	struct bna_rxf_config rxf_config;
+};
+
+enum bnad_ucast_cmd {
+	BNAD_UCAST_MAC_SET,
+	BNAD_UCAST_MAC_ADD,
+	BNAD_UCAST_MAC_DEL
+};
+
+enum bnad_state {
+	BNAD_S_START = 0,
+	BNAD_S_INIT = 1,
+	BNAD_S_INIT_DOWN = 2,
+	BNAD_S_INIT_DISABLING = 3,
+	BNAD_S_INIT_DISABLED = 4,
+	BNAD_S_OPENING = 5,
+	BNAD_S_OPEN = 6,
+	BNAD_S_OPEN_DOWN = 7,
+	BNAD_S_OPEN_DISABLING = 8,
+	BNAD_S_OPEN_DISABLED = 9,
+	BNAD_S_CLOSING = 10,
+	BNAD_S_UNLOADING = 11
+};
+
+enum bnad_link_state {
+	BNAD_LS_DOWN = 0,
+	BNAD_LS_UP = 1
+};
+struct bnad {
+	struct net_device *netdev;
+	struct pci_dev *pcidev;
+	struct bna_dev *priv;
+
+	enum bnad_state state;
+	unsigned long flags;
+#define BNAD_F_BCU_DISABLED		0
+#define BNAD_F_HWERROR			1
+#define BNAD_F_MBOX_IRQ_DISABLED	2
+#define BNAD_F_CEE_RUNNING		3
+
+	unsigned int config;
+#define BNAD_CF_MSIX		0x01
+#define BNAD_CF_PROMISC		0x02
+#define BNAD_CF_ALLMULTI		0x04
+#define BNAD_CF_TXQ_DEPTH	0x10
+#define BNAD_CF_RXQ_DEPTH	0x20
+
+	unsigned int priority;
+	unsigned int curr_priority;	/* currently applied priority */
+
+	enum bnad_link_state link_state;
+	u8 cee_linkup;
+
+	uint txq_num;
+	uint txq_depth;
+	struct bnad_txq_info *txq_table;
+
+	struct tasklet_struct tx_free_tasklet;	/* For Tx cleanup */
+
+	uint rxq_num;
+	uint rxq_depth;
+	struct bnad_rxq_info *rxq_table;
+	uint cq_num;
+	struct bnad_cq_info *cq_table;
+
+	struct vlan_group *vlangrp;
+
+	u32 rx_csum;
+
+	uint msix_num;
+	struct msix_entry *msix_table;
+
+	uint ib_num;
+	struct bnad_ib_entry *ib_table;
+
+	struct bna_rit_entry *rit;	/* RxQ Indirection Table */
+
+	spinlock_t priv_lock ____cacheline_aligned;
+
+	uint txf_num;
+	struct bnad_txf_info *txf_table;
+	uint rxf_num;
+	struct bnad_rxf_info *rxf_table;
+
+	struct timer_list stats_timer;
+	struct net_device_stats net_stats;
+
+	u8 tx_coalescing_timeo;	/* Unit is 5usec. */
+	u8 tx_interpkt_count;
+
+	u8 rx_coalescing_timeo;	/* Unit is 5usec. */
+	u8 rx_interpkt_count;
+	u8 rx_interpkt_timeo;	/* 4 bits, unit is 0.5usec. */
+
+	u8 rx_dyn_coalesce_on;	/* Rx Dynamic Intr Moderation Flag */
+
+	u8 ref_count;
+
+	u8 lldp_comp_status;
+	u8 cee_stats_comp_status;
+	u8 cee_reset_stats_status;
+	u8 ucast_comp_status;
+	u8 qstop_comp_status;
+
+	int ioc_comp_status;
+
+	struct bna_pause_config pause_config;
+
+	struct bna_stats *hw_stats;
+	struct bnad_drv_stats stats;
+
+	struct work_struct work;
+	unsigned int work_flags;
+#define BNAD_WF_ERROR		0x1
+#define BNAD_WF_RESETDONE	0x2
+#define BNAD_WF_CEE_PRIO	0x4
+#define BNAD_WF_LS_NOTIFY	0x8
+
+	struct completion lldp_comp;
+	struct completion cee_stats_comp;
+	struct completion cee_reset_stats_comp;
+	struct completion ucast_comp;
+	struct completion qstop_comp;
+	struct completion ioc_comp;
+
+	u32 bna_id;
+	u8 __iomem *bar0;	/* registers */
+	unsigned char perm_addr[ETH_ALEN];
+
+	void *priv_stats;
+	  DECLARE_PCI_UNMAP_ADDR(priv_stats_dma)
+
+	struct bfa_trc_mod *trcmod;
+	struct bfa_log_mod *logmod;
+	struct bna_meminfo ioc_meminfo[BNA_MEM_T_MAX];
+	struct timer_list ioc_timer;
+	struct semaphore    conf_sem;
+
+	struct bna_mbox_cbfn priv_cbfn;
+
+	char adapter_name[64];
+	char port_name[64];
+
+	/* CEE Stuff */
+	struct bfa_cee_cbfn cee_cbfn;
+	struct bfa_cee cee;
+
+	struct list_head list_entry;
+};
+
+extern uint bnad_rxqs_per_cq;
+
+extern struct semaphore bnad_list_sem;
+extern struct list_head bnad_list;
+
+int bnad_open(struct net_device *netdev);
+int bnad_stop(struct net_device *netdev);
+int bnad_stop_locked(struct net_device *netdev);
+int bnad_open_locked(struct net_device *netdev);
+int bnad_sw_reset_locked(struct net_device *netdev);
+int bnad_ioc_disabling_locked(struct bnad *bnad);
+void bnad_set_ethtool_ops(struct net_device *netdev);
+void bnad_ioctl_init(void);
+void bnad_ioctl_exit(void);
+struct net_device_stats *bnad_get_stats(struct net_device *netdev);
+
+int bnad_ucast_mac(struct bnad *bnad, unsigned int rxf_id, u8 * mac_ptr,
+		   unsigned int cmd);
+void bnad_rxf_init(struct bnad *bnad, uint rxf_id, u8 rit_offset, int rss);
+int bnad_rxq_init(struct bnad *bnad, uint rxq_id);
+void bnad_setup_rxq(struct bnad *bnad, uint rxq_id);
+void bnad_alloc_for_rxq(struct bnad *bnad, uint rxq_id);
+int bnad_disable_rxqs(struct bnad *bnad, u64 rxq_id_mask);
+void bnad_free_rxq(struct bnad *bnad, uint rxq_id);
+int bnad_cq_init(struct bnad *bnad, uint cq_id);
+void bnad_setup_cq(struct bnad *bnad, uint cq_id);
+void bnad_setup_ib(struct bnad *bnad, uint ib_id);
+void bnad_rxib_init(struct bnad *bnad, uint cq_id, uint ib_id);
+void bnad_free_ib(struct bnad *bnad, uint ib_id);
+int bnad_request_cq_irq(struct bnad *bnad, uint cq_id);
+u32 bnad_get_msglevel(struct net_device *netdev);
+void bnad_set_msglevel(struct net_device *netdev, u32 msglevel);
+int bnad_alloc_unmap_q(struct bnad_unmap_q *unmap_q, u32 q_depth);
+void bnad_free_cq(struct bnad *bnad, uint cq_id);
+void bnad_add_to_list(struct bnad *bnad);
+void bnad_remove_from_list(struct bnad *bnad);
+struct bnad *get_bnadev(int bna_id);
+int bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev);
+
+#endif /* _BNAD_H_ */

From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 16 Oct 2009 11:24:56 -0700
Message-ID: <200910161824.n9GIOuoX010135@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:36256 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbZJPS37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 14:29:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 1/6 which contains linux driver source for
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.32

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 bnad.c | 3576 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 bnad.h |  374 ++++++
 2 files changed, 3950 insertions(+)

diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bnad.c linux-2.6.32-rc4-mod/drivers/net/bna/bnad.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bnad.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bnad.c	2009-10-16 10:30:53.050461000 -0700
@@ -0,0 +1,3576 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved.
+ */
+
+/**
+ *  bnad.c  Brocade 10G PCIe Ethernet driver.
+ */
+
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
+#ifdef NETIF_F_TSO
+#include <net/checksum.h>
+#endif
+
+
+#include "bnad.h"
+#include "bna_os.h"
+#include "bna_iocll.h"
+#include "bna_intr.h"
+#include "bnad_defs.h"
+
+#ifdef BNAD_NO_IP_ALIGN
+#undef NET_IP_ALIGN
+#define NET_IP_ALIGN	0
+#endif
+
+
+
+#define BNAD_TXQ_WI_NEEDED(_vectors)	(((_vectors) + 3) >> 2)
+
+#define BNAD_RESET_Q(_bnad, _q, _unmap_q)				\
+do {									\
+	if ((_q)->producer_index != (_q)->consumer_index) {      \
+		DPRINTK(ERR, "Q producer index %u != ",	(_q)->producer_index);      \
+		DPRINTK(ERR, "consumer index %u\n", (_q)->consumer_index);      \
+	}								\
+	BNA_ASSERT((_q)->producer_index == (_q)->consumer_index);      \
+	if ((_unmap_q)->producer_index != (_unmap_q)->consumer_index) {      \
+		DPRINTK(ERR, "UnmapQ producer index %u != ", (_unmap_q)->producer_index);      \
+		DPRINTK(ERR, "consumer index %u\n", (_unmap_q)->consumer_index);      \
+	}								\
+	BNA_ASSERT((_unmap_q)->producer_index == \
+		(_unmap_q)->consumer_index);      \
+	(_q)->producer_index = 0;	\
+	(_q)->consumer_index = 0;	\
+	(_unmap_q)->producer_index = 0;	\
+	(_unmap_q)->consumer_index = 0;	\
+	{	\
+		u32 _ui;	\
+		for (_ui = 0; _ui < (_unmap_q)->q_depth; _ui++)		\
+			BNA_ASSERT(!(_unmap_q)->unmap_array[_ui].skb);      \
+	}	\
+} while (0)
+
+static uint bnad_msix = 1;
+module_param(bnad_msix, uint, 0444);
+MODULE_PARM_DESC(bnad_msix, "Enable MSI-X");
+
+uint bnad_small_large_rxbufs = 1;
+module_param(bnad_small_large_rxbufs, uint, 0444);
+MODULE_PARM_DESC(bnad_small_large_rxbufs, "Enable small/large buffer receive");
+
+static uint bnad_rxqsets_used;
+module_param(bnad_rxqsets_used, uint, 0444);
+MODULE_PARM_DESC(bnad_rxqsets_used, "Number of RxQ sets to be used");
+
+static uint bnad_ipid_mode;
+module_param(bnad_ipid_mode, uint, 0444);
+MODULE_PARM_DESC(bnad_ipid_mode, "0 - Use IP ID 0x0000 - 0x7FFF for LSO; "
+    "1 - Use full range of IP ID for LSO");
+
+uint bnad_txq_depth = BNAD_ENTRIES_PER_TXQ;
+module_param(bnad_txq_depth, uint, 0444);
+MODULE_PARM_DESC(bnad_txq_depth, "Maximum number of entries per TxQ");
+
+uint bnad_rxq_depth = BNAD_ENTRIES_PER_RXQ;
+module_param(bnad_rxq_depth, uint, 0444);
+MODULE_PARM_DESC(bnad_rxq_depth, "Maximum number of entries per RxQ");
+
+static uint bnad_vlan_strip = 1;
+module_param(bnad_vlan_strip, uint, 0444);
+MODULE_PARM_DESC(bnad_vlan_strip, "Let the hardware strip off VLAN header");
+
+static uint bnad_log_level = LOG_WARN_LEVEL;
+module_param(bnad_log_level, uint, 0644);
+MODULE_PARM_DESC(bnad_log_level, "Log level");
+
+static uint bnad_ioc_auto_recover = 1;
+module_param(bnad_ioc_auto_recover, uint, 0644);
+MODULE_PARM_DESC(bnad_ioc_auto_recover, "Enable auto recovery");
+
+uint bnad_rxqs_per_cq;
+
+static void bnad_disable_msix(struct bnad *bnad);
+static void bnad_free_ibs(struct bnad *bnad);
+static void bnad_set_rx_mode(struct net_device *netdev);
+static void bnad_set_rx_mode_locked(struct net_device *netdev);
+static void bnad_reconfig_vlans(struct bnad *bnad);
+static void bnad_q_num_init(struct bnad *bnad, uint rxqsets);
+static int bnad_set_mac_address(struct net_device *netdev, void *addr);
+static int bnad_set_mac_address_locked(struct net_device *netdev, void *addr);
+static int bnad_change_mtu(struct net_device *netdev, int new_mtu);
+static int bnad_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
+static void
+bnad_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
+static void bnad_vlan_rx_add_vid(struct net_device *netdev, unsigned short vid);
+static void
+bnad_vlan_rx_kill_vid(struct net_device *netdev, unsigned short vid);
+static void bnad_netpoll(struct net_device *netdev);
+
+static const struct net_device_ops bnad_netdev_ops = {
+	.ndo_open				= bnad_open,
+	.ndo_stop				= bnad_stop,
+	.ndo_start_xmit			= bnad_start_xmit,
+	.ndo_get_stats			= bnad_get_stats,
+#ifdef HAVE_SET_RX_MODE
+	.ndo_set_rx_mode		= &bnad_set_rx_mode,
+#endif
+	.ndo_set_multicast_list	= bnad_set_rx_mode,
+	.ndo_set_mac_address	= bnad_set_mac_address,
+	.ndo_change_mtu			= bnad_change_mtu,
+	.ndo_do_ioctl			= bnad_ioctl,
+
+	.ndo_vlan_rx_register	= bnad_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= bnad_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= bnad_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= bnad_netpoll,
+#endif
+};
+static int bnad_check_module_params(void)
+{
+	/* bnad_msix */
+	if (bnad_msix && bnad_msix != 1)
+		printk(KERN_WARNING "bna: bnad_msix should be 0 or 1, "
+		    "%u is invalid, set bnad_msix to 1\n", bnad_msix);
+
+	/* bnad_small_large_rxbufs */
+	if (bnad_small_large_rxbufs && bnad_small_large_rxbufs != 1)
+		printk(KERN_WARNING "bna: bnad_small_large_rxbufs should be "
+		    "0 or 1, %u is invalid, set bnad_small_large_rxbufs to 1\n",
+		    bnad_small_large_rxbufs);
+	if (bnad_small_large_rxbufs)
+		bnad_rxqs_per_cq = 2;
+	else
+		bnad_rxqs_per_cq = 1;
+
+	/* bnad_rxqsets_used */
+	if (bnad_rxqsets_used > BNAD_MAX_RXQS / bnad_rxqs_per_cq) {
+		printk(KERN_ERR "bna: the maximum value for bnad_rxqsets_used "
+		    "is %u, %u is invalid\n",
+		    BNAD_MAX_RXQS / bnad_rxqs_per_cq, bnad_rxqsets_used);
+		return -EINVAL;
+	}
+	if (!BNA_POWER_OF_2(bnad_rxqsets_used)) {
+		printk(KERN_ERR "bna: bnad_rxqsets_used should be power of 2, "
+		    "%u is invalid\n", bnad_rxqsets_used);
+		return -EINVAL;
+	}
+	if (bnad_rxqsets_used > (uint)num_online_cpus())
+		printk(KERN_WARNING "bna: set bnad_rxqsets_used (%u) "
+		    "larger than number of CPUs (%d) may not be helpful\n",
+		    bnad_rxqsets_used, num_online_cpus());
+
+	/* bnad_ipid_mode */
+	if (bnad_ipid_mode && bnad_ipid_mode != 1) {
+		printk(KERN_ERR "bna: bnad_ipid_mode should be 0 or 1, "
+		    "%u is invalid\n", bnad_ipid_mode);
+		return -EINVAL;
+	}
+
+	/* bnad_txq_depth */
+	if (bnad_txq_depth > BNAD_MAX_Q_DEPTH) {
+		printk(KERN_ERR "bna: bnad_txq_depth should be <= %u, "
+		    "%u is invalid\n", BNAD_MAX_Q_DEPTH, bnad_txq_depth);
+		return -EINVAL;
+	}
+	if (!BNA_POWER_OF_2(bnad_txq_depth)) {
+		printk(KERN_ERR "bna: bnad_txq_depth should be power of 2, "
+		    "%u is invalid\n", bnad_txq_depth);
+		return -EINVAL;
+	}
+	if (bnad_txq_depth < BNAD_MIN_Q_DEPTH) {
+		printk(KERN_ERR "bna: bnad_txq_depth should be >= %u, "
+		    "%u is invalid\n", BNAD_MIN_Q_DEPTH, bnad_txq_depth);
+		return -EINVAL;
+	}
+
+	/* bnad_rxq_depth */
+	if (bnad_rxq_depth > BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq) {
+		printk(KERN_ERR "bna: bnad_rxq_depth should be <= %u, "
+		    "%u is invalid\n", BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq,
+		    bnad_rxq_depth);
+		return -EINVAL;
+	}
+	if (!BNA_POWER_OF_2(bnad_rxq_depth)) {
+		printk(KERN_ERR "bna: bnad_rxq_depth should be power of 2, "
+		    "%u is invalid\n", bnad_rxq_depth);
+		return -EINVAL;
+	}
+	if (bnad_rxq_depth < BNAD_MIN_Q_DEPTH) {
+		printk(KERN_ERR "bna: bnad_rxq_depth should be >= %u, "
+		    "%u is invalid\n", BNAD_MIN_Q_DEPTH, bnad_rxq_depth);
+		return -EINVAL;
+	}
+
+	/* bnad_vlan_strip */
+	if (bnad_vlan_strip && bnad_vlan_strip != 1)
+		printk(KERN_WARNING "bna: bnad_vlan_strip should be 0 or 1, "
+		    "%u is invalid, set bnad_vlan_strip to 1\n",
+		    bnad_vlan_strip);
+
+	/* bnad_ioc_auto_recover */
+	if (bnad_ioc_auto_recover && bnad_ioc_auto_recover != 1)
+		printk(KERN_WARNING
+			"bna: bnad_ioc_auto_recover should be 0 or 1, "
+		    "%u is invalid, set bnad_ioc_auto_recover to 1\n",
+		    bnad_ioc_auto_recover);
+
+
+	return 0;
+}
+
+u32 bnad_get_msglevel(struct net_device *netdev)
+{
+	return bnad_log_level;
+}
+
+void bnad_set_msglevel(struct net_device *netdev, u32 msglevel)
+{
+	bnad_log_level = msglevel;
+}
+
+static unsigned int bnad_free_txbufs(struct bnad_txq_info *txqinfo,
+    u16 updated_txq_cons)
+{
+	struct bnad *bnad = txqinfo->bnad;
+	unsigned int sent_packets = 0, sent_bytes = 0;
+	u16 wis, unmap_cons;
+	struct bnad_skb_unmap *unmap_array;
+	struct sk_buff *skb;
+	int i;
+
+	wis = BNAD_Q_INDEX_CHANGE(txqinfo->txq.q.consumer_index,
+	    updated_txq_cons, txqinfo->txq.q.q_depth);
+	BNA_ASSERT(wis <=
+	    BNA_QE_IN_USE_CNT(&txqinfo->txq.q, txqinfo->txq.q.q_depth));
+	unmap_array = txqinfo->skb_unmap_q.unmap_array;
+	unmap_cons = txqinfo->skb_unmap_q.consumer_index;
+	prefetch(&unmap_array[unmap_cons + 1]);
+	while (wis) {
+		skb = unmap_array[unmap_cons].skb;
+		BNA_ASSERT(skb);
+		unmap_array[unmap_cons].skb = NULL;
+		BNA_ASSERT(wis >=
+		    BNAD_TXQ_WI_NEEDED(1 + skb_shinfo(skb)->nr_frags));
+		BNA_ASSERT(((txqinfo->skb_unmap_q.producer_index -
+		    unmap_cons) & (txqinfo->skb_unmap_q.q_depth - 1)) >=
+		    1 + skb_shinfo(skb)->nr_frags);
+
+		sent_packets++;
+		sent_bytes += skb->len;
+		wis -= BNAD_TXQ_WI_NEEDED(1 + skb_shinfo(skb)->nr_frags);
+
+		pci_unmap_single(bnad->pcidev,
+		    pci_unmap_addr(&unmap_array[unmap_cons], dma_addr),
+		    skb_headlen(skb), PCI_DMA_TODEVICE);
+		pci_unmap_addr_set(&unmap_array[unmap_cons], dma_addr, 0);
+		BNA_QE_INDX_ADD(unmap_cons, 1, txqinfo->skb_unmap_q.q_depth);
+		prefetch(&unmap_array[unmap_cons + 1]);
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			pci_unmap_page(bnad->pcidev,
+			    pci_unmap_addr(&unmap_array[unmap_cons], dma_addr),
+			    skb_shinfo(skb)->frags[i].size, PCI_DMA_TODEVICE);
+			pci_unmap_addr_set(&unmap_array[unmap_cons], dma_addr,
+			    0);
+			BNA_QE_INDX_ADD(unmap_cons, 1,
+			    txqinfo->skb_unmap_q.q_depth);
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
+static int bnad_lro_get_skb_header(struct sk_buff *skb, void **iphdr,
+    void **tcphdr, u64 *hdr_flags, void *priv)
+{
+	struct bna_cq_entry *cmpl = priv;
+	u32 flags = ntohl(cmpl->flags);
+
+	if ((flags & BNA_CQ_EF_IPV4) && (flags & BNA_CQ_EF_TCP)) {
+		skb_reset_network_header(skb);
+		skb_set_transport_header(skb, ip_hdrlen(skb));
+		*iphdr = ip_hdr(skb);
+		*tcphdr = tcp_hdr(skb);
+		*hdr_flags = LRO_IPV4 | LRO_TCP;
+		return 0;
+	} else {
+		return -1;
+	}
+}
+
+static inline void bnad_disable_txrx_irqs(struct bnad *bnad)
+{
+	int i;
+
+	for (i = 0; i < bnad->txq_num; i++) {
+		bna_ib_coalescing_timer_set(bnad->priv,
+		    &bnad->txq_table[i].ib, 0);
+		bna_ib_ack(bnad->priv, &bnad->txq_table[i].ib, 0);
+	}
+
+	for (i = 0; i < bnad->cq_num; i++) {
+		bna_ib_coalescing_timer_set(bnad->priv,
+		    &bnad->cq_table[i].ib, 0);
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
+		bna_ib_coalescing_timer_set(bnad->priv,
+		    &bnad->txq_table[i].ib, bnad->tx_coalescing_timeo);
+		bna_ib_ack(bnad->priv, &bnad->txq_table[i].ib, 0);
+	}
+
+	for (i = 0; i < bnad->cq_num; i++) {
+		bna_ib_coalescing_timer_set(bnad->priv,
+		    &bnad->cq_table[i].ib,
+			bnad->cq_table[i].rx_coalescing_timeo);
+		bna_ib_ack(bnad->priv, &bnad->cq_table[i].ib, 0);
+	}
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+static inline void
+bnad_disable_rx_irq(struct bnad *bnad, struct bnad_cq_info *cqinfo)
+{
+	bna_ib_coalescing_timer_set(bnad->priv, &cqinfo->ib, 0);
+	bna_ib_ack(bnad->priv, &cqinfo->ib, 0);
+}
+static inline void
+bnad_enable_rx_irq(struct bnad *bnad, struct bnad_cq_info *cqinfo)
+{
+	spin_lock_irq(&bnad->priv_lock);
+
+	bna_ib_coalescing_timer_set(bnad->priv, &cqinfo->ib,
+	    cqinfo->rx_coalescing_timeo);
+	bna_ib_ack(bnad->priv, &cqinfo->ib, 0);
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
+	DPRINTK(DEBUG, "%s ", netdev->name);
+	DPRINTK(DEBUG, "TxQ hw consumer index %u\n",
+		*txqinfo->hw_consumer_index);
+	 sent = bnad_free_txbufs(txqinfo,
+	    (u16)(*txqinfo->hw_consumer_index));
+	if (sent) {
+		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev) &&
+		    BNA_Q_FREE_COUNT(&txqinfo->txq) >=
+				BNAD_NETIF_WAKE_THRESHOLD) {
+			netif_wake_queue(netdev);
+			bnad->stats.netif_queue_wakeup++;
+		}
+		bna_ib_ack(bnad->priv, &txqinfo->ib, sent);
+		DPRINTK(DEBUG, "%s ack TxQ IB %u packets\n",
+			netdev->name, sent);
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
+	to_alloc = BNA_QE_FREE_CNT(&rxqinfo->skb_unmap_q,
+	    rxqinfo->skb_unmap_q.q_depth);
+
+	unmap_array = rxqinfo->skb_unmap_q.unmap_array;
+	unmap_prod = rxqinfo->skb_unmap_q.producer_index;
+	BNA_RXQ_QPGE_PTR_GET(unmap_prod, &rxqinfo->rxq.q, rxent, wi_range);
+	BNA_ASSERT(wi_range && wi_range <= rxqinfo->rxq.q.q_depth);
+
+	while (to_alloc--) {
+		if (!wi_range) {
+			BNA_RXQ_QPGE_PTR_GET(unmap_prod, &rxqinfo->rxq.q,
+			    rxent, wi_range);
+			BNA_ASSERT(wi_range &&
+			    wi_range <= rxqinfo->rxq.q.q_depth);
+		}
+#ifdef BNAD_RXBUF_HEADROOM
+		skb = netdev_alloc_skb(rxqinfo->bnad->netdev,
+		    rxqinfo->rxq_config.buffer_size + NET_IP_ALIGN);
+#else
+		skb = alloc_skb(rxqinfo->rxq_config.buffer_size + NET_IP_ALIGN,
+		    GFP_ATOMIC);
+#endif
+		if (unlikely(!skb)) {
+			rxqinfo->rxbuf_alloc_failed++;
+			goto finishing;
+		}
+#ifndef BNAD_RXBUF_HEADROOM
+		skb->dev = rxqinfo->bnad->netdev;
+#endif
+		skb_reserve(skb, NET_IP_ALIGN);
+		unmap_array[unmap_prod].skb = skb;
+		dma_addr = pci_map_single(rxqinfo->bnad->pcidev, skb->data,
+		    rxqinfo->rxq_config.buffer_size, PCI_DMA_FROMDEVICE);
+		pci_unmap_addr_set(&unmap_array[unmap_prod],
+			dma_addr, dma_addr);
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
+		if (BNA_QE_FREE_CNT(&rxqinfo->skb_unmap_q,
+		    rxqinfo->skb_unmap_q.q_depth) >>
+		    BNAD_RXQ_REFILL_THRESHOLD_SHIFT)
+			bnad_alloc_rxbufs(rxqinfo);
+		smp_mb__before_clear_bit();
+		clear_bit(BNAD_RXQ_REFILL, &rxqinfo->flags);
+	}
+}
+
+static unsigned int
+bnad_poll_cq(struct bnad *bnad, struct bnad_cq_info *cqinfo, int budget)
+{
+	struct bna_cq_entry *cmpl, *next_cmpl;
+	unsigned int wi_range, packets = 0, wis = 0;
+	struct bnad_rxq_info *rxqinfo = NULL;
+	struct bnad_unmap_q *unmap_q;
+	struct sk_buff *skb;
+	u32 flags;
+	struct bna_pkt_rate *pkt_rt = &cqinfo->pkt_rate;
+
+	prefetch(bnad);
+	prefetch(bnad->netdev);
+	cmpl = bna_cq_pg_prod_ptr(&cqinfo->cq, &wi_range);
+	BNA_ASSERT(wi_range && wi_range <= cqinfo->cq.q.q_depth);
+	while (cmpl->valid && packets < budget) {
+		packets++;
+		BNA_UPDATE_PKT_CNT(pkt_rt, ntohs(cmpl->length));
+		rxqinfo = &bnad->rxq_table[cmpl->rxq_id];
+		unmap_q = &rxqinfo->skb_unmap_q;
+		skb = unmap_q->unmap_array[unmap_q->consumer_index].skb;
+		BNA_ASSERT(skb);
+		prefetch(skb->data - NET_IP_ALIGN);
+		unmap_q->unmap_array[unmap_q->consumer_index].skb = NULL;
+		pci_unmap_single(bnad->pcidev,
+		    pci_unmap_addr(
+		    &unmap_q->unmap_array[unmap_q->consumer_index],
+		    dma_addr),
+		    rxqinfo->rxq_config.buffer_size, PCI_DMA_FROMDEVICE);
+		BNA_QE_INDX_ADD(unmap_q->consumer_index, 1, unmap_q->q_depth);
+		/* XXX May be bad for performance. */
+		BNA_Q_CI_ADD(&rxqinfo->rxq, 1);
+		wis++;
+		if (likely(--wi_range)) {
+			next_cmpl = cmpl + 1;
+		} else {
+			BNA_Q_PI_ADD(&cqinfo->cq, wis);
+			wis = 0;
+			next_cmpl = bna_cq_pg_prod_ptr(&cqinfo->cq, &wi_range);
+			BNA_ASSERT(wi_range &&
+			    wi_range <= cqinfo->cq.q.q_depth);
+		}
+		prefetch(next_cmpl);
+
+		flags = ntohl(cmpl->flags);
+		if (unlikely(flags & (BNA_CQ_EF_MAC_ERROR |
+			BNA_CQ_EF_FCS_ERROR | BNA_CQ_EF_TOO_LONG))) {
+			dev_kfree_skb_any(skb);
+			rxqinfo->rx_packets_with_error++;
+			goto next;
+		}
+
+		skb_put(skb, ntohs(cmpl->length));
+		if (likely(bnad->rx_csum &&
+		    (((flags & BNA_CQ_EF_IPV4) &&
+		    (flags & BNA_CQ_EF_L3_CKSUM_OK)) ||
+		    (flags & BNA_CQ_EF_IPV6)) &&
+		    (flags & (BNA_CQ_EF_TCP | BNA_CQ_EF_UDP)) &&
+		    (flags & BNA_CQ_EF_L4_CKSUM_OK)))
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
+			if (skb->ip_summed == CHECKSUM_UNNECESSARY
+#ifdef NETIF_F_LRO
+			    && (bnad->netdev->features & NETIF_F_LRO)
+#endif
+) {
+				lro_vlan_hwaccel_receive_skb(&cqinfo->lro, skb,
+				    bnad->vlangrp, ntohs(cmpl->vlan_tag), cmpl);
+			} else {
+				vlan_hwaccel_receive_skb(skb, bnad->vlangrp,
+				    ntohs(cmpl->vlan_tag));
+			}
+
+		} else {
+
+			if (skb->ip_summed == CHECKSUM_UNNECESSARY
+#ifdef NETIF_F_LRO
+			    && (bnad->netdev->features & NETIF_F_LRO)
+#endif
+) {
+				lro_receive_skb(&cqinfo->lro, skb, cmpl);
+			} else {
+				netif_receive_skb(skb);
+			}
+
+		}
+
+		bnad->netdev->last_rx = jiffies;
+next:
+		cmpl->valid = 0;
+		cmpl = next_cmpl;
+	}
+
+	lro_flush_all(&cqinfo->lro);
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
+		if (likely(netif_rx_schedule_prep(bnad->netdev,
+			&cqinfo->napi))) {
+			bnad_disable_rx_irq(bnad, cqinfo);
+			__netif_rx_schedule(bnad->netdev, &cqinfo->napi);
+		}
+
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
+	bna_intr_status_get(bnad->priv, &intr_status);
+	if (BNA_IS_MBOX_ERR_INTR(intr_status)) {
+		DPRINTK(DEBUG, "port %d msix err/mbox irq status 0x%x\n",
+			bnad->bna_id, intr_status);
+		bna_mbox_err_handler(bnad->priv, intr_status);
+	} else {
+		DPRINTK(WARNING, "port %d msix err/mbox irq status 0x%x\n",
+			 bnad->bna_id, intr_status);
+	}
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
+	spin_unlock(&bnad->priv_lock);
+
+	if (!intr_status)
+		return IRQ_NONE;
+
+	DPRINTK(DEBUG, "port %u bnad_isr: 0x%x\n", bnad->bna_id, intr_status);
+	if (BNA_IS_MBOX_ERR_INTR(intr_status)) {
+		spin_lock(&bnad->priv_lock);
+		bna_mbox_err_handler(bnad->priv, intr_status);
+		spin_unlock(&bnad->priv_lock);
+		if (BNA_IS_ERR_INTR(intr_status) ||
+		    !BNA_IS_INTX_DATA_INTR(intr_status))
+			goto exit_isr;
+	}
+
+	if (likely(netif_rx_schedule_prep(bnad->netdev,
+	    &bnad->cq_table[0].napi))) {
+		bnad_disable_txrx_irqs(bnad);
+		__netif_rx_schedule(bnad->netdev, &bnad->cq_table[0].napi);
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
+	if (bnad->flags & BNAD_F_MSIX) {
+		DPRINTK(DEBUG,
+			"port %u requests IRQ %u for mailbox in MSI-X mode\n",
+			bnad->bna_id,
+			bnad->msix_table[bnad->msix_num - 1].vector);
+		err = request_irq(bnad->msix_table[bnad->msix_num - 1].vector,
+		    (irq_handler_t)&bnad_msix_err_mbox, 0, bnad->netdev->name,
+		    bnad->netdev);
+	} else {
+		DPRINTK(DEBUG, "port %u requests IRQ %u in INTx mode\n",
+			bnad->bna_id, bnad->pcidev->irq);
+		err = request_irq(bnad->pcidev->irq, (irq_handler_t)&bnad_isr,
+		    IRQF_SHARED, bnad->netdev->name, bnad->netdev);
+	}
+
+	if (err) {
+		dev_err(&bnad->pcidev->dev,
+		    "Request irq for mailbox failed: %d\n", err);
+		return err;
+	}
+
+	if (bnad->flags & BNAD_F_MSIX)
+		bna_mbox_msix_idx_set(bnad->priv, bnad->msix_num - 1);
+
+	bna_mbox_intr_enable(bnad->priv);
+	return 0;
+}
+
+
+static void bnad_sync_mbox_irq(struct bnad *bnad)
+{
+	uint irq;
+
+	if (bnad->flags & BNAD_F_MSIX)
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
+	if (bnad->flags & BNAD_F_MSIX)
+		irq = bnad->msix_table[bnad->msix_num - 1].vector;
+	else
+		irq = bnad->pcidev->irq;
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_mbox_intr_disable(bnad->priv);
+	spin_unlock_irq(&bnad->priv_lock);
+	free_irq(irq, bnad->netdev);
+}
+
+static int bnad_request_txq_irq(struct bnad *bnad, uint txq_id)
+{
+	BNA_ASSERT(txq_id < bnad->txq_num);
+	if (!(bnad->flags & BNAD_F_MSIX))
+		return 0;
+	DPRINTK(DEBUG, "port %u requests irq %u for TxQ %u in MSIX mode\n",
+		bnad->bna_id, bnad->msix_table[txq_id].vector, txq_id);
+	return request_irq(bnad->msix_table[txq_id].vector,
+	    (irq_handler_t)&bnad_msix_tx, 0, bnad->txq_table[txq_id].name,
+	    &bnad->txq_table[txq_id]);
+}
+
+int bnad_request_cq_irq(struct bnad *bnad, uint cq_id)
+{
+	BNA_ASSERT(cq_id < bnad->cq_num);
+	if (!(bnad->flags & BNAD_F_MSIX))
+		return 0;
+	DPRINTK(DEBUG, "port %u requests irq %u for CQ %u in MSIX mode\n",
+		bnad->bna_id,
+		bnad->msix_table[bnad->txq_num + cq_id].vector, cq_id);
+	return request_irq(bnad->msix_table[bnad->txq_num + cq_id].vector,
+	    (irq_handler_t)&bnad_msix_rx, 0, bnad->cq_table[cq_id].name,
+	    &bnad->cq_table[cq_id]);
+}
+
+static void bnad_intx_enable_txrx(struct bnad *bnad)
+{
+	u32 mask;
+	int i;
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_intx_disable(bnad->priv, &mask);
+	mask &= ~0xffff;
+	bna_intx_enable(bnad->priv, mask);
+	for (i = 0; i < bnad->ib_num; i++)
+		bna_ib_ack(bnad->priv, bnad->ib_table[i].ib, 0);
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+static int bnad_request_txrx_irqs(struct bnad *bnad)
+{
+	struct msix_entry *entries;
+	int i;
+	int err;
+
+	if (!(bnad->flags & BNAD_F_MSIX)) {
+		bnad_intx_enable_txrx(bnad);
+		return 0;
+	}
+
+	entries = bnad->msix_table;
+	for (i = 0; i < bnad->txq_num; i++) {
+		err = bnad_request_txq_irq(bnad, i);
+		if (err) {
+			printk(KERN_ERR "%s request irq for TxQ %d failed %d\n",
+			    bnad->netdev->name, i, err);
+			while (--i >= 0) {
+				free_irq(entries[i].vector,
+				    &bnad->txq_table[i]);
+			}
+			return err;
+		}
+	}
+
+	for (i = 0; i < bnad->cq_num; i++) {
+		err = bnad_request_cq_irq(bnad, i);
+		if (err) {
+			printk(KERN_ERR "%s request irq for CQ %u failed %d\n",
+			    bnad->netdev->name, i, err);
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
+	if (bnad->flags & BNAD_F_MSIX) {
+		entries = bnad->msix_table;
+		for (i = 0; i < bnad->txq_num; i++)
+			free_irq(entries[i].vector, &bnad->txq_table[i]);
+
+		for (i = 0; i < bnad->cq_num; i++)
+			free_irq(entries[bnad->txq_num + i].vector,
+			    &bnad->cq_table[i]);
+	} else {
+		synchronize_irq(bnad->pcidev->irq);
+	}
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
+	    &ib_entry->ib_config);
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
+static void bnad_link_up_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = (struct bnad *)arg;
+	struct net_device *netdev = bnad->netdev;
+
+	DPRINTK(INFO, "%s bnad_link_up_cb\n", netdev->name);
+	if (netif_running(netdev)) {
+		if (!netif_carrier_ok(netdev) &&
+		    !test_bit(BNAD_DISABLED, &bnad->state)) {
+				printk(KERN_INFO "%s link up\n", netdev->name);
+			netif_carrier_on(netdev);
+			netif_wake_queue(netdev);
+			bnad->stats.netif_queue_wakeup++;
+		}
+	}
+}
+
+static void bnad_link_down_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = (struct bnad *)arg;
+	struct net_device *netdev = bnad->netdev;
+
+	DPRINTK(INFO, "%s bnad_link_down_cb\n", netdev->name);
+	if (netif_running(netdev)) {
+		if (netif_carrier_ok(netdev)) {
+			printk(KERN_INFO "%s link down\n", netdev->name);
+			netif_carrier_off(netdev);
+			netif_stop_queue(netdev);
+			bnad->stats.netif_queue_stop++;
+		}
+	}
+}
+
+static void bnad_stats_get_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = (struct bnad *)arg;
+
+	bnad->stats.hw_stats_updates++;
+	if (!test_bit(BNAD_DISABLED, &bnad->state))
+		mod_timer(&bnad->stats_timer, jiffies + HZ);
+}
+
+/* Diagnostics */
+static void bnad_set_diag_lb_cb(void *arg, u8 status)
+{
+	struct bnad_diag_lb_params *dlbp =
+	    (struct bnad_diag_lb_params *)arg;
+
+	dlbp->diag_lb_comp_status = status;
+	DPRINTK(INFO, "bnad_set_diag_lb_cb() for %s %d\n",
+		dlbp->bnad->netdev->name, status);
+	complete(&dlbp->diag_lb_comp);
+}
+
+/* Called with bnad priv_lock held. */
+static void bnad_hw_error(struct bnad *bnad, u8 status)
+{
+	unsigned int irq;
+
+	bna_mbox_intr_disable(bnad->priv);
+	if (bnad->flags & BNAD_F_MSIX) {
+		if (!test_and_set_bit(BNAD_MBOX_IRQ_DISABLED, &bnad->state)) {
+			irq = bnad->msix_table[bnad->txq_num +
+			    bnad->cq_num].vector;
+			DPRINTK(WARNING, "Disabling Mbox IRQ %d for port %d\n",
+				irq, bnad->bna_id);
+			disable_irq_nosync(irq);
+		}
+	}
+
+	bna_cleanup(bnad->priv);
+	bnad->work_flags = BNAD_WF_ERROR;
+	if (!test_bit(BNAD_REMOVED, &bnad->state))
+		schedule_work(&bnad->work);
+}
+
+static void bnad_hw_error_cb(void *arg, u8 status)
+{
+	struct bnad *bnad = (struct bnad *)arg;
+
+	DPRINTK(WARNING, "port %d HW error callback %u\n",
+		bnad->bna_id, status);
+
+	bnad_hw_error(bnad, status);
+}
+
+int bnad_alloc_unmap_q(struct bnad_unmap_q *unmap_q, u32 q_depth)
+{
+	/* Q_depth must be power of 2 for macros to work. */
+	BNA_ASSERT(BNA_POWER_OF_2(q_depth));
+	unmap_q->q_depth = q_depth;
+	unmap_q->unmap_array = vmalloc(q_depth *
+	    sizeof(struct bnad_skb_unmap));
+	if (!unmap_q->unmap_array)
+		return -ENOMEM;
+	memset(unmap_q->unmap_array, 0,
+	    q_depth * sizeof(struct bnad_skb_unmap));
+	return 0;
+}
+
+static int bnad_alloc_unmap_queues(struct bnad *bnad)
+{
+	int i, err = 0;
+	struct bnad_txq_info *txqinfo;
+	struct bnad_rxq_info *rxqinfo;
+
+	for (i = 0; i < bnad->txq_num; i++) {
+		txqinfo = &bnad->txq_table[i];
+		err = bnad_alloc_unmap_q(&txqinfo->skb_unmap_q,
+		    txqinfo->txq.q.q_depth * 4);
+		DPRINTK(DEBUG, "%s allocating Tx unmap Q %d depth %u\n",
+			bnad->netdev->name, i, txqinfo->txq.q.q_depth * 4);
+		if (err) {
+			DPRINTK(ERR, "%s allocating Tx unmap Q %d failed: %d\n",
+				bnad->netdev->name, i, err);
+			return err;
+		}
+	}
+	for (i = 0; i < bnad->rxq_num; i++) {
+		rxqinfo = &bnad->rxq_table[i];
+		err = bnad_alloc_unmap_q(&rxqinfo->skb_unmap_q,
+		    rxqinfo->rxq.q.q_depth);
+		DPRINTK(INFO, "%s allocating Rx unmap Q %d depth %u\n",
+			bnad->netdev->name, i, rxqinfo->rxq.q.q_depth);
+		if (err) {
+			DPRINTK(ERR, "%s allocating Rx unmap Q %d failed: %d\n",
+				bnad->netdev->name, i, err);
+			return err;
+		}
+	}
+	return 0;
+}
+
+/* Called with priv_lock. */
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
+		    pci_unmap_addr(
+		    &unmap_q->unmap_array[unmap_q->consumer_index], dma_addr),
+		    rxqinfo->rxq_config.buffer_size + NET_IP_ALIGN,
+		    PCI_DMA_FROMDEVICE);
+		dev_kfree_skb(skb);
+		BNA_QE_INDX_ADD(unmap_q->consumer_index, 1, unmap_q->q_depth);
+		BNA_Q_CI_ADD(&rxqinfo->rxq, 1);
+	}
+
+	BNAD_RESET_Q(bnad, &rxqinfo->rxq.q, &rxqinfo->skb_unmap_q);
+	cq_id = rxqinfo->rxq_id / bnad_rxqs_per_cq;
+	*bnad->cq_table[cq_id].hw_producer_index = 0;
+}
+
+static int bnad_disable_txq(struct bnad *bnad, u32 txq_id)
+{
+	struct bnad_txq_info *txqinfo;
+	int err;
+
+	WARN_ON(in_interrupt());
+
+	init_completion(&bnad->qstop_comp);
+	txqinfo = &bnad->txq_table[txq_id];
+	spin_lock_irq(&bnad->priv_lock);
+	err = bna_txq_stop(bnad->priv, txq_id);
+	spin_unlock_irq(&bnad->priv_lock);
+	if (err)
+		goto txq_stop_exit;
+
+	DPRINTK(INFO, "Waiting for %s TxQ %d stop reply\n",
+		bnad->netdev->name, txq_id);
+	wait_for_completion(&bnad->qstop_comp);
+
+	err = bnad->qstop_comp_status;
+txq_stop_exit:
+	if (err)
+		DPRINTK(ERR, "%s bna_txq_stop %d failed %d\n",
+			bnad->netdev->name, txq_id, err);
+	return err;
+}
+
+int bnad_disable_rxqs(struct bnad *bnad, u64 rxq_id_mask)
+{
+	int err;
+
+	struct timeval  tv;
+
+	BNA_ASSERT(!in_interrupt());
+
+	init_completion(&bnad->qstop_comp);
+
+	spin_lock_irq(&bnad->priv_lock);
+	do_gettimeofday(&tv);
+	DPRINTK(DEBUG, "Calling bna_multi_rxq_stop at %ld:%ld\n",
+		tv.tv_sec, tv.tv_usec);
+	err = bna_multi_rxq_stop(bnad->priv, rxq_id_mask);
+	spin_unlock_irq(&bnad->priv_lock);
+	if (err)
+		goto rxq_stop_exit;
+
+	DPRINTK(INFO, "Waiting for %s RxQs(0x%llx) stop reply\n",
+		bnad->netdev->name, rxq_id_mask);
+	wait_for_completion(&bnad->qstop_comp);
+
+	do_gettimeofday(&tv);
+	DPRINTK(DEBUG, "bna_multi_rxq_stop returned at %ld:%ld\n",
+		tv.tv_sec, tv.tv_usec);
+	err = bnad->qstop_comp_status;
+rxq_stop_exit:
+	if (err)
+		DPRINTK(ERR, "%s bna_multi_rxq_stop(0x%llx) failed %d\n",
+			bnad->netdev->name, rxq_id_mask, err);
+	return err;
+
+}
+
+static int bnad_poll_rx(struct napi_struct *napi, int budget)
+{
+	struct bnad_cq_info *cqinfo =
+	    container_of(napi, struct bnad_cq_info, napi);
+	struct bnad *bnad = cqinfo->bnad;
+	unsigned int rcvd;
+
+	rcvd = bnad_poll_cq(bnad, cqinfo, budget);
+	if (rcvd == budget)
+		return rcvd;
+	netif_rx_complete(bnad->netdev, napi);
+	bnad->stats.netif_rx_complete++;
+	bnad_enable_rx_irq(bnad, cqinfo);
+	return rcvd;
+}
+
+static int bnad_poll_txrx(struct napi_struct *napi, int budget)
+{
+	struct bnad_cq_info *cqinfo =
+	    container_of(napi, struct bnad_cq_info, napi);
+	struct bnad *bnad = cqinfo->bnad;
+	unsigned int rcvd;
+
+	bnad_tx(bnad, &bnad->txq_table[0]);
+	rcvd = bnad_poll_cq(bnad, cqinfo, budget);
+	if (rcvd == budget)
+		return rcvd;
+	netif_rx_complete(bnad->netdev, napi);
+	bnad->stats.netif_rx_complete++;
+	bnad_enable_txrx_irqs(bnad);
+	return rcvd;
+}
+
+static void bnad_napi_init(struct bnad *bnad)
+{
+	int (*napi_poll)(struct napi_struct *, int);
+	int i;
+
+	if (bnad->flags & BNAD_F_MSIX)
+		napi_poll = bnad_poll_rx;
+	else
+		napi_poll = bnad_poll_txrx;
+
+	for (i = 0; i < bnad->cq_num; i++)
+		netif_napi_add(bnad->netdev, &bnad->cq_table[i].napi,
+		    napi_poll, 64);
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
+
+static void bnad_detach(struct bnad *bnad)
+{
+	int i;
+
+	ASSERT_RTNL();
+
+	spin_lock_irq(&bnad->priv_lock);
+	if (!test_bit(BNAD_RESETTING, &bnad->state)) {
+		/* Graceful detach */
+
+		bna_txf_disable(bnad->priv, BNAD_TX_FUNC_ID);
+		bna_multi_rxf_disable(bnad->priv, (1 << bnad->rxf_num) - 1);
+		for (i = 0; i < bnad->txq_num; i++)
+			bna_ib_disable(bnad->priv, &bnad->txq_table[i].ib);
+		for (i = 0; i < bnad->cq_num; i++)
+			bna_ib_disable(bnad->priv, &bnad->cq_table[i].ib);
+	} else {
+		/* Error */
+		/* XXX Should not write to registers if RESETTING. */
+
+		bna_txf_disable(bnad->priv, BNAD_TX_FUNC_ID);
+		bna_rxf_disable_old(bnad->priv, BNAD_RX_FUNC_ID);
+
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
+		bnad_napi_disable(bnad);
+		bnad_napi_uninit(bnad);
+
+	/* Delete the stats timer after synchronize with mbox irq. */
+	del_timer_sync(&bnad->stats_timer);
+		netif_tx_disable(bnad->netdev);
+		netif_carrier_off(bnad->netdev);
+}
+
+static int bnad_disable(struct bnad *bnad)
+{
+	int err, i;
+	u64 rxq_id_mask = 0;
+
+	ASSERT_RTNL();
+		DPRINTK(INFO, "bring %s link down\n", bnad->netdev->name);
+		spin_lock_irq(&bnad->priv_lock);
+		bna_port_admin(bnad->priv, BNA_DISABLE);
+		spin_unlock_irq(&bnad->priv_lock);
+
+	bnad_detach(bnad);
+
+	for (i = 0; i < bnad->txq_num; i++) {
+		err = bnad_disable_txq(bnad, i);
+		if (err)
+			return err;
+	}
+
+	for (i = 0; i < bnad->rxq_num; i++)
+		rxq_id_mask |= (1 << i);
+	if (rxq_id_mask) {
+		err = bnad_disable_rxqs(bnad, rxq_id_mask);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+int bnad_sw_reset(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err;
+
+	if (!netif_running(bnad->netdev))
+		return 0;
+
+	err = bnad_stop_locked(netdev);
+	if (err) {
+		DPRINTK(WARNING, "%s sw reset: disable failed %d\n",
+			bnad->netdev->name, err);
+		/* Recoverable */
+		return 0;
+	}
+
+	err = bnad_open_locked(netdev);
+	if (err) {
+		DPRINTK(WARNING, "%s sw reset: enable failed %d\n",
+			bnad->netdev->name, err);
+		return err;
+	}
+
+	return 0;
+}
+
+int bnad_resetting(struct bnad *bnad)
+{
+	rtnl_lock();
+	if (netif_running(bnad->netdev))
+		bnad_stop_locked(bnad->netdev);
+	set_bit(BNAD_RESETTING, &bnad->state);
+	rtnl_unlock();
+	return 0;
+}
+
+int bnad_alloc_ib(struct bnad *bnad, uint ib_id)
+{
+	struct bnad_ib_entry *ib_entry;
+	dma_addr_t dma_addr;
+
+	BNA_ASSERT(bnad->ib_table && ib_id < bnad->ib_num);
+	ib_entry = &bnad->ib_table[ib_id];
+	ib_entry->ib_seg_addr = pci_alloc_consistent(bnad->pcidev,
+	    L1_CACHE_BYTES, &dma_addr);
+	if (!ib_entry->ib_seg_addr)
+		return -ENOMEM;
+	DPRINTK(DEBUG, "%s IB %d dma addr 0x%llx\n",
+		bnad->netdev->name, ib_id, dma_addr);
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
+	bnad->ib_table = kzalloc(bnad->ib_num *
+	    sizeof(struct bnad_ib_entry), GFP_KERNEL);
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
+		    ib_entry->ib_seg_addr, dma_addr);
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
+
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
+	DPRINTK(DEBUG, "qpt page count 0x%x, ", qpt->page_count);
+	DPRINTK(DEBUG, "page size 0x%x\n", qpt->page_size);
+
+	qpt->kv_qpt_ptr = pci_alloc_consistent(bnad->pcidev,
+	    qpt->page_count * sizeof(struct bna_dma_addr), &dma_addr);
+	if (!qpt->kv_qpt_ptr)
+		return -ENOMEM;
+	BNA_SET_DMA_ADDR(dma_addr, &qpt->hw_qpt_ptr);
+	DPRINTK(DEBUG, "qpt host addr %p, ", qpt->kv_qpt_ptr);
+	DPRINTK(DEBUG, "dma addr 0x%llx\n", dma_addr);
+
+	q->qpt_ptr = kzalloc(qpt->page_count * sizeof(void *), GFP_KERNEL);
+	if (!q->qpt_ptr)
+		return -ENOMEM;
+	qpt->qpt_ptr = q->qpt_ptr;
+	for (i = 0; i < qpt->page_count; i++) {
+		q->qpt_ptr[i] = pci_alloc_consistent(bnad->pcidev, PAGE_SIZE,
+		    &dma_addr);
+		if (!q->qpt_ptr[i])
+			return -ENOMEM;
+		BNA_SET_DMA_ADDR(dma_addr,
+		    &((struct bna_dma_addr *)qpt->kv_qpt_ptr)[i]);
+
+		DPRINTK(DEBUG, "page %d ", (int)i);
+		DPRINTK(DEBUG, "host addr %p, ", q->qpt_ptr[i]);
+		DPRINTK(DEBUG, "dma addr 0x%llx\n", dma_addr);
+	}
+
+	return 0;
+}
+
+static void
+bnad_free_q(struct bnad *bnad, struct bna_qpt *qpt, struct bna_q *q)
+{
+	int i;
+	dma_addr_t dma_addr;
+
+	if (qpt->kv_qpt_ptr && q->qpt_ptr) {
+		for (i = 0; i < qpt->page_count; i++) {
+			if (q->qpt_ptr[i]) {
+				BNA_GET_DMA_ADDR(
+				    &((struct bna_dma_addr *)
+					qpt->kv_qpt_ptr)[i], dma_addr);
+				pci_free_consistent(bnad->pcidev, PAGE_SIZE,
+				    q->qpt_ptr[i], dma_addr);
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
+		    qpt->page_count * sizeof(struct bna_dma_addr),
+		    qpt->kv_qpt_ptr, dma_addr);
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
+	vfree(cqinfo->lro.lro_arr);
+	cqinfo->lro.lro_arr = NULL;
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
+	DPRINTK(DEBUG, "%s allocating TxQ %d\n", bnad->netdev->name, txq_id);
+	err = bnad_alloc_q(bnad, &txqinfo->txq_config.qpt, &txqinfo->txq.q,
+	    bnad->txq_depth * sizeof(struct bna_txq_entry));
+	if (err) {
+		bnad_free_q(bnad, &txqinfo->txq_config.qpt, &txqinfo->txq.q);
+		return err;
+	}
+	txqinfo->txq.q.q_depth = bnad->txq_depth;
+	txqinfo->bnad = bnad;
+	txqinfo->txq_config.txf_id = BNAD_TX_FUNC_ID;
+	snprintf(txqinfo->name, sizeof(txqinfo->name), "%s TxQ %d",
+	    bnad->netdev->name, txq_id);
+	return 0;
+}
+
+static int bnad_txqs_init(struct bnad *bnad)
+{
+	int i, err = 0;
+
+	bnad->txq_table = kzalloc(bnad->txq_num *
+	    sizeof(struct bnad_txq_info), GFP_KERNEL);
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
+	DPRINTK(DEBUG, "%s allocating RxQ %d\n", bnad->netdev->name, rxq_id);
+	err = bnad_alloc_q(bnad, &rxqinfo->rxq_config.qpt, &rxqinfo->rxq.q,
+	    bnad->rxq_depth * sizeof(struct bna_rxq_entry));
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
+	bnad->rxq_table = kzalloc(bnad->rxq_num *
+	    sizeof(struct bnad_rxq_info), GFP_KERNEL);
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
+	DPRINTK(DEBUG, "%s allocating CQ %d\n", bnad->netdev->name, cq_id);
+	err = bnad_alloc_q(bnad, &cqinfo->cq_config.qpt, &cqinfo->cq.q,
+	    bnad->rxq_depth * bnad_rxqs_per_cq * sizeof(struct bna_cq_entry));
+	if (err) {
+		bnad_free_q(bnad, &cqinfo->cq_config.qpt, &cqinfo->cq.q);
+		return err;
+	}
+
+	cqinfo->cq.q.q_depth = bnad->rxq_depth * bnad_rxqs_per_cq;
+	cqinfo->bnad = bnad;
+
+	cqinfo->lro.dev = bnad->netdev;
+	cqinfo->lro.features |= LRO_F_NAPI;
+	if (bnad_vlan_strip)
+		cqinfo->lro.features |= LRO_F_EXTRACT_VLAN_ID;
+	cqinfo->lro.ip_summed = CHECKSUM_UNNECESSARY;
+	cqinfo->lro.ip_summed_aggr = CHECKSUM_UNNECESSARY;
+	cqinfo->lro.max_desc = BNAD_LRO_MAX_DESC;
+	cqinfo->lro.max_aggr = BNAD_LRO_MAX_AGGR;
+	/* XXX */
+	cqinfo->lro.frag_align_pad = 0;
+	cqinfo->lro.lro_arr = vmalloc(BNAD_LRO_MAX_DESC *
+	    sizeof(struct net_lro_desc));
+	if (!cqinfo->lro.lro_arr) {
+		bnad_free_q(bnad, &cqinfo->cq_config.qpt, &cqinfo->cq.q);
+		return err;
+	}
+	memset(cqinfo->lro.lro_arr, 0, BNAD_LRO_MAX_DESC *
+	    sizeof(struct net_lro_desc));
+	cqinfo->lro.get_skb_header = bnad_lro_get_skb_header;
+
+	cqinfo->rx_coalescing_timeo = bnad->rx_coalescing_timeo;
+
+	cqinfo->cq_id = cq_id;
+	snprintf(cqinfo->name, sizeof(cqinfo->name), "%s CQ %d",
+	    bnad->netdev->name, cq_id);
+
+	return 0;
+}
+
+static int bnad_cqs_init(struct bnad *bnad)
+{
+	int i, err = 0;
+
+	bnad->cq_table = kzalloc(bnad->cq_num * sizeof(struct bnad_cq_info),
+	    GFP_KERNEL);
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
+	if (mtu > ETH_DATA_LEN) {
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
+	if (!(bnad->flags & BNAD_F_TXQ_DEPTH))
+		bnad->txq_depth = bnad_get_qsize(bnad_txq_depth,
+		    bnad->netdev->mtu);
+	if (!(bnad->flags & BNAD_F_RXQ_DEPTH))
+		bnad->rxq_depth = bnad_get_qsize(bnad_rxq_depth,
+		    bnad->netdev->mtu);
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
+	cqinfo->hw_producer_index = (u32 *)(ib_entry->ib_seg_addr);
+	cqinfo->cq_config.ib_id = ib_id;
+	cqinfo->cq_config.ib_seg_index = 0;
+
+	ib_entry->ib = &cqinfo->ib;
+	ib_config = &ib_entry->ib_config;
+	ib_config->coalescing_timer = bnad->rx_coalescing_timeo;
+#if 1
+	ib_config->control_flags = BNA_IB_CF_INT_ENABLE |
+	    BNA_IB_CF_MASTER_ENABLE;
+#else
+	ib_config->control_flags = BNA_IB_CF_INT_ENABLE |
+	    BNA_IB_CF_INTER_PKT_ENABLE | BNA_IB_CF_MASTER_ENABLE;
+	ib_config->interpkt_count = bnad->rx_interpkt_count;
+	ib_config->interpkt_timer = bnad->rx_interpkt_timeo;
+#endif
+	if (bnad->flags & BNAD_F_MSIX) {
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
+		ib_config->control_flags = BNA_IB_CF_INTER_PKT_DMA |
+		    BNA_IB_CF_INT_ENABLE | BNA_IB_CF_COALESCING_MODE |
+		    BNA_IB_CF_MASTER_ENABLE;
+		if (bnad->flags & BNAD_F_MSIX) {
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
+	txf_info->txf_config.flags = BNA_TXF_CF_VLAN_WI_BASED |
+	    BNA_TXF_CF_ENABLE;
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
+		rxf_rss->type = BNA_RSS_V4_TCP | BNA_RSS_V4_IP |
+		    BNA_RSS_V6_TCP | BNA_RSS_V6_IP;
+		rxf_rss->hash_mask = bnad->cq_num - 1;
+		get_random_bytes(rxf_rss->toeplitz_hash_key,
+		    sizeof(rxf_rss->toeplitz_hash_key));
+	}
+	DPRINTK(DEBUG, "%s RxF %u config flags 0x%x\n",
+		bnad->netdev->name, rxf_id, rxf_info->rxf_config.flags);
+}
+
+static int bnad_init_funcs(struct bnad *bnad)
+{
+	bnad->txf_table = kzalloc(sizeof(struct bnad_txf_info) * bnad->txf_num,
+				  GFP_KERNEL);
+	if (!bnad->txf_table)
+		return -ENOMEM;
+	bnad_txf_init(bnad, BNAD_TX_FUNC_ID);
+
+	bnad->rxf_table = kzalloc(sizeof(struct bnad_rxf_info) * bnad->rxf_num,
+				  GFP_KERNEL);
+	if (!bnad->rxf_table)
+		return -ENOMEM;
+	bnad_rxf_init(bnad, BNAD_RX_FUNC_ID, BNAD_RIT_OFFSET,
+	    (bnad->cq_num > 1) ? 1 : 0);
+	return 0;
+}
+
+static void bnad_setup_txq(struct bnad *bnad, uint txq_id)
+{
+	struct bnad_txq_info *txqinfo;
+
+	BNA_ASSERT(txq_id < bnad->txq_num);
+	txqinfo = &bnad->txq_table[txq_id];
+	txqinfo->txq_config.priority = txq_id;
+	/*  Set wrr_quota properly if multiple priorities/TxQs are enabled. */
+	txqinfo->txq_config.wrr_quota = BNAD_TX_MAX_WRR_QUOTA;
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_txq_config(bnad->priv, &txqinfo->txq, txq_id,
+	    &txqinfo->txq_config);
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+void bnad_setup_rxq(struct bnad *bnad, uint rxq_id)
+{
+	struct bnad_rxq_info *rxqinfo;
+
+	BNA_ASSERT(rxq_id < bnad->rxq_num);
+	rxqinfo = &bnad->rxq_table[rxq_id];
+	/*
+	 * Every RxQ set has 2 RxQs: the first is large buffer RxQ,
+	 * the second is small buffer RxQ.
+	 */
+	if ((rxq_id % bnad_rxqs_per_cq) == 0)
+		rxqinfo->rxq_config.buffer_size =
+		    (bnad_vlan_strip ? VLAN_ETH_HLEN : ETH_HLEN) +
+		    bnad->netdev->mtu + ETH_FCS_LEN;
+	else
+		rxqinfo->rxq_config.buffer_size = BNAD_SMALL_RXBUF_SIZE;
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_rxq_config(bnad->priv, &rxqinfo->rxq, rxq_id,
+	    &rxqinfo->rxq_config);
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
+	bna_cq_config(bnad->priv, &cqinfo->cq, cq_id,
+	    &cqinfo->cq_config);
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
+
+static void bnad_setup_rit(struct bnad *bnad)
+{
+	int i, size;
+
+	size = bnad->cq_num;
+
+	for (i = 0; i < size; i++) {
+		if (bnad_small_large_rxbufs) {
+			bnad->rit[i].large_rxq_id = (i << 1);
+			bnad->rit[i].small_rxq_id = (i << 1) + 1;
+		} else
+			bnad->rit[i].large_rxq_id = i;
+	}
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_rit_config_set(bnad->priv, BNAD_RIT_OFFSET,
+	    bnad->rit, size);
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
+	    rxqinfo->skb_unmap_q.q_depth);
+	DPRINTK(INFO, "%s allocated %u rx buffers for RxQ %u\n",
+		bnad->netdev->name, rxbufs, rxq_id);
+}
+
+static int bnad_config_hw(struct bnad *bnad)
+{
+	int i, err;
+	u64 rxq_id_mask = 0;
+	struct sockaddr sa;
+	struct net_device *netdev = bnad->netdev;
+
+	spin_lock_irq(&bnad->priv_lock);
+	/* Disable the RxF until later bringing port up. */
+	bna_multi_rxf_disable(bnad->priv, (1 << bnad->rxf_num) - 1);
+	spin_unlock_irq(&bnad->priv_lock);
+	for (i = 0; i < bnad->txq_num; i++) {
+		err = bnad_disable_txq(bnad, i);
+		if (err)
+			return err;
+	}
+	for (i = 0; i < bnad->rxq_num; i++)
+		rxq_id_mask |= (1 << i);
+	if (rxq_id_mask) {
+		err = bnad_disable_rxqs(bnad, rxq_id_mask);
+		if (err)
+			return err;
+	}
+
+	bnad_setup_queues(bnad);
+
+	bnad_setup_rit(bnad);
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_txf_config_set(bnad->priv, BNAD_TX_FUNC_ID,
+	    &bnad->txf_table->txf_config);
+	for (i = 0; i < bnad->rxf_num; i++) {
+		bna_rxf_config_set(bnad->priv, i,
+		    &bnad->rxf_table[i].rxf_config);
+		bna_rxf_vlan_filter(bnad->priv, i, BNA_ENABLE);
+	}
+	spin_unlock_irq(&bnad->priv_lock);
+
+	/* Mailbox should be enabled before this! */
+	memcpy(sa.sa_data, netdev->dev_addr, netdev->addr_len);
+	bnad_set_mac_address_locked(netdev, &sa);
+
+	spin_lock_irq(&bnad->priv_lock);
+	/* Receive broadcasts */
+	bna_rxf_broadcast(bnad->priv, BNAD_RX_FUNC_ID, BNA_ENABLE);
+
+	bna_mtu_info(bnad->priv, netdev->mtu, bnad);
+	bna_set_pause_config(bnad->priv, &bnad->pause_config, bnad);
+
+	bna_rxf_mcast_del_all(bnad->priv, BNAD_RX_FUNC_ID);
+	bna_mcast_mac_reset_list(bnad->priv);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	bnad_set_rx_mode_locked(bnad->netdev);
+
+	bnad_reconfig_vlans(bnad);
+
+	bnad_setup_ibs(bnad);
+
+	return 0;
+}
+
+/* Note: bnad_cleanup doesn't not free irqs and queues. */
+static void bnad_cleanup(struct bnad *bnad)
+{
+	kfree(bnad->rit);
+	bnad->rit = NULL;
+	kfree(bnad->txf_table);
+	bnad->txf_table = NULL;
+	kfree(bnad->rxf_table);
+	bnad->rxf_table = NULL;
+
+	bnad_free_ibs(bnad);
+	bnad_free_queues(bnad);
+}
+
+/* Should be called with rtnl_lock held. */
+static int bnad_start(struct bnad *bnad)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	err = bnad_alloc_ibs(bnad);
+	if (err)
+		return err;
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
+	bnad->rit = kzalloc(bnad->cq_num * sizeof(struct bna_rit_entry),
+	    GFP_KERNEL);
+
+	if (!bnad->rit)
+		goto finished;
+
+	err = bnad_config_hw(bnad);
+	if (err)
+		goto finished;
+
+		bnad_napi_init(bnad);
+		bnad_napi_enable(bnad);
+
+	err = bnad_request_txrx_irqs(bnad);
+	if (err) {
+		DPRINTK(ERR, "%s requests Tx/Rx irqs failed: %d\n",
+			bnad->netdev->name, err);
+		goto finished;
+	}
+	return 0;
+
+finished:
+	bnad_cleanup(bnad);
+	return err;
+}
+
+int bnad_open_locked(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	uint i;
+	int err;
+
+	ASSERT_RTNL();
+	DPRINTK(WARNING, "%s open\n", netdev->name);
+
+	if (BNAD_NOT_READY(bnad)) {
+		DPRINTK(WARNING, "%s is not ready yet (0x%lx)\n",
+			netdev->name, bnad->state);
+		return 0;
+	}
+
+	if (!test_bit(BNAD_DISABLED, &bnad->state)) {
+		DPRINTK(WARNING, "%s is already opened (0x%lx)\n",
+			netdev->name, bnad->state);
+
+		return 0;
+	}
+
+	err = bnad_start(bnad);
+	if (err) {
+		DPRINTK(ERR, "%s failed to start %d\n", netdev->name, err);
+		return err;
+	}
+	for (i = 0; i < bnad->rxq_num; i++)
+		bnad_alloc_for_rxq(bnad, i);
+
+	smp_mb__before_clear_bit();
+	clear_bit(BNAD_DISABLED, &bnad->state);
+	DPRINTK(INFO, "%s is opened\n", bnad->netdev->name);
+
+	/* XXX Packet may be come before we bring the port up. */
+	spin_lock_irq(&bnad->priv_lock);
+
+	/* RxF was disabled earlier. */
+	bna_rxf_enable(bnad->priv, BNAD_RX_FUNC_ID);
+	spin_unlock_irq(&bnad->priv_lock);
+
+
+	DPRINTK(INFO, "Bring %s link up\n", netdev->name);
+		spin_lock_irq(&bnad->priv_lock);
+		bna_port_admin(bnad->priv, BNA_ENABLE);
+		spin_unlock_irq(&bnad->priv_lock);
+
+	mod_timer(&bnad->stats_timer, jiffies + HZ);
+
+	return 0;
+}
+
+int bnad_stop_locked(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	ASSERT_RTNL();
+	DPRINTK(WARNING, "%s stop\n", netdev->name);
+
+	if (test_and_set_bit(BNAD_DISABLED, &bnad->state)) {
+		if (BNAD_NOT_READY(bnad))
+			DPRINTK(WARNING, "%s is not ready (0x%lx)\n",
+				netdev->name, bnad->state);
+		else
+			DPRINTK(WARNING, "%s is already stopped (0x%lx)\n",
+				netdev->name, bnad->state);
+		return 0;
+	}
+
+	bnad_disable(bnad);
+	bnad_cleanup(bnad);
+	DPRINTK(INFO, "%s is stopped\n", bnad->netdev->name);
+	return 0;
+}
+
+int bnad_open(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int error = 0;
+
+	bnad_lock();
+	if (!test_bit(BNAD_PORT_DISABLED, &bnad->state))
+		error = bnad_open_locked(netdev);
+	bnad_unlock();
+	return error;
+}
+
+int bnad_stop(struct net_device *netdev)
+{
+	int error = 0;
+
+	bnad_lock();
+	error = bnad_stop_locked(netdev);
+	bnad_unlock();
+	return error;
+}
+
+static int bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
+{
+#ifdef NETIF_F_TSO
+	int err;
+
+#ifdef SKB_GSO_TCPV4
+	/* SKB_GSO_TCPV4 and SKB_GSO_TCPV6 is defined since 2.6.18. */
+	BNA_ASSERT(skb_shinfo(skb)->gso_type == SKB_GSO_TCPV4 ||
+	    skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6);
+#endif
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
+		tcp_hdr(skb)->check = ~csum_tcpudp_magic(
+		    iph->saddr, iph->daddr, 0, IPPROTO_TCP, 0);
+		bnad->stats.tso4++;
+#ifdef NETIF_F_TSO6
+	} else {
+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+
+		BNA_ASSERT(skb->protocol == htons(ETH_P_IPV6));
+		ipv6h->payload_len = 0;
+		tcp_hdr(skb)->check = ~csum_ipv6_magic(
+		    &ipv6h->saddr, &ipv6h->daddr, 0, IPPROTO_TCP, 0);
+		bnad->stats.tso6++;
+#endif
+	}
+
+	return 0;
+#else
+	return -EINVAL;
+#endif
+}
+
+int bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct bnad_txq_info *txqinfo;
+	struct bna_txq *txq;
+	struct bnad_unmap_q *unmap_q;
+	u16 txq_prod;
+	unsigned int unmap_prod, wis, wis_used, wi_range;
+	unsigned int vectors, vect_id, i, acked;
+	int err;
+	dma_addr_t dma_addr;
+	struct bna_txq_entry *txqent;
+	bna_txq_wi_ctrl_flag_t flags;
+
+	if (unlikely(skb->len <= ETH_HLEN ||
+	    skb->len > BNAD_TX_MAX_DATA_PER_WI)) {
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
+	if (unlikely(wis > BNA_Q_FREE_COUNT(txq) ||
+	    vectors > BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth))) {
+		if ((u16)(*txqinfo->hw_consumer_index) !=
+		    txq->q.consumer_index &&
+		    !test_and_set_bit(BNAD_TXQ_FREE_SENT, &txqinfo->flags)) {
+			acked = bnad_free_txbufs(txqinfo,
+			    (u16)(*txqinfo->hw_consumer_index));
+			bna_ib_ack(bnad->priv, &txqinfo->ib, acked);
+			DPRINTK(DEBUG, "%s ack TxQ IB %u packets\n",
+				netdev->name, acked);
+			smp_mb__before_clear_bit();
+			clear_bit(BNAD_TXQ_FREE_SENT, &txqinfo->flags);
+		} else {
+				netif_stop_queue(netdev);
+		}
+
+		smp_mb();
+		/*
+		 * Check again to deal with race condition between
+		 * netif_stop_queue here, and netif_wake_queue in
+		 * interrupt handler which is not inside netif tx lock.
+		 */
+		if (likely(wis > BNA_Q_FREE_COUNT(txq) ||
+		    vectors > BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth))) {
+			bnad->stats.netif_queue_stop++;
+			return NETDEV_TX_BUSY;
+		} else {
+				netif_wake_queue(netdev);
+		}
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
+	txqent->hdr.wi.opcode = htons((skb_is_gso(skb) ?
+	    BNA_TXQ_WI_SEND_LSO : BNA_TXQ_WI_SEND));
+
+	if (bnad_ipid_mode)
+		flags |= BNA_TXQ_WI_CF_IPID_MODE;
+
+	if (bnad->vlangrp && vlan_tx_tag_present(skb)) {
+		u16 vlan_tag = (u16)vlan_tx_tag_get(skb);
+		if ((vlan_tag >> 13) & 0x7)
+			flags |= BNA_TXQ_WI_CF_INS_PRIO;
+		if (vlan_tag & VLAN_VID_MASK)
+			flags |= BNA_TXQ_WI_CF_INS_VLAN;
+		txqent->hdr.wi.vlan_tag = htons(vlan_tag);
+	} else
+		txqent->hdr.wi.vlan_tag = 0;
+
+	if (skb_is_gso(skb)) {
+		err = bnad_tso_prepare(bnad, skb);
+		if (err) {
+			dev_kfree_skb(skb);
+			return NETDEV_TX_OK;
+		}
+		txqent->hdr.wi.lso_mss = htons(skb_is_gso(skb));
+		flags |= (BNA_TXQ_WI_CF_IP_CKSUM | BNA_TXQ_WI_CF_TCP_CKSUM);
+		txqent->hdr.wi.l4_hdr_size_n_offset = htons(
+		    BNA_TXQ_WI_L4_HDR_N_OFFSET(tcp_hdrlen(skb) >> 2,
+		    skb_transport_offset(skb)));
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		u8 proto = 0;
+
+		txqent->hdr.wi.lso_mss = 0;
+
+		if (skb->protocol == htons(ETH_P_IP))
+			proto = ip_hdr(skb)->protocol;
+#ifdef NETIF_F_IPV6_CSUM
+		else if (skb->protocol == htons(ETH_P_IPV6)) {
+			/* XXX the nexthdr may not be TCP immediately. */
+			proto = ipv6_hdr(skb)->nexthdr;
+		}
+#endif
+		if (proto == IPPROTO_TCP) {
+			flags |= BNA_TXQ_WI_CF_TCP_CKSUM;
+			txqent->hdr.wi.l4_hdr_size_n_offset = htons(
+			    BNA_TXQ_WI_L4_HDR_N_OFFSET(0,
+			    skb_transport_offset(skb)));
+			bnad->stats.tcpcsum_offload++;
+			BNA_ASSERT(skb_headlen(skb) >=
+			    skb_transport_offset(skb) + tcp_hdrlen(skb));
+		} else if (proto == IPPROTO_UDP) {
+			flags |= BNA_TXQ_WI_CF_UDP_CKSUM;
+			txqent->hdr.wi.l4_hdr_size_n_offset = htons(
+			    BNA_TXQ_WI_L4_HDR_N_OFFSET(0,
+			    skb_transport_offset(skb)));
+			bnad->stats.udpcsum_offload++;
+			BNA_ASSERT(skb_headlen(skb) >=
+			    skb_transport_offset(skb) + sizeof(struct udphdr));
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
+	dma_addr = pci_map_single(bnad->pcidev, skb->data, skb_headlen(skb),
+	    PCI_DMA_TODEVICE);
+	pci_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
+	    dma_addr);
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
+				    txq->q.q_depth);
+				wis_used = 0;
+				BNA_TXQ_QPGE_PTR_GET(txq_prod, &txq->q, txqent,
+				    wi_range);
+				BNA_ASSERT(wi_range &&
+				    wi_range <= txq->q.q_depth);
+			}
+			wis_used++;
+			txqent->hdr.wi_ext.opcode = htons(BNA_TXQ_WI_EXTENSION);
+		}
+
+		BNA_ASSERT(frag->size <= BNAD_TX_MAX_DATA_PER_VECTOR);
+		txqent->vector[vect_id].length = htons(frag->size);
+		BNA_ASSERT(unmap_q->unmap_array[unmap_prod].skb == NULL);
+		dma_addr = pci_map_page(bnad->pcidev, frag->page,
+		    frag->page_offset, frag->size, PCI_DMA_TODEVICE);
+		pci_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
+		    dma_addr);
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
+	netdev->trans_start = jiffies;
+
+	if ((u16)(*txqinfo->hw_consumer_index) !=
+	    txq->q.consumer_index &&
+	    !test_and_set_bit(BNAD_TXQ_FREE_SENT, &txqinfo->flags)) {
+		acked = bnad_free_txbufs(txqinfo,
+		    (u16)(*txqinfo->hw_consumer_index));
+		bna_ib_ack(bnad->priv, &txqinfo->ib, acked);
+		smp_mb__before_clear_bit();
+		clear_bit(BNAD_TXQ_FREE_SENT, &txqinfo->flags);
+	}
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
+	net_stats->rx_errors = rxstats->rx_fcs_error +
+	    rxstats->rx_alignment_error + rxstats->rx_frame_length_error +
+	    rxstats->rx_code_error + rxstats->rx_undersize;
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
+	net_stats->rx_fifo_errors =
+	    bnad->hw_stats->rxf_stats[0].frame_drops;
+
+	return net_stats;
+}
+
+void bnad_reset_stats(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct bnad_rxq_info *rxqinfo;
+	struct bnad_txq_info *txqinfo;
+	int i;
+	memset(&bnad->stats, 0, sizeof(bnad->stats));
+
+	if (bnad->rxq_table) {
+		for (i = 0; i < bnad->rxq_num; i++) {
+			rxqinfo = &bnad->rxq_table[i];
+			rxqinfo->rx_packets = 0;
+			rxqinfo->rx_bytes = 0;
+			rxqinfo->rx_packets_with_error = 0;
+			rxqinfo->rxbuf_alloc_failed = 0;
+		}
+	}
+	if (bnad->txq_table) {
+		for (i = 0; i < bnad->txq_num; i++) {
+			txqinfo = &bnad->txq_table[i];
+			txqinfo->tx_packets = 0;
+			txqinfo->tx_bytes = 0;
+		}
+	}
+}
+
+static void bnad_set_rx_mode_locked(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err;
+	unsigned long irq_flags;
+
+	if (BNAD_NOT_READY(bnad))
+		return;
+
+	spin_lock_irqsave(&bnad->priv_lock, irq_flags);
+	if (netdev->flags & IFF_PROMISC) {
+		if (!(bnad->flags & BNAD_F_PROMISC)) {
+			bna_rxf_promiscuous(bnad->priv,
+			    BNAD_RX_FUNC_ID, BNA_ENABLE);
+			bnad->flags |= BNAD_F_PROMISC;
+		}
+	} else {
+		if (bnad->flags & BNAD_F_PROMISC) {
+			bna_rxf_promiscuous(bnad->priv,
+			    BNAD_RX_FUNC_ID, BNA_DISABLE);
+			bnad->flags &= ~BNAD_F_PROMISC;
+		}
+	}
+
+	if (netdev->flags & IFF_ALLMULTI) {
+		if (!(bnad->flags & BNAD_F_ALLMULTI)) {
+			bna_rxf_mcast_filter(bnad->priv,
+			    BNAD_RX_FUNC_ID, BNA_DISABLE);
+			bnad->flags |= BNAD_F_ALLMULTI;
+		}
+	} else {
+		if (bnad->flags & BNAD_F_ALLMULTI) {
+			bna_rxf_mcast_filter(bnad->priv,
+			    BNAD_RX_FUNC_ID, BNA_ENABLE);
+			bnad->flags &= ~BNAD_F_ALLMULTI;
+		}
+	}
+	spin_unlock_irqrestore(&bnad->priv_lock, irq_flags);
+
+	if (netdev->mc_count) {
+		u8 *mcaddr_list;
+		u8 bcast_addr[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+		struct dev_mc_list *mc;
+		int i;
+
+		mcaddr_list = kzalloc((netdev->mc_count + 1) *
+		    (ETH_ALEN * sizeof(u8)), GFP_ATOMIC);
+		if (!mcaddr_list)
+			return;
+		memcpy(&mcaddr_list[0], bcast_addr, ETH_ALEN * sizeof(u8));
+
+		mc = netdev->mc_list;
+		for (i = 1; mc && i < netdev->mc_count + 1; i++, mc = mc->next)
+			memcpy(&mcaddr_list[i], mc->dmi_addr,
+				ETH_ALEN * sizeof(u8));
+
+		spin_lock_irqsave(&bnad->priv_lock, irq_flags);
+		err = bna_rxf_mcast_mac_set_list(bnad->priv, BNAD_RX_FUNC_ID,
+		    (const u8 *)mcaddr_list, netdev->mc_count + 1);
+		spin_unlock_irqrestore(&bnad->priv_lock, irq_flags);
+
+		kfree(mcaddr_list);
+	}
+}
+
+static void bnad_set_rx_mode(struct net_device *netdev)
+{
+	bnad_lock();
+	bnad_set_rx_mode_locked(netdev);
+	bnad_unlock();
+}
+
+int bnad_ucast_mac(struct bnad *bnad, unsigned int rxf_id,
+    u8 *mac_ptr, unsigned int cmd)
+{
+	int err = 0;
+	enum bna_status_e (*ucast_mac_func)(struct bna_dev_s *bna_dev,
+		unsigned int rxf_id, const u8 *mac_addr_ptr) = NULL;
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
+	while (test_and_set_bit(BNAD_SET_UCAST, &bnad->state))
+		msleep(1);
+	init_completion(&bnad->ucast_comp);
+	spin_lock_irq(&bnad->priv_lock);
+	err = ucast_mac_func(bnad->priv, rxf_id, (const u8 *)mac_ptr);
+	spin_unlock_irq(&bnad->priv_lock);
+	if (err)
+		goto ucast_mac_exit;
+
+	DPRINTK(INFO, "Waiting for %s MAC operation %d reply\n",
+		bnad->netdev->name, cmd);
+	wait_for_completion(&bnad->ucast_comp);
+	err = bnad->ucast_comp_status;
+ucast_mac_exit:
+	smp_mb__before_clear_bit();
+	clear_bit(BNAD_SET_UCAST, &bnad->state);
+	if (err) {
+		printk(KERN_INFO
+		    "%s unicast MAC address command %d failed: %d\n",
+		    bnad->netdev->name, cmd, err);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int bnad_set_mac_address_locked(struct net_device *netdev, void *addr)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct sockaddr *sa = (struct sockaddr *)addr;
+	int err;
+
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (!BNAD_NOT_READY(bnad)) {
+		err = bnad_ucast_mac(bnad, BNAD_RX_FUNC_ID, (u8 *)sa->sa_data,
+		    BNAD_UCAST_MAC_SET);
+		if (err)
+			return err;
+	}
+
+	memcpy(netdev->dev_addr, sa->sa_data, netdev->addr_len);
+	return 0;
+}
+
+static int bnad_set_mac_address(struct net_device *netdev, void *addr)
+{
+	int err = 0;
+
+	bnad_lock();
+	err = bnad_set_mac_address_locked(netdev, addr);
+	bnad_unlock();
+	return err;
+
+}
+
+static int bnad_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	int err = 0;
+
+	WARN_ON(in_interrupt());
+
+	if (new_mtu + ETH_HLEN < ETH_ZLEN || new_mtu > BNAD_JUMBO_MTU)
+		return -EINVAL;
+
+	bnad_lock();
+
+	netdev->mtu = new_mtu;
+
+	err = bnad_sw_reset(netdev);
+
+	bnad_unlock();
+
+	return err;
+}
+
+static int bnad_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	return -EOPNOTSUPP;
+}
+
+static void
+bnad_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_lock();
+	bnad->vlangrp = grp;
+	bnad_unlock();
+}
+
+static void bnad_vlan_rx_add_vid(struct net_device *netdev, unsigned short vid)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	unsigned long irq_flags;
+
+	DPRINTK(INFO, "%s add vlan %u\n", netdev->name, vid);
+	bnad_lock();
+	if (BNAD_NOT_READY(bnad)) {
+		bnad_unlock();
+		return;
+	}
+	spin_lock_irqsave(&bnad->priv_lock, irq_flags);
+	bna_rxf_vlan_add(bnad->priv, BNAD_RX_FUNC_ID, (unsigned int)vid);
+	spin_unlock_irqrestore(&bnad->priv_lock, irq_flags);
+	bnad_unlock();
+}
+
+static void
+bnad_vlan_rx_kill_vid(struct net_device *netdev, unsigned short vid)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	unsigned long irq_flags;
+
+	DPRINTK(INFO, "%s remove vlan %u\n", netdev->name, vid);
+	bnad_lock();
+	if (BNAD_NOT_READY(bnad)) {
+		bnad_unlock();
+		return;
+	}
+	spin_lock_irqsave(&bnad->priv_lock, irq_flags);
+	bna_rxf_vlan_del(bnad->priv, BNAD_RX_FUNC_ID, (unsigned int)vid);
+	spin_unlock_irqrestore(&bnad->priv_lock, irq_flags);
+	bnad_unlock();
+}
+
+static void bnad_reconfig_vlans(struct bnad *bnad)
+{
+	u16 vlan_id;
+
+	spin_lock_irq(&bnad->priv_lock);
+	bna_rxf_vlan_del_all(bnad->priv, BNAD_RX_FUNC_ID);
+	if (bnad->vlangrp) {
+		for (vlan_id = 0; vlan_id < VLAN_GROUP_ARRAY_LEN; vlan_id++) {
+			if (vlan_group_get_device(bnad->vlangrp, vlan_id))
+				bna_rxf_vlan_add(bnad->priv, BNAD_RX_FUNC_ID,
+				    (unsigned int)vlan_id);
+		}
+	}
+	spin_unlock_irq(&bnad->priv_lock);
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void bnad_netpoll(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	DPRINTK(INFO, "%s bnad_netpoll\n", netdev->name);
+	disable_irq(bnad->pcidev->irq);
+	bnad_isr(bnad->pcidev->irq, netdev);
+	enable_irq(bnad->pcidev->irq);
+}
+#endif
+
+static void bnad_q_num_init(struct bnad *bnad, uint rxqsets)
+{
+	bnad->txq_num = BNAD_TXQ_NUM;
+	bnad->txf_num = 1;
+
+	if (bnad->flags & BNAD_F_MSIX) {
+		if (rxqsets) {
+			bnad->cq_num = rxqsets;
+			if (bnad->cq_num > BNAD_MAX_CQS)
+				bnad->cq_num = BNAD_MAX_CQS;
+		} else
+			bnad->cq_num = min((uint)num_online_cpus(),
+			    (uint)BNAD_MAX_RXQSETS_USED);
+		if (!BNA_POWER_OF_2(bnad->cq_num))
+			BNA_TO_POWER_OF_2(bnad->cq_num);
+		bnad->rxq_num = bnad->cq_num * bnad_rxqs_per_cq;
+
+		bnad->rxf_num = 1;
+		bnad->msix_num = bnad->txq_num + bnad->cq_num +
+		    BNAD_MSIX_ERR_MAILBOX_NUM;
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
+	if (!(bnad->flags & BNAD_F_MSIX) || bnad->msix_table)
+		return;
+
+	bnad->msix_table = kzalloc(
+	    bnad->msix_num * sizeof(struct msix_entry), GFP_KERNEL);
+	if (!bnad->msix_table)
+		goto intx_mode;
+
+	for (i = 0; i < bnad->msix_num; i++)
+		bnad->msix_table[i].entry = i;
+
+	ret = pci_enable_msix(bnad->pcidev, bnad->msix_table,
+	    bnad->msix_num);
+	if (ret > 0) {
+		/* Not enough MSI-X vectors. */
+		int rxqsets = ret;
+
+		dev_err(&bnad->pcidev->dev,
+		    "Tried to get %d MSI-X vectors, only got %d\n",
+		    bnad->msix_num, ret);
+		BNA_TO_POWER_OF_2(rxqsets);
+		while (bnad->msix_num > ret && rxqsets) {
+			bnad_q_num_init(bnad, rxqsets);
+			rxqsets >>= 1;
+		}
+		if (bnad->msix_num <= ret) {
+			ret = pci_enable_msix(bnad->pcidev, bnad->msix_table,
+			    bnad->msix_num);
+			if (ret) {
+				dev_err(&bnad->pcidev->dev,
+				    "Enabling MSI-X failed: %d\n", ret);
+				goto intx_mode;
+			}
+		} else {
+			dev_err(&bnad->pcidev->dev,
+			    "Enabling MSI-X failed: limited (%d) vectors\n",
+			    ret);
+			goto intx_mode;
+		}
+	} else if (ret < 0) {
+		dev_err(&bnad->pcidev->dev, "Enabling MSI-X failed: %d\n", ret);
+		goto intx_mode;
+	}
+
+	dev_info(&bnad->pcidev->dev,
+	    "Enabling MSI-X succeeded with %d vectors, %s\n", bnad->msix_num,
+	    (bnad->cq_num > 1) ? "RSS is enabled" : "RSS is not enabled");
+	return;
+
+intx_mode:
+	dev_warn(&bnad->pcidev->dev, "Switching to INTx mode with no RSS\n");
+	kfree(bnad->msix_table);
+	bnad->msix_table = NULL;
+	bnad->flags &= ~BNAD_F_MSIX;
+	bnad_q_num_init(bnad, 0);
+}
+
+static void bnad_disable_msix(struct bnad *bnad)
+{
+	if ((bnad->flags & BNAD_F_MSIX) && bnad->msix_table) {
+		pci_disable_msix(bnad->pcidev);
+		kfree(bnad->msix_table);
+		bnad->msix_table = NULL;
+		bnad->flags &= ~BNAD_F_MSIX;
+	}
+}
+
+static void bnad_error(struct bnad *bnad)
+{
+	DPRINTK(INFO, "%s bnad_error\n", bnad->netdev->name);
+
+	rtnl_lock();
+	set_bit(BNAD_RESETTING, &bnad->state);
+	if (!test_and_set_bit(BNAD_DISABLED, &bnad->state)) {
+		bnad_detach(bnad);
+		bnad_cleanup(bnad);
+		DPRINTK(WARNING, "%s is disabled upon error\n",
+			bnad->netdev->name);
+	}
+	rtnl_unlock();
+}
+
+static void bnad_resume_after_reset(struct bnad *bnad)
+{
+	int err;
+	struct net_device *netdev = bnad->netdev;
+
+	DPRINTK(WARNING, "port %d resumes after reset\n", bnad->bna_id);
+
+	rtnl_lock();
+	clear_bit(BNAD_RESETTING, &bnad->state);
+
+	bna_port_mac_get(bnad->priv, (u8 *)bnad->perm_addr);
+	BNA_ASSERT(netdev->addr_len == sizeof(bnad->perm_addr));
+#ifdef ETHTOOL_GPERMADDR
+	memcpy(netdev->perm_addr, bnad->perm_addr, netdev->addr_len);
+#endif
+	if (is_zero_ether_addr(netdev->dev_addr))
+		memcpy(netdev->dev_addr, bnad->perm_addr, netdev->addr_len);
+
+	if (netif_running(bnad->netdev)) {
+		err = bnad_open_locked(bnad->netdev);
+		if (err)
+			DPRINTK(ERR, "%s bnad_open failed after reset: %d\n",
+				bnad->netdev->name, err);
+	}
+	rtnl_unlock();
+}
+
+static void bnad_work(struct work_struct *work)
+{
+	struct bnad *bnad = container_of(work, struct bnad, work);
+	unsigned long work_flags;
+
+	DPRINTK(INFO, "port %u bnad_work flags 0x%x\n",
+		bnad->bna_id, bnad->work_flags);
+
+	spin_lock_irq(&bnad->priv_lock);
+	work_flags = bnad->work_flags;
+	bnad->work_flags = 0;
+	spin_unlock_irq(&bnad->priv_lock);
+
+	if (work_flags & BNAD_WF_ERROR) {
+		DPRINTK(INFO, "port %u bnad_work: BNAD_WF_ERROR\n",
+			bnad->bna_id);
+		bnad_error(bnad);
+	}
+
+	if (work_flags & BNAD_WF_RESETDONE) {
+		DPRINTK(INFO, "port %u bnad_work: BNAD_WF_RESETDONE\n",
+			bnad->bna_id);
+		bnad_resume_after_reset(bnad);
+	}
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
+			if ((cq->pkt_rate.small_pkt_cnt == 0)
+			    && (cq->pkt_rate.large_pkt_cnt == 0))
+				continue;
+
+				cls_timer = bna_calc_coalescing_timer(
+				bnad->priv, &cq->pkt_rate);
+
+			/*For NAPI version, coalescing timer need to stored*/
+			cq->rx_coalescing_timeo = cls_timer;
+
+			bna_ib_coalescing_timer_set(bnad->priv, &cq->ib,
+			    cls_timer);
+		}
+	}
+
+	for (i = 0; i < bnad->rxq_num; i++) {
+		rxqinfo = &bnad->rxq_table[i];
+		if (!(BNA_QE_IN_USE_CNT(&rxqinfo->skb_unmap_q,
+		    rxqinfo->skb_unmap_q.q_depth) >>
+		     BNAD_RXQ_REFILL_THRESHOLD_SHIFT)) {
+			DPRINTK(INFO, "%s: RxQ %d more buffers to allocate\n",
+				bnad->netdev->name, i);
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
+			    bnad->ioc_meminfo[i].len, bnad->ioc_meminfo[i].kva,
+			    *(dma_addr_t *)&bnad->ioc_meminfo[i].dma);
+		else if (bnad->ioc_meminfo[i].kva)
+			vfree(bnad->ioc_meminfo[i].kva);
+		bnad->ioc_meminfo[i].kva = NULL;
+	}
+}
+
+/* The following IOC callback functions are called with priv_lock held. */
+
+void bna_iocll_enable_cbfn(void *arg, enum bfa_status status)
+{
+	struct bnad *bnad = arg;
+
+	DPRINTK(WARNING, "port %u IOC enable callback, status %d\n",
+		bnad->bna_id, status);
+
+	bnad->ioc_comp_status = status;
+	complete(&bnad->ioc_comp);
+
+	if (!status) {
+		bnad->work_flags |= BNAD_WF_RESETDONE;
+		if (!test_bit(BNAD_REMOVED, &bnad->state))
+			schedule_work(&bnad->work);
+	}
+}
+
+void bna_iocll_disable_cbfn(void *arg)
+{
+	struct bnad *bnad = arg;
+
+	DPRINTK(WARNING, "port %u IOC disable callback\n",
+		bnad->bna_id);
+	complete(&bnad->ioc_comp);
+}
+
+void bna_iocll_hbfail_cbfn(void *arg)
+{
+	struct bnad *bnad = arg;
+
+	DPRINTK(ERR, "port %u IOC HBFail callback\n", bnad->bna_id);
+	bnad_hw_error(bnad, BFA_STATUS_IOC_FAILURE);
+}
+
+void bna_iocll_reset_cbfn(void *arg)
+{
+	struct bnad *bnad = arg;
+	u32 int_status, int_mask;
+	unsigned int irq;
+
+	DPRINTK(WARNING, "port %u IOC reset callback\n", bnad->bna_id);
+
+	/* Clear the status */
+	bna_intr_status_get(bnad->priv, &int_status);
+
+	if (bnad->flags & BNAD_F_MSIX) {
+		if (test_and_clear_bit(BNAD_MBOX_IRQ_DISABLED, &bnad->state)) {
+			irq = bnad->msix_table[bnad->txq_num +
+				bnad->cq_num].vector;
+			DPRINTK(WARNING, "Enabling Mbox IRQ %d for port %d\n",
+				irq, bnad->bna_id);
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
+	if (!test_bit(BNAD_REMOVED, &bnad->state))
+		mod_timer(&bnad->ioc_timer,
+		    jiffies + HZ * BNA_IOC_TIMER_FREQ / 1000);
+}
+
+s32
+bnad_cee_attach(struct bnad *bnad)
+{
+	u8 *dma_kva;
+	dma_addr_t dma_pa;
+	struct bfa_cee_s *cee = &bnad->cee;
+
+	memset(cee, 0, sizeof(struct bfa_cee_s));
+
+	/*Allocate memory for dma*/
+	dma_kva = pci_alloc_consistent(bnad->pcidev, bfa_cee_meminfo(),
+			    &dma_pa);
+	if (dma_kva == NULL)
+		return -ENOMEM;
+
+	/*Ugly... need to remove once CAL is fixed.*/
+	((struct bna_dev_s *)bnad->priv)->cee = cee;
+
+	bnad->cee_cbfn.get_attr_cbfn = bnad_cee_get_attr_cb;
+	bnad->cee_cbfn.get_stats_cbfn = bnad_cee_get_stats_cb;
+	bnad->cee_cbfn.reset_stats_cbfn = bnad_cee_reset_stats_cb;
+	bnad->cee_cbfn.reset_stats_cbfn = NULL;
+
+	/*Invoke cee attach function*/
+	bfa_cee_attach(cee, &bnad->priv->ioc, bnad,
+	    bnad->trcmod, bnad->logmod);
+	bfa_cee_mem_claim(cee, dma_kva, dma_pa);
+	return 0;
+}
+
+static void
+bnad_cee_detach(struct bnad *bnad)
+{
+	struct bfa_cee_s *cee = &bnad->cee;
+	if (cee->attr_dma.kva) {
+		pci_free_consistent(bnad->pcidev, bfa_cee_meminfo(),
+		    cee->attr_dma.kva, cee->attr_dma.pa);
+	}
+	bfa_cee_detach(&bnad->cee);
+}
+
+
+static int bnad_priv_init(struct bnad *bnad)
+{
+	dma_addr_t dma_addr;
+	struct bna_dma_addr bna_dma_addr;
+	char inst_name[16];
+	int err, i;
+	struct bfa_pcidev_s pcidev_info;
+	u32 intr_mask;
+
+	DPRINTK(DEBUG, "port %u bnad_priv_init\n", bnad->bna_id);
+
+	if (bnad_msix)
+		bnad->flags |= BNAD_F_MSIX;
+	bnad_q_num_init(bnad, bnad_rxqsets_used);
+
+	bnad->work_flags = 0;
+	INIT_WORK(&bnad->work, bnad_work);
+
+	init_timer(&bnad->stats_timer);
+	bnad->stats_timer.function = &bnad_stats_timeo;
+	bnad->stats_timer.data = (unsigned long)bnad;
+
+	bnad->tx_coalescing_timeo = BNAD_TX_COALESCING_TIMEO;
+	bnad->tx_interpkt_count = BNAD_TX_INTERPKT_COUNT;
+
+	bnad->rx_coalescing_timeo = BNAD_RX_COALESCING_TIMEO;
+	bnad->rx_interpkt_count = BNAD_RX_INTERPKT_COUNT;
+	bnad->rx_interpkt_timeo = BNAD_RX_INTERPKT_TIMEO;
+	bnad->rx_dyn_coalesce_on = BNA_TRUE;
+
+	bnad->rx_csum = 1;
+	bnad->pause_config.tx_pause = 0;
+	bnad->pause_config.rx_pause = 0;
+
+	/* XXX could be vmalloc? */
+	bnad->trcmod = kzalloc(sizeof(struct bfa_trc_mod_s), GFP_KERNEL);
+	if (!bnad->trcmod) {
+		DPRINTK(ERR, "port %u failed allocating trace buffer!\n",
+			bnad->bna_id);
+		return -ENOMEM;
+	}
+	bfa_trc_init(bnad->trcmod);
+
+	bnad->logmod = NULL;
+	sprintf(inst_name, "%u", bnad->bna_id);
+
+	bnad->aen = NULL;
+	INIT_LIST_HEAD(&bnad->file_q);
+	INIT_LIST_HEAD(&bnad->file_free_q);
+	for (i = 0; i < BNAD_AEN_MAX_APPS; i++) {
+		bfa_q_qe_init(&bnad->file_buf[i].qe);
+		list_add_tail(&bnad->file_buf[i].qe, &bnad->file_free_q);
+	}
+
+	bnad->priv = kzalloc(bna_get_handle_size(), GFP_KERNEL);
+	if (!bnad->priv) {
+		DPRINTK(ERR, "port %u failed allocating memory for bna\n",
+			bnad->bna_id);
+		err = -ENOMEM;
+		goto free_trcmod;
+	}
+	bnad->priv_stats = pci_alloc_consistent(bnad->pcidev,
+	    BNA_HW_STATS_SIZE, &dma_addr);
+	if (!bnad->priv_stats) {
+		DPRINTK(ERR, "port %u failed allocating memory for bna stats\n",
+			bnad->bna_id);
+		err = -ENOMEM;
+		goto free_priv_mem;
+	}
+	pci_unmap_addr_set(bnad, priv_stats_dma, dma_addr);
+	DPRINTK(DEBUG, "port %u priv_stats dma addr 0x%llx\n",
+		bnad->bna_id, dma_addr);
+
+	BNA_SET_DMA_ADDR(dma_addr, &bna_dma_addr);
+	bna_init(bnad->priv, (void *)bnad->bar0, bnad->priv_stats,
+	    bna_dma_addr, bnad->trcmod);
+	bna_all_stats_get(bnad->priv, &bnad->hw_stats);
+	spin_lock_init(&bnad->priv_lock);
+	bnad->priv_cbfn.ucast_set_cb = bnad_ucast_set_cb;
+	bnad->priv_cbfn.txq_stop_cb = bnad_q_stop_cb;
+	bnad->priv_cbfn.rxq_stop_cb = bnad_q_stop_cb;
+	bnad->priv_cbfn.link_up_cb = bnad_link_up_cb;
+	bnad->priv_cbfn.link_down_cb = bnad_link_down_cb;
+	bnad->priv_cbfn.stats_get_cb = bnad_stats_get_cb;
+	bnad->priv_cbfn.hw_error_cb = bnad_hw_error_cb;
+	bnad->priv_cbfn.lldp_get_cfg_cb = bnad_lldp_get_cfg_cb;
+	/* Diagnostics */
+	bnad->priv_cbfn.set_diag_lb_cb = bnad_set_diag_lb_cb;
+
+	bna_register_callback(bnad->priv, &bnad->priv_cbfn, bnad);
+
+	bna_iocll_meminfo(bnad->priv, bnad->ioc_meminfo);
+	for (i = 0; i < BNA_MEM_T_MAX; i++) {
+		if (!bnad->ioc_meminfo[i].len)
+			continue;
+		switch (i) {
+		case BNA_KVA_MEM_T_FWTRC:
+			bnad->ioc_meminfo[i].kva = vmalloc(
+			    bnad->ioc_meminfo[i].len);
+			break;
+		default:
+			bnad->ioc_meminfo[i].kva = pci_alloc_consistent(
+			    bnad->pcidev, bnad->ioc_meminfo[i].len,
+			    (dma_addr_t *)&bnad->ioc_meminfo[i].dma);
+
+			break;
+		}
+		if (!bnad->ioc_meminfo[i].kva) {
+			DPRINTK(ERR,
+				"port %u failed allocating %u bytes"
+				"memory for IOC\n",
+				bnad->bna_id, bnad->ioc_meminfo[i].len);
+			err = -ENOMEM;
+			goto free_ioc_mem;
+		}
+	}
+
+	pcidev_info.pci_slot = PCI_SLOT(bnad->pcidev->devfn);
+	pcidev_info.pci_func = PCI_FUNC(bnad->pcidev->devfn);
+	pcidev_info.device_id = bnad->pcidev->device;
+	pcidev_info.pci_bar_kva = bnad->bar0;
+	bna_iocll_attach(bnad->priv, bnad, bnad->ioc_meminfo,
+	    &pcidev_info, bnad->trcmod, bnad->aen, bnad->logmod);
+
+	err = bnad_cee_attach(bnad);
+	if (err) {
+		DPRINTK(ERR, "port %u cee_attach failed: %d\n",
+			bnad->bna_id, err);
+		goto iocll_detach;
+	}
+
+	if (bnad->flags & BNAD_F_MSIX)
+		bnad_enable_msix(bnad);
+	else
+		dev_info(&bnad->pcidev->dev, "Working in INTx mode, no RSS\n");
+	bna_intx_disable(bnad->priv, &intr_mask);
+	err = bnad_request_mbox_irq(bnad);
+	if (err)
+		goto disable_msix;
+
+	init_completion(&bnad->ioc_comp);
+	DPRINTK(DEBUG, "port %u enabling IOC ...\n", bnad->bna_id);
+	spin_lock_irq(&bnad->priv_lock);
+	bna_iocll_enable(bnad->priv);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	init_timer(&bnad->ioc_timer);
+	bnad->ioc_timer.function = &bnad_ioc_timeout;
+	bnad->ioc_timer.data = (unsigned long)bnad;
+	mod_timer(&bnad->ioc_timer, jiffies + HZ * BNA_IOC_TIMER_FREQ / 1000);
+
+	DPRINTK(DEBUG, "port %u waiting for IOC ready.\n", bnad->bna_id);
+	wait_for_completion(&bnad->ioc_comp);
+	if (!bnad->ioc_comp_status) {
+		DPRINTK(INFO, "port %u IOC is enabled.\n", bnad->bna_id);
+		bna_port_mac_get(bnad->priv,
+		    (u8 *)bnad->perm_addr);
+	} else {
+		DPRINTK(ERR, "port %u enabling IOC failed: %d\n",
+			bnad->bna_id, bnad->ioc_comp_status);
+		set_bit(BNAD_RESETTING, &bnad->state);
+	}
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
+	    pci_unmap_addr(bnad, priv_stats_dma));
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
+
+	if (bnad->priv) {
+		DPRINTK(INFO, "port %u disabling IOC ...\n", bnad->bna_id);
+		init_completion(&bnad->ioc_comp);
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
+			DPRINTK(INFO,
+				"bna_iocll_disable failed,"
+				"clean up and try again\n");
+			spin_lock_irq(&bnad->priv_lock);
+			bna_cleanup(bnad->priv);
+			err = bna_iocll_disable(bnad->priv);
+			spin_unlock_irq(&bnad->priv_lock);
+			BNA_ASSERT(!err);
+		}
+		wait_for_completion(&bnad->ioc_comp);
+		set_bit(BNAD_IOC_DISABLED, &bnad->state);
+		DPRINTK(INFO, "port %u IOC is disabled\n", bnad->bna_id);
+
+		set_bit(BNAD_REMOVED, &bnad->state);
+		/* Stop the timer after disabling IOC. */
+		del_timer_sync(&bnad->ioc_timer);
+		bnad_free_ioc_mem(bnad);
+		bna_iocll_detach(bnad->priv);
+
+		flush_scheduled_work();
+		bnad_free_mbox_irq(bnad);
+		bnad_disable_msix(bnad);
+
+		bnad_cee_detach(bnad);
+
+		bna_uninit(bnad->priv);
+		if (bnad->priv_stats) {
+			pci_free_consistent(bnad->pcidev, BNA_HW_STATS_SIZE,
+			    bnad->priv_stats,
+			    pci_unmap_addr(bnad, priv_stats_dma));
+			bnad->priv_stats = NULL;
+		}
+		kfree(bnad->priv);
+		bnad->priv = NULL;
+	}
+	BNA_ASSERT(list_empty(&bnad->file_q));
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
+	 .class_mask = 0xffff00
+	},
+	{0, 0}
+};
+MODULE_DEVICE_TABLE(pci, bnad_pci_id_table);
+
+static int __devinit
+bnad_pci_probe(struct pci_dev *pcidev, const struct pci_device_id *pcidev_id)
+{
+	int err, using_dac;
+	struct net_device *netdev;
+	struct bnad *bnad;
+	unsigned long mmio_start, mmio_len;
+	static u32 bna_id;
+
+	DPRINTK(INFO, "bnad_pci_probe(0x%p, 0x%p)\n", pcidev, pcidev_id);
+
+	DPRINTK(DEBUG, "PCI func %d\n", PCI_FUNC(pcidev->devfn));
+	if (!bfad_get_firmware_buf(pcidev)) {
+		printk(KERN_WARNING "Failed to load Firmware Image!\n");
+		return 0;
+	}
+
+	err = pci_enable_device(pcidev);
+	if (err) {
+		dev_err(&pcidev->dev, "pci_enable_device failed: %d\n", err);
+		return err;
+	}
+
+	err = pci_request_regions(pcidev, BNAD_NAME);
+	if (err) {
+		dev_err(&pcidev->dev, "pci_request_regions failed: %d\n", err);
+		goto disable_device;
+	}
+
+	if (!pci_set_dma_mask(pcidev, DMA_BIT_MASK(64)) &&
+	    !pci_set_consistent_dma_mask(pcidev, DMA_BIT_MASK(64))) {
+		using_dac = 1;
+		DPRINTK(INFO, "64bit DMA mask\n");
+	} else {
+		err = pci_set_dma_mask(pcidev, DMA_BIT_MASK(32));
+		if (err) {
+			err = pci_set_consistent_dma_mask(pcidev,
+							  DMA_BIT_MASK(32));
+			if (err) {
+				dev_err(&pcidev->dev,
+				    "set 32bit consistent DMA mask failed: %d\n"
+					, err);
+				goto release_regions;
+			}
+		}
+		using_dac = 0;
+		DPRINTK(INFO, "32bit DMA mask\n");
+	}
+
+	pci_set_master(pcidev);
+
+	 netdev = alloc_etherdev(sizeof(struct bnad));
+	if (!netdev) {
+		dev_err(&pcidev->dev, "alloc_etherdev failed\n");
+		err = -ENOMEM;
+		goto release_regions;
+	}
+	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &pcidev->dev);
+	pci_set_drvdata(pcidev, netdev);
+
+	bnad = netdev_priv(netdev);
+	set_bit(BNAD_DISABLED, &bnad->state);
+	bnad->netdev = netdev;
+	bnad->pcidev = pcidev;
+	mmio_start = pci_resource_start(pcidev, 0);
+	mmio_len = pci_resource_len(pcidev, 0);
+	bnad->bar0 = ioremap_nocache(mmio_start, mmio_len);
+	if (!bnad->bar0) {
+		dev_err(&pcidev->dev, "ioremap for bar0 failed\n");
+		err = -ENOMEM;
+		goto free_devices;
+	}
+	DPRINTK(INFO, "bar0 mapped to %p, len %lu\n", bnad->bar0, mmio_len);
+
+	netdev->netdev_ops = &bnad_netdev_ops;
+	netdev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
+#ifdef NETIF_F_IPV6_CSUM
+	netdev->features |= NETIF_F_IPV6_CSUM;
+#endif
+#ifdef NETIF_F_TSO
+	netdev->features |= NETIF_F_TSO;
+#endif
+#ifdef NETIF_F_TSO6
+	netdev->features |= NETIF_F_TSO6;
+#endif
+#ifdef NETIF_F_LRO
+	netdev->features |= NETIF_F_LRO;
+#endif
+#ifdef BNAD_VLAN_FEATURES
+	netdev->vlan_features = netdev->features;
+#endif
+	if (using_dac)
+		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
+	    NETIF_F_HW_VLAN_FILTER;
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
+#ifdef ETHTOOL_GPERMADDR
+	memcpy(netdev->perm_addr, bnad->perm_addr, netdev->addr_len);
+#endif
+	memcpy(netdev->dev_addr, bnad->perm_addr, netdev->addr_len);
+
+
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+	err = register_netdev(netdev);
+	if (err) {
+		printk(KERN_ERR "port %u register_netdev failed: %d\n",
+		    bnad->bna_id, err);
+		goto bnad_device_uninit;
+	}
+
+
+	bna_id++;
+	return 0;
+
+bnad_device_uninit:
+	bnad_priv_uninit(bnad);
+unmap_bar0:
+	iounmap(bnad->bar0);
+free_devices:
+	pci_set_drvdata(pcidev, NULL);
+	free_netdev(netdev);
+release_regions:
+	pci_release_regions(pcidev);
+disable_device:
+	pci_disable_device(pcidev);
+
+	return err;
+}
+
+static void __devexit bnad_pci_remove(struct pci_dev *pcidev)
+{
+	struct net_device *netdev = pci_get_drvdata(pcidev);
+	struct bnad *bnad;
+
+	DPRINTK(INFO, "%s bnad_pci_remove\n", netdev->name);
+	if (!netdev)
+		return;
+	bnad = netdev_priv(netdev);
+
+
+	unregister_netdev(netdev);
+
+	bnad_priv_uninit(bnad);
+	iounmap(bnad->bar0);
+	pci_set_drvdata(pcidev, NULL);
+	free_netdev(netdev);
+	pci_release_regions(pcidev);
+	pci_disable_device(pcidev);
+}
+
+static struct pci_driver bnad_pci_driver = {
+	.name = BNAD_NAME,
+	.id_table = bnad_pci_id_table,
+	.probe    = bnad_pci_probe,
+	.remove   = __devexit_p(bnad_pci_remove),
+};
+
+static int __init bnad_module_init(void)
+{
+	int err;
+
+	printk(KERN_INFO "Brocade 10G Ethernet driver %s\n", bfa_version);
+	DPRINTK(INFO, "Module bna is loaded at 0x%p\n",
+		__this_module.module_core);
+	err = bnad_check_module_params();
+	if (err)
+		return err;
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
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bnad.h linux-2.6.32-rc4-mod/drivers/net/bna/bnad.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bnad.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bnad.h	2009-10-16 10:30:53.075436000 -0700
@@ -0,0 +1,374 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved.
+ */
+
+#ifndef _BNAD_H_
+#define _BNAD_H_
+
+#include <cee/bfa_cee.h>
+#include "bna.h"
+
+#if !defined(CONFIG_INET_LRO) && !defined(CONFIG_INET_LRO_MODULE)
+#include <net/ip.h>
+#include <net/tcp.h>
+#else
+#include <linux/inet_lro.h>
+#endif
+
+#include "bnad_compat.h"
+
+#if !defined(CONFIG_INET_LRO) && !defined(CONFIG_INET_LRO_MODULE)
+#include "inet_lro.h"
+#endif
+
+#define BNAD_LRO_MAX_DESC	8
+#define BNAD_LRO_MAX_AGGR	64
+
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
+#define BNAD_MAX_COALESCING_TIMEO	0xFF 	/* in 5us units */
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
+#define BNAD_TX_MAX_DATA_PER_VECTOR	0x3FFF		/* 14 bits */
+#define BNAD_TX_MAX_WRR_QUOTA		0xFFF		/* 12 bits */
+
+#define BNAD_RXQ_REFILL_THRESHOLD_SHIFT	3
+
+#define BNAD_CQ_PROCESS_LIMIT		512
+
+#define BNAD_NOT_READY(_bnad)	test_bit(BNAD_RESETTING, &(_bnad)->state)
+
+#define BNAD_Q_INDEX_CHANGE(_old_idx, _updated_idx, _q_depth)	\
+    (((_updated_idx) - (_old_idx)) & ((_q_depth) - 1))
+
+#define bnad_lock()
+#define bnad_unlock()
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
+    u32    producer_index;
+    u32    consumer_index;
+    struct bnad_skb_unmap *unmap_array;
+    u32	q_depth;
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
+#ifdef DEBUG_TX
+	u32 max_tso;
+	u32 tx_vectors[32];
+#endif
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
+}  ____cacheline_aligned;
+
+struct bnad_cq_info {
+	struct bna_cq cq;
+	struct bna_ib ib;
+	struct bnad *bnad;
+	struct bna_pkt_rate pkt_rate;
+	u8 rx_coalescing_timeo;	/* Unit is 5usec. */
+	volatile u32 *hw_producer_index;
+	struct net_lro_mgr  lro;
+	struct napi_struct napi;
+	u32 cq_id;
+	struct bna_cq_config cq_config;
+	char name[BNAD_QUEUE_NAME_SIZE];
+}  ____cacheline_aligned;
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
+struct bnad_diag_lb_params {
+	struct bnad *bnad;
+	struct completion diag_lb_comp;
+	int diag_lb_comp_status;
+	int diag_lb_link_state;
+#define BNAD_DIAG_LB_LS_UNKNOWN	-1
+#define BNAD_DIAG_LB_LS_UP	 0
+#define BNAD_DIAG_LB_LS_DOWN	 1
+};
+
+#define BNAD_AEN_MAX_APPS 8
+struct bnad_aen_file_s {
+	struct list_head  qe;
+	struct bnad *bnad;
+	s32 ri;
+	s32 app_id;
+};
+
+struct bnad {
+	struct net_device *netdev;
+	struct pci_dev *pcidev;
+	struct bna_dev_s *priv;
+
+	unsigned long state;
+#define BNAD_DISABLED		0
+#define BNAD_RESETTING		1
+#define BNAD_REMOVED		2
+#define BNAD_SET_UCAST		4
+#define BNAD_IOC_DISABLED	5
+#define BNAD_PORT_DISABLED	6
+#define BNAD_MBOX_IRQ_DISABLED	7
+
+	unsigned int flags;
+#define BNAD_F_MSIX		0x01
+#define BNAD_F_PROMISC		0x02
+#define BNAD_F_ALLMULTI		0x04
+#define BNAD_F_WOL		0x08
+#define BNAD_F_TXQ_DEPTH	0x10
+#define BNAD_F_RXQ_DEPTH	0x20
+
+
+	uint txq_num;
+	uint txq_depth;
+	struct bnad_txq_info *txq_table;
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
+	struct bna_rit_entry *rit;		/* RxQ Indirection Table */
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
+	u8	rx_interpkt_timeo;	/* 4 bits, unit is 0.5usec. */
+	u8 rx_dyn_coalesce_on;	/* Rx Dynamic Intr Moderation Flag */
+	u8 ref_count;
+	u8 lldp_comp_status;
+	u8 cee_stats_comp_status;
+	u8 cee_reset_stats_status;
+	u8 ucast_comp_status;
+	u8 qstop_comp_status;
+	u16 rsvd_2;
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
+
+	struct completion lldp_comp;
+	struct completion cee_stats_comp;
+	struct completion cee_reset_stats_comp;
+	struct completion ucast_comp;
+	struct completion qstop_comp;
+	struct completion ioc_comp;
+
+	u32 bna_id;
+	u8 __iomem *bar0;			/* registers */
+	unsigned char perm_addr[ETH_ALEN];
+	u32 pci_saved_config[16];
+
+	void *priv_stats;
+	DECLARE_PCI_UNMAP_ADDR(priv_stats_dma)
+
+	struct bfa_trc_mod_s *trcmod;
+	struct bfa_log_mod_s *logmod;
+	struct bfa_aen_s *aen;
+	struct bnad_aen_file_s file_buf[BNAD_AEN_MAX_APPS];
+	struct list_head         file_q;
+	struct list_head         file_free_q;
+	struct bna_meminfo ioc_meminfo[BNA_MEM_T_MAX];
+	struct timer_list ioc_timer;
+
+	struct bna_mbox_cbfn priv_cbfn;
+
+	char adapter_name[64];
+	char port_name[64];
+
+	/* Diagnostics */
+	struct bna_diag_lb_pkt_stats *lb_stats;
+	struct bnad_diag_lb_params *dlbp;
+
+	/* CEE Stuff */
+	struct bfa_cee_cbfn_s cee_cbfn;
+	struct bfa_cee_s cee;
+
+	struct list_head list_entry;
+};
+
+extern uint bnad_rxqs_per_cq;
+extern uint bnad_rxq_depth;
+extern uint bnad_txq_depth;
+extern uint bnad_small_large_rxbufs;
+
+extern struct list_head bnad_list;
+
+int bnad_open(struct net_device *netdev);
+int bnad_stop(struct net_device *netdev);
+int bnad_stop_locked(struct net_device *netdev);
+int bnad_open_locked(struct net_device *netdev);
+int bnad_sw_reset(struct net_device *netdev);
+int bnad_resetting(struct bnad *bnad);
+void bnad_set_ethtool_ops(struct net_device *netdev);
+void bnad_ioctl_init(void);
+void bnad_ioctl_exit(void);
+struct net_device_stats *bnad_get_stats(struct net_device *netdev);
+void bnad_reset_stats(struct net_device *netdev);
+
+int bnad_ucast_mac(struct bnad *bnad, unsigned int rxf_id,
+		   u8 *mac_ptr, unsigned int cmd);
+int bnad_rxq_init(struct bnad *bnad, uint rxq_id);
+void bnad_setup_rxq(struct bnad *bnad, uint rxq_id);
+void bnad_alloc_for_rxq(struct bnad *bnad, uint rxq_id);
+void bnad_free_rxq(struct bnad *bnad, uint rxq_id);
+int bnad_cq_init(struct bnad *bnad, uint cq_id);
+void bnad_setup_cq(struct bnad *bnad, uint cq_id);
+int bnad_alloc_ib(struct bnad *bnad, uint ib_id);
+void bnad_setup_ib(struct bnad *bnad, uint ib_id);
+void bnad_rxib_init(struct bnad *bnad, uint cq_id, uint ib_id);
+void bnad_free_ib(struct bnad *bnad, uint ib_id);
+int bnad_request_cq_irq(struct bnad *bnad, uint cq_id);
+u32 bnad_get_msglevel(struct net_device *netdev);
+void bnad_set_msglevel(struct net_device *netdev, u32 msglevel);
+int bnad_alloc_unmap_q(struct bnad_unmap_q *unmap_q, u32 q_depth);
+int bnad_disable_rxq(struct bnad *bnad, u32 rxq_id);
+void bnad_free_cq(struct bnad *bnad, uint cq_id);
+void bnad_add_to_list(struct bnad *bnad);
+void bnad_remove_from_list(struct bnad *bnad);
+struct bnad *get_bnadev(int bna_id);
+/* For diagnostics */
+int bnad_diag_lb_rx(struct bnad *bnad, struct sk_buff *skb);
+int bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev);
+
+#endif /* _BNAD_H_ */

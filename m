From: ggrundstrom@neteffect.com
Subject: [ofa-general] [PATCH 8/14 v2] nes: nic device routines
Date: Fri, 19 Oct 2007 15:17:22 -0500
Message-ID: <200710192017.l9JKHMA9021789@neteffect.com>
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: ewg@lists.openfabrics.org, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

NIC device routines.

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---

--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.3/drivers/infiniband/hw/nes/nes_nic.c	2007-10-19 09:43:32.000000000 -0500
@@ -0,0 +1,1517 @@
+/*
+ * Copyright (c) 2006 - 2007 NetEffect, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/if_arp.h>
+#include <linux/if_vlan.h>
+#include <linux/ethtool.h>
+#include <net/tcp.h>
+
+#include <net/inet_common.h>
+#include <linux/inet.h>
+
+#include "nes.h"
+
+static struct nic_qp_map nic_qp_mapping_0[] = {
+	{16,0,0,1},{24,4,0,0},{28,8,0,0},{32,12,0,0},
+	{20,2,2,1},{26,6,2,0},{30,10,2,0},{34,14,2,0},
+	{18,1,1,1},{25,5,1,0},{29,9,1,0},{33,13,1,0},
+	{22,3,3,1},{27,7,3,0},{31,11,3,0},{35,15,3,0}
+};
+
+static struct nic_qp_map nic_qp_mapping_1[] = {
+	{18,1,1,1},{25,5,1,0},{29,9,1,0},{33,13,1,0},
+	{22,3,3,1},{27,7,3,0},{31,11,3,0},{35,15,3,0}
+};
+
+static struct nic_qp_map nic_qp_mapping_2[] = {
+	{20,2,2,1},{26,6,2,0},{30,10,2,0},{34,14,2,0}
+};
+
+static struct nic_qp_map nic_qp_mapping_3[] = {
+	{22,3,3,1},{27,7,3,0},{31,11,3,0},{35,15,3,0}
+};
+
+static struct nic_qp_map nic_qp_mapping_4[] = {
+	{28,8,0,0},{32,12,0,0}
+};
+
+static struct nic_qp_map nic_qp_mapping_5[] = {
+	{29,9,1,0},{33,13,1,0}
+};
+
+static struct nic_qp_map nic_qp_mapping_6[] = {
+	{30,10,2,0},{34,14,2,0}
+};
+
+static struct nic_qp_map nic_qp_mapping_7[] = {
+	{31,11,3,0},{35,15,3,0}
+};
+
+static struct nic_qp_map *nic_qp_mapping_per_function[] = {
+	nic_qp_mapping_0, nic_qp_mapping_1, nic_qp_mapping_2, nic_qp_mapping_3,
+	nic_qp_mapping_4, nic_qp_mapping_5, nic_qp_mapping_6, nic_qp_mapping_7
+};
+
+static const u32 default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK
+		| NETIF_MSG_IFUP | NETIF_MSG_IFDOWN;
+static int debug = -1;
+
+static int rdma_enabled = 0;
+
+static int nes_netdev_open(struct net_device *);
+static int nes_netdev_stop(struct net_device *);
+static int nes_netdev_start_xmit(struct sk_buff *, struct net_device *);
+static struct net_device_stats *nes_netdev_get_stats(struct net_device *);
+static void nes_netdev_tx_timeout(struct net_device *);
+static int nes_netdev_set_mac_address(struct net_device *, void *);
+static int nes_netdev_change_mtu(struct net_device *, int);
+
+#ifdef NES_NAPI
+/**
+ * nes_netdev_poll
+ */
+static int nes_netdev_poll(struct net_device* netdev, int* budget)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_hw_nic_cq *nescq = &nesvnic->nic_cq;
+
+	nesvnic->budget = *budget;
+	nesvnic->cqes_pending = 0;
+	nesvnic->rx_cqes_completed = 0;
+	nesvnic->cqe_allocs_pending = 0;
+
+	nes_nic_ce_handler(nesdev, nescq);
+
+	netdev->quota -= nesvnic->rx_cqes_completed;
+	*budget -= nesvnic->rx_cqes_completed;
+
+	if (0 == nesvnic->cqes_pending) {
+		netif_rx_complete(netdev);
+		/* clear out completed cqes and arm */
+		nes_write32(nesdev->regs+NES_CQE_ALLOC, NES_CQE_ALLOC_NOTIFY_NEXT |
+				nescq->cq_number | (nesvnic->cqe_allocs_pending << 16));
+		nes_read32(nesdev->regs+NES_CQE_ALLOC);
+	} else {
+		/* clear out completed cqes but don't arm */
+		nes_write32(nesdev->regs+NES_CQE_ALLOC,
+				nescq->cq_number | (nesvnic->cqe_allocs_pending << 16));
+		nes_debug(NES_DBG_NETDEV, "%s: exiting with work pending\n",
+				nesvnic->netdev->name);
+	}
+
+	return((0 == nesvnic->cqes_pending) ? 0 : 1);
+}
+#endif
+
+
+/**
+ * nes_netdev_open - Activate the network interface; ifconfig
+ * ethx up.
+ */
+static int nes_netdev_open(struct net_device *netdev)
+{
+	u32 macaddr_low;
+	u16 macaddr_high;
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	int ret;
+	int i;
+	struct nes_vnic *first_nesvnic;
+	u32 nic_active_bit;
+	u32 nic_active;
+
+	assert(nesdev != NULL);
+
+	first_nesvnic = list_entry(nesdev->nesadapter->nesvnic_list[nesdev->mac_index].next,
+			struct nes_vnic, list);
+
+	if (netif_msg_ifup(nesvnic))
+		printk(KERN_INFO PFX "%s: enabling interface\n", netdev->name);
+
+	ret = nes_init_nic_qp(nesdev, netdev);
+	if (ret) {
+		return ret;
+	}
+
+	netif_stop_queue(netdev);
+
+	if ((!nesvnic->of_device_registered) && (nesvnic->rdma_enabled)) {
+		nesvnic->nesibdev = nes_init_ofa_device(netdev);
+		if (nesvnic->nesibdev == NULL) {
+			printk(KERN_ERR PFX "%s: nesvnic->nesibdev alloc failed", netdev->name);
+		} else {
+			nesvnic->nesibdev->nesvnic = nesvnic;
+			ret = nes_register_ofa_device(nesvnic->nesibdev);
+			if (ret) {
+				printk(KERN_ERR PFX "%s: Unable to register RDMA device, ret = %d\n",
+						netdev->name, ret);
+			}
+		}
+	}
+	/* Set packet filters */
+	nic_active_bit = 1 << nesvnic->nic_index;
+	nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_ACTIVE);
+	nic_active |= nic_active_bit;
+	nes_write_indexed(nesdev, NES_IDX_NIC_ACTIVE, nic_active);
+	nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_MULTICAST_ALL);
+	nic_active |= nic_active_bit;
+	nes_write_indexed(nesdev, NES_IDX_NIC_MULTICAST_ALL, nic_active);
+	nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_BROADCAST_ON);
+	nic_active |= nic_active_bit;
+	nes_write_indexed(nesdev, NES_IDX_NIC_BROADCAST_ON, nic_active);
+
+	macaddr_high = ((u16)netdev->dev_addr[0]) << 8;
+	macaddr_high += (u16)netdev->dev_addr[1];
+	macaddr_low = ((u32)netdev->dev_addr[2]) << 24;
+	macaddr_low += ((u32)netdev->dev_addr[3]) << 16;
+	macaddr_low += ((u32)netdev->dev_addr[4]) << 8;
+	macaddr_low += (u32)netdev->dev_addr[5];
+
+#define NES_MAX_PORT_COUNT 4
+	/* Program the various MAC regs */
+	for (i = 0; i < NES_MAX_PORT_COUNT; i++) {
+		if (nesvnic->qp_nic_index[i] == 0xf) {
+			break;
+		}
+		nes_debug(NES_DBG_NETDEV, "i=%d, perfect filter table index= %d, PERF FILTER LOW"
+				" (Addr:%08X) = %08X, HIGH = %08X.\n",
+				i, nesvnic->qp_nic_index[i],
+				NES_IDX_PERFECT_FILTER_LOW+((nesvnic->perfect_filter_index + i) * 8),
+				macaddr_low,
+				(u32)macaddr_high | NES_MAC_ADDR_VALID |
+				((((u32)nesvnic->nic_index) << 16)));
+		nes_write_indexed(nesdev,
+				NES_IDX_PERFECT_FILTER_LOW + (nesvnic->qp_nic_index[i] * 8),
+				macaddr_low);
+		nes_write_indexed(nesdev,
+				NES_IDX_PERFECT_FILTER_HIGH + (nesvnic->qp_nic_index[i] * 8),
+				(u32)macaddr_high | NES_MAC_ADDR_VALID |
+				((((u32)nesvnic->nic_index) << 16)));
+	}
+
+	
+	if (netdev->ip_ptr) {
+		struct in_device *ip = netdev->ip_ptr;
+		struct in_ifaddr *in = NULL;
+		if (ip && ip->ifa_list) {
+			in = ip->ifa_list;
+			nes_manage_arp_cache(nesvnic->netdev, netdev->dev_addr,
+					ntohl(in->ifa_address), NES_ARP_ADD);
+		}
+	}
+
+	nes_write32(nesdev->regs+NES_CQE_ALLOC, NES_CQE_ALLOC_NOTIFY_NEXT |
+			nesvnic->nic_cq.cq_number);
+	nes_read32(nesdev->regs+NES_CQE_ALLOC);
+
+	if (first_nesvnic->linkup) {
+		/* Enable network packets */
+		nesvnic->linkup = 1;
+		netif_start_queue(netdev);
+	} else {
+		netif_carrier_off(netdev);
+	}
+	nesvnic->netdev_open = 1;
+
+	return 0;
+}
+
+
+/**
+ * nes_netdev_stop
+ */
+static int nes_netdev_stop(struct net_device *netdev)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	u32 nic_active_mask;
+	u32 nic_active;
+
+	nes_debug(NES_DBG_SHUTDOWN, "\n");
+	if (0 == nesvnic->netdev_open)
+		return 0;
+
+	if (netif_msg_ifdown(nesvnic))
+		printk(KERN_INFO PFX "%s: disabling interface\n", netdev->name);
+
+	/* Disable network packets */
+	netif_stop_queue(netdev);
+	if ((nesdev->netdev[0] == netdev)&(nesvnic->logical_port == nesdev->mac_index)) {
+		nes_write_indexed(nesdev,
+				NES_IDX_MAC_INT_MASK+(0x200*nesdev->mac_index), 0xffffffff);
+	}
+
+	nic_active_mask = ~((u32)(1 << nesvnic->nic_index));
+	nes_write_indexed(nesdev, NES_IDX_PERFECT_FILTER_HIGH+
+			(nesvnic->perfect_filter_index*8), 0);
+	nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_ACTIVE);
+	nic_active &= nic_active_mask;
+	nes_write_indexed(nesdev, NES_IDX_NIC_ACTIVE, nic_active);
+	nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_MULTICAST_ALL);
+	nic_active &= nic_active_mask;
+	nes_write_indexed(nesdev, NES_IDX_NIC_MULTICAST_ALL, nic_active);
+	nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_BROADCAST_ON);
+	nic_active &= nic_active_mask;
+	nes_write_indexed(nesdev, NES_IDX_NIC_BROADCAST_ON, nic_active);
+
+
+	if (nesvnic->of_device_registered) {
+		nes_destroy_ofa_device(nesvnic->nesibdev);
+		nesvnic->nesibdev = NULL;
+		nesvnic->of_device_registered = 0;
+		rdma_enabled = 0;
+	}
+	nes_destroy_nic_qp(nesvnic);
+
+	nesvnic->netdev_open = 0;
+
+	return 0;
+}
+
+
+/**
+ * nes_nic_send
+ */
+static int nes_nic_send(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_hw_nic *nesnic = &nesvnic->nic;
+	struct nes_hw_nic_sq_wqe *nic_sqe;
+#ifdef NETIF_F_TSO
+	struct tcphdr *tcph;
+	/* struct udphdr *udph; */
+#endif
+//	u64 *wqe_fragment_address;
+	u16 *wqe_fragment_length;
+	u32 wqe_misc;
+	u16 wqe_fragment_index = 1;	/* first fragment (0) is used by copy buffer */
+	u16 skb_fragment_index;
+	dma_addr_t bus_address;
+
+	nic_sqe = &nesnic->sq_vbase[nesnic->sq_head];
+	wqe_fragment_length = (u16 *)&nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_0_TAG_IDX];
+
+	/* setup the VLAN tag if present */
+	if (vlan_tx_tag_present(skb)) {
+		nes_debug(NES_DBG_NIC_TX, "%s: VLAN packet to send... VLAN = %08X\n",
+				netdev->name, vlan_tx_tag_get(skb));
+		wqe_misc = NES_NIC_SQ_WQE_TAGVALUE_ENABLE;
+		wqe_fragment_length[0] = vlan_tx_tag_get(skb);
+	} else
+		wqe_misc = 0;
+
+	/* bump past the vlan tag */
+	wqe_fragment_length++;
+	/*	wqe_fragment_address = (u64 *)&nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG0_LOW_IDX]; */
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+#ifdef OFED_1_2
+		tcph = skb->h.th;
+#else
+		tcph = tcp_hdr(skb);
+#endif
+		if (1) {
+#ifdef NETIF_F_TSO
+			if (nes_skb_is_gso(skb)) {
+				/* nes_debug(NES_DBG_NIC_TX, "%s: TSO request... seg size = %u\n",
+						netdev->name, nes_skb_is_gso(skb)); */
+				wqe_misc |= NES_NIC_SQ_WQE_LSO_ENABLE |
+						NES_NIC_SQ_WQE_COMPLETION | (u16)nes_skb_is_gso(skb);
+				nic_sqe->wqe_words[NES_NIC_SQ_WQE_LSO_INFO_IDX] =
+						cpu_to_le32(((u32)tcph->doff) |
+						(((u32)(((unsigned char *)tcph) - skb->data)) << 4));
+			} else {
+#endif
+				wqe_misc |= NES_NIC_SQ_WQE_COMPLETION;
+#ifdef NETIF_F_TSO
+			}
+#endif
+		}
+	} else {	/* CHECKSUM_HW */
+		wqe_misc |= NES_NIC_SQ_WQE_DISABLE_CHKSUM | NES_NIC_SQ_WQE_COMPLETION;
+	}
+
+	nic_sqe->wqe_words[NES_NIC_SQ_WQE_TOTAL_LENGTH_IDX] = cpu_to_le32(skb->len);
+	memcpy(&nesnic->first_frag_vbase[nesnic->sq_head].buffer,
+			skb->data, min(((unsigned int)NES_FIRST_FRAG_SIZE), skb_headlen(skb)));
+	wqe_fragment_length[0] = cpu_to_le16(min(((unsigned int)NES_FIRST_FRAG_SIZE),
+			skb_headlen(skb)));
+	wqe_fragment_length[1] = 0;
+	if (skb_headlen(skb) > NES_FIRST_FRAG_SIZE) {
+		if ((skb_shinfo(skb)->nr_frags + 1) > 4) {
+			nes_debug(NES_DBG_NIC_TX, "%s: Packet with %u fragments not sent, skb_headlen=%u\n",
+					netdev->name, skb_shinfo(skb)->nr_frags + 2, skb_headlen(skb));
+			kfree_skb(skb);
+			nesvnic->tx_sw_dropped++;
+			return NETDEV_TX_LOCKED;
+		}
+		bus_address = pci_map_single(nesdev->pcidev, skb->data + NES_FIRST_FRAG_SIZE,
+				skb_headlen(skb) - NES_FIRST_FRAG_SIZE, PCI_DMA_TODEVICE);
+		wqe_fragment_length[wqe_fragment_index++] =
+				cpu_to_le16(skb_headlen(skb) - NES_FIRST_FRAG_SIZE);
+		wqe_fragment_length[wqe_fragment_index] = 0;
+		nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG1_LOW_IDX] = cpu_to_le32((u32)((u64)(bus_address)));
+		nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG1_HIGH_IDX] = cpu_to_le32((u32)(((u64)(bus_address))>>32));
+		nesnic->tx_skb[nesnic->sq_head] = skb;
+	}
+
+	if (skb_headlen(skb) == skb->len) {
+		if (skb_headlen(skb) <= NES_FIRST_FRAG_SIZE) {
+			nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_2_1_IDX] = 0;
+			nesnic->tx_skb[nesnic->sq_head] = NULL;
+			dev_kfree_skb(skb);
+		}
+	} else {
+		/* Deal with Fragments */
+		nesnic->tx_skb[nesnic->sq_head] = skb;
+		for (skb_fragment_index = 0; skb_fragment_index < skb_shinfo(skb)->nr_frags;
+				skb_fragment_index++) {
+			bus_address = pci_map_page( nesdev->pcidev,
+					skb_shinfo(skb)->frags[skb_fragment_index].page,
+					skb_shinfo(skb)->frags[skb_fragment_index].page_offset,
+					skb_shinfo(skb)->frags[skb_fragment_index].size,
+					PCI_DMA_TODEVICE);
+			wqe_fragment_length[wqe_fragment_index] =
+					cpu_to_le16(skb_shinfo(skb)->frags[skb_fragment_index].size);
+			nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG0_LOW_IDX+(2*wqe_fragment_index)] =
+				cpu_to_le32((u32)((u64)(bus_address)));
+			nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG0_HIGH_IDX+(2*wqe_fragment_index)] =
+				cpu_to_le32((u32)(((u64)(bus_address))>>32));
+			wqe_fragment_index++;
+			if (wqe_fragment_index < 5)
+				wqe_fragment_length[wqe_fragment_index] = 0;
+		}
+	}
+
+	nic_sqe->wqe_words[NES_NIC_SQ_WQE_MISC_IDX] = cpu_to_le32(wqe_misc);
+	nesnic->sq_head++;
+	nesnic->sq_head &= nesnic->sq_size - 1;
+
+	return NETDEV_TX_OK;
+}
+
+
+/**
+ * nes_netdev_start_xmit
+ */
+static int nes_netdev_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_hw_nic *nesnic = &nesvnic->nic;
+	struct nes_hw_nic_sq_wqe *nic_sqe;
+#ifdef NETIF_F_TSO
+	struct tcphdr *tcph;
+	/* struct udphdr *udph; */
+#define NES_MAX_TSO_FRAGS 18
+	/* 64K segment plus overflow on each side */
+	dma_addr_t tso_bus_address[NES_MAX_TSO_FRAGS];
+	u32 tso_frag_index;
+	u32 tso_frag_count;
+	u32 tso_wqe_length;
+	u32 curr_tcp_seq;
+#endif
+	u32 wqe_count=1;
+	u32 send_rc;
+	struct iphdr *iph;
+	unsigned long flags;
+	u16 *wqe_fragment_length;
+//	u64 *wqe_fragment_address;
+	/* first fragment (0) is used by copy buffer */
+	u16 wqe_fragment_index=1;
+	u16 hoffset;
+	u16 nhoffset;
+#ifdef NETIF_F_TSO
+	u16 wqes_needed;
+	u16 wqes_available;
+#endif
+	u32 old_head;
+	u32 wqe_misc;
+
+	if (nes_debug_level & NES_DBG_NIC_TX) {
+		nes_debug(NES_DBG_NIC_TX, "%s Request to tx NIC packet length %u, headlen %u,"
+				" (%u frags), tso_size=%u\n",
+				netdev->name, skb->len, skb_headlen(skb),
+				skb_shinfo(skb)->nr_frags, nes_skb_is_gso(skb));
+	}
+	local_irq_save(flags);
+	if (!spin_trylock(&nesnic->sq_lock)) {
+		local_irq_restore(flags);
+		nesvnic->sq_locked++;
+		return NETDEV_TX_LOCKED;
+	}
+
+	/* Check if SQ is full */
+	if ((((nesnic->sq_tail+(nesnic->sq_size*2))-nesnic->sq_head) & (nesnic->sq_size - 1)) == 1) {
+		netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&nesnic->sq_lock, flags);
+		nesvnic->sq_full++;
+		return NETDEV_TX_BUSY;
+	}
+
+	/* Check if too many fragments */
+	if (unlikely((skb_shinfo(skb)->nr_frags) > 4)) {
+#ifdef NETIF_F_TSO
+		if (nes_skb_is_gso(skb) && (skb_headlen(skb) <= NES_FIRST_FRAG_SIZE)) {
+			nesvnic->segmented_tso_requests++;
+			nesvnic->tso_requests++;
+			old_head = nesnic->sq_head;
+			/* Basically 4 fragments available per WQE with extended fragments */
+			wqes_needed = skb_shinfo(skb)->nr_frags >> 2;
+			wqes_needed += (skb_shinfo(skb)->nr_frags&3)?1:0;
+			wqes_available = (((nesnic->sq_tail+nesnic->sq_size)-nesnic->sq_head) - 1) &
+					(nesnic->sq_size - 1);
+
+			if (unlikely(wqes_needed > wqes_available)) {
+				netif_stop_queue(netdev);
+				spin_unlock_irqrestore(&nesnic->sq_lock, flags);
+				nes_debug(NES_DBG_NIC_TX, "%s: HNIC SQ full- TSO request has too many frags!\n",
+						netdev->name);
+				nesvnic->sq_full++;
+				return NETDEV_TX_BUSY;
+			}
+			/* Map all the buffers */
+			for (tso_frag_count=0; tso_frag_count < skb_shinfo(skb)->nr_frags;
+					tso_frag_count++) {
+				tso_bus_address[tso_frag_count] = pci_map_page( nesdev->pcidev,
+						skb_shinfo(skb)->frags[tso_frag_count].page,
+						skb_shinfo(skb)->frags[tso_frag_count].page_offset,
+						skb_shinfo(skb)->frags[tso_frag_count].size,
+						PCI_DMA_TODEVICE);
+			}
+
+			tso_frag_index = 0;
+#ifdef OFED_1_2
+			curr_tcp_seq = ntohl(skb->h.th->seq);
+#else
+			curr_tcp_seq = ntohl(tcp_hdr(skb)->seq);
+#endif
+#ifdef OFED_1_2
+			hoffset = skb->h.raw - skb->data;
+			nhoffset = skb->nh.raw - skb->data;
+#else
+			hoffset = skb_transport_header(skb) - skb->data;
+			nhoffset = skb_network_header(skb) - skb->data;
+#endif
+
+			for (wqe_count=0; wqe_count<((u32)wqes_needed); wqe_count++) {
+				tso_wqe_length = 0;
+				nic_sqe = &nesnic->sq_vbase[nesnic->sq_head];
+				wqe_fragment_length =
+						(u16 *)&nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_0_TAG_IDX];
+				/* setup the VLAN tag if present */
+				if (vlan_tx_tag_present(skb)) {
+					nes_debug(NES_DBG_NIC_TX, "%s: VLAN packet to send... VLAN = %08X\n",
+							netdev->name, vlan_tx_tag_get(skb) );
+					wqe_misc = NES_NIC_SQ_WQE_TAGVALUE_ENABLE;
+					wqe_fragment_length[0] = vlan_tx_tag_get(skb);
+				} else
+					wqe_misc = 0;
+
+				/* bump past the vlan tag */
+				wqe_fragment_length++;
+//				wqe_fragment_address =
+//						(u64 *)&nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG0_LOW_IDX];
+
+				/* Assumes header totally fits in allocated buffer and is in first fragment */
+				if (skb_headlen(skb) > NES_FIRST_FRAG_SIZE) {
+					nes_debug(NES_DBG_NIC_TX, "ERROR: SKB header too big, skb_headlen=%u, FIRST_FRAG_SIZE=%u\n",
+							skb_headlen(skb), NES_FIRST_FRAG_SIZE);
+					nes_debug(NES_DBG_NIC_TX, "%s Request to tx NIC packet length %u, headlen %u,"
+							" (%u frags), tso_size=%u\n",
+							netdev->name,
+							skb->len, skb_headlen(skb),
+							skb_shinfo(skb)->nr_frags, nes_skb_is_gso(skb));
+				}
+				memcpy(&nesnic->first_frag_vbase[nesnic->sq_head].buffer,
+						skb->data, min(((unsigned int)NES_FIRST_FRAG_SIZE),
+						skb_headlen(skb)));
+				iph = (struct iphdr *)
+				(&nesnic->first_frag_vbase[nesnic->sq_head].buffer[nhoffset]);
+				tcph = (struct tcphdr *)
+				(&nesnic->first_frag_vbase[nesnic->sq_head].buffer[hoffset]);
+				if ((wqe_count+1)!=(u32)wqes_needed) {
+					tcph->fin = 0;
+					tcph->psh = 0;
+					tcph->rst = 0;
+					tcph->urg = 0;
+				}
+				if (wqe_count) {
+					tcph->syn = 0;
+				}
+				tcph->seq = htonl(curr_tcp_seq);
+				wqe_fragment_length[0] = cpu_to_le16(min(((unsigned int)NES_FIRST_FRAG_SIZE),
+						skb_headlen(skb)));
+
+				for (wqe_fragment_index = 1; wqe_fragment_index < 5;) {
+					wqe_fragment_length[wqe_fragment_index] =
+							cpu_to_le16(skb_shinfo(skb)->frags[tso_frag_index].size);
+					nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG0_LOW_IDX+(2*wqe_fragment_index)] =
+						cpu_to_le32((u32)((u64)tso_bus_address[tso_frag_index]));
+					nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG0_HIGH_IDX+(2*wqe_fragment_index)] =
+						cpu_to_le32((u32)(((u64)tso_bus_address[tso_frag_index])>>32));
+					wqe_fragment_index++;
+					tso_wqe_length += skb_shinfo(skb)->frags[tso_frag_index++].size;
+					if (wqe_fragment_index < 5)
+						wqe_fragment_length[wqe_fragment_index] = 0;
+					if (tso_frag_index == tso_frag_count)
+						break;
+				}
+				if ((wqe_count+1) == (u32)wqes_needed) {
+					nesnic->tx_skb[nesnic->sq_head] = skb;
+				} else {
+					nesnic->tx_skb[nesnic->sq_head] = NULL;
+				}
+				wqe_misc |= NES_NIC_SQ_WQE_COMPLETION | (u16)nes_skb_is_gso(skb);
+				if ((tso_wqe_length + skb_headlen(skb)) > nes_skb_is_gso(skb)) {
+					wqe_misc |= NES_NIC_SQ_WQE_LSO_ENABLE;
+				} else {
+					iph->tot_len = htons(tso_wqe_length + skb_headlen(skb) - nhoffset);
+				}
+
+				nic_sqe->wqe_words[NES_NIC_SQ_WQE_MISC_IDX] = cpu_to_le32(wqe_misc);
+				nic_sqe->wqe_words[NES_NIC_SQ_WQE_LSO_INFO_IDX] =
+						cpu_to_le32(((u32)tcph->doff) | (((u32)hoffset) << 4));
+
+				nic_sqe->wqe_words[NES_NIC_SQ_WQE_TOTAL_LENGTH_IDX] =
+						cpu_to_le32(tso_wqe_length+skb_headlen(skb));
+				curr_tcp_seq += tso_wqe_length;
+				nesnic->sq_head++;
+				nesnic->sq_head &= nesnic->sq_size-1;
+			}
+		} else {
+#endif
+			nesvnic->linearized_skbs++;
+#ifdef OFED_1_2
+			hoffset = skb->h.raw - skb->data;
+			nhoffset = skb->nh.raw - skb->data;
+#else
+			hoffset = skb_transport_header(skb) - skb->data;
+			nhoffset = skb_network_header(skb) - skb->data;
+#endif
+			nes_skb_linearize(skb);
+#ifdef OFED_1_2
+			skb->h.raw = skb->data + hoffset;
+			skb->nh.raw = skb->data + nhoffset;
+#else
+			skb_set_transport_header(skb, hoffset);
+			skb_set_network_header(skb, nhoffset);
+#endif
+			send_rc = nes_nic_send(skb, netdev);
+			if (send_rc != NETDEV_TX_OK) {
+				spin_unlock_irqrestore(&nesnic->sq_lock, flags);
+				return NETDEV_TX_OK;
+			}
+#ifdef NETIF_F_TSO
+		}
+#endif
+	} else {
+		send_rc = nes_nic_send(skb, netdev);
+		if (send_rc != NETDEV_TX_OK) {
+			spin_unlock_irqrestore(&nesnic->sq_lock, flags);
+			return NETDEV_TX_OK;
+		}
+	}
+
+	barrier();
+
+	if (wqe_count)
+		nes_write32(nesdev->regs+NES_WQE_ALLOC,
+				(wqe_count << 24) | (1 << 23) | nesvnic->nic.qp_id);
+
+	netdev->trans_start = jiffies;
+	spin_unlock_irqrestore(&nesnic->sq_lock, flags);
+
+	return NETDEV_TX_OK;
+}
+
+
+/**
+ * nes_netdev_get_stats
+ */
+static struct net_device_stats *nes_netdev_get_stats(struct net_device *netdev)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	u64 u64temp;
+	u32 u32temp;
+
+	u32temp = nes_read_indexed(nesdev,
+			NES_IDX_ENDNODE0_NSTAT_RX_DISCARD + (nesvnic->nic_index*0x200));
+	nesvnic->netstats.rx_dropped += u32temp;
+	nesvnic->endnode_nstat_rx_discard += u32temp;
+
+	u64temp = (u64)nes_read_indexed(nesdev,
+			NES_IDX_ENDNODE0_NSTAT_RX_OCTETS_LO + (nesvnic->nic_index*0x200));
+	u64temp += ((u64)nes_read_indexed(nesdev,
+			NES_IDX_ENDNODE0_NSTAT_RX_OCTETS_HI + (nesvnic->nic_index*0x200))) << 32;
+
+	nesvnic->endnode_nstat_rx_octets += u64temp;
+	nesvnic->netstats.rx_bytes += u64temp;
+
+	u64temp = (u64)nes_read_indexed(nesdev,
+			NES_IDX_ENDNODE0_NSTAT_RX_FRAMES_LO + (nesvnic->nic_index*0x200));
+	u64temp += ((u64)nes_read_indexed(nesdev,
+			NES_IDX_ENDNODE0_NSTAT_RX_FRAMES_HI + (nesvnic->nic_index*0x200))) << 32;
+
+	nesvnic->endnode_nstat_rx_frames += u64temp;
+	nesvnic->netstats.rx_packets += u64temp;
+
+	u64temp = (u64)nes_read_indexed(nesdev,
+			NES_IDX_ENDNODE0_NSTAT_TX_OCTETS_LO + (nesvnic->nic_index*0x200));
+	u64temp += ((u64)nes_read_indexed(nesdev,
+			NES_IDX_ENDNODE0_NSTAT_TX_OCTETS_HI + (nesvnic->nic_index*0x200))) << 32;
+
+	nesvnic->endnode_nstat_tx_octets += u64temp;
+	nesvnic->netstats.tx_bytes += u64temp;
+
+	u64temp = (u64)nes_read_indexed(nesdev,
+			NES_IDX_ENDNODE0_NSTAT_TX_FRAMES_LO + (nesvnic->nic_index*0x200));
+	u64temp += ((u64)nes_read_indexed(nesdev,
+			NES_IDX_ENDNODE0_NSTAT_TX_FRAMES_HI + (nesvnic->nic_index*0x200))) << 32;
+
+	nesvnic->endnode_nstat_tx_frames += u64temp;
+	nesvnic->netstats.tx_packets += u64temp;
+
+	u32temp = nes_read_indexed(nesdev,
+			NES_IDX_MAC_RX_SHORT_FRAMES + (nesvnic->nesdev->mac_index*0x200));
+	nesvnic->netstats.rx_dropped += u32temp;
+	nesvnic->nesdev->mac_rx_errors += u32temp;
+	nesvnic->nesdev->mac_rx_short_frames += u32temp;
+
+	u32temp = nes_read_indexed(nesdev,
+			NES_IDX_MAC_RX_OVERSIZED_FRAMES + (nesvnic->nesdev->mac_index*0x200));
+	nesvnic->netstats.rx_dropped += u32temp;
+	nesvnic->nesdev->mac_rx_errors += u32temp;
+	nesvnic->nesdev->mac_rx_oversized_frames += u32temp;
+
+	u32temp = nes_read_indexed(nesdev,
+			NES_IDX_MAC_RX_JABBER_FRAMES + (nesvnic->nesdev->mac_index*0x200));
+	nesvnic->netstats.rx_dropped += u32temp;
+	nesvnic->nesdev->mac_rx_errors += u32temp;
+	nesvnic->nesdev->mac_rx_jabber_frames += u32temp;
+
+	u32temp = nes_read_indexed(nesdev,
+			NES_IDX_MAC_RX_SYMBOL_ERR_FRAMES + (nesvnic->nesdev->mac_index*0x200));
+	nesvnic->netstats.rx_dropped += u32temp;
+	nesvnic->nesdev->mac_rx_errors += u32temp;
+	nesvnic->nesdev->mac_rx_symbol_err_frames += u32temp;
+
+	u32temp = nes_read_indexed(nesdev,
+			NES_IDX_MAC_RX_LENGTH_ERR_FRAMES + (nesvnic->nesdev->mac_index*0x200));
+	nesvnic->netstats.rx_length_errors += u32temp;
+	nesvnic->nesdev->mac_rx_errors += u32temp;
+
+	u32temp = nes_read_indexed(nesdev,
+			NES_IDX_MAC_RX_CRC_ERR_FRAMES + (nesvnic->nesdev->mac_index*0x200));
+	nesvnic->nesdev->mac_rx_errors += u32temp;
+	nesvnic->nesdev->mac_rx_crc_errors += u32temp;
+	nesvnic->netstats.rx_crc_errors += u32temp;
+
+	u32temp = nes_read_indexed(nesdev,
+			NES_IDX_MAC_TX_ERRORS + (nesvnic->nesdev->mac_index*0x200));
+	nesvnic->nesdev->mac_tx_errors += u32temp;
+	nesvnic->netstats.tx_errors += u32temp;
+
+	return &nesvnic->netstats;
+}
+
+
+/**
+ * nes_netdev_tx_timeout
+ */
+static void nes_netdev_tx_timeout(struct net_device *netdev)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+
+	if (netif_msg_timer(nesvnic))
+		nes_debug(NES_DBG_NIC_TX, "%s: tx timeout\n", netdev->name);
+}
+
+
+/**
+ * nes_netdev_set_mac_address
+ */
+static int nes_netdev_set_mac_address(struct net_device *netdev, void *p)
+{
+	return -1;
+}
+
+
+/**
+ * nes_netdev_change_mtu
+ */
+static int nes_netdev_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	int ret = 0;
+
+	if ((new_mtu < ETH_ZLEN) || (new_mtu > max_mtu))
+		return -EINVAL;
+
+	netdev->mtu = new_mtu;
+	nesvnic->max_frame_size = new_mtu+ETH_HLEN;
+
+	if (netif_running(netdev)) {
+		nes_netdev_stop(netdev);
+		nes_netdev_open(netdev);
+	}
+
+	return ret;
+}
+
+
+/**
+ * nes_netdev_exit - destroy network device
+ */
+void nes_netdev_exit(struct nes_vnic *nesvnic)
+{
+	struct net_device *netdev = nesvnic->netdev;
+	struct nes_ib_device *nesibdev = nesvnic->nesibdev;
+
+	nes_debug(NES_DBG_SHUTDOWN, "\n");
+
+	// destroy the ibdevice if RDMA enabled
+	if ((nesvnic->rdma_enabled)&&(nesvnic->of_device_registered)) {
+		nes_destroy_ofa_device( nesibdev );
+		nesvnic->of_device_registered = 0;
+		rdma_enabled = 0;
+		nesvnic->nesibdev = NULL;
+	}
+	unregister_netdev(netdev);
+	nes_debug(NES_DBG_SHUTDOWN, "\n");
+}
+
+
+#define NES_ETHTOOL_STAT_COUNT 52
+static const char nes_ethtool_stringset[NES_ETHTOOL_STAT_COUNT][ETH_GSTRING_LEN] = {
+	"Link Change Interrupts",
+	"Linearized SKBs",
+	"T/GSO Requests",
+	"Pause Frames Sent",
+	"Pause Frames Received",
+	"Internal Routing Errors",
+	"SQ SW Dropped SKBs",
+	"SQ Locked",
+	"SQ Full",
+	"Segmented TSO Requests",
+	"Rx Symbol Errors",
+	"Rx Jabber Errors",
+	"Rx Oversized Frames",
+	"Rx Short Frames",
+	"Endnode Rx Discards",
+	"Endnode Rx Octets",
+	"Endnode Rx Frames",
+	"Endnode Tx Octets",
+	"Endnode Tx Frames",
+	"mh detected",
+	"mh pauses",
+	"Retransmission Count",
+	"CM Connects",
+	"CM Accepts",
+	"Disconnects",
+	"Connected Events",
+	"Connect Requests",
+	"CM Rejects",
+	"ModifyQP Timeouts",
+	"CreateQPs",
+	"SW DestroyQPs",
+	"DestroyQPs",
+	"CM Closes",
+	"CM Packets Sent",
+	"CM Packets Bounced",
+	"CM Packets Created",
+	"CM Packets Rcvd",
+	"CM Packets Dropped",
+	"CM Packets Retrans",
+	"CM Listens Created",
+	"CM Listens Destroyed",
+	"CM Backlog Drops",
+	"CM Nodes Created",
+	"CM Nodes Destroyed",
+	"CM Accel Drops",
+	"CM Resets Received",
+	"CQP Req Allocs",
+	"CQP Req Deallocs",
+	"CQP Req Dynamic Allocs",
+	"CQP Req Dynamic Deallocs",
+	"CQP Req Queues",
+	"CQP Req Redrives",
+};
+
+
+/**
+ * nes_netdev_get_rx_csum
+ */
+static u32 nes_netdev_get_rx_csum (struct net_device *netdev)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+
+	if (nesvnic->rx_checksum_disabled)
+		return 0;
+	else
+		return 1;
+}
+
+
+/**
+ * nes_netdev_set_rc_csum
+ */
+static int nes_netdev_set_rx_csum(struct net_device *netdev, u32 enable)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+
+	if (enable)
+		nesvnic->rx_checksum_disabled = 0;
+	else
+		nesvnic->rx_checksum_disabled = 1;
+	return 0;
+}
+
+
+/**
+ * nes_netdev_get_stats_count
+ */
+static int nes_netdev_get_stats_count(struct net_device *netdev)
+{
+	return NES_ETHTOOL_STAT_COUNT;
+}
+
+
+/**
+ * nes_netdev_get_strings
+ */
+static void nes_netdev_get_strings(struct net_device *netdev, u32 stringset,
+		u8 *ethtool_strings)
+{
+	if (stringset == ETH_SS_STATS)
+		memcpy(ethtool_strings,
+				&nes_ethtool_stringset,
+				sizeof(nes_ethtool_stringset));
+}
+
+
+/**
+ * nes_netdev_get_ethtool_stats
+ */
+static void nes_netdev_get_ethtool_stats(struct net_device *netdev,
+		struct ethtool_stats *target_ethtool_stats, u64 *target_stat_values)
+{
+	u64 u64temp;
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	u32 nic_count;
+	u32 u32temp;
+
+	target_ethtool_stats->n_stats = NES_ETHTOOL_STAT_COUNT;
+	target_stat_values[0] = nesvnic->nesdev->link_status_interrupts;
+	target_stat_values[1] = nesvnic->linearized_skbs;
+	target_stat_values[2] = nesvnic->tso_requests;
+
+	u32temp = nes_read_indexed(nesdev,
+			NES_IDX_MAC_TX_PAUSE_FRAMES + (nesvnic->nesdev->mac_index*0x200));
+	nesvnic->nesdev->mac_pause_frames_sent += u32temp;
+	target_stat_values[3] = nesvnic->nesdev->mac_pause_frames_sent;
+
+	u32temp = nes_read_indexed(nesdev,
+			NES_IDX_MAC_RX_PAUSE_FRAMES + (nesvnic->nesdev->mac_index*0x200));
+	nesvnic->nesdev->mac_pause_frames_received += u32temp;
+
+	for (nic_count = 0; nic_count < NES_MAX_PORT_COUNT; nic_count++) {
+		if (nesvnic->qp_nic_index[nic_count] == 0xf)
+			break;
+
+		u32temp = nes_read_indexed(nesdev,
+				NES_IDX_ENDNODE0_NSTAT_RX_DISCARD +
+				(nesvnic->qp_nic_index[nic_count]*0x200));
+		nesvnic->netstats.rx_dropped += u32temp;
+		nesvnic->endnode_nstat_rx_discard += u32temp;
+
+		u64temp = (u64)nes_read_indexed(nesdev,
+				NES_IDX_ENDNODE0_NSTAT_RX_OCTETS_LO +
+				(nesvnic->qp_nic_index[nic_count]*0x200));
+		u64temp += ((u64)nes_read_indexed(nesdev,
+				NES_IDX_ENDNODE0_NSTAT_RX_OCTETS_HI +
+				(nesvnic->qp_nic_index[nic_count]*0x200))) << 32;
+
+		nesvnic->endnode_nstat_rx_octets += u64temp;
+		nesvnic->netstats.rx_bytes += u64temp;
+
+		u64temp = (u64)nes_read_indexed(nesdev,
+				NES_IDX_ENDNODE0_NSTAT_RX_FRAMES_LO +
+				(nesvnic->qp_nic_index[nic_count]*0x200));
+		u64temp += ((u64)nes_read_indexed(nesdev,
+				NES_IDX_ENDNODE0_NSTAT_RX_FRAMES_HI +
+				(nesvnic->qp_nic_index[nic_count]*0x200))) << 32;
+
+		nesvnic->endnode_nstat_rx_frames += u64temp;
+		nesvnic->netstats.rx_packets += u64temp;
+
+		u64temp = (u64)nes_read_indexed(nesdev,
+				NES_IDX_ENDNODE0_NSTAT_TX_OCTETS_LO +
+				(nesvnic->qp_nic_index[nic_count]*0x200));
+		u64temp += ((u64)nes_read_indexed(nesdev,
+				NES_IDX_ENDNODE0_NSTAT_TX_OCTETS_HI +
+				(nesvnic->qp_nic_index[nic_count]*0x200))) << 32;
+
+		nesvnic->endnode_nstat_tx_octets += u64temp;
+		nesvnic->netstats.tx_bytes += u64temp;
+
+		u64temp = (u64)nes_read_indexed(nesdev,
+				NES_IDX_ENDNODE0_NSTAT_TX_FRAMES_LO +
+				(nesvnic->qp_nic_index[nic_count]*0x200));
+		u64temp += ((u64)nes_read_indexed(nesdev,
+				NES_IDX_ENDNODE0_NSTAT_TX_FRAMES_HI +
+				(nesvnic->qp_nic_index[nic_count]*0x200))) << 32;
+
+		nesvnic->endnode_nstat_tx_frames += u64temp;
+		nesvnic->netstats.tx_packets += u64temp;
+
+		u32temp = nes_read_indexed(nesdev,
+				NES_IDX_IPV4_TCP_REXMITS + (nesvnic->qp_nic_index[nic_count]*0x200));
+		nesvnic->endnode_ipv4_tcp_retransmits += u32temp;
+	}
+
+	target_stat_values[4] = nesvnic->nesdev->mac_pause_frames_received;
+	target_stat_values[5] = nesdev->nesadapter->nic_rx_eth_route_err;
+	target_stat_values[6] = nesvnic->tx_sw_dropped;
+	target_stat_values[7] = nesvnic->sq_locked;
+	target_stat_values[8] = nesvnic->sq_full;
+	target_stat_values[9] = nesvnic->segmented_tso_requests;
+	target_stat_values[10] = nesvnic->nesdev->mac_rx_symbol_err_frames;
+	target_stat_values[11] = nesvnic->nesdev->mac_rx_jabber_frames;
+	target_stat_values[12] = nesvnic->nesdev->mac_rx_oversized_frames;
+	target_stat_values[13] = nesvnic->nesdev->mac_rx_short_frames;
+	target_stat_values[14] = nesvnic->endnode_nstat_rx_discard;
+	target_stat_values[15] = nesvnic->endnode_nstat_rx_octets;
+	target_stat_values[16] = nesvnic->endnode_nstat_rx_frames;
+	target_stat_values[17] = nesvnic->endnode_nstat_tx_octets;
+	target_stat_values[18] = nesvnic->endnode_nstat_tx_frames;
+	target_stat_values[19] = mh_detected;
+	target_stat_values[20] = mh_pauses_sent;
+	target_stat_values[21] = nesvnic->endnode_ipv4_tcp_retransmits;
+	target_stat_values[22] = atomic_read(&cm_connects);
+	target_stat_values[23] = atomic_read(&cm_accepts);
+	target_stat_values[24] = atomic_read(&cm_disconnects);
+	target_stat_values[25] = atomic_read(&cm_connecteds);
+	target_stat_values[26] = atomic_read(&cm_connect_reqs);
+	target_stat_values[27] = atomic_read(&cm_rejects);
+	target_stat_values[28] = atomic_read(&mod_qp_timouts);
+	target_stat_values[29] = atomic_read(&qps_created);
+	target_stat_values[30] = atomic_read(&sw_qps_destroyed);
+	target_stat_values[31] = atomic_read(&qps_destroyed);
+	target_stat_values[32] = atomic_read(&cm_closes);
+	target_stat_values[33] = cm_packets_sent;
+	target_stat_values[34] = cm_packets_bounced;
+	target_stat_values[35] = cm_packets_created;
+	target_stat_values[36] = cm_packets_received;
+	target_stat_values[37] = cm_packets_dropped;
+	target_stat_values[38] = cm_packets_retrans;
+	target_stat_values[39] = cm_listens_created;
+	target_stat_values[40] = cm_listens_destroyed;
+	target_stat_values[41] = cm_backlog_drops;
+	target_stat_values[42] = atomic_read(&cm_nodes_created);
+	target_stat_values[43] = atomic_read(&cm_nodes_destroyed);
+	target_stat_values[44] = atomic_read(&cm_accel_dropped_pkts);
+	target_stat_values[45] = atomic_read(&cm_resets_recvd);
+	target_stat_values[46] = atomic_read(&cqp_reqs_allocated);
+	target_stat_values[47] = atomic_read(&cqp_reqs_freed);
+	target_stat_values[48] = atomic_read(&cqp_reqs_dynallocated);
+	target_stat_values[49] = atomic_read(&cqp_reqs_dynfreed);
+	target_stat_values[50] = atomic_read(&cqp_reqs_queued);
+	target_stat_values[51] = atomic_read(&cqp_reqs_redriven);
+
+}
+
+
+/**
+ * nes_netdev_get_drvinfo
+ */
+static void nes_netdev_get_drvinfo(struct net_device *netdev,
+		struct ethtool_drvinfo *drvinfo)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+
+	strcpy(drvinfo->driver, DRV_NAME);
+	strcpy(drvinfo->bus_info, pci_name(nesvnic->nesdev->pcidev));
+	strcpy(drvinfo->fw_version, "TBD");
+	strcpy(drvinfo->version, DRV_VERSION);
+	drvinfo->n_stats = nes_netdev_get_stats_count(netdev);
+	drvinfo->testinfo_len = 0;
+	drvinfo->eedump_len = 0;
+	drvinfo->regdump_len = 0;
+}
+
+
+/**
+ * nes_netdev_set_coalesce
+ */
+static int nes_netdev_set_coalesce(struct net_device *netdev,
+		struct ethtool_coalesce *et_coalesce)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+
+	/* using this to drive total interrupt moderation */
+	nesvnic->nesdev->et_rx_coalesce_usecs_irq = et_coalesce->rx_coalesce_usecs_irq;
+	if (nesdev->et_rx_coalesce_usecs_irq) {
+		nes_write32(nesdev->regs+NES_PERIODIC_CONTROL,
+				0x80000000 | ((u32)(nesdev->et_rx_coalesce_usecs_irq*8)));
+	}
+	return 0;
+}
+
+
+/**
+ * nes_netdev_get_coalesce
+ */
+static int nes_netdev_get_coalesce(struct net_device *netdev,
+		struct ethtool_coalesce *et_coalesce)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct ethtool_coalesce temp_et_coalesce;
+
+	memset(&temp_et_coalesce, 0, sizeof(temp_et_coalesce));
+	temp_et_coalesce.rx_coalesce_usecs_irq = nesvnic->nesdev->et_rx_coalesce_usecs_irq;
+	memcpy(et_coalesce, &temp_et_coalesce, sizeof(*et_coalesce));
+	return 0;
+}
+
+
+/**
+ * nes_netdev_get_pauseparam
+ */
+static void nes_netdev_get_pauseparam(struct net_device *netdev,
+		struct ethtool_pauseparam *et_pauseparam)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+
+	et_pauseparam->autoneg = 0;
+	et_pauseparam->rx_pause = (nesvnic->nesdev->disable_rx_flow_control==0)?1:0;
+	et_pauseparam->tx_pause = (nesvnic->nesdev->disable_tx_flow_control==0)?1:0;
+}
+
+
+/**
+ * nes_netdev_set_pauseparam
+ */
+static int nes_netdev_set_pauseparam(struct net_device *netdev,
+		struct ethtool_pauseparam *et_pauseparam)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	u32 u32temp;
+
+	if (et_pauseparam->autoneg) {
+		/* TODO: should return unsupported */
+		return 0;
+	}
+	if ((et_pauseparam->tx_pause==1) && (nesdev->disable_tx_flow_control==1)) {
+		u32temp = nes_read_indexed(nesdev,
+				NES_IDX_MAC_TX_CONFIG + (nesdev->mac_index*0x200));
+		u32temp |= NES_IDX_MAC_TX_CONFIG_ENABLE_PAUSE;
+		nes_write_indexed(nesdev,
+				NES_IDX_MAC_TX_CONFIG_ENABLE_PAUSE + (nesdev->mac_index*0x200), u32temp);
+		nesdev->disable_tx_flow_control = 0;
+	} else if ((et_pauseparam->tx_pause==0) && (nesdev->disable_tx_flow_control==0)) {
+		u32temp = nes_read_indexed(nesdev,
+				NES_IDX_MAC_TX_CONFIG + (nesdev->mac_index*0x200));
+		u32temp &= ~NES_IDX_MAC_TX_CONFIG_ENABLE_PAUSE;
+		nes_write_indexed(nesdev,
+				NES_IDX_MAC_TX_CONFIG_ENABLE_PAUSE + (nesdev->mac_index*0x200), u32temp);
+		nesdev->disable_tx_flow_control = 1;
+	}
+	if ((et_pauseparam->rx_pause==1) && (nesdev->disable_rx_flow_control==1)) {
+		u32temp = nes_read_indexed(nesdev,
+				NES_IDX_MPP_DEBUG + (nesdev->mac_index*0x40));
+		u32temp &= ~NES_IDX_MPP_DEBUG_PORT_DISABLE_PAUSE;
+		nes_write_indexed(nesdev,
+				NES_IDX_MPP_DEBUG + (nesdev->mac_index*0x40), u32temp);
+		nesdev->disable_rx_flow_control = 0;
+	} else if ((et_pauseparam->rx_pause==0) && (nesdev->disable_rx_flow_control==0)) {
+		u32temp = nes_read_indexed(nesdev,
+				NES_IDX_MPP_DEBUG + (nesdev->mac_index*0x40));
+		u32temp |= NES_IDX_MPP_DEBUG_PORT_DISABLE_PAUSE;
+		nes_write_indexed(nesdev,
+				NES_IDX_MPP_DEBUG + (nesdev->mac_index*0x40), u32temp);
+		nesdev->disable_rx_flow_control = 1;
+	}
+
+	return 0;
+}
+
+
+/**
+ * nes_netdev_get_settings
+ */
+static int nes_netdev_get_settings(struct net_device *netdev, struct ethtool_cmd *et_cmd)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	u16 phy_data;
+
+	et_cmd->duplex = DUPLEX_FULL;
+	if (nesadapter->OneG_Mode) {
+		et_cmd->supported = SUPPORTED_1000baseT_Full|SUPPORTED_Autoneg;
+		et_cmd->advertising = ADVERTISED_1000baseT_Full|ADVERTISED_Autoneg;
+		et_cmd->speed = SPEED_1000;
+		nes_read_1G_phy_reg(nesdev, 0, nesadapter->phy_index[nesdev->mac_index],
+				&phy_data);
+		if (phy_data&0x1000) {
+			et_cmd->autoneg = AUTONEG_ENABLE;
+		} else {
+			et_cmd->autoneg = AUTONEG_DISABLE;
+		}
+		et_cmd->transceiver = XCVR_EXTERNAL;
+		et_cmd->phy_address = nesadapter->phy_index[nesdev->mac_index];
+	} else {
+		et_cmd->supported = SUPPORTED_10000baseT_Full;
+		et_cmd->advertising = ADVERTISED_10000baseT_Full;
+		et_cmd->speed = SPEED_10000;
+		et_cmd->autoneg = AUTONEG_DISABLE;
+		et_cmd->transceiver = XCVR_INTERNAL;
+		et_cmd->phy_address = nesdev->mac_index;
+	}
+	et_cmd->port = PORT_MII;
+	et_cmd->maxtxpkt = 511;
+	et_cmd->maxrxpkt = 511;
+	return 0;
+}
+
+
+/**
+ * nes_netdev_set_settings
+ */
+static int nes_netdev_set_settings(struct net_device *netdev, struct ethtool_cmd *et_cmd)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	u16 phy_data;
+
+	if (nesadapter->OneG_Mode) {
+		nes_read_1G_phy_reg(nesdev, 0, nesadapter->phy_index[nesdev->mac_index],
+				&phy_data);
+		if (et_cmd->autoneg) {
+			/* Turn on Full duplex, Autoneg, and restart autonegotiation */
+			phy_data |= 0x1300;
+		} else {
+			// Turn off autoneg
+			phy_data &= ~0x1000;
+		}
+		nes_write_1G_phy_reg(nesdev, 0, nesadapter->phy_index[nesdev->mac_index],
+				phy_data);
+	}
+
+	return 0;
+}
+
+
+/**
+ * nes_netdev_get_msglevel
+ */
+static u32 nes_netdev_get_msglevel(struct net_device *netdev)
+{
+	return nes_debug_level;
+}
+
+
+/**
+ * nes_netdev_set_msglevel
+ */
+static void nes_netdev_set_msglevel(struct net_device *netdev, u32 level)
+{
+	nes_debug(NES_DBG_NETDEV, "Setting message level to: %u\n", level);
+	nes_debug_level = level;
+}
+
+
+static struct ethtool_ops nes_ethtool_ops = {
+	.get_link = ethtool_op_get_link,
+	.get_settings = nes_netdev_get_settings,
+	.set_settings = nes_netdev_set_settings,
+	.get_tx_csum = ethtool_op_get_tx_csum,
+	.get_rx_csum = nes_netdev_get_rx_csum,
+	.get_sg = ethtool_op_get_sg,
+	.get_strings = nes_netdev_get_strings,
+	.get_stats_count = nes_netdev_get_stats_count,
+	.get_ethtool_stats = nes_netdev_get_ethtool_stats,
+	.get_drvinfo = nes_netdev_get_drvinfo,
+	.get_coalesce = nes_netdev_get_coalesce,
+	.set_coalesce = nes_netdev_set_coalesce,
+	.get_pauseparam = nes_netdev_get_pauseparam,
+	.set_pauseparam = nes_netdev_set_pauseparam,
+	.get_msglevel = nes_netdev_get_msglevel,
+	.set_msglevel = nes_netdev_set_msglevel,
+	.set_tx_csum = ethtool_op_set_tx_csum,
+	.set_rx_csum = nes_netdev_set_rx_csum,
+	.set_sg = ethtool_op_set_sg,
+#ifdef NETIF_F_TSO
+	.get_tso = ethtool_op_get_tso,
+	.set_tso = ethtool_op_set_tso,
+#endif
+};
+
+
+#ifdef NETIF_F_HW_VLAN_TX
+static void nes_netdev_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	u32 u32temp;
+
+	nesvnic->vlan_grp = grp;
+
+	/* Enable/Disable VLAN Stripping */
+	u32temp = nes_read_indexed(nesdev, NES_IDX_PCIX_DIAG);
+	if (grp)
+		u32temp &= 0xfdffffff;
+	else
+		u32temp	|= 0x02000000;
+
+	nes_write_indexed(nesdev, NES_IDX_PCIX_DIAG, u32temp);
+}
+#endif
+
+
+/**
+ * nes_netdev_init - initialize network device
+ */
+struct net_device *nes_netdev_init(struct nes_device *nesdev,
+		void __iomem *mmio_addr)
+{
+	u64 u64temp;
+	struct nes_vnic *nesvnic = NULL;
+	struct net_device *netdev;
+	struct nic_qp_map *curr_qp_map;
+	u32 u32temp;
+
+	netdev = alloc_etherdev(sizeof(struct nes_vnic));
+	if (!netdev) {
+		printk(KERN_ERR PFX "nesvnic etherdev alloc failed");
+		return NULL;
+	}
+
+	nes_debug(NES_DBG_INIT, "netdev = %p.\n", netdev);
+
+	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &nesdev->pcidev->dev);
+
+	netdev->open = nes_netdev_open;
+	netdev->stop = nes_netdev_stop;
+	netdev->hard_start_xmit = nes_netdev_start_xmit;
+	netdev->get_stats = nes_netdev_get_stats;
+	netdev->tx_timeout = nes_netdev_tx_timeout;
+	netdev->set_mac_address = nes_netdev_set_mac_address;
+	netdev->change_mtu = nes_netdev_change_mtu;
+	netdev->watchdog_timeo = NES_TX_TIMEOUT;
+	netdev->irq = nesdev->pcidev->irq;
+	netdev->mtu = ETH_DATA_LEN;
+	netdev->hard_header_len = ETH_HLEN;
+	netdev->addr_len = ETH_ALEN;
+	netdev->type = ARPHRD_ETHER;
+	netdev->features = NETIF_F_HIGHDMA;
+	netdev->ethtool_ops = &nes_ethtool_ops;
+#ifdef NES_NAPI
+	netdev->poll = nes_netdev_poll;
+	netdev->weight = 128;
+#endif
+#ifdef NETIF_F_HW_VLAN_TX
+	nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.\n");
+	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	netdev->vlan_rx_register = nes_netdev_vlan_rx_register;
+#endif
+#ifdef NETIF_F_LLTX
+	netdev->features |= NETIF_F_LLTX;
+#endif
+
+	/* Fill in the port structure */
+	nesvnic = netdev_priv(netdev);
+
+	memset(nesvnic, 0, sizeof(*nesvnic));
+	nesvnic->netdev = netdev;
+	nesvnic->nesdev = nesdev;
+	nesvnic->msg_enable = netif_msg_init(debug, default_msg);
+	nesvnic->netdev_index = nesdev->netdev_count;
+	nesvnic->perfect_filter_index = nesdev->nesadapter->netdev_count;
+	nesvnic->max_frame_size = netdev->mtu+netdev->hard_header_len;
+
+	curr_qp_map = nic_qp_mapping_per_function[PCI_FUNC(nesdev->pcidev->devfn)];
+	nesvnic->nic.qp_id = curr_qp_map[nesdev->netdev_count].qpid;
+	nesvnic->nic_index = curr_qp_map[nesdev->netdev_count].nic_index;
+	nesvnic->logical_port = curr_qp_map[nesdev->netdev_count].logical_port;
+
+	/* Setup the burned in MAC address */
+	u64temp = (u64)nesdev->nesadapter->mac_addr_low;
+	u64temp += ((u64)nesdev->nesadapter->mac_addr_high) << 32;
+	u64temp += nesvnic->nic_index;
+	netdev->dev_addr[0] = (u8)(u64temp>>40);
+	netdev->dev_addr[1] = (u8)(u64temp>>32);
+	netdev->dev_addr[2] = (u8)(u64temp>>24);
+	netdev->dev_addr[3] = (u8)(u64temp>>16);
+	netdev->dev_addr[4] = (u8)(u64temp>>8);
+	netdev->dev_addr[5] = (u8)u64temp;
+
+	if ((nesvnic->logical_port < 2) || (nesdev->nesadapter->hw_rev != NE020_REV)) {
+#ifdef NETIF_F_TSO
+		netdev->features |= NETIF_F_TSO | NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_IP_CSUM;
+#endif
+#ifdef NETIF_F_GSO
+		netdev->features |= NETIF_F_GSO | NETIF_F_TSO | NETIF_F_SG | NETIF_F_IP_CSUM;
+#endif
+	} else {
+		netdev->features |= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_IP_CSUM;
+	}
+
+	nes_debug(NES_DBG_INIT, "nesvnic = %p, reported features = 0x%lX, QPid = %d,"
+			" nic_index = %d, logical_port = %d, mac_index = %d.\n",
+			nesvnic, (unsigned long)netdev->features, nesvnic->nic.qp_id,
+			nesvnic->nic_index, nesvnic->logical_port,  nesdev->mac_index);
+
+	if (nesvnic->nesdev->nesadapter->port_count == 1) {
+		nesvnic->qp_nic_index[0] = nesvnic->nic_index;
+		nesvnic->qp_nic_index[1] = nesvnic->nic_index + 1;
+		if (nes_drv_opt & NES_DRV_OPT_DUAL_LOGICAL_PORT) {
+			nesvnic->qp_nic_index[2] = 0xf;
+			nesvnic->qp_nic_index[3] = 0xf;
+		} else {
+			nesvnic->qp_nic_index[2] = nesvnic->nic_index + 2;
+			nesvnic->qp_nic_index[3] = nesvnic->nic_index + 3;
+		}
+	} else {
+		if (nesvnic->nesdev->nesadapter->port_count == 2) {
+			nesvnic->qp_nic_index[0] = nesvnic->nic_index;
+			nesvnic->qp_nic_index[1] = nesvnic->nic_index + 2;
+			nesvnic->qp_nic_index[2] = 0xf;
+			nesvnic->qp_nic_index[3] = 0xf;
+		} else {
+			nesvnic->qp_nic_index[0] = nesvnic->nic_index;
+			nesvnic->qp_nic_index[1] = 0xf;
+			nesvnic->qp_nic_index[2] = 0xf;
+			nesvnic->qp_nic_index[3] = 0xf;
+		}
+	}
+	nesvnic->next_qp_nic_index = 0;
+
+	if (0 == nesdev->netdev_count) {
+		if (rdma_enabled == 0) {
+			rdma_enabled = 1;
+			nesvnic->rdma_enabled = 1;
+		}
+	} else {
+		nesvnic->rdma_enabled = 0;
+	}
+	nesvnic->nic_cq.cq_number = nesvnic->nic.qp_id;
+	spin_lock_init(&nesvnic->tx_lock);
+	nesdev->netdev[nesdev->netdev_count] = netdev;
+
+	nes_debug(NES_DBG_INIT, "Adding nesvnic (%p) to the adapters nesvnic_list for MAC%d.\n",
+			nesvnic, nesdev->mac_index);
+	list_add_tail(&nesvnic->list, &nesdev->nesadapter->nesvnic_list[nesdev->mac_index]);
+
+	if ((0 == nesdev->netdev_count) &&
+			(PCI_FUNC(nesdev->pcidev->devfn) == nesdev->mac_index)) {
+		nes_debug(NES_DBG_INIT, "Setting up PHY interrupt mask. Using register index 0x%04X\n",
+				NES_IDX_PHY_PCS_CONTROL_STATUS0+(0x200*(nesvnic->logical_port&1)));
+		u32temp = nes_read_indexed(nesdev, NES_IDX_PHY_PCS_CONTROL_STATUS0 +
+				(0x200*(nesvnic->logical_port&1)));
+		u32temp |= 0x00200000;
+		nes_write_indexed(nesdev, NES_IDX_PHY_PCS_CONTROL_STATUS0 +
+				(0x200*(nesvnic->logical_port&1)), u32temp);
+		u32temp = nes_read_indexed(nesdev, NES_IDX_PHY_PCS_CONTROL_STATUS0 +
+				(0x200*(nesvnic->logical_port&1)) );
+		if (0x0f0f0000 == (u32temp&0x0f1f0000)) {
+			nes_debug(NES_DBG_INIT, "The Link is UP!!.\n");
+			nesvnic->linkup = 1;
+		}
+		nes_debug(NES_DBG_INIT, "Setting up MAC interrupt mask.\n");
+		/* clear the MAC interrupt status, assumes direct logical to physical mapping */
+		u32temp = nes_read_indexed(nesdev, NES_IDX_MAC_INT_STATUS+(0x200*nesvnic->logical_port));
+		nes_debug(NES_DBG_INIT, "Phy interrupt status = 0x%X.\n", u32temp);
+		nes_write_indexed(nesdev, NES_IDX_MAC_INT_STATUS+(0x200*nesvnic->logical_port), u32temp);
+
+		nes_init_phy(nesdev);
+		nes_write_indexed(nesdev, NES_IDX_MAC_INT_MASK+(0x200*nesvnic->logical_port),
+				~(NES_MAC_INT_LINK_STAT_CHG | NES_MAC_INT_XGMII_EXT |
+				NES_MAC_INT_TX_UNDERFLOW | NES_MAC_INT_TX_ERROR));
+	}
+
+	return netdev;
+}
+
+
+/**
+ * nes_netdev_destroy - destroy network device structure
+ */
+void nes_netdev_destroy(struct net_device *netdev)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+
+	/* make sure 'stop' method is called by Linux stack */
+	/* nes_netdev_stop(netdev); */
+
+	list_del(&nesvnic->list);
+
+	if (nesvnic->of_device_registered) {
+		nes_destroy_ofa_device(nesvnic->nesibdev);
+	}
+
+	free_netdev(netdev);
+}
+
+
+/**
+ * nes_nic_cm_xmit -- CM calls this to send out pkts
+ */
+int nes_nic_cm_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	int ret;
+
+	skb->dev = netdev;
+	ret = dev_queue_xmit(skb);
+	if (ret) {
+		nes_debug(NES_DBG_CM, "Bad return code from dev_queue_xmit %d\n", ret);
+	}
+
+	return ret;
+}
+

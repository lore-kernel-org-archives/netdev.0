From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: [PATCH 6/9] NetEffect 10Gb RNIC Driver: kernel network interface c file
Date: Thu, 26 Oct 2006 19:17:21 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EBE@venom2>
Reply-To: <glenng@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:9695 "EHLO
	mail2.neteffect.com") by vger.kernel.org with ESMTP
	id S1946051AbWJ0ARW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 20:17:22 -0400
Content-class: urn:content-classes:message
To: <openib-general@openib.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel driver patch 6 of 9.

Signed-off-by: Glenn Grundstrom <glenng@neteffect.com>

======================================================

diff -ruNp old/drivers/infiniband/hw/nes/nes_nic.c
new/drivers/infiniband/hw/nes/nes_nic.c
--- old/drivers/infiniband/hw/nes/nes_nic.c	1969-12-31
18:00:00.000000000 -0600
+++ new/drivers/infiniband/hw/nes/nes_nic.c	2006-10-25
10:15:50.000000000 -0500
@@ -0,0 +1,567 @@
+/*
+ * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
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
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/if_arp.h>
+
+#include "nes.h"
+
+static const u32 default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
NETIF_MSG_LINK
+							   |
NETIF_MSG_IFUP | NETIF_MSG_IFDOWN;
+static int debug = -1;
+
+static int nes_netdev_open(struct net_device *);
+static int nes_netdev_stop(struct net_device *);
+static int nes_netdev_start_xmit(struct sk_buff *, struct net_device
*);
+static struct net_device_stats *nes_netdev_get_stats(struct net_device
*);
+static void nes_netdev_tx_timeout(struct net_device *);
+static int nes_netdev_set_mac_address(struct net_device *, void *);
+static int nes_netdev_change_mtu(struct net_device *, int);
+
+
+/**
+ * nes_netdev_open
+ * 
+ * @param netdev
+ * 
+ * @return int
+ */
+static int nes_netdev_open(struct net_device *netdev)
+{
+	struct nes_port *nes_port = netdev_priv(netdev);
+	struct nes_dev *nesdev = nes_port->nesdev;
+	u32 u32temp;
+	u32 nic_active_bit;
+	u32 nic_active;
+	u16 link_up = 0;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	assert(nesdev != NULL);
+
+	if (netif_msg_ifup(nes_port))
+		dprintk(KERN_INFO PFX "%s: enabling interface\n",
netdev->name);
+
+	/* clear the MAC interrupt status */
+	u32temp = nes_read_indexed(nesdev->index_reg,
NES_IDX_MAC_INT_STATUS );
+	dprintk("Phy interrupt status = 0x%X.\n", u32temp);
+	nes_write_indexed(nesdev->index_reg, NES_IDX_MAC_INT_STATUS,
u32temp);
+
+	nes_phy_init(nesdev);
+
+	nes_nic_qp_init(nesdev, netdev);
+
+	// Set packet filters
+	nic_active_bit = 1<<PCI_FUNC(nesdev->pcidev->devfn);
+	nic_active = nes_read_indexed(nesdev->index_reg,
NES_IDX_NIC_ACTIVE);
+	nic_active |= nic_active_bit;
+	nic_active |= 2;	
+	nes_write_indexed(nesdev->index_reg, NES_IDX_NIC_ACTIVE,
nic_active);
+	nic_active = nes_read_indexed(nesdev->index_reg,
NES_IDX_NIC_MULTICAST_ALL);
+	nic_active |= nic_active_bit;
+	nes_write_indexed(nesdev->index_reg, NES_IDX_NIC_MULTICAST_ALL,
nic_active);
+	nic_active = nes_read_indexed(nesdev->index_reg,
NES_IDX_NIC_BROADCAST_ON);
+	nic_active |= nic_active_bit;
+	nes_write_indexed(nesdev->index_reg, NES_IDX_NIC_BROADCAST_ON,
nic_active);
+
+
+	nes_write32(nesdev->regs+NES_CQE_ALLOC,
NES_CQE_ALLOC_NOTIFY_NEXT | 
+				nesdev->hnic_cq.cq_number );
+
+	// TODO: add proper way to setup packet filters
+	// TODO: move some of the code from init_netdev?
+
+	if ( link_up ) {
+		/* Enable network packets */
+		nes_port->linkup = 1;
+		netif_start_queue(netdev);
+	} else {
+		nes_port->linkup = 0;
+		netif_carrier_off(netdev);
+	}
+
+	nes_write_indexed(nesdev->index_reg, NES_IDX_MAC_INT_MASK, 
+					  ~(NES_MAC_INT_LINK_STAT_CHG |
NES_MAC_INT_XGMII_EXT | 
+						NES_MAC_INT_TX_UNDERFLOW
| NES_MAC_INT_TX_ERROR) );
+
+	return 0;
+}
+
+
+/**
+ * nes_netdev_stop
+ * 
+ * @param netdev
+ * 
+ * @return int
+ */
+static int nes_netdev_stop(struct net_device *netdev)
+{
+	struct nes_port *nes_port = netdev_priv(netdev);
+	struct nes_dev *nesdev = nes_port->nesdev;
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	struct nes_hw_nic_rq_wqe *nic_rqe;
+	u64 wqe_frag;
+	u32 cqp_head;
+	u32 nic_active_mask;
+	u32 nic_active;
+	unsigned long flags;
+	int ret;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	nes_stop_cm(nesdev);
+
+	if (netif_msg_ifdown(nes_port))
+		dprintk(KERN_INFO PFX "%s: disabling interface\n",
netdev->name);
+
+	nes_write_indexed(nesdev->index_reg, NES_IDX_MAC_INT_MASK,
0xffffffff );
+
+	nic_active_mask = ~((u32)(1<<PCI_FUNC(nesdev->pcidev->devfn)));
+	nic_active_mask = ~((u32)(1 << (PCI_FUNC(nesdev->pcidev->devfn)
+ 1)));
+	nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_PERFECT_FILTER_HIGH+((PCI_FUNC(nesdev->pcidev->devfn)+1)*8), 0);
+	nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_PERFECT_FILTER_HIGH+(PCI_FUNC(nesdev->pcidev->devfn)*8), 0);
+	nic_active = nes_read_indexed(nesdev->index_reg,
NES_IDX_NIC_ACTIVE);
+	nic_active &= nic_active_mask;
+	nes_write_indexed(nesdev->index_reg, NES_IDX_NIC_ACTIVE,
nic_active);
+	nic_active = nes_read_indexed(nesdev->index_reg,
NES_IDX_NIC_MULTICAST_ALL);
+	nic_active &= nic_active_mask;
+	nes_write_indexed(nesdev->index_reg, NES_IDX_NIC_MULTICAST_ALL,
nic_active);
+	nic_active = nes_read_indexed(nesdev->index_reg,
NES_IDX_NIC_BROADCAST_ON);
+	nic_active &= nic_active_mask;
+	nes_write_indexed(nesdev->index_reg, NES_IDX_NIC_BROADCAST_ON,
nic_active);
+
+
+	/* Disable network packets */
+	netif_stop_queue(netdev);
+
+	// Free remaining NIC receive buffers
+	while (nesdev->hnic.rq_head != nesdev->hnic.rq_tail) {
+		nic_rqe = &nesdev->hnic.rq_vbase[nesdev->hnic.rq_tail];
+		wqe_frag =
nic_rqe->wqe_words[NES_NIC_RQ_WQE_FRAG0_LOW_IDX];
+		wqe_frag +=
((u64)nic_rqe->wqe_words[NES_NIC_RQ_WQE_FRAG0_HIGH_IDX])<<32;
+		pci_unmap_single(nesdev->pcidev, (dma_addr_t)wqe_frag,
+						 max_frame_len,
PCI_DMA_FROMDEVICE);
+
dev_kfree_skb(nesdev->hnic.rx_skb[nesdev->hnic.rq_tail++]);
+		nesdev->hnic.rq_tail &= nesdev->hnic.rq_size - 1;
+	}
+
+	// Destroy NIC QP
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+	cqp_head = nesdev->cqp.sq_head;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_QP | NES_CQP_QP_TYPE_NIC);
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
cpu_to_le32(nesdev->hnic_cq.cq_number);
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
+	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
cqp_head;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =  0;
+	if (++cqp_head >= nesdev->cqp.sq_size) cqp_head = 0;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+
+	// Destroy NIC CQ
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_CQ | (nesdev->hnic_cq.cq_size<<16));
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
cpu_to_le32(nesdev->hnic_cq.cq_number |
((u32)PCI_FUNC(nesdev->pcidev->devfn)<<16));
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
+	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
cqp_head;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =  0;
+	if (++cqp_head >= nesdev->cqp.sq_size) cqp_head = 0;
+
+	nesdev->cqp.sq_head = cqp_head;
+	barrier();
+
+	// Ring doorbell (2 WQEs)
+	nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x02800000 |
nesdev->cqp.qp_id );
+
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	dprintk("Waiting for destroy NIC QP to complete.\n");
+	cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
+	ret =
wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
2);
+
+	dprintk("Destroy NIC QP completed, wait_event_timeout ret =
%u.\n", ret);
+
+	// Free the NIC memory
+	pci_free_consistent(nesdev->pcidev, nesdev->nic_mem_size,
nesdev->hnic.first_frag_vbase,
+
nesdev->hnic.frag_paddr[0]);
+
+	return 0;
+}
+
+
+/**
+ * nes_netdev_start_xmit
+ * 
+ * @param skb
+ * @param netdev
+ * 
+ * @return int
+ */
+static int nes_netdev_start_xmit(struct sk_buff *skb, struct net_device
*netdev)
+{
+	struct nes_port *nes_port = netdev_priv(netdev);
+	struct nes_dev *nesdev = nes_port->nesdev;
+	struct nes_hw_nic *nesnic = &nesdev->hnic;
+	struct nes_hw_nic_sq_wqe *nic_sqe;
+	unsigned long flags;
+	dma_addr_t bus_address;
+
+//	printk(KERN_ERR PFX "%s: Request to transmit a NIC packet length
%u (%u frags), first address = %p...\n",
+//		pci_name(nesdev->pcidev), skb_headlen(skb),
skb_shinfo(skb)->nr_frags, skb->data);
+	local_irq_save(flags);
+	if (!spin_trylock(&nesnic->sq_lock)) {
+		local_irq_restore(flags);
+		return NETDEV_TX_LOCKED;
+	}
+
+	/* Check if SQ is full */
+	if ((((nesnic->sq_tail+(nesnic->sq_size*2))-nesnic->sq_head) &
(nesnic->sq_size - 1)) == 1 ) {
+		netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&nesnic->sq_lock, flags);
+		dprintk(KERN_WARNING PFX "%s: HNIC SQ full when queue
awake!\n", netdev->name);
+		return NETDEV_TX_BUSY;
+	}
+
+	/* Check if too many fragments */
+	if (skb_shinfo(skb)->nr_frags) {
+		/* TODO: if too many fragments copy the data or enable
EFBs */
+		spin_unlock_irqrestore(&nesnic->sq_lock, flags);
+		kfree_skb(skb);
+		dprintk(KERN_WARNING PFX "%s: HNIC TODO: Need support
for more 4 fragments!  Packet with %u fragments not sent.\n",
+				netdev->name,
skb_shinfo(skb)->nr_frags+1);
+		return NETDEV_TX_OK;
+	}
+
+	memcpy(&nesnic->first_frag_vbase[nesnic->sq_head].buffer, 
+		   skb->data, min(((unsigned int)NES_FIRST_FRAG_SIZE),
(skb_headlen(skb))));
+
+	nic_sqe = &nesnic->sq_vbase[nesnic->sq_head];
+
+	nic_sqe->wqe_words[NES_NIC_SQ_WQE_MISC_IDX] =
cpu_to_le32(NES_NIC_SQ_WQE_DISABLE_CHKSUM | NES_NIC_SQ_WQE_COMPLETION);
+	nic_sqe->wqe_words[NES_NIC_SQ_WQE_TOTAL_LENGTH_IDX] =
cpu_to_le32(skb_headlen(skb));
+	if (skb_headlen(skb)>NES_FIRST_FRAG_SIZE) {
+		bus_address = pci_map_single(nesdev->pcidev,
skb->data+NES_FIRST_FRAG_SIZE, 
+
skb_headlen(skb)-NES_FIRST_FRAG_SIZE, PCI_DMA_TODEVICE);
+		nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_2_1_IDX] =
cpu_to_le32(skb_headlen(skb)-NES_FIRST_FRAG_SIZE);
+		nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG1_LOW_IDX] =
cpu_to_le32((u32)bus_address);
+		nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG1_HIGH_IDX] =
cpu_to_le32((u32)((u64)bus_address>>32));
+//      dprintk("Mapping sq fragment 0x%08X%08X, length = %u.\n", 
+//
nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG1_HIGH_IDX],
+//
nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG1_LOW_IDX], 
+//
nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_2_1_IDX]);
+		nesnic->tx_skb[nesnic->sq_head] = skb;
+	} else {
+		nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_2_1_IDX] = 0;
+		nesnic->tx_skb[nesnic->sq_head] = 0;
+		dev_kfree_skb(skb);
+	}
+
+	nesnic->sq_head++;
+	nesnic->sq_head &= nesnic->sq_size-1;
+
+	barrier();
+
+	nes_write32(nesdev->regs+NES_WQE_ALLOC, (1<<24) | (1<<23) |
nesdev->hnic.qp_id );
+
+	netdev->trans_start = jiffies;
+	nes_port->netstats.tx_packets++;
+	nes_port->netstats.tx_bytes += skb_headlen(skb);
+	spin_unlock_irqrestore(&nesnic->sq_lock, flags);
+
+	return NETDEV_TX_OK;
+}
+
+
+/**
+ * nes_netdev_get_stats
+ * 
+ * @param netdev
+ * 
+ * @return struct net_device_stats*
+ */
+static struct net_device_stats *nes_netdev_get_stats(struct net_device
*netdev)
+{
+	struct nes_port *nes_port = netdev_priv(netdev);
+
+	return (&nes_port->netstats);
+}
+
+
+/**
+ * nes_netdev_tx_timeout
+ * 
+ * @param netdev
+ */
+static void nes_netdev_tx_timeout(struct net_device *netdev)
+{
+	struct nes_port *nes_port = netdev_priv(netdev);
+
+	if (netif_msg_timer(nes_port))
+		dprintk(KERN_DEBUG PFX "%s: tx timeout\n",
netdev->name);
+}
+
+
+/**
+ * nes_netdev_set_mac_address
+ * 
+ * @param netdev
+ * @param p
+ * 
+ * @return int
+ */
+static int nes_netdev_set_mac_address(struct net_device *netdev, void
*p)
+{
+	return -1;
+}
+
+
+/**
+ * nes_netdev_change_mtu
+ * 
+ * @param netdev
+ * @param new_mtu
+ * 
+ * @return int
+ */
+static int nes_netdev_change_mtu(struct net_device *netdev, int
new_mtu)
+{
+	int ret = 0;
+
+	if ( (new_mtu < ETH_ZLEN) || (new_mtu > max_mtu) )
+		return -EINVAL;
+
+	netdev->mtu = new_mtu;
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
+ * nes_netdev_init - initialize network device
+ * 
+ * @param nesdev
+ * @param mmio_addr
+ * 
+ * @return struct net_device*
+ */
+struct net_device *nes_netdev_init(struct nes_dev *nesdev, void __iomem
*mmio_addr)
+{
+	struct nes_port *nes_port = NULL;
+	struct net_device *netdev = alloc_etherdev(sizeof(*nes_port));
+	u32 count=0;
+
+	if (!netdev) {
+		dprintk(KERN_ERR PFX "nes_port etherdev alloc failed");
+		return NULL;
+	}
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
+	netdev->mtu = max_mtu;
+	netdev->hard_header_len = ETH_HLEN;
+	netdev->addr_len = ETH_ALEN;
+	netdev->type = ARPHRD_ETHER;
+
+	/* Setup the burned in MAC address */
+	netdev->dev_addr[0] =
(u8)(nesdev->nesadapter->mac_addr_high>>8);
+	netdev->dev_addr[1] = (u8)nesdev->nesadapter->mac_addr_high;
+	netdev->dev_addr[2] =
(u8)(nesdev->nesadapter->mac_addr_low>>24);
+	netdev->dev_addr[3] =
(u8)(nesdev->nesadapter->mac_addr_low>>16);
+	netdev->dev_addr[4] = (u8)(nesdev->nesadapter->mac_addr_low>>8);
+	netdev->dev_addr[5] = (u8)nesdev->nesadapter->mac_addr_low;
+
+	/* Program the various MAC regs */
+	nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_PERFECT_FILTER_LOW+(PCI_FUNC(nesdev->pcidev->devfn)*8), 
+
nesdev->nesadapter->mac_addr_low+PCI_FUNC(nesdev->pcidev->devfn));
+	nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_PERFECT_FILTER_HIGH+(PCI_FUNC(nesdev->pcidev->devfn)*8), 
+
(u32)nesdev->nesadapter->mac_addr_high | NES_MAC_ADDR_VALID | 
+
((((u32)PCI_FUNC(nesdev->pcidev->devfn))<<16)));
+	nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_PERFECT_FILTER_LOW+((PCI_FUNC(nesdev->pcidev->devfn)+1)*8), 
+
nesdev->nesadapter->mac_addr_low+PCI_FUNC(nesdev->pcidev->devfn));
+	nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_PERFECT_FILTER_HIGH+((PCI_FUNC(nesdev->pcidev->devfn)+1)*8), 
+
(u32)nesdev->nesadapter->mac_addr_high | NES_MAC_ADDR_VALID | 
+
((((u32)PCI_FUNC(nesdev->pcidev->devfn))<<16)));
+
+	/* Fill in the port structure */
+	nes_port = netdev_priv(netdev);
+	nes_port->netdev = netdev;
+	nes_port->nesdev = nesdev;
+	nes_port->msg_enable = netif_msg_init(debug, default_msg);
+
+	spin_lock_init(&nes_port->tx_lock);
+
+	nes_cqp_init(nesdev);
+
+	// Arm the CCQ
+	nes_write32(nesdev->regs+NES_CQE_ALLOC,
NES_CQE_ALLOC_NOTIFY_NEXT | 
+				PCI_FUNC(nesdev->pcidev->devfn) );
+
+	// Enable the interrupts
+	nesdev->int_req = (1<<PCI_FUNC(nesdev->pcidev->devfn)) | 
+
(1<<(PCI_FUNC(nesdev->pcidev->devfn)+16)) | 
+
(1<<(PCI_FUNC(nesdev->pcidev->devfn)+24));
+	nesdev->intf_int_req &= ~NES_INTF_INT_CRITERR;
+	nes_write32(nesdev->regs+NES_INTF_INT_MASK,
~(nesdev->intf_int_req));
+
+	nes_write32(nesdev->regs+NES_INT_MASK, ~nesdev->int_req);
+	dprintk("Waiting for create CQP init to complete.\n");
+	do {
+		if (count++ > 1000)
+			break;
+		udelay(10);
+	} while (!(nesdev->cqp.sq_head == nesdev->cqp.sq_tail));
+
+	nesdev->netdev = netdev;
+
+	list_add_tail(&nesdev->list, &nes_dev_list);
+
+	return netdev;
+}
+
+
+/**
+ * nes_netdev_exit
+ * 
+ * @param nesdev
+ */
+void nes_netdev_exit(struct nes_dev *nesdev)
+{
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	u32 count=0;
+	u32 cqp_head;
+	unsigned long flags;
+	int ret;
+
+	dprintk("Waiting for CQP work to complete.\n");
+	do {
+		if (count++ > 1000)	break;
+		udelay(10);
+	} while ( !(nesdev->cqp.sq_head == nesdev->cqp.sq_tail) );
+
+	// Reset CCQ
+	nes_write32(nesdev->regs+NES_CQE_ALLOC, NES_CQE_ALLOC_RESET | 
+				nesdev->ccq.cq_number );
+	// Disable device interrupts
+	nes_write32(nesdev->regs+NES_INT_MASK, 0x7fffffff );
+	// Destroy the AEQ
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+	cqp_head = nesdev->cqp.sq_head++;
+	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_AEQ + (PCI_FUNC(nesdev->pcidev->devfn)<<8));
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
+	// Destroy the CEQ
+	cqp_head = nesdev->cqp.sq_head++;
+	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_CEQ + (PCI_FUNC(nesdev->pcidev->devfn)<<8));
+	// Destroy the CCQ
+	cqp_head = nesdev->cqp.sq_head++;
+	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_CQ);
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] = cpu_to_le32(
PCI_FUNC(nesdev->pcidev->devfn) ||
(PCI_FUNC(nesdev->pcidev->devfn)<<16));
+	// Destroy CQP
+	cqp_head = nesdev->cqp.sq_head++;
+	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_DESTROY_QP | NES_CQP_QP_TYPE_CQP);
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
cpu_to_le32(nesdev->cqp.qp_id);
+
+	barrier();
+	// Ring doorbell (4 WQEs)
+	nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x04800000 |
nesdev->cqp.qp_id);
+
+	// Wait for the destroy to complete
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	dprintk("%s:Waiting for DestroyQP.\n",__FUNCTION__);
+	cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
+	ret =
wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
2);
+	dprintk("%s:Done waiting for DestroyQP. wait_event_timeout ret =
%d.\n",__FUNCTION__, ret);
+	// Free the control structures
+	pci_free_consistent(nesdev->pcidev, nesdev->cqp_mem_size,
nesdev->cqp.sq_vbase,
+						nesdev->cqp.sq_pbase);
+	list_del(&nesdev->list);
+}
+
+
+/**
+ * nes_adapter_free - free network adapter
+ *
+ * @param nesadapter
+ */
+void nes_adapter_free(struct nes_adapter *nesadapter)
+{
+	struct nes_adapter *tmp_adapter;
+	list_for_each_entry(tmp_adapter, &nes_adapter_list, list) {
+		dprintk("%s: Nes Adapter list entry = 0x%p.\n",
__FUNCTION__, tmp_adapter);
+	}
+
+	nesadapter->ref_count--;
+	if (!nesadapter->ref_count) {
+		dprintk("nes_adapter_free: Deleting adapter from adapter
list.\n" );
+		list_del(&nesadapter->list);
+		/* TODO: free the resources from the resource list */
+		dprintk("nes_adapter_free: Freeing adapter
structure.\n");
+		kfree(nesadapter);
+	}
+	dprintk("nes_adapter_free: Done.\n");
+}
+
+


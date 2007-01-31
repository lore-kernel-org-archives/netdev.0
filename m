From: olof@lixom.net (Olof Johansson)
Subject: [PATCH] [v3] PA Semi PWRficient Ethernet driver
Date: Tue, 30 Jan 2007 23:44:57 -0600
Message-ID: <20070131054457.GA32043@lixom.net>
References: <20070129060852.GA7814@lixom.net> <20070130014434.GC18935@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:39392 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932896AbXAaFiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 00:38:15 -0500
Content-Disposition: inline
In-Reply-To: <20070130014434.GC18935@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver for the PA Semi PWRficient on-chip Ethernet (1/10G)

Basic enablement, will be complemented with performance enhancements
over time. PHY support will be added as well.

Signed-off-by: Olof Johansson <olof@lixom.net>

---

Further improvements based on comments:

* Added remove function
* Checking interrupt status in handler
* Misc cleanups w.r.t. ring handing (INFO/DESCR/BUFF are gone)
* Added locking of the rings
* Using PCI DMA for all buffers

Misc other changes while I was touching the code:

* Setting the interrupt descriptor field to include interface number
* Added PCI vendor ID, it's been submitted to sf.net as well.
* Moved Kconfig entry to the 10GbE section


Index: merge/drivers/net/Kconfig
===================================================================
--- merge.orig/drivers/net/Kconfig
+++ merge/drivers/net/Kconfig
@@ -2488,6 +2488,13 @@ config NETXEN_NIC
 	help
 	  This enables the support for NetXen's Gigabit Ethernet card.
 
+config PASEMI_MAC
+	tristate "PA Semi 1/10Gbit MAC"
+	depends on PPC64 && PCI
+	help
+	  This driver supports the on-chip 1/10Gbit Ethernet controller on
+	  PA Semi's PWRficient line of chips.
+
 endmenu
 
 source "drivers/net/tokenring/Kconfig"
Index: merge/drivers/net/Makefile
===================================================================
--- merge.orig/drivers/net/Makefile
+++ merge/drivers/net/Makefile
@@ -196,6 +196,7 @@ obj-$(CONFIG_SMC91X) += smc91x.o
 obj-$(CONFIG_SMC911X) += smc911x.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_FEC_8XX) += fec_8xx/
+obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o
 
 obj-$(CONFIG_MACB) += macb.o
 
Index: merge/drivers/net/pasemi_mac.c
===================================================================
--- /dev/null
+++ merge/drivers/net/pasemi_mac.c
@@ -0,0 +1,963 @@
+/*
+ * Copyright (C) 2006-2007 PA Semi, Inc
+ *
+ * Driver for the PA Semi PWRficient onchip 1G/10G Ethernet MACs
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/interrupt.h>
+#include <linux/dmaengine.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <asm/dma-mapping.h>
+#include <linux/in.h>
+#include <linux/skbuff.h>
+
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <net/checksum.h>
+
+#include "pasemi_mac.h"
+
+#define INITIAL_RX_RING_SIZE 512
+#define INITIAL_TX_RING_SIZE 512
+
+#define BUF_SIZE 1646 /* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
+
+#define PAS_DMA_MAX_IF     40
+#define PAS_DMA_MAX_RXCH   8
+#define PAS_DMA_MAX_TXCH   8
+
+/* XXXOJN these should come out of the device tree some day */
+#define PAS_DMA_CAP_BASE   0xe00d0040
+#define PAS_DMA_CAP_SIZE   0x100
+#define PAS_DMA_COM_BASE   0xe00d0100
+#define PAS_DMA_COM_SIZE   0x100
+
+static struct pasdma_status *dma_status;
+
+static int pasemi_set_mac_addr(struct pasemi_mac *mac)
+{
+	struct pci_dev *pdev = mac->pdev;
+	struct device_node *dn = pci_device_to_OF_node(pdev);
+	const u8 *maddr;
+	u8 addr[6];
+
+	if (!dn) {
+		dev_dbg(&pdev->dev,
+			  "No device node for mac, not configuring\n");
+		return -ENOENT;
+	}
+
+	maddr = get_property(dn, "mac-address", NULL);
+	if (maddr == NULL) {
+		dev_warn(&pdev->dev,
+			 "no mac address in device tree, not configuring\n");
+		return -ENOENT;
+	}
+
+	if (sscanf(maddr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", &addr[0],
+		   &addr[1], &addr[2], &addr[3], &addr[4], &addr[5]) != 6) {
+		dev_warn(&pdev->dev,
+			 "can't parse mac address, not configuring\n");
+		return -EINVAL;
+	}
+
+	memcpy(mac->mac_addr, addr, sizeof(addr));
+	return 0;
+}
+
+static int pasemi_mac_setup_rx_resources(struct net_device *dev)
+{
+	struct pasemi_mac_rxring *ring;
+	struct pasemi_mac *mac = netdev_priv(dev);
+	int chan_id = mac->dma_rxch;
+
+	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+
+	if (!ring)
+		goto out_ring;
+
+	spin_lock_init(&ring->lock);
+	ring->count = INITIAL_RX_RING_SIZE;
+
+	ring->desc_info = kzalloc(sizeof(struct pasemi_mac_buffer)*ring->count,
+				  GFP_KERNEL);
+
+	if (!ring->desc_info)
+		goto out_desc_info;
+
+	/* Allocate descriptors */
+	ring->desc = dma_alloc_coherent(&mac->dma_pdev->dev,
+					ring->count *
+					sizeof(struct pas_dma_xct_descr),
+					&ring->dma, GFP_KERNEL);
+
+	if (!ring->desc)
+		goto out_desc;
+
+	memset(ring->desc, 0, ring->count * sizeof(struct pas_dma_xct_descr));
+
+	ring->buffers = dma_alloc_coherent(&mac->dma_pdev->dev,
+					   ring->count * sizeof(u64),
+					   &ring->buf_dma, GFP_KERNEL);
+	if (!ring->buffers)
+		goto out_buffers;
+
+	memset(ring->buffers, 0, ring->count * sizeof(u64));
+
+	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXCHAN_BASEL(chan_id),
+			       PAS_DMA_RXCHAN_BASEL_BRBL(ring->dma));
+
+	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXCHAN_BASEU(chan_id),
+			       PAS_DMA_RXCHAN_BASEU_BRBH(ring->dma >> 32) |
+			       PAS_DMA_RXCHAN_BASEU_SIZ(INITIAL_RX_RING_SIZE >> 2));
+
+	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXCHAN_CFG(chan_id),
+			       PAS_DMA_RXCHAN_CFG_HBU(1));
+
+	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXINT_BASEL(mac->dma_if),
+			       PAS_DMA_RXINT_BASEL_BRBL(__pa(ring->buffers)));
+
+	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXINT_BASEU(mac->dma_if),
+			       PAS_DMA_RXINT_BASEU_BRBH(__pa(ring->buffers) >> 32) |
+			       PAS_DMA_RXINT_BASEU_SIZ(INITIAL_RX_RING_SIZE >> 3));
+
+	ring->next_to_fill = 0;
+	ring->next_to_clean = 0;
+
+	snprintf(ring->irq_name, sizeof(ring->irq_name),
+		 "%s rx", dev->name);
+	mac->rx = ring;
+
+	return 0;
+
+out_buffers:
+	dma_free_coherent(&mac->dma_pdev->dev,
+			  mac->rx->count * sizeof(struct pas_dma_xct_descr),
+			  mac->rx->desc, mac->rx->dma);
+out_desc:
+	kfree(ring->desc_info);
+out_desc_info:
+	kfree(ring);
+out_ring:
+	return -ENOMEM;
+}
+
+
+static int pasemi_mac_setup_tx_resources(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	u32 val;
+	int chan_id = mac->dma_txch;
+	struct pasemi_mac_txring *ring;
+
+	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+	if (!ring)
+		goto out_ring;
+
+	spin_lock_init(&ring->lock);
+	ring->count = INITIAL_TX_RING_SIZE;
+
+	ring->desc_info = kzalloc(sizeof(struct pasemi_mac_buffer)*ring->count,
+				  GFP_KERNEL);
+	if (!ring->desc_info)
+		goto out_desc_info;
+
+	/* Allocate descriptors */
+	ring->desc = dma_alloc_coherent(&mac->dma_pdev->dev,
+					ring->count *
+					sizeof(struct pas_dma_xct_descr),
+					&ring->dma, GFP_KERNEL);
+	if (!ring->desc)
+		goto out_desc;
+
+	memset(ring->desc, 0, ring->count * sizeof(struct pas_dma_xct_descr));
+
+	pci_write_config_dword(mac->dma_pdev, PAS_DMA_TXCHAN_BASEL(chan_id),
+			       PAS_DMA_TXCHAN_BASEL_BRBL(ring->dma));
+	val = PAS_DMA_TXCHAN_BASEU_BRBH(ring->dma >> 32);
+	val |= PAS_DMA_TXCHAN_BASEU_SIZ(INITIAL_TX_RING_SIZE >> 2);
+
+	pci_write_config_dword(mac->dma_pdev, PAS_DMA_TXCHAN_BASEU(chan_id), val);
+
+	pci_write_config_dword(mac->dma_pdev, PAS_DMA_TXCHAN_CFG(chan_id),
+			       PAS_DMA_TXCHAN_CFG_TY_IFACE |
+			       PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
+			       PAS_DMA_TXCHAN_CFG_UP |
+			       PAS_DMA_TXCHAN_CFG_WT(2));
+
+	ring->next_to_use = 0;
+	ring->next_to_clean = 0;
+
+	snprintf(ring->irq_name, sizeof(ring->irq_name),
+		 "%s tx", dev->name);
+	mac->tx = ring;
+
+	return 0;
+
+out_desc:
+	kfree(ring->desc_info);
+out_desc_info:
+	kfree(ring);
+out_ring:
+	return -ENOMEM;
+}
+
+static noinline void pasemi_mac_free_tx_resources(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	unsigned int i;
+	struct pasemi_mac_buffer *info;
+	struct pas_dma_xct_descr *dp;
+
+	for (i = 0; i < mac->tx->count; i++) {
+		info = &mac->tx->desc_info[i % mac->tx->count];
+		dp = &mac->tx->desc[i % mac->tx->count];
+		if (info->dma) {
+			if (info->skb) {
+				pci_unmap_single(mac->dma_pdev,
+						 info->dma,
+						 info->skb->len,
+						 PCI_DMA_TODEVICE);
+				dev_kfree_skb_any(info->skb);
+			}
+			info->dma = 0;
+			info->skb = 0;
+			dp->mactx = 0;
+			dp->ptr = 0;
+		}
+	}
+
+	dma_free_coherent(&mac->dma_pdev->dev,
+			  mac->tx->count * sizeof(struct pas_dma_xct_descr),
+			  mac->tx->desc, mac->tx->dma);
+
+	kfree(mac->tx->desc_info);
+	kfree(mac->tx);
+	mac->tx = NULL;
+}
+
+static noinline void pasemi_mac_free_rx_resources(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	unsigned int i;
+	struct pasemi_mac_buffer *info;
+	struct pas_dma_xct_descr *dp;
+
+	for (i = 0; i < mac->rx->count; i++) {
+		info = &mac->rx->desc_info[i % mac->rx->count];
+		dp = &mac->rx->desc[i % mac->rx->count];
+		if (info->dma) {
+			if (info->skb) {
+				pci_unmap_single(mac->dma_pdev,
+						 info->dma,
+						 info->skb->len,
+						 PCI_DMA_FROMDEVICE);
+				dev_kfree_skb_any(info->skb);
+			}
+			info->dma = 0;
+			info->skb = 0;
+			dp->macrx = 0;
+			dp->ptr = 0;
+		}
+	}
+
+	dma_free_coherent(&mac->dma_pdev->dev,
+			  mac->rx->count * sizeof(struct pas_dma_xct_descr),
+			  mac->rx->desc, mac->rx->dma);
+
+	dma_free_coherent(&mac->dma_pdev->dev, mac->rx->count * sizeof(u64),
+			  mac->rx->buffers, mac->rx->buf_dma);
+
+	kfree(mac->rx->desc_info);
+	kfree(mac->rx);
+	mac->rx = NULL;
+}
+
+static void pasemi_mac_replenish_rx_ring(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	unsigned int i;
+	int start = mac->rx->next_to_fill;
+	int count;
+
+	count = ((mac->rx->next_to_clean & ~7) + mac->rx->count -
+		 mac->rx->next_to_fill) % mac->rx->count;
+
+	if (unlikely(mac->rx->next_to_clean == 0 && mac->rx->next_to_fill == 0))
+		count = mac->rx->count - 8;
+
+	/* Limit so we don't go into the last cache line */
+	count -= 8;
+
+	if (count <= 0)
+		return;
+
+	for (i = start; i < start + count; i++) {
+		struct pasemi_mac_buffer *info = &mac->rx->desc_info[i % mac->rx->count];
+		u64 *buff = &mac->rx->buffers[i % mac->rx->count];
+		struct sk_buff *skb;
+		dma_addr_t dma;
+
+		skb = dev_alloc_skb(BUF_SIZE);
+
+		if (!skb)
+			return;
+
+		skb->dev = dev;
+
+		dma = pci_map_single(mac->dma_pdev, skb->data, skb->len,
+				     PCI_DMA_FROMDEVICE);
+		info->skb = skb;
+		info->dma = dma;
+		*buff = XCT_RXB_LEN(BUF_SIZE) | XCT_RXB_ADDR(dma);
+	}
+
+	wmb();
+
+	pci_write_config_dword(mac->dma_pdev,
+			       PAS_DMA_RXCHAN_INCR(mac->dma_rxch),
+			       count);
+	pci_write_config_dword(mac->dma_pdev,
+			       PAS_DMA_RXINT_INCR(mac->dma_if),
+			       count);
+
+	mac->rx->next_to_fill += count;
+}
+
+static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
+{
+	unsigned int i;
+	int start, count;
+
+	spin_lock(&mac->rx->lock);
+
+	start = mac->rx->next_to_clean;
+	count = 0;
+
+	for (i = start; i < (start + mac->rx->count) && count < limit; i++) {
+		struct pas_dma_xct_descr *dp;
+		struct pasemi_mac_buffer *info;
+		struct sk_buff *skb;
+		unsigned int j, len;
+		dma_addr_t dma;
+
+		rmb();
+
+		dp = &mac->rx->desc[i % mac->rx->count];
+
+		if (!(dp->macrx & XCT_MACRX_O))
+			break;
+
+		count++;
+
+		info = NULL;
+
+		/* We have to scan for our skb since there's no way
+		 * to back-map them from the descriptor, and if we
+		 * have several receive channels then they might not
+		 * show up in the same order as they were put on the
+		 * interface ring.
+		 */
+
+		dma = (dp->ptr & XCT_PTR_ADDR_M);
+		for (j = start; j < (start + mac->rx->count); j++) {
+			info = &mac->rx->desc_info[j % mac->rx->count];
+			if (info->dma == dma)
+				break;
+		}
+
+		BUG_ON(!info);
+		BUG_ON(info->dma != dma);
+
+		pci_unmap_single(mac->dma_pdev, info->dma, info->skb->len,
+				 PCI_DMA_FROMDEVICE);
+
+		skb = info->skb;
+
+		len = (dp->macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
+
+		skb_put(skb, len);
+
+		skb->protocol = eth_type_trans(skb, mac->netdev);
+
+		if ((dp->macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK) {
+			skb->ip_summed = CHECKSUM_COMPLETE;
+			skb->csum = (dp->macrx & XCT_MACRX_CSUM_M) >>
+					   XCT_MACRX_CSUM_S;
+		} else
+			skb->ip_summed = CHECKSUM_NONE;
+
+		mac->stats.rx_bytes += len;
+		mac->stats.rx_packets++;
+
+		netif_receive_skb(skb);
+
+		dp->ptr = 0;
+		dp->macrx = 0;
+		info->dma = 0;
+		info->skb = 0;
+	}
+
+	mac->rx->next_to_clean += count;
+	pasemi_mac_replenish_rx_ring(mac->netdev);
+
+	spin_unlock(&mac->rx->lock);
+
+	return count;
+}
+
+static int pasemi_mac_clean_tx(struct pasemi_mac *mac)
+{
+	int i;
+	struct pasemi_mac_buffer *info;
+	struct pas_dma_xct_descr *dp;
+	int start, count;
+	int flags;
+
+	if (!spin_trylock_irqsave(&mac->tx->lock, flags))
+		return 0;
+
+	start = mac->tx->next_to_clean;
+	count = 0;
+
+	for (i = start; i < mac->tx->next_to_use; i++) {
+		dp = &mac->tx->desc[i % mac->tx->count];
+		if (!dp || (dp->mactx & XCT_MACTX_O))
+			break;
+
+		count++;
+
+		info = &mac->tx->desc_info[i % mac->tx->count];
+
+		pci_unmap_single(mac->dma_pdev, info->dma,
+				 info->skb->len, PCI_DMA_TODEVICE);
+		dev_kfree_skb_irq(info->skb);
+		info->skb = NULL;
+		info->dma = 0;
+		dp->mactx = 0;
+		dp->ptr = 0;
+	}
+	mac->tx->next_to_clean += count;
+	spin_unlock_irqrestore(&mac->tx->lock, flags);
+
+	return count;
+}
+
+
+static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
+{
+	struct net_device *dev = data;
+	struct pasemi_mac *mac = netdev_priv(dev);
+	unsigned int reg;
+
+	if (!(*mac->rx_status & PAS_STATUS_INT))
+		return IRQ_NONE;
+
+	netif_rx_schedule(dev);
+	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
+			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0));
+
+	reg = PAS_IOB_DMA_RXCH_RESET_PINTC | PAS_IOB_DMA_RXCH_RESET_SINTC |
+	      PAS_IOB_DMA_RXCH_RESET_DINTC;
+	if (*mac->rx_status & PAS_STATUS_TIMER)
+		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
+
+	pci_write_config_dword(mac->iob_pdev,
+			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
+
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
+{
+	struct net_device *dev = data;
+	struct pasemi_mac *mac = netdev_priv(dev);
+	unsigned int reg;
+	int was_full;
+
+	was_full = mac->tx->next_to_clean + mac->tx->count == mac->tx->next_to_use;
+
+	if (!(*mac->tx_status & PAS_STATUS_INT))
+		return IRQ_NONE;
+
+	pasemi_mac_clean_tx(mac);
+
+	reg = PAS_IOB_DMA_TXCH_RESET_PINTC | PAS_IOB_DMA_TXCH_RESET_SINTC;
+	if (*mac->tx_status & PAS_STATUS_TIMER)
+		reg |= PAS_IOB_DMA_TXCH_RESET_TINTC;
+
+	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
+			       reg);
+
+	if (was_full)
+		netif_wake_queue(dev);
+
+	return IRQ_HANDLED;
+}
+
+static int pasemi_mac_open(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	unsigned int flags;
+	int ret;
+
+	/* enable rx section */
+	pci_write_config_dword(mac->dma_pdev, PAS_DMA_COM_RXCMD,
+			       PAS_DMA_COM_RXCMD_EN);
+
+	/* enable tx section */
+	pci_write_config_dword(mac->dma_pdev, PAS_DMA_COM_TXCMD,
+			       PAS_DMA_COM_TXCMD_EN);
+
+	flags = PAS_MAC_CFG_TXP_FCE | PAS_MAC_CFG_TXP_FPC(3) |
+		PAS_MAC_CFG_TXP_SL(3) | PAS_MAC_CFG_TXP_COB(0xf) |
+		PAS_MAC_CFG_TXP_TIFT(8) | PAS_MAC_CFG_TXP_TIFG(12);
+
+	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_TXP, flags);
+
+	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
+		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
+
+	flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
+
+	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
+			       PAS_IOB_DMA_RXCH_CFG_CNTTH(30));
+
+	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
+			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
+
+	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
+
+	ret = pasemi_mac_setup_rx_resources(dev);
+	if (ret)
+		goto out_rx_resources;
+
+	ret = pasemi_mac_setup_tx_resources(dev);
+	if (ret)
+		goto out_tx_resources;
+
+	pci_write_config_dword(mac->pdev, PAS_MAC_IPC_CHNL,
+			       PAS_MAC_IPC_CHNL_DCHNO(mac->dma_rxch) |
+			       PAS_MAC_IPC_CHNL_BCH(mac->dma_rxch));
+
+	/* enable rx if */
+	pci_write_config_dword(mac->dma_pdev,
+			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+			       PAS_DMA_RXINT_RCMDSTA_EN);
+
+	/* enable rx channel */
+	pci_write_config_dword(mac->dma_pdev,
+			       PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
+			       PAS_DMA_RXCHAN_CCMDSTA_EN |
+			       PAS_DMA_RXCHAN_CCMDSTA_DU);
+
+	/* enable tx channel */
+	pci_write_config_dword(mac->dma_pdev,
+			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
+			       PAS_DMA_TXCHAN_TCMDSTA_EN);
+
+	pasemi_mac_replenish_rx_ring(dev);
+
+	netif_start_queue(dev);
+	netif_poll_enable(dev);
+
+	ret = request_irq(mac->dma_pdev->irq + mac->dma_txch,
+			  &pasemi_mac_tx_intr, IRQF_DISABLED,
+			  mac->tx->irq_name, dev);
+	if (ret) {
+		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
+		       mac->dma_pdev->irq + mac->dma_txch, ret);
+		goto out_tx_int;
+	}
+
+	ret = request_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch,
+			  &pasemi_mac_rx_intr, IRQF_DISABLED,
+			  mac->rx->irq_name, dev);
+	if (ret) {
+		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
+		       mac->dma_pdev->irq + 20 + mac->dma_rxch, ret);
+		goto out_rx_int;
+	}
+
+	return 0;
+
+out_rx_int:
+	free_irq(mac->dma_pdev->irq + mac->dma_txch, dev);
+out_tx_int:
+	netif_poll_disable(dev);
+	netif_stop_queue(dev);
+	pasemi_mac_free_tx_resources(dev);
+out_tx_resources:
+	pasemi_mac_free_rx_resources(dev);
+out_rx_resources:
+
+	return ret;
+}
+
+static int pasemi_mac_close(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	unsigned int stat;
+
+	netif_stop_queue(dev);
+
+	/* Clean out any pending buffers */
+	pasemi_mac_clean_tx(mac);
+	pasemi_mac_clean_rx(mac, mac->rx->count);
+
+	/* Disable interface */
+	pci_write_config_dword(mac->dma_pdev,
+			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
+			       PAS_DMA_TXCHAN_TCMDSTA_ST);
+	pci_write_config_dword(mac->dma_pdev,
+		      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+		      PAS_DMA_RXINT_RCMDSTA_ST);
+	pci_write_config_dword(mac->dma_pdev,
+		      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
+		      PAS_DMA_RXCHAN_CCMDSTA_ST);
+
+	do {
+		pci_read_config_dword(mac->dma_pdev,
+				      PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
+				      &stat);
+	} while (stat & PAS_DMA_TXCHAN_TCMDSTA_ACT);
+
+	do {
+		pci_read_config_dword(mac->dma_pdev,
+				      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
+				      &stat);
+	} while (stat & PAS_DMA_RXCHAN_CCMDSTA_ACT);
+
+	do {
+		pci_read_config_dword(mac->dma_pdev,
+				      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+				      &stat);
+	} while (stat & PAS_DMA_RXINT_RCMDSTA_ACT);
+
+	/* Then, disable the channel. This must be done separately from
+	 * stopping, since you can't disable when active.
+	 */
+
+	pci_write_config_dword(mac->dma_pdev,
+			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch), 0);
+	pci_write_config_dword(mac->dma_pdev,
+			       PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), 0);
+	pci_write_config_dword(mac->dma_pdev,
+			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
+
+	synchronize_irq(mac->dma_pdev->irq + mac->dma_txch);
+	synchronize_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch);
+
+	free_irq(mac->dma_pdev->irq + mac->dma_txch, dev);
+	free_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch, dev);
+
+	/* Free resources */
+	pasemi_mac_free_rx_resources(dev);
+	pasemi_mac_free_tx_resources(dev);
+
+	return 0;
+}
+
+static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	struct pasemi_mac_txring *txring;
+	struct pasemi_mac_buffer *info;
+	struct pas_dma_xct_descr *dp;
+	u64 flags;
+	dma_addr_t map;
+
+	txring = mac->tx;
+
+	if (txring->next_to_clean + txring->count == txring->next_to_use) {
+		pasemi_mac_clean_tx(mac);
+
+		if (txring->next_to_clean + txring->count == txring->next_to_use) {
+			/* Still no room -- stop the queue and wait for tx
+			 * intr when there's room.
+			 */
+			netif_stop_queue(dev);
+			return NETDEV_TX_BUSY;
+		}
+	}
+
+	mac->stats.tx_packets++;
+	mac->stats.tx_bytes += skb->len;
+
+	flags = XCT_MACTX_O | XCT_MACTX_ST |
+		XCT_MACTX_SS | XCT_MACTX_CRC_PAD;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		switch (skb->nh.iph->protocol) {
+		case IPPROTO_TCP:
+			flags |= XCT_MACTX_CSUM_TCP;
+			flags |= XCT_MACTX_IPH((skb->h.raw - skb->nh.raw) >> 2);
+			flags |= XCT_MACTX_IPO(skb->nh.raw - skb->data);
+			break;
+		case IPPROTO_UDP:
+			flags |= XCT_MACTX_CSUM_UDP;
+			flags |= XCT_MACTX_IPH((skb->h.raw - skb->nh.raw) >> 2);
+			flags |= XCT_MACTX_IPO(skb->nh.raw - skb->data);
+			break;
+		}
+	}
+
+	map = pci_map_single(mac->dma_pdev, skb->data, skb->len, PCI_DMA_TODEVICE);
+
+	dp = &txring->desc[txring->next_to_use % txring->count];
+	info = &txring->desc_info[txring->next_to_use % txring->count];
+
+	dp->mactx = flags | XCT_MACTX_LLEN(skb->len);
+	dp->ptr = XCT_PTR_LEN(skb->len) | XCT_PTR_ADDR(map);
+	info->dma = map;
+	info->skb = skb;
+	/* XXXOJN Deal with fragmented packets when larger MTU is supported */
+
+	txring->next_to_use++;
+
+	pci_write_config_dword(mac->dma_pdev,
+			       PAS_DMA_TXCHAN_INCR(mac->dma_txch), 1);
+
+	return NETDEV_TX_OK;
+}
+
+static struct net_device_stats *pasemi_mac_get_stats(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+
+	return &mac->stats;
+}
+
+static void pasemi_mac_set_rx_mode(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	unsigned int flags;
+
+	pci_read_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, &flags);
+
+	/* Set promiscuous */
+	if (dev->flags & IFF_PROMISC)
+		flags |= PAS_MAC_CFG_PCFG_PR;
+	else
+		flags &= ~PAS_MAC_CFG_PCFG_PR;
+
+	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
+}
+
+
+static int pasemi_mac_poll(struct net_device *dev, int *budget)
+{
+	int pkts, limit = min(*budget, dev->quota);
+	struct pasemi_mac *mac = netdev_priv(dev);
+
+	pkts = pasemi_mac_clean_rx(mac, limit);
+
+	if (pkts < limit) {
+		/* all done, no more packets present */
+		netif_rx_complete(dev);
+
+		/* re-enable receive interrupts */
+		pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
+				       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
+		return 0;
+	} else {
+		/* used up our quantum, so reschedule */
+		dev->quota -= pkts;
+		*budget -= pkts;
+		return 1;
+	}
+}
+
+static int __devinit
+pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	static int index = 0;
+	struct net_device *dev;
+	struct pasemi_mac *mac;
+	int err;
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "pasemi_mac: Could not enable device.\n");
+		return err;
+	}
+	dev = alloc_etherdev(sizeof(struct pasemi_mac));
+	if (dev == NULL) {
+		dev_err(&pdev->dev,
+			"pasemi_mac: Could not allocate ethernet device.\n");
+		return -ENOMEM;
+	}
+
+	SET_MODULE_OWNER(dev);
+	pci_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	mac = netdev_priv(dev);
+
+	mac->pdev = pdev;
+	mac->netdev = dev;
+	mac->dma_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa007, NULL);
+
+	if (!mac->dma_pdev) {
+		dev_err(&pdev->dev, "Can't find DMA Controller\n");
+		free_netdev(dev);
+		return -ENODEV;
+	}
+
+	mac->iob_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
+
+	if (!mac->iob_pdev) {
+		dev_err(&pdev->dev, "Can't find I/O Bridge\n");
+		free_netdev(dev);
+		return -ENODEV;
+	}
+
+	/* These should come out of the device tree eventually */
+	mac->dma_txch = index;
+	mac->dma_rxch = index;
+
+	/* We probe GMAC before XAUI, but the DMA interfaces are
+	 * in XAUI, GMAC order.
+	 */
+	if (index < 4)
+		mac->dma_if = index + 2;
+	else
+		mac->dma_if = index - 4;
+	index++;
+
+	switch (pdev->device) {
+	case 0xa005:
+		mac->type = MAC_TYPE_GMAC;
+		break;
+	case 0xa006:
+		mac->type = MAC_TYPE_XAUI;
+		break;
+	default:
+		err = -ENODEV;
+		goto out;
+	}
+
+	/* get mac addr from device tree */
+	if (pasemi_set_mac_addr(mac) || !is_valid_ether_addr(mac->mac_addr)) {
+		err = -ENODEV;
+		goto out;
+	}
+	memcpy(dev->dev_addr, mac->mac_addr, sizeof(mac->mac_addr));
+
+	dev->open = pasemi_mac_open;
+	dev->stop = pasemi_mac_close;
+	dev->hard_start_xmit = pasemi_mac_start_tx;
+	dev->get_stats = pasemi_mac_get_stats;
+	dev->set_multicast_list = pasemi_mac_set_rx_mode;
+	dev->weight = 64;
+	dev->poll = pasemi_mac_poll;
+	dev->features = NETIF_F_HW_CSUM;
+
+	/* The dma status structure is located in the I/O bridge, and
+	 * is cache coherent.
+	 */
+	if (!dma_status)
+		/* XXXOJN This should come from the device tree */
+		dma_status = __ioremap(0xfd800000, 0x1000, 0);
+
+	mac->rx_status = &dma_status->rx_sta[mac->dma_rxch];
+	mac->tx_status = &dma_status->tx_sta[mac->dma_txch];
+
+	err = register_netdev(dev);
+
+	if (err) {
+		dev_err(&mac->pdev->dev, "register_netdev failed with error %d\n",
+			err);
+		goto out;
+	} else
+		printk(KERN_INFO "%s: PA Semi %s: intf %d, txch %d, rxch %d, "
+		       "hw addr %02x:%02x:%02x:%02x:%02x:%02x\n",
+		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
+		       mac->dma_if, mac->dma_txch, mac->dma_rxch,
+		       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
+		       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+
+	return err;
+
+out:
+	dev_err(&mac->pdev->dev, "pasemi_mac: init failed\n");
+
+	pci_disable_device(pdev);
+	pci_dev_put(mac->dma_pdev);
+	pci_dev_put(mac->iob_pdev);
+	free_netdev(dev);
+	return err;
+}
+
+static void __devexit pasemi_mac_remove(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct pasemi_mac *mac;
+
+	if (!netdev)
+		return;
+
+	mac = netdev_priv(netdev);
+
+	unregister_netdev(netdev);
+
+	pci_disable_device(pdev);
+	pci_dev_put(mac->dma_pdev);
+	pci_dev_put(mac->iob_pdev);
+
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(netdev);
+}
+
+static struct pci_device_id pasemi_mac_pci_tbl[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa005) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa006) },
+	{ 0 }
+};
+
+MODULE_DEVICE_TABLE(pci, pasemi_mac_pci_tbl);
+
+static struct pci_driver pasemi_mac_driver = {
+	.name		= "pasemi_mac",
+	.id_table	= pasemi_mac_pci_tbl,
+	.probe		= pasemi_mac_probe,
+	.remove		= __devexit_p(pasemi_mac_remove),
+};
+
+static void __exit pasemi_mac_cleanup_module(void)
+{
+	pci_unregister_driver(&pasemi_mac_driver);
+	__iounmap(dma_status);
+	dma_status = NULL;
+}
+
+int pasemi_mac_init_module(void)
+{
+	return pci_register_driver(&pasemi_mac_driver);
+}
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR ("Olof Johansson <olof@lixom.net>");
+MODULE_DESCRIPTION("PA Semi PWRficient Ethernet driver");
+
+module_init(pasemi_mac_init_module);
+module_exit(pasemi_mac_cleanup_module);
Index: merge/drivers/net/pasemi_mac.h
===================================================================
--- /dev/null
+++ merge/drivers/net/pasemi_mac.h
@@ -0,0 +1,443 @@
+/*
+ * Copyright (C) 2006 PA Semi, Inc
+ *
+ * Driver for the PA6T-1682M onchip 1G/10G Ethernet MACs, soft state and
+ * hardware register layouts.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ */
+
+#ifndef PASEMI_MAC_H
+#define PASEMI_MAC_H
+
+#include <linux/ethtool.h>
+#include <linux/netdevice.h>
+#include <linux/spinlock.h>
+
+struct pasemi_mac_txring {
+	spinlock_t	 lock;
+	struct pas_dma_xct_descr	*desc;
+	dma_addr_t	 dma;
+	unsigned int	 size;
+	unsigned int	 count;
+	unsigned int	 next_to_use;
+	unsigned int	 next_to_clean;
+	unsigned short	 last_count;
+	struct pasemi_mac_buffer *desc_info;
+	char		 irq_name[10];  /* "eth%d tx" */
+};
+
+struct pasemi_mac_rxring {
+	spinlock_t	 lock;
+	struct pas_dma_xct_descr	*desc;	/* RX channel descriptor ring */
+	dma_addr_t	 dma;
+	u64		*buffers;	/* RX interface buffer ring */
+	dma_addr_t	 buf_dma;
+	unsigned int	 size;
+	unsigned int	 count;
+	unsigned int	 next_to_fill;
+	unsigned int	 next_to_clean;
+	unsigned short	 last_count;
+	struct pasemi_mac_buffer *desc_info;
+	char		 irq_name[10];  /* "eth%d rx" */
+};
+
+/* Number of unused descriptors, considering ring wraparounds */
+#define PASEMI_MAC_DESC_UNUSED(ring) ((((ring)->next_to_clean >		\
+					(ring)->next_to_use) ?		\
+					  0 :				\
+					  (ring)->count) +		\
+					  (ring)->next_to_clean -	\
+					  (ring)->next_to_use - 1)
+
+struct pasemi_mac {
+	struct net_device *netdev;
+	struct pci_dev *pdev;
+	struct pci_dev *dma_pdev;
+	struct pci_dev *iob_pdev;
+	struct net_device_stats stats;
+
+	/* Pointer to the cacheable per-channel status registers */
+	u64	*rx_status;
+	u64	*tx_status;
+
+	u8		type;
+#define MAC_TYPE_GMAC	1
+#define MAC_TYPE_XAUI	2
+	u32	dma_txch;
+	u32	dma_if;
+	u32	dma_rxch;
+
+	u8		mac_addr[6];
+
+	struct timer_list	rxtimer;
+
+	struct pasemi_mac_txring *tx;
+	struct pasemi_mac_rxring *rx;
+};
+
+struct pasemi_mac_buffer {
+	struct sk_buff *skb;
+	dma_addr_t	dma;
+};
+
+
+
+#define PAS_MAC_CFG_PCFG		0x80
+#define    PAS_MAC_CFG_PCFG_PE		0x80000000
+#define    PAS_MAC_CFG_PCFG_CE		0x40000000
+#define    PAS_MAC_CFG_PCFG_BU		0x20000000
+#define    PAS_MAC_CFG_PCFG_TT		0x10000000
+#define    PAS_MAC_CFG_PCFG_TSR_M	0x0c000000
+#define    PAS_MAC_CFG_PCFG_TSR_10M	0x00000000
+#define    PAS_MAC_CFG_PCFG_TSR_100M	0x04000000
+#define    PAS_MAC_CFG_PCFG_TSR_1G	0x08000000
+#define    PAS_MAC_CFG_PCFG_TSR_10G	0x0c000000
+#define    PAS_MAC_CFG_PCFG_T24		0x02000000
+#define    PAS_MAC_CFG_PCFG_PR		0x01000000
+#define    PAS_MAC_CFG_PCFG_CRO_M	0x00ff0000
+#define    PAS_MAC_CFG_PCFG_CRO_S	16
+#define    PAS_MAC_CFG_PCFG_IPO_M	0x0000ff00
+#define    PAS_MAC_CFG_PCFG_IPO_S	8
+#define    PAS_MAC_CFG_PCFG_S1		0x00000080
+#define    PAS_MAC_CFG_PCFG_IO_M	0x00000060
+#define    PAS_MAC_CFG_PCFG_IO_MAC	0x00000000
+#define    PAS_MAC_CFG_PCFG_IO_OFF	0x00000020
+#define    PAS_MAC_CFG_PCFG_IO_IND_ETH	0x00000040
+#define    PAS_MAC_CFG_PCFG_IO_IND_IP	0x00000060
+#define    PAS_MAC_CFG_PCFG_LP		0x00000010
+#define    PAS_MAC_CFG_PCFG_TS		0x00000008
+#define    PAS_MAC_CFG_PCFG_HD		0x00000004
+#define    PAS_MAC_CFG_PCFG_SPD_M	0x00000003
+#define    PAS_MAC_CFG_PCFG_SPD_10M	0x00000000
+#define    PAS_MAC_CFG_PCFG_SPD_100M	0x00000001
+#define    PAS_MAC_CFG_PCFG_SPD_1G	0x00000002
+#define    PAS_MAC_CFG_PCFG_SPD_10G	0x00000003
+#define PAS_MAC_CFG_TXP			0x98
+#define    PAS_MAC_CFG_TXP_FCF		0x01000000
+#define    PAS_MAC_CFG_TXP_FCE		0x00800000
+#define    PAS_MAC_CFG_TXP_FC		0x00400000
+#define    PAS_MAC_CFG_TXP_FPC_M	0x00300000
+#define    PAS_MAC_CFG_TXP_FPC_S	20
+#define    PAS_MAC_CFG_TXP_FPC(x)	(((x) << PAS_MAC_CFG_TXP_FPC_S) & PAS_MAC_CFG_TXP_FPC_M)
+#define    PAS_MAC_CFG_TXP_RT		0x00080000
+#define    PAS_MAC_CFG_TXP_BL		0x00040000
+#define    PAS_MAC_CFG_TXP_SL_M		0x00030000
+#define    PAS_MAC_CFG_TXP_SL_S		16
+#define    PAS_MAC_CFG_TXP_SL(x)	(((x) << PAS_MAC_CFG_TXP_SL_S) & PAS_MAC_CFG_TXP_SL_M)
+#define    PAS_MAC_CFG_TXP_COB_M	0x0000f000
+#define    PAS_MAC_CFG_TXP_COB_S	12
+#define    PAS_MAC_CFG_TXP_COB(x)	(((x) << PAS_MAC_CFG_TXP_COB_S) & PAS_MAC_CFG_TXP_COB_M)
+#define    PAS_MAC_CFG_TXP_TIFT_M	0x00000f00
+#define    PAS_MAC_CFG_TXP_TIFT_S	8
+#define    PAS_MAC_CFG_TXP_TIFT(x)	(((x) << PAS_MAC_CFG_TXP_TIFT_S) & PAS_MAC_CFG_TXP_TIFT_M)
+#define    PAS_MAC_CFG_TXP_TIFG_M	0x000000ff
+#define    PAS_MAC_CFG_TXP_TIFG_S	0
+#define    PAS_MAC_CFG_TXP_TIFG(x)	(((x) << PAS_MAC_CFG_TXP_TIFG_S) & PAS_MAC_CFG_TXP_TIFG_M)
+
+#define PAS_MAC_IPC_CHNL		0x208
+#define    PAS_MAC_IPC_CHNL_DCHNO_M	0x003f0000
+#define    PAS_MAC_IPC_CHNL_DCHNO_S	16
+#define    PAS_MAC_IPC_CHNL_DCHNO(x)	(((x) << PAS_MAC_IPC_CHNL_DCHNO_S) & \
+					 PAS_MAC_IPC_CHNL_DCHNO_M)
+#define    PAS_MAC_IPC_CHNL_BCH_M	0x0000003f
+#define    PAS_MAC_IPC_CHNL_BCH_S	0
+#define    PAS_MAC_IPC_CHNL_BCH(x)	(((x) << PAS_MAC_IPC_CHNL_BCH_S) & \
+					 PAS_MAC_IPC_CHNL_BCH_M)
+
+/* All these registers live in the PCI configuration space for the DMA PCI
+ * device. Use the normal PCI config access functions for them.
+ */
+
+#define PAS_DMA_COM_TXCMD	0x100	/* Transmit Command Register  */
+#define    PAS_DMA_COM_TXCMD_EN		0x00000001 /* enable */
+#define PAS_DMA_COM_TXSTA	0x104	/* Transmit Status Register   */
+#define    PAS_DMA_COM_TXSTA_ACT	0x00000001 /* active */
+#define PAS_DMA_COM_RXCMD	0x108	/* Receive Command Register   */
+#define    PAS_DMA_COM_RXCMD_EN		0x00000001 /* enable */
+#define PAS_DMA_COM_RXSTA	0x10c	/* Receive Status Register    */
+#define    PAS_DMA_COM_RXSTA_ACT	0x00000001 /* active */
+
+
+#define _PAS_DMA_RXINT_STRIDE		0x20
+#define PAS_DMA_RXINT_RCMDSTA(i)	(0x200+(i)*_PAS_DMA_RXINT_STRIDE)
+#define    PAS_DMA_RXINT_RCMDSTA_EN	0x00000001
+#define    PAS_DMA_RXINT_RCMDSTA_ST	0x00000002
+#define    PAS_DMA_RXINT_RCMDSTA_OO	0x00000100
+#define    PAS_DMA_RXINT_RCMDSTA_BP	0x00000200
+#define    PAS_DMA_RXINT_RCMDSTA_DR	0x00000400
+#define    PAS_DMA_RXINT_RCMDSTA_BT	0x00000800
+#define    PAS_DMA_RXINT_RCMDSTA_TB	0x00001000
+#define    PAS_DMA_RXINT_RCMDSTA_ACT	0x00010000
+#define    PAS_DMA_RXINT_RCMDSTA_DROPS_M	0xfffe0000
+#define    PAS_DMA_RXINT_RCMDSTA_DROPS_S	17
+#define PAS_DMA_RXINT_INCR(i)		(0x210+(i)*_PAS_DMA_RXINT_STRIDE)
+#define    PAS_DMA_RXINT_INCR_INCR_M	0x0000ffff
+#define    PAS_DMA_RXINT_INCR_INCR_S	0
+#define    PAS_DMA_RXINT_INCR_INCR(x)	((x) & 0x0000ffff)
+#define PAS_DMA_RXINT_BASEL(i)		(0x218+(i)*_PAS_DMA_RXINT_STRIDE)
+#define    PAS_DMA_RXINT_BASEL_BRBL(x)	((x) & ~0x3f)
+#define PAS_DMA_RXINT_BASEU(i)		(0x21c+(i)*_PAS_DMA_RXINT_STRIDE)
+#define    PAS_DMA_RXINT_BASEU_BRBH(x)	((x) & 0xfff)
+#define    PAS_DMA_RXINT_BASEU_SIZ_M	0x3fff0000	/* # of cache lines worth of buffer ring */
+#define    PAS_DMA_RXINT_BASEU_SIZ_S	16		/* 0 = 16K */
+#define    PAS_DMA_RXINT_BASEU_SIZ(x)	(((x) << PAS_DMA_RXINT_BASEU_SIZ_S) & \
+					 PAS_DMA_RXINT_BASEU_SIZ_M)
+
+
+#define _PAS_DMA_TXCHAN_STRIDE	0x20    /* Size per channel		*/
+#define _PAS_DMA_TXCHAN_TCMDSTA	0x300	/* Command / Status		*/
+#define _PAS_DMA_TXCHAN_CFG	0x304	/* Configuration		*/
+#define _PAS_DMA_TXCHAN_DSCRBU	0x308	/* Descriptor BU Allocation	*/
+#define _PAS_DMA_TXCHAN_INCR	0x310	/* Descriptor increment		*/
+#define _PAS_DMA_TXCHAN_CNT	0x314	/* Descriptor count/offset	*/
+#define _PAS_DMA_TXCHAN_BASEL	0x318	/* Descriptor ring base (low)	*/
+#define _PAS_DMA_TXCHAN_BASEU	0x31c	/*			(high)	*/
+#define PAS_DMA_TXCHAN_TCMDSTA(c) (0x300+(c)*_PAS_DMA_TXCHAN_STRIDE)
+#define    PAS_DMA_TXCHAN_TCMDSTA_EN	0x00000001	/* Enabled */
+#define    PAS_DMA_TXCHAN_TCMDSTA_ST	0x00000002	/* Stop interface */
+#define    PAS_DMA_TXCHAN_TCMDSTA_ACT	0x00010000	/* Active */
+#define PAS_DMA_TXCHAN_CFG(c)     (0x304+(c)*_PAS_DMA_TXCHAN_STRIDE)
+#define    PAS_DMA_TXCHAN_CFG_TY_IFACE	0x00000000	/* Type = interface */
+#define    PAS_DMA_TXCHAN_CFG_TATTR_M	0x0000003c
+#define    PAS_DMA_TXCHAN_CFG_TATTR_S	2
+#define    PAS_DMA_TXCHAN_CFG_TATTR(x)	(((x) << PAS_DMA_TXCHAN_CFG_TATTR_S) & \
+					 PAS_DMA_TXCHAN_CFG_TATTR_M)
+#define    PAS_DMA_TXCHAN_CFG_WT_M	0x000001c0
+#define    PAS_DMA_TXCHAN_CFG_WT_S	6
+#define    PAS_DMA_TXCHAN_CFG_WT(x)	(((x) << PAS_DMA_TXCHAN_CFG_WT_S) & \
+					 PAS_DMA_TXCHAN_CFG_WT_M)
+#define    PAS_DMA_TXCHAN_CFG_CF	0x00001000	/* Clean first line */
+#define    PAS_DMA_TXCHAN_CFG_CL	0x00002000	/* Clean last line */
+#define    PAS_DMA_TXCHAN_CFG_UP	0x00004000	/* update tx descr when sent */
+#define PAS_DMA_TXCHAN_INCR(c)    (0x310+(c)*_PAS_DMA_TXCHAN_STRIDE)
+#define PAS_DMA_TXCHAN_BASEL(c)   (0x318+(c)*_PAS_DMA_TXCHAN_STRIDE)
+#define    PAS_DMA_TXCHAN_BASEL_BRBL_M	0xffffffc0
+#define    PAS_DMA_TXCHAN_BASEL_BRBL_S	0
+#define    PAS_DMA_TXCHAN_BASEL_BRBL(x)	(((x) << PAS_DMA_TXCHAN_BASEL_BRBL_S) & \
+					 PAS_DMA_TXCHAN_BASEL_BRBL_M)
+#define PAS_DMA_TXCHAN_BASEU(c)   (0x31c+(c)*_PAS_DMA_TXCHAN_STRIDE)
+#define    PAS_DMA_TXCHAN_BASEU_BRBH_M	0x00000fff
+#define    PAS_DMA_TXCHAN_BASEU_BRBH_S	0
+#define    PAS_DMA_TXCHAN_BASEU_BRBH(x)	(((x) << PAS_DMA_TXCHAN_BASEU_BRBH_S) & \
+					 PAS_DMA_TXCHAN_BASEU_BRBH_M)
+/* # of cache lines worth of buffer ring */
+#define    PAS_DMA_TXCHAN_BASEU_SIZ_M	0x3fff0000
+#define    PAS_DMA_TXCHAN_BASEU_SIZ_S	16		/* 0 = 16K */
+#define    PAS_DMA_TXCHAN_BASEU_SIZ(x)	(((x) << PAS_DMA_TXCHAN_BASEU_SIZ_S) & \
+					 PAS_DMA_TXCHAN_BASEU_SIZ_M)
+
+#define _PAS_DMA_RXCHAN_STRIDE	0x20    /* Size per channel		*/
+#define _PAS_DMA_RXCHAN_CCMDSTA	0x800	/* Command / Status		*/
+#define _PAS_DMA_RXCHAN_CFG	0x804	/* Configuration		*/
+#define _PAS_DMA_RXCHAN_INCR	0x810	/* Descriptor increment		*/
+#define _PAS_DMA_RXCHAN_CNT	0x814	/* Descriptor count/offset	*/
+#define _PAS_DMA_RXCHAN_BASEL	0x818	/* Descriptor ring base (low)	*/
+#define _PAS_DMA_RXCHAN_BASEU	0x81c	/*			(high)	*/
+#define PAS_DMA_RXCHAN_CCMDSTA(c) (0x800+(c)*_PAS_DMA_RXCHAN_STRIDE)
+#define    PAS_DMA_RXCHAN_CCMDSTA_EN	0x00000001	/* Enabled */
+#define    PAS_DMA_RXCHAN_CCMDSTA_ST	0x00000002	/* Stop interface */
+#define    PAS_DMA_RXCHAN_CCMDSTA_ACT	0x00010000	/* Active */
+#define    PAS_DMA_RXCHAN_CCMDSTA_DU	0x00020000
+#define PAS_DMA_RXCHAN_CFG(c)     (0x804+(c)*_PAS_DMA_RXCHAN_STRIDE)
+#define    PAS_DMA_RXCHAN_CFG_HBU_M	0x00000380
+#define    PAS_DMA_RXCHAN_CFG_HBU_S	7
+#define    PAS_DMA_RXCHAN_CFG_HBU(x)	(((x) << PAS_DMA_RXCHAN_CFG_HBU_S) & \
+					 PAS_DMA_RXCHAN_CFG_HBU_M)
+#define PAS_DMA_RXCHAN_INCR(c)    (0x810+(c)*_PAS_DMA_RXCHAN_STRIDE)
+#define PAS_DMA_RXCHAN_BASEL(c)   (0x818+(c)*_PAS_DMA_RXCHAN_STRIDE)
+#define    PAS_DMA_RXCHAN_BASEL_BRBL_M	0xffffffc0
+#define    PAS_DMA_RXCHAN_BASEL_BRBL_S	0
+#define    PAS_DMA_RXCHAN_BASEL_BRBL(x)	(((x) << PAS_DMA_RXCHAN_BASEL_BRBL_S) & \
+					 PAS_DMA_RXCHAN_BASEL_BRBL_M)
+#define PAS_DMA_RXCHAN_BASEU(c)   (0x81c+(c)*_PAS_DMA_RXCHAN_STRIDE)
+#define    PAS_DMA_RXCHAN_BASEU_BRBH_M	0x00000fff
+#define    PAS_DMA_RXCHAN_BASEU_BRBH_S	0
+#define    PAS_DMA_RXCHAN_BASEU_BRBH(x)	(((x) << PAS_DMA_RXCHAN_BASEU_BRBH_S) & \
+					 PAS_DMA_RXCHAN_BASEU_BRBH_M)
+/* # of cache lines worth of buffer ring */
+#define    PAS_DMA_RXCHAN_BASEU_SIZ_M	0x3fff0000
+#define    PAS_DMA_RXCHAN_BASEU_SIZ_S	16		/* 0 = 16K */
+#define    PAS_DMA_RXCHAN_BASEU_SIZ(x)	(((x) << PAS_DMA_RXCHAN_BASEU_SIZ_S) & \
+					 PAS_DMA_RXCHAN_BASEU_SIZ_M)
+
+/* status register layout in IOB region, at 0xfb800000 */
+struct pasdma_status {
+	u64 rx_sta[64];
+	u64 tx_sta[20];
+};
+
+#define    PAS_STATUS_PCNT_M		0x000000000000ffff
+#define    PAS_STATUS_PCNT_S		0
+#define    PAS_STATUS_DCNT_M		0x00000000ffff0000
+#define    PAS_STATUS_DCNT_S		16
+#define    PAS_STATUS_BPCNT_M		0x0000ffff00000000
+#define    PAS_STATUS_BPCNT_S		32
+#define    PAS_STATUS_TIMER		0x1000000000000000
+#define    PAS_STATUS_ERROR		0x2000000000000000
+#define    PAS_STATUS_SOFT		0x4000000000000000
+#define    PAS_STATUS_INT		0x8000000000000000
+
+#define PAS_IOB_DMA_RXCH_CFG(i)		(0x1100 + (i)*4)
+#define    PAS_IOB_DMA_RXCH_CFG_CNTTH_M		0x00000fff
+#define    PAS_IOB_DMA_RXCH_CFG_CNTTH_S		0
+#define    PAS_IOB_DMA_RXCH_CFG_CNTTH(x)	(((x) << PAS_IOB_DMA_RXCH_CFG_CNTTH_S) & \
+						 PAS_IOB_DMA_RXCH_CFG_CNTTH_M)
+#define PAS_IOB_DMA_TXCH_CFG(i)		(0x1200 + (i)*4)
+#define    PAS_IOB_DMA_TXCH_CFG_CNTTH_M		0x00000fff
+#define    PAS_IOB_DMA_TXCH_CFG_CNTTH_S		0
+#define    PAS_IOB_DMA_TXCH_CFG_CNTTH(x)	(((x) << PAS_IOB_DMA_TXCH_CFG_CNTTH_S) & \
+						 PAS_IOB_DMA_TXCH_CFG_CNTTH_M)
+#define PAS_IOB_DMA_RXCH_STAT(i)	(0x1300 + (i)*4)
+#define    PAS_IOB_DMA_RXCH_STAT_INTGEN	0x00001000
+#define    PAS_IOB_DMA_RXCH_STAT_CNTDEL_M	0x00000fff
+#define    PAS_IOB_DMA_RXCH_STAT_CNTDEL_S	0
+#define    PAS_IOB_DMA_RXCH_STAT_CNTDEL(x)	(((x) << PAS_IOB_DMA_RXCH_STAT_CNTDEL_S) &\
+						 PAS_IOB_DMA_RXCH_STAT_CNTDEL_M)
+#define PAS_IOB_DMA_TXCH_STAT(i)	(0x1400 + (i)*4)
+#define    PAS_IOB_DMA_TXCH_STAT_INTGEN	0x00001000
+#define    PAS_IOB_DMA_TXCH_STAT_CNTDEL_M	0x00000fff
+#define    PAS_IOB_DMA_TXCH_STAT_CNTDEL_S	0
+#define    PAS_IOB_DMA_TXCH_STAT_CNTDEL(x)	(((x) << PAS_IOB_DMA_TXCH_STAT_CNTDEL_S) &\
+						 PAS_IOB_DMA_TXCH_STAT_CNTDEL_M)
+#define PAS_IOB_DMA_RXCH_RESET(i)	(0x1500 + (i)*4)
+#define    PAS_IOB_DMA_RXCH_RESET_PCNT_M	0xffff0000
+#define    PAS_IOB_DMA_RXCH_RESET_PCNT_S	0
+#define    PAS_IOB_DMA_RXCH_RESET_PCNT(x)	(((x) << PAS_IOB_DMA_RXCH_RESET_PCNT_S) & \
+						 PAS_IOB_DMA_RXCH_RESET_PCNT_M)
+#define    PAS_IOB_DMA_RXCH_RESET_PCNTRST	0x00000020
+#define    PAS_IOB_DMA_RXCH_RESET_DCNTRST	0x00000010
+#define    PAS_IOB_DMA_RXCH_RESET_TINTC		0x00000008
+#define    PAS_IOB_DMA_RXCH_RESET_DINTC		0x00000004
+#define    PAS_IOB_DMA_RXCH_RESET_SINTC		0x00000002
+#define    PAS_IOB_DMA_RXCH_RESET_PINTC		0x00000001
+#define PAS_IOB_DMA_TXCH_RESET(i)	(0x1600 + (i)*4)
+#define    PAS_IOB_DMA_TXCH_RESET_PCNT_M	0xffff0000
+#define    PAS_IOB_DMA_TXCH_RESET_PCNT_S	0
+#define    PAS_IOB_DMA_TXCH_RESET_PCNT(x)	(((x) << PAS_IOB_DMA_TXCH_RESET_PCNT_S) & \
+						 PAS_IOB_DMA_TXCH_RESET_PCNT_M)
+#define    PAS_IOB_DMA_TXCH_RESET_PCNTRST	0x00000020
+#define    PAS_IOB_DMA_TXCH_RESET_DCNTRST	0x00000010
+#define    PAS_IOB_DMA_TXCH_RESET_TINTC		0x00000008
+#define    PAS_IOB_DMA_TXCH_RESET_DINTC		0x00000004
+#define    PAS_IOB_DMA_TXCH_RESET_SINTC		0x00000002
+#define    PAS_IOB_DMA_TXCH_RESET_PINTC		0x00000001
+
+#define PAS_IOB_DMA_COM_TIMEOUTCFG		0x1700
+#define    PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT_M	0x00ffffff
+#define    PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT_S	0
+#define    PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(x)	(((x) << PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT_S) & \
+						 PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT_M)
+
+struct pas_dma_xct_descr {
+	union {
+ 		u64	mactx;
+#define	XCT_MACTX_T		0x8000000000000000
+#define	XCT_MACTX_ST		0x4000000000000000
+#define XCT_MACTX_NORES		0x0000000000000000
+#define XCT_MACTX_8BRES		0x1000000000000000
+#define XCT_MACTX_24BRES	0x2000000000000000
+#define XCT_MACTX_40BRES	0x3000000000000000
+#define XCT_MACTX_I		0x0800000000000000
+#define XCT_MACTX_O		0x0400000000000000
+#define XCT_MACTX_E		0x0200000000000000
+#define XCT_MACTX_VLAN_M	0x0180000000000000
+#define XCT_MACTX_VLAN_NOP	0x0000000000000000
+#define XCT_MACTX_VLAN_REMOVE	0x0080000000000000
+#define XCT_MACTX_VLAN_INSERT   0x0100000000000000
+#define XCT_MACTX_VLAN_REPLACE  0x0180000000000000
+#define XCT_MACTX_CRC_M		0x0060000000000000
+#define XCT_MACTX_CRC_NOP	0x0000000000000000
+#define XCT_MACTX_CRC_INSERT	0x0020000000000000
+#define XCT_MACTX_CRC_PAD	0x0040000000000000
+#define XCT_MACTX_CRC_REPLACE	0x0060000000000000
+#define XCT_MACTX_SS		0x0010000000000000
+#define XCT_MACTX_LLEN_M	0x00007fff00000000
+#define XCT_MACTX_LLEN_S	32ull
+#define XCT_MACTX_LLEN(x)	((((long)(x)) << XCT_MACTX_LLEN_S) & XCT_MACTX_LLEN_M)
+#define XCT_MACTX_IPH_M		0x00000000f8000000
+#define XCT_MACTX_IPH_S		27ull
+#define XCT_MACTX_IPH(x)	((((long)(x)) << XCT_MACTX_IPH_S) & XCT_MACTX_IPH_M)
+#define XCT_MACTX_IPO_M		0x0000000007c00000
+#define XCT_MACTX_IPO_S		22ull
+#define XCT_MACTX_IPO(x)	((((long)(x)) << XCT_MACTX_IPO_S) & XCT_MACTX_IPO_M)
+#define XCT_MACTX_CSUM_M	0x0000000000000060
+#define XCT_MACTX_CSUM_NOP	0x0000000000000000
+#define XCT_MACTX_CSUM_TCP	0x0000000000000040
+#define XCT_MACTX_CSUM_UDP	0x0000000000000060
+#define XCT_MACTX_V6		0x0000000000000010
+#define XCT_MACTX_C		0x0000000000000004
+#define XCT_MACTX_AL2		0x0000000000000002
+		u64	macrx;
+#define	XCT_MACRX_T		0x8000000000000000
+#define	XCT_MACRX_ST		0x4000000000000000
+#define XCT_MACRX_NORES		0x0000000000000000
+#define XCT_MACRX_8BRES		0x1000000000000000
+#define XCT_MACRX_24BRES	0x2000000000000000
+#define XCT_MACRX_40BRES	0x3000000000000000
+#define XCT_MACRX_O		0x0400000000000000
+#define XCT_MACRX_E		0x0200000000000000
+#define XCT_MACRX_FF		0x0100000000000000
+#define XCT_MACRX_PF		0x0080000000000000
+#define XCT_MACRX_OB		0x0040000000000000
+#define XCT_MACRX_OD		0x0020000000000000
+#define XCT_MACRX_FS		0x0010000000000000
+#define XCT_MACRX_NB_M		0x000fc00000000000
+#define XCT_MACRX_NB_S		46ULL
+#define XCT_MACRX_NB(x)		((((long)(x)) << XCT_MACRX_NB_S) & XCT_MACRX_NB_M)
+#define XCT_MACRX_LLEN_M	0x00003fff00000000
+#define XCT_MACRX_LLEN_S	32ULL
+#define XCT_MACRX_LLEN(x)	((((long)(x)) << XCT_MACRX_LLEN_S) & XCT_MACRX_LLEN_M)
+#define XCT_MACRX_CRC		0x0000000080000000
+#define XCT_MACRX_LEN_M		0x0000000060000000
+#define XCT_MACRX_LEN_TOOSHORT	0x0000000020000000
+#define XCT_MACRX_LEN_BELOWMIN	0x0000000040000000
+#define XCT_MACRX_LEN_TRUNC	0x0000000060000000
+#define XCT_MACRX_CAST_M	0x0000000018000000
+#define XCT_MACRX_CAST_UNI	0x0000000000000000
+#define XCT_MACRX_CAST_MULTI	0x0000000008000000
+#define XCT_MACRX_CAST_BROAD	0x0000000010000000
+#define XCT_MACRX_CAST_PAUSE	0x0000000018000000
+#define XCT_MACRX_VLC_M		0x0000000006000000
+#define XCT_MACRX_FM		0x0000000001000000
+#define XCT_MACRX_HTY_M		0x0000000000c00000
+#define XCT_MACRX_HTY_IPV4_OK	0x0000000000000000
+#define XCT_MACRX_HTY_IPV6 	0x0000000000400000
+#define XCT_MACRX_HTY_IPV4_BAD	0x0000000000800000
+#define XCT_MACRX_HTY_NONIP	0x0000000000c00000
+#define XCT_MACRX_IPP_M		0x00000000003f0000
+#define XCT_MACRX_IPP_S		16
+#define XCT_MACRX_CSUM_M	0x000000000000ffff
+#define XCT_MACRX_CSUM_S	0
+	};
+	union {
+		u64	ptr;
+#define XCT_PTR_T		0x8000000000000000
+#define XCT_PTR_LEN_M		0x7ffff00000000000
+#define XCT_PTR_LEN_S		44
+#define XCT_PTR_LEN(x)		((((long)(x)) << XCT_PTR_LEN_S) & XCT_PTR_LEN_M)
+#define XCT_PTR_ADDR_M		0x00000fffffffffff
+#define XCT_PTR_ADDR_S		0
+#define XCT_PTR_ADDR(x)		((((long)(x)) << XCT_PTR_ADDR_S) & XCT_PTR_ADDR_M)
+		u64	rxb;
+#define XCT_RXB_LEN_M		0x0ffff00000000000
+#define XCT_RXB_LEN_S		44
+#define XCT_RXB_LEN(x)		((((long)(x)) << XCT_PTR_LEN_S) & XCT_PTR_LEN_M)
+#define XCT_RXB_ADDR_M		0x00000fffffffffff
+#define XCT_RXB_ADDR_S		0
+#define XCT_RXB_ADDR(x)		((((long)(x)) << XCT_PTR_ADDR_S) & XCT_PTR_ADDR_M)
+	};
+};
+
+#endif /* PASEMI_MAC_H */
Index: merge/MAINTAINERS
===================================================================
--- merge.orig/MAINTAINERS
+++ merge/MAINTAINERS
@@ -2484,6 +2484,12 @@ L:	orinoco-devel@lists.sourceforge.net
 W:	http://www.nongnu.org/orinoco/
 S:	Maintained
 
+PA SEMI ETHERNET DRIVER
+P:	Olof Johansson
+M:	olof@lixom.net
+L:	netdev@vger.kernel.org
+S:	Maintained
+
 PARALLEL PORT SUPPORT
 P:	Phil Blundell
 M:	philb@gnu.org
Index: merge/include/linux/pci_ids.h
===================================================================
--- merge.orig/include/linux/pci_ids.h
+++ merge/include/linux/pci_ids.h
@@ -2064,6 +2064,8 @@
 #define PCI_VENDOR_ID_TDI               0x192E
 #define PCI_DEVICE_ID_TDI_EHCI          0x0101
 
+#define PCI_VENDOR_ID_PASEMI		0x1959
+
 #define PCI_VENDOR_ID_JMICRON		0x197B
 #define PCI_DEVICE_ID_JMICRON_JMB360	0x2360
 #define PCI_DEVICE_ID_JMICRON_JMB361	0x2361

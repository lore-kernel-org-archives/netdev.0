From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] PA Semi PWRficient Ethernet driver
Date: Mon, 29 Jan 2007 23:35:06 +0100
Message-ID: <20070129223506.GA29068@electric-eye.fr.zoreil.com>
References: <20070129060852.GA7814@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36394 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752088AbXA2Wgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 17:36:53 -0500
Content-Disposition: inline
In-Reply-To: <20070129060852.GA7814@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson <olof@lixom.net> :
> Driver for the PA Semi PWRficient on-chip Ethernet (1/10G)
> 
> Basic enablement, will be complemented with performance enhancements
> over time. PHY support will be added as well.

- The driver does not contain a single SMP locking instruction but
  http://www.pasemi.com claims the platform to be multicore.
  Is the driver really designed to be lockless ?

- Is there really no other choice than constantly accessing the
  registers of the device through pci_write_config_dword() ?
  No PCI BAR remappable area ?

- Is there a volunteer to maintain the driver ? If so the MAINTAINERS
  file should be updated (hint, hint).

- No known public documentation for the hardware ?

Inlined remarks below.

[...]
> Index: merge/drivers/net/pasemi_mac.c
> ===================================================================
> --- /dev/null
> +++ merge/drivers/net/pasemi_mac.c
> @@ -0,0 +1,797 @@
> +/*
> + * Copyright (C) 2006-2007 PA Semi, Inc
> + *
> + * Driver for the PA Semi PWRficient onchip 1G/10G Ethernet MACs
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
> + */
> +
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/pci.h>
> +#include <linux/interrupt.h>
> +#include <linux/dmaengine.h>
> +#include <linux/delay.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <asm/dma-mapping.h>
> +#include <linux/in.h>
> +#include <linux/skbuff.h>
> +
> +#include <linux/ip.h>
> +#include <linux/tcp.h>
> +#include <net/checksum.h>
> +
> +#include "pasemi_mac.h"
> +
> +#define INITIAL_RX_RING_SIZE 512
> +#define INITIAL_TX_RING_SIZE 512
> +
> +#define BUF_SIZE 2048

Is there a specific reason for this rather unusual size ?

> +
> +#define PAS_DMA_MAX_IF     40
> +#define PAS_DMA_MAX_RXCH   8
> +#define PAS_DMA_MAX_TXCH   8
> +
> +/* XXXOJN these should come out of the device tree some day */
> +#define PAS_DMA_CAP_BASE   0xe00d0040
> +#define PAS_DMA_CAP_SIZE   0x100
> +#define PAS_DMA_COM_BASE   0xe00d0100
> +#define PAS_DMA_COM_SIZE   0x100
> +
> +static irqreturn_t pasemi_mac_tx_intr(int, void *);
> +static irqreturn_t pasemi_mac_rx_intr(int, void *);
> +static int pasemi_mac_clean_tx(struct pasemi_mac *mac);
> +static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit);

Reorder and remove the forward declarations ?

> +
> +static struct pasdma_status *dma_status;
> +
> +static int pasemi_set_mac_addr(struct pasemi_mac *mac)
> +{
> +	struct pci_dev *pdev = mac->pdev;
> +	struct device_node *dn = pci_device_to_OF_node(pdev);
> +	const u8 *maddr;
> +	u8 addr[6];
> +
> +	if (!dn) {
> +		dev_dbg(&pdev->dev,
> +			  "No device node for mac, not configuring\n");
> +		return -ENOENT;
> +	}
> +
> +	maddr = get_property(dn, "mac-address", NULL);
> +	if (maddr == NULL) {
> +		dev_warn(&pdev->dev,
> +			 "no mac address in device tree, not configuring\n");
> +		return -ENOENT;
> +	}
> +
> +	if (sscanf(maddr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", &addr[0],
> +		   &addr[1], &addr[2], &addr[3], &addr[4], &addr[5]) != 6) {
> +		dev_warn(&pdev->dev,
> +			 "can't parse mac address, not configuring\n");
> +		return -EINVAL;
> +	}
> +
> +	memcpy(mac->mac_addr, addr, sizeof(addr));

Add a check for is_valid_ether_addr() ?

> +	return 0;
> +}
> +
> +static void pasemi_mac_setup_rx_resources(struct net_device *dev)
> +{
> +	struct pasemi_mac_rxring *ring;
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	int chan_id = mac->dma_rxch;
> +
> +	ring = kzalloc(sizeof(*ring), GFP_KERNEL);

k*alloc can fail. Please check !ring.

> +
> +	ring->count = INITIAL_RX_RING_SIZE;
> +
> +	ring->desc_info = kzalloc(sizeof(struct pasemi_mac_buffer)*ring->count,
> +				  GFP_KERNEL);
> +
> +	/* Allocate descriptors */
> +	ring->desc = (void *)__get_free_pages(GFP_KERNEL,
> +				      get_order(ring->count *
> +				      sizeof(struct pas_dma_xct_descr)));
> +	ring->dma = virt_to_phys(ring->desc);
> +	memset(ring->desc, 0, ring->count * sizeof(struct pas_dma_xct_descr));
> +
> +	ring->buffers = (void *)__get_free_pages(GFP_KERNEL,
> +					 get_order(ring->count * sizeof(u64)));
> +	ring->buf_dma = virt_to_phys(ring->buffers);
> +	memset(ring->buffers, 0, ring->count * sizeof(u64));

Use pci_alloc_consistent() ?

> +
> +	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXCHAN_BASEL(chan_id),
> +			       PAS_DMA_RXCHAN_BASEL_BRBL(ring->dma));
> +
> +	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXCHAN_BASEU(chan_id),
> +			       PAS_DMA_RXCHAN_BASEU_BRBH(ring->dma >> 32) |
> +			       PAS_DMA_RXCHAN_BASEU_SIZ(INITIAL_RX_RING_SIZE >> 2));
> +
> +	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXCHAN_CFG(chan_id),
> +			       PAS_DMA_RXCHAN_CFG_HBU(1));
> +
> +	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXINT_BASEL(mac->dma_if),
> +			       PAS_DMA_RXINT_BASEL_BRBL(__pa(ring->buffers)));
> +
> +	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXINT_BASEU(mac->dma_if),
> +			       PAS_DMA_RXINT_BASEU_BRBH(__pa(ring->buffers) >> 32) |
> +			       PAS_DMA_RXINT_BASEU_SIZ(INITIAL_RX_RING_SIZE >> 3));
> +
> +	ring->next_to_fill = 0; ring->next_to_clean = 0;

Line feed please.

> +	mac->rx = ring;
> +}
> +
> +
> +static void pasemi_mac_setup_tx_resources(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	u32 val;
> +	int chan_id = mac->dma_txch;
> +	struct pasemi_mac_txring *ring;
> +
> +	ring = kzalloc(sizeof(*ring), GFP_KERNEL);

k*alloc can fail.

> +
> +	ring->count = INITIAL_TX_RING_SIZE;
> +
> +	ring->desc_info = kzalloc(sizeof(struct pasemi_mac_buffer)*ring->count,
> +				  GFP_KERNEL);
> +	/* Allocate descriptors */
> +	ring->desc = (void *)__get_free_pages(GFP_KERNEL,
> +				      get_order(ring->count *
> +				      sizeof(struct pas_dma_xct_descr)));
> +	ring->dma = virt_to_phys(ring->desc);
> +
> +	memset(ring->desc, 0, ring->count * sizeof(struct pas_dma_xct_descr));

Use pci_alloc_consistent() ?

> +
> +	pci_write_config_dword(mac->dma_pdev, PAS_DMA_TXCHAN_BASEL(chan_id),
> +			       PAS_DMA_TXCHAN_BASEL_BRBL(ring->dma));
> +	val = PAS_DMA_TXCHAN_BASEU_BRBH(ring->dma >> 32);
> +	val |= PAS_DMA_TXCHAN_BASEU_SIZ(INITIAL_TX_RING_SIZE >> 2);
> +
> +	pci_write_config_dword(mac->dma_pdev, PAS_DMA_TXCHAN_BASEU(chan_id), val);
> +
> +	pci_write_config_dword(mac->dma_pdev, PAS_DMA_TXCHAN_CFG(chan_id),
> +			       PAS_DMA_TXCHAN_CFG_TY_IFACE |
> +			       PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
> +			       PAS_DMA_TXCHAN_CFG_UP |
> +			       PAS_DMA_TXCHAN_CFG_WT(2));
> +
> +	ring->next_to_use = 0; ring->next_to_clean = 0;

Line feed please.

> +	mac->tx = ring;
> +}
> +
> +static noinline void pasemi_mac_free_resources(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	int i;

unsigned int is supposed to save some cycles on ppc.

> +
> +	for (i = 0; i < mac->tx->count; i++) {
> +		if (INFO(mac->tx, i).dma) {
> +			pr_debug("cleaning tx %d, dma addr %lx\n", i, INFO(mac->tx, i).dma);
> +			if (INFO(mac->tx, i).skb)
> +				dev_kfree_skb_any(INFO(mac->tx, i).skb);
> +			INFO(mac->tx, i).dma = 0;
> +			INFO(mac->tx, i).skb = 0;
> +			DESCR(mac->tx, i).mactx = 0;
> +			DESCR(mac->tx, i).ptr = 0;
> +		}
> +	}
> +
> +	/* Add free of all data structures here */
> +	free_pages((unsigned long)mac->tx->desc, get_order(
> +			mac->tx->count * sizeof(struct pas_dma_xct_descr)));
> +
> +	kfree(mac->tx);
> +	mac->tx = NULL;
> +
> +	for (i = 0; i < mac->rx->count; i++) {
> +		if (INFO(mac->rx, i).dma) {
> +			pr_debug("cleaning rx %d, dma addr %lx\n", i, INFO(mac->rx, i).dma);
> +			if (INFO(mac->rx, i).skb)
> +				dev_kfree_skb_any(INFO(mac->rx, i).skb);
> +			INFO(mac->rx, i).dma = 0;
> +			INFO(mac->rx, i).skb = 0;
> +			DESCR(mac->rx, i).macrx = 0;
> +			DESCR(mac->rx, i).ptr = 0;
> +		}
> +	}
> +
> +	free_pages((unsigned long)mac->rx->desc, get_order(mac->rx->count *
> +		   sizeof(struct pas_dma_xct_descr)));
> +
> +	free_pages((unsigned long)mac->rx->buffers,
> +		   get_order(mac->rx->count * sizeof(u64)));
> +
> +	kfree(mac->rx);
> +	mac->rx = NULL;
> +}
> +
> +static void pasemi_mac_replenish_rx_ring(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int i;
> +	dma_addr_t dma;
> +	struct sk_buff *skb;
> +	int start = mac->rx->next_to_fill;
> +	int count;
> +
> +	count = ((mac->rx->next_to_clean & ~7) + mac->rx->count -
> +		 mac->rx->next_to_fill) % mac->rx->count;
> +
> +	if (unlikely(mac->rx->next_to_clean == 0 && mac->rx->next_to_fill == 0)) {
> +		pr_debug("first time fill, clean %d fill %d\n",
> +			 mac->rx->next_to_clean, mac->rx->next_to_fill);
> +		count = mac->rx->count - 8;
> +	}
> +
> +	/* Limit so we don't go into the last cache line */
> +	count -= 8;
> +
> +	if (count <= 0)
> +		return;
> +
> +	for (i = start; i < start+count; i++) {
                                ^^^
> +		skb = dev_alloc_skb(BUF_SIZE);
> +
> +		if (!skb)
> +			return;
> +
> +		skb->dev = dev;
> +
> +		dma = virt_to_phys(skb->data);

Use pci_map_single() and friends ?

It is described in Documentation/DMA-mapping.txt and widely used
in the in-kernel drivers.

[...]
> +static int pasemi_mac_open(struct net_device *dev)
> +{
[...]
> +	if (ret)
> +		printk("request_irq of irq %d failed: %d\n",
> +		       mac->dma_pdev->irq + mac->dma_txch, ret);


Missing KERN_XYZ.

> +
> +	ret = request_irq(128 + 20 + mac->dma_rxch, &pasemi_mac_rx_intr,
> +			  IRQF_DISABLED, "pasemi_mac rx", dev);
> +	if (ret)
> +		printk("request_irq of irq %d failed: %d\n",
> +		       mac->dma_pdev->irq + 20 + mac->dma_rxch, ret);

Missing KERN_XYZ.

[...]
> +static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	struct pasemi_mac_txring *txring;
> +	u64 flags;
> +	dma_addr_t map;
> +
> +	if (mac->tx->next_to_clean+mac->tx->count == mac->tx->next_to_use)
> +		pasemi_mac_clean_tx(mac);
> +
> +	mac->stats.tx_packets++;
> +	mac->stats.tx_bytes += skb->len;
> +
> +	txring = mac->tx;
> +
> +	flags = XCT_MACTX_O | XCT_MACTX_ST |
> +		XCT_MACTX_SS | XCT_MACTX_CRC_PAD;
> +
> +	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +		switch (skb->nh.iph->protocol) {
> +		case IPPROTO_TCP:
> +			flags |= XCT_MACTX_CSUM_TCP;
> +			flags |= XCT_MACTX_IPH((skb->h.raw - skb->nh.raw) >> 2);
> +			flags |= XCT_MACTX_IPO(skb->nh.raw - skb->data);
> +			break;
> +		case IPPROTO_UDP:
> +			flags |= XCT_MACTX_CSUM_UDP;
> +			flags |= XCT_MACTX_IPH((skb->h.raw - skb->nh.raw) >> 2);
> +			flags |= XCT_MACTX_IPO(skb->nh.raw - skb->data);
> +			break;
> +		}
> +	}
> +
> +	map = virt_to_phys(skb->data);

Use pci_map_single() and friends ?

> +
> +	DESCR(txring, txring->next_to_use).mactx = flags |
> +						XCT_MACTX_LLEN(skb->len);
> +	DESCR(txring, txring->next_to_use).ptr = XCT_PTR_LEN(skb->len) |
> +						XCT_PTR_ADDR(map);
> +	INFO(txring, txring->next_to_use).dma = map;
> +	INFO(txring, txring->next_to_use).skb = skb;
> +	/* XXXOJN Deal with fragmented packets when larger MTU is supported */
> +
> +	txring->next_to_use++;
> +
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_TXCHAN_INCR(mac->dma_txch), 1);
> +
> +	return NETDEV_TX_OK;

How is the TX process stopped when the ring gets full ?

> +}
> +
> +static struct net_device_stats *pasemi_mac_get_stats(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +
> +	return &mac->stats;
> +}
> +
> +static void pasemi_mac_set_rx_mode(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int flags;
> +
> +	return;

Huh ?

> +
> +	pci_read_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, &flags);
> +
> +	/* Set promiscuous */
> +	if (dev->flags & IFF_PROMISC)
> +		flags |= PAS_MAC_CFG_PCFG_PR;
> +	else
> +		flags &= ~PAS_MAC_CFG_PCFG_PR;
> +
> +	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
> +}
> +
> +
> +static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
> +{
> +	int i, j;

unsigned int ?

Needlessly wide scope for j...

> +	struct pas_dma_xct_descr descr;
> +	struct pasemi_mac_buffer *info;
> +	struct sk_buff *skb;

... and for descr/info/skb...

> +	unsigned int len;
> +	int start;
> +	int count;
> +	dma_addr_t dma;

... and for dma.

> +
> +	start = mac->rx->next_to_clean;
> +	count = 0;
> +
> +	for (i = start; i < start+mac->rx->count && count < limit; i++) {
                                ^^^
I would not protest against a few parenthesis here and there.

> +		rmb();
> +		mb();

rmb() _and_ mb() ?

Btw a scroll of ancient incantation is available in
Documentation/memory-barriers.txt btw.

> +		descr = DESCR(mac->rx, i);
> +		if (!(descr.macrx & XCT_MACRX_O))
> +			break;
> +
> +		count++;
> +
> +		info = NULL;
> +
> +		/* We have to scan for our skb since there's no way
> +		 * to back-map them from the descriptor, and if we
> +		 * have several receive channels then they might not
> +		 * show up in the same order as they were put on the
> +		 * interface ring.
> +		 */
> +
> +		dma = (descr.ptr & XCT_PTR_ADDR_M);
> +		for (j = start; j < start+mac->rx->count; j++)
> +			if (INFO(mac->rx, j).dma == dma) {
> +				info = &INFO(mac->rx, j);
> +				break;
> +			}

This is not a single line statement: please add curly-braces.

[...]
> +static int __devinit
> +pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> +{
[..]
> +	/* The dma status structure is located in the I/O bridge, and
> +	 * is cache coherent.
> +	 */
> +	if (!dma_status)
> +		/* XXXOJN This should come from the device tree */
> +		dma_status = __ioremap(0xfd800000, 0x1000, 0);

Is this address really set in stone or can it be retrieved after some
pci_get_device(...) practice ?

> +
> +	mac->rx_status = &dma_status->rx_sta[mac->dma_rxch];
> +	mac->tx_status = &dma_status->tx_sta[mac->dma_txch];

Addresses returned from ioremap are not guaranteed to be dereferencable
like that.

> +
> +	err = register_netdev(dev);
> +
> +	if (err)
> +		printk("register_netdev failed with error %d\n", err);

Missing KERN_XYZ.

> +	else
> +		printk(KERN_INFO "%s: PA Semi %s: intf %d, txch %d, rxch %d, "
> +		       "hw addr %02x:%02x:%02x:%02x:%02x:%02x\n",
> +		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
> +		       mac->dma_if, mac->dma_txch, mac->dma_rxch,
> +		       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
> +		       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
> +
> +	return err;
> +
> +out:
> +	printk(KERN_ERR "pasemi_mac: init failed\n");
> +
> +	pci_disable_device(pdev);
> +	free_netdev(dev);
> +	return err;
> +}
> +
> +static struct pci_device_id pasemi_mac_pci_tbl[] = {
> +	{ PCI_DEVICE(0x1959, 0xa005) },
> +	{ PCI_DEVICE(0x1959, 0xa006) },

Minor nit: just use a #define for the vendor ID and you will simply
submit a one-line removal the day pci_ids is updated.

> +	{ 0 }
> +};
> +
> +MODULE_DEVICE_TABLE(pci, pasemi_mac_pci_tbl);
> +
> +static struct pci_driver pasemi_mac_driver = {
> +	.name = "pasemi_mac",
> +	.id_table = pasemi_mac_pci_tbl,
> +	.probe = pasemi_mac_probe,

	.name		= "pasemi_mac",
	.id_table	= pasemi_mac_pci_tbl,
	.probe		= pasemi_mac_probe,
[...]
> Index: merge/drivers/net/pasemi_mac.h
> ===================================================================
> --- /dev/null
> +++ merge/drivers/net/pasemi_mac.h
[...]
> +/* Number of unused descriptors, considering ring wraparounds */
> +#define PASEMI_MAC_DESC_UNUSED(ring) ((((ring)->next_to_clean >		\
> +					(ring)->next_to_use) ?		\
> +					  0 :				\
> +					  (ring)->count) +		\
> +					  (ring)->next_to_clean -	\
> +					  (ring)->next_to_use - 1)
> +
> +#define DESCR(ring, i) ((ring)->desc[i % ((ring)->count)])
> +#define BUFF(ring, i) ((ring)->buffers[i % ((ring)->count)])
> +#define INFO(ring, i) ((ring)->desc_info[i % ((ring)->count)])

A bit ugly/obfuscating/name clash prone imvho.

Use local variables ?

> +
> +struct pasemi_mac {
> +	struct net_device *netdev;
> +	struct pci_dev *pdev;
> +	struct pci_dev *dma_pdev;
> +	struct pci_dev *iob_pdev;
> +	struct net_device_stats stats;
> +
> +	/* Pointer to the cacheable per-channel status registers */
> +	uint64_t	*rx_status;
> +	uint64_t	*tx_status;

No uintxy_t please. Use plain u64.

-- 
Ueimor

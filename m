From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [v3] PA Semi PWRficient Ethernet driver
Date: Wed, 31 Jan 2007 05:34:06 -0500
Message-ID: <45C0709E.9090103@garzik.org>
References: <20070129060852.GA7814@lixom.net> <20070130014434.GC18935@lixom.net> <20070131054457.GA32043@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55553 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932950AbXAaKeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 05:34:13 -0500
In-Reply-To: <20070131054457.GA32043@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> Driver for the PA Semi PWRficient on-chip Ethernet (1/10G)
> 
> Basic enablement, will be complemented with performance enhancements
> over time. PHY support will be added as well.
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

Looks generally pretty clean, well done.

Comments included inline...

> +#include "pasemi_mac.h"
> +
> +#define INITIAL_RX_RING_SIZE 512
> +#define INITIAL_TX_RING_SIZE 512
> +
> +#define BUF_SIZE 1646 /* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
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

consider enums rather than #define's for constants.  they generate 
symbols at the C level rather than cpp level, making the code more 
readable, providing more type information to the C compiler, and making 
symbols visible at the debugger level.

example:

enum {
	PAS_DMA_MAX_IF		= 40,
	PAS_DMA_MAX_RXCH	= 8,
	PAS_DMA_MAX_TXCH	= 8,
};

> +static int pasemi_set_mac_addr(struct pasemi_mac *mac)

poor name.  from the context of the code reader and driver, this should 
be "pasemi_GET_mac_addr", rather than ...set...
;

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
> +	return 0;
> +}
> +
> +
> +static noinline void pasemi_mac_free_tx_resources(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int i;
> +	struct pasemi_mac_buffer *info;
> +	struct pas_dma_xct_descr *dp;
> +
> +	for (i = 0; i < mac->tx->count; i++) {
> +		info = &mac->tx->desc_info[i % mac->tx->count];
> +		dp = &mac->tx->desc[i % mac->tx->count];
> +		if (info->dma) {
> +			if (info->skb) {
> +				pci_unmap_single(mac->dma_pdev,
> +						 info->dma,
> +						 info->skb->len,
> +						 PCI_DMA_TODEVICE);
> +				dev_kfree_skb_any(info->skb);
> +			}
> +			info->dma = 0;
> +			info->skb = 0;
> +			dp->mactx = 0;
> +			dp->ptr = 0;

"0" is not the same as "NULL".  Use NULL where appropriate.

Then make sure your driver passes sparse checks (read 
Documentation/sparse.txt)


> +	dma_free_coherent(&mac->dma_pdev->dev,
> +			  mac->tx->count * sizeof(struct pas_dma_xct_descr),
> +			  mac->tx->desc, mac->tx->dma);
> +
> +	kfree(mac->tx->desc_info);
> +	kfree(mac->tx);
> +	mac->tx = NULL;
> +}
> +
> +static noinline void pasemi_mac_free_rx_resources(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int i;
> +	struct pasemi_mac_buffer *info;
> +	struct pas_dma_xct_descr *dp;
> +
> +	for (i = 0; i < mac->rx->count; i++) {
> +		info = &mac->rx->desc_info[i % mac->rx->count];
> +		dp = &mac->rx->desc[i % mac->rx->count];
> +		if (info->dma) {
> +			if (info->skb) {
> +				pci_unmap_single(mac->dma_pdev,
> +						 info->dma,
> +						 info->skb->len,
> +						 PCI_DMA_FROMDEVICE);
> +				dev_kfree_skb_any(info->skb);
> +			}
> +			info->dma = 0;
> +			info->skb = 0;
> +			dp->macrx = 0;
> +			dp->ptr = 0;

0 != NULL


> +	dma_free_coherent(&mac->dma_pdev->dev,
> +			  mac->rx->count * sizeof(struct pas_dma_xct_descr),
> +			  mac->rx->desc, mac->rx->dma);
> +
> +	dma_free_coherent(&mac->dma_pdev->dev, mac->rx->count * sizeof(u64),
> +			  mac->rx->buffers, mac->rx->buf_dma);
> +
> +	kfree(mac->rx->desc_info);
> +	kfree(mac->rx);
> +	mac->rx = NULL;
> +}
> +
> +static void pasemi_mac_replenish_rx_ring(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int i;
> +	int start = mac->rx->next_to_fill;
> +	int count;
> +
> +	count = ((mac->rx->next_to_clean & ~7) + mac->rx->count -
> +		 mac->rx->next_to_fill) % mac->rx->count;

if feasible, logical operations are often more optimal than '%'

maybe you need something like tg3.c's NEXT_TX() ?


> +	if (unlikely(mac->rx->next_to_clean == 0 && mac->rx->next_to_fill == 0))
> +		count = mac->rx->count - 8;

why this is needed?

> +	/* Limit so we don't go into the last cache line */
> +	count -= 8;
> +
> +	if (count <= 0)
> +		return;
> +
> +	for (i = start; i < start + count; i++) {
> +		struct pasemi_mac_buffer *info = &mac->rx->desc_info[i % mac->rx->count];
> +		u64 *buff = &mac->rx->buffers[i % mac->rx->count];
> +		struct sk_buff *skb;
> +		dma_addr_t dma;
> +
> +		skb = dev_alloc_skb(BUF_SIZE);
> +
> +		if (!skb)
> +			return;
> +
> +		skb->dev = dev;
> +
> +		dma = pci_map_single(mac->dma_pdev, skb->data, skb->len,
> +				     PCI_DMA_FROMDEVICE);

check for DMA mapping error


> +		info->skb = skb;
> +		info->dma = dma;
> +		*buff = XCT_RXB_LEN(BUF_SIZE) | XCT_RXB_ADDR(dma);
> +	}
> +
> +	wmb();
> +
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_RXCHAN_INCR(mac->dma_rxch),
> +			       count);
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_RXINT_INCR(mac->dma_if),
> +			       count);
> +
> +	mac->rx->next_to_fill += count;
> +}
> +
> +static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
> +{
> +	unsigned int i;
> +	int start, count;
> +
> +	spin_lock(&mac->rx->lock);
> +
> +	start = mac->rx->next_to_clean;
> +	count = 0;
> +
> +	for (i = start; i < (start + mac->rx->count) && count < limit; i++) {
> +		struct pas_dma_xct_descr *dp;
> +		struct pasemi_mac_buffer *info;
> +		struct sk_buff *skb;
> +		unsigned int j, len;
> +		dma_addr_t dma;
> +
> +		rmb();
> +
> +		dp = &mac->rx->desc[i % mac->rx->count];
> +
> +		if (!(dp->macrx & XCT_MACRX_O))
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
> +		dma = (dp->ptr & XCT_PTR_ADDR_M);
> +		for (j = start; j < (start + mac->rx->count); j++) {
> +			info = &mac->rx->desc_info[j % mac->rx->count];
> +			if (info->dma == dma)
> +				break;
> +		}
> +
> +		BUG_ON(!info);
> +		BUG_ON(info->dma != dma);
> +
> +		pci_unmap_single(mac->dma_pdev, info->dma, info->skb->len,
> +				 PCI_DMA_FROMDEVICE);
> +
> +		skb = info->skb;
> +
> +		len = (dp->macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
> +
> +		skb_put(skb, len);
> +
> +		skb->protocol = eth_type_trans(skb, mac->netdev);
> +
> +		if ((dp->macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK) {
> +			skb->ip_summed = CHECKSUM_COMPLETE;
> +			skb->csum = (dp->macrx & XCT_MACRX_CSUM_M) >>
> +					   XCT_MACRX_CSUM_S;
> +		} else
> +			skb->ip_summed = CHECKSUM_NONE;
> +
> +		mac->stats.rx_bytes += len;
> +		mac->stats.rx_packets++;
> +
> +		netif_receive_skb(skb);
> +
> +		dp->ptr = 0;
> +		dp->macrx = 0;
> +		info->dma = 0;
> +		info->skb = 0;

0 != NULL


> +	mac->rx->next_to_clean += count;
> +	pasemi_mac_replenish_rx_ring(mac->netdev);
> +
> +	spin_unlock(&mac->rx->lock);
> +
> +	return count;
> +}
> +
> +static int pasemi_mac_clean_tx(struct pasemi_mac *mac)
> +{
> +	int i;
> +	struct pasemi_mac_buffer *info;
> +	struct pas_dma_xct_descr *dp;
> +	int start, count;
> +	int flags;
> +
> +	if (!spin_trylock_irqsave(&mac->tx->lock, flags))
> +		return 0;

what prevents starvation?


> +	start = mac->tx->next_to_clean;
> +	count = 0;
> +
> +	for (i = start; i < mac->tx->next_to_use; i++) {
> +		dp = &mac->tx->desc[i % mac->tx->count];
> +		if (!dp || (dp->mactx & XCT_MACTX_O))
> +			break;
> +
> +		count++;
> +
> +		info = &mac->tx->desc_info[i % mac->tx->count];
> +
> +		pci_unmap_single(mac->dma_pdev, info->dma,
> +				 info->skb->len, PCI_DMA_TODEVICE);
> +		dev_kfree_skb_irq(info->skb);
> +		info->skb = NULL;
> +		info->dma = 0;
> +		dp->mactx = 0;
> +		dp->ptr = 0;
> +	}
> +	mac->tx->next_to_clean += count;
> +	spin_unlock_irqrestore(&mac->tx->lock, flags);
> +
> +	return count;
> +}
> +
> +
> +static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
> +{
> +	struct net_device *dev = data;
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int reg;
> +
> +	if (!(*mac->rx_status & PAS_STATUS_INT))
> +		return IRQ_NONE;
> +
> +	netif_rx_schedule(dev);
> +	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
> +			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0));
> +
> +	reg = PAS_IOB_DMA_RXCH_RESET_PINTC | PAS_IOB_DMA_RXCH_RESET_SINTC |
> +	      PAS_IOB_DMA_RXCH_RESET_DINTC;
> +	if (*mac->rx_status & PAS_STATUS_TIMER)
> +		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
> +
> +	pci_write_config_dword(mac->iob_pdev,
> +			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);

is there any faster method of register reading/writing than through PCI 
config registers?

pci_{read,write}_config_foo acquires and releases a spinlock for each 
operation, making it rather expensive in fast path code


> +static int pasemi_mac_close(struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	unsigned int stat;
> +
> +	netif_stop_queue(dev);
> +
> +	/* Clean out any pending buffers */
> +	pasemi_mac_clean_tx(mac);
> +	pasemi_mac_clean_rx(mac, mac->rx->count);
> +
> +	/* Disable interface */
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
> +			       PAS_DMA_TXCHAN_TCMDSTA_ST);
> +	pci_write_config_dword(mac->dma_pdev,
> +		      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
> +		      PAS_DMA_RXINT_RCMDSTA_ST);
> +	pci_write_config_dword(mac->dma_pdev,
> +		      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
> +		      PAS_DMA_RXCHAN_CCMDSTA_ST);
> +
> +	do {
> +		pci_read_config_dword(mac->dma_pdev,
> +				      PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
> +				      &stat);
> +	} while (stat & PAS_DMA_TXCHAN_TCMDSTA_ACT);
> +
> +	do {
> +		pci_read_config_dword(mac->dma_pdev,
> +				      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
> +				      &stat);
> +	} while (stat & PAS_DMA_RXCHAN_CCMDSTA_ACT);
> +
> +	do {
> +		pci_read_config_dword(mac->dma_pdev,
> +				      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
> +				      &stat);
> +	} while (stat & PAS_DMA_RXINT_RCMDSTA_ACT);
> +
> +	/* Then, disable the channel. This must be done separately from
> +	 * stopping, since you can't disable when active.
> +	 */
> +
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch), 0);
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), 0);
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
> +
> +	synchronize_irq(mac->dma_pdev->irq + mac->dma_txch);
> +	synchronize_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch);
> +
> +	free_irq(mac->dma_pdev->irq + mac->dma_txch, dev);
> +	free_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch, dev);

shouldn't need synchronize_irq() right before free_irq()


> +	/* Free resources */
> +	pasemi_mac_free_rx_resources(dev);
> +	pasemi_mac_free_tx_resources(dev);
> +
> +	return 0;
> +}
> +
> +static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +	struct pasemi_mac_txring *txring;
> +	struct pasemi_mac_buffer *info;
> +	struct pas_dma_xct_descr *dp;
> +	u64 flags;
> +	dma_addr_t map;

needs locking, as mentioned elsewhere


> +	txring = mac->tx;
> +
> +	if (txring->next_to_clean + txring->count == txring->next_to_use) {
> +		pasemi_mac_clean_tx(mac);
> +
> +		if (txring->next_to_clean + txring->count == txring->next_to_use) {
> +			/* Still no room -- stop the queue and wait for tx
> +			 * intr when there's room.
> +			 */
> +			netif_stop_queue(dev);
> +			return NETDEV_TX_BUSY;
> +		}
> +	}
> +
> +	mac->stats.tx_packets++;
> +	mac->stats.tx_bytes += skb->len;
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
> +	map = pci_map_single(mac->dma_pdev, skb->data, skb->len, PCI_DMA_TODEVICE);

check for mapping error


> +	dp = &txring->desc[txring->next_to_use % txring->count];
> +	info = &txring->desc_info[txring->next_to_use % txring->count];
> +
> +	dp->mactx = flags | XCT_MACTX_LLEN(skb->len);
> +	dp->ptr = XCT_PTR_LEN(skb->len) | XCT_PTR_ADDR(map);
> +	info->dma = map;
> +	info->skb = skb;
> +	/* XXXOJN Deal with fragmented packets when larger MTU is supported */

does this comment imply that larger MTUs make the driver go splat, or 
does driver code elsewhere prevent the user from using an invalid MTU?


> +	txring->next_to_use++;
> +
> +	pci_write_config_dword(mac->dma_pdev,
> +			       PAS_DMA_TXCHAN_INCR(mac->dma_txch), 1);
> +
> +	return NETDEV_TX_OK;
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
> +	pci_read_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, &flags);
> +
> +	/* Set promiscuous */
> +	if (dev->flags & IFF_PROMISC)
> +		flags |= PAS_MAC_CFG_PCFG_PR;
> +	else
> +		flags &= ~PAS_MAC_CFG_PCFG_PR;
> +
> +	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);

you have no multicast capability?


> +static int pasemi_mac_poll(struct net_device *dev, int *budget)
> +{
> +	int pkts, limit = min(*budget, dev->quota);
> +	struct pasemi_mac *mac = netdev_priv(dev);
> +
> +	pkts = pasemi_mac_clean_rx(mac, limit);
> +
> +	if (pkts < limit) {
> +		/* all done, no more packets present */
> +		netif_rx_complete(dev);
> +
> +		/* re-enable receive interrupts */
> +		pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
> +				       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
> +		return 0;
> +	} else {
> +		/* used up our quantum, so reschedule */
> +		dev->quota -= pkts;
> +		*budget -= pkts;
> +		return 1;
> +	}
> +}
> +
> +static int __devinit
> +pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> +{
> +	static int index = 0;
> +	struct net_device *dev;
> +	struct pasemi_mac *mac;
> +	int err;
> +
> +	err = pci_enable_device(pdev);
> +	if (err) {
> +		dev_err(&pdev->dev, "pasemi_mac: Could not enable device.\n");
> +		return err;

PCI layer already prints out an error msg for this case


> +	dev = alloc_etherdev(sizeof(struct pasemi_mac));
> +	if (dev == NULL) {
> +		dev_err(&pdev->dev,
> +			"pasemi_mac: Could not allocate ethernet device.\n");
> +		return -ENOMEM;

call pci_disable_device() on error


> +	SET_MODULE_OWNER(dev);
> +	pci_set_drvdata(pdev, dev);
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	mac = netdev_priv(dev);
> +
> +	mac->pdev = pdev;
> +	mac->netdev = dev;
> +	mac->dma_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa007, NULL);
> +
> +	if (!mac->dma_pdev) {
> +		dev_err(&pdev->dev, "Can't find DMA Controller\n");
> +		free_netdev(dev);

undo pci_enable_device()
undo pci_set_drvdata()

> +		return -ENODEV;
> +	}
> +
> +	mac->iob_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
> +
> +	if (!mac->iob_pdev) {
> +		dev_err(&pdev->dev, "Can't find I/O Bridge\n");
> +		free_netdev(dev);

ditto


> +		return -ENODEV;
> +	}
> +
> +	/* These should come out of the device tree eventually */
> +	mac->dma_txch = index;
> +	mac->dma_rxch = index;
> +
> +	/* We probe GMAC before XAUI, but the DMA interfaces are
> +	 * in XAUI, GMAC order.
> +	 */
> +	if (index < 4)
> +		mac->dma_if = index + 2;
> +	else
> +		mac->dma_if = index - 4;
> +	index++;
> +
> +	switch (pdev->device) {
> +	case 0xa005:
> +		mac->type = MAC_TYPE_GMAC;
> +		break;
> +	case 0xa006:
> +		mac->type = MAC_TYPE_XAUI;
> +		break;
> +	default:
> +		err = -ENODEV;
> +		goto out;
> +	}
> +
> +	/* get mac addr from device tree */
> +	if (pasemi_set_mac_addr(mac) || !is_valid_ether_addr(mac->mac_addr)) {
> +		err = -ENODEV;
> +		goto out;
> +	}
> +	memcpy(dev->dev_addr, mac->mac_addr, sizeof(mac->mac_addr));
> +
> +	dev->open = pasemi_mac_open;
> +	dev->stop = pasemi_mac_close;
> +	dev->hard_start_xmit = pasemi_mac_start_tx;
> +	dev->get_stats = pasemi_mac_get_stats;
> +	dev->set_multicast_list = pasemi_mac_set_rx_mode;
> +	dev->weight = 64;
> +	dev->poll = pasemi_mac_poll;
> +	dev->features = NETIF_F_HW_CSUM;
> +
> +	/* The dma status structure is located in the I/O bridge, and
> +	 * is cache coherent.
> +	 */
> +	if (!dma_status)
> +		/* XXXOJN This should come from the device tree */
> +		dma_status = __ioremap(0xfd800000, 0x1000, 0);

why __ioremap ?


> +	mac->rx_status = &dma_status->rx_sta[mac->dma_rxch];
> +	mac->tx_status = &dma_status->tx_sta[mac->dma_txch];
> +
> +	err = register_netdev(dev);
> +
> +	if (err) {
> +		dev_err(&mac->pdev->dev, "register_netdev failed with error %d\n",
> +			err);
> +		goto out;
> +	} else
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
> +	dev_err(&mac->pdev->dev, "pasemi_mac: init failed\n");
> +
> +	pci_disable_device(pdev);
> +	pci_dev_put(mac->dma_pdev);
> +	pci_dev_put(mac->iob_pdev);
> +	free_netdev(dev);
> +	return err;
> +}
> +
> +static void __devexit pasemi_mac_remove(struct pci_dev *pdev)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct pasemi_mac *mac;
> +
> +	if (!netdev)
> +		return;
> +
> +	mac = netdev_priv(netdev);
> +
> +	unregister_netdev(netdev);
> +
> +	pci_disable_device(pdev);
> +	pci_dev_put(mac->dma_pdev);
> +	pci_dev_put(mac->iob_pdev);
> +
> +	pci_set_drvdata(pdev, NULL);
> +	free_netdev(netdev);
> +}
> +
> +static struct pci_device_id pasemi_mac_pci_tbl[] = {
> +	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa005) },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa006) },
> +	{ 0 }

remove the '0'


> +};
> +
> +MODULE_DEVICE_TABLE(pci, pasemi_mac_pci_tbl);
> +
> +static struct pci_driver pasemi_mac_driver = {
> +	.name		= "pasemi_mac",
> +	.id_table	= pasemi_mac_pci_tbl,
> +	.probe		= pasemi_mac_probe,
> +	.remove		= __devexit_p(pasemi_mac_remove),
> +};
> +
> +static void __exit pasemi_mac_cleanup_module(void)
> +{
> +	pci_unregister_driver(&pasemi_mac_driver);
> +	__iounmap(dma_status);
> +	dma_status = NULL;
> +}
> +
> +int pasemi_mac_init_module(void)
> +{
> +	return pci_register_driver(&pasemi_mac_driver);
> +}
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR ("Olof Johansson <olof@lixom.net>");
> +MODULE_DESCRIPTION("PA Semi PWRficient Ethernet driver");
> +
> +module_init(pasemi_mac_init_module);


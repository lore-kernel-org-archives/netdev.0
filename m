From: Darek Marcinkiewicz <reksio@newterm.pl>
Subject: [PATCH v2 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Sun, 27 Apr 2014 23:10:49 +0200
Message-ID: <20140427211049.GB14757@newterm.pl>
References: <20140424204615.GA14757@newterm.pl>
 <20140426.122400.1793404589768219066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.newterm.pl ([79.187.237.18]:38302 "EHLO apollo.newterm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751307AbaD0VK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Apr 2014 17:10:56 -0400
Content-Disposition: inline
In-Reply-To: <20140426.122400.1793404589768219066.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 26, 2014 at 12:24:00PM -0400, David Miller wrote:
> From: Darek Marcinkiewicz <reksio@newterm.pl>
> Date: Thu, 24 Apr 2014 22:46:15 +0200
....
> 
> All of these descriptor structures need to be properly annotated using
> endianness types, and their fields accessed using proper endian
> translating interfaces such as le32_to_cpu() et al.
> 

Thanks. Patch updated.

Changes since v1:
  * added endianess annotation to descriptors' structures
  * killed checkpath warnings about string literals being split into multiple
    lines

>8----------------------------------------8<


This driver adds support for EtherCAT master module located on CCAT
FPGA found on Beckhoff CX series industrail PCs. The driver exposes
EtherCAT master as an ethernet interface.

EtherCAT is a filedbus protocol defined on top of ethernet and Beckhoff
CX5020 PCs come with built-in EtherCAT master module located on a FPGA,
which in turn is connected to a PCI bus.

Signed-off-by: Dariusz Marcinkiewicz <reksio@newterm.pl>
---
 drivers/net/ethernet/Kconfig  |   11 +
 drivers/net/ethernet/Makefile |    1 +
 drivers/net/ethernet/ec_bh.c  |  768 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 780 insertions(+)
 create mode 100644 drivers/net/ethernet/ec_bh.c

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 39b26fe..a81611d 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -35,6 +35,17 @@ source "drivers/net/ethernet/calxeda/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/cirrus/Kconfig"
 source "drivers/net/ethernet/cisco/Kconfig"
+
+config CX_ECAT
+	tristate "Beckhoff CX5020 EtherCAT master support"
+	---help---
+	  Driver for EtherCAT master module located on CCAT FPGA
+	  that can be found on Beckhoff CX5020, and possibly other of CX
+	  Beckhoff CX series industrial PCs.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ec_bh.
+
 source "drivers/net/ethernet/davicom/Kconfig"
 
 config DNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 545d0b3..1712c87 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -21,6 +21,7 @@ obj-$(CONFIG_NET_CALXEDA_XGMAC) += calxeda/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CIRRUS) += cirrus/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
+obj-$(CONFIG_CX_ECAT) += ec_bh.o
 obj-$(CONFIG_DM9000) += davicom/
 obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_NET_VENDOR_DEC) += dec/
diff --git a/drivers/net/ethernet/ec_bh.c b/drivers/net/ethernet/ec_bh.c
new file mode 100644
index 0000000..cc63af4
--- /dev/null
+++ b/drivers/net/ethernet/ec_bh.c
@@ -0,0 +1,768 @@
+/*
+ * drivers/net/ethernet/beckhoff/ec_bh.c
+ *
+ * Copyright (C) 2014 Darek Marcinkiewicz <reksio@newterm.pl>
+ *
+ * This software is licensed under the terms of the GNU General Public
+ * License version 2, as published by the Free Software Foundation, and
+ * may be copied, distributed, and modified under those terms.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+/* This is a driver for EtherCAT master module present on CCAT FPGA.
+ * Those can be found on Bechhoff CX50xx industrial PCs.
+ */
+
+#if 0
+#define DEBUG
+#endif
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/pci.h>
+#include <linux/init.h>
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/skbuff.h>
+#include <linux/hrtimer.h>
+#include <linux/interrupt.h>
+#include <linux/stat.h>
+
+#define TIMER_INTERVAL_NSEC	20000
+
+#define INFO_BLOCK_SIZE		0x10
+#define INFO_BLOCK_TYPE		0x0
+#define INFO_BLOCK_REV		0x2
+#define INFO_BLOCK_BLK_CNT	0x4
+#define INFO_BLOCK_TX_CHAN	0x4
+#define INFO_BLOCK_RX_CHAN	0x5
+#define INFO_BLOCK_OFFSET	0x8
+
+#define EC_MII_OFFSET		0x4
+#define EC_FIFO_OFFSET		0x8
+#define EC_MAC_OFFSET		0xc
+
+#define MAC_FRAME_ERR_CNT	0x0
+#define MAC_RX_ERR_CNT		0x1
+#define MAC_CRC_ERR_CNT		0x2
+#define MAC_LNK_LST_ERR_CNT	0x3
+#define MAC_TX_FRAME_CNT	0x10
+#define MAC_RX_FRAME_CNT	0x14
+#define MAC_TX_FIFO_LVL		0x20
+#define MAC_DROPPED_FRMS	0x28
+#define MAC_CONNECTED_CCAT_FLAG	0x78
+
+#define MII_MAC_ADDR		0x8
+#define MII_MAC_FILT_FLAG	0xe
+#define MII_LINK_STATUS		0xf
+
+#define FIFO_TX_REG		0x0
+#define FIFO_TX_RESET		0x8
+#define FIFO_RX_REG		0x10
+#define FIFO_RX_RESET		0x18
+
+#define DMA_CHAN_OFFSET		0x1000
+#define DMA_CHAN_SIZE		0x8
+
+static struct pci_device_id ids[] = {
+	{ PCI_DEVICE(0x15ec, 0x5000), },
+	{ 0, }
+};
+MODULE_DEVICE_TABLE(pci, ids);
+
+struct rx_header {
+#define RXHDR_NEXT_ADDR_MASK	0xffffffu
+#define RXHDR_NEXT_VALID	(1u << 31)
+	__le32 next;
+#define RXHDR_NEXT_RECV_FLAG	0x1
+	__le32 recv;
+#define RXHDR_LEN_MASK		0xfffu
+	__le16 len;
+	__le16 port;
+	__le32 reserved;
+	u8 timestamp[8];
+} __packed;
+
+struct rx_desc {
+	struct rx_header header;
+#define RX_PAYLOAD_SIZE		0x7e8
+	u8 data[RX_PAYLOAD_SIZE];
+} __packed;
+
+struct tx_header {
+	__le16 len;
+#define TX_HDR_PORT_0		0x1
+#define TX_HDR_PORT_1		0x2
+	u8 port;
+	u8 ts_enable;
+#define TX_HDR_SENT		0x1
+	__le32 sent;
+	u8 timestamp[8];
+} __packed;
+
+#define TX_HEADER_SIZE		16
+#define MAX_TX_BODY_SIZE	1518
+#define MAX_TX_PKT_SIZE		(MAX_TX_BODY_SIZE + TX_HEADER_SIZE)
+
+#define RX_TX_LEN		(10 * 1024)
+
+static long polling_frequency = TIMER_INTERVAL_NSEC;
+
+struct bh_priv {
+	struct net_device *net_dev;
+
+	struct pci_dev *dev;
+
+	void * __iomem io;
+	void * __iomem dma_io;
+
+	struct hrtimer hrtimer;
+
+	u32 offset;
+	int tx_dma_chan;
+	int rx_dma_chan;
+	void * __iomem ec_io;
+	void * __iomem fifo_io;
+	void * __iomem mii_io;
+	void * __iomem mac_io;
+
+	u8 *rx;
+	struct rx_desc *rx_desc;
+	u8 *rx_buf;
+	dma_addr_t rx_phys;
+	dma_addr_t rx_buf_phys;
+	size_t rx_len;
+
+	u8 *tx;
+	u8 *tx_buf;
+	dma_addr_t tx_phys;
+	dma_addr_t tx_buf_phys;
+	size_t tx_len;
+
+	u8 *tx_put;
+	u8 *tx_get;
+	int tx_in_flight;
+
+	atomic_t shutting_down;
+
+	spinlock_t lock;
+};
+
+#define PRIV_TO_DEV(priv) (&(priv)->dev->dev)
+
+#define ETHERCAT_MASTER_ID	0x14
+
+static void ec_bh_print_status(struct bh_priv *priv)
+{
+	dev_info(PRIV_TO_DEV(priv),
+		 "Frame error counter:%d\n",
+		 ioread8(priv->mac_io + MAC_FRAME_ERR_CNT));
+	dev_info(PRIV_TO_DEV(priv),
+		 "RX error counter:%d\n",
+		 ioread8(priv->mac_io + MAC_RX_ERR_CNT));
+	dev_info(PRIV_TO_DEV(priv),
+		 "CRC error counter:%d\n",
+		 ioread8(priv->mac_io + MAC_CRC_ERR_CNT));
+	dev_info(PRIV_TO_DEV(priv),
+		 "TX frame counter:%d\n",
+		 ioread32(priv->mac_io + MAC_TX_FRAME_CNT));
+	dev_info(PRIV_TO_DEV(priv),
+		 "RX frame counter:%d\n",
+		 ioread32(priv->mac_io + MAC_RX_FRAME_CNT));
+	dev_info(PRIV_TO_DEV(priv),
+		 "TX fifo level:%d\n",
+		 ioread8(priv->mac_io + MAC_TX_FIFO_LVL));
+	dev_info(PRIV_TO_DEV(priv),
+		 "Dropped frames:%d\n",
+		 ioread8(priv->mac_io + MAC_DROPPED_FRMS));
+	dev_info(PRIV_TO_DEV(priv),
+		 "Connected with CCAT slot:%d\n",
+		 ioread8(priv->mac_io + MAC_CONNECTED_CCAT_FLAG));
+	dev_info(PRIV_TO_DEV(priv),
+		 "Link status:%d\n",
+		 ioread8(priv->mii_io + MII_LINK_STATUS));
+}
+
+static void ec_bh_reset(struct bh_priv *priv)
+{
+	iowrite8(0, priv->mac_io + MAC_FRAME_ERR_CNT);
+	iowrite8(0, priv->mac_io + MAC_RX_ERR_CNT);
+	iowrite8(0, priv->mac_io + MAC_CRC_ERR_CNT);
+	iowrite8(0, priv->mac_io + MAC_LNK_LST_ERR_CNT);
+	iowrite32(0, priv->mac_io + MAC_TX_FRAME_CNT);
+	iowrite32(0, priv->mac_io + MAC_RX_FRAME_CNT);
+	iowrite8(0, priv->mac_io + MAC_DROPPED_FRMS);
+
+	iowrite8(0, priv->fifo_io + FIFO_TX_RESET);
+	iowrite8(0, priv->fifo_io + FIFO_RX_RESET);
+
+	iowrite8(0, priv->mac_io + MAC_TX_FIFO_LVL);
+}
+
+static void ec_bh_send_packet(struct bh_priv *priv)
+{
+	struct tx_header *header = (struct tx_header *)priv->tx_get;
+	u32 addr = priv->tx_get - priv->tx;
+	u32 len = le16_to_cpu(header->len) + sizeof(*header);
+
+	iowrite32((((len + 8) / 8) << 24) | addr,
+			priv->fifo_io + FIFO_TX_REG);
+
+	dev_dbg(PRIV_TO_DEV(priv), "Done sending packet\n");
+}
+
+static void ec_bh_process_tx(struct bh_priv *priv)
+{
+	int sent;
+	struct tx_header *header;
+	u8 *pkt_end, *next_pkt;
+
+	if (!priv->tx_in_flight)
+		return;
+
+	header = (struct tx_header *)priv->tx_get;
+	sent = le32_to_cpu(header->sent) & TX_HDR_SENT;
+	if (!sent)
+		return;
+
+	pkt_end = priv->tx_get;
+	pkt_end += (sizeof(*header) + le16_to_cpu(header->len) + 7) / 8 * 8;
+
+	if (pkt_end + MAX_TX_PKT_SIZE > priv->tx + priv->tx_len)
+		next_pkt = priv->tx;
+	else
+		next_pkt = pkt_end;
+	priv->tx_get = next_pkt;
+
+	if (next_pkt != priv->tx_put)
+		ec_bh_send_packet(priv);
+	else
+		priv->tx_in_flight = 0;
+
+	if (netif_queue_stopped(priv->net_dev) &&
+		(priv->tx_put > priv->tx_get
+			|| priv->tx_put + MAX_TX_PKT_SIZE < priv->tx_get)) {
+		dev_info(PRIV_TO_DEV(priv), "Waking netif queue\n");
+		netif_wake_queue(priv->net_dev);
+	}
+}
+
+static int ec_bh_pkt_received(struct rx_desc *desc)
+{
+	return le32_to_cpu(desc->header.recv) & RXHDR_NEXT_RECV_FLAG;
+}
+
+static void ec_bh_process_rx(struct bh_priv *priv)
+{
+	int recv = 0;
+	struct rx_desc *desc = priv->rx_desc;
+
+	while (ec_bh_pkt_received(desc)) {
+		int pkt_size = (le16_to_cpu(desc->header.len) & RXHDR_LEN_MASK)
+			       - sizeof(struct rx_header)
+			       - 4;
+		u8 *data = desc->data;
+		struct sk_buff *skb;
+
+		skb = netdev_alloc_skb_ip_align(priv->net_dev, pkt_size);
+		dev_dbg(PRIV_TO_DEV(priv),
+			"Received packet, size:%d\n",
+			pkt_size);
+
+		if (skb) {
+			memcpy(skb_put(skb, pkt_size), data, pkt_size);
+			skb->protocol = eth_type_trans(skb, priv->net_dev);
+			dev_dbg(PRIV_TO_DEV(priv),
+				"Protocol type: %x\n",
+				skb->protocol);
+
+			netif_rx(skb);
+		} else {
+			if (printk_ratelimit())
+				dev_err(PRIV_TO_DEV(priv),
+					"Couldn't allocate a skb_buff for a packet of size %u\n",
+					pkt_size);
+		}
+
+		priv->net_dev->stats.rx_packets++;
+		priv->net_dev->stats.rx_bytes += pkt_size;
+
+		desc->header.recv = 0;
+		desc += 1;
+		if (priv->rx + priv->rx_len <= (u8 *) desc + sizeof(*desc))
+			desc = (struct rx_desc *)priv->rx;
+
+		priv->rx_desc = desc;
+		recv = 1;
+	}
+
+	if (recv) {
+		mmiowb();
+		iowrite32((1 << 31) | ((u8 *)(desc) - priv->rx),
+			  priv->fifo_io + FIFO_RX_REG);
+	}
+
+}
+
+static enum hrtimer_restart ec_bh_timer_fun(struct hrtimer *timer)
+{
+	struct bh_priv *priv = container_of(timer,
+					struct bh_priv,
+					hrtimer);
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	ec_bh_process_rx(priv);
+	ec_bh_process_tx(priv);
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	if (atomic_read(&priv->shutting_down))
+		return HRTIMER_NORESTART;
+
+	hrtimer_forward_now(timer, ktime_set(0, polling_frequency));
+	return HRTIMER_RESTART;
+}
+
+static int ec_bh_setup_offsets(struct bh_priv *priv)
+{
+	unsigned block_count, i;
+	void * __iomem ec_info;
+
+	dev_info(PRIV_TO_DEV(priv),
+		"Info block:\n");
+	dev_info(PRIV_TO_DEV(priv),
+		"Type of function:%x\n",
+		(unsigned)ioread16(priv->io));
+	dev_info(PRIV_TO_DEV(priv),
+		"Revision of function:%x\n",
+		(unsigned)ioread16(priv->io + INFO_BLOCK_REV));
+
+	block_count = ioread8(priv->io + INFO_BLOCK_BLK_CNT);
+	dev_info(PRIV_TO_DEV(priv),
+		"Number of function blocks:%x\n",
+		block_count);
+
+	for (i = 0; i < block_count; i++) {
+		u16 type = ioread16(priv->io
+				    + i * INFO_BLOCK_SIZE
+				    + INFO_BLOCK_TYPE);
+		if (type == ETHERCAT_MASTER_ID)
+			break;
+	}
+	if (i == block_count) {
+		dev_err(PRIV_TO_DEV(priv),
+			"EtherCAT master with DMA block not found\n");
+		return -ENODEV;
+	}
+	dev_info(PRIV_TO_DEV(priv),
+		"EtherCAT master with DMA block found at pos:%d\n",
+		 i);
+
+	ec_info = priv->io + i * INFO_BLOCK_SIZE;
+	dev_info(PRIV_TO_DEV(priv),
+		 "EtherCAT master revision:%d\n",
+		 ioread16(ec_info + INFO_BLOCK_REV));
+
+	priv->tx_dma_chan = ioread8(ec_info + INFO_BLOCK_TX_CHAN);
+	dev_info(PRIV_TO_DEV(priv),
+		 "EtherCAT master tx dma channel:%d\n",
+		 priv->tx_dma_chan);
+
+	priv->rx_dma_chan = ioread8(ec_info + INFO_BLOCK_RX_CHAN);
+	dev_info(PRIV_TO_DEV(priv),
+		 "EtherCAT master rx dma channel:%d\n",
+		 priv->rx_dma_chan);
+
+	priv->ec_io = priv->io + ioread32(ec_info + INFO_BLOCK_OFFSET);
+	priv->mii_io = priv->ec_io + ioread32(priv->ec_io + EC_MII_OFFSET);
+	priv->fifo_io = priv->ec_io + ioread32(priv->ec_io + EC_FIFO_OFFSET);
+	priv->mac_io = priv->ec_io + ioread32(priv->ec_io + EC_MAC_OFFSET);
+
+	dev_info(PRIV_TO_DEV(priv),
+		"EtherCAT block addres: %p, fifo address %p, mii address:%p, mac address:%p",
+		priv->ec_io,
+		priv->fifo_io,
+		priv->mii_io,
+		priv->mac_io);
+
+	return 0;
+}
+
+static netdev_tx_t ec_bh_start_xmit(struct sk_buff *skb,
+				    struct net_device *net_dev)
+{
+	unsigned long flags;
+	unsigned len;
+	struct bh_priv *priv = netdev_priv(net_dev);
+	struct tx_header *header = (struct tx_header *)priv->tx_put;
+	u8 *tx = priv->tx_put + sizeof(struct tx_header);
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	dev_dbg(PRIV_TO_DEV(priv), "Starting xmit\n");
+
+	/*
+	 * Drop packets that are too large or have no chance
+	 * to be a ethercat packets (cause they are too small)
+	 */
+	if (unlikely(skb->len > priv->tx_len
+			|| skb->len < 13)) {
+		net_dev->stats.tx_dropped++;
+		dev_info(PRIV_TO_DEV(priv), "Dropping packet\n");
+		goto out_unlock;
+	}
+
+	skb_copy_and_csum_dev(skb, tx);
+	len = skb->len;
+
+	memset(header, 0, sizeof(*header));
+	header->len = cpu_to_le16(len);
+	header->port = TX_HDR_PORT_0;
+	mmiowb();
+
+	if (!priv->tx_in_flight) {
+		ec_bh_send_packet(priv);
+		priv->tx_in_flight = 1;
+	}
+
+	priv->tx_put += (TX_HEADER_SIZE + len + 7) / 8 * 8;
+	if (priv->tx_put + MAX_TX_PKT_SIZE > priv->tx + priv->tx_len)
+		priv->tx_put = priv->tx;
+
+	if (priv->tx_put <= priv->tx_get
+			&& priv->tx_put + MAX_TX_PKT_SIZE > priv->tx_get) {
+		dev_info(PRIV_TO_DEV(priv), "Stopping netif queue\n");
+		ec_bh_print_status(priv);
+		netif_stop_queue(net_dev);
+	}
+
+	priv->net_dev->stats.tx_bytes += len;
+	priv->net_dev->stats.tx_packets++;
+out_unlock:
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	dev_kfree_skb(skb);
+
+	return NETDEV_TX_OK;
+}
+
+void *ec_bh_alloc_dma_mem(struct bh_priv *priv,
+			     int channel,
+			     u8 **buf,
+			     dma_addr_t *phys,
+			     dma_addr_t *phys_buf,
+			     size_t *len) {
+	u32 mask;
+	int offset = channel * DMA_CHAN_SIZE + DMA_CHAN_OFFSET;
+
+	iowrite32(0xffffffff, priv->dma_io + offset);
+
+	mask = ioread32(priv->dma_io + offset);
+	mask &= 0xfffffffc;
+	dev_info(PRIV_TO_DEV(priv),
+		 "Read mask %x for channel %d\n",
+		 mask, channel);
+	*len = ~mask + 1;
+
+	dev_info(PRIV_TO_DEV(priv),
+		 "Allocating %d bytes for channel %d",
+		 (int)*len, channel);
+	*buf = pci_alloc_consistent(priv->dev,
+				    *len * 2,
+				    phys_buf);
+	if (*buf == NULL) {
+		dev_info(PRIV_TO_DEV(priv),
+			 "Failed to allocate buffer\n");
+		return NULL;
+	}
+
+	*phys = (*phys_buf + *len) & mask;
+
+	iowrite32(0, priv->dma_io + offset + 4);
+	iowrite32(*phys, priv->dma_io + offset);
+	dev_dbg(PRIV_TO_DEV(priv),
+		"Buffer %x and read from dev:%x",
+		(unsigned)*phys, ioread32(priv->dma_io + offset));
+
+	return *buf + *phys - *phys_buf;
+}
+
+static int ec_bh_open(struct net_device *net_dev)
+{
+	int err = 0, dcount, i;
+	unsigned long flags;
+	struct rx_desc *desc;
+	struct bh_priv *priv = netdev_priv(net_dev);
+
+	dev_info(PRIV_TO_DEV(priv), "Opening device\n");
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	ec_bh_reset(priv);
+
+	priv->rx = ec_bh_alloc_dma_mem(priv, priv->rx_dma_chan,
+				       &priv->rx_buf, &priv->rx_phys,
+				       &priv->rx_buf_phys, &priv->rx_len);
+	if (!priv->rx) {
+		dev_err(PRIV_TO_DEV(priv),
+			"Failed to allocate rx buffer");
+		err = -ENOMEM;
+		goto out;
+	}
+	priv->rx_desc = (struct rx_desc *)priv->rx;
+
+	dev_info(PRIV_TO_DEV(priv),
+		 "RX buffer allocated, address: %x\n",
+		 (unsigned)priv->rx_phys);
+
+	priv->tx = ec_bh_alloc_dma_mem(priv, priv->tx_dma_chan,
+				       &priv->tx_buf, &priv->tx_phys,
+				       &priv->tx_buf_phys, &priv->tx_len);
+	if (!priv->tx) {
+		dev_err(PRIV_TO_DEV(priv),
+			"Failed to allocate tx buffer");
+		err = -ENOMEM;
+		goto error_rx_free;
+	}
+	priv->tx_get = priv->tx_put = priv->tx;
+
+	dev_info(PRIV_TO_DEV(priv),
+		"TX buffer allocated, addres:%x\n",
+		 (unsigned)priv->tx_phys);
+
+	priv->tx_in_flight = 0;
+	atomic_set(&priv->shutting_down, 0);
+
+	memset(priv->rx_buf, 0, priv->rx_len * 2);
+	memset(priv->tx_buf, 0, priv->tx_len * 2);
+
+	dcount = priv->rx_len / (sizeof(struct rx_desc));
+	desc = (struct rx_desc *)(priv->rx);
+	for (i = 0; i < dcount; i++) {
+		u32 next;
+		if (i != dcount - 1)
+			next = (u8 *)(desc + 1) - priv->rx;
+		else
+			next = 0;
+		next |= RXHDR_NEXT_VALID;
+		desc->header.next = cpu_to_le32(next);
+		desc->header.recv = 0;
+		desc += 1;
+	}
+
+	iowrite8(0, priv->mii_io + MII_MAC_FILT_FLAG);
+	iowrite32(1 << 31, priv->fifo_io + FIFO_RX_REG);
+
+	netif_start_queue(net_dev);
+
+	hrtimer_init(&priv->hrtimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+	priv->hrtimer.function = ec_bh_timer_fun;
+	hrtimer_start(&priv->hrtimer,
+		      ktime_set(0, TIMER_INTERVAL_NSEC),
+		      HRTIMER_MODE_REL);
+
+	dev_info(PRIV_TO_DEV(priv), "Device open\n");
+
+	ec_bh_print_status(priv);
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+
+error_rx_free:
+	pci_free_consistent(priv->dev, 2 * priv->rx_len,
+			    priv->rx_buf, priv->rx_buf_phys);
+out:
+	spin_unlock_irqrestore(&priv->lock, flags);
+	return err;
+}
+
+static int ec_bh_stop(struct net_device *dev)
+{
+	struct bh_priv *priv = netdev_priv(dev);
+
+	atomic_set(&priv->shutting_down,  1);
+
+	hrtimer_cancel(&priv->hrtimer);
+
+	ec_bh_reset(priv);
+
+	netif_tx_disable(dev);
+
+	pci_free_consistent(priv->dev, 2 * priv->tx_len,
+			    priv->tx_buf, priv->tx_buf_phys);
+	pci_free_consistent(priv->dev, 2 * priv->rx_len,
+			    priv->rx_buf, priv->rx_buf_phys);
+
+	return 0;
+}
+
+static const struct net_device_ops ec_bh_netdev_ops = {
+	.ndo_start_xmit		= ec_bh_start_xmit,
+	.ndo_open		= ec_bh_open,
+	.ndo_stop		= ec_bh_stop,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr
+};
+
+static int ec_bh_probe(struct pci_dev *dev, const struct pci_device_id *id)
+{
+	int err = 0;
+	void * __iomem io;
+	void * __iomem dma_io;
+	struct net_device *net_dev;
+	struct bh_priv *priv;
+
+	err = pci_enable_device(dev);
+	if (err)
+		return err;
+
+	pci_set_master(dev);
+
+	err = pci_set_dma_mask(dev, DMA_BIT_MASK(32));
+	if (err) {
+		dev_err(&dev->dev,
+			"Required dma mask not supported, failed to initialize device\n");
+		err = -EIO;
+		goto err_disable_dev;
+	}
+
+	err = pci_set_consistent_dma_mask(dev, DMA_BIT_MASK(32));
+	if (err) {
+		dev_err(&dev->dev,
+			"Required dma mask not supported, failed to initialize device\n");
+		goto err_disable_dev;
+	}
+
+	err = pci_request_regions(dev, "ec_bh");
+	if (err) {
+		dev_err(&dev->dev,
+			"Failed to request pci memory regions\n");
+		goto err_disable_dev;
+	}
+
+	io = pci_iomap(dev, 0, 0);
+	if (!io) {
+		dev_err(&dev->dev, "Failed to map pci card memory bar 0");
+		err = -EIO;
+		goto err_release_regions;
+	}
+
+	dma_io = pci_iomap(dev, 2, 0);
+	if (!dma_io) {
+		dev_err(&dev->dev, "Failed to map pci card memory bar 2");
+		err = -EIO;
+		goto err_unmap;
+	}
+
+	net_dev = alloc_etherdev(sizeof(struct bh_priv));
+	if (net_dev == 0) {
+		err = -ENOMEM;
+		goto err_unmap_dma_io;
+	}
+
+	pci_set_drvdata(dev, net_dev);
+	SET_NETDEV_DEV(net_dev, &dev->dev);
+
+	net_dev->mem_start = pci_resource_start(dev, 0);
+	net_dev->mem_end = pci_resource_end(dev, 0);
+	net_dev->irq = dev->irq;
+
+	net_dev->features = 0;
+	net_dev->flags |= IFF_NOARP;
+
+	net_dev->netdev_ops = &ec_bh_netdev_ops;
+
+	priv = netdev_priv(net_dev);
+	priv->net_dev = net_dev;
+	priv->io = io;
+	priv->dma_io = dma_io;
+	priv->dev = dev;
+
+	spin_lock_init(&priv->lock);
+
+	if (ec_bh_setup_offsets(priv)) {
+		err = -ENODEV;
+		goto err_free_net_dev;
+	}
+
+	memcpy_fromio(net_dev->dev_addr, priv->mii_io + MII_MAC_ADDR, 6);
+
+	dev_info(PRIV_TO_DEV(priv),
+		 "CX5000 Ethercat master address: %pM\n",
+		 net_dev->dev_addr);
+
+	err = register_netdev(net_dev);
+	if (err < 0)
+		goto err_free_net_dev;
+
+	return 0;
+
+err_free_net_dev:
+	free_netdev(net_dev);
+err_unmap_dma_io:
+	pci_iounmap(dev, dma_io);
+err_unmap:
+	pci_iounmap(dev, io);
+err_release_regions:
+	pci_release_regions(dev);
+err_disable_dev:
+	pci_clear_master(dev);
+	pci_disable_device(dev);
+
+	return err;
+}
+
+static void ec_bh_remove(struct pci_dev *dev)
+{
+	struct net_device *net_dev = pci_get_drvdata(dev);
+	struct bh_priv *priv = netdev_priv(net_dev);
+	void * __iomem io = priv->io;
+	void * __iomem dma_io = priv->dma_io;
+
+	unregister_netdev(net_dev);
+	free_netdev(net_dev);
+
+	pci_iounmap(dev, dma_io);
+	pci_iounmap(dev, io);
+	pci_release_regions(dev);
+	pci_clear_master(dev);
+	pci_disable_device(dev);
+}
+
+static struct pci_driver pci_driver = {
+	.name = "ec_bh",
+	.id_table = ids,
+	.probe = ec_bh_probe,
+	.remove = ec_bh_remove,
+};
+
+static int __init ec_bh_init(void)
+{
+	return pci_register_driver(&pci_driver);
+}
+
+static void __exit ec_bh_exit(void)
+{
+	pci_unregister_driver(&pci_driver);
+}
+
+module_init(ec_bh_init);
+module_exit(ec_bh_exit);
+
+module_param(polling_frequency, long, S_IRUGO);
+MODULE_PARM_DESC(polling_frequency, "Polling timer frequency in ns");
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Dariusz Marcinkiewicz <reksio@newterm.pl>");
+
-- 
1.7.10.4

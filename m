From: Mans Rullgard <mans@mansr.com>
Subject: [PATCH v2 2/2] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Thu, 22 Oct 2015 17:28:50 +0100
Message-ID: <1445531330-17461-2-git-send-email-mans@mansr.com>
References: <1445531330-17461-1-git-send-email-mans@mansr.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:41899 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754296AbbJVQ3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 12:29:24 -0400
In-Reply-To: <1445531330-17461-1-git-send-email-mans@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
It is an almost complete rewrite of a driver originally found in
a Sigma Designs 2.6.22 tree.

Signed-off-by: Mans Rullgard <mans@mansr.com>
---
Changes:
- fix 64-bit build warnings
---
 drivers/net/ethernet/Kconfig         |    1 +
 drivers/net/ethernet/Makefile        |    1 +
 drivers/net/ethernet/aurora/Kconfig  |   20 +
 drivers/net/ethernet/aurora/Makefile |    1 +
 drivers/net/ethernet/aurora/nb8800.c | 1173 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/aurora/nb8800.h |  257 ++++++++
 6 files changed, 1453 insertions(+)
 create mode 100644 drivers/net/ethernet/aurora/Kconfig
 create mode 100644 drivers/net/ethernet/aurora/Makefile
 create mode 100644 drivers/net/ethernet/aurora/nb8800.c
 create mode 100644 drivers/net/ethernet/aurora/nb8800.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 05aa759..8310163 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -29,6 +29,7 @@ source "drivers/net/ethernet/apm/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/arc/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
+source "drivers/net/ethernet/aurora/Kconfig"
 source "drivers/net/ethernet/cadence/Kconfig"
 source "drivers/net/ethernet/adi/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index ddfc808..b435fb0 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_NET_XGENE) += apm/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_VENDOR_ARC) += arc/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
+obj-$(CONFIG_NET_VENDOR_AURORA) += aurora/
 obj-$(CONFIG_NET_CADENCE) += cadence/
 obj-$(CONFIG_NET_BFIN) += adi/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
diff --git a/drivers/net/ethernet/aurora/Kconfig b/drivers/net/ethernet/aurora/Kconfig
new file mode 100644
index 0000000..a3c7106
--- /dev/null
+++ b/drivers/net/ethernet/aurora/Kconfig
@@ -0,0 +1,20 @@
+config NET_VENDOR_AURORA
+	bool "Aurora VLSI devices"
+	help
+	  If you have a network (Ethernet) device belonging to this class,
+	  say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  questions about Aurora devices. If you say Y, you will be asked
+	  for your specific device in the following questions.
+
+if NET_VENDOR_AURORA
+
+config AURORA_NB8800
+	tristate "Aurora AU-NB8800 support"
+	select PHYLIB
+	help
+	 Support for the AU-NB8800 gigabit Ethernet controller.
+
+endif
diff --git a/drivers/net/ethernet/aurora/Makefile b/drivers/net/ethernet/aurora/Makefile
new file mode 100644
index 0000000..6cb528a
--- /dev/null
+++ b/drivers/net/ethernet/aurora/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_AURORA_NB8800) += nb8800.o
diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
new file mode 100644
index 0000000..7b83747
--- /dev/null
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -0,0 +1,1173 @@
+/*
+ * Copyright (C) 2015 Mans Rullgard <mans@mansr.com>
+ *
+ * Mostly rewritten, based on driver from Sigma Designs.  Original
+ * copyright notice below.
+ *
+ *
+ * Driver for tangox SMP864x/SMP865x/SMP867x/SMP868x builtin Ethernet Mac.
+ *
+ * Copyright (C) 2005 Maxime Bizon <mbizon@freebox.fr>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/etherdevice.h>
+#include <linux/delay.h>
+#include <linux/ethtool.h>
+#include <linux/interrupt.h>
+#include <linux/platform_device.h>
+#include <linux/of_device.h>
+#include <linux/of_net.h>
+#include <linux/dma-mapping.h>
+#include <linux/phy.h>
+#include <linux/cache.h>
+#include <linux/jiffies.h>
+#include <linux/io.h>
+#include <asm/barrier.h>
+
+#include "nb8800.h"
+
+static void nb8800_tx_reclaim(unsigned long data);
+
+static inline u8 nb8800_readb(struct nb8800_priv *priv, int reg)
+{
+	return readb(priv->base + reg);
+}
+
+static inline u32 nb8800_readl(struct nb8800_priv *priv, int reg)
+{
+	return readl(priv->base + reg);
+}
+
+static inline void nb8800_writeb(struct nb8800_priv *priv, int reg, u8 val)
+{
+	writeb(val, priv->base + reg);
+}
+
+static inline void nb8800_writew(struct nb8800_priv *priv, int reg, u16 val)
+{
+	writew(val, priv->base + reg);
+}
+
+static inline void nb8800_writel(struct nb8800_priv *priv, int reg, u32 val)
+{
+	writel(val, priv->base + reg);
+}
+
+#define nb8800_set_bits(sz, priv, reg, bits) do {			\
+		u32 __o = nb8800_read##sz(priv, reg);			\
+		u32 __n = __o | (bits);					\
+		if (__n != __o)						\
+			nb8800_write##sz(priv, reg, __n);		\
+	} while (0)
+
+#define nb8800_clear_bits(sz, priv, reg, bits) do {			\
+		u32 __o = nb8800_read##sz(priv, reg);			\
+		u32 __n = __o & ~(bits);				\
+		if (__n != __o)						\
+			nb8800_write##sz(priv, reg, __n);		\
+	} while (0)
+
+#define MDIO_TIMEOUT	1000
+
+static int nb8800_mdio_wait(struct mii_bus *bus)
+{
+	struct nb8800_priv *priv = bus->priv;
+	int tmo = MDIO_TIMEOUT;
+
+	while (--tmo) {
+		if (!(nb8800_readl(priv, NB8800_MDIO_CMD) & MDIO_CMD_GO))
+			break;
+		udelay(1);
+	}
+
+	return tmo;
+}
+
+static int nb8800_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+{
+	struct nb8800_priv *priv = bus->priv;
+	int val;
+
+	if (!nb8800_mdio_wait(bus))
+		return -ETIMEDOUT;
+
+	val = MIIAR_ADDR(phy_id) | MIIAR_REG(reg);
+	nb8800_writel(priv, NB8800_MDIO_CMD, val | MDIO_CMD_GO);
+
+	if (!nb8800_mdio_wait(bus))
+		return -ETIMEDOUT;
+
+	val = nb8800_readl(priv, NB8800_MDIO_STS);
+	if (val & MDIO_STS_ERR)
+		return 0xffff;
+
+	return val & 0xffff;
+}
+
+static int nb8800_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 val)
+{
+	struct nb8800_priv *priv = bus->priv;
+	int tmp;
+
+	if (!nb8800_mdio_wait(bus))
+		return -ETIMEDOUT;
+
+	tmp = MIIAR_DATA(val) | MIIAR_ADDR(phy_id) | MIIAR_REG(reg);
+	nb8800_writel(priv, NB8800_MDIO_CMD, tmp | MDIO_CMD_WR | MDIO_CMD_GO);
+
+	if (!nb8800_mdio_wait(bus))
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static void nb8800_mac_tx(struct net_device *dev, int enable)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	while (nb8800_readl(priv, NB8800_TXC_CR) & TCR_EN)
+		cpu_relax();
+
+	if (enable)
+		nb8800_set_bits(b, priv, NB8800_TX_CTL1, TX_EN);
+	else
+		nb8800_clear_bits(b, priv, NB8800_TX_CTL1, TX_EN);
+}
+
+static void nb8800_mac_rx(struct net_device *dev, int enable)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	if (enable)
+		nb8800_set_bits(b, priv, NB8800_RX_CTL, RX_EN);
+	else
+		nb8800_clear_bits(b, priv, NB8800_RX_CTL, RX_EN);
+}
+
+static void nb8800_mac_af(struct net_device *dev, int enable)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	if (enable)
+		nb8800_set_bits(b, priv, NB8800_RX_CTL, RX_AF_EN);
+	else
+		nb8800_clear_bits(b, priv, NB8800_RX_CTL, RX_AF_EN);
+}
+
+static void nb8800_stop_rx(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < RX_DESC_COUNT; i++)
+		priv->rx_descs[i].config |= DESC_EOC;
+
+	while (nb8800_readl(priv, NB8800_RXC_CR) & RCR_EN)
+		usleep_range(1000, 10000);
+}
+
+static void nb8800_start_rx(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	nb8800_set_bits(l, priv, NB8800_RXC_CR, RCR_EN);
+}
+
+static int nb8800_alloc_rx(struct net_device *dev, int i, int napi)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	struct nb8800_dma_desc *rx = &priv->rx_descs[i];
+	struct rx_buf *buf = &priv->rx_bufs[i];
+	int size = L1_CACHE_ALIGN(RX_BUF_SIZE);
+	void *data;
+
+	data = napi ? napi_alloc_frag(size) : netdev_alloc_frag(size);
+	if (!data) {
+		buf->page = NULL;
+		rx->config = DESC_BTS(2) | DESC_EOF;
+		return -ENOMEM;
+	}
+
+	buf->page = virt_to_head_page(data);
+	buf->offset = data - page_address(buf->page);
+
+	rx->s_addr = dma_map_page(&dev->dev, buf->page, buf->offset,
+				  RX_BUF_SIZE, DMA_FROM_DEVICE);
+	rx->config = RX_BUF_SIZE | DESC_BTS(2) | DESC_DS | DESC_EOF;
+
+	return 0;
+}
+
+static void nb8800_receive(struct net_device *dev, int i, int len)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	struct nb8800_dma_desc *rx = &priv->rx_descs[i];
+	struct page *page = priv->rx_bufs[i].page;
+	int offset = priv->rx_bufs[i].offset;
+	void *data = page_address(page) + offset;
+	dma_addr_t dma = rx->s_addr;
+	struct sk_buff *skb;
+
+	skb = napi_alloc_skb(&priv->napi, RX_COPYBREAK);
+	if (!skb) {
+		netdev_err(dev, "rx skb allocation failed\n");
+		return;
+	}
+
+	if (len <= RX_COPYBREAK) {
+		dma_sync_single_for_cpu(&dev->dev, dma, len, DMA_FROM_DEVICE);
+		memcpy(skb_put(skb, len), data, len);
+		dma_sync_single_for_device(&dev->dev, dma, len,
+					   DMA_FROM_DEVICE);
+	} else {
+		dma_unmap_page(&dev->dev, dma, RX_BUF_SIZE, DMA_FROM_DEVICE);
+		memcpy(skb_put(skb, 128), data, 128);
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
+				offset + 128, len - 128, RX_BUF_SIZE);
+		priv->rx_bufs[i].page = NULL;
+	}
+
+	skb->protocol = eth_type_trans(skb, dev);
+	netif_receive_skb(skb);
+
+	priv->stats.rx_packets++;
+	priv->stats.rx_bytes += len;
+}
+
+static void nb8800_rx_error(struct net_device *dev, u32 report)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	int len = RX_BYTES_TRANSFERRED(report);
+
+	if (report & RX_FCS_ERR)
+		priv->stats.rx_crc_errors++;
+
+	if ((report & (RX_FRAME_LEN_ERROR | RX_LENGTH_ERR)) ||
+	    (len > RX_BUF_SIZE))
+		priv->stats.rx_length_errors++;
+
+	priv->stats.rx_errors++;
+}
+
+static int nb8800_poll(struct napi_struct *napi, int budget)
+{
+	struct net_device *dev = napi->dev;
+	struct nb8800_priv *priv = netdev_priv(dev);
+	struct nb8800_dma_desc *rx;
+	int work = 0;
+	int last = priv->rx_eoc;
+	int next;
+
+	while (work < budget) {
+		struct rx_buf *rx_buf;
+		u32 report;
+		int len;
+
+		next = (last + 1) & (RX_DESC_COUNT - 1);
+
+		rx_buf = &priv->rx_bufs[next];
+		rx = &priv->rx_descs[next];
+		report = rx->report;
+
+		if (!report)
+			break;
+
+		if (IS_RX_ERROR(report)) {
+			nb8800_rx_error(dev, report);
+		} else if (likely(rx_buf->page)) {
+			len = RX_BYTES_TRANSFERRED(report);
+			nb8800_receive(dev, next, len);
+		}
+
+		rx->report = 0;
+		if (!rx_buf->page)
+			nb8800_alloc_rx(dev, next, 1);
+
+		last = next;
+		work++;
+	}
+
+	if (work) {
+		priv->rx_descs[last].config |= DESC_EOC;
+		wmb();	/* ensure new EOC is written before clearing old */
+		priv->rx_descs[priv->rx_eoc].config &= ~DESC_EOC;
+		priv->rx_eoc = last;
+		nb8800_start_rx(dev);
+	}
+
+	if (work < budget)
+		napi_complete_done(napi, work);
+
+	nb8800_tx_reclaim((unsigned long)dev);
+
+	return work;
+}
+
+static void nb8800_tx_dma_queue(struct net_device *dev, dma_addr_t data,
+				int len, int flags)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	int next = priv->tx_next;
+	struct nb8800_dma_desc *tx = &priv->tx_descs[next];
+
+	tx->s_addr = data;
+	tx->config = DESC_BTS(2) | DESC_DS | flags | len;
+	tx->report = 0;
+
+	priv->tx_next = (next + 1) & (TX_DESC_COUNT - 1);
+}
+
+static void nb8800_tx_dma_start(struct net_device *dev, int new)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	struct nb8800_dma_desc *tx;
+	struct tx_buf *tx_buf;
+	u32 txc_cr;
+	int next;
+
+	next = xchg(&priv->tx_pending, -1);
+	if (next < 0)
+		next = new;
+	if (next < 0)
+		goto end;
+
+	txc_cr = nb8800_readl(priv, NB8800_TXC_CR) & 0xffff;
+	if (txc_cr & TCR_EN)
+		goto end;
+
+	tx = &priv->tx_descs[next];
+	tx_buf = &priv->tx_bufs[next];
+
+	next = (next + tx_buf->frags) & (TX_DESC_COUNT - 1);
+	priv->tx_reclaim_next = next;
+
+	nb8800_writel(priv, NB8800_TX_DESC_ADDR, tx_buf->desc_dma);
+	wmb();		/* ensure desc addr is written before starting DMA */
+	nb8800_writel(priv, NB8800_TXC_CR, txc_cr | TCR_EN);
+
+	if (!priv->tx_bufs[next].frags)
+		next = -1;
+
+end:
+	priv->tx_pending = next;
+}
+
+static int nb8800_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	struct tx_skb_data *skb_data;
+	struct tx_buf *tx_buf;
+	dma_addr_t dma_addr;
+	unsigned int dma_len;
+	int cpsz, next;
+	int frags;
+
+	if (atomic_read(&priv->tx_free) <= NB8800_DESC_LOW) {
+		netif_stop_queue(dev);
+		return NETDEV_TX_BUSY;
+	}
+
+	cpsz = (8 - (uintptr_t)skb->data) & 7;
+
+	frags = cpsz ? 2 : 1;
+	atomic_sub(frags, &priv->tx_free);
+
+	dma_len = skb->len - cpsz;
+	dma_addr = dma_map_single(&dev->dev, skb->data + cpsz,
+				  dma_len, DMA_TO_DEVICE);
+
+	next = priv->tx_next;
+	tx_buf = &priv->tx_bufs[next];
+
+	if (cpsz) {
+		dma_addr_t dma = tx_buf->desc_dma +
+			offsetof(struct nb8800_dma_desc, buf);
+		memcpy(priv->tx_descs[next].buf, skb->data, cpsz);
+		nb8800_tx_dma_queue(dev, dma, cpsz, 0);
+	}
+
+	nb8800_tx_dma_queue(dev, dma_addr, dma_len, DESC_EOF | DESC_EOC);
+	netdev_sent_queue(dev, skb->len);
+
+	tx_buf->skb = skb;
+	tx_buf->frags = frags;
+
+	skb_data = (struct tx_skb_data *)skb->cb;
+	skb_data->dma_addr = dma_addr;
+	skb_data->dma_len = dma_len;
+
+	nb8800_tx_dma_start(dev, next);
+
+	if (!skb->xmit_more && !timer_pending(&priv->tx_reclaim_timer))
+		mod_timer(&priv->tx_reclaim_timer, jiffies + HZ / 20);
+
+	if (atomic_read(&priv->tx_free) <= NB8800_DESC_LOW)
+		netif_stop_queue(dev);
+
+	return NETDEV_TX_OK;
+}
+
+static void nb8800_tx_reclaim(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct nb8800_priv *priv = netdev_priv(dev);
+	int packets = 0, bytes = 0;
+	int reclaimed = 0;
+	int dirty, limit;
+
+	dirty = xchg(&priv->tx_dirty, -1);
+	if (dirty < 0)
+		return;
+
+	limit = priv->tx_reclaim_limit;
+	if (dirty == limit)
+		goto end;
+
+	while (dirty != limit) {
+		struct nb8800_dma_desc *tx = &priv->tx_descs[dirty];
+		struct tx_buf *tx_buf = &priv->tx_bufs[dirty];
+		struct sk_buff *skb = tx_buf->skb;
+		struct tx_skb_data *skb_data = (struct tx_skb_data *)skb->cb;
+		int frags = tx_buf->frags;
+
+		packets++;
+		bytes += skb->len;
+
+		dma_unmap_single(&dev->dev, skb_data->dma_addr,
+				 skb_data->dma_len, DMA_TO_DEVICE);
+		dev_kfree_skb(skb);
+
+		tx->report = 0;
+		tx_buf->skb = NULL;
+		tx_buf->frags = 0;
+
+		dirty = (dirty + frags) & (TX_DESC_COUNT - 1);
+		reclaimed += frags;
+	}
+
+	priv->stats.tx_packets += packets;
+	priv->stats.tx_bytes += bytes;
+
+	smp_mb__before_atomic();
+	atomic_add(reclaimed, &priv->tx_free);
+
+	netif_wake_queue(dev);
+
+end:
+	priv->tx_dirty = dirty;
+}
+
+static void nb8800_tx_done(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	struct tx_buf *tx_buf;
+	int tx_mask = (TX_DESC_COUNT - 1);
+	int nr_dirty;
+
+	tx_buf = &priv->tx_bufs[priv->tx_done];
+	priv->tx_done = (priv->tx_done + tx_buf->frags) & tx_mask;
+
+	netdev_completed_queue(dev, 1, tx_buf->skb->len);
+
+	priv->tx_reclaim_limit = priv->tx_reclaim_next;
+
+	nb8800_tx_dma_start(dev, -1);
+
+	nr_dirty = (priv->tx_reclaim_limit - priv->tx_dirty) & tx_mask;
+	if (nr_dirty >= NB8800_DESC_RECLAIM)
+		tasklet_schedule(&priv->tx_reclaim_tasklet);
+}
+
+static irqreturn_t nb8800_isr(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct nb8800_priv *priv = netdev_priv(dev);
+	u32 val;
+
+	/* tx interrupt */
+	val = nb8800_readl(priv, NB8800_TXC_SR);
+	if (val) {
+		nb8800_writel(priv, NB8800_TXC_SR, val);
+
+		if (likely(val & TSR_TI))
+			nb8800_tx_done(dev);
+
+		if (unlikely(val & TSR_DE))
+			netdev_err(dev, "TX DMA error\n");
+
+		if (unlikely(val & TSR_TO))
+			netdev_err(dev, "TX Status FIFO overflow\n");
+	}
+
+	/* rx interrupt */
+	val = nb8800_readl(priv, NB8800_RXC_SR);
+	if (val) {
+		nb8800_writel(priv, NB8800_RXC_SR, val);
+
+		if (likely(val & RSR_RI))
+			napi_schedule_irqoff(&priv->napi);
+
+		if (unlikely(val & RSR_DE))
+			netdev_err(dev, "RX DMA error\n");
+
+		if (unlikely(val & RSR_RO)) {
+			int i;
+
+			netdev_err(dev, "RX Status FIFO overflow\n");
+
+			for (i = 0; i < 4; i++)
+				nb8800_readl(priv, NB8800_RX_FIFO_SR);
+		}
+	}
+
+	/* wake on lan */
+	val = nb8800_readb(priv, NB8800_WAKEUP);
+	if (val == 1) {
+		nb8800_writeb(priv, NB8800_SLEEP_MODE, 0);
+		nb8800_writeb(priv, NB8800_WAKEUP, 0);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static void nb8800_mac_config(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	if (priv->duplex)
+		nb8800_clear_bits(b, priv, NB8800_MAC_MODE, HALF_DUPLEX);
+	else
+		nb8800_set_bits(b, priv, NB8800_MAC_MODE, HALF_DUPLEX);
+
+	if (priv->speed == SPEED_1000) {
+		nb8800_set_bits(b, priv, NB8800_MAC_MODE,
+				RGMII_MODE | GMAC_MODE);
+		nb8800_writeb(priv, NB8800_IC_THRESHOLD, 3);
+		nb8800_writeb(priv, NB8800_SLOT_TIME, 255);
+	} else {
+		nb8800_clear_bits(b, priv, NB8800_MAC_MODE,
+				  RGMII_MODE | GMAC_MODE);
+		nb8800_writeb(priv, NB8800_IC_THRESHOLD, 1);
+		nb8800_writeb(priv, NB8800_SLOT_TIME, 127);
+	}
+}
+
+static void nb8800_link_reconfigure(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+
+	if (phydev->speed == priv->speed && phydev->duplex == priv->duplex &&
+	    phydev->link == priv->link)
+		return;
+
+	if (phydev->link != priv->link || phydev->link)
+		phy_print_status(priv->phydev);
+
+	priv->speed = phydev->speed;
+	priv->duplex = phydev->duplex;
+	priv->link = phydev->link;
+
+	if (priv->link)
+		nb8800_mac_config(dev);
+}
+
+static void nb8800_update_mac_addr(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	nb8800_writeb(priv, NB8800_MAC_ADDR1, dev->dev_addr[0]);
+	nb8800_writeb(priv, NB8800_MAC_ADDR2, dev->dev_addr[1]);
+	nb8800_writeb(priv, NB8800_MAC_ADDR3, dev->dev_addr[2]);
+	nb8800_writeb(priv, NB8800_MAC_ADDR4, dev->dev_addr[3]);
+	nb8800_writeb(priv, NB8800_MAC_ADDR5, dev->dev_addr[4]);
+	nb8800_writeb(priv, NB8800_MAC_ADDR6, dev->dev_addr[5]);
+
+	nb8800_writeb(priv, NB8800_UC_ADDR1, dev->dev_addr[0]);
+	nb8800_writeb(priv, NB8800_UC_ADDR2, dev->dev_addr[1]);
+	nb8800_writeb(priv, NB8800_UC_ADDR3, dev->dev_addr[2]);
+	nb8800_writeb(priv, NB8800_UC_ADDR4, dev->dev_addr[3]);
+	nb8800_writeb(priv, NB8800_UC_ADDR5, dev->dev_addr[4]);
+	nb8800_writeb(priv, NB8800_UC_ADDR6, dev->dev_addr[5]);
+}
+
+static int nb8800_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sockaddr *sock = addr;
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	ether_addr_copy(dev->dev_addr, sock->sa_data);
+	nb8800_update_mac_addr(dev);
+
+	return 0;
+}
+
+static void nb8800_mc_init(struct net_device *dev, int val)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	nb8800_writeb(priv, NB8800_MC_INIT, val);
+	while (nb8800_readb(priv, NB8800_MC_INIT))
+		cpu_relax();
+}
+
+static void nb8800_set_rx_mode(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	struct netdev_hw_addr *ha;
+	int af_en;
+
+	if ((dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) ||
+	    netdev_mc_count(dev) > 64)
+		af_en = 0;
+	else
+		af_en = 1;
+
+	nb8800_mac_af(dev, af_en);
+
+	if (!af_en)
+		return;
+
+	nb8800_mc_init(dev, 0);
+
+	netdev_for_each_mc_addr(ha, dev) {
+		char *addr = ha->addr;
+
+		nb8800_writeb(priv, NB8800_MC_ADDR1, addr[0]);
+		nb8800_writeb(priv, NB8800_MC_ADDR2, addr[1]);
+		nb8800_writeb(priv, NB8800_MC_ADDR3, addr[2]);
+		nb8800_writeb(priv, NB8800_MC_ADDR4, addr[3]);
+		nb8800_writeb(priv, NB8800_MC_ADDR5, addr[4]);
+		nb8800_writeb(priv, NB8800_MC_ADDR6, addr[5]);
+
+		nb8800_mc_init(dev, 0xff);
+	}
+}
+
+static void nb8800_dma_reinit(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	struct nb8800_dma_desc *rx;
+	int i;
+
+	priv->tx_pending = -1;
+	priv->tx_reclaim_limit = 0;
+	priv->tx_dirty = 0;
+	priv->tx_next = 0;
+	priv->tx_done = 0;
+	atomic_set(&priv->tx_free, TX_DESC_COUNT);
+
+	priv->rx_eoc = RX_DESC_COUNT - 1;
+
+	for (i = 0; i < RX_DESC_COUNT - 1; i++) {
+		rx = &priv->rx_descs[i];
+		rx->report = 0;
+		rx->config &= ~DESC_EOC;
+	}
+
+	rx = &priv->rx_descs[i];
+	rx->report = 0;
+	rx->config |= DESC_EOC;
+
+	nb8800_writel(priv, NB8800_TX_DESC_ADDR, priv->tx_desc_dma);
+	nb8800_writel(priv, NB8800_RX_DESC_ADDR, priv->rx_desc_dma);
+}
+
+static int nb8800_open(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	phy_resume(priv->phydev);
+	phy_start(priv->phydev);
+
+	nb8800_writel(priv, NB8800_RXC_SR, 0xf);
+	nb8800_writel(priv, NB8800_TXC_SR, 0xf);
+
+	nb8800_dma_reinit(dev);
+	wmb();		/* ensure all setup is written before starting */
+	nb8800_start_rx(dev);
+
+	nb8800_mac_rx(dev, 1);
+	nb8800_mac_tx(dev, 1);
+
+	napi_enable(&priv->napi);
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+static int nb8800_stop(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+	napi_disable(&priv->napi);
+
+	nb8800_stop_rx(dev);
+
+	nb8800_mac_rx(dev, 0);
+	nb8800_mac_tx(dev, 0);
+
+	phy_stop(priv->phydev);
+	phy_suspend(priv->phydev);
+
+	return 0;
+}
+
+static struct net_device_stats *nb8800_get_stats(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	return &priv->stats;
+}
+
+static int nb8800_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	return phy_mii_ioctl(priv->phydev, rq, cmd);
+}
+
+static const struct net_device_ops nb8800_netdev_ops = {
+	.ndo_open		= nb8800_open,
+	.ndo_stop		= nb8800_stop,
+	.ndo_start_xmit		= nb8800_xmit,
+	.ndo_get_stats		= nb8800_get_stats,
+	.ndo_set_mac_address	= nb8800_set_mac_address,
+	.ndo_set_rx_mode	= nb8800_set_rx_mode,
+	.ndo_do_ioctl		= nb8800_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+static int nb8800_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	return phy_ethtool_gset(priv->phydev, cmd);
+}
+
+static int nb8800_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	return phy_ethtool_sset(priv->phydev, cmd);
+}
+
+static int nb8800_nway_reset(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	return genphy_restart_aneg(priv->phydev);
+}
+
+static u32 nb8800_get_link(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+
+	phy_read_status(priv->phydev);
+
+	return priv->phydev->link;
+}
+
+static struct ethtool_ops nb8800_ethtool_ops = {
+	.get_settings		= nb8800_get_settings,
+	.set_settings		= nb8800_set_settings,
+	.nway_reset		= nb8800_nway_reset,
+	.get_link		= nb8800_get_link,
+};
+
+static int nb8800_dma_init(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	int n_rx = RX_DESC_COUNT;
+	int n_tx = TX_DESC_COUNT;
+	int i;
+
+	priv->rx_descs = dmam_alloc_coherent(dev->dev.parent,
+					     n_rx * sizeof(*priv->rx_descs),
+					     &priv->rx_desc_dma, GFP_KERNEL);
+	if (!priv->rx_descs)
+		return -ENOMEM;
+
+	priv->rx_bufs = devm_kcalloc(dev->dev.parent, n_rx,
+				     sizeof(*priv->rx_bufs), GFP_KERNEL);
+	if (!priv->rx_bufs)
+		return -ENOMEM;
+
+	for (i = 0; i < n_rx; i++) {
+		struct nb8800_dma_desc *rx = &priv->rx_descs[i];
+		dma_addr_t rx_dma;
+		int err;
+
+		rx_dma = priv->rx_desc_dma + i * sizeof(struct nb8800_dma_desc);
+		rx->n_addr = rx_dma + sizeof(struct nb8800_dma_desc);
+		rx->r_addr = rx_dma + offsetof(struct nb8800_dma_desc, report);
+
+		err = nb8800_alloc_rx(dev, i, 0);
+		if (err)
+			return err;
+	}
+
+	priv->rx_descs[n_rx - 1].n_addr = priv->rx_desc_dma;
+
+	priv->tx_descs = dmam_alloc_coherent(dev->dev.parent,
+					     n_tx * sizeof(*priv->tx_descs),
+					     &priv->tx_desc_dma, GFP_KERNEL);
+	if (!priv->tx_descs)
+		return -ENOMEM;
+
+	priv->tx_bufs = devm_kcalloc(dev->dev.parent, n_tx,
+				     sizeof(*priv->tx_bufs), GFP_KERNEL);
+	if (!priv->tx_bufs)
+		return -ENOMEM;
+
+	for (i = 0; i < n_tx; i++) {
+		struct nb8800_dma_desc *tx = &priv->tx_descs[i];
+		dma_addr_t tx_dma;
+
+		tx_dma = priv->tx_desc_dma + i * sizeof(struct nb8800_dma_desc);
+		tx->n_addr = tx_dma + sizeof(struct nb8800_dma_desc);
+		tx->r_addr = tx_dma + offsetof(struct nb8800_dma_desc, report);
+
+		priv->tx_bufs[i].desc_dma = tx_dma;
+	}
+
+	priv->tx_descs[n_tx - 1].n_addr = priv->tx_desc_dma;
+
+	nb8800_dma_reinit(dev);
+
+	return 0;
+}
+
+static void nb8800_dma_free(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	int i;
+
+	if (priv->rx_bufs)
+		for (i = 0; i < RX_DESC_COUNT; i++)
+			if (priv->rx_bufs[i].page)
+				put_page(priv->rx_bufs[i].page);
+
+	if (priv->tx_bufs)
+		for (i = 0; i < TX_DESC_COUNT; i++)
+			kfree_skb(priv->tx_bufs[i].skb);
+}
+
+static void nb8800_tangox_init(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	u32 val;
+
+	val = nb8800_readb(priv, NB8800_TANGOX_PAD_MODE) & 0x78;
+	if (priv->phydev->supported & PHY_1000BT_FEATURES)
+		val |= 1;
+	nb8800_writeb(priv, NB8800_TANGOX_PAD_MODE, val);
+}
+
+static void nb8800_tangox_reset(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	int clk_div;
+
+	nb8800_writeb(priv, NB8800_TANGOX_RESET, 0);
+	usleep_range(1000, 10000);
+	nb8800_writeb(priv, NB8800_TANGOX_RESET, 1);
+
+	wmb();		/* ensure reset is cleared before proceeding */
+
+	clk_div = DIV_ROUND_UP(clk_get_rate(priv->clk), 2 * MAX_MDC_CLOCK);
+	nb8800_writew(priv, NB8800_TANGOX_MDIO_CLKDIV, clk_div);
+}
+
+static const struct nb8800_ops nb8800_tangox_ops = {
+	.init	= nb8800_tangox_init,
+	.reset	= nb8800_tangox_reset,
+};
+
+static int nb8800_hw_init(struct net_device *dev)
+{
+	struct nb8800_priv *priv = netdev_priv(dev);
+	unsigned int val = 0;
+	int clkdiv, itrmul;
+
+	clkdiv = priv->gigabit ? 125000000 : 25000000;
+	itrmul = clk_get_rate(priv->clk) / clkdiv + 2;
+
+	nb8800_writeb(priv, NB8800_RANDOM_SEED, 0x08);
+
+	/* TX single deferral params */
+	nb8800_writeb(priv, NB8800_TX_SDP, 0xc);
+
+	/* Threshold for partial full */
+	nb8800_writeb(priv, NB8800_PF_THRESHOLD, 0xff);
+
+	/* Pause Quanta */
+	nb8800_writeb(priv, NB8800_PQ1, 0xff);
+	nb8800_writeb(priv, NB8800_PQ2, 0xff);
+
+	/* configure TX DMA Channels */
+	val = nb8800_readl(priv, NB8800_TXC_CR);
+	val &= TCR_LE;
+	val |= TCR_DM | TCR_RS | TCR_TFI(TFI) | TCR_BTS(2);
+	nb8800_writel(priv, NB8800_TXC_CR, val);
+
+	/* TX Interrupt Time Register */
+	val = TFI * TX_BUF_SIZE * itrmul;
+	nb8800_writel(priv, NB8800_TX_ITR, val);
+
+	/* configure RX DMA Channels */
+	val = nb8800_readl(priv, NB8800_RXC_CR);
+	val &= RCR_LE;
+	val |= RCR_DM | RCR_RS | RCR_RFI(RFI) | RCR_BTS(2) | RCR_FL;
+	nb8800_writel(priv, NB8800_RXC_CR, val);
+
+	/* RX Interrupt Time Register */
+	val = RFI * RX_BUF_SIZE * itrmul;
+	nb8800_writel(priv, NB8800_RX_ITR, val);
+
+	val = TX_RETRY_EN | TX_PAD_EN | TX_APPEND_FCS;
+	nb8800_writeb(priv, NB8800_TX_CTL1, val);
+
+	/* collision retry count */
+	nb8800_writeb(priv, NB8800_TX_CTL2, 5);
+
+	val = RX_PAD_STRIP | RX_PAUSE_EN | RX_AF_EN | RX_RUNT;
+	nb8800_writeb(priv, NB8800_RX_CTL, val);
+
+	nb8800_mc_init(dev, 0);
+
+	nb8800_writeb(priv, NB8800_TX_BUFSIZE, 0xff);
+
+	return 0;
+}
+
+static const struct of_device_id nb8800_dt_ids[] = {
+	{
+		.compatible = "aurora,nb8800",
+	},
+	{
+		.compatible = "sigma,smp8640-ethernet",
+		.data = &nb8800_tangox_ops,
+	},
+	{ }
+};
+
+static int nb8800_probe(struct platform_device *pdev)
+{
+	const struct of_device_id *match;
+	const struct nb8800_ops *ops = NULL;
+	struct nb8800_priv *priv;
+	struct resource *res;
+	struct net_device *dev;
+	struct mii_bus *bus;
+	struct phy_device *phydev;
+	const unsigned char *mac;
+	void __iomem *base;
+	int phy_mode;
+	u32 speed;
+	int irq;
+	int ret;
+
+	match = of_match_device(nb8800_dt_ids, &pdev->dev);
+	if (match)
+		ops = match->data;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "No MMIO base\n");
+		return -EINVAL;
+	}
+
+	irq = platform_get_irq(pdev, 0);
+	if (irq <= 0) {
+		dev_err(&pdev->dev, "No IRQ\n");
+		return -EINVAL;
+	}
+
+	base = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(base))
+		return PTR_ERR(base);
+
+	dev_info(&pdev->dev, "AU-NB8800 Ethernet at %pa\n", &res->start);
+
+	dev = alloc_etherdev(sizeof(*priv));
+	if (!dev)
+		return -ENOMEM;
+
+	platform_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	priv = netdev_priv(dev);
+	priv->base = base;
+
+	if (!of_property_read_u32(pdev->dev.of_node, "max-speed", &speed))
+		priv->gigabit = speed >= 1000;
+
+	phy_mode = of_get_phy_mode(pdev->dev.of_node);
+	if (phy_mode < 0)
+		phy_mode = PHY_INTERFACE_MODE_RGMII;
+
+	priv->clk = devm_clk_get(&pdev->dev, NULL);
+	if (IS_ERR(priv->clk)) {
+		dev_err(&pdev->dev, "failed to get clock\n");
+		ret = PTR_ERR(priv->clk);
+		goto err_free_dev;
+	}
+
+	ret = clk_prepare_enable(priv->clk);
+	if (ret)
+		goto err_free_dev;
+
+	if (ops && ops->reset)
+		ops->reset(dev);
+
+	bus = devm_mdiobus_alloc(&pdev->dev);
+	if (!bus) {
+		ret = -ENOMEM;
+		goto err_disable_clk;
+	}
+
+	bus->name = "nb8800-mii";
+	bus->read = nb8800_mdio_read;
+	bus->write = nb8800_mdio_write;
+	bus->parent = &pdev->dev;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%.*s-mii", MII_BUS_ID_SIZE - 5,
+		 pdev->name);
+	bus->priv = priv;
+
+	ret = mdiobus_register(bus);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to register MII bus\n");
+		goto err_disable_clk;
+	}
+
+	phydev = phy_find_first(bus);
+	if (!phydev || phy_read(phydev, MII_BMSR) <= 0) {
+		dev_err(&pdev->dev, "no PHY detected\n");
+		ret = -ENODEV;
+		goto err_free_bus;
+	}
+
+	priv->mii_bus = bus;
+	priv->phydev = phydev;
+
+	phydev->irq = PHY_POLL;
+
+	ret = phy_connect_direct(dev, phydev, nb8800_link_reconfigure,
+				 phy_mode);
+	if (ret)
+		goto err_free_bus;
+
+	dev_info(&pdev->dev, "PHY: found %s at 0x%x\n",
+		 phydev->drv->name, phydev->addr);
+
+	if (ops && ops->init)
+		ops->init(dev);
+
+	ret = nb8800_hw_init(dev);
+	if (ret)
+		goto err_detach_phy;
+
+	ret = nb8800_dma_init(dev);
+	if (ret)
+		goto err_detach_phy;
+
+	ret = request_irq(irq, nb8800_isr, 0, dev_name(&pdev->dev), dev);
+	if (ret)
+		goto err_free_dma;
+
+	dev->netdev_ops = &nb8800_netdev_ops;
+	dev->ethtool_ops = &nb8800_ethtool_ops;
+	dev->tx_queue_len = TX_DESC_COUNT;
+	dev->flags |= IFF_MULTICAST;
+	dev->irq = irq;
+
+	mac = of_get_mac_address(pdev->dev.of_node);
+	if (mac)
+		ether_addr_copy(dev->dev_addr, mac);
+
+	if (!is_valid_ether_addr(dev->dev_addr))
+		eth_hw_addr_random(dev);
+
+	nb8800_update_mac_addr(dev);
+
+	tasklet_init(&priv->tx_reclaim_tasklet, nb8800_tx_reclaim,
+		     (unsigned long)dev);
+	setup_timer(&priv->tx_reclaim_timer, nb8800_tx_reclaim,
+		    (unsigned long)dev);
+
+	netif_carrier_off(dev);
+
+	ret = register_netdev(dev);
+	if (ret) {
+		netdev_err(dev, "failed to register netdev\n");
+		goto err_free_dma;
+	}
+
+	netif_napi_add(dev, &priv->napi, nb8800_poll, NAPI_POLL_WEIGHT);
+
+	netdev_info(dev, "MAC address %pM\n", dev->dev_addr);
+
+	return 0;
+
+err_free_dma:
+	nb8800_dma_free(dev);
+err_detach_phy:
+	phy_detach(priv->phydev);
+err_free_bus:
+	mdiobus_unregister(bus);
+err_disable_clk:
+	clk_disable_unprepare(priv->clk);
+err_free_dev:
+	free_netdev(dev);
+
+	return ret;
+}
+
+static int nb8800_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct nb8800_priv *priv = netdev_priv(ndev);
+
+	unregister_netdev(ndev);
+	free_irq(ndev->irq, ndev);
+
+	phy_detach(priv->phydev);
+	mdiobus_unregister(priv->mii_bus);
+
+	clk_disable_unprepare(priv->clk);
+
+	nb8800_dma_free(ndev);
+	free_netdev(ndev);
+
+	return 0;
+}
+
+static struct platform_driver nb8800_driver = {
+	.driver = {
+		.name		= "nb8800",
+		.of_match_table	= nb8800_dt_ids,
+	},
+	.probe	= nb8800_probe,
+	.remove	= nb8800_remove,
+};
+
+module_platform_driver(nb8800_driver);
+
+MODULE_DESCRIPTION("Aurora AU-NB8800 Ethernet driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/aurora/nb8800.h b/drivers/net/ethernet/aurora/nb8800.h
new file mode 100644
index 0000000..f8988bf
--- /dev/null
+++ b/drivers/net/ethernet/aurora/nb8800.h
@@ -0,0 +1,257 @@
+#ifndef _NB8800_H_
+#define _NB8800_H_
+
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/phy.h>
+#include <linux/clk.h>
+#include <linux/timer.h>
+#include <linux/bitops.h>
+
+#define RX_DESC_COUNT			256
+#define TX_DESC_COUNT			256
+
+#define NB8800_DESC_LOW			4
+#define NB8800_DESC_RECLAIM		64
+
+#define RX_BUF_SIZE			1552
+#define TX_BUF_SIZE			1552
+
+#define RX_COPYBREAK			256
+
+#define RFI				7
+#define TFI				1
+
+#define MAX_MDC_CLOCK			2500000
+
+/* register offsets */
+#define NB8800_TX_CTL1			0x00
+#define TX_TPD				BIT(5)
+#define TX_APPEND_FCS			BIT(4)
+#define TX_PAD_EN			BIT(3)
+#define TX_RETRY_EN			BIT(2)
+#define TX_EN				BIT(0)
+
+#define NB8800_TX_CTL2			0x01
+
+#define NB8800_RX_CTL			0x04
+#define RX_BC_DISABLE			BIT(7)
+#define RX_RUNT				BIT(6)
+#define RX_AF_EN			BIT(5)
+#define RX_PAUSE_EN			BIT(3)
+#define RX_SEND_CRC			BIT(2)
+#define RX_PAD_STRIP			BIT(1)
+#define RX_EN				BIT(0)
+
+#define NB8800_RANDOM_SEED		0x8
+#define NB8800_TX_SDP			0x14
+#define NB8800_TX_TPDP1			0x18
+#define NB8800_TX_TPDP2			0x19
+#define NB8800_SLOT_TIME		0x1c
+
+#define NB8800_MDIO_CMD			0x20
+#define MIIAR_ADDR(x)			((x) << 21)
+#define MIIAR_REG(x)			((x) << 16)
+#define MIIAR_DATA(x)			((x) <<	 0)
+#define MDIO_CMD_GO			BIT(31)
+#define MDIO_CMD_WR			BIT(26)
+
+#define NB8800_MDIO_STS			0x24
+#define MDIO_STS_ERR			BIT(31)
+
+#define NB8800_MC_ADDR1			0x28
+#define NB8800_MC_ADDR2			0x29
+#define NB8800_MC_ADDR3			0x2a
+#define NB8800_MC_ADDR4			0x2b
+#define NB8800_MC_ADDR5			0x2c
+#define NB8800_MC_ADDR6			0x2d
+#define NB8800_MC_INIT			0x2e
+#define NB8800_UC_ADDR1			0x3c
+#define NB8800_UC_ADDR2			0x3d
+#define NB8800_UC_ADDR3			0x3e
+#define NB8800_UC_ADDR4			0x3f
+#define NB8800_UC_ADDR5			0x40
+#define NB8800_UC_ADDR6			0x41
+
+#define NB8800_MAC_MODE			0x44
+#define RGMII_MODE			BIT(7)
+#define HALF_DUPLEX			BIT(4)
+#define BURST_EN			BIT(3)
+#define LOOPBACK_EN			BIT(2)
+#define GMAC_MODE			BIT(0)
+
+#define NB8800_IC_THRESHOLD		0x50
+#define NB8800_PE_THRESHOLD		0x51
+#define NB8800_PF_THRESHOLD		0x52
+#define NB8800_TX_BUFSIZE		0x54
+#define NB8800_FIFO_CTL			0x56
+#define NB8800_PQ1			0x60
+#define NB8800_PQ2			0x61
+#define NB8800_MAC_ADDR1		0x6a
+#define NB8800_MAC_ADDR2		0x6b
+#define NB8800_MAC_ADDR3		0x6c
+#define NB8800_MAC_ADDR4		0x6d
+#define NB8800_MAC_ADDR5		0x6e
+#define NB8800_MAC_ADDR6		0x6f
+#define NB8800_STAT_DATA1		0x78
+#define NB8800_STAT_DATA2		0x79
+#define NB8800_STAT_DATA3		0x7a
+#define NB8800_STAT_DATA4		0x7b
+#define NB8800_STAT_INDEX		0x7c
+#define NB8800_STAT_CLEAR		0x7d
+
+#define NB8800_SLEEP_MODE		0x7e
+#define SLEEP_MODE			BIT(0)
+
+#define NB8800_WAKEUP			0x7f
+#define WAKEUP				BIT(0)
+
+#define NB8800_TXC_CR			0x100
+#define TCR_LK				BIT(12)
+#define TCR_DS				BIT(11)
+#define TCR_BTS(x)			(((x) & 0x7) << 8)
+#define TCR_DIE				BIT(7)
+#define TCR_TFI(x)			(((x) & 0x7) << 4)
+#define TCR_LE				BIT(3)
+#define TCR_RS				BIT(2)
+#define TCR_DM				BIT(1)
+#define TCR_EN				BIT(0)
+
+#define NB8800_TXC_SR			0x104
+#define TSR_DE				BIT(3)
+#define TSR_DI				BIT(2)
+#define TSR_TO				BIT(1)
+#define TSR_TI				BIT(0)
+
+#define NB8800_TX_SAR			0x108
+#define NB8800_TX_DESC_ADDR		0x10c
+
+#define NB8800_TX_REPORT_ADDR		0x110
+#define TX_BYTES_TRASFERRED(x)		(((x) >> 16) & 0xffff)
+#define TX_FIRST_DEFERRAL		BIT(7)
+#define TX_EARLY_COLLISIONS(x)		(((x) >> 3) & 0xf)
+#define TX_LATE_COLLISION		BIT(2)
+#define TX_PACKET_DROPPED		BIT(1)
+#define TX_FIFO_UNDERRUN		BIT(0)
+#define IS_TX_ERROR(r)			((r) & 0x87)
+
+#define NB8800_TX_FIFO_SR		0x114
+#define NB8800_TX_ITR			0x118
+
+#define NB8800_RXC_CR			0x200
+#define RCR_FL				BIT(13)
+#define RCR_LK				BIT(12)
+#define RCR_DS				BIT(11)
+#define RCR_BTS(x)			(((x) & 7) << 8)
+#define RCR_DIE				BIT(7)
+#define RCR_RFI(x)			(((x) & 7) << 4)
+#define RCR_LE				BIT(3)
+#define RCR_RS				BIT(2)
+#define RCR_DM				BIT(1)
+#define RCR_EN				BIT(0)
+
+#define NB8800_RXC_SR			0x204
+#define RSR_DE				BIT(3)
+#define RSR_DI				BIT(2)
+#define RSR_RO				BIT(1)
+#define RSR_RI				BIT(0)
+
+#define NB8800_RX_SAR			0x208
+#define NB8800_RX_DESC_ADDR		0x20c
+
+#define NB8800_RX_REPORT_ADDR		0x210
+#define RX_BYTES_TRANSFERRED(x)		(((x) >> 16) & 0xFFFF)
+#define RX_MULTICAST_PKT		BIT(9)
+#define RX_BROADCAST_PKT		BIT(8)
+#define RX_LENGTH_ERR			BIT(7)
+#define RX_FCS_ERR			BIT(6)
+#define RX_RUNT_PKT			BIT(5)
+#define RX_FIFO_OVERRUN			BIT(4)
+#define RX_LATE_COLLISION		BIT(3)
+#define RX_FRAME_LEN_ERROR		BIT(2)
+#define RX_ERROR_MASK			0xfc
+#define IS_RX_ERROR(r)			((r) & RX_ERROR_MASK)
+
+#define NB8800_RX_FIFO_SR		0x214
+#define NB8800_RX_ITR			0x218
+
+/* Sigma Designs SMP86xx additional registers */
+#define NB8800_TANGOX_PAD_MODE		0x400
+#define NB8800_TANGOX_MDIO_CLKDIV	0x420
+#define NB8800_TANGOX_RESET		0x424
+
+struct nb8800_dma_desc {
+	u32 s_addr;
+	u32 n_addr;
+	u32 r_addr;
+	u32 config;
+	u8  buf[12];
+	u32 report;
+};
+
+#define DESC_ID				BIT(23)
+#define DESC_EOC			BIT(22)
+#define DESC_EOF			BIT(21)
+#define DESC_LK				BIT(20)
+#define DESC_DS				BIT(19)
+#define DESC_BTS(x)			(((x) & 0x7) << 16)
+
+struct rx_buf {
+	struct page *page;
+	int offset;
+};
+
+struct tx_buf {
+	struct sk_buff *skb;
+	dma_addr_t desc_dma;
+	int frags;
+};
+
+struct tx_skb_data {
+	dma_addr_t dma_addr;
+	unsigned int dma_len;
+};
+
+struct nb8800_priv {
+	struct napi_struct		napi;
+
+	void __iomem			*base;
+
+	struct nb8800_dma_desc		*rx_descs;
+	struct rx_buf			*rx_bufs;
+	u16				rx_eoc;
+
+	struct nb8800_dma_desc		*tx_descs;
+	struct tx_buf			*tx_bufs;
+	atomic_t			tx_free;
+	u32				tx_pending;
+	u32				tx_dirty;
+	u16				tx_next;
+	u16				tx_reclaim_next;
+	u16				tx_reclaim_limit;
+	u16				tx_done;
+
+	struct tasklet_struct		tx_reclaim_tasklet;
+	struct timer_list		tx_reclaim_timer;
+
+	struct net_device_stats		stats;
+
+	struct mii_bus			*mii_bus;
+	struct phy_device		*phydev;
+	int				speed;
+	int				duplex;
+	int				link;
+
+	dma_addr_t			rx_desc_dma;
+	dma_addr_t			tx_desc_dma;
+
+	int				gigabit;
+	struct clk			*clk;
+};
+
+struct nb8800_ops {
+	void (*init)(struct net_device *dev);
+	void (*reset)(struct net_device *dev);
+};
+
+#endif /* _NB8800_H_ */
-- 
2.5.3

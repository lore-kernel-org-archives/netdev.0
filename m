From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: [PATCH 1/1] net: Add Aeroflex Gaisler GRETH 10/100/1G Ethernet MAC driver
Date: Fri,  8 Jan 2010 16:45:31 +0100
Message-ID: <1262965531-4800-2-git-send-email-kristoffer@gaisler.com>
References: <1262965531-4800-1-git-send-email-kristoffer@gaisler.com>
Cc: Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail176c2.megamailservers.com ([69.49.111.76]:33462 "EHLO
	mail176c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753547Ab0AHQDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 11:03:15 -0500
In-Reply-To: <1262965531-4800-1-git-send-email-kristoffer@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds device driver for Aeroflex Gaisler 10/100 and 10/100/1G Ethernet MAC IP cores.

Signed-off-by: Kristoffer Glembo <kristoffer@gaisler.com>
---
 MAINTAINERS          |    6 +
 drivers/net/Kconfig  |   48 ++
 drivers/net/Makefile |    1 +
 drivers/net/greth.c  | 1384 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/greth.h  |  154 ++++++
 5 files changed, 1593 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/greth.c
 create mode 100644 drivers/net/greth.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 745643b..45c047c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2372,6 +2372,12 @@ F:	Documentation/isdn/README.gigaset
 F:	drivers/isdn/gigaset/
 F:	include/linux/gigaset_dev.h
 
+GRETH 10/100/1G Ethernet MAC device driver
+M:	Kristoffer Glembo <kristoffer@gaisler.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/greth*
+
 HARD DRIVE ACTIVE PROTECTION SYSTEM (HDAPS) DRIVER
 M:	Frank Seidel <frank@f-seidel.de>
 L:	lm-sensors@lm-sensors.org
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dd9a09c..806c127 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -983,6 +983,30 @@ config ETHOC
 	help
 	  Say Y here if you want to use the OpenCores 10/100 Mbps Ethernet MAC.
 
+config GRETH
+	tristate "Aeroflex Gaisler GRETH Ethernet MAC support"
+	depends on OF
+	select PHYLIB
+	select CRC32
+	help
+	  Say Y here if you want to use the Aeroflex Gaisler GRETH Ethernet MAC.
+
+config GRETH_MACMSB
+	hex "MSB 24 bits of Ethernet MAC address (hex)" 
+	default 00007A
+	depends on GRETH
+	---help---
+	  Most significant 24 bits of the default MAC address
+	  that is initialized when driver probes. 
+
+config GRETH_MACLSB
+	hex "LSB 24 bits of MAC address (hex)" 
+	default CC0012
+	depends on GRETH
+	---help---
+	  Least significant 24 bits of the default MAC address
+	  that is initialized when driver probes. 
+
 config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
@@ -2489,6 +2513,30 @@ config S6GMAC
 
 source "drivers/net/stmmac/Kconfig"
 
+config GRETH
+	tristate "Aeroflex Gaisler GRETH_GBIT Ethernet MAC support"
+	depends on OF
+	select PHYLIB
+	select CRC32
+	help
+	  Say Y here if you want to use the Aeroflex Gaisler GRETH_GBIT Ethernet MAC.
+
+config GRETH_MACMSB
+	hex "MSB 24 bits of Ethernet MAC address (hex)" 
+	default 00007A
+	depends on GRETH
+	---help---
+	  Most significant 24 bits of the default MAC address
+	  that is initialized when driver probes. 
+
+config GRETH_MACLSB
+	hex "LSB 24 bits of MAC address (hex)" 
+	default CC0012
+	depends on GRETH
+	---help---
+	  Least significant 24 bits of the default MAC address
+	  that is initialized when driver probes. 
+
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ad1346d..9f12170 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -246,6 +246,7 @@ pasemi_mac_driver-objs := pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_MLX4_CORE) += mlx4/
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
+obj-$(CONFIG_GRETH) += greth.o
 
 obj-$(CONFIG_XTENSA_XT2000_SONIC) += xtsonic.o
 
diff --git a/drivers/net/greth.c b/drivers/net/greth.c
new file mode 100644
index 0000000..7df4bee
--- /dev/null
+++ b/drivers/net/greth.c
@@ -0,0 +1,1384 @@
+/*
+ * Aeroflex Gaisler GRETH 10/100/1G Ethernet MAC.
+ *
+ * 2005-2009 (c) Aeroflex Gaisler AB
+ *
+ * This driver supports GRETH 10/100 and GRETH 10/100/1G Ethernet MACs
+ * available in the GRLIB VHDL IP core library.
+ *
+ * A GPL version of the library can be downloaded from www.gaisler.com
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2 of the License, or (at your
+ * option) any later version.
+ *
+ * Contributors: Kristoffer Glembo
+ *               Daniel Hellstrom
+ *               Marko Isomaki
+ */
+
+#include <linux/module.h>
+#include <linux/uaccess.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/io.h>
+#include <linux/crc32.h>
+
+#include <linux/of_device.h>
+#include <linux/of_platform.h>
+
+#include <asm/cacheflush.h>
+#include <linux/mii.h>
+
+#include "greth.h"
+
+#undef DEBUG
+#undef DEBUG_TX_PACKETS
+#undef DEBUG_RX_PACKETS
+
+static int greth_open(struct net_device *dev);
+static int greth_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static int greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev);
+static int greth_rx(struct net_device *dev, int limit);
+static int greth_rx_gbit(struct net_device *dev, int limit);
+static void greth_clean_tx(struct net_device *dev);
+static void greth_clean_tx_gbit(struct net_device *dev);
+static irqreturn_t greth_interrupt(int irq, void *dev_id);
+static int greth_close(struct net_device *dev);
+static struct net_device_stats *greth_get_stats(struct net_device *dev);
+static int greth_set_mac_add(struct net_device *dev, void *p);
+static void greth_set_multicast_list(struct net_device *dev);
+
+#define GRETH_REGLOAD(a)	    (__raw_readl(&(a)))
+#define GRETH_REGSAVE(a, v)         (__raw_writel(v, &(a)))
+#define GRETH_REGORIN(a, v)         (GRETH_REGSAVE(a, (GRETH_REGLOAD(a) | (v))))
+#define GRETH_REGANDIN(a, v)        (GRETH_REGSAVE(a, (GRETH_REGLOAD(a) & (v))))
+
+#ifdef DEBUG
+static void greth_print_rx_packet(unsigned long addr, int len)
+{
+	int i;
+
+	pr_debug("RX packet: addr = %x, len = %d\n", addr, len);
+
+	for (i = 0; i < len; i++) {
+
+		if (!(i % 16))
+			pr_debug("\n");
+
+		pr_debug(" %.2x", *(((unsigned char *) addr) + i));
+	}
+	pr_debug("\n");
+}
+
+static void greth_print_tx_packet(struct sk_buff *skb)
+{
+	int i;
+	int j;
+	int count;
+
+	pr_debug("TX packet: len = %d nr_frags = %d \n", skb->len, skb_shinfo(skb)->nr_frags);
+
+	count = 0;
+	for (i = 0; i < skb->len - skb->data_len; i++) {
+
+		if (!(count % 16))
+			pr_debug("\n");
+
+		pr_debug(" %.2x", *(((unsigned char *) skb->data) + i));
+		count++;
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+
+		for (j = 0; j < skb_shinfo(skb)->frags[i].size; j++) {
+
+			if (!(count % 16))
+				pr_debug("\n");
+
+			pr_debug(" %.2x", *((unsigned char *)
+					    (phys_to_virt
+					     (skb_shinfo(skb)->frags[i].page) +
+					     skb_shinfo(skb)->frags[i].page_offset + j)));
+
+			count++;
+		}
+	}
+	pr_debug("\n");
+}
+#endif
+
+/* Wait for a register change with a timeout, jiffies used has time reference */
+#define wait_loop(wait_statement, timeout, label_on_timeout, arg_on_timeout) \
+	{ \
+		unsigned long _timeout = jiffies + HZ*timeout; \
+		while (wait_statement) { \
+			if (time_after(jiffies, _timeout)) { \
+				arg_on_timeout; \
+goto label_on_timeout; \
+			} \
+		} \
+	}
+
+
+static int greth_init_rings(struct greth_private *greth)
+{
+	struct sk_buff *skb;
+	struct greth_bd *rx_bd, *tx_bd;
+	int i;
+
+	rx_bd = greth->rx_bd_base;
+	tx_bd = greth->tx_bd_base;
+
+	/* Initialize descriptor rings and buffers */
+	if (greth->gbit_mac) {
+
+		for (i = 0; i < GRETH_RXBD_NUM; i++) {
+			skb = netdev_alloc_skb(greth->netdev, MAX_FRAME_SIZE + NET_IP_ALIGN);
+			skb_reserve(skb, NET_IP_ALIGN);
+			if (skb == NULL) {
+				return -ENOMEM;
+			}
+			rx_bd[i].addr = dma_map_single(greth->dev,
+						       skb->data,
+						       MAX_FRAME_SIZE + NET_IP_ALIGN,
+						       DMA_FROM_DEVICE);
+
+			greth->rx_skbuff[i] = skb;
+			rx_bd[i].stat = GRETH_BD_EN | GRETH_BD_IE;
+		}
+
+	} else {
+
+		/* 10/100 MAC uses preallocated buffers */
+		greth->tx_bufs = kmalloc(MAX_FRAME_SIZE * GRETH_TXBD_NUM, GFP_KERNEL);
+
+		if (greth->tx_bufs == NULL) {
+			return -ENOMEM;
+		}
+
+		greth->rx_bufs = kmalloc(MAX_FRAME_SIZE * GRETH_RXBD_NUM, GFP_KERNEL);
+
+		if (greth->rx_bufs == NULL) {
+			kfree(greth->tx_bufs);
+			return -ENOMEM;
+		}
+
+		for (i = 0; i < GRETH_RXBD_NUM; i++) {
+			rx_bd[i].addr = dma_map_single(greth->dev,
+						       greth->rx_bufs +
+						       MAX_FRAME_SIZE * i,
+						       MAX_FRAME_SIZE, DMA_FROM_DEVICE);
+
+			rx_bd[i].stat = GRETH_BD_EN | GRETH_BD_IE;
+		}
+		for (i = 0; i < GRETH_TXBD_NUM; i++) {
+			tx_bd[i].addr = dma_map_single(greth->dev,
+						       greth->tx_bufs +
+						       MAX_FRAME_SIZE * i,
+						       MAX_FRAME_SIZE, DMA_TO_DEVICE);
+			tx_bd[i].stat = 0;
+		}
+	}
+	rx_bd[GRETH_RXBD_NUM - 1].stat |= GRETH_BD_WR;
+
+	/* Initialize pointers. */
+	greth->rx_cur = 0;
+	greth->tx_next = 0;
+	greth->tx_last = 0;
+	greth->tx_free = GRETH_TXBD_NUM;
+
+	/* Initialize descriptor base address */
+	GRETH_REGSAVE(greth->regs->tx_desc_p, greth->tx_bd_base_phys);
+	GRETH_REGSAVE(greth->regs->rx_desc_p, greth->rx_bd_base_phys);
+
+	return 0;
+}
+
+static void greth_clean_rings(struct greth_private *greth)
+{
+	int i;
+
+	/* Free buffers */
+	if (greth->gbit_mac) {
+		for (i = 0; i < GRETH_RXBD_NUM; i++) {
+			if (greth->rx_skbuff[i] != NULL) {
+				dev_kfree_skb(greth->rx_skbuff[i]);
+			}
+		}
+		for (i = 0; i < GRETH_TXBD_NUM; i++) {
+			if (greth->tx_skbuff[i] != NULL) {
+				dev_kfree_skb(greth->tx_skbuff[i]);
+			}
+		}
+	} else {
+		kfree(greth->tx_bufs);
+		kfree(greth->rx_bufs);
+	}
+}
+
+static int greth_open(struct net_device *dev)
+{
+	struct greth_private *greth = netdev_priv(dev);
+	struct greth_regs *regs = (struct greth_regs *) greth->regs;
+	int err;
+
+	err = greth_init_rings(greth);
+	if (err) {
+		dev_err(&dev->dev, "Could not allocate memory for DMA rings\n");
+		return err;
+	}
+
+	err = request_irq(greth->irq, greth_interrupt, 0, "eth", (void *) dev);
+	if (err) {
+		dev_err(&dev->dev, "Could not allocate interrupt %d\n", dev->irq);
+		return err;
+	}
+
+	if (netif_queue_stopped(dev)) {
+		dev_dbg(&dev->dev, " resuming queue\n");
+		netif_wake_queue(dev);
+	} else {
+		dev_dbg(&dev->dev, " starting queue\n");
+		netif_start_queue(dev);
+	}
+
+	napi_enable(&greth->napi);
+
+	/* Enable receiver and rx/tx interrupts */
+	GRETH_REGORIN(regs->control, GRETH_RXEN | GRETH_RXI | GRETH_TXI);
+	return 0;
+
+}
+
+static int greth_close(struct net_device *dev)
+{
+	struct greth_private *greth = netdev_priv(dev);
+	struct greth_regs *regs = (struct greth_regs *) greth->regs;
+
+	napi_disable(&greth->napi);
+
+	free_irq(greth->irq, (void *) dev);
+
+	/* Disable receiver and transmitter */
+	GRETH_REGANDIN(regs->control, ~(GRETH_RXEN | GRETH_TXEN));
+
+	if (!netif_queue_stopped(dev))
+		netif_stop_queue(dev);
+
+	greth_clean_rings(greth);
+
+	return 0;
+}
+
+static int greth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct greth_private *greth = netdev_priv(dev);
+	struct greth_regs *regs;
+	struct greth_bd *bdp;
+	int err = NETDEV_TX_OK;
+	u32 status;
+
+	regs = (struct greth_regs *) greth->regs;
+
+	bdp = greth->tx_bd_base + greth->tx_next;
+
+	if (unlikely(greth->tx_free <= 0)) {
+		netif_stop_queue(dev);
+		err = NETDEV_TX_BUSY;
+		goto out;
+	}
+#ifdef DEBUG_TX_PACKETS
+	greth_print_tx_packet(skb);
+#endif
+
+	if (unlikely(skb->len > MAX_FRAME_SIZE)) {
+		greth->stats.tx_errors++;
+		goto out;
+	}
+
+	memcpy((unsigned char *) phys_to_virt(bdp->addr), skb->data, skb->len);
+
+	dma_sync_single_for_device(greth->dev, bdp->addr, skb->len, DMA_TO_DEVICE);
+
+
+	status = GRETH_BD_EN | (skb->len & GRETH_BD_LEN);
+
+	/* Wrap around descriptor ring */
+	if (greth->tx_next == GRETH_TXBD_NUM_MASK) {
+		status |= GRETH_BD_WR;
+	}
+
+	greth->tx_next = ((greth->tx_next + 1) & GRETH_TXBD_NUM_MASK);
+	greth->tx_free--;
+
+	/* No more descriptors */
+	if (unlikely(greth->tx_free == 0)) {
+
+		/* Free transmitted descriptors */
+		greth_clean_tx(dev);
+
+		/* If nothing was cleaned, stop queue & wait for irq */
+		if (unlikely(greth->tx_free == 0)) {
+			status |= GRETH_BD_IE;
+			netif_stop_queue(dev);
+		}
+	}
+
+	/* Write descriptor control word and enable transmission */
+	bdp->stat = status;
+	GRETH_REGORIN(regs->control, GRETH_TXEN);
+
+out:
+	dev_kfree_skb(skb);
+	return err;
+}
+
+
+static int greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct greth_private *greth = netdev_priv(dev);
+	struct greth_regs *regs = (struct greth_regs *) greth->regs;
+	struct greth_bd *bdp;
+	u32 status;
+	int nr_frags, i, err = NETDEV_TX_OK;
+
+	nr_frags = skb_shinfo(skb)->nr_frags;
+
+	bdp = greth->tx_bd_base + greth->tx_next;
+
+	if (greth->tx_free < nr_frags + 1) {
+		netif_stop_queue(dev);
+		err = NETDEV_TX_BUSY;
+		goto out;
+	}
+#ifdef DEBUG_TX_PACKETS
+	greth_print_tx_packet(skb);
+#endif
+
+	if (unlikely(skb->len > MAX_FRAME_SIZE)) {
+		greth->stats.tx_errors++;
+		goto out;
+	}
+
+	/* Save skb pointer. */
+	greth->tx_skbuff[greth->tx_next] = skb;
+
+	if (nr_frags == 0) {
+
+		bdp->addr = dma_map_single(greth->dev, skb->data, skb->len, DMA_TO_DEVICE);
+
+		status = GRETH_BD_EN | GRETH_TXBD_CSALL;
+		status |= skb->len & GRETH_BD_LEN;
+		if (greth->tx_next == GRETH_TXBD_NUM_MASK)
+			status |= GRETH_BD_WR;
+
+
+		greth->tx_next = ((greth->tx_next + 1) & GRETH_TXBD_NUM_MASK);
+		greth->tx_free--;
+
+		/* Clean up */
+		if (greth->tx_free < (MAX_SKB_FRAGS + 1)) {
+			status |= GRETH_BD_IE;
+			netif_stop_queue(dev);
+		}
+		bdp->stat = status;
+	} else {
+
+		/* Initial fragment */
+		bdp->addr = dma_map_single(greth->dev, skb->data, skb->len, DMA_TO_DEVICE);
+
+		status = GRETH_BD_EN | GRETH_TXBD_MORE | GRETH_TXBD_CSALL;
+		status |= skb_headlen(skb) & GRETH_BD_LEN;
+		if (greth->tx_next == GRETH_TXBD_NUM_MASK)
+			status |= GRETH_BD_WR;
+
+		bdp->stat = status;
+
+		greth->tx_next = ((greth->tx_next + 1) & GRETH_TXBD_NUM_MASK);
+		greth->tx_free--;
+
+		bdp = greth->tx_bd_base + greth->tx_next;
+
+		/* Add descriptors for the rest of the frags */
+		for (i = 0; i < nr_frags; i++) {
+
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+			greth->tx_skbuff[greth->tx_next] = NULL;
+			greth->tx_free--;
+
+			bdp->addr = dma_map_page(greth->dev,
+						 frag->page,
+						 frag->page_offset, frag->size, DMA_TO_DEVICE);
+
+			status = GRETH_BD_EN | GRETH_TXBD_CSALL;
+			status |= frag->size & GRETH_BD_LEN;
+
+			/* Wrap around descriptor ring */
+			if (greth->tx_next == GRETH_TXBD_NUM_MASK)
+				status |= GRETH_BD_WR;
+
+			greth->tx_next = (greth->tx_next + 1) & GRETH_TXBD_NUM_MASK;
+
+			/* More fragments left */
+			if (i < nr_frags - 1)
+				status |= GRETH_TXBD_MORE;
+
+			/* ... last fragment */
+			else {
+				if (greth->tx_free <= (MAX_SKB_FRAGS + 1)) {
+					status |= GRETH_BD_IE;
+					netif_stop_queue(dev);
+				}
+			}
+
+			bdp->stat = status;
+			bdp = greth->tx_bd_base + greth->tx_next;
+		}
+	}
+
+	GRETH_REGORIN(regs->control, GRETH_TXEN);
+
+out:
+	return err;
+}
+
+
+static irqreturn_t greth_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct greth_private *greth;
+	u32 status;
+
+	greth = netdev_priv(dev);
+
+	spin_lock(&greth->devlock);
+
+	/* Get the interrupt events that caused us to be here. */
+	status = GRETH_REGLOAD(greth->regs->status);
+
+	/* Clear interrupt status */
+	GRETH_REGORIN(greth->regs->status,
+		      status & (GRETH_INT_RX | GRETH_INT_TX | GRETH_STATUS_PHYSTAT));
+
+	/* Handle rx and tx interrupts through poll */
+	if (status & (GRETH_INT_RX | GRETH_INT_TX)) {
+		if (napi_schedule_prep(&greth->napi)) {
+			/* Disable interrupts and schedule poll() */
+			GRETH_REGANDIN(greth->regs->control, ~(GRETH_RXI | GRETH_TXI));
+			__napi_schedule(&greth->napi);
+		}
+	}
+
+	spin_unlock(&greth->devlock);
+
+	return IRQ_HANDLED;
+}
+
+static void greth_clean_tx(struct net_device *dev)
+{
+	struct greth_private *greth;
+	struct greth_bd *bdp;
+	u32 stat;
+
+	greth = netdev_priv(dev);
+
+	while (1) {
+		bdp = greth->tx_bd_base + greth->tx_last;
+		stat = bdp->stat;
+
+		if (unlikely(stat & GRETH_BD_EN))
+			break;
+
+		if (greth->tx_free == GRETH_TXBD_NUM)
+			break;
+
+		/* Check status for errors
+		 */
+		if (unlikely(stat & GRETH_TXBD_STATUS)) {
+			greth->stats.tx_errors++;
+			if (stat & GRETH_TXBD_ERR_AL)
+				greth->stats.tx_aborted_errors++;
+			if (stat & GRETH_TXBD_ERR_UE)
+				greth->stats.tx_fifo_errors++;
+		}
+		greth->stats.tx_packets++;
+		greth->tx_last = (greth->tx_last + 1) & GRETH_TXBD_NUM_MASK;
+		greth->tx_free++;
+	}
+
+	if (unlikely(netif_queue_stopped(dev) && greth->tx_free > 0)) {
+		netif_wake_queue(dev);
+	}
+
+}
+
+static void greth_clean_tx_gbit(struct net_device *dev)
+{
+	struct greth_private *greth;
+	struct greth_bd *bdp;
+	struct sk_buff *skb;
+	u32 stat;
+
+	greth = netdev_priv(dev);
+
+	while (1) {
+		bdp = greth->tx_bd_base + greth->tx_last;
+		stat = bdp->stat;
+
+		if (stat & GRETH_BD_EN)
+			break;
+
+		if (greth->tx_free >= GRETH_TXBD_NUM)
+			break;
+
+		/* Check status for errors */
+		if (unlikely(stat & GRETH_TXBD_STATUS)) {
+			greth->stats.tx_errors++;
+			if (stat & GRETH_TXBD_ERR_AL)
+				greth->stats.tx_aborted_errors++;
+			if (stat & GRETH_TXBD_ERR_UE)
+				greth->stats.tx_fifo_errors++;
+			if (stat & GRETH_TXBD_ERR_LC)
+				greth->stats.tx_aborted_errors++;
+		}
+		greth->stats.tx_packets++;
+
+		dma_unmap_single(greth->dev,
+				 bdp->addr, MAX_FRAME_SIZE + NET_IP_ALIGN, DMA_TO_DEVICE);
+
+		skb = greth->tx_skbuff[greth->tx_last];
+		if (skb != NULL) {
+			dev_kfree_skb_irq(skb);
+		}
+		greth->tx_last = (greth->tx_last + 1) & GRETH_TXBD_NUM_MASK;
+		greth->tx_free++;
+	}
+
+	if (unlikely(netif_queue_stopped(dev) && greth->tx_free > (MAX_SKB_FRAGS + 1))) {
+		netif_wake_queue(dev);
+	}
+}
+
+static int greth_pending_packets(struct greth_private *greth)
+{
+	struct greth_bd *bdp;
+	u32 status;
+	bdp = greth->rx_bd_base + greth->rx_cur;
+	status = bdp->stat;
+	if (status & GRETH_BD_EN)
+		return 0;
+	else
+		return 1;
+}
+
+static int greth_rx(struct net_device *dev, int limit)
+{
+	struct greth_private *greth;
+	struct greth_regs *regs;
+	struct greth_bd *bdp;
+	struct sk_buff *skb;
+	int pkt_len;
+	int bad, count;
+	u32 status;
+
+	greth = netdev_priv(dev);
+
+	regs = (struct greth_regs *) greth->regs;
+
+	for (count = 0; count < limit; ++count) {
+
+		bdp = greth->rx_bd_base + greth->rx_cur;
+		status = bdp->stat;
+		bad = 0;
+
+		if (unlikely(status & GRETH_BD_EN)) {
+			break;
+		}
+
+		/* Check status for errors. */
+		if (unlikely(status & GRETH_RXBD_STATUS)) {
+			if (status & GRETH_RXBD_ERR_FT) {
+				greth->stats.rx_length_errors++;
+				bad = 1;
+			}
+			if (status & (GRETH_RXBD_ERR_AE | GRETH_RXBD_ERR_OE)) {
+				greth->stats.rx_frame_errors++;
+				bad = 1;
+			}
+			if (status & GRETH_RXBD_ERR_CRC) {
+				greth->stats.rx_crc_errors++;
+				bad = 1;
+			}
+		}
+		if (unlikely(bad)) {
+			greth->stats.rx_errors++;
+
+		} else {
+
+			pkt_len = status & GRETH_BD_LEN;
+
+			skb = netdev_alloc_skb(dev, pkt_len + NET_IP_ALIGN);
+
+			if (unlikely(skb == NULL)) {
+
+				if (net_ratelimit())
+					dev_warn(&dev->dev, "low on memory - " "packet dropped\n");
+
+				greth->stats.rx_dropped++;
+
+			} else {
+				skb_reserve(skb, NET_IP_ALIGN);
+				skb->dev = dev;
+
+				dma_sync_single_for_cpu(greth->dev,
+							bdp->addr, pkt_len, DMA_FROM_DEVICE);
+
+#ifdef DEBUG_RX_PACKETS
+				greth_print_rx_packet(phys_to_virt(bdp->addr), pkt_len);
+#endif
+				memcpy(skb_put(skb, pkt_len), phys_to_virt(bdp->addr), pkt_len);
+
+				skb->protocol = eth_type_trans(skb, dev);
+				greth->stats.rx_packets++;
+				netif_receive_skb(skb);
+			}
+		}
+
+		status = GRETH_BD_EN | GRETH_BD_IE;
+		if (greth->rx_cur == GRETH_RXBD_NUM_MASK) {
+			status |= GRETH_BD_WR;
+		}
+		bdp->stat = status;
+
+		dma_sync_single_for_device(greth->dev, bdp->addr, MAX_FRAME_SIZE, DMA_FROM_DEVICE);
+
+		GRETH_REGORIN(regs->control, GRETH_RXEN);
+
+		greth->rx_cur = (greth->rx_cur + 1) & GRETH_RXBD_NUM_MASK;
+	}
+
+	return count;
+}
+
+static inline int hw_checksummed(u32 status)
+{
+
+	if (status & GRETH_RXBD_IP_FRAG)
+		return 0;
+
+	if (status & GRETH_RXBD_IP && status & GRETH_RXBD_IP_CSERR)
+		return 0;
+
+	if (status & GRETH_RXBD_UDP && status & GRETH_RXBD_UDP_CSERR)
+		return 0;
+
+	if (status & GRETH_RXBD_TCP && status & GRETH_RXBD_TCP_CSERR)
+		return 0;
+
+	return 1;
+}
+
+static int greth_rx_gbit(struct net_device *dev, int limit)
+{
+	struct greth_private *greth;
+	struct greth_regs *regs;
+	struct greth_bd *bdp;
+	struct sk_buff *skb;
+	int pkt_len;
+	int bad, count = 0;
+	u32 status;
+
+	greth = netdev_priv(dev);
+	regs = (struct greth_regs *) greth->regs;
+
+	for (count = 0; count < limit; ++count) {
+
+		bdp = greth->rx_bd_base + greth->rx_cur;
+		skb = greth->rx_skbuff[greth->rx_cur];
+		status = bdp->stat;
+		bad = 0;
+
+		if (status & GRETH_BD_EN)
+			break;
+
+		/* Check status for errors. */
+		if (unlikely(status & GRETH_RXBD_STATUS)) {
+
+			if (status & GRETH_RXBD_ERR_FT) {
+				greth->stats.rx_length_errors++;
+				bad = 1;
+			} else if (status &
+				   (GRETH_RXBD_ERR_AE | GRETH_RXBD_ERR_OE | GRETH_RXBD_ERR_LE)) {
+				greth->stats.rx_frame_errors++;
+				bad = 1;
+			} else if (status & GRETH_RXBD_ERR_CRC) {
+				greth->stats.rx_crc_errors++;
+				bad = 1;
+			}
+		}
+
+		if (unlikely(bad)) {
+			greth->stats.rx_dropped++;
+
+		} else {
+
+			/* Process the incoming frame. */
+			pkt_len = status & GRETH_BD_LEN;
+			skb_put(skb, pkt_len);
+
+			dma_unmap_single(greth->dev, bdp->addr, skb->len, DMA_FROM_DEVICE);
+
+#ifdef DEBUG_RX_PACKETS
+			greth_print_rx_packet(phys_to_virt(bdp->addr), pkt_len);
+#endif
+
+			if (hw_checksummed(status))
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			else
+				skb->ip_summed = CHECKSUM_NONE;
+
+			skb->dev = dev;
+			skb->protocol = eth_type_trans(skb, dev);
+			greth->stats.rx_packets++;
+			netif_receive_skb(skb);
+
+			skb = netdev_alloc_skb(dev, MAX_FRAME_SIZE + NET_IP_ALIGN);
+
+			skb_reserve(skb, NET_IP_ALIGN);
+
+			if (skb) {
+				bdp->addr = dma_map_single(greth->dev,
+							   skb->data,
+							   MAX_FRAME_SIZE +
+							   NET_IP_ALIGN, DMA_FROM_DEVICE);
+
+			} else {
+				dev_err(&dev->dev, "error allocating new skb.");
+			}
+			greth->rx_skbuff[greth->rx_cur] = skb;
+
+		}
+
+		status = GRETH_BD_EN | GRETH_BD_IE;
+		if (greth->rx_cur == GRETH_RXBD_NUM_MASK) {
+			status |= GRETH_BD_WR;
+		}
+		bdp->stat = status;
+
+		GRETH_REGORIN(regs->control, GRETH_RXEN);
+
+		greth->rx_cur = (greth->rx_cur + 1) & GRETH_RXBD_NUM_MASK;
+
+	}
+
+	return count;
+
+}
+
+static int greth_poll(struct napi_struct *napi, int budget)
+{
+	struct greth_private *greth;
+	int work_done = 0;
+	greth = container_of(napi, struct greth_private, napi);
+
+	if (greth->gbit_mac) {
+		greth_clean_tx_gbit(greth->netdev);
+	} else {
+		greth_clean_tx(greth->netdev);
+	}
+
+restart_poll:
+	if (greth->gbit_mac) {
+		work_done += greth_rx_gbit(greth->netdev, budget - work_done);
+	} else {
+		work_done += greth_rx(greth->netdev, budget - work_done);
+	}
+
+	if (work_done < budget) {
+
+		napi_complete(napi);
+
+		if (greth_pending_packets(greth)) {
+			napi_reschedule(napi);
+			goto restart_poll;
+		}
+	}
+
+	/* Enable interrupts */
+	GRETH_REGORIN(greth->regs->control, GRETH_RXI | GRETH_TXI);
+	return work_done;
+}
+
+static struct net_device_stats *greth_get_stats(struct net_device *dev)
+{
+	struct greth_private *greth = netdev_priv(dev);
+	return &greth->stats;
+}
+
+static int greth_set_mac_add(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct greth_private *greth;
+	struct greth_regs *regs;
+
+	greth = (struct greth_private *) netdev_priv(dev);
+	regs = (struct greth_regs *) greth->regs;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	GRETH_REGSAVE(regs->esa_msb, addr->sa_data[0] << 8 | addr->sa_data[1]);
+	GRETH_REGSAVE(regs->esa_lsb,
+		      addr->sa_data[2] << 24 | addr->
+		      sa_data[3] << 16 | addr->sa_data[4] << 8 | addr->sa_data[5]);
+	return 0;
+}
+
+static u32 greth_hash_get_index(__u8 *addr)
+{
+	return (ether_crc(6, addr)) & 0x3F;
+}
+
+static void greth_set_hash_filter(struct net_device *dev)
+{
+	struct dev_mc_list *curr;
+	struct greth_private *greth = (struct greth_private *) netdev_priv(dev);
+	struct greth_regs *regs = (struct greth_regs *) greth->regs;
+	u32 mc_filter[2];
+	unsigned int i, bitnr;
+
+	mc_filter[0] = mc_filter[1] = 0;
+
+	curr = dev->mc_list;
+
+	for (i = 0; i < dev->mc_count; i++, curr = curr->next) {
+
+		if (!curr)
+			break;	/* unexpected end of list */
+
+		bitnr = greth_hash_get_index(curr->dmi_addr);
+		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
+	}
+
+	GRETH_REGSAVE(regs->hash_msb, mc_filter[1]);
+	GRETH_REGSAVE(regs->hash_lsb, mc_filter[0]);
+}
+
+static void greth_set_multicast_list(struct net_device *dev)
+{
+	int cfg;
+	struct greth_private *greth = netdev_priv(dev);
+	struct greth_regs *regs = (struct greth_regs *) greth->regs;
+
+	cfg = GRETH_REGLOAD(regs->control);
+	if (dev->flags & IFF_PROMISC)
+		cfg |= GRETH_CTRL_PR;
+	else
+		cfg &= ~GRETH_CTRL_PR;
+
+	if (greth->multicast) {
+		if (dev->flags & IFF_ALLMULTI) {
+			GRETH_REGSAVE(regs->hash_msb, -1);
+			GRETH_REGSAVE(regs->hash_lsb, -1);
+			cfg |= GRETH_CTRL_MCEN;
+			GRETH_REGSAVE(regs->control, cfg);
+			return;
+		}
+
+		if (dev->mc_count == 0) {
+			cfg &= ~GRETH_CTRL_MCEN;
+			GRETH_REGSAVE(regs->control, cfg);
+			return;
+		}
+
+		/* Setup multicast filter */
+		greth_set_hash_filter(dev);
+		cfg |= GRETH_CTRL_MCEN;
+	}
+	GRETH_REGSAVE(regs->control, cfg);
+}
+
+static struct net_device_ops greth_netdev_ops = {
+	.ndo_open = greth_open,
+	.ndo_stop = greth_close,
+	.ndo_start_xmit = greth_start_xmit,
+	.ndo_set_mac_address = greth_set_mac_add,
+	.ndo_get_stats = greth_get_stats,
+};
+
+static struct net_device_ops greth_gbit_netdev_ops = {
+	.ndo_open = greth_open,
+	.ndo_stop = greth_close,
+	.ndo_start_xmit = greth_start_xmit_gbit,
+	.ndo_set_mac_address = greth_set_mac_add,
+	.ndo_get_stats = greth_get_stats,
+};
+
+
+static int greth_mdio_read(struct mii_bus *bus, int phy, int reg)
+{
+	struct greth_private *greth = bus->priv;
+	int data, err = 0;
+
+	wait_loop((GRETH_REGLOAD(greth->regs->mdio) & GRETH_MII_BUSY), 4, out, err = -EBUSY);
+
+	GRETH_REGSAVE(greth->regs->mdio, ((phy & 0x1F) << 11) | ((reg & 0x1F) << 6) | 2);
+
+	wait_loop((GRETH_REGLOAD(greth->regs->mdio) & GRETH_MII_BUSY), 4, out, err = -EBUSY);
+
+	if (!(GRETH_REGLOAD(greth->regs->mdio) & GRETH_MII_NVALID)) {
+		data = (GRETH_REGLOAD(greth->regs->mdio) >> 16) & 0xFFFF;
+		return data;
+
+	} else {
+		return -1;
+	}
+out:
+	return err;
+}
+
+
+static int greth_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
+{
+	struct greth_private *greth = bus->priv;
+	int err = 0;
+
+	wait_loop((GRETH_REGLOAD(greth->regs->mdio) & GRETH_MII_BUSY), 4, out, err = -EBUSY);
+
+	GRETH_REGSAVE(greth->regs->mdio,
+		      ((val & 0xFFFF) << 16) | ((phy & 0x1F) << 11) | ((reg & 0x1F) << 6) | 1);
+
+	wait_loop((GRETH_REGLOAD(greth->regs->mdio) & GRETH_MII_BUSY), 4, out, err = -EBUSY);
+
+	return 0;
+
+out:
+	return err;
+}
+
+static int greth_mdio_reset(struct mii_bus *bus)
+{
+	return 0;
+}
+
+static void greth_link_change(struct net_device *dev)
+{
+	struct greth_private *greth = netdev_priv(dev);
+	struct phy_device *phydev = greth->phy;
+	unsigned long flags;
+
+	int status_change = 0;
+
+	spin_lock_irqsave(&greth->devlock, flags);
+
+	if (phydev->link) {
+
+		if ((greth->speed != phydev->speed) || (greth->duplex != phydev->duplex)) {
+
+			GRETH_REGANDIN(greth->regs->control,
+				       ~(GRETH_CTRL_FD | GRETH_CTRL_SP | GRETH_CTRL_GB));
+
+			if (phydev->duplex)
+				GRETH_REGORIN(greth->regs->control, GRETH_CTRL_FD);
+
+			if (phydev->speed == SPEED_100) {
+
+				GRETH_REGORIN(greth->regs->control, GRETH_CTRL_SP);
+			}
+
+			else if (phydev->speed == SPEED_1000)
+				GRETH_REGORIN(greth->regs->control, GRETH_CTRL_GB);
+
+			greth->speed = phydev->speed;
+			greth->duplex = phydev->duplex;
+			status_change = 1;
+		}
+	}
+
+	if (phydev->link != greth->link) {
+		if (!phydev->link) {
+			greth->speed = 0;
+			greth->duplex = -1;
+		}
+		greth->link = phydev->link;
+
+		status_change = 1;
+	}
+
+	spin_unlock_irqrestore(&greth->devlock, flags);
+
+	if (status_change) {
+		if (phydev->link)
+			pr_debug("%s: link up (%d/%s)\n",
+				dev->name, phydev->speed,
+				DUPLEX_FULL == phydev->duplex ? "Full" : "Half");
+		else
+			pr_debug("%s: link down\n", dev->name);
+	}
+}
+
+static int greth_mdio_probe(struct net_device *dev)
+{
+	struct greth_private *greth = netdev_priv(dev);
+	struct phy_device *phy = NULL;
+	u32 interface;
+	int i;
+
+	/* Find the first PHY */
+	for (i = 0; i < PHY_MAX_ADDR; i++) {
+		if (greth->mdio->phy_map[i]) {
+			phy = greth->mdio->phy_map[i];
+			break;
+		}
+	}
+	if (!phy) {
+		dev_err(&dev->dev, "no PHY found\n");
+		return -ENXIO;
+	}
+
+	if (greth->gbit_mac)
+		interface = PHY_INTERFACE_MODE_GMII;
+	else
+		interface = PHY_INTERFACE_MODE_MII;
+
+	phy = phy_connect(dev, dev_name(&phy->dev), &greth_link_change, 0, interface);
+
+	if (greth->gbit_mac)
+		phy->supported &= PHY_GBIT_FEATURES;
+	else
+		phy->supported &= PHY_BASIC_FEATURES;
+
+	phy->advertising = phy->supported;
+
+	if (IS_ERR(phy)) {
+		dev_err(&dev->dev, "could not attach to PHY\n");
+		return PTR_ERR(phy);
+	}
+
+	greth->link = 0;
+	greth->speed = 0;
+	greth->duplex = -1;
+	greth->phy = phy;
+
+	return 0;
+}
+
+static inline int phy_aneg_done(struct phy_device *phydev)
+{
+	int retval;
+
+	retval = phy_read(phydev, MII_BMSR);
+
+	return (retval < 0) ? retval : (retval & BMSR_ANEGCOMPLETE);
+}
+
+static int greth_mdio_init(struct greth_private *greth)
+{
+	int ret, phy;
+	unsigned long timeout;
+
+	greth->mdio = mdiobus_alloc();
+	if (!greth->mdio) {
+		return -ENOMEM;
+	}
+
+	greth->mdio->name = "greth-mdio";
+	snprintf(greth->mdio->id, MII_BUS_ID_SIZE, "%s-%d", greth->mdio->name, greth->irq);
+	greth->mdio->read = greth_mdio_read;
+	greth->mdio->write = greth_mdio_write;
+	greth->mdio->reset = greth_mdio_reset;
+	greth->mdio->priv = greth;
+
+	greth->mdio->irq = greth->mdio_irqs;
+
+	for (phy = 0; phy < PHY_MAX_ADDR; phy++)
+		greth->mdio->irq[phy] = PHY_POLL;
+
+	ret = mdiobus_register(greth->mdio);
+	if (ret) {
+		goto error;
+	}
+
+	ret = greth_mdio_probe(greth->netdev);
+	if (ret) {
+		dev_err(&greth->netdev->dev, "failed to probe MDIO bus\n");
+		goto unreg_mdio;
+	}
+
+	phy_start(greth->phy);
+
+	/* If we have Ethernet debug link make autoneg happen right away */
+	if (greth->edcl) {
+		phy_start_aneg(greth->phy);
+		timeout = jiffies + 5*HZ;
+		while (!phy_aneg_done(greth->phy) && time_before(jiffies, timeout)) {
+		}
+		genphy_read_status(greth->phy);
+		greth_link_change(greth->netdev);
+	}
+
+	return 0;
+
+unreg_mdio:
+	mdiobus_unregister(greth->mdio);
+error:
+	mdiobus_free(greth->mdio);
+	return ret;
+}
+
+/* Initialize the GRETH MAC */
+static int __devinit greth_of_probe(struct of_device *ofdev, const struct of_device_id *match)
+{
+	struct net_device *dev;
+	struct net_device_ops *ops;
+	struct greth_private *greth;
+	struct greth_regs *regs;
+
+	int err;
+	int tmp;
+	unsigned long timeout;
+
+	unsigned int *irqs;
+	int irq;
+	struct amba_prom_registers *prom_regs;
+	unsigned int addr;
+
+	irqs = (int *) of_get_property(ofdev->node, "interrupts", NULL);
+	prom_regs = (struct amba_prom_registers *) of_get_property(ofdev->node, "reg", NULL);
+	if (!irqs || !prom_regs)
+		return -ENODEV;
+
+	addr = prom_regs->phys_addr;
+	irq = *irqs;
+
+	dev = alloc_etherdev(sizeof(struct greth_private));
+
+	if (dev == NULL)
+		return -ENOMEM;
+
+	greth = netdev_priv(dev);
+	greth->netdev = dev;
+	greth->dev = &ofdev->dev;
+
+	spin_lock_init(&greth->devlock);
+
+	if (!request_mem_region(addr, 0x100, "grlib-greth")) {
+		dev_err(greth->dev, "Couldn't lock memory region at %x\n", addr);
+		err = -EBUSY;
+		goto error1;
+	}
+
+	greth->regs = (struct greth_regs *) ioremap(addr, sizeof(struct greth_regs));
+
+	if (greth->regs == NULL) {
+		dev_err(greth->dev, "Ioremap failure.\n");
+		err = -EIO;
+		goto error2;
+	}
+
+	regs = (struct greth_regs *) greth->regs;
+	greth->irq = irq;
+
+	dev_set_drvdata(greth->dev, dev);
+	SET_NETDEV_DEV(dev, greth->dev);
+
+	/* Reset the controller. */
+	GRETH_REGSAVE(regs->control, GRETH_RESET);
+
+	/* Wait max 3 s for MAC to reset itself */
+	timeout = jiffies + HZ*3;
+	while (GRETH_REGLOAD(regs->control) & GRETH_RESET) {
+		if (time_after(jiffies, timeout)) {
+			err = -EIO;
+			dev_err(greth->dev, "timeout when waiting for reset.\n");
+			goto error3;
+		}
+	}
+
+	/* Get default PHY address  */
+	greth->phyaddr = (GRETH_REGLOAD(regs->mdio) >> 11) & 0x1F;
+
+	/* Check if we have GBIT capable MAC */
+	tmp = GRETH_REGLOAD(regs->control);
+	greth->gbit_mac = (tmp >> 27) & 1;
+
+	/* Check for multicast capability */
+	greth->multicast = (tmp >> 25) & 1;
+
+	greth->edcl = (tmp >> 31) & 1;
+
+	/* If we have EDCL we disable the EDCL speed-duplex FSM so
+	 * it doesn't interfere with the software */
+	if (greth->edcl != 0)
+		GRETH_REGORIN(regs->control, GRETH_CTRL_DISDUPLEX);
+
+	/* Check if MAC can handle MDIO interrupts */
+	greth->mdio_int_en = (tmp >> 26) & 1;
+
+	err = greth_mdio_init(greth);
+	if (err) {
+		dev_err(greth->dev, "failed to register MDIO bus\n");
+		goto error3;
+	}
+
+	/* Allocate TX descriptor ring in coherent memory */
+	greth->tx_bd_base = (struct greth_bd *) dma_alloc_coherent(greth->dev,
+								   1024,
+								   &greth->tx_bd_base_phys,
+								   GFP_KERNEL);
+
+	if (!greth->tx_bd_base) {
+		dev_err(&dev->dev, "could not allocate descriptor memory.\n");
+		err = -ENOMEM;
+		goto error4;
+	}
+
+	memset(greth->tx_bd_base, 0, 1024);
+
+	/* Allocate RX descriptor ring in coherent memory */
+	greth->rx_bd_base = (struct greth_bd *) dma_alloc_coherent(greth->dev,
+								   1024,
+								   &greth->rx_bd_base_phys,
+								   GFP_KERNEL);
+
+	if (!greth->rx_bd_base) {
+		dev_err(greth->dev, "could not allocate descriptor memory.\n");
+		err = -ENOMEM;
+		goto error5;
+	}
+
+	memset(greth->rx_bd_base, 0, 1024);
+
+	/* Set MAC address */
+	dev->dev_addr[0] = MACADDR0;
+	dev->dev_addr[1] = MACADDR1;
+	dev->dev_addr[2] = MACADDR2;
+	dev->dev_addr[3] = MACADDR3;
+	dev->dev_addr[4] = MACADDR4;
+	dev->dev_addr[5] = MACADDR5;
+
+	if (!is_valid_ether_addr(&dev->dev_addr[0])) {
+		dev_err(greth->dev, "no valid ethernet address, aborting.\n");
+		err = -EINVAL;
+		goto error6;
+	}
+
+	GRETH_REGSAVE(regs->esa_msb, MACADDR0 << 8 | MACADDR1);
+	GRETH_REGSAVE(regs->esa_lsb, MACADDR2 << 24 | MACADDR3 << 16 | MACADDR4 << 8 | MACADDR5);
+
+	/* Clear all pending interrupts except PHY irq */
+	GRETH_REGSAVE(regs->status, 0xFF);
+
+	dev->base_addr = (unsigned long) addr;
+
+	if (greth->gbit_mac) {
+		dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_HIGHDMA;
+		ops = &greth_gbit_netdev_ops;
+	} else {
+		ops = &greth_netdev_ops;
+	}
+
+	if (greth->multicast) {
+		ops->ndo_set_multicast_list = greth_set_multicast_list;
+		dev->flags |= IFF_MULTICAST;
+	} else {
+		dev->flags &= ~IFF_MULTICAST;
+	}
+
+	dev->netdev_ops = ops;
+
+	if (register_netdev(dev)) {
+		dev_err(greth->dev, "netdevice registration failed.\n");
+		err = -ENOMEM;
+		goto error6;
+	}
+
+	/* setup NAPI */
+	memset(&greth->napi, 0, sizeof(greth->napi));
+	netif_napi_add(dev, &greth->napi, greth_poll, 64);
+
+	return 0;
+
+error6:
+	dma_free_coherent(greth->dev, 1024, greth->rx_bd_base, greth->rx_bd_base_phys);
+error5:
+	dma_free_coherent(greth->dev, 1024, greth->tx_bd_base, greth->tx_bd_base_phys);
+error4:
+	mdiobus_unregister(greth->mdio);
+error3:
+	iounmap(greth->regs);
+error2:
+	release_mem_region(addr, 0x100);
+error1:
+	free_netdev(dev);
+	return err;
+}
+
+static int __devexit greth_of_remove(struct of_device *of_dev)
+{
+	struct net_device *ndev = dev_get_drvdata(&of_dev->dev);
+	struct greth_private *greth = netdev_priv(ndev);
+
+	/* Free descriptor areas */
+	dma_free_coherent(&of_dev->dev, 1024, greth->rx_bd_base, greth->rx_bd_base_phys);
+
+	dma_free_coherent(&of_dev->dev, 1024, greth->tx_bd_base, greth->tx_bd_base_phys);
+
+	release_mem_region(ndev->base_addr, 0x100);
+	dev_set_drvdata(&of_dev->dev, NULL);
+
+	if (greth->phy)
+		phy_stop(greth->phy);
+	mdiobus_unregister(greth->mdio);
+
+	unregister_netdev(ndev);
+	free_netdev(ndev);
+
+	iounmap(greth->regs);
+
+	return 0;
+}
+
+static struct of_device_id greth_of_match[] = {
+	{
+	 .name = "GAISLER_ETHMAC",
+	 },
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, greth_of_match);
+
+static struct of_platform_driver greth_of_driver = {
+	.name = "grlib-greth",
+	.match_table = greth_of_match,
+	.probe = greth_of_probe,
+	.remove = __devexit_p(greth_of_remove),
+	.driver = {
+		   .owner = THIS_MODULE,
+		   .name = "grlib-greth",
+		   },
+};
+
+static int __init greth_init(void)
+{
+	return of_register_platform_driver(&greth_of_driver);
+}
+
+static void __exit greth_cleanup(void)
+{
+	of_unregister_platform_driver(&greth_of_driver);
+}
+
+module_init(greth_init);
+module_exit(greth_cleanup);
+
+MODULE_AUTHOR("Aeroflex Gaisler AB.");
+MODULE_DESCRIPTION("Aeroflex Gaisler Ethernet MAC driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/greth.h b/drivers/net/greth.h
new file mode 100644
index 0000000..f1cc72e
--- /dev/null
+++ b/drivers/net/greth.h
@@ -0,0 +1,154 @@
+#ifndef GRETH_H
+#define GRETH_H
+
+#include <linux/phy.h>
+
+/* Register bits and masks */
+#define GRETH_RESET 0x40
+#define GRETH_MII_BUSY 0x8
+#define GRETH_MII_NVALID 0x10
+
+#define GRETH_CTRL_FD         0x10
+#define GRETH_CTRL_PR         0x20
+#define GRETH_CTRL_SP         0x80
+#define GRETH_CTRL_GB         0x100
+#define GRETH_CTRL_PSTATIEN   0x400
+#define GRETH_CTRL_MCEN       0x800
+#define GRETH_CTRL_DISDUPLEX  0x1000
+#define GRETH_STATUS_PHYSTAT  0x100
+
+#define GRETH_BD_EN 0x800
+#define GRETH_BD_WR 0x1000
+#define GRETH_BD_IE 0x2000
+#define GRETH_BD_LEN 0x7FF
+
+#define GRETH_TXEN 0x1
+#define GRETH_INT_TX 0x8
+#define GRETH_TXI 0x4
+#define GRETH_TXBD_STATUS 0x0001C000
+#define GRETH_TXBD_MORE 0x20000
+#define GRETH_TXBD_IPCS 0x40000
+#define GRETH_TXBD_TCPCS 0x80000
+#define GRETH_TXBD_UDPCS 0x100000
+#define GRETH_TXBD_CSALL (GRETH_TXBD_IPCS | GRETH_TXBD_TCPCS | GRETH_TXBD_UDPCS)
+#define GRETH_TXBD_ERR_LC 0x10000
+#define GRETH_TXBD_ERR_UE 0x4000
+#define GRETH_TXBD_ERR_AL 0x8000
+
+#define GRETH_INT_RX         0x4
+#define GRETH_RXEN           0x2
+#define GRETH_RXI            0x8
+#define GRETH_RXBD_STATUS    0xFFFFC000
+#define GRETH_RXBD_ERR_AE    0x4000
+#define GRETH_RXBD_ERR_FT    0x8000
+#define GRETH_RXBD_ERR_CRC   0x10000
+#define GRETH_RXBD_ERR_OE    0x20000
+#define GRETH_RXBD_ERR_LE    0x40000
+#define GRETH_RXBD_IP        0x80000
+#define GRETH_RXBD_IP_CSERR  0x100000
+#define GRETH_RXBD_UDP       0x200000
+#define GRETH_RXBD_UDP_CSERR 0x400000
+#define GRETH_RXBD_TCP       0x800000
+#define GRETH_RXBD_TCP_CSERR 0x1000000
+#define GRETH_RXBD_IP_FRAG   0x2000000
+#define GRETH_RXBD_MCAST     0x4000000
+
+/* MAC address */
+#define MACADDR0 ((CONFIG_GRETH_MACMSB >> 16) & 0xff)
+#define MACADDR1 ((CONFIG_GRETH_MACMSB >> 8) & 0xff)
+#define MACADDR2 ((CONFIG_GRETH_MACMSB >> 0) & 0xff)
+#define MACADDR3 ((CONFIG_GRETH_MACLSB >> 16) & 0xff)
+#define MACADDR4 ((CONFIG_GRETH_MACLSB >> 8) & 0xff)
+#define MACADDR5 ((CONFIG_GRETH_MACLSB >> 0) & 0xff)
+
+/* Descriptor parameters */
+#define GRETH_TXBD_NUM 128
+#define GRETH_TXBD_NUM_MASK (GRETH_TXBD_NUM-1)
+#define GRETH_TX_BUF_SIZE 2048
+#define GRETH_RXBD_NUM 128
+#define GRETH_RXBD_NUM_MASK (GRETH_RXBD_NUM-1)
+#define GRETH_RX_BUF_SIZE 2048
+
+/* Buffers per page */
+#define GRETH_RX_BUF_PPGAE	(PAGE_SIZE/GRETH_RX_BUF_SIZE)
+#define GRETH_TX_BUF_PPGAE	(PAGE_SIZE/GRETH_TX_BUF_SIZE)
+
+/* How many pages are needed for buffers */
+#define GRETH_RX_BUF_PAGE_NUM	(GRETH_RXBD_NUM/GRETH_RX_BUF_PPGAE)
+#define GRETH_TX_BUF_PAGE_NUM	(GRETH_TXBD_NUM/GRETH_TX_BUF_PPGAE)
+
+/* Buffer size.
+ * Gbit MAC uses tagged maximum frame size which is 1518 excluding CRC.
+ * Set to 1520 to make all buffers word aligned for non-gbit MAC.
+ */
+#define MAX_FRAME_SIZE		1520
+
+
+/* GRETH APB registers */
+struct greth_regs {
+	u32 control;
+	u32 status;
+	u32 esa_msb;
+	u32 esa_lsb;
+	u32 mdio;
+	u32 tx_desc_p;
+	u32 rx_desc_p;
+	u32 edclip;
+	u32 hash_msb;
+	u32 hash_lsb;
+};
+
+/* GRETH buffer descriptor */
+struct greth_bd {
+	u32 stat;
+	u32 addr;
+};
+
+struct greth_private {
+	struct sk_buff *rx_skbuff[GRETH_RXBD_NUM];
+	struct sk_buff *tx_skbuff[GRETH_TXBD_NUM];
+	unsigned char *tx_bufs;
+	unsigned char *rx_bufs;
+
+	u16 tx_next;
+	u16 tx_last;
+	u16 tx_free;
+	u16 rx_cur;
+
+	u8 phyaddr;
+	u8 multicast;
+	u8 gbit_mac;
+	u8 mdio_int_en;
+	u8 edcl;
+
+	struct greth_regs *regs;	/* Address of controller registers. */
+	struct greth_bd *rx_bd_base;	/* Address of Rx BDs. */
+	struct greth_bd *tx_bd_base;	/* Address of Tx BDs. */
+	dma_addr_t rx_bd_base_phys;
+	dma_addr_t tx_bd_base_phys;
+
+	int irq;
+
+	struct device *dev;	        /* Pointer to of_device->dev */
+	struct net_device *netdev;
+	struct napi_struct napi;
+	struct net_device_stats stats;
+	spinlock_t devlock;
+
+	struct work_struct greth_wq;
+
+	struct phy_device *phy;
+	struct mii_bus *mdio;
+	int mdio_irqs[PHY_MAX_ADDR];
+	unsigned int link;
+	unsigned int speed;
+	unsigned int duplex;
+};
+
+
+struct amba_prom_registers {
+	unsigned int phys_addr;
+	unsigned int reg_size;
+};
+
+#endif
-- 
1.6.4.1


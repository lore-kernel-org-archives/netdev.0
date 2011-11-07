From: Taehun Kim <kth3321@gmail.com>
Subject: [PATCH net-next] W5300: Add WIZnet W5300 Ethernet driver
Date: Mon,  7 Nov 2011 23:37:41 +0900
Message-ID: <1320676661-19138-1-git-send-email-kth3321@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	suhwan@wiznet.co.kr, bongbong@wiznet.co.kr
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:64145 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754394Ab1KGOhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 09:37:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have modified W5300 driver by applying the David Miller's feedback
(http://www.spinics.net/lists/netdev/msg177862.html).

Please review this driver and apply it if do not have any problems.

Thank you,

T.K.

Signed-off-by: Taehun Kim <kth3321@gmail.com>
---
 drivers/net/ethernet/Kconfig         |    1 +
 drivers/net/ethernet/Makefile        |    1 +
 drivers/net/ethernet/wiznet/Kconfig  |   32 ++
 drivers/net/ethernet/wiznet/Makefile |    5 +
 drivers/net/ethernet/wiznet/w5300.c  |  697 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/wiznet/w5300.h  |  121 ++++++
 6 files changed, 857 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/wiznet/Kconfig
 create mode 100644 drivers/net/ethernet/wiznet/Makefile
 create mode 100644 drivers/net/ethernet/wiznet/w5300.c
 create mode 100644 drivers/net/ethernet/wiznet/w5300.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 6dff5a0..6325d85 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -173,5 +173,6 @@ source "drivers/net/ethernet/tundra/Kconfig"
 source "drivers/net/ethernet/via/Kconfig"
 source "drivers/net/ethernet/xilinx/Kconfig"
 source "drivers/net/ethernet/xircom/Kconfig"
+source "drivers/net/ethernet/wiznet/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c53ad3a..7bd5211 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -72,3 +72,4 @@ obj-$(CONFIG_NET_VENDOR_TUNDRA) += tundra/
 obj-$(CONFIG_NET_VENDOR_VIA) += via/
 obj-$(CONFIG_NET_VENDOR_XILINX) += xilinx/
 obj-$(CONFIG_NET_VENDOR_XIRCOM) += xircom/
+obj-$(CONFIG_NET_VENDOR_WIZNET) += wiznet/
diff --git a/drivers/net/ethernet/wiznet/Kconfig b/drivers/net/ethernet/wiznet/Kconfig
new file mode 100644
index 0000000..b5925bd
--- /dev/null
+++ b/drivers/net/ethernet/wiznet/Kconfig
@@ -0,0 +1,32 @@
+#
+# WIZnet device configuration
+#
+
+config NET_VENDOR_WIZNET
+	bool "WIZnet devices"
+	default y
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about WIZnet devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_WIZNET
+
+config W5300
+	tristate "WIZnet W5300 Ethernet support"
+	depends on ARM
+	---help---
+	  This driver supports the Ethernet in the WIZnet W5300 chips.
+	  W5300 supports hardwired TCP/IP stack. But this driver is limited to
+	  the Ethernet function. To use hardwired TCP/IP stack, need to modify
+	  the TCP/IP stack in linux kerenl.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called w5300.
+
+endif # NET_VENDOR_WIZNET
diff --git a/drivers/net/ethernet/wiznet/Makefile b/drivers/net/ethernet/wiznet/Makefile
new file mode 100644
index 0000000..53120bc
--- /dev/null
+++ b/drivers/net/ethernet/wiznet/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the WIZnet device drivers.
+#
+
+obj-$(CONFIG_W5300) += w5300.o
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
new file mode 100644
index 0000000..6fe3b57
--- /dev/null
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -0,0 +1,697 @@
+/* w5300.c: A Linux Ethernet driver for the WIZnet W5300 chip. */
+/*
+  Copyright (C) 2011 Taehun Kim <kth3321@gmail.com>
+
+  This software may be used and distributed according to the terms of
+  the GNU General Public License (GPL), incorporated herein by reference.
+  Drivers based on or derived from this code fall under the GPL and must
+  retain the authorship, copyright and license notice.  This file is not
+  a complete program and may only be used when the entire operating
+  system is licensed under the GPL.
+*/
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/errno.h>
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+
+#include <linux/device.h>
+#include <linux/platform_device.h>
+#include <linux/ioport.h>
+#include <linux/io.h>
+
+#include "w5300.h"
+
+#define DEV_NAME    "W5300"
+#define DRV_VERSION "1.0"
+#define DRV_RELDATE "Nov 7, 2011"
+
+#define W5300_DEF_MSG_ENABLE	  \
+	(NETIF_MSG_DRV		| \
+	 NETIF_MSG_TIMER	| \
+	 NETIF_MSG_IFUP		| \
+	 NETIF_MSG_RX_ERR	| \
+	 NETIF_MSG_INTR		| \
+	 NETIF_MSG_TX_DONE)
+
+static const char version[] =
+	DEV_NAME ": Ethernet driver v" DRV_VERSION "(" DRV_RELDATE ")\n";
+
+MODULE_AUTHOR("Taehun Kim <kth3321@gmail.com>");
+MODULE_DESCRIPTION("WIZnet W5300 Ethernet driver");
+MODULE_VERSION(DRV_VERSION);
+MODULE_LICENSE("GPL");
+
+/* Transmit timeout, default 5 seconds. */
+static int watchdog = 5000;
+module_param(watchdog, int, 0400);
+MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
+
+static int debug = -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "W5300: bitmapped message enable number");
+
+/*
+ * This is W5300 information structure.
+ * Additional information is included in struct net_device.
+ */
+struct wiz_private {
+	void __iomem *base;
+	struct net_device *dev;
+	u8 rxbuf_conf[MAX_SOCK_NUM];
+	u8 txbuf_conf[MAX_SOCK_NUM];
+	struct napi_struct napi;
+	spinlock_t lock;
+	u32 msg_enable;
+};
+
+/* Default MAC address. */
+static __initdata u8 w5300_defmac[6] = {0x00, 0x08, 0xDC, 0xA0, 0x00, 0x01};
+
+/* Default RX/TX buffer size(KByte). */
+static u8 w5300_rxbuf_conf[MAX_SOCK_NUM] __initdata = {
+	64, 0, 0, 0, 0, 0, 0, 0
+};
+
+static u8 w5300_txbuf_conf[MAX_SOCK_NUM] __initdata = {
+	64, 0, 0, 0, 0, 0, 0, 0
+};
+
+/* Notifying packet size in the RX FIFO */
+static int w5300_get_rxsize(struct wiz_private *wp, int s)
+{
+	u32 val;
+
+	val = w5300_read(wp, Sn_RX_RSR(s));
+	val = (val << 16) + w5300_read(wp, Sn_RX_RSR(s) + 2);
+	return val;
+}
+
+/* Packet Receive Function. It reads received packet from the Rx FIFO. */
+static void w5300_recv_data(struct wiz_private *wp, int s, u8 *buf,
+			    ssize_t len)
+{
+	int i;
+	u16 recv_data;
+
+	/* read from RX FIFO */
+	for (i = 0; i < len; i += 2) {
+		recv_data = w5300_read(wp, Sn_RX_FIFO(s));
+		buf[i] = (u8) ((recv_data & 0xFF00) >> 8);
+		buf[i + 1] = (u8) (recv_data & 0x00FF);
+	}
+}
+
+/* Setting MAC address of W5300 */
+static void w5300_set_macaddr(struct wiz_private *wp, u8 * addr)
+{
+	int i;
+
+	for (i = 0; i < 3; ++i) {
+		u16 mac_addr = (addr[2*i] << 8) | addr[2*i+1];
+
+		w5300_write(wp, SHAR + 2*i, mac_addr);
+	}
+}
+
+/* Opening channels of W5300 */
+static int w5300_channel_open(struct wiz_private *wp, u32 type)
+{
+	int timeout = 1000;
+
+	/* Which type will be used for open? */
+	switch (type) {
+	case Sn_MR_MACRAW:
+	case Sn_MR_MACRAW_MF:
+		w5300_write(wp, Sn_MR(0), type);
+		break;
+	default:
+		netif_err(wp, ifup, wp->dev,
+				"Unknown socket type (%d)\n", type);
+
+		return -EFAULT;
+	}
+
+	w5300_write(wp, Sn_CR(0), Sn_CR_OPEN);
+
+	while (timeout--) {
+		if (!w5300_read(wp, Sn_CR(0)))
+			return 0;
+		udelay(1);
+	}
+
+	return -EBUSY;
+}
+
+/* Activating the interrupt of related channel */
+static void w5300_interrupt_enable(struct wiz_private *wp)
+{
+	u16 mask;
+
+	mask = w5300_read(wp, IMR) | 0x1;
+	w5300_write(wp, IMR, mask);
+}
+
+/* De-activating the interrupt of related channel */
+static void w5300_interrupt_disable(struct wiz_private *wp)
+{
+	u16 mask;
+
+	mask = w5300_read(wp, IMR) & ~0x1;
+	w5300_write(wp, IMR, mask);
+}
+
+/* W5300 initialization function */
+static int w5300_reset(struct net_device *dev)
+{
+	struct wiz_private *wp = netdev_priv(dev);
+	u32 txbuf_total = 0, i;
+	u16 mem_cfg = 0;
+	u16 rx_size, tx_size;
+
+	netif_dbg(wp, drv, wp->dev, "w5300 chip reset\n");
+
+	/* W5300 is initialized by sending RESET command. */
+	w5300_write(wp, MR, MR_RST);
+	mdelay(5);
+
+	/* Mode Register Setting
+	 * Ping uses S/W stack of the Linux kernel. Set the Ping Block.*/
+	w5300_write(wp, MR, MR_WDF(1) | MR_PB);
+
+	/* Setting MAC address */
+	w5300_set_macaddr(wp, dev->dev_addr);
+
+	/* Setting the size of Rx/Tx FIFO */
+	for (i = 0; i < MAX_SOCK_NUM; ++i) {
+		if (wp->rxbuf_conf[i] > 64) {
+			netif_err(wp, drv, wp->dev,
+			"Illegal Channel(%d) RX memory size.\n", i);
+
+			return -EINVAL;
+		}
+		if (wp->txbuf_conf[i] > 64) {
+			netif_err(wp, drv, wp->dev,
+			"Illegal Channel(%d) TX memory size.\n", i);
+
+			return -EINVAL;
+		}
+		txbuf_total += wp->txbuf_conf[i];
+	}
+
+	if (txbuf_total % 8) {
+		netif_err(wp, drv, wp->dev,
+			      "Illegal memory size register setting.\n");
+
+		return -EINVAL;
+	}
+
+	for (i = 0; i < 4; ++i) {
+		rx_size = (wp->rxbuf_conf[2*i] << 8) | wp->rxbuf_conf[2*i+1];
+		tx_size = (wp->txbuf_conf[2*i] << 8) | wp->txbuf_conf[2*i+1];
+
+		w5300_write(wp, RMSR + 2*i, rx_size);
+		w5300_write(wp, TMSR + 2*i, tx_size);
+	}
+
+	/* Setting FIFO Memory Type (TX&RX) */
+	for (i = 0; i < txbuf_total / 8; ++i) {
+		mem_cfg <<= 1;
+		mem_cfg |= 1;
+	}
+	w5300_write(wp, MTYPER, mem_cfg);
+
+	/* Masking all interrupts */
+	w5300_write(wp, IMR, 0x0000);
+
+	return 0;
+}
+
+/* Interrupt Handler(ISR) */
+static irqreturn_t wiz_interrupt(int irq, void *dev_instance)
+{
+	struct net_device *dev = dev_instance;
+	struct wiz_private *wp = netdev_priv(dev);
+	int timeout = 100;
+	u16 isr, ssr;
+	int s;
+
+	isr = w5300_read(wp, IR);
+
+	/* Completing all interrupts at a time. */
+	while (isr && timeout--) {
+		w5300_write(wp, IR, isr);
+
+		/* Finding the channel to create the interrupt */
+		s = find_first_bit((ulong *)&isr, sizeof(u16));
+		ssr = w5300_read(wp, Sn_IR(s));
+		/* socket interrupt is cleared. */
+		w5300_write(wp, Sn_IR(s), ssr);
+
+		netif_dbg(wp, intr, wp->dev,
+			"ISR = %X, SSR = %X, s = %X\n",
+			isr, ssr, s);
+
+		if (likely(!s)) {
+			if (ssr & Sn_IR_RECV) {
+				/* Interrupt disable. */
+				w5300_interrupt_disable(wp);
+				/* Receiving by polling method */
+				napi_schedule(&wp->napi);
+			}
+		}
+
+		/* Is there any interrupt to be processed? */
+		isr = w5300_read(wp, IR);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static int wiz_open(struct net_device *dev)
+{
+	struct wiz_private *wp = netdev_priv(dev);
+	int ret;
+
+	napi_enable(&wp->napi);
+
+	ret = request_irq(dev->irq, wiz_interrupt, IRQF_SHARED,
+			dev->name, dev);
+	if (ret < 0) {
+		netif_err(wp, ifup, wp->dev, "request_irq() error!\n");
+		return ret;
+	}
+
+	w5300_interrupt_enable(wp);
+
+	/* Sending OPEN command to use channel 0 as MACRAW mode. */
+	ret = w5300_channel_open(wp, Sn_MR_MACRAW_MF);
+	if (ret < 0) {
+		netif_err(wp, ifup, wp->dev, "w5300 channel open fail!\n");
+		return ret;
+	}
+
+	netif_carrier_on(dev);
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+static int wiz_close(struct net_device *dev)
+{
+	struct wiz_private *wp = netdev_priv(dev);
+	int timeout = 1000;
+
+	napi_disable(&wp->napi);
+	netif_carrier_off(dev);
+
+	/* Interrupt masking of all channels */
+	w5300_write(wp, IMR, 0x0000);
+	w5300_write(wp, Sn_CR(0), Sn_CR_CLOSE);
+
+	while (timeout--) {
+		if (!w5300_read(wp, Sn_CR(0)))
+			break;
+		udelay(1);
+	}
+
+	free_irq(dev->irq, dev);
+
+	return 0;
+}
+
+static int w5300_send_data(struct wiz_private *wp, u8 *buf, ssize_t len)
+{
+	int i;
+	u16 send_data;
+	int timeout = 1000;
+
+	/* Writing packets in to Tx FIFO */
+	for (i = 0; i < len; i += 2) {
+		send_data = (buf[i] << 8) | buf[i+1];
+		w5300_write(wp, Sn_TX_FIFO(0), send_data);
+	}
+
+	w5300_write(wp, Sn_TX_WRSR(0), (u16)(len >> 16));
+	w5300_write(wp, Sn_TX_WRSR(0) + 2, (u16)len);
+	w5300_write(wp, Sn_CR(0), Sn_CR_SEND);
+
+	while (timeout--) {
+		if (!w5300_read(wp, Sn_CR(0)))
+			return len;
+		udelay(1);
+	}
+
+	return -EBUSY;
+}
+
+/* Function to transmit data at the MACRAW mode */
+static int wiz_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct wiz_private *wp = netdev_priv(dev);
+	int ret;
+
+	ret = w5300_send_data(wp, skb->data, skb->len);
+
+	/* Statistical Process */
+	if (ret < 0) {
+		dev->stats.tx_dropped++;
+	} else {
+		dev->stats.tx_bytes += skb->len;
+		dev->stats.tx_packets++;
+		dev->trans_start = jiffies;
+		netif_dbg(wp, tx_done, wp->dev,
+			"tx done, packet size = %d\n", skb->len);
+	}
+	dev_kfree_skb(skb);
+
+	return NETDEV_TX_OK;
+}
+
+/* It is called when multi-cast list or flag is changed. */
+static void wiz_set_multicast(struct net_device *dev)
+{
+	struct wiz_private *wp = netdev_priv(dev);
+	int ret;
+	u32 type = dev->flags & IFF_PROMISC ? Sn_MR_MACRAW : Sn_MR_MACRAW_MF;
+
+	ret = w5300_channel_open(wp, type);
+	if (ret < 0) {
+		netif_err(wp, ifup, wp->dev,
+			"w5300 channel open fail!\n");
+	}
+}
+
+static int wiz_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct wiz_private *wp = netdev_priv(dev);
+	struct sockaddr *sock_addr = addr;
+
+	netif_dbg(wp, drv, wp->dev, "set mac address");
+
+	spin_lock(&wp->lock);
+	w5300_set_macaddr(wp, sock_addr->sa_data);
+	memcpy(dev->dev_addr, sock_addr->sa_data, dev->addr_len);
+	spin_unlock(&wp->lock);
+
+	return 0;
+}
+
+static void wiz_tx_timeout(struct net_device *dev)
+{
+	struct wiz_private *wp = netdev_priv(dev);
+	unsigned long flags;
+
+	netif_dbg(wp, timer, wp->dev, "Transmit timeout");
+
+	spin_lock_irqsave(&wp->lock, flags);
+
+	/* Initializing W5300 chip. */
+	if (w5300_reset(dev) < 0) {
+		netif_err(wp, timer, wp->dev, "w5300 reset fail!\n");
+		return;
+	}
+
+	/* Waking up network interface */
+	netif_wake_queue(dev);
+	spin_unlock_irqrestore(&wp->lock, flags);
+}
+
+/*
+ * Polling Function to process only receiving at the MACRAW mode.
+ * De-activating the interrupt when recv interrupt occurs,
+ * and processing the RECEIVE with this Function
+ * Activating the interrupt after completing RECEIVE process
+ * As recv interrupt often occurs at short intervals,
+ * there will system load in case that interrupt handler process the RECEIVE.
+ */
+static int wiz_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct wiz_private *wp = container_of(napi, struct wiz_private, napi);
+	struct net_device *dev = wp->dev;
+	int npackets = 0;
+
+	/* Processing the RECEIVE during Rx FIFO is containing any packet */
+	while (w5300_get_rxsize(wp, 0) > 0) {
+		struct sk_buff *skb;
+		u16 rxbuf_len, pktlen;
+		u32 crc;
+
+		/* The first 2byte is the information about packet lenth. */
+		w5300_recv_data(wp, 0, (u8 *)&pktlen, 2);
+		pktlen = be16_to_cpu(pktlen);
+
+		netif_dbg(wp, rx_err, wp->dev, "pktlen = %d\n", pktlen);
+
+		/*
+		 * Allotting the socket buffer in which packet will be contained
+		 * Ethernet packet is of 14byte.
+		 * In order to make it multiplied by 2, the buffer allocation
+		 * should be 2bytes bigger than the packet.
+		 */
+		skb = netdev_alloc_skb_ip_align(dev, pktlen);
+		if (!skb) {
+			u8 temp[pktlen + 4];
+
+			dev->stats.rx_dropped++;
+			w5300_recv_data(wp, 0, temp, pktlen + 4);
+			continue;
+		}
+
+		/* Initializing the socket buffer */
+		skb->dev = dev;
+		skb_reserve(skb, 2);
+		skb_put(skb, pktlen);
+
+		/* Reading packets from W5300 Rx FIFO into socket buffer. */
+		w5300_recv_data(wp, 0, (u8 *)skb->data, pktlen);
+
+		/* Reading and discarding 4byte CRC. */
+		w5300_recv_data(wp, 0, (u8 *)&crc, 4);
+		crc = be32_to_cpu(crc);
+
+		/* The packet type is Ethernet. */
+		skb->protocol = eth_type_trans(skb, dev);
+
+		/* Passing packets to uppder stack (kernel). */
+		netif_receive_skb(skb);
+
+		/* Processing statistical information */
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += pktlen;
+		dev->last_rx = jiffies;
+		rxbuf_len -= pktlen;
+		npackets++;
+
+		if (npackets >= budget)
+			break;
+	}
+
+	/* If packet number is smaller than budget when getting out of loopback,
+	 * the RECEIVE process is completed. */
+	if (npackets < budget) {
+		unsigned long flags;
+
+		spin_lock_irqsave(&wp->lock, flags);
+		w5300_interrupt_enable(wp);
+		__napi_complete(napi);
+		spin_unlock_irqrestore(&wp->lock, flags);
+	}
+	return npackets;
+}
+
+static const struct net_device_ops wiz_netdev_ops = {
+	.ndo_open		= wiz_open,
+	.ndo_stop		= wiz_close,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= wiz_set_mac_address,
+	.ndo_set_rx_mode	= wiz_set_multicast,
+	.ndo_start_xmit		= wiz_start_xmit,
+	.ndo_tx_timeout		= wiz_tx_timeout,
+};
+
+/* Initialize W5300 driver. */
+static int __devinit w5300_drv_probe(struct platform_device *pdev)
+{
+	struct net_device *dev;
+	struct wiz_private *wp;
+	struct resource *res;
+	void __iomem *addr;
+	int ret;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		ret  = -ENODEV;
+		goto out;
+	}
+
+	/* Request the chip register regions. */
+	if (!request_mem_region(res->start, resource_size(res), DEV_NAME)) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	/* Allocatting struct net_device structure which is managing W5300 */
+	dev = alloc_etherdev(sizeof(struct wiz_private));
+	if (!dev) {
+		ret = -ENOMEM;
+		goto release_region;
+	}
+
+	dev->dma = (unsigned char)-1;
+	dev->irq = platform_get_irq(pdev, 0);
+	wp = netdev_priv(dev);
+	wp->dev = dev;
+	wp->msg_enable = (debug < 0 ? W5300_DEF_MSG_ENABLE : debug);
+	addr = ioremap(res->start, SZ_1M);
+	if (!addr) {
+		ret = -ENOMEM;
+		goto release_both;
+	}
+
+	platform_set_drvdata(pdev, dev);
+	wp->base = addr;
+
+	spin_lock_init(&wp->lock);
+
+	/* Initialization of Rx/Tx FIFO size */
+	memcpy(wp->rxbuf_conf, w5300_rxbuf_conf, MAX_SOCK_NUM);
+	memcpy(wp->txbuf_conf, w5300_txbuf_conf, MAX_SOCK_NUM);
+
+	dev->base_addr = res->start;
+
+	memcpy(dev->dev_addr, w5300_defmac, dev->addr_len);
+	dev->netdev_ops = &wiz_netdev_ops;
+
+	/* Setting napi. Enabling to process max 16 packets at a time. */
+	netif_napi_add(dev, &wp->napi, wiz_rx_poll, 16);
+
+	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
+
+	ret = w5300_reset(dev);
+	if (ret < 0)
+		goto release_both;
+
+	ret = register_netdev(dev);
+	if (ret != 0) {
+		platform_set_drvdata(pdev, NULL);
+		iounmap(addr);
+release_both:
+		free_netdev(dev);
+release_region:
+		release_mem_region(res->start, resource_size(res));
+	}
+out:
+	return ret;
+}
+
+static int __devexit w5300_drv_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct wiz_private *wp = netdev_priv(dev);
+	struct resource *res;
+
+	platform_set_drvdata(pdev, NULL);
+	unregister_netdev(dev);
+
+	iounmap(wp->base);
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (res != NULL)
+		release_mem_region(res->start, resource_size(res));
+
+	free_netdev(dev);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+
+static int w5300_drv_suspend(struct platform_device *pdev, pm_message_t state)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	if (dev) {
+		struct wiz_private *wp = netdev_priv(dev);
+
+		if (netif_running(dev)) {
+			int timeout = 1000;
+
+			netif_carrier_off(dev);
+			netif_device_detach(dev);
+			w5300_write(wp, IMR, 0x0000);
+			w5300_write(wp, Sn_CR(0), Sn_CR_CLOSE);
+
+			while (timeout--) {
+				if (!w5300_read(wp, Sn_CR(0)))
+					return 0;
+				udelay(1);
+			}
+			return -EBUSY;
+		}
+	}
+	return 0;
+}
+
+static int w5300_drv_resume(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	int ret = 0;
+
+	if (dev) {
+		struct wiz_private *wp = netdev_priv(dev);
+
+		if (netif_running(dev)) {
+			ret = w5300_reset(dev);
+			if (ret < 0)
+				goto out;
+
+			w5300_interrupt_enable(wp);
+
+			ret = w5300_channel_open(wp, Sn_MR_MACRAW_MF);
+			if (ret < 0)
+				goto out;
+
+			netif_carrier_on(dev);
+			netif_device_attach(dev);
+		}
+	}
+
+out:
+	return ret;
+}
+#endif /* CONFIG_PM */
+
+static struct platform_driver w5300_driver = {
+	.driver		= {
+		.name	= DEV_NAME,
+		.owner	= THIS_MODULE,
+	},
+	.probe		= w5300_drv_probe,
+	.remove		= __devexit_p(w5300_drv_remove),
+#ifdef CONFIG_PM
+	.suspend	= w5300_drv_suspend,
+	.resume		= w5300_drv_resume,
+#endif
+};
+
+static int __init wiz_module_init(void)
+{
+	return platform_driver_register(&w5300_driver);
+}
+
+static void __exit wiz_module_exit(void)
+{
+	platform_driver_unregister(&w5300_driver);
+}
+
+module_init(wiz_module_init);
+module_exit(wiz_module_exit);
diff --git a/drivers/net/ethernet/wiznet/w5300.h b/drivers/net/ethernet/wiznet/w5300.h
new file mode 100644
index 0000000..0d12288
--- /dev/null
+++ b/drivers/net/ethernet/wiznet/w5300.h
@@ -0,0 +1,121 @@
+#ifndef	_W5300_H_
+#define	_W5300_H_
+
+/* Maximum socket number. W5300 supports max 8 channels. */
+#define MAX_SOCK_NUM	8
+
+/* socket register */
+#define CH_BASE		(0x200)
+
+/* size of each channel register map */
+#define CH_SIZE		0x40
+
+#define MR		(0)	/**< Mode register */
+#define IR		(0x02)	/**< Interrupt register */
+#define IMR		(0x04)	/**< Interrupt mask register */
+#define SHAR		(0x08)	/**< Source MAC register address */
+#define TMSR		(0x20)	/**< Transmit memory size register */
+#define RMSR		(0x28)	/**< Receive memory size register */
+
+/*
+ * Memory Type Register
+ * '1' - TX memory
+ * '0' - RX memory
+ */
+#define MTYPER		(0x30)
+
+/* Chip ID register(=0x5300) */
+#define IDR		(0xFE)
+#define IDR1		(IDR + 1)
+
+/* socket Mode register */
+#define Sn_MR(ch)	(CH_BASE + ch * CH_SIZE + 0x00)
+#define Sn_MR1(ch)	(Sn_MR(ch)+1)
+
+/* socket command register */
+#define Sn_CR(ch)	(CH_BASE + ch * CH_SIZE + 0x02)
+#define Sn_CR1(ch)	(Sn_CR(ch)+1);
+
+/* socket interrupt register */
+#define Sn_IR(ch)	(CH_BASE + ch * CH_SIZE + 0x06)
+
+/* Transmit Size Register (Byte count) */
+#define Sn_TX_WRSR(ch)	(CH_BASE + ch * CH_SIZE + 0x20)
+
+/* Transmit free memory size register (Byte count) */
+#define Sn_TX_FSR(ch)	(CH_BASE + ch * CH_SIZE + 0x24)
+
+/* Received data size register (Byte count) */
+#define Sn_RX_RSR(ch)	(CH_BASE + ch * CH_SIZE + 0x28)
+
+/* FIFO register for Transmit */
+#define Sn_TX_FIFO(ch)	(CH_BASE + ch * CH_SIZE + 0x2E)
+
+/* FIFO register for Receive */
+#define Sn_RX_FIFO(ch)	(CH_BASE + ch * CH_SIZE + 0x30)
+
+/* MODE register values */
+#define MR_DBW		(1 << 15) /**< Data bus width bit of MR. */
+#define MR_MPF		(1 << 14) /**< Mac layer pause frame bit of MR. */
+#define MR_WDF(x)	((x & 0x07) << 11) /**< Write data fetch time bit of  MR. */
+#define MR_RDH		(1 << 10) /**< Read data hold time bit of MR. */
+#define MR_FS		(1 << 8)  /**< FIFO swap bit of MR. */
+#define MR_RST		(1 << 7)  /**< S/W reset bit of MR. */
+#define MR_MT		(1 << 5)  /**< Memory test bit of MR. */
+#define MR_PB		(1 << 4)  /**< Ping block bit of MR. */
+#define MR_PPPoE	(1 << 3)  /**< PPPoE bit of MR. */
+#define MR_DBS		(1 << 2)  /**< Data bus swap of MR. */
+#define MR_IND		(1 << 0)  /**< Indirect mode bit of MR. */
+
+/* IR register values */
+#define IR_IPCF		(1 << 7)  /**< IP conflict bit of IR. */
+#define IR_DPUR		(1 << 6)  /**< Destination port unreachable bit of IR. */
+#define IR_PPPT		(1 << 5)  /**< PPPoE terminate bit of IR. */
+#define IR_FMTU		(1 << 4)  /**< Fragment MTU bit of IR. */
+#define IR_SnINT(n)	(0x01 << n) /**< SOCKETn interrupt occurrence bit of IR. */
+
+/* Sn_MR values */
+#define Sn_MR_ALIGN     (1 << 8)  /**< Alignment bit of Sn_MR. */
+#define Sn_MR_MULTI     (1 << 7)  /**< Multicasting bit of Sn_MR. */
+#define Sn_MR_MF        (1 << 6)  /**< MAC filter bit of Sn_MR. */
+#define Sn_MR_IGMPv     (1 << 5)  /**< IGMP version bit of Sn_MR. */
+#define Sn_MR_ND        (1 << 5)  /**< No delayed ack bit of Sn_MR. */
+#define Sn_MR_CLOSE     0x00	  /**< Protocol bits of Sn_MR. */
+#define Sn_MR_TCP       0x01	  /**< Protocol bits of Sn_MR. */
+#define Sn_MR_UDP       0x02	  /**< Protocol bits of Sn_MR. */
+#define Sn_MR_IPRAW     0x03	  /**< Protocol bits of Sn_MR. */
+#define Sn_MR_MACRAW    0x04	  /**< Protocol bits of Sn_MR. */
+#define Sn_MR_MACRAW_MF 0x44	  /**< Protocol bits of Sn_MR  */
+#define Sn_MR_PPPoE     0x05	  /**< Protocol bits of Sn_MR. */
+
+/* Sn_CR values */
+#define Sn_CR_OPEN      0x01	/**< OPEN command value of Sn_CR. */
+#define Sn_CR_LISTEN    0x02	/**< LISTEN command value of Sn_CR. */
+#define Sn_CR_CONNECT   0x04	/**< CONNECT command value of Sn_CR. */
+#define Sn_CR_DISCON    0x08	/**< DISCONNECT command value of Sn_CR. */
+#define Sn_CR_CLOSE     0x10	/**< CLOSE command value of Sn_CR. */
+#define Sn_CR_SEND      0x20	/**< SEND command value of Sn_CR. */
+#define Sn_CR_SEND_MAC  0x21	/**< SEND_MAC command value of Sn_CR. */
+#define Sn_CR_SEND_KEEP 0x22	/**< SEND_KEEP command value of Sn_CR */
+#define Sn_CR_RECV      0x40	/**< RECV command value of Sn_CR */
+#define Sn_CR_PCON      0x23	/**< PCON command value of Sn_CR */
+#define Sn_CR_PDISCON   0x24	/**< PDISCON command value of Sn_CR */
+#define Sn_CR_PCR       0x25	/**< PCR command value of Sn_CR */
+#define Sn_CR_PCN       0x26	/**< PCN command value of Sn_CR */
+#define Sn_CR_PCJ       0x27	/**< PCJ command value of Sn_CR */
+
+/* Sn_IR values */
+#define Sn_IR_PRECV     0x80	/**< PPP receive bit of Sn_IR */
+#define Sn_IR_PFAIL     0x40	/**< PPP fail bit of Sn_IR */
+#define Sn_IR_PNEXT     0x20	/**< PPP next phase bit of Sn_IR */
+#define Sn_IR_SENDOK    0x10	/**< Send OK bit of Sn_IR */
+#define Sn_IR_TIMEOUT   0x08	/**< Timout bit of Sn_IR */
+#define Sn_IR_RECV      0x04	/**< Receive bit of Sn_IR */
+#define Sn_IR_DISCON    0x02	/**< Disconnect bit of Sn_IR */
+#define Sn_IR_CON       0x01	/**< Connect bit of Sn_IR */
+
+/* W5300 Register READ/WRITE funtions(Just 16 bit interface). */
+#define w5300_write(wp, addr, val) writew(val, (wp->base + addr))
+#define w5300_read(wp, addr) readw((wp->base + addr))
+
+#endif /* _W5300_H_ */
-- 
1.7.1

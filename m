From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: [PATCH][resend] add driver for enc28j60 ethernet chip
Date: Mon, 14 Jan 2008 11:00:28 +0100
Message-ID: <478B32BC.6070206@eptar.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030809000904040700020206"
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay03.albacom.net ([217.220.57.137]:62815 "EHLO
	fe-relay03.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432AbYANJ7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 04:59:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030809000904040700020206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch add support for Microchip enc28j60 10Mbps Ethernet chip used in embedded systems
due to its cheap SPI interface.
This 2nd version include changes from previous comments by Jeff and Stephen,
all but NAPI, see comments below at this regard.

I resend the patch because I didn't receive any feedback.

Changes to 1st version:
- use mutex instead of semaphore
- add carrier detect handling
- add ethtool support
- set_multicast_list when the interface is up using a workqueue
- add restart_work to reset the chip in case of tx_timeout
- removed kmalloc() for spi_transfer_buf (array defined in the priv struct)

Jeff Garzik wrote:
>
> comments:
>
> * Why do interrupt work in a kernel thread?  Your comment says you 
> cannot, but does not explain.
The enc28j60 is a SPI to Ethernet adapter, so we cannot access register 
with simple in() out() instructions, but we need to use the SPI 
subsystem. The spi_sync() basic operation to read/write a register is a 
blocking operation, so can't be done in interrupt context.
Since every basic operation like read interrupt flag register call 
spi_sync() we need the work queue for almost everything.

>
> * should use NAPI
>
For the reason I just explained I don't think NAPI is a viable way for 
enc28j60.
Furthermore enc28j60 is a 10Mb only device and probably don't suffer to 
interrupt overload.

I'm waiting for any comments, please.

Cheers,
Claudio Lanconelli



--------------030809000904040700020206
Content-Type: text/x-patch;
 name="enc28j60.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="enc28j60.patch"

Signed-off-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>

diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
new file mode 100644
index 0000000..0809a6a
--- /dev/null
+++ b/drivers/net/enc28j60.c
@@ -0,0 +1,1600 @@
+/*
+ * Microchip ENC28J60 ethernet driver (MAC + PHY)
+ *
+ * Copyright (C) 2007 Eurek srl
+ * Author: Claudio Lanconelli <lanconelli.claudio@eptar.com>
+ * based on enc28j60.c written by David Anders for 2.4 kernel version
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * $Id: enc28j60.c,v 1.22 2007/12/20 10:47:01 claudio Exp $
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/fcntl.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/tcp.h>
+#include <linux/skbuff.h>
+#include <linux/delay.h>
+#include <linux/spi/spi.h>
+
+#include "enc28j60_hw.h"
+
+#define DRV_NAME	"enc28j60"
+#define DRV_VERSION	"1.01"
+
+#define SPI_OPLEN	1
+
+#define ENC28J60_MSG_DEFAULT	\
+	(NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN | NETIF_MSG_LINK)
+
+/* Buffer size required for the largest SPI transfer (i.e., reading a
+ * frame). */
+#define SPI_TRANSFER_BUF_LEN	(4 + MAX_FRAMELEN)
+
+#define TX_TIMEOUT	(4 * HZ)
+
+/* Max TX retries in case of collision as suggested by errata datasheet */
+#define MAX_TX_RETRYCOUNT	16
+
+enum {
+	RXFILTER_NORMAL,
+	RXFILTER_MULTI,
+	RXFILTER_PROMISC
+};
+
+/* Driver local data */
+struct enc28j60_net {
+	struct net_device *netdev;
+	struct spi_device *spi;
+	struct mutex lock;
+	struct sk_buff *tx_skb;
+	struct work_struct tx_work;
+	struct work_struct irq_work;
+	struct work_struct setrx_work;
+	struct work_struct restart_work;
+	u8 bank;		/* current register bank selected */
+	u16 next_pk_ptr;	/* next packet pointer within FIFO */
+	u16 max_pk_counter;	/* statistics: max packet counter */
+	u16 tx_retry_count;
+	bool hw_enable;
+	bool full_duplex;
+	int rxfilter;
+	u32 msg_enable;
+	u8 spi_transfer_buf[SPI_TRANSFER_BUF_LEN];
+};
+
+/* use ethtool to change the level for any given device */
+static struct {
+	u32 msg_enable;
+} debug = { -1 };
+
+/*
+ * SPI read buffer
+ * wait for the SPI transfer and copy received data to destination
+ */
+static int
+spi_read_buf(struct enc28j60_net *priv, int len, u8 *data)
+{
+	u8 *rx_buf = priv->spi_transfer_buf + 4;
+	u8 *tx_buf = priv->spi_transfer_buf;
+	struct spi_transfer t = {
+		.tx_buf = tx_buf,
+		.rx_buf = rx_buf,
+		.len = SPI_OPLEN + len,
+	};
+	struct spi_message msg;
+	int ret;
+
+	tx_buf[0] = ENC28J60_READ_BUF_MEM;
+	tx_buf[1] = tx_buf[2] = tx_buf[3] = 0;	/* don't care */
+
+	spi_message_init(&msg);
+	spi_message_add_tail(&t, &msg);
+	ret = spi_sync(priv->spi, &msg);
+	if (ret == 0) {
+		memcpy(data, &rx_buf[SPI_OPLEN], len);
+		ret = msg.status;
+	}
+	if (ret && netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
+			__FUNCTION__, ret);
+
+	return ret;
+}
+
+/*
+ * SPI write buffer
+ */
+static int spi_write_buf(struct enc28j60_net *priv, int len,
+			 const u8 *data)
+{
+	int ret;
+
+	if (len > SPI_TRANSFER_BUF_LEN - 1 || len <= 0)
+		ret = -EINVAL;
+	else {
+		priv->spi_transfer_buf[0] = ENC28J60_WRITE_BUF_MEM;
+		memcpy(&priv->spi_transfer_buf[1], data, len);
+		ret = spi_write(priv->spi, priv->spi_transfer_buf, len + 1);
+		if (ret && netif_msg_drv(priv))
+			printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
+				__FUNCTION__, ret);
+	}
+	return ret;
+}
+
+/*
+ * basic SPI read operation
+ */
+static u8 spi_read_op(struct enc28j60_net *priv, u8 op,
+			   u8 addr)
+{
+	u8 tx_buf[2];
+	u8 rx_buf[4];
+	u8 val = 0;
+	int ret;
+	int slen = SPI_OPLEN;
+
+	/* do dummy read if needed */
+	if (addr & SPRD_MASK)
+		slen++;
+
+	tx_buf[0] = op | (addr & ADDR_MASK);
+	ret = spi_write_then_read(priv->spi, tx_buf, 1, rx_buf, slen);
+	if (ret)
+		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
+			__FUNCTION__, ret);
+	else
+		val = rx_buf[slen - 1];
+
+	return val;
+}
+
+/*
+ * basic SPI write operation
+ */
+static int spi_write_op(struct enc28j60_net *priv, u8 op,
+			u8 addr, u8 val)
+{
+	int ret;
+
+	priv->spi_transfer_buf[0] = op | (addr & ADDR_MASK);
+	priv->spi_transfer_buf[1] = val;
+	ret = spi_write(priv->spi, priv->spi_transfer_buf, 2);
+	if (ret && netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
+			__FUNCTION__, ret);
+	return ret;
+}
+
+static void enc28j60_soft_reset(struct enc28j60_net *priv)
+{
+	if (netif_msg_hw(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+
+	spi_write_op(priv, ENC28J60_SOFT_RESET, 0, ENC28J60_SOFT_RESET);
+	/* Errata workaround #1, CLKRDY check is unreliable,
+	 * delay at least 1 mS instead */
+	udelay(2000);
+}
+
+/*
+ * select the current register bank if necessary
+ */
+static void enc28j60_set_bank(struct enc28j60_net *priv, u8 addr)
+{
+	if ((addr & BANK_MASK) != priv->bank) {
+		u8 b = (addr & BANK_MASK) >> 5;
+
+		if (b != (ECON1_BSEL1 | ECON1_BSEL0))
+			spi_write_op(priv, ENC28J60_BIT_FIELD_CLR, ECON1,
+				     ECON1_BSEL1 | ECON1_BSEL0);
+		if (b != 0)
+			spi_write_op(priv, ENC28J60_BIT_FIELD_SET, ECON1, b);
+		priv->bank = (addr & BANK_MASK);
+	}
+}
+
+/*
+ * Register access routines through the SPI bus.
+ * Every register access comes in two flavours:
+ * - nolock_xxx: caller needs to invoke mutex_lock, usually to access
+ *   atomically more than one register
+ * - locked_xxx: caller doesn't need to invoke mutex_lock, single access
+ *
+ * Some registers can be accessed through the bit field clear and
+ * bit field set to avoid a read modify write cycle.
+ */
+
+/*
+ * Register bit field Set
+ */
+static void nolock_reg_bfset(struct enc28j60_net *priv,
+				      u8 addr, u8 mask)
+{
+	enc28j60_set_bank(priv, addr);
+	spi_write_op(priv, ENC28J60_BIT_FIELD_SET, addr, mask);
+}
+
+static void locked_reg_bfset(struct enc28j60_net *priv,
+				      u8 addr, u8 mask)
+{
+	mutex_lock(&priv->lock);
+	nolock_reg_bfset(priv, addr, mask);
+	mutex_unlock(&priv->lock);
+}
+
+/*
+ * Register bit field Clear
+ */
+static void nolock_reg_bfclr(struct enc28j60_net *priv,
+				      u8 addr, u8 mask)
+{
+	enc28j60_set_bank(priv, addr);
+	spi_write_op(priv, ENC28J60_BIT_FIELD_CLR, addr, mask);
+}
+
+static void locked_reg_bfclr(struct enc28j60_net *priv,
+				      u8 addr, u8 mask)
+{
+	mutex_lock(&priv->lock);
+	nolock_reg_bfclr(priv, addr, mask);
+	mutex_unlock(&priv->lock);
+}
+
+/*
+ * Register byte read
+ */
+static int nolock_regb_read(struct enc28j60_net *priv,
+				     u8 address)
+{
+	enc28j60_set_bank(priv, address);
+	return spi_read_op(priv, ENC28J60_READ_CTRL_REG, address);
+}
+
+static int locked_regb_read(struct enc28j60_net *priv,
+				     u8 address)
+{
+	int ret;
+
+	mutex_lock(&priv->lock);
+	ret = nolock_regb_read(priv, address);
+	mutex_unlock(&priv->lock);
+
+	return ret;
+}
+
+/*
+ * Register word read
+ */
+static int nolock_regw_read(struct enc28j60_net *priv,
+				     u8 address)
+{
+	int rl, rh;
+
+	enc28j60_set_bank(priv, address);
+	rl = spi_read_op(priv, ENC28J60_READ_CTRL_REG, address);
+	rh = spi_read_op(priv, ENC28J60_READ_CTRL_REG, address + 1);
+
+	return (rh << 8) | rl;
+}
+
+static int locked_regw_read(struct enc28j60_net *priv,
+				     u8 address)
+{
+	int ret;
+
+	mutex_lock(&priv->lock);
+	ret = nolock_regw_read(priv, address);
+	mutex_unlock(&priv->lock);
+
+	return ret;
+}
+
+/*
+ * Register byte write
+ */
+static void nolock_regb_write(struct enc28j60_net *priv,
+				       u8 address, u8 data)
+{
+	enc28j60_set_bank(priv, address);
+	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, address, data);
+}
+
+static void locked_regb_write(struct enc28j60_net *priv,
+				       u8 address, u8 data)
+{
+	mutex_lock(&priv->lock);
+	nolock_regb_write(priv, address, data);
+	mutex_unlock(&priv->lock);
+}
+
+/*
+ * Register word write
+ */
+static void nolock_regw_write(struct enc28j60_net *priv,
+				       u8 address, u16 data)
+{
+	enc28j60_set_bank(priv, address);
+	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, address, (u8) data);
+	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, address + 1,
+		     (u8) (data >> 8));
+}
+
+static void locked_regw_write(struct enc28j60_net *priv,
+				       u8 address, u16 data)
+{
+	mutex_lock(&priv->lock);
+	nolock_regw_write(priv, address, data);
+	mutex_unlock(&priv->lock);
+}
+
+/*
+ * Buffer memory read
+ * Select the starting address and execute a SPI buffer read
+ */
+static void enc28j60_mem_read(struct enc28j60_net *priv,
+				     u16 addr, int len, u8 *data)
+{
+	mutex_lock(&priv->lock);
+	nolock_regw_write(priv, ERDPTL, addr);
+#ifdef CONFIG_ENC28J60_WRITEVERIFY
+	if (netif_msg_drv(priv)) {
+		u16 reg;
+		reg = nolock_regw_read(priv, ERDPTL);
+		if (reg != addr)
+			printk(KERN_DEBUG DRV_NAME ": %s() error writing ERDPT "
+				"(0x%04x - 0x%04x)\n", __FUNCTION__, reg, addr);
+	}
+#endif
+	spi_read_buf(priv, len, data);
+	mutex_unlock(&priv->lock);
+}
+
+/*
+ * Write packet to enc28j60 TX buffer memory
+ */
+static void
+enc28j60_packet_write(struct enc28j60_net *priv, int len, const u8 *data)
+{
+	mutex_lock(&priv->lock);
+	/* Set the write pointer to start of transmit buffer area */
+	nolock_regw_write(priv, EWRPTL, TXSTART_INIT);
+#ifdef CONFIG_ENC28J60_WRITEVERIFY
+	if (netif_msg_drv(priv)) {
+		u16 reg;
+		reg = nolock_regw_read(priv, EWRPTL);
+		if (reg != TXSTART_INIT)
+			printk(KERN_DEBUG DRV_NAME
+				": %s() ERWPT:0x%04x != 0x%04x\n",
+				__FUNCTION__, reg, TXSTART_INIT);
+	}
+#endif
+	/* Set the TXND pointer to correspond to the packet size given */
+	nolock_regw_write(priv, ETXNDL, TXSTART_INIT + len);
+	/* write per-packet control byte */
+	spi_write_op(priv, ENC28J60_WRITE_BUF_MEM, 0, 0x00);
+	if (netif_msg_hw(priv))
+		printk(KERN_DEBUG DRV_NAME
+			": %s() after control byte ERWPT:0x%04x\n",
+			__FUNCTION__, nolock_regw_read(priv, EWRPTL));
+	/* copy the packet into the transmit buffer */
+	spi_write_buf(priv, len, data);
+	if (netif_msg_hw(priv))
+		printk(KERN_DEBUG DRV_NAME
+			 ": %s() after write packet ERWPT:0x%04x, len=%d\n",
+			 __FUNCTION__, nolock_regw_read(priv, EWRPTL), len);
+	mutex_unlock(&priv->lock);
+}
+
+/*
+ * Wait until the PHY operation is complete.
+ */
+static int wait_phy_ready(struct enc28j60_net *priv)
+{
+	unsigned long timeout = jiffies + 20 * HZ / 1000;
+	int ret = 1;
+
+	/* 20 msec timeout read */
+	while (nolock_regb_read(priv, MISTAT) & MISTAT_BUSY) {
+		if (time_after(jiffies, timeout)) {
+			if (netif_msg_drv(priv))
+				printk(KERN_DEBUG DRV_NAME
+					": PHY ready timeout!\n");
+			ret = 0;
+			break;
+		}
+		cpu_relax();
+	}
+	return ret;
+}
+
+/*
+ * PHY register read
+ * PHY registers are not accessed directly, but through the MII
+ */
+static u16 enc28j60_phy_read(struct enc28j60_net *priv, u8 address)
+{
+	u16 ret;
+
+	mutex_lock(&priv->lock);
+	/* set the PHY register address */
+	nolock_regb_write(priv, MIREGADR, address);
+	/* start the register read operation */
+	nolock_regb_write(priv, MICMD, MICMD_MIIRD);
+	/* wait until the PHY read completes */
+	wait_phy_ready(priv);
+	/* quit reading */
+	nolock_regb_write(priv, MICMD, 0x00);
+	/* return the data */
+	ret  = nolock_regw_read(priv, MIRDL);
+	mutex_unlock(&priv->lock);
+
+	return ret;
+}
+
+static int enc28j60_phy_write(struct enc28j60_net *priv, u8 address, u16 data)
+{
+	int ret;
+
+	mutex_lock(&priv->lock);
+	/* set the PHY register address */
+	nolock_regb_write(priv, MIREGADR, address);
+	/* write the PHY data */
+	nolock_regw_write(priv, MIWRL, data);
+	/* wait until the PHY write completes and return */
+	ret = wait_phy_ready(priv);
+	mutex_unlock(&priv->lock);
+
+	return ret;
+}
+
+/*
+ * Program the hardware MAC address from dev->dev_addr.
+ */
+static int enc28j60_set_hw_macaddr(struct net_device *ndev)
+{
+	int ret;
+	struct enc28j60_net *priv = netdev_priv(ndev);
+
+	mutex_lock(&priv->lock);
+	if (!priv->hw_enable) {
+		if (netif_msg_drv(priv)) {
+			DECLARE_MAC_BUF(mac);
+			printk(KERN_INFO DRV_NAME
+				": %s: Setting MAC address to %s\n",
+				ndev->name, print_mac(mac, ndev->dev_addr));
+		}
+		/* NOTE: MAC address in ENC28J60 is byte-backward */
+		nolock_regb_write(priv, MAADR5, ndev->dev_addr[0]);
+		nolock_regb_write(priv, MAADR4, ndev->dev_addr[1]);
+		nolock_regb_write(priv, MAADR3, ndev->dev_addr[2]);
+		nolock_regb_write(priv, MAADR2, ndev->dev_addr[3]);
+		nolock_regb_write(priv, MAADR1, ndev->dev_addr[4]);
+		nolock_regb_write(priv, MAADR0, ndev->dev_addr[5]);
+		ret = 0;
+	} else {
+		if (netif_msg_drv(priv))
+			printk(KERN_DEBUG DRV_NAME
+				": %s() Hardware must be disabled to set "
+				"Mac address\n", __FUNCTION__);
+		ret = -EBUSY;
+	}
+	mutex_unlock(&priv->lock);
+	return ret;
+}
+
+/*
+ * Store the new hardware address in dev->dev_addr, and update the MAC.
+ */
+static int enc28j60_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sockaddr *address = addr;
+
+	if (netif_running(dev))
+		return -EBUSY;
+	if (!is_valid_ether_addr(address->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, address->sa_data, dev->addr_len);
+	return enc28j60_set_hw_macaddr(dev);
+}
+
+/*
+ * Debug routine to dump useful register contents
+ */
+static void enc28j60_dump_regs(struct enc28j60_net *priv, const char *msg)
+{
+	mutex_lock(&priv->lock);
+	printk(KERN_DEBUG DRV_NAME " %s\n"
+		"HwRevID: 0x%02x\n"
+		"Cntrl: ECON1 ECON2 ESTAT  EIR  EIE\n"
+		"       0x%02x  0x%02x  0x%02x  0x%02x  0x%02x\n"
+		"MAC  : MACON1 MACON3 MACON4\n"
+		"       0x%02x   0x%02x   0x%02x\n"
+		"Rx   : ERXST  ERXND  ERXWRPT ERXRDPT ERXFCON EPKTCNT MAMXFL\n"
+		"       0x%04x 0x%04x 0x%04x  0x%04x  "
+		"0x%02x    0x%02x    0x%04x\n"
+		"Tx   : ETXST  ETXND  MACLCON1 MACLCON2 MAPHSUP\n"
+		"       0x%04x 0x%04x 0x%02x     0x%02x     0x%02x\n",
+		msg, nolock_regb_read(priv, EREVID),
+		nolock_regb_read(priv, ECON1), nolock_regb_read(priv, ECON2),
+		nolock_regb_read(priv, ESTAT), nolock_regb_read(priv, EIR),
+		nolock_regb_read(priv, EIE), nolock_regb_read(priv, MACON1),
+		nolock_regb_read(priv, MACON3), nolock_regb_read(priv, MACON4),
+		nolock_regw_read(priv, ERXSTL), nolock_regw_read(priv, ERXNDL),
+		nolock_regw_read(priv, ERXWRPTL),
+		nolock_regw_read(priv, ERXRDPTL),
+		nolock_regb_read(priv, ERXFCON),
+		nolock_regb_read(priv, EPKTCNT),
+		nolock_regw_read(priv, MAMXFLL), nolock_regw_read(priv, ETXSTL),
+		nolock_regw_read(priv, ETXNDL),
+		nolock_regb_read(priv, MACLCON1),
+		nolock_regb_read(priv, MACLCON2),
+		nolock_regb_read(priv, MAPHSUP));
+	mutex_unlock(&priv->lock);
+}
+
+/*
+ * ERXRDPT need to be set always at odd addresses, refer to errata datasheet
+ */
+static u16 erxrdpt_workaround(u16 next_packet_ptr, u16 start, u16 end)
+{
+	u16 erxrdpt;
+
+	if ((next_packet_ptr - 1 < start) || (next_packet_ptr - 1 > end))
+		erxrdpt = end;
+	else
+		erxrdpt = next_packet_ptr - 1;
+
+	return erxrdpt;
+}
+
+static void nolock_rxfifo_init(struct enc28j60_net *priv, u16 start, u16 end)
+{
+	u16 erxrdpt;
+
+	if (start > 0x1FFF || end > 0x1FFF || start > end) {
+		if (netif_msg_drv(priv))
+			printk(KERN_ERR DRV_NAME ": %s(%d, %d) RXFIFO "
+				"bad parameters!\n", __FUNCTION__, start, end);
+		return;
+	}
+	/* set receive buffer start + end */
+	priv->next_pk_ptr = start;
+	nolock_regw_write(priv, ERXSTL, start);
+	erxrdpt = erxrdpt_workaround(priv->next_pk_ptr, start, end);
+	nolock_regw_write(priv, ERXRDPTL, erxrdpt);
+	nolock_regw_write(priv, ERXNDL, end);
+}
+
+static void nolock_txfifo_init(struct enc28j60_net *priv, u16 start, u16 end)
+{
+	if (start > 0x1FFF || end > 0x1FFF || start > end) {
+		if (netif_msg_drv(priv))
+			printk(KERN_ERR DRV_NAME ": %s(%d, %d) TXFIFO "
+				"bad parameters!\n", __FUNCTION__, start, end);
+		return;
+	}
+	/* set transmit buffer start + end */
+	nolock_regw_write(priv, ETXSTL, start);
+	nolock_regw_write(priv, ETXNDL, end);
+}
+
+static int enc28j60_hw_init(struct enc28j60_net *priv)
+{
+	u8 reg;
+
+	if (netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() - %s\n", __FUNCTION__,
+			priv->full_duplex ? "FullDuplex" : "HalfDuplex");
+
+	mutex_lock(&priv->lock);
+	/* first reset the chip */
+	enc28j60_soft_reset(priv);
+	/* Clear ECON1 */
+	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, ECON1, 0x00);
+	priv->bank = 0;
+	priv->hw_enable = false;
+	priv->tx_retry_count = 0;
+	priv->max_pk_counter = 0;
+	priv->rxfilter = RXFILTER_NORMAL;
+	/* enable address auto increment */
+	nolock_regb_write(priv, ECON2, ECON2_AUTOINC);
+
+	nolock_rxfifo_init(priv, RXSTART_INIT, RXEND_INIT);
+	nolock_txfifo_init(priv, TXSTART_INIT, TXEND_INIT);
+	mutex_unlock(&priv->lock);
+
+	/*
+	 * Check the RevID.
+	 * If it's 0x00 or 0xFF probably the enc28j60 is not mounted or
+	 * damaged
+	 */
+	reg = locked_regb_read(priv, EREVID);
+	if (netif_msg_drv(priv))
+		printk(KERN_INFO DRV_NAME ": chip RevID: 0x%02x\n", reg);
+	if (reg == 0x00 || reg == 0xff) {
+		if (netif_msg_drv(priv))
+			printk(KERN_DEBUG DRV_NAME ": %s() Invalid RevId %d\n",
+				__FUNCTION__, reg);
+		return 0;
+	}
+
+	/* default filter mode: (unicast OR broadcast) AND crc valid */
+	locked_regb_write(priv, ERXFCON,
+			    ERXFCON_UCEN | ERXFCON_CRCEN | ERXFCON_BCEN);
+
+	/* enable MAC receive */
+	locked_regb_write(priv, MACON1,
+			    MACON1_MARXEN | MACON1_TXPAUS | MACON1_RXPAUS);
+	/* enable automatic padding and CRC operations */
+	if (priv->full_duplex) {
+		locked_regb_write(priv, MACON3,
+				    MACON3_PADCFG0 | MACON3_TXCRCEN |
+				    MACON3_FRMLNEN | MACON3_FULDPX);
+		/* set inter-frame gap (non-back-to-back) */
+		locked_regb_write(priv, MAIPGL, 0x12);
+		/* set inter-frame gap (back-to-back) */
+		locked_regb_write(priv, MABBIPG, 0x15);
+	} else {
+		locked_regb_write(priv, MACON3,
+				    MACON3_PADCFG0 | MACON3_TXCRCEN |
+				    MACON3_FRMLNEN);
+		locked_regb_write(priv, MACON4, 1 << 6);	/* DEFER bit */
+		/* set inter-frame gap (non-back-to-back) */
+		locked_regw_write(priv, MAIPGL, 0x0C12);
+		/* set inter-frame gap (back-to-back) */
+		locked_regb_write(priv, MABBIPG, 0x12);
+	}
+	/*
+	 * MACLCON1 (default)
+	 * MACLCON2 (default)
+	 * Set the maximum packet size which the controller will accept
+	 */
+	locked_regw_write(priv, MAMXFLL, MAX_FRAMELEN);
+
+	/* Configure LEDs */
+	if (!enc28j60_phy_write(priv, PHLCON, ENC28J60_LAMPS_MODE))
+		return 0;
+
+	if (priv->full_duplex) {
+		if (!enc28j60_phy_write(priv, PHCON1, PHCON1_PDPXMD))
+			return 0;
+		if (!enc28j60_phy_write(priv, PHCON2, 0x00))
+			return 0;
+	} else {
+		if (!enc28j60_phy_write(priv, PHCON1, 0x00))
+			return 0;
+		if (!enc28j60_phy_write(priv, PHCON2, PHCON2_HDLDIS))
+			return 0;
+	}
+	if (netif_msg_hw(priv))
+		enc28j60_dump_regs(priv, "Hw initialized.");
+
+	return 1;
+}
+
+static void enc28j60_hw_enable(struct enc28j60_net *priv)
+{
+	/* enable interrutps */
+	if (netif_msg_hw(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() enabling interrupts.\n",
+			__FUNCTION__);
+
+	enc28j60_phy_write(priv, PHIE, PHIE_PGEIE | PHIE_PLNKIE);
+
+	mutex_lock(&priv->lock);
+	nolock_reg_bfclr(priv, EIR, EIR_DMAIF | EIR_LINKIF |
+			 EIR_TXIF | EIR_TXERIF | EIR_RXERIF | EIR_PKTIF);
+	nolock_regb_write(priv, EIE, EIE_INTIE | EIE_PKTIE | EIE_LINKIE |
+			  EIE_TXIE | EIE_TXERIE | EIE_RXERIE);
+
+	/* enable receive logic */
+	nolock_reg_bfset(priv, ECON1, ECON1_RXEN);
+	priv->hw_enable = true;
+	mutex_unlock(&priv->lock);
+}
+
+static void enc28j60_hw_disable(struct enc28j60_net *priv)
+{
+	mutex_lock(&priv->lock);
+	/* disable interrutps and packet reception */
+	nolock_regb_write(priv, EIE, 0x00);
+	nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
+	priv->hw_enable = false;
+	mutex_unlock(&priv->lock);
+}
+
+static int
+enc28j60_setlink(struct net_device *ndev, u8 autoneg, u16 speed, u8 duplex)
+{
+	struct enc28j60_net *priv = netdev_priv(ndev);
+	int ret = 0;
+
+	if (!priv->hw_enable) {
+		if (autoneg == AUTONEG_DISABLE && speed == SPEED_10) {
+			priv->full_duplex = (duplex == DUPLEX_FULL);
+			if (!enc28j60_hw_init(priv)) {
+				if (netif_msg_drv(priv))
+					dev_err(&ndev->dev,
+						"hw_reset() failed\n");
+				ret = -EINVAL;
+			}
+		} else {
+			if (netif_msg_link(priv))
+				dev_warn(&ndev->dev,
+					"unsupported link setting\n");
+			ret = -EOPNOTSUPP;
+		}
+	} else {
+		if (netif_msg_link(priv))
+			dev_warn(&ndev->dev, "Warning: hw must be disabled "
+				"to set link mode\n");
+		ret = -EBUSY;
+	}
+	return ret;
+}
+
+/*
+ * Read the Transmit Status Vector
+ */
+static void enc28j60_read_tsv(struct enc28j60_net *priv, u8 tsv[TSV_SIZE])
+{
+	int endptr;
+
+	endptr = locked_regw_read(priv, ETXNDL);
+	if (netif_msg_hw(priv))
+		printk(KERN_DEBUG DRV_NAME ": reading TSV at addr:0x%04x\n",
+			 endptr + 1);
+	enc28j60_mem_read(priv, endptr + 1, sizeof(tsv), tsv);
+}
+
+static void enc28j60_dump_tsv(struct enc28j60_net *priv, const char *msg,
+				u8 tsv[TSV_SIZE])
+{
+	u16 tmp1, tmp2;
+
+	printk(KERN_DEBUG DRV_NAME ": %s - TSV:\n", msg);
+	tmp1 = tsv[1];
+	tmp1 <<= 8;
+	tmp1 |= tsv[0];
+
+	tmp2 = tsv[5];
+	tmp2 <<= 8;
+	tmp2 |= tsv[4];
+
+	printk(KERN_DEBUG DRV_NAME ": ByteCount: %d, CollisionCount: %d,"
+		" TotByteOnWire: %d\n", tmp1, tsv[2] & 0x0f, tmp2);
+	printk(KERN_DEBUG DRV_NAME ": TxDone: %d, CRCErr:%d, LenChkErr: %d,"
+		" LenOutOfRange: %d\n", TSV_GETBIT(tsv, TSV_TXDONE),
+		TSV_GETBIT(tsv, TSV_TXCRCERROR),
+		TSV_GETBIT(tsv, TSV_TXLENCHKERROR),
+		TSV_GETBIT(tsv, TSV_TXLENOUTOFRANGE));
+	printk(KERN_DEBUG DRV_NAME ": Multicast: %d, Broadcast: %d, "
+		"PacketDefer: %d, ExDefer: %d\n",
+		TSV_GETBIT(tsv, TSV_TXMULTICAST),
+		TSV_GETBIT(tsv, TSV_TXBROADCAST),
+		TSV_GETBIT(tsv, TSV_TXPACKETDEFER),
+		TSV_GETBIT(tsv, TSV_TXEXDEFER));
+	printk(KERN_DEBUG DRV_NAME ": ExCollision: %d, LateCollision: %d, "
+		 "Giant: %d, Underrun: %d\n",
+		 TSV_GETBIT(tsv, TSV_TXEXCOLLISION),
+		 TSV_GETBIT(tsv, TSV_TXLATECOLLISION),
+		 TSV_GETBIT(tsv, TSV_TXGIANT), TSV_GETBIT(tsv, TSV_TXUNDERRUN));
+	printk(KERN_DEBUG DRV_NAME ": ControlFrame: %d, PauseFrame: %d, "
+		 "BackPressApp: %d, VLanTagFrame: %d\n",
+		 TSV_GETBIT(tsv, TSV_TXCONTROLFRAME),
+		 TSV_GETBIT(tsv, TSV_TXPAUSEFRAME),
+		 TSV_GETBIT(tsv, TSV_BACKPRESSUREAPP),
+		 TSV_GETBIT(tsv, TSV_TXVLANTAGFRAME));
+}
+
+/*
+ * Receive Status vector
+ */
+static void enc28j60_dump_rsv(struct enc28j60_net *priv, const char *msg,
+			      u16 pk_ptr, int len, u16 sts)
+{
+	printk(KERN_DEBUG DRV_NAME ": %s - NextPk: 0x%04x - RSV:\n",
+		msg, pk_ptr);
+	printk(KERN_DEBUG DRV_NAME ": ByteCount: %d, DribbleNibble: %d\n", len,
+		 RSV_GETBIT(sts, RSV_DRIBBLENIBBLE));
+	printk(KERN_DEBUG DRV_NAME ": RxOK: %d, CRCErr:%d, LenChkErr: %d,"
+		 " LenOutOfRange: %d\n", RSV_GETBIT(sts, RSV_RXOK),
+		 RSV_GETBIT(sts, RSV_CRCERROR),
+		 RSV_GETBIT(sts, RSV_LENCHECKERR),
+		 RSV_GETBIT(sts, RSV_LENOUTOFRANGE));
+	printk(KERN_DEBUG DRV_NAME ": Multicast: %d, Broadcast: %d, "
+		 "LongDropEvent: %d, CarrierEvent: %d\n",
+		 RSV_GETBIT(sts, RSV_RXMULTICAST),
+		 RSV_GETBIT(sts, RSV_RXBROADCAST),
+		 RSV_GETBIT(sts, RSV_RXLONGEVDROPEV),
+		 RSV_GETBIT(sts, RSV_CARRIEREV));
+	printk(KERN_DEBUG DRV_NAME ": ControlFrame: %d, PauseFrame: %d,"
+		 " UnknownOp: %d, VLanTagFrame: %d\n",
+		 RSV_GETBIT(sts, RSV_RXCONTROLFRAME),
+		 RSV_GETBIT(sts, RSV_RXPAUSEFRAME),
+		 RSV_GETBIT(sts, RSV_RXUNKNOWNOPCODE),
+		 RSV_GETBIT(sts, RSV_RXTYPEVLAN));
+}
+
+static void dump_packet(const char *msg, int len, const char *data)
+{
+	printk(KERN_DEBUG DRV_NAME ": %s - packet len:%d\n", msg, len);
+	print_hex_dump(KERN_DEBUG, "pk data: ", DUMP_PREFIX_OFFSET, 16, 1,
+			data, len, true);
+}
+
+/*
+ * Hardware receive function.
+ * Read the buffer memory, update the FIFO pointer to free the buffer,
+ * check the status vector and decrement the packet counter.
+ */
+static void enc28j60_hw_rx(struct net_device *ndev)
+{
+	struct enc28j60_net *priv = netdev_priv(ndev);
+	struct sk_buff *skb = NULL;
+	u16 erxrdpt, next_packet, rxstat;
+	u8 rsv[RSV_SIZE];
+	int len;
+
+	if (netif_msg_rx_status(priv))
+		printk(KERN_DEBUG DRV_NAME ": RX pk_addr:0x%04x\n",
+			priv->next_pk_ptr);
+
+	if (unlikely(priv->next_pk_ptr > RXEND_INIT)) {
+		if (netif_msg_rx_err(priv))
+			dev_err(&ndev->dev,
+				"%s() Invalid packet address!! 0x%04x\n",
+				__FUNCTION__, priv->next_pk_ptr);
+		/* packet address corrupted: reset RX logic */
+		mutex_lock(&priv->lock);
+		nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
+		nolock_reg_bfset(priv, ECON1, ECON1_RXRST);
+		nolock_reg_bfclr(priv, ECON1, ECON1_RXRST);
+		nolock_rxfifo_init(priv, RXSTART_INIT, RXEND_INIT);
+		nolock_reg_bfclr(priv, EIR, EIR_RXERIF);
+		nolock_reg_bfset(priv, ECON1, ECON1_RXEN);
+		mutex_unlock(&priv->lock);
+		ndev->stats.rx_errors++;
+		return;
+	}
+	/* Read next packet pointer and rx status vector */
+	enc28j60_mem_read(priv, priv->next_pk_ptr, sizeof(rsv), rsv);
+
+	next_packet = rsv[1];
+	next_packet <<= 8;
+	next_packet |= rsv[0];
+
+	len = rsv[3];
+	len <<= 8;
+	len |= rsv[2];
+
+	rxstat = rsv[5];
+	rxstat <<= 8;
+	rxstat |= rsv[4];
+
+	if (netif_msg_rx_status(priv))
+		enc28j60_dump_rsv(priv, __FUNCTION__, next_packet, len, rxstat);
+
+	if (!RSV_GETBIT(rxstat, RSV_RXOK)) {
+		if (netif_msg_rx_err(priv))
+			dev_err(&ndev->dev, "Rx Error (%04x)\n", rxstat);
+		ndev->stats.rx_errors++;
+		if (RSV_GETBIT(rxstat, RSV_CRCERROR))
+			ndev->stats.rx_crc_errors++;
+		if (RSV_GETBIT(rxstat, RSV_LENCHECKERR))
+			ndev->stats.rx_frame_errors++;
+	} else {
+		skb = dev_alloc_skb(len);
+		if (!skb) {
+			if (netif_msg_rx_err(priv))
+				dev_err(&ndev->dev,
+					"out of memory for Rx'd frame\n");
+			ndev->stats.rx_dropped++;
+		} else {
+			skb->dev = ndev;
+			/* copy the packet from the receive buffer */
+			enc28j60_mem_read(priv, priv->next_pk_ptr + sizeof(rsv),
+					len, skb_put(skb, len));
+			if (netif_msg_pktdata(priv))
+				dump_packet(__FUNCTION__, skb->len, skb->data);
+			skb->protocol = eth_type_trans(skb, ndev);
+			/* update statistics */
+			ndev->stats.rx_packets++;
+			ndev->stats.rx_bytes += len;
+			ndev->last_rx = jiffies;
+			netif_rx(skb);
+		}
+	}
+	/*
+	 * Move the RX read pointer to the start of the next
+	 * received packet.
+	 * This frees the memory we just read out
+	 */
+	erxrdpt = erxrdpt_workaround(next_packet, RXSTART_INIT, RXEND_INIT);
+	if (netif_msg_hw(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() ERXRDPT:0x%04x\n",
+			__FUNCTION__, erxrdpt);
+
+	mutex_lock(&priv->lock);
+	nolock_regw_write(priv, ERXRDPTL, erxrdpt);
+#ifdef CONFIG_ENC28J60_WRITEVERIFY
+	if (netif_msg_drv(priv)) {
+		u16 reg;
+		reg = nolock_regw_read(priv, ERXRDPTL);
+		if (reg != erxrdpt)
+			printk(KERN_DEBUG DRV_NAME ": %s() ERXRDPT verify "
+				"error (0x%04x - 0x%04x)\n", __FUNCTION__,
+				reg, erxrdpt);
+	}
+#endif
+	priv->next_pk_ptr = next_packet;
+	/* we are done with this packet, decrement the packet counter */
+	nolock_reg_bfset(priv, ECON2, ECON2_PKTDEC);
+	mutex_unlock(&priv->lock);
+}
+
+/*
+ * Calculate free space in RxFIFO
+ */
+static int enc28j60_get_free_rxfifo(struct enc28j60_net *priv)
+{
+	int epkcnt, erxst, erxnd, erxwr, erxrd;
+	int free_space;
+
+	mutex_lock(&priv->lock);
+	epkcnt = nolock_regb_read(priv, EPKTCNT);
+	if (epkcnt >= 255)
+		free_space = -1;
+	else {
+		erxst = nolock_regw_read(priv, ERXSTL);
+		erxnd = nolock_regw_read(priv, ERXNDL);
+		erxwr = nolock_regw_read(priv, ERXWRPTL);
+		erxrd = nolock_regw_read(priv, ERXRDPTL);
+
+		if (erxwr > erxrd)
+			free_space = (erxnd - erxst) - (erxwr - erxrd);
+		else if (erxwr == erxrd)
+			free_space = (erxnd - erxst);
+		else
+			free_space = erxrd - erxwr - 1;
+	}
+	mutex_unlock(&priv->lock);
+	if (netif_msg_rx_status(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() free_space = %d\n",
+			__FUNCTION__, free_space);
+	return free_space;
+}
+
+/*
+ * Access the PHY to determine link status
+ */
+static void enc28j60_check_link_status(struct net_device *ndev)
+{
+	struct enc28j60_net *priv = netdev_priv(ndev);
+	u16 reg;
+	int duplex;
+
+	reg = enc28j60_phy_read(priv, PHSTAT2);
+	if (netif_msg_hw(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() PHSTAT1: %04x, "
+			"PHSTAT2: %04x\n", __FUNCTION__,
+			enc28j60_phy_read(priv, PHSTAT1), reg);
+	duplex = reg & PHSTAT2_DPXSTAT;
+
+	if (reg & PHSTAT2_LSTAT) {
+		netif_carrier_on(ndev);
+		if (netif_msg_ifup(priv))
+			dev_info(&ndev->dev, "link up - %s\n",
+				duplex ? "Full duplex" : "Half duplex");
+	} else {
+		if (netif_msg_ifdown(priv))
+			dev_info(&ndev->dev, "link down\n");
+		netif_carrier_off(ndev);
+	}
+}
+
+static void enc28j60_tx_clear(struct net_device *ndev, bool err)
+{
+	struct enc28j60_net *priv = netdev_priv(ndev);
+
+	if (err)
+		ndev->stats.tx_errors++;
+	else
+		ndev->stats.tx_packets++;
+
+	if (priv->tx_skb) {
+		if (!err)
+			ndev->stats.tx_bytes += priv->tx_skb->len;
+		dev_kfree_skb(priv->tx_skb);
+		priv->tx_skb = NULL;
+	}
+	locked_reg_bfclr(priv, ECON1, ECON1_TXRTS);
+	netif_wake_queue(ndev);
+}
+
+/*
+ * RX handler
+ * ignore PKTIF because is unreliable! (look at the errata datasheet)
+ * check EPKTCNT is the suggested workaround.
+ * We don't need to clear interrupt flag, automatically done when
+ * enc28j60_hw_rx() decrements the packet counter.
+ * Returns how many packet processed.
+ */
+static int enc28j60_rx_interrupt(struct net_device *ndev)
+{
+	struct enc28j60_net *priv = netdev_priv(ndev);
+	int pk_counter, ret;
+
+	pk_counter = locked_regb_read(priv, EPKTCNT);
+	if (pk_counter && netif_msg_intr(priv))
+		printk(KERN_DEBUG DRV_NAME ": intRX, pk_cnt: %d\n", pk_counter);
+	if (pk_counter > priv->max_pk_counter) {
+		/* update statistics */
+		priv->max_pk_counter = pk_counter;
+		if (netif_msg_rx_status(priv) && priv->max_pk_counter > 1)
+			printk(KERN_DEBUG DRV_NAME ": RX max_pk_cnt: %d\n",
+				priv->max_pk_counter);
+	}
+	ret = pk_counter;
+	while (pk_counter-- > 0)
+		enc28j60_hw_rx(ndev);
+
+	return ret;
+}
+
+static void enc28j60_irq_work_handler(struct work_struct *work)
+{
+	struct enc28j60_net *priv =
+		container_of(work, struct enc28j60_net, irq_work);
+	struct net_device *ndev = priv->netdev;
+	int intflags, loop;
+
+	if (netif_msg_intr(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+	/* disable further interrupts */
+	locked_reg_bfclr(priv, EIE, EIE_INTIE);
+
+	do {
+		loop = 0;
+		intflags = locked_regb_read(priv, EIR);
+		/* DMA interrupt handler (not currently used) */
+		if ((intflags & EIR_DMAIF) != 0) {
+			loop++;
+			if (netif_msg_intr(priv))
+				printk(KERN_DEBUG DRV_NAME
+					": intDMA(%d)\n", loop);
+			locked_reg_bfclr(priv, EIR, EIR_DMAIF);
+		}
+		/* LINK changed handler */
+		if ((intflags & EIR_LINKIF) != 0) {
+			loop++;
+			if (netif_msg_intr(priv))
+				printk(KERN_DEBUG DRV_NAME
+					": intLINK(%d)\n", loop);
+			enc28j60_check_link_status(ndev);
+			/* read PHIR to clear the flag */
+			enc28j60_phy_read(priv, PHIR);
+		}
+		/* TX complete handler */
+		if ((intflags & EIR_TXIF) != 0) {
+			bool err = false;
+			loop++;
+			if (netif_msg_intr(priv))
+				printk(KERN_DEBUG DRV_NAME
+					": intTX(%d)\n", loop);
+			priv->tx_retry_count = 0;
+			if (locked_regb_read(priv, ESTAT) & ESTAT_TXABRT) {
+				if (netif_msg_tx_err(priv))
+					dev_err(&ndev->dev,
+						"Tx Error (aborted)\n");
+				err = true;
+			}
+			if (netif_msg_tx_done(priv)) {
+				u8 tsv[TSV_SIZE];
+				enc28j60_read_tsv(priv, tsv);
+				enc28j60_dump_tsv(priv, "Tx Done", tsv);
+			}
+			enc28j60_tx_clear(ndev, err);
+			locked_reg_bfclr(priv, EIR, EIR_TXIF);
+		}
+		/* TX Error handler */
+		if ((intflags & EIR_TXERIF) != 0) {
+			u8 tsv[TSV_SIZE];
+
+			loop++;
+			if (netif_msg_intr(priv))
+				printk(KERN_DEBUG DRV_NAME
+					": intTXErr(%d)\n", loop);
+			locked_reg_bfclr(priv, ECON1, ECON1_TXRTS);
+			enc28j60_read_tsv(priv, tsv);
+			if (netif_msg_tx_err(priv))
+				enc28j60_dump_tsv(priv, "Tx Error", tsv);
+			/* Reset TX logic */
+			mutex_lock(&priv->lock);
+			nolock_reg_bfset(priv, ECON1, ECON1_TXRST);
+			nolock_reg_bfclr(priv, ECON1, ECON1_TXRST);
+			nolock_txfifo_init(priv, TXSTART_INIT, TXEND_INIT);
+			mutex_unlock(&priv->lock);
+			/* Transmit Late collision check for retransmit */
+			if (TSV_GETBIT(tsv, TSV_TXLATECOLLISION)) {
+				if (netif_msg_tx_err(priv))
+					printk(KERN_DEBUG DRV_NAME
+						": LateCollision TXErr (%d)\n",
+						priv->tx_retry_count);
+				if (priv->tx_retry_count++ < MAX_TX_RETRYCOUNT)
+					locked_reg_bfset(priv, ECON1,
+							   ECON1_TXRTS);
+				else
+					enc28j60_tx_clear(ndev, true);
+			} else
+				enc28j60_tx_clear(ndev, true);
+			locked_reg_bfclr(priv, EIR, EIR_TXERIF);
+		}
+		/* RX Error handler */
+		if ((intflags & EIR_RXERIF) != 0) {
+			loop++;
+			if (netif_msg_intr(priv))
+				printk(KERN_DEBUG DRV_NAME
+					": intRXErr(%d)\n", loop);
+			/* Check free FIFO space to flag RX overrun */
+			if (enc28j60_get_free_rxfifo(priv) <= 0) {
+				if (netif_msg_rx_err(priv))
+					printk(KERN_DEBUG DRV_NAME
+						": RX Overrun\n");
+				ndev->stats.rx_dropped++;
+			}
+			locked_reg_bfclr(priv, EIR, EIR_RXERIF);
+		}
+		/* RX handler */
+		if (enc28j60_rx_interrupt(ndev))
+			loop++;
+	} while (loop);
+
+	/* re-enable interrupts */
+	locked_reg_bfset(priv, EIE, EIE_INTIE);
+	if (netif_msg_intr(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() exit\n", __FUNCTION__);
+}
+
+/*
+ * Hardware transmit function.
+ * Fill the buffer memory and send the contents of the transmit buffer
+ * onto the network
+ */
+static void enc28j60_hw_tx(struct enc28j60_net *priv)
+{
+	if (netif_msg_tx_queued(priv))
+		printk(KERN_DEBUG DRV_NAME
+			": Tx Packet Len:%d\n", priv->tx_skb->len);
+
+	if (netif_msg_pktdata(priv))
+		dump_packet(__FUNCTION__,
+			    priv->tx_skb->len, priv->tx_skb->data);
+	enc28j60_packet_write(priv, priv->tx_skb->len, priv->tx_skb->data);
+
+#ifdef CONFIG_ENC28J60_WRITEVERIFY
+	/* readback and verify written data */
+	if (netif_msg_drv(priv)) {
+		int test_len, k;
+		u8 test_buf[64]; /* limit the test to the first 64 bytes */
+		int okflag;
+
+		test_len = priv->tx_skb->len;
+		if (test_len > sizeof(test_buf))
+			test_len = sizeof(test_buf);
+
+		/* + 1 to skip control byte */
+		enc28j60_mem_read(priv, TXSTART_INIT + 1, test_len, test_buf);
+		okflag = 1;
+		for (k = 0; k < test_len; k++) {
+			if (priv->tx_skb->data[k] != test_buf[k]) {
+				printk(KERN_DEBUG DRV_NAME
+					 ": Error, %d location differ: "
+					 "0x%02x-0x%02x\n", k,
+					 priv->tx_skb->data[k], test_buf[k]);
+				okflag = 0;
+			}
+		}
+		if (!okflag)
+			printk(KERN_DEBUG DRV_NAME ": Tx write buffer, "
+				"verify ERROR!\n");
+	}
+#endif
+	/* set TX request flag */
+	locked_reg_bfset(priv, ECON1, ECON1_TXRTS);
+}
+
+static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct enc28j60_net *priv = netdev_priv(dev);
+
+	if (netif_msg_tx_queued(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+
+	/* If some error occurs while trying to transmit this
+	 * packet, you should return '1' from this function.
+	 * In such a case you _may not_ do anything to the
+	 * SKB, it is still owned by the network queueing
+	 * layer when an error is returned.  This means you
+	 * may not modify any SKB fields, you may not free
+	 * the SKB, etc.
+	 */
+	netif_stop_queue(dev);
+
+	/* save the timestamp */
+	priv->netdev->trans_start = jiffies;
+	/* Remember the skb for deferred processing */
+	priv->tx_skb = skb;
+	schedule_work(&priv->tx_work);
+
+	return 0;
+}
+
+static void enc28j60_tx_work_handler(struct work_struct *work)
+{
+	struct enc28j60_net *priv =
+		container_of(work, struct enc28j60_net, tx_work);
+
+	/* actual delivery of data */
+	enc28j60_hw_tx(priv);
+}
+
+static irqreturn_t enc28j60_irq(int irq, void *dev_id)
+{
+	struct enc28j60_net *priv = dev_id;
+
+	/*
+	 * Can't do anything in interrupt context because we need to
+	 * block (spi_sync() is blocking) so fire of the interrupt
+	 * handling workqueue.
+	 * Remember that we access enc28j60 registers through SPI bus
+	 * via spi_sync() call.
+	 */
+	schedule_work(&priv->irq_work);
+
+	return IRQ_HANDLED;
+}
+
+static void enc28j60_tx_timeout(struct net_device *ndev)
+{
+	struct enc28j60_net *priv = netdev_priv(ndev);
+
+	if (netif_msg_timer(priv))
+		dev_err(&ndev->dev, DRV_NAME " tx timeout\n");
+
+	ndev->stats.tx_errors++;
+	/* can't restart safely under softirq */
+	schedule_work(&priv->restart_work);
+}
+
+/*
+ * Open/initialize the board. This is called (in the current kernel)
+ * sometime after booting when the 'ifconfig' program is run.
+ *
+ * This routine should set everything up anew at each open, even
+ * registers that "should" only need to be set once at boot, so that
+ * there is non-reboot way to recover if something goes wrong.
+ */
+static int enc28j60_net_open(struct net_device *dev)
+{
+	struct enc28j60_net *priv = netdev_priv(dev);
+
+	if (netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		if (netif_msg_ifup(priv)) {
+			DECLARE_MAC_BUF(mac);
+			dev_err(&dev->dev, "invalid MAC address %s\n",
+				print_mac(mac, dev->dev_addr));
+		}
+		return -EADDRNOTAVAIL;
+	}
+	/* Reset the hardware here */
+	enc28j60_hw_disable(priv);
+	if (!enc28j60_hw_init(priv)) {
+		if (netif_msg_ifup(priv))
+			dev_err(&dev->dev, "hw_reset() failed\n");
+		return -EINVAL;
+	}
+	/* Update the MAC address (in case user has changed it) */
+	enc28j60_set_hw_macaddr(dev);
+	/* Enable interrupts */
+	enc28j60_hw_enable(priv);
+	/* check link status */
+	enc28j60_check_link_status(dev);
+	/* We are now ready to accept transmit requests from
+	 * the queueing layer of the networking.
+	 */
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+/* The inverse routine to net_open(). */
+static int enc28j60_net_close(struct net_device *dev)
+{
+	struct enc28j60_net *priv = netdev_priv(dev);
+
+	if (netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+
+	enc28j60_hw_disable(priv);
+	netif_stop_queue(dev);
+
+	return 0;
+}
+
+/*
+ * Set or clear the multicast filter for this adapter
+ * num_addrs == -1	Promiscuous mode, receive all packets
+ * num_addrs == 0	Normal mode, filter out multicast packets
+ * num_addrs > 0	Multicast mode, receive normal and MC packets
+ */
+static void enc28j60_set_multicast_list(struct net_device *dev)
+{
+	struct enc28j60_net *priv = netdev_priv(dev);
+	int oldfilter = priv->rxfilter;
+
+	if (dev->flags & IFF_PROMISC) {
+		if (netif_msg_link(priv))
+			dev_info(&dev->dev, "promiscuous mode\n");
+		priv->rxfilter = RXFILTER_PROMISC;
+	} else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count) {
+		if (netif_msg_link(priv))
+			dev_info(&dev->dev, "%smulticast mode\n",
+				(dev->flags & IFF_ALLMULTI) ? "all-" : "");
+		priv->rxfilter = RXFILTER_MULTI;
+	} else {
+		if (netif_msg_link(priv))
+			dev_info(&dev->dev, "normal mode\n");
+		priv->rxfilter = RXFILTER_NORMAL;
+	}
+
+	if (oldfilter != priv->rxfilter)
+		schedule_work(&priv->setrx_work);
+}
+
+static void enc28j60_setrx_work_handler(struct work_struct *work)
+{
+	struct enc28j60_net *priv =
+		container_of(work, struct enc28j60_net, setrx_work);
+
+	if (priv->rxfilter == RXFILTER_PROMISC) {
+		if (netif_msg_drv(priv))
+			printk(KERN_DEBUG DRV_NAME ": promiscuous mode\n");
+		locked_regb_write(priv, ERXFCON, 0x00);
+	} else if (priv->rxfilter == RXFILTER_MULTI) {
+		if (netif_msg_drv(priv))
+			printk(KERN_DEBUG DRV_NAME ": multicast mode\n");
+		locked_regb_write(priv, ERXFCON,
+					ERXFCON_UCEN | ERXFCON_CRCEN |
+					ERXFCON_BCEN | ERXFCON_MCEN);
+	} else {
+		if (netif_msg_drv(priv))
+			printk(KERN_DEBUG DRV_NAME ": normal mode\n");
+		locked_regb_write(priv, ERXFCON,
+					ERXFCON_UCEN | ERXFCON_CRCEN |
+					ERXFCON_BCEN);
+	}
+}
+
+static void enc28j60_restart_work_handler(struct work_struct *work)
+{
+	struct enc28j60_net *priv =
+			container_of(work, struct enc28j60_net, restart_work);
+	struct net_device *ndev = priv->netdev;
+	int ret;
+
+	rtnl_lock();
+	if (netif_running(ndev)) {
+		enc28j60_net_close(ndev);
+		ret = enc28j60_net_open(ndev);
+		if (unlikely(ret)) {
+			dev_info(&ndev->dev, " could not restart %d\n", ret);
+			dev_close(ndev);
+		}
+	}
+	rtnl_unlock();
+}
+
+/* ......................... ETHTOOL SUPPORT ........................... */
+
+static void
+enc28j60_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info,
+		dev->dev.parent->bus_id, sizeof(info->bus_info));
+}
+
+static int
+enc28j60_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct enc28j60_net *priv = netdev_priv(dev);
+
+	cmd->transceiver = XCVR_INTERNAL;
+	cmd->supported	= SUPPORTED_10baseT_Half
+			| SUPPORTED_10baseT_Full
+			| SUPPORTED_TP;
+	cmd->speed	= SPEED_10;
+	cmd->duplex	= priv->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
+	cmd->port	= PORT_TP;
+	cmd->autoneg	= AUTONEG_DISABLE;
+
+	return 0;
+}
+
+static int
+enc28j60_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	return enc28j60_setlink(dev, cmd->autoneg, cmd->speed, cmd->duplex);
+}
+
+static u32 enc28j60_get_msglevel(struct net_device *dev)
+{
+	struct enc28j60_net *priv = netdev_priv(dev);
+	return priv->msg_enable;
+}
+
+static void enc28j60_set_msglevel(struct net_device *dev, u32 val)
+{
+	struct enc28j60_net *priv = netdev_priv(dev);
+	priv->msg_enable = val;
+}
+
+static const struct ethtool_ops enc28j60_ethtool_ops = {
+	.get_settings	= enc28j60_get_settings,
+	.set_settings	= enc28j60_set_settings,
+	.get_drvinfo	= enc28j60_get_drvinfo,
+	.get_msglevel	= enc28j60_get_msglevel,
+	.set_msglevel	= enc28j60_set_msglevel,
+};
+
+static int enc28j60_chipset_init(struct net_device *dev)
+{
+	struct enc28j60_net *priv = netdev_priv(dev);
+
+	return enc28j60_hw_init(priv);
+}
+
+static int __devinit enc28j60_probe(struct spi_device *spi)
+{
+	struct net_device *dev;
+	struct enc28j60_net *priv;
+	int ret = 0;
+
+	if (netif_msg_drv(&debug))
+		dev_info(&spi->dev, DRV_NAME " Ethernet driver %s loaded\n",
+			DRV_VERSION);
+
+	dev = alloc_etherdev(sizeof(struct enc28j60_net));
+	if (!dev) {
+		if (netif_msg_drv(&debug))
+			dev_err(&spi->dev, DRV_NAME
+				": unable to alloc new ethernet\n");
+		ret = -ENOMEM;
+		goto error_alloc;
+	}
+	priv = netdev_priv(dev);
+
+	priv->netdev = dev;	/* priv to netdev reference */
+	priv->spi = spi;	/* priv to spi reference */
+	priv->msg_enable = netif_msg_init(debug.msg_enable,
+						ENC28J60_MSG_DEFAULT);
+	mutex_init(&priv->lock);
+	INIT_WORK(&priv->tx_work, enc28j60_tx_work_handler);
+	INIT_WORK(&priv->setrx_work, enc28j60_setrx_work_handler);
+	INIT_WORK(&priv->irq_work, enc28j60_irq_work_handler);
+	INIT_WORK(&priv->restart_work, enc28j60_restart_work_handler);
+	dev_set_drvdata(&spi->dev, priv);	/* spi to priv reference */
+	SET_NETDEV_DEV(dev, &spi->dev);
+
+	if (!enc28j60_chipset_init(dev)) {
+		if (netif_msg_probe(priv))
+			dev_info(&spi->dev, DRV_NAME " chip not found\n");
+		ret = -EIO;
+		goto error_irq;
+	}
+	random_ether_addr(dev->dev_addr);
+	enc28j60_set_hw_macaddr(dev);
+
+	ret = request_irq(spi->irq, enc28j60_irq, IRQF_TRIGGER_FALLING,
+			  DRV_NAME, priv);
+	if (ret < 0) {
+		if (netif_msg_probe(priv))
+			dev_err(&spi->dev, DRV_NAME ": request irq %d failed "
+				"(ret = %d)\n", spi->irq, ret);
+		goto error_irq;
+	}
+
+	dev->if_port = IF_PORT_10BASET;
+	dev->irq = spi->irq;
+	dev->open = enc28j60_net_open;
+	dev->stop = enc28j60_net_close;
+	dev->hard_start_xmit = enc28j60_send_packet;
+	dev->set_multicast_list = &enc28j60_set_multicast_list;
+	dev->set_mac_address = enc28j60_set_mac_address;
+	dev->tx_timeout = &enc28j60_tx_timeout;
+	dev->watchdog_timeo = TX_TIMEOUT;
+	SET_ETHTOOL_OPS(dev, &enc28j60_ethtool_ops);
+
+	ret = register_netdev(dev);
+	if (ret) {
+		if (netif_msg_probe(priv))
+			dev_err(&spi->dev, "register netdev " DRV_NAME
+				" failed (ret = %d)\n", ret);
+		goto error_register;
+	}
+	dev_info(&dev->dev, DRV_NAME " driver registered\n");
+
+	return 0;
+
+error_register:
+	free_irq(spi->irq, priv);
+error_irq:
+	free_netdev(dev);
+error_alloc:
+	return ret;
+}
+
+static int enc28j60_remove(struct spi_device *spi)
+{
+	struct enc28j60_net *priv = dev_get_drvdata(&spi->dev);
+
+	if (netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": remove\n");
+
+	unregister_netdev(priv->netdev);
+	free_irq(spi->irq, priv);
+	free_netdev(priv->netdev);
+
+	return 0;
+}
+
+static struct spi_driver enc28j60_driver = {
+	.driver = {
+		   .name = DRV_NAME,
+		   .bus = &spi_bus_type,
+		   .owner = THIS_MODULE,
+		   },
+	.probe = enc28j60_probe,
+	.remove = __devexit_p(enc28j60_remove),
+};
+
+static int __init enc28j60_init(void)
+{
+	return spi_register_driver(&enc28j60_driver);
+}
+
+module_init(enc28j60_init);
+
+static void __exit enc28j60_exit(void)
+{
+	spi_unregister_driver(&enc28j60_driver);
+}
+
+module_exit(enc28j60_exit);
+
+MODULE_DESCRIPTION(DRV_NAME " ethernet driver");
+MODULE_AUTHOR("Claudio Lanconelli <lanconelli.claudio@eptar.com>");
+MODULE_LICENSE("GPL");
+module_param_named(debug, debug.msg_enable, int, 0);
+MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., ffff=all)");
diff --git a/drivers/net/enc28j60_hw.h b/drivers/net/enc28j60_hw.h
new file mode 100644
index 0000000..1a0b209
--- /dev/null
+++ b/drivers/net/enc28j60_hw.h
@@ -0,0 +1,309 @@
+/*
+ * enc28j60_hw.h: EDTP FrameThrower style enc28j60 registers
+ *
+ * $Id: enc28j60_hw.h,v 1.9 2007/12/14 11:59:16 claudio Exp $
+ */
+
+#ifndef _ENC28J60_HW_H
+#define _ENC28J60_HW_H
+
+/*
+ * ENC28J60 Control Registers
+ * Control register definitions are a combination of address,
+ * bank number, and Ethernet/MAC/PHY indicator bits.
+ * - Register address	(bits 0-4)
+ * - Bank number	(bits 5-6)
+ * - MAC/MII indicator	(bit 7)
+ */
+#define ADDR_MASK	0x1F
+#define BANK_MASK	0x60
+#define SPRD_MASK	0x80
+/* All-bank registers */
+#define EIE		0x1B
+#define EIR		0x1C
+#define ESTAT		0x1D
+#define ECON2		0x1E
+#define ECON1		0x1F
+/* Bank 0 registers */
+#define ERDPTL		(0x00|0x00)
+#define ERDPTH		(0x01|0x00)
+#define EWRPTL		(0x02|0x00)
+#define EWRPTH		(0x03|0x00)
+#define ETXSTL		(0x04|0x00)
+#define ETXSTH		(0x05|0x00)
+#define ETXNDL		(0x06|0x00)
+#define ETXNDH		(0x07|0x00)
+#define ERXSTL		(0x08|0x00)
+#define ERXSTH		(0x09|0x00)
+#define ERXNDL		(0x0A|0x00)
+#define ERXNDH		(0x0B|0x00)
+#define ERXRDPTL	(0x0C|0x00)
+#define ERXRDPTH	(0x0D|0x00)
+#define ERXWRPTL	(0x0E|0x00)
+#define ERXWRPTH	(0x0F|0x00)
+#define EDMASTL		(0x10|0x00)
+#define EDMASTH		(0x11|0x00)
+#define EDMANDL		(0x12|0x00)
+#define EDMANDH		(0x13|0x00)
+#define EDMADSTL	(0x14|0x00)
+#define EDMADSTH	(0x15|0x00)
+#define EDMACSL		(0x16|0x00)
+#define EDMACSH		(0x17|0x00)
+/* Bank 1 registers */
+#define EHT0		(0x00|0x20)
+#define EHT1		(0x01|0x20)
+#define EHT2		(0x02|0x20)
+#define EHT3		(0x03|0x20)
+#define EHT4		(0x04|0x20)
+#define EHT5		(0x05|0x20)
+#define EHT6		(0x06|0x20)
+#define EHT7		(0x07|0x20)
+#define EPMM0		(0x08|0x20)
+#define EPMM1		(0x09|0x20)
+#define EPMM2		(0x0A|0x20)
+#define EPMM3		(0x0B|0x20)
+#define EPMM4		(0x0C|0x20)
+#define EPMM5		(0x0D|0x20)
+#define EPMM6		(0x0E|0x20)
+#define EPMM7		(0x0F|0x20)
+#define EPMCSL		(0x10|0x20)
+#define EPMCSH		(0x11|0x20)
+#define EPMOL		(0x14|0x20)
+#define EPMOH		(0x15|0x20)
+#define EWOLIE		(0x16|0x20)
+#define EWOLIR		(0x17|0x20)
+#define ERXFCON		(0x18|0x20)
+#define EPKTCNT		(0x19|0x20)
+/* Bank 2 registers */
+#define MACON1		(0x00|0x40|SPRD_MASK)
+/* #define MACON2	(0x01|0x40|SPRD_MASK) */
+#define MACON3		(0x02|0x40|SPRD_MASK)
+#define MACON4		(0x03|0x40|SPRD_MASK)
+#define MABBIPG		(0x04|0x40|SPRD_MASK)
+#define MAIPGL		(0x06|0x40|SPRD_MASK)
+#define MAIPGH		(0x07|0x40|SPRD_MASK)
+#define MACLCON1	(0x08|0x40|SPRD_MASK)
+#define MACLCON2	(0x09|0x40|SPRD_MASK)
+#define MAMXFLL		(0x0A|0x40|SPRD_MASK)
+#define MAMXFLH		(0x0B|0x40|SPRD_MASK)
+#define MAPHSUP		(0x0D|0x40|SPRD_MASK)
+#define MICON		(0x11|0x40|SPRD_MASK)
+#define MICMD		(0x12|0x40|SPRD_MASK)
+#define MIREGADR	(0x14|0x40|SPRD_MASK)
+#define MIWRL		(0x16|0x40|SPRD_MASK)
+#define MIWRH		(0x17|0x40|SPRD_MASK)
+#define MIRDL		(0x18|0x40|SPRD_MASK)
+#define MIRDH		(0x19|0x40|SPRD_MASK)
+/* Bank 3 registers */
+#define MAADR1		(0x00|0x60|SPRD_MASK)
+#define MAADR0		(0x01|0x60|SPRD_MASK)
+#define MAADR3		(0x02|0x60|SPRD_MASK)
+#define MAADR2		(0x03|0x60|SPRD_MASK)
+#define MAADR5		(0x04|0x60|SPRD_MASK)
+#define MAADR4		(0x05|0x60|SPRD_MASK)
+#define EBSTSD		(0x06|0x60)
+#define EBSTCON		(0x07|0x60)
+#define EBSTCSL		(0x08|0x60)
+#define EBSTCSH		(0x09|0x60)
+#define MISTAT		(0x0A|0x60|SPRD_MASK)
+#define EREVID		(0x12|0x60)
+#define ECOCON		(0x15|0x60)
+#define EFLOCON		(0x17|0x60)
+#define EPAUSL		(0x18|0x60)
+#define EPAUSH		(0x19|0x60)
+/* PHY registers */
+#define PHCON1		0x00
+#define PHSTAT1		0x01
+#define PHHID1		0x02
+#define PHHID2		0x03
+#define PHCON2		0x10
+#define PHSTAT2		0x11
+#define PHIE		0x12
+#define PHIR		0x13
+#define PHLCON		0x14
+
+/* ENC28J60 EIE Register Bit Definitions */
+#define EIE_INTIE	0x80
+#define EIE_PKTIE	0x40
+#define EIE_DMAIE	0x20
+#define EIE_LINKIE	0x10
+#define EIE_TXIE	0x08
+/* #define EIE_WOLIE	0x04 (reserved) */
+#define EIE_TXERIE	0x02
+#define EIE_RXERIE	0x01
+/* ENC28J60 EIR Register Bit Definitions */
+#define EIR_PKTIF	0x40
+#define EIR_DMAIF	0x20
+#define EIR_LINKIF	0x10
+#define EIR_TXIF	0x08
+/* #define EIR_WOLIF	0x04 (reserved) */
+#define EIR_TXERIF	0x02
+#define EIR_RXERIF	0x01
+/* ENC28J60 ESTAT Register Bit Definitions */
+#define ESTAT_INT	0x80
+#define ESTAT_LATECOL	0x10
+#define ESTAT_RXBUSY	0x04
+#define ESTAT_TXABRT	0x02
+#define ESTAT_CLKRDY	0x01
+/* ENC28J60 ECON2 Register Bit Definitions */
+#define ECON2_AUTOINC	0x80
+#define ECON2_PKTDEC	0x40
+#define ECON2_PWRSV	0x20
+#define ECON2_VRPS	0x08
+/* ENC28J60 ECON1 Register Bit Definitions */
+#define ECON1_TXRST	0x80
+#define ECON1_RXRST	0x40
+#define ECON1_DMAST	0x20
+#define ECON1_CSUMEN	0x10
+#define ECON1_TXRTS	0x08
+#define ECON1_RXEN	0x04
+#define ECON1_BSEL1	0x02
+#define ECON1_BSEL0	0x01
+/* ENC28J60 MACON1 Register Bit Definitions */
+#define MACON1_LOOPBK	0x10
+#define MACON1_TXPAUS	0x08
+#define MACON1_RXPAUS	0x04
+#define MACON1_PASSALL	0x02
+#define MACON1_MARXEN	0x01
+/* ENC28J60 MACON2 Register Bit Definitions */
+#define MACON2_MARST	0x80
+#define MACON2_RNDRST	0x40
+#define MACON2_MARXRST	0x08
+#define MACON2_RFUNRST	0x04
+#define MACON2_MATXRST	0x02
+#define MACON2_TFUNRST	0x01
+/* ENC28J60 MACON3 Register Bit Definitions */
+#define MACON3_PADCFG2	0x80
+#define MACON3_PADCFG1	0x40
+#define MACON3_PADCFG0	0x20
+#define MACON3_TXCRCEN	0x10
+#define MACON3_PHDRLEN	0x08
+#define MACON3_HFRMLEN	0x04
+#define MACON3_FRMLNEN	0x02
+#define MACON3_FULDPX	0x01
+/* ENC28J60 MICMD Register Bit Definitions */
+#define MICMD_MIISCAN	0x02
+#define MICMD_MIIRD	0x01
+/* ENC28J60 MISTAT Register Bit Definitions */
+#define MISTAT_NVALID	0x04
+#define MISTAT_SCAN	0x02
+#define MISTAT_BUSY	0x01
+/* ENC28J60 ERXFCON Register Bit Definitions */
+#define ERXFCON_UCEN	0x80
+#define ERXFCON_ANDOR	0x40
+#define ERXFCON_CRCEN	0x20
+#define ERXFCON_PMEN	0x10
+#define ERXFCON_MPEN	0x08
+#define ERXFCON_HTEN	0x04
+#define ERXFCON_MCEN	0x02
+#define ERXFCON_BCEN	0x01
+
+/* ENC28J60 PHY PHCON1 Register Bit Definitions */
+#define PHCON1_PRST	0x8000
+#define PHCON1_PLOOPBK	0x4000
+#define PHCON1_PPWRSV	0x0800
+#define PHCON1_PDPXMD	0x0100
+/* ENC28J60 PHY PHSTAT1 Register Bit Definitions */
+#define PHSTAT1_PFDPX	0x1000
+#define PHSTAT1_PHDPX	0x0800
+#define PHSTAT1_LLSTAT	0x0004
+#define PHSTAT1_JBSTAT	0x0002
+/* ENC28J60 PHY PHSTAT2 Register Bit Definitions */
+#define PHSTAT2_TXSTAT	(1 << 13)
+#define PHSTAT2_RXSTAT	(1 << 12)
+#define PHSTAT2_COLSTAT	(1 << 11)
+#define PHSTAT2_LSTAT	(1 << 10)
+#define PHSTAT2_DPXSTAT	(1 << 9)
+#define PHSTAT2_PLRITY	(1 << 5)
+/* ENC28J60 PHY PHCON2 Register Bit Definitions */
+#define PHCON2_FRCLINK	0x4000
+#define PHCON2_TXDIS	0x2000
+#define PHCON2_JABBER	0x0400
+#define PHCON2_HDLDIS	0x0100
+/* ENC28J60 PHY PHIE Register Bit Definitions */
+#define PHIE_PLNKIE	(1 << 4)
+#define PHIE_PGEIE	(1 << 1)
+/* ENC28J60 PHY PHIR Register Bit Definitions */
+#define PHIR_PLNKIF	(1 << 4)
+#define PHIR_PGEIF	(1 << 1)
+
+/* ENC28J60 Packet Control Byte Bit Definitions */
+#define PKTCTRL_PHUGEEN		0x08
+#define PKTCTRL_PPADEN		0x04
+#define PKTCTRL_PCRCEN		0x02
+#define PKTCTRL_POVERRIDE	0x01
+
+/* ENC28J60 Transmit Status Vector */
+#define TSV_TXBYTECNT		0
+#define TSV_TXCOLLISIONCNT	16
+#define TSV_TXCRCERROR		20
+#define TSV_TXLENCHKERROR	21
+#define TSV_TXLENOUTOFRANGE	22
+#define TSV_TXDONE		23
+#define TSV_TXMULTICAST		24
+#define TSV_TXBROADCAST		25
+#define TSV_TXPACKETDEFER	26
+#define TSV_TXEXDEFER		27
+#define TSV_TXEXCOLLISION	28
+#define TSV_TXLATECOLLISION	29
+#define TSV_TXGIANT		30
+#define TSV_TXUNDERRUN		31
+#define TSV_TOTBYTETXONWIRE	32
+#define TSV_TXCONTROLFRAME	48
+#define TSV_TXPAUSEFRAME	49
+#define TSV_BACKPRESSUREAPP	50
+#define TSV_TXVLANTAGFRAME	51
+
+#define TSV_SIZE		7
+#define TSV_BYTEOF(x)		((x) / 8)
+#define TSV_BITMASK(x)		(1 << ((x) % 8))
+#define TSV_GETBIT(x, y)	(((x)[TSV_BYTEOF(y)] & TSV_BITMASK(y)) ? 1 : 0)
+
+/* ENC28J60 Receive Status Vector */
+#define RSV_RXLONGEVDROPEV	16
+#define RSV_CARRIEREV		18
+#define RSV_CRCERROR		20
+#define RSV_LENCHECKERR		21
+#define RSV_LENOUTOFRANGE	22
+#define RSV_RXOK		23
+#define RSV_RXMULTICAST		24
+#define RSV_RXBROADCAST		25
+#define RSV_DRIBBLENIBBLE	26
+#define RSV_RXCONTROLFRAME	27
+#define RSV_RXPAUSEFRAME	28
+#define RSV_RXUNKNOWNOPCODE	29
+#define RSV_RXTYPEVLAN		30
+
+#define RSV_SIZE		6
+#define RSV_BITMASK(x)		(1 << ((x) - 16))
+#define RSV_GETBIT(x, y)	(((x) & RSV_BITMASK(y)) ? 1 : 0)
+
+
+/* SPI operation codes */
+#define ENC28J60_READ_CTRL_REG	0x00
+#define ENC28J60_READ_BUF_MEM	0x3A
+#define ENC28J60_WRITE_CTRL_REG 0x40
+#define ENC28J60_WRITE_BUF_MEM	0x7A
+#define ENC28J60_BIT_FIELD_SET	0x80
+#define ENC28J60_BIT_FIELD_CLR	0xA0
+#define ENC28J60_SOFT_RESET	0xFF
+
+
+/* buffer boundaries applied to internal 8K ram
+ * entire available packet buffer space is allocated.
+ * Give TX buffer space for one full ethernet frame (~1500 bytes)
+ * receive buffer gets the rest */
+#define TXSTART_INIT		0x1A00
+#define TXEND_INIT		0x1FFF
+
+/* Put RX buffer at 0 as suggested by the Errata datasheet */
+#define RXSTART_INIT		0x0000
+#define RXEND_INIT		0x19FF
+
+/* maximum ethernet frame length */
+#define MAX_FRAMELEN		1518
+
+/* Prefered half duplex: LEDA: Link status LEDB: Rx/Tx activity */
+#define ENC28J60_LAMPS_MODE	0x3476
+
+#endif
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d9107e5..3e196cf 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -922,6 +922,24 @@ config DM9000
 	  To compile this driver as a module, choose M here.  The module
 	  will be called dm9000.
 
+config ENC28J60
+	tristate "ENC28J60 support"
+	depends on EXPERIMENTAL && SPI && NET_ETHERNET
+	select CRC32
+	---help---
+	  Support for the Microchip EN28J60 ethernet chip.
+
+	  To compile this driver as a module, choose M here and read
+	  <file:Documentation/networking/net-modules.txt>.  The module will be
+	  called enc28j60.
+
+config ENC28J60_WRITEVERIFY
+	bool "Enable write verify"
+	depends on ENC28J60
+	---help---
+	  Enable the verify after the buffer write useful for debugging purpose.
+	  If unsure, say N.
+
 config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0e5fde4..e91e3a3 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -216,6 +216,7 @@ obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_FEC_8XX) += fec_8xx/
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o
 obj-$(CONFIG_MLX4_CORE) += mlx4/
+obj-$(CONFIG_ENC28J60) += enc28j60.o
 
 obj-$(CONFIG_MACB) += macb.o
 


--------------030809000904040700020206--

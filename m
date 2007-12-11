From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: [PATCH 1/2] add driver for enc28j60 ethernet chip
Date: Tue, 11 Dec 2007 15:57:10 +0100
Message-ID: <475EA546.7030202@eptar.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060005040304050407010904"
Cc: jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay03.albacom.net ([217.220.57.137]:54490 "EHLO
	fe-relay03.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbXLKPD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 10:03:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060005040304050407010904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

These patches add support for Microchip enc28j60 ethernet chip 
controlled via SPI.
I tested it on my custom board (S162) with ARM9 s3c2442 SoC.
Any comments are welcome.

Signed-off-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>

--------------060005040304050407010904
Content-Type: text/x-patch;
 name="enc28j60_p1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="enc28j60_p1.diff"

 drivers/net/enc28j60.c    | 1400 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/enc28j60_hw.h |  303 ++++++++++
 2 files changed, 1703 insertions(+), 0 deletions(-)

diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
new file mode 100644
index 0000000..6182473
--- /dev/null
+++ b/drivers/net/enc28j60.c
@@ -0,0 +1,1400 @@
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
+ * $Id: enc28j60.c,v 1.10 2007/12/10 16:59:37 claudio Exp $
+ */
+
+#include <linux/autoconf.h>
+
+#if CONFIG_ENC28J60_DBGLEVEL > 1
+# define VERBOSE_DEBUG
+#endif
+#if CONFIG_ENC28J60_DBGLEVEL > 0
+# define DEBUG
+#endif
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/fcntl.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/spinlock.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/spi/spi.h>
+#include <asm/semaphore.h>
+
+#include "enc28j60_hw.h"
+
+/* Buffer size required for the largest SPI transfer (i.e., reading a
+ * frame). */
+#define SPI_TRANSFER_BUF_LEN	(4 + MAX_FRAMELEN)
+
+#define MY_TX_TIMEOUT  ((500*HZ)/1000)
+
+/* Max TX retries in case of collision as suggested by errata datasheet */
+#define MAX_TX_RETRYCOUNT	16
+
+/* Driver local data */
+struct enc28j60_net_local {
+	struct net_device_stats stats;
+
+	struct net_device *netdev;
+	struct spi_device *spi;
+	struct semaphore semlock;	/* protect spi_transfer_buf */
+	uint8_t *spi_transfer_buf;
+	struct sk_buff *tx_skb;
+	struct work_struct tx_work;
+	struct work_struct irq_work;
+	int bank;			/* current register bank selected */
+	uint16_t next_pk_ptr;		/* next packet pointer within FIFO */
+	int max_pk_counter;		/* statistics: max packet counter */
+	int tx_retry_count;
+	int hw_enable;
+};
+
+/* Selects Full duplex vs. Half duplex mode */
+static int full_duplex = 0;
+
+static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev);
+static int enc28j60_net_close(struct net_device *dev);
+static struct net_device_stats *enc28j60_net_get_stats(struct net_device *dev);
+static void enc28j60_set_multicast_list(struct net_device *dev);
+static void enc28j60_net_tx_timeout(struct net_device *ndev);
+
+static int enc28j60_chipset_init(struct net_device *dev);
+static void enc28j60_hw_disable(struct enc28j60_net_local *priv);
+static void enc28j60_hw_enable(struct enc28j60_net_local *priv);
+static void enc28j60_hw_rx(struct enc28j60_net_local *priv);
+static void enc28j60_hw_tx(struct enc28j60_net_local *priv);
+
+/* Basic SPI operations */
+static int spi_read_buf(struct enc28j60_net_local *priv, int len,
+			uint8_t *data);
+static int spi_write_buf(struct enc28j60_net_local *priv, int len,
+			const uint8_t * data);
+static uint8_t spi_read_op(struct enc28j60_net_local *priv, uint8_t op,
+			uint8_t addr);
+static int spi_write_op(struct enc28j60_net_local *priv, uint8_t op,
+			uint8_t addr, uint8_t val);
+
+/* Low level routines */
+
+/* utility function for register access routines */
+static void enc28j60_set_bank(struct enc28j60_net_local *priv, uint8_t address);
+
+static inline int enc28j60_regb_read(struct enc28j60_net_local *priv,
+					uint8_t address);
+static inline int enc28j60_regw_read(struct enc28j60_net_local *priv,
+					uint8_t address);
+static inline void enc28j60_regb_write(struct enc28j60_net_local *priv,
+					uint8_t address, uint8_t data);
+static inline void enc28j60_regw_write(struct enc28j60_net_local *priv,
+					uint8_t address, uint16_t data);
+
+static inline void enc28j60_reg_bfset(struct enc28j60_net_local *priv,
+					uint8_t reg, uint8_t mask);
+static inline void enc28j60_reg_bfclr(struct enc28j60_net_local *priv,
+					uint8_t reg, uint8_t mask);
+
+static void enc28j60_soft_reset(struct enc28j60_net_local *priv);
+
+/* debug routines */
+static void dump_packet(struct enc28j60_net_local *priv, const char *msg,
+			int len, const char *data);
+static void enc28j60_dump_tsv(struct enc28j60_net_local *priv, const char *msg,
+			uint8_t tsv[TSV_SIZE]);
+static void enc28j60_dump_rsv(struct enc28j60_net_local *priv, const char *msg,
+			uint16_t pk_ptr, int len, uint16_t sts);
+static void enc28j60_dump_regs(struct enc28j60_net_local *priv,
+			const char *msg);
+
+/*
+ * SPI read buffer
+ * wait for the SPI transfer and copy received data to destination
+ */
+static int
+spi_read_buf(struct enc28j60_net_local *priv, int len, uint8_t *data)
+{
+	uint8_t *rx_buf;
+	uint8_t *tx_buf;
+	struct spi_transfer t;
+	struct spi_message msg;
+	int ret, slen;
+
+	slen = 1;
+	memset(&t, 0, sizeof(t));
+	t.tx_buf = tx_buf = priv->spi_transfer_buf;
+	t.rx_buf = rx_buf = priv->spi_transfer_buf + 4;
+	t.len = slen + len;
+
+	down(&priv->semlock);
+	tx_buf[0] = ENC28J60_READ_BUF_MEM;
+	tx_buf[1] = tx_buf[2] = tx_buf[3] = 0;	/* don't care */
+
+	spi_message_init(&msg);
+	spi_message_add_tail(&t, &msg);
+	ret = spi_sync(priv->spi, &msg);
+	if (ret == 0) {
+		memcpy(data, &rx_buf[slen], len);
+		ret = msg.status;
+	}
+	up(&priv->semlock);
+	if (ret != 0)
+		dev_dbg(&priv->netdev->dev, "%s: failed: ret = %d\n",
+			__FUNCTION__, ret);
+
+	return ret;
+}
+
+/*
+ * SPI write buffer
+ */
+static int spi_write_buf(struct enc28j60_net_local *priv, int len,
+			 const uint8_t * data)
+{
+	int ret;
+
+	if (len > SPI_TRANSFER_BUF_LEN - 1 || len <= 0)
+		ret = -EINVAL;
+	else {
+		down(&priv->semlock);
+		priv->spi_transfer_buf[0] = ENC28J60_WRITE_BUF_MEM;
+		memcpy(&priv->spi_transfer_buf[1], data, len);
+		ret = spi_write(priv->spi, priv->spi_transfer_buf, len + 1);
+		up(&priv->semlock);
+		if (ret != 0)
+			dev_dbg(&priv->netdev->dev, "%s: failed: ret = %d\n",
+				__FUNCTION__, ret);
+	}
+	return ret;
+}
+
+/*
+ * basic SPI read operation
+ */
+static uint8_t spi_read_op(struct enc28j60_net_local *priv, uint8_t op,
+			   uint8_t addr)
+{
+	uint8_t tx_buf[2];
+	uint8_t rx_buf[4];
+	uint8_t val = 0;
+	int ret;
+	int slen;
+
+	slen = 1;
+	/* do dummy read if needed */
+	if (addr & SPRD_MASK)
+		slen++;
+
+	tx_buf[0] = op | (addr & ADDR_MASK);
+	ret = spi_write_then_read(priv->spi, tx_buf, 1, rx_buf, slen);
+	if (ret != 0)
+		dev_err(&priv->netdev->dev, "%s: failed: ret = %d\n",
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
+static int spi_write_op(struct enc28j60_net_local *priv, uint8_t op,
+			uint8_t addr, uint8_t val)
+{
+	int ret;
+
+	down(&priv->semlock);
+	priv->spi_transfer_buf[0] = op | (addr & ADDR_MASK);
+	priv->spi_transfer_buf[1] = val;
+	ret = spi_write(priv->spi, priv->spi_transfer_buf, 2);
+	up(&priv->semlock);
+	if (ret != 0)
+		dev_dbg(&priv->netdev->dev, "%s: failed: ret = %d\n",
+			__FUNCTION__, ret);
+	return ret;
+}
+
+/*
+ * Issue a soft reset command
+ */
+static void enc28j60_soft_reset(struct enc28j60_net_local *priv)
+{
+	dev_vdbg(&priv->netdev->dev, "%s\n", __FUNCTION__);
+
+	spi_write_op(priv, ENC28J60_SOFT_RESET, 0, ENC28J60_SOFT_RESET);
+	/* Errata workaround #1, CLKRDY check is unreliable,
+	 * delay 1 mS instead */
+	udelay(1000);
+}
+
+/*
+ * select the current register bank if necessary
+ */
+static void enc28j60_set_bank(struct enc28j60_net_local *priv, uint8_t addr)
+{
+	if ((addr & BANK_MASK) != priv->bank) {
+		uint8_t b = (addr & BANK_MASK) >> 5;
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
+ * Register bit field Set
+ */
+static inline void enc28j60_reg_bfset(struct enc28j60_net_local *priv,
+				      uint8_t addr, uint8_t mask)
+{
+	enc28j60_set_bank(priv, addr);
+	spi_write_op(priv, ENC28J60_BIT_FIELD_SET, addr, mask);
+}
+
+/*
+ * Register bit field Clear
+ */
+static inline void enc28j60_reg_bfclr(struct enc28j60_net_local *priv,
+				      uint8_t addr, uint8_t mask)
+{
+	enc28j60_set_bank(priv, addr);
+	spi_write_op(priv, ENC28J60_BIT_FIELD_CLR, addr, mask);
+}
+
+/*
+ * Register byte read
+ */
+static inline int enc28j60_regb_read(struct enc28j60_net_local *priv,
+				     uint8_t address)
+{
+	enc28j60_set_bank(priv, address);
+	return spi_read_op(priv, ENC28J60_READ_CTRL_REG, address);
+}
+
+/*
+ * Register word read
+ */
+static inline int enc28j60_regw_read(struct enc28j60_net_local *priv,
+				     uint8_t address)
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
+/*
+ * Register byte write
+ */
+static inline void enc28j60_regb_write(struct enc28j60_net_local *priv,
+				       uint8_t address, uint8_t data)
+{
+	enc28j60_set_bank(priv, address);
+	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, address, data);
+}
+
+/*
+ * Register word write
+ */
+static inline void enc28j60_regw_write(struct enc28j60_net_local *priv,
+				       uint8_t address, uint16_t data)
+{
+	enc28j60_set_bank(priv, address);
+	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, address, (uint8_t) data);
+	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, address + 1,
+		     (uint8_t) (data >> 8));
+}
+
+/*
+ * Buffer memory read
+ * Select the starting address and execute a SPI buffer read
+ */
+static inline void enc28j60_mem_read(struct enc28j60_net_local *priv,
+				     uint16_t addr, int len, uint8_t * data)
+{
+	enc28j60_regw_write(priv, ERDPTL, addr);
+
+#ifdef CONFIG_ENC28J60_WRITEVERIFY
+	{
+		uint16_t reg;
+		reg = enc28j60_regw_read(priv, ERDPTL);
+		if (reg != addr) {
+			dev_dbg(&priv->netdev->dev,
+				"%s() error writing ERDPT (0x%04x - 0x%04x)\n",
+				__FUNCTION__, reg, addr);
+		}
+	}
+#endif
+	spi_read_buf(priv, len, data);
+}
+
+/*
+ * Wait until the PHY operation is complete.
+ */
+static inline int wait_phy_ready(struct enc28j60_net_local *priv)
+{
+	unsigned long timeout = jiffies + 20 * HZ / 1000;
+	int ret = 1;
+
+	/* 20msec timeout read */
+	while ((enc28j60_regb_read(priv, MISTAT) & MISTAT_BUSY) != 0) {
+		if (time_after(jiffies, timeout)) {
+			dev_dbg(&priv->netdev->dev,
+				"enc28j60: PHY ready timeout!\n");
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
+ * PHY registers are not accessed directly
+ */
+static uint16_t enc28j60_phy_read(struct enc28j60_net_local *priv,
+				  uint8_t address)
+{
+	/* set the PHY register address */
+	enc28j60_regb_write(priv, MIREGADR, address);
+	/* start the register read operation */
+	enc28j60_regb_write(priv, MICMD, MICMD_MIIRD);
+	udelay(11);
+	/* wait until the PHY read completes */
+	wait_phy_ready(priv);
+	/* quit reading */
+	enc28j60_regb_write(priv, MICMD, 0x00);
+	/* return the data */
+	return enc28j60_regw_read(priv, MIRDL);
+}
+
+static int enc28j60_phy_write(struct enc28j60_net_local *priv, uint8_t address,
+			      uint16_t data)
+{
+	/* set the PHY register address */
+	enc28j60_regb_write(priv, MIREGADR, address);
+	/* write the PHY data */
+	enc28j60_regw_write(priv, MIWRL, data);
+	udelay(11);
+	/* wait until the PHY write completes and return */
+	return wait_phy_ready(priv);
+}
+
+/*
+ * read MAC address registers
+ */
+static void enc28j60_get_hw_macaddr(struct enc28j60_net_local *priv)
+{
+	struct net_device *ndev = priv->netdev;
+
+	/* NOTE: MAC address in ENC28J60 is byte-backward */
+	ndev->dev_addr[0] = enc28j60_regb_read(priv, MAADR5);
+	ndev->dev_addr[1] = enc28j60_regb_read(priv, MAADR4);
+	ndev->dev_addr[2] = enc28j60_regb_read(priv, MAADR3);
+	ndev->dev_addr[3] = enc28j60_regb_read(priv, MAADR2);
+	ndev->dev_addr[4] = enc28j60_regb_read(priv, MAADR1);
+	ndev->dev_addr[5] = enc28j60_regb_read(priv, MAADR0);
+
+	dev_dbg(&priv->spi->dev,
+		"%s() Get MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
+		__FUNCTION__, ndev->dev_addr[0], ndev->dev_addr[1],
+		ndev->dev_addr[2], ndev->dev_addr[3], ndev->dev_addr[4],
+		ndev->dev_addr[5]);
+}
+
+/*
+ * Program the hardware MAC address from dev->dev_addr.
+ */
+static void enc28j60_set_hw_macaddr(struct enc28j60_net_local *priv)
+{
+	struct net_device *ndev = priv->netdev;
+
+	if (!priv->hw_enable) {
+		/* NOTE: MAC address in ENC28J60 is byte-backward */
+		enc28j60_regb_write(priv, MAADR5, ndev->dev_addr[0]);
+		enc28j60_regb_write(priv, MAADR4, ndev->dev_addr[1]);
+		enc28j60_regb_write(priv, MAADR3, ndev->dev_addr[2]);
+		enc28j60_regb_write(priv, MAADR2, ndev->dev_addr[3]);
+		enc28j60_regb_write(priv, MAADR1, ndev->dev_addr[4]);
+		enc28j60_regb_write(priv, MAADR0, ndev->dev_addr[5]);
+
+		dev_dbg(&ndev->dev,
+			"%s() [%s] Setting MAC address to "
+			"%02x:%02x:%02x:%02x:%02x:%02x\n",
+			__FUNCTION__, ndev->name, ndev->dev_addr[0],
+			ndev->dev_addr[1], ndev->dev_addr[2], ndev->dev_addr[3],
+			ndev->dev_addr[4], ndev->dev_addr[5]);
+	} else
+		dev_dbg(&ndev->dev,
+			"%s() Warning: hw must be disabled to set hw "
+			"Mac address\n", __FUNCTION__);
+}
+
+/*
+ * Store the new hardware address in dev->dev_addr, and update the MAC.
+ */
+static int enc28j60_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sockaddr *address = addr;
+	struct enc28j60_net_local *priv = netdev_priv(dev);
+
+	if (!is_valid_ether_addr(address->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, address->sa_data, dev->addr_len);
+	enc28j60_set_hw_macaddr(priv);
+
+	return 0;
+}
+
+static void enc28j60_dump_regs(struct enc28j60_net_local *priv, const char *msg)
+{
+	dev_dbg(&priv->spi->dev, "%s - HwRevID: 0x%02x\n", msg,
+		enc28j60_regb_read(priv, EREVID));
+
+#if CONFIG_ENC28J60_DBGLEVEL > 2
+	printk("Cntrl: ECON1 ECON2 ESTAT  EIR  EIE\n");
+	printk("       0x%02x  ", enc28j60_regb_read(priv, ECON1));
+	printk("0x%02x  ", enc28j60_regb_read(priv, ECON2));
+	printk("0x%02x  ", enc28j60_regb_read(priv, ESTAT));
+	printk("0x%02x  ", enc28j60_regb_read(priv, EIR));
+	printk("0x%02x\n", enc28j60_regb_read(priv, EIE));
+
+	printk("MAC  : MACON1 MACON3 MACON4 MAC-Address\n");
+	printk("       0x%02x   ", enc28j60_regb_read(priv, MACON1));
+	printk("0x%02x   ", enc28j60_regb_read(priv, MACON3));
+	printk("0x%02x   ", enc28j60_regb_read(priv, MACON4));
+	printk("%02x:", enc28j60_regb_read(priv, MAADR5));
+	printk("%02x:", enc28j60_regb_read(priv, MAADR4));
+	printk("%02x:", enc28j60_regb_read(priv, MAADR3));
+	printk("%02x:", enc28j60_regb_read(priv, MAADR2));
+	printk("%02x:", enc28j60_regb_read(priv, MAADR1));
+	printk("%02x\n", enc28j60_regb_read(priv, MAADR0));
+
+	printk("Rx   : ERXST  ERXND  ERXWRPT ERXRDPT ERXFCON EPKTCNT MAMXFL\n");
+	printk("       0x%04x ", enc28j60_regw_read(priv, ERXSTL));
+	printk("0x%04x ", enc28j60_regw_read(priv, ERXNDL));
+	printk("0x%04x  ", enc28j60_regw_read(priv, ERXWRPTL));
+	printk("0x%04x  ", enc28j60_regw_read(priv, ERXRDPTL));
+	printk("0x%02x    ", enc28j60_regb_read(priv, ERXFCON));
+	printk("0x%02x    ", enc28j60_regb_read(priv, EPKTCNT));
+	printk("0x%04x\n", enc28j60_regw_read(priv, MAMXFLL));
+
+	printk("Tx   : ETXST  ETXND  MACLCON1 MACLCON2 MAPHSUP\n");
+	printk("       0x%04x ", enc28j60_regw_read(priv, ETXSTL));
+	printk("0x%04x ", enc28j60_regw_read(priv, ETXNDL));
+	printk("0x%02x     ", enc28j60_regb_read(priv, MACLCON1));
+	printk("0x%02x     ", enc28j60_regb_read(priv, MACLCON2));
+	printk("0x%02x\n", enc28j60_regb_read(priv, MAPHSUP));
+#endif
+}
+
+/*
+ * ERXRDPT need to be set always at odd addresses, refer to errata datasheet
+ */
+static inline uint16_t erxrdpt_workaround(uint16_t next_packet_ptr,
+					  uint16_t start, uint16_t end)
+{
+	uint16_t erxrdpt;
+
+	if ((next_packet_ptr - 1 < start) || (next_packet_ptr - 1 > end)) {
+		erxrdpt = end;
+	} else
+		erxrdpt = next_packet_ptr - 1;
+
+	return erxrdpt;
+}
+
+static void enc28j60_rxfifo_init(struct enc28j60_net_local *priv,
+				 uint16_t start, uint16_t end)
+{
+	uint16_t erxrdpt;
+
+	if (start > 0x1FFF || end > 0x1FFF || start > end)
+		dev_err(&priv->netdev->dev,
+			"%s(%d, %d) RXFIFO bad parameters, fatal error!!\n",
+			__FUNCTION__, start, end);
+
+	priv->next_pk_ptr = start;
+	/* set receive buffer start */
+	enc28j60_regw_write(priv, ERXSTL, start);
+	/* set receive pointer address */
+	erxrdpt = erxrdpt_workaround(priv->next_pk_ptr, start, end);
+	enc28j60_regw_write(priv, ERXRDPTL, erxrdpt);
+	/* set receive buffer end */
+	enc28j60_regw_write(priv, ERXNDL, end);
+}
+
+static void enc28j60_txfifo_init(struct enc28j60_net_local *priv,
+				 uint16_t start, uint16_t end)
+{
+	if (start > 0x1FFF || end > 0x1FFF || start > end)
+		dev_err(&priv->netdev->dev,
+			"%s(%d, %d) TXFIFO bad parameters, fatal error!!\n",
+			__FUNCTION__, start, end);
+
+	/* set transmit buffer start */
+	enc28j60_regw_write(priv, ETXSTL, start);
+	/* set transmit buffer end */
+	enc28j60_regw_write(priv, ETXNDL, end);
+}
+
+static int enc28j60_hw_init(struct enc28j60_net_local *priv)
+{
+	uint8_t reg;
+
+	dev_dbg(&priv->spi->dev, "%s() - %s\n",
+		__FUNCTION__, full_duplex ? "FullDuplex" : "HalfDuplex");
+	/* first soft reset the chip */
+	enc28j60_soft_reset(priv);
+
+	dev_vdbg(&priv->spi->dev, "%s() bank0\n", __FUNCTION__);
+
+	/* Clear ECON1 */
+	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, ECON1, 0x00);
+	priv->bank = 0;
+	priv->hw_enable = 0;
+	priv->tx_retry_count = 0;
+
+	enc28j60_regb_write(priv, ECON2, ECON2_AUTOINC);
+	enc28j60_rxfifo_init(priv, RXSTART_INIT, RXEND_INIT);
+	enc28j60_txfifo_init(priv, TXSTART_INIT, TXEND_INIT);
+
+	/*
+	 * Check the RevID.
+	 * If it's 0x00 or 0xFF probably the enc28j60 is not mounted or
+	 * damaged
+	 */
+	reg = enc28j60_regb_read(priv, EREVID);
+	if (reg == 0x00 || reg == 0xff)
+		return 0;
+
+	dev_vdbg(&priv->spi->dev, "%s() bank1\n", __FUNCTION__);
+
+	/* default filter mode: (unicast OR broadcast) AND crc valid */
+	enc28j60_regb_write(priv, ERXFCON,
+			    ERXFCON_UCEN | ERXFCON_CRCEN | ERXFCON_BCEN);
+
+	dev_vdbg(&priv->spi->dev, "%s() bank2\n", __FUNCTION__);
+	/* enable MAC receive */
+	enc28j60_regb_write(priv, MACON1,
+			    MACON1_MARXEN | MACON1_TXPAUS | MACON1_RXPAUS);
+	/* enable automatic padding and CRC operations */
+	if (full_duplex) {
+		enc28j60_regb_write(priv, MACON3,
+				    MACON3_PADCFG0 | MACON3_TXCRCEN |
+				    MACON3_FRMLNEN | MACON3_FULDPX);
+		/* set inter-frame gap (non-back-to-back) */
+		enc28j60_regb_write(priv, MAIPGL, 0x12);
+		/* set inter-frame gap (back-to-back) */
+		enc28j60_regb_write(priv, MABBIPG, 0x15);
+	} else {
+		enc28j60_regb_write(priv, MACON3,
+				    MACON3_PADCFG0 | MACON3_TXCRCEN |
+				    MACON3_FRMLNEN);
+		enc28j60_regb_write(priv, MACON4, 1 << 6);	/* DEFER bit */
+		/* set inter-frame gap (non-back-to-back) */
+		enc28j60_regw_write(priv, MAIPGL, 0x0C12);
+		/* set inter-frame gap (back-to-back) */
+		enc28j60_regb_write(priv, MABBIPG, 0x12);
+	}
+	/*
+	 * MACLCON1 (default)
+	 * MACLCON2 (default)
+	 * Set the maximum packet size which the controller will accept
+	 */
+	enc28j60_regw_write(priv, MAMXFLL, MAX_FRAMELEN);
+
+	dev_vdbg(&priv->spi->dev, "%s() bank3\n", __FUNCTION__);
+	/* NOTE: MAC address in ENC28J60 is byte-backward */
+	enc28j60_regb_write(priv, MAADR5, ENC28J60_MAC0);
+	enc28j60_regb_write(priv, MAADR4, ENC28J60_MAC1);
+	enc28j60_regb_write(priv, MAADR3, ENC28J60_MAC2);
+	enc28j60_regb_write(priv, MAADR2, ENC28J60_MAC3);
+	enc28j60_regb_write(priv, MAADR1, ENC28J60_MAC4);
+	enc28j60_regb_write(priv, MAADR0, ENC28J60_MAC5);
+
+	/* no loopback of transmitted frames */
+	dev_vdbg(&priv->spi->dev, "%s() PHY\n", __FUNCTION__);
+
+	/* Configure LEDs */
+	if (!enc28j60_phy_write(priv, PHLCON, ENC28J60_LAMPS_MODE))
+		return 0;
+
+	if (full_duplex) {
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
+	enc28j60_dump_regs(priv, "enc28j60 initialized");
+
+	return 1;
+}
+
+static void enc28j60_hw_enable(struct enc28j60_net_local *priv)
+{
+	/* enable interrutps */
+	dev_dbg(&priv->netdev->dev, "%s() enabling interrupts!\n",
+		__FUNCTION__);
+
+	enc28j60_reg_bfclr(priv, EIR, EIR_DMAIF | EIR_LINKIF |
+			   EIR_TXIF | EIR_TXERIF | EIR_RXERIF | EIR_PKTIF);
+	enc28j60_regb_write(priv, EIE, EIE_INTIE | EIE_PKTIE |
+			    EIE_TXIE | EIE_TXERIE | EIE_RXERIE);
+
+	/* enable receive logic */
+	enc28j60_reg_bfset(priv, ECON1, ECON1_RXEN);
+	priv->hw_enable = 1;
+}
+
+static void enc28j60_hw_disable(struct enc28j60_net_local *priv)
+{
+	/* disable interrutps */
+	enc28j60_regb_write(priv, EIE, 0x00);
+	/* disable packet reception */
+	enc28j60_reg_bfclr(priv, ECON1, ECON1_RXEN);
+	priv->hw_enable = 0;
+}
+
+/*
+ * Read the Transmit Status Vector
+ */
+static inline void enc28j60_read_tsv(struct enc28j60_net_local *priv,
+				     uint8_t tsv[TSV_SIZE])
+{
+	int endptr;
+
+	endptr = enc28j60_regw_read(priv, ETXNDL);
+	dev_vdbg(&priv->netdev->dev, "reading TSV at addr:0x%04x\n",
+		 endptr + 1);
+	enc28j60_mem_read(priv, endptr + 1, sizeof(tsv), tsv);
+}
+
+static void enc28j60_dump_tsv(struct enc28j60_net_local *priv, const char *msg,
+			      uint8_t tsv[TSV_SIZE])
+{
+	struct net_device *ndev = priv->netdev;
+	uint16_t tmp1, tmp2;
+
+	dev_vdbg(&ndev->dev, "%s - TSV:\n", msg);
+	tmp1 = tsv[1];
+	tmp1 <<= 8;
+	tmp1 |= tsv[0];
+
+	tmp2 = tsv[5];
+	tmp2 <<= 8;
+	tmp2 |= tsv[4];
+
+	dev_vdbg(&ndev->dev,
+		 "ByteCount: %d, CollisionCount: %d, TotByteOnWire: %d\n", tmp1,
+		 tsv[2] & 0x0f, tmp2);
+	dev_vdbg(&ndev->dev,
+		 "TxDone: %d, CRCErr:%d, LenChkErr: %d, LenOutOfRange: %d\n",
+		 TSV_GETBIT(tsv, TSV_TXDONE), TSV_GETBIT(tsv, TSV_TXCRCERROR),
+		 TSV_GETBIT(tsv, TSV_TXLENCHKERROR),
+		 TSV_GETBIT(tsv, TSV_TXLENOUTOFRANGE));
+	dev_vdbg(&ndev->dev,
+		 "Multicast: %d, Broadcast: %d, PacketDefer: %d, ExDefer: %d\n",
+		 TSV_GETBIT(tsv, TSV_TXMULTICAST),
+		 TSV_GETBIT(tsv, TSV_TXBROADCAST),
+		 TSV_GETBIT(tsv, TSV_TXPACKETDEFER),
+		 TSV_GETBIT(tsv, TSV_TXEXDEFER));
+	dev_vdbg(&ndev->dev,
+		 "ExCollision: %d, LateCollision: %d, Giant: %d, Underrun: %d\n",
+		 TSV_GETBIT(tsv, TSV_TXEXCOLLISION),
+		 TSV_GETBIT(tsv, TSV_TXLATECOLLISION),
+		 TSV_GETBIT(tsv, TSV_TXGIANT), TSV_GETBIT(tsv, TSV_TXUNDERRUN));
+	dev_vdbg(&ndev->dev,
+		 "ControlFrame: %d, PauseFrame: %d, "
+		 "BackPressApp: %d, VLanTagFrame: %d\n",
+		 TSV_GETBIT(tsv, TSV_TXCONTROLFRAME),
+		 TSV_GETBIT(tsv, TSV_TXPAUSEFRAME),
+		 TSV_GETBIT(tsv, TSV_BACKPRESSUREAPP),
+		 TSV_GETBIT(tsv, TSV_TXVLANTAGFRAME));
+}
+
+/*
+ * Calculate free space in RxFIFO
+ */
+static inline int enc28j60_get_free_rxfifo(struct enc28j60_net_local *priv)
+{
+	int epkcnt, erxst, erxnd, erxwr, erxrd;
+	int free_space;
+
+	epkcnt = enc28j60_regb_read(priv, EPKTCNT);
+	if (epkcnt >= 255)
+		free_space = -1;
+	else {
+		erxst = enc28j60_regw_read(priv, ERXSTL);
+		erxnd = enc28j60_regw_read(priv, ERXNDL);
+		erxwr = enc28j60_regw_read(priv, ERXWRPTL);
+		erxrd = enc28j60_regw_read(priv, ERXRDPTL);
+
+		if (erxwr > erxrd)
+			free_space = (erxnd - erxst) - (erxwr - erxrd);
+		else if (erxwr == erxrd)
+			free_space = (erxnd - erxst);
+		else
+			free_space = erxrd - erxwr - 1;
+	}
+	dev_vdbg(&priv->netdev->dev, "%s() free_space = %d\n", __FUNCTION__,
+		 free_space);
+
+	return free_space;
+}
+
+static void enc28j60_irq_work_handler(struct work_struct *work)
+{
+	struct enc28j60_net_local *priv =
+	    container_of(work, struct enc28j60_net_local, irq_work);
+	int intflags, loop, pk_counter;
+
+	dev_vdbg(&priv->netdev->dev, "%s(priv=%p)\n", __FUNCTION__, priv);
+
+	/* disable further interrupts */
+	enc28j60_reg_bfclr(priv, EIE, EIE_INTIE);
+
+	do {
+		loop = 0;
+		intflags = enc28j60_regb_read(priv, EIR);
+		/* DMA interrupt handler */
+		if ((intflags & EIR_DMAIF) != 0) {
+			loop++;
+			dev_vdbg(&priv->netdev->dev, "intDMA(%d)\n", loop);
+			enc28j60_reg_bfclr(priv, EIR, EIR_DMAIF);
+		}
+		/* LINK changed handler */
+		if ((intflags & EIR_LINKIF) != 0) {
+			loop++;
+			dev_vdbg(&priv->netdev->dev, "intLINK(%d)\n", loop);
+			/* read PHIR to clear the flag */
+			enc28j60_phy_read(priv, PHIR);
+		}
+		/* TX complete handler */
+		if ((intflags & EIR_TXIF) != 0) {
+			loop++;
+			dev_vdbg(&priv->netdev->dev, "intTX(%d,skb:%p)\n", loop,
+				 priv->tx_skb);
+
+			priv->tx_retry_count = 0;
+			if (enc28j60_regb_read(priv, ESTAT) & ESTAT_TXABRT) {
+				dev_err(&priv->netdev->dev,
+					"enc28j60 tx error (aborted)\n");
+				priv->stats.tx_errors++;
+			} else
+				priv->stats.tx_packets++;
+			if (priv->tx_skb) {
+				/* update statistics and free skb */
+				priv->stats.tx_bytes += priv->tx_skb->len;
+				dev_kfree_skb(priv->tx_skb);
+				priv->tx_skb = NULL;
+			}
+			netif_wake_queue(priv->netdev);
+			enc28j60_reg_bfclr(priv, ECON1, ECON1_TXRTS);
+			enc28j60_reg_bfclr(priv, EIR, EIR_TXIF);
+		}
+		/* TX Error handler */
+		if ((intflags & EIR_TXERIF) != 0) {
+			uint8_t tsv[TSV_SIZE];
+
+			loop++;
+			dev_vdbg(&priv->netdev->dev, "intTXErr(%d)\n", loop);
+
+			enc28j60_reg_bfclr(priv, ECON1, ECON1_TXRTS);
+			enc28j60_read_tsv(priv, tsv);
+			enc28j60_dump_tsv(priv, __FUNCTION__, tsv);
+			/* Reset TX logic */
+			enc28j60_reg_bfset(priv, ECON1, ECON1_TXRST);
+			enc28j60_reg_bfclr(priv, ECON1, ECON1_TXRST);
+			/* Transmit Late collision check for retransmit */
+			if (TSV_GETBIT(tsv, TSV_TXLATECOLLISION)) {
+				if (priv->tx_retry_count++ < MAX_TX_RETRYCOUNT)
+					enc28j60_reg_bfset(priv, ECON1,
+							   ECON1_TXRTS);
+				else
+					priv->stats.tx_errors++;
+			} else
+				priv->stats.tx_errors++;
+			/* Clear IF flag */
+			enc28j60_reg_bfclr(priv, EIR, EIR_TXERIF);
+		}
+		/* RX Error handler */
+		if ((intflags & EIR_RXERIF) != 0) {
+			loop++;
+			dev_vdbg(&priv->netdev->dev, "intRXErr(%d)\n", loop);
+
+			/* Check free FIFO space to flag RX overrun */
+			if (enc28j60_get_free_rxfifo(priv) <= 0) {
+				dev_err(&priv->netdev->dev,
+					"enc28j60 RX overrun\n");
+				priv->stats.rx_dropped++;
+			}
+			enc28j60_reg_bfclr(priv, EIR, EIR_RXERIF);
+		}
+		/*
+		 * RX handler
+		 * PKTIF don't work reliably!!! (look at the errata datasheet)
+		 * check EPKTCNT is the suggested workaround
+		 * process any packet pending (hw_rx MUST decrement PKCNT for
+		 * any packet processed)
+		 */
+		while ((pk_counter = enc28j60_regb_read(priv, EPKTCNT)) > 0) {
+			loop++;
+			dev_vdbg(&priv->netdev->dev, "intRX(%d), pk_cnt: %d\n",
+				 loop, pk_counter);
+			/* update statistics */
+			if (pk_counter > priv->max_pk_counter) {
+				priv->max_pk_counter = pk_counter;
+				if (priv->max_pk_counter > 4)
+					dev_dbg(&priv->netdev->dev,
+						"enc28j60 RX, max_pk_cnt: %d\n",
+						priv->max_pk_counter);
+				else if (priv->max_pk_counter > 1)
+					dev_vdbg(&priv->netdev->dev,
+						 "enc28j60 RX, max_pk_cnt: %d\n",
+						 priv->max_pk_counter);
+			}
+			/*
+			 * don't need to clear interrupt flag, automatically done
+			 * when enc28j60_hw_rx() decrements the packet counter
+			 */
+			enc28j60_hw_rx(priv);
+		}
+	} while (loop);
+
+	/* re-enable interrupts */
+	enc28j60_reg_bfset(priv, EIE, EIE_INTIE);
+	dev_vdbg(&priv->netdev->dev, "%s() exit\n", __FUNCTION__);
+}
+
+static void dump_packet(struct enc28j60_net_local *priv, const char *msg,
+			int len, const char *data)
+{
+#if CONFIG_ENC28J60_DBGLEVEL > 2
+	int k;
+	struct net_device *ndev = priv->netdev;
+
+	dev_vdbg(&ndev->dev, "%s(), packet len:%d", msg, len);
+	for (k = 0; len--; k++) {
+		if (!(k % 16))
+			printk("\n%04x: ", k);
+		printk("%02x ", data[k]);
+	}
+	printk("\n");
+#endif
+}
+
+/*
+ * Hardware transmit function.
+ * Fill the buffer memory and send the contents of the transmit buffer
+ * onto the network
+ */
+static void enc28j60_hw_tx(struct enc28j60_net_local *priv)
+{
+	dev_vdbg(&priv->netdev->dev, "%s(), packet len:%d\n",
+		 __FUNCTION__, priv->tx_skb->len);
+
+	/* Set the write pointer to start of transmit buffer area */
+	enc28j60_regw_write(priv, EWRPTL, TXSTART_INIT);
+#ifdef CONFIG_ENC28J60_WRITEVERIFY
+	{
+		uint16_t reg;
+		reg = enc28j60_regw_read(priv, EWRPTL);
+		if (reg != TXSTART_INIT)
+			dev_dbg(&priv->netdev->dev,
+				"%s() ERWPT:0x%04x != 0x%04x\n", __FUNCTION__,
+				reg, TXSTART_INIT);
+	}
+#endif
+	/* Set the TXND pointer to correspond to the packet size given */
+	enc28j60_regw_write(priv, ETXNDL, TXSTART_INIT + priv->tx_skb->len);
+	/* write per-packet control byte */
+	spi_write_op(priv, ENC28J60_WRITE_BUF_MEM, 0, 0x00);
+	dev_vdbg(&priv->netdev->dev, "%s() after control byte ERWPT:0x%04x\n",
+		 __FUNCTION__, enc28j60_regw_read(priv, EWRPTL));
+
+	dump_packet(priv, __FUNCTION__, priv->tx_skb->len, priv->tx_skb->data);
+
+	/* copy the packet into the transmit buffer */
+	spi_write_buf(priv, priv->tx_skb->len, priv->tx_skb->data);
+	dev_vdbg(&priv->netdev->dev,
+		 "%s() after write packet ERWPT:0x%04x, len=%d\n", __FUNCTION__,
+		 enc28j60_regw_read(priv, EWRPTL), priv->tx_skb->len);
+
+#ifdef CONFIG_ENC28J60_WRITEVERIFY
+	{	/* readback and verify written data */
+		int test_len, k;
+		uint8_t test_buf[256];
+		int okflag = 1;
+
+		test_len = priv->tx_skb->len;
+		if (test_len > sizeof(test_buf))
+			test_len = sizeof(test_buf);
+
+		/* + 1 to skip control byte */
+		enc28j60_mem_read(priv, TXSTART_INIT + 1, test_len, test_buf);
+		for (k = 0; k < test_len; k++) {
+			if (priv->tx_skb->data[k] != test_buf[k]) {
+				dev_vdbg(&priv->netdev->dev,
+					 "%s(),Err! differ [%d] "
+					 "0x%02x - 0x%02x\n",
+					 __FUNCTION__, k, priv->tx_skb->data[k],
+					 test_buf[k]);
+				okflag = 0;
+			}
+		}
+		if (!okflag)
+			dev_dbg(&priv->netdev->dev,
+				"%s(), Write buffer verify error!\n",
+				__FUNCTION__);
+		else
+			dev_vdbg(&priv->netdev->dev,
+				 "%s(), Write buffer verify OK\n",
+				 __FUNCTION__);
+	}
+#endif
+	/* set TX request flag */
+	enc28j60_reg_bfset(priv, ECON1, ECON1_TXRTS);
+}
+
+/*
+ * Read the Receive Status Vector
+ */
+static void enc28j60_dump_rsv(struct enc28j60_net_local *priv, const char *msg,
+			      uint16_t pk_ptr, int len, uint16_t sts)
+{
+	struct net_device *ndev = priv->netdev;
+
+	dev_vdbg(&ndev->dev, "%s - NexPk: 0x%04x - RSV:\n", msg, pk_ptr);
+	dev_vdbg(&ndev->dev, "ByteCount: %d, DribbleNibble: %d\n", len,
+		 RSV_GETBIT(sts, RSV_DRIBBLENIBBLE));
+	dev_vdbg(&ndev->dev,
+		 "RxOK: %d, CRCErr:%d, LenChkErr: %d, LenOutOfRange: %d\n",
+		 RSV_GETBIT(sts, RSV_RXOK), RSV_GETBIT(sts, RSV_CRCERROR),
+		 RSV_GETBIT(sts, RSV_LENCHECKERR),
+		 RSV_GETBIT(sts, RSV_LENOUTOFRANGE));
+	dev_vdbg(&ndev->dev,
+		 "Multicast: %d, Broadcast: %d, "
+		 "LongDropEvent: %d, CarrierEvent: %d\n",
+		 RSV_GETBIT(sts, RSV_RXMULTICAST),
+		 RSV_GETBIT(sts, RSV_RXBROADCAST),
+		 RSV_GETBIT(sts, RSV_RXLONGEVDROPEV),
+		 RSV_GETBIT(sts, RSV_CARRIEREV));
+	dev_vdbg(&ndev->dev,
+		 "ControlFrame: %d, PauseFrame: %d, UnknownOp: %d, "
+		 "VLanTagFrame: %d\n",
+		 RSV_GETBIT(sts, RSV_RXCONTROLFRAME),
+		 RSV_GETBIT(sts, RSV_RXPAUSEFRAME),
+		 RSV_GETBIT(sts, RSV_RXUNKNOWNOPCODE),
+		 RSV_GETBIT(sts, RSV_RXTYPEVLAN));
+}
+
+/*
+ * Hardware receive function.
+ * Read the buffer memory, update the FIFO pointer,
+ * check the status vector and decrement the packet counter
+ */
+static void enc28j60_hw_rx(struct enc28j60_net_local *priv)
+{
+	struct sk_buff *skb;
+	uint16_t erxrdpt, next_packet, rxstat;
+	uint8_t tmpv[6];
+	int len;
+
+	dev_vdbg(&priv->netdev->dev, "%s() pk_addr:0x%04x\n", __FUNCTION__,
+		 priv->next_pk_ptr);
+
+	if (priv->next_pk_ptr > RXEND_INIT) {
+		dev_err(&priv->netdev->dev,
+			"%s() Invalid packet address!! 0x%04x\n", __FUNCTION__,
+			priv->next_pk_ptr);
+		return;
+	}
+	/* Read next packet pointer and rx status vector */
+	enc28j60_mem_read(priv, priv->next_pk_ptr, sizeof(tmpv), tmpv);
+
+	next_packet = tmpv[1];
+	next_packet <<= 8;
+	next_packet |= tmpv[0];
+
+	len = tmpv[3];
+	len <<= 8;
+	len |= tmpv[2];
+
+	rxstat = tmpv[5];
+	rxstat <<= 8;
+	rxstat |= tmpv[4];
+
+	enc28j60_dump_rsv(priv, __FUNCTION__, next_packet, len, rxstat);
+
+	if (!RSV_GETBIT(rxstat, RSV_RXOK)) {
+		dev_dbg(&priv->netdev->dev, "enc28j60: Rx Error (%04x)\n",
+			rxstat);
+
+		priv->stats.rx_errors++;
+		if (RSV_GETBIT(rxstat, RSV_CRCERROR))
+			priv->stats.rx_crc_errors++;
+		if (RSV_GETBIT(rxstat, RSV_LENCHECKERR))
+			priv->stats.rx_frame_errors++;
+	} else {
+		skb = dev_alloc_skb(len);
+		if (!skb) {
+			dev_err(&priv->netdev->dev,
+				"enc28j60: out of memory for Rx'd frame\n");
+			priv->stats.rx_dropped++;
+			return;
+		}
+		skb->dev = priv->netdev;
+
+		/* copy the packet from the receive buffer */
+		enc28j60_mem_read(priv, priv->next_pk_ptr + sizeof(tmpv), len,
+				  skb_put(skb, len));
+
+		priv->next_pk_ptr = next_packet;
+
+		/*
+		 * Move the RX read pointer to the start of the next
+		 * received packet.
+		 * This frees the memory we just read out
+		 */
+		erxrdpt =
+		    erxrdpt_workaround(priv->next_pk_ptr, RXSTART_INIT,
+				       RXEND_INIT);
+		enc28j60_regw_write(priv, ERXRDPTL, erxrdpt);
+
+		dev_vdbg(&priv->netdev->dev,
+			 "%s() RxSize:%d, RxStat:0x%04x ERXRDPT:0x%04x\n",
+			 __FUNCTION__, len, rxstat, erxrdpt);
+		dump_packet(priv, __FUNCTION__, skb->len, skb->data);
+
+		/* we are done with this packet, decrement the packet counter */
+		enc28j60_reg_bfset(priv, ECON2, ECON2_PKTDEC);
+
+		skb->protocol = eth_type_trans(skb, priv->netdev);
+
+		/* update statistics */
+		priv->stats.rx_packets++;
+		priv->stats.rx_bytes += len;
+		priv->netdev->last_rx = jiffies;
+		netif_rx(skb);
+	}
+}
+
+static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct enc28j60_net_local *priv = netdev_priv(dev);
+
+	dev_vdbg(&dev->dev, "%s()\n", __FUNCTION__);
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
+	struct enc28j60_net_local *priv =
+	    container_of(work, struct enc28j60_net_local, tx_work);
+	dev_vdbg(&priv->netdev->dev, "%s()\n", __FUNCTION__);
+
+	/* actual delivery of data */
+	enc28j60_hw_tx(priv);
+}
+
+static irqreturn_t enc28j60_irq(int irq, void *dev_id)
+{
+	struct enc28j60_net_local *priv = dev_id;
+
+	dev_vdbg(&priv->netdev->dev, "%s(priv=%p)\n", __FUNCTION__, priv);
+
+	/*
+	 * Can't do anything in interrupt context so fire of the interrupt
+	 * handling workqueue.
+	 */
+	schedule_work(&priv->irq_work);
+
+	return IRQ_HANDLED;
+}
+
+static void enc28j60_net_tx_timeout(struct net_device *ndev)
+{
+	struct enc28j60_net_local *priv = netdev_priv(ndev);
+
+	dev_dbg(&ndev->dev, "enc28j60 transmit timed out\n");
+
+	/* Reset the TX logic */
+	enc28j60_reg_bfset(priv, ECON1, ECON1_TXRST);
+	enc28j60_reg_bfclr(priv, ECON1, ECON1_TXRST);
+	enc28j60_reg_bfclr(priv, EIR, EIR_TXERIF | EIR_TXIF);
+	priv->stats.tx_errors++;
+	netif_wake_queue(ndev);
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
+	struct enc28j60_net_local *priv = netdev_priv(dev);
+
+	dev_dbg(&dev->dev, "%s() enter [priv:%p]\n", __FUNCTION__, priv);
+
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		dev_err(&dev->dev, "%s() invalid MAC address\n", __FUNCTION__);
+		return -EADDRNOTAVAIL;
+	}
+
+	/* Reset the hardware here */
+	enc28j60_hw_disable(priv);
+	enc28j60_reg_bfset(priv, ECON1, ECON1_TXRST | ECON1_RXRST);
+	enc28j60_reg_bfclr(priv, ECON1, ECON1_TXRST | ECON1_RXRST);
+
+	/* Update the MAC address (in case user has changed it) */
+	enc28j60_set_hw_macaddr(priv);
+
+	/* Enable interrupts */
+	enc28j60_hw_enable(priv);
+
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
+	struct enc28j60_net_local *priv = netdev_priv(dev);
+
+	dev_dbg(&dev->dev, "%s()\n", __FUNCTION__);
+
+	enc28j60_hw_disable(priv);
+	netif_stop_queue(dev);
+
+	return 0;
+}
+
+/*
+ * Get the current statistics.
+ * This may be called with the card open or closed.
+ */
+static struct net_device_stats *enc28j60_net_get_stats(struct net_device *dev)
+{
+	struct enc28j60_net_local *priv = netdev_priv(dev);
+
+	return &priv->stats;
+}
+
+/*
+ * Set or clear the multicast filter for this adaptor.
+ * num_addrs == -1	Promiscuous mode, receive all packets
+ * num_addrs == 0	Normal mode, clear multicast list
+ * num_addrs > 0	Multicast mode, receive normal and MC packets,
+ *			and do best-effort filtering.
+ */
+static void enc28j60_set_multicast_list(struct net_device *dev)
+{
+	struct enc28j60_net_local *priv = netdev_priv(dev);
+
+	if (!priv->hw_enable) {
+		if (dev->flags & IFF_PROMISC) {
+			dev_dbg(&dev->dev, "%s() promiscuous mode\n",
+				__FUNCTION__);
+			enc28j60_regb_write(priv, ERXFCON, 0x00);
+		} else if (dev->flags & IFF_ALLMULTI) {
+			dev_dbg(&dev->dev, "%s() multicast mode\n",
+				__FUNCTION__);
+			enc28j60_regb_write(priv, ERXFCON,
+					    ERXFCON_UCEN | ERXFCON_CRCEN |
+					    ERXFCON_BCEN | ERXFCON_MCEN);
+		} else {
+			dev_dbg(&dev->dev, "%s() normal mode\n", __FUNCTION__);
+			enc28j60_regb_write(priv, ERXFCON,
+					    ERXFCON_UCEN | ERXFCON_CRCEN |
+					    ERXFCON_BCEN);
+		}
+	} else
+		dev_dbg(&dev->dev,
+			"%s() Warning: hw must be disabled to set rx filter\n",
+			__FUNCTION__);
+}
+
+static int enc28j60_chipset_init(struct net_device *dev)
+{
+	struct enc28j60_net_local *priv = netdev_priv(dev);
+
+	return enc28j60_hw_init(priv);
+}
+
+static int __devinit enc28j60_probe(struct spi_device *spi)
+{
+	struct net_device *dev;
+	struct enc28j60_net_local *priv;
+	int ret = 0;
+
+	dev_dbg(&spi->dev, "%s() start\n", __FUNCTION__);
+
+	dev = alloc_etherdev(sizeof(struct enc28j60_net_local));
+	if (!dev) {
+		ret = -ENOMEM;
+		goto error_alloc;
+	}
+	priv = netdev_priv(dev);
+
+	priv->netdev = dev;	/* priv to netdev reference */
+	priv->spi = spi;	/* priv to spi reference */
+	priv->spi_transfer_buf = kmalloc(SPI_TRANSFER_BUF_LEN, GFP_KERNEL);
+	if (!priv->spi_transfer_buf) {
+		ret = -ENOMEM;
+		goto error_buf;
+	}
+	init_MUTEX(&priv->semlock);
+
+	INIT_WORK(&priv->tx_work, enc28j60_tx_work_handler);
+	INIT_WORK(&priv->irq_work, enc28j60_irq_work_handler);
+	dev_set_drvdata(&spi->dev, priv);	/* spi to priv reference */
+	SET_NETDEV_DEV(dev, &spi->dev);
+
+	if (!enc28j60_chipset_init(dev)) {
+		dev_dbg(&spi->dev, "enc28j60 not found\n");
+		ret = -EIO;
+		goto error_irq;
+	}
+	enc28j60_get_hw_macaddr(priv);
+
+	ret = request_irq(spi->irq, enc28j60_irq, IRQF_TRIGGER_FALLING,
+			  "enc28j60", priv);
+	if (ret < 0) {
+		dev_err(&spi->dev, "request irq %d failed (ret = %d)\n",
+			spi->irq, ret);
+		goto error_irq;
+	}
+
+	dev->irq = spi->irq;
+
+	dev->open = enc28j60_net_open;
+	dev->stop = enc28j60_net_close;
+	dev->hard_start_xmit = enc28j60_send_packet;
+	dev->get_stats = enc28j60_net_get_stats;
+	dev->set_multicast_list = &enc28j60_set_multicast_list;
+	dev->set_mac_address = enc28j60_set_mac_address;
+	dev->tx_timeout = &enc28j60_net_tx_timeout;
+	dev->watchdog_timeo = MY_TX_TIMEOUT;
+
+	ret = register_netdev(dev);
+	if (ret) {
+		dev_err(&spi->dev,
+			"register netdev enc28j60 failed (ret = %d)\n", ret);
+		goto error_register;
+	}
+	dev_info(&spi->dev, "%s: enc28j60 driver registered (interrupt %d)\n",
+		 dev->name, dev->irq);
+
+	return 0;
+
+      error_register:
+	free_irq(spi->irq, priv);
+      error_irq:
+	kfree(priv->spi_transfer_buf);
+      error_buf:
+	free_netdev(dev);
+      error_alloc:
+	return ret;
+}
+
+static int enc28j60_remove(struct spi_device *spi)
+{
+	struct enc28j60_net_local *priv = dev_get_drvdata(&spi->dev);
+
+	dev_dbg(&spi->dev, "%s: stop\n", __FUNCTION__);
+
+	unregister_netdev(priv->netdev);
+	free_irq(spi->irq, priv);
+	kfree(priv->spi_transfer_buf);
+	free_netdev(priv->netdev);
+
+	return 0;
+}
+
+static struct spi_driver enc28j60_driver = {
+	.driver = {
+		   .name = "enc28j60",
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
+MODULE_DESCRIPTION("ENC28J60 ethernet driver");
+MODULE_AUTHOR("Claudio Lanconelli <lanconelli.claudio@eptar.com>");
+MODULE_LICENSE("GPL");
+module_param(full_duplex, int, 0);
+MODULE_PARM_DESC(full_duplex, "Enable full duplex mode");
diff --git a/drivers/net/enc28j60_hw.h b/drivers/net/enc28j60_hw.h
new file mode 100644
index 0000000..78f415a
--- /dev/null
+++ b/drivers/net/enc28j60_hw.h
@@ -0,0 +1,303 @@
+/*
+ * enc28j60_hw.h: EDTP FrameThrower style enc28j60 registers
+ *
+ * $Id: enc28j60_hw.h,v 1.5 2007/12/11 10:35:40 claudio Exp $
+ */
+
+#ifndef _ENC28J60_HW_H
+#define _ENC28J60_HW_H
+
+/*
+ * ENC28J60 Control Registers
+ * Control register definitions are a combination of address,
+ * bank number, and Ethernet/MAC/PHY indicator bits.
+ * - Register address   (bits 0-4)
+ * - Bank number        (bits 5-6)
+ * - MAC/MII indicator  (bit 7)
+ */
+#define ADDR_MASK   0x1F
+#define BANK_MASK   0x60
+#define SPRD_MASK   0x80
+/* All-bank registers */
+#define EIE         0x1B
+#define EIR         0x1C
+#define ESTAT       0x1D
+#define ECON2       0x1E
+#define ECON1       0x1F
+/* Bank 0 registers */
+#define ERDPTL      (0x00|0x00)
+#define ERDPTH      (0x01|0x00)
+#define EWRPTL      (0x02|0x00)
+#define EWRPTH      (0x03|0x00)
+#define ETXSTL      (0x04|0x00)
+#define ETXSTH      (0x05|0x00)
+#define ETXNDL      (0x06|0x00)
+#define ETXNDH      (0x07|0x00)
+#define ERXSTL      (0x08|0x00)
+#define ERXSTH      (0x09|0x00)
+#define ERXNDL      (0x0A|0x00)
+#define ERXNDH      (0x0B|0x00)
+#define ERXRDPTL    (0x0C|0x00)
+#define ERXRDPTH    (0x0D|0x00)
+#define ERXWRPTL    (0x0E|0x00)
+#define ERXWRPTH    (0x0F|0x00)
+#define EDMASTL     (0x10|0x00)
+#define EDMASTH     (0x11|0x00)
+#define EDMANDL     (0x12|0x00)
+#define EDMANDH     (0x13|0x00)
+#define EDMADSTL    (0x14|0x00)
+#define EDMADSTH    (0x15|0x00)
+#define EDMACSL     (0x16|0x00)
+#define EDMACSH     (0x17|0x00)
+/* Bank 1 registers */
+#define EHT0        (0x00|0x20)
+#define EHT1        (0x01|0x20)
+#define EHT2        (0x02|0x20)
+#define EHT3        (0x03|0x20)
+#define EHT4        (0x04|0x20)
+#define EHT5        (0x05|0x20)
+#define EHT6        (0x06|0x20)
+#define EHT7        (0x07|0x20)
+#define EPMM0       (0x08|0x20)
+#define EPMM1       (0x09|0x20)
+#define EPMM2       (0x0A|0x20)
+#define EPMM3       (0x0B|0x20)
+#define EPMM4       (0x0C|0x20)
+#define EPMM5       (0x0D|0x20)
+#define EPMM6       (0x0E|0x20)
+#define EPMM7       (0x0F|0x20)
+#define EPMCSL      (0x10|0x20)
+#define EPMCSH      (0x11|0x20)
+#define EPMOL       (0x14|0x20)
+#define EPMOH       (0x15|0x20)
+#define EWOLIE      (0x16|0x20)
+#define EWOLIR      (0x17|0x20)
+#define ERXFCON     (0x18|0x20)
+#define EPKTCNT     (0x19|0x20)
+/* Bank 2 registers */
+#define MACON1      (0x00|0x40|SPRD_MASK)
+/* #define MACON2      (0x01|0x40|SPRD_MASK) */
+#define MACON3      (0x02|0x40|SPRD_MASK)
+#define MACON4      (0x03|0x40|SPRD_MASK)
+#define MABBIPG     (0x04|0x40|SPRD_MASK)
+#define MAIPGL      (0x06|0x40|SPRD_MASK)
+#define MAIPGH      (0x07|0x40|SPRD_MASK)
+#define MACLCON1    (0x08|0x40|SPRD_MASK)
+#define MACLCON2    (0x09|0x40|SPRD_MASK)
+#define MAMXFLL     (0x0A|0x40|SPRD_MASK)
+#define MAMXFLH     (0x0B|0x40|SPRD_MASK)
+#define MAPHSUP     (0x0D|0x40|SPRD_MASK)
+#define MICON       (0x11|0x40|SPRD_MASK)
+#define MICMD       (0x12|0x40|SPRD_MASK)
+#define MIREGADR    (0x14|0x40|SPRD_MASK)
+#define MIWRL       (0x16|0x40|SPRD_MASK)
+#define MIWRH       (0x17|0x40|SPRD_MASK)
+#define MIRDL       (0x18|0x40|SPRD_MASK)
+#define MIRDH       (0x19|0x40|SPRD_MASK)
+/* Bank 3 registers */
+#define MAADR1      (0x00|0x60|SPRD_MASK)
+#define MAADR0      (0x01|0x60|SPRD_MASK)
+#define MAADR3      (0x02|0x60|SPRD_MASK)
+#define MAADR2      (0x03|0x60|SPRD_MASK)
+#define MAADR5      (0x04|0x60|SPRD_MASK)
+#define MAADR4      (0x05|0x60|SPRD_MASK)
+#define EBSTSD      (0x06|0x60)
+#define EBSTCON     (0x07|0x60)
+#define EBSTCSL     (0x08|0x60)
+#define EBSTCSH     (0x09|0x60)
+#define MISTAT      (0x0A|0x60|SPRD_MASK)
+#define EREVID      (0x12|0x60)
+#define ECOCON      (0x15|0x60)
+#define EFLOCON     (0x17|0x60)
+#define EPAUSL      (0x18|0x60)
+#define EPAUSH      (0x19|0x60)
+/* PHY registers */
+#define PHCON1      0x00
+#define PHSTAT1     0x01
+#define PHHID1      0x02
+#define PHHID2      0x03
+#define PHCON2      0x10
+#define PHSTAT2     0x11
+#define PHIE        0x12
+#define PHIR        0x13
+#define PHLCON      0x14
+
+/* ENC28J60 EIE Register Bit Definitions */
+#define EIE_INTIE       0x80
+#define EIE_PKTIE       0x40
+#define EIE_DMAIE       0x20
+#define EIE_LINKIE      0x10
+#define EIE_TXIE        0x08
+#define EIE_WOLIE       0x04
+#define EIE_TXERIE      0x02
+#define EIE_RXERIE      0x01
+/* ENC28J60 EIR Register Bit Definitions */
+#define EIR_PKTIF       0x40
+#define EIR_DMAIF       0x20
+#define EIR_LINKIF      0x10
+#define EIR_TXIF        0x08
+#define EIR_WOLIF       0x04
+#define EIR_TXERIF      0x02
+#define EIR_RXERIF      0x01
+/* ENC28J60 ESTAT Register Bit Definitions */
+#define ESTAT_INT       0x80
+#define ESTAT_LATECOL   0x10
+#define ESTAT_RXBUSY    0x04
+#define ESTAT_TXABRT    0x02
+#define ESTAT_CLKRDY    0x01
+/* ENC28J60 ECON2 Register Bit Definitions */
+#define ECON2_AUTOINC   0x80
+#define ECON2_PKTDEC    0x40
+#define ECON2_PWRSV     0x20
+#define ECON2_VRPS      0x08
+/* ENC28J60 ECON1 Register Bit Definitions */
+#define ECON1_TXRST     0x80
+#define ECON1_RXRST     0x40
+#define ECON1_DMAST     0x20
+#define ECON1_CSUMEN    0x10
+#define ECON1_TXRTS     0x08
+#define ECON1_RXEN      0x04
+#define ECON1_BSEL1     0x02
+#define ECON1_BSEL0     0x01
+/* ENC28J60 MACON1 Register Bit Definitions */
+#define MACON1_LOOPBK   0x10
+#define MACON1_TXPAUS   0x08
+#define MACON1_RXPAUS   0x04
+#define MACON1_PASSALL  0x02
+#define MACON1_MARXEN   0x01
+/* ENC28J60 MACON2 Register Bit Definitions */
+#define MACON2_MARST    0x80
+#define MACON2_RNDRST   0x40
+#define MACON2_MARXRST  0x08
+#define MACON2_RFUNRST  0x04
+#define MACON2_MATXRST  0x02
+#define MACON2_TFUNRST  0x01
+/* ENC28J60 MACON3 Register Bit Definitions */
+#define MACON3_PADCFG2  0x80
+#define MACON3_PADCFG1  0x40
+#define MACON3_PADCFG0  0x20
+#define MACON3_TXCRCEN  0x10
+#define MACON3_PHDRLEN  0x08
+#define MACON3_HFRMLEN  0x04
+#define MACON3_FRMLNEN  0x02
+#define MACON3_FULDPX   0x01
+/* ENC28J60 MICMD Register Bit Definitions */
+#define MICMD_MIISCAN   0x02
+#define MICMD_MIIRD     0x01
+/* ENC28J60 MISTAT Register Bit Definitions */
+#define MISTAT_NVALID   0x04
+#define MISTAT_SCAN     0x02
+#define MISTAT_BUSY     0x01
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
+#define PHCON1_PRST     0x8000
+#define PHCON1_PLOOPBK  0x4000
+#define PHCON1_PPWRSV   0x0800
+#define PHCON1_PDPXMD   0x0100
+/* ENC28J60 PHY PHSTAT1 Register Bit Definitions */
+#define PHSTAT1_PFDPX   0x1000
+#define PHSTAT1_PHDPX   0x0800
+#define PHSTAT1_LLSTAT  0x0004
+#define PHSTAT1_JBSTAT  0x0002
+/* ENC28J60 PHY PHCON2 Register Bit Definitions */
+#define PHCON2_FRCLINK  0x4000
+#define PHCON2_TXDIS    0x2000
+#define PHCON2_JABBER   0x0400
+#define PHCON2_HDLDIS   0x0100
+
+/* ENC28J60 Packet Control Byte Bit Definitions */
+#define PKTCTRL_PHUGEEN     0x08
+#define PKTCTRL_PPADEN      0x04
+#define PKTCTRL_PCRCEN      0x02
+#define PKTCTRL_POVERRIDE   0x01
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
+#define TSV_SIZE 7
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
+#define RSV_BITMASK(x)		(1 << ((x) - 16))
+#define RSV_GETBIT(x, y)	(((x) & RSV_BITMASK(y)) ? 1 : 0)
+
+
+/* SPI operation codes */
+#define ENC28J60_READ_CTRL_REG  0x00
+#define ENC28J60_READ_BUF_MEM   0x3A
+#define ENC28J60_WRITE_CTRL_REG 0x40
+#define ENC28J60_WRITE_BUF_MEM  0x7A
+#define ENC28J60_BIT_FIELD_SET  0x80
+#define ENC28J60_BIT_FIELD_CLR  0xA0
+#define ENC28J60_SOFT_RESET     0xFF
+
+
+/* buffer boundaries applied to internal 8K ram
+ * entire available packet buffer space is allocated.
+ * Give TX buffer space for one full ethernet frame (~1500 bytes)
+ * receive buffer gets the rest */
+#define TXSTART_INIT	0x1A00
+#define TXEND_INIT	0x1FFF
+
+/* Put RX buffer at 0 as suggested by the Errata datasheet */
+#define RXSTART_INIT	0x0000
+#define RXEND_INIT	0x19FF
+
+/* maximum ethernet frame length */
+#define MAX_FRAMELEN    1518
+
+/* Prefered half duplex: LEDA: Link status LEDB: Rx/Tx activity */
+#define ENC28J60_LAMPS_MODE	0x3476
+
+/* Default MAC address for this interface */
+#define ENC28J60_MAC0 0x00
+#define ENC28J60_MAC1 0x00
+#define ENC28J60_MAC2 'F'
+#define ENC28J60_MAC3 'I'
+#define ENC28J60_MAC4 'C'
+#define ENC28J60_MAC5 'E'
+
+#endif

--------------060005040304050407010904--

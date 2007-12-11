From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2] add driver for enc28j60 ethernet chip
Date: Tue, 11 Dec 2007 09:06:48 -0800
Message-ID: <20071211090648.24ee1742@freepuppy.rosehill>
References: <475EA546.7030202@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57254 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752042AbXLKRXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 12:23:42 -0500
In-Reply-To: <475EA546.7030202@eptar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Dec 2007 15:57:10 +0100
Claudio Lanconelli <lanconelli.claudio@eptar.com> wrote:

> These patches add support for Microchip enc28j60 ethernet chip 
> controlled via SPI.
> I tested it on my custom board (S162) with ARM9 s3c2442 SoC.
> Any comments are welcome.
> 
> Signed-off-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>

General comments:
  * device driver does no carrier detection. This makes it useless
    for bridging, bonding, or any form of failover.

  * use random_ether_addr rather than hardocoding constant mac address

  * use msglevel method (via ethtool) to control debug messages
    rather than kernel configuration. This allows enabling debugging
    without recompilation which is important in distributions.

  * kernel uses u8 rather than uint8_t for byte variables

  * use netdev_priv(netdev) rather than netdev->priv

  * Please add ethtool support

  * Consider using NAPI


Output from checkpatch:
ERROR: do not initialise statics to 0 or NULL
#148: FILE: drivers/net/enc28j60.c:73:
+static int full_duplex = 0;

ERROR: "foo * bar" should be "foo *bar"
#166: FILE: drivers/net/enc28j60.c:91:
+			const uint8_t * data);

ERROR: "foo * bar" should be "foo *bar"
#245: FILE: drivers/net/enc28j60.c:170:
+			 const uint8_t * data)

ERROR: "foo * bar" should be "foo *bar"
#413: FILE: drivers/net/enc28j60.c:338:
+				     uint16_t addr, int len, uint8_t * data)

WARNING: printk() should include KERN_ facility level
#557: FILE: drivers/net/enc28j60.c:482:
+	printk("Cntrl: ECON1 ECON2 ESTAT  EIR  EIE\n");

WARNING: printk() should include KERN_ facility level
#558: FILE: drivers/net/enc28j60.c:483:
+	printk("       0x%02x  ", enc28j60_regb_read(priv, ECON1));

WARNING: printk() should include KERN_ facility level
#564: FILE: drivers/net/enc28j60.c:489:
+	printk("MAC  : MACON1 MACON3 MACON4 MAC-Address\n");

WARNING: printk() should include KERN_ facility level
#565: FILE: drivers/net/enc28j60.c:490:
+	printk("       0x%02x   ", enc28j60_regb_read(priv, MACON1));

WARNING: printk() should include KERN_ facility level
#575: FILE: drivers/net/enc28j60.c:500:
+	printk("Rx   : ERXST  ERXND  ERXWRPT ERXRDPT ERXFCON EPKTCNT MAMXFL\n");

WARNING: printk() should include KERN_ facility level
#576: FILE: drivers/net/enc28j60.c:501:
+	printk("       0x%04x ", enc28j60_regw_read(priv, ERXSTL));

WARNING: printk() should include KERN_ facility level
#584: FILE: drivers/net/enc28j60.c:509:
+	printk("Tx   : ETXST  ETXND  MACLCON1 MACLCON2 MAPHSUP\n");

WARNING: printk() should include KERN_ facility level
#585: FILE: drivers/net/enc28j60.c:510:
+	printk("       0x%04x ", enc28j60_regw_read(priv, ETXSTL));

WARNING: braces {} are not necessary for single statement blocks
#601: FILE: drivers/net/enc28j60.c:526:
+	if ((next_packet_ptr - 1 < start) || (next_packet_ptr - 1 > end)) {
+		erxrdpt = end;
+	} else

WARNING: line over 80 characters
#810: FILE: drivers/net/enc28j60.c:735:
+		 "ExCollision: %d, LateCollision: %d, Giant: %d, Underrun: %d\n",

WARNING: line over 80 characters
#961: FILE: drivers/net/enc28j60.c:886:
+						 "enc28j60 RX, max_pk_cnt: %d\n",

WARNING: line over 80 characters
#965: FILE: drivers/net/enc28j60.c:890:
+			 * don't need to clear interrupt flag, automatically done

WARNING: printk() should include KERN_ facility level
#987: FILE: drivers/net/enc28j60.c:912:
+			printk("\n%04x: ", k);

WARNING: labels should not be indented
#1423: FILE: drivers/net/enc28j60.c:1348:
+      error_register:

WARNING: labels should not be indented
#1425: FILE: drivers/net/enc28j60.c:1350:
+      error_irq:

WARNING: labels should not be indented
#1427: FILE: drivers/net/enc28j60.c:1352:
+      error_buf:

WARNING: labels should not be indented
#1429: FILE: drivers/net/enc28j60.c:1354:
+      error_alloc:

total: 4 errors, 17 warnings, 1703 lines checked

Your patch has style problems, please review.  If any of these errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.

My comments:

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

Use msglvl instead see netdevice.h

+
+#if CONFIG_ENC28J60_DBGLEVEL > 1
+# define VERBOSE_DEBUG
+#endif
+#if CONFIG_ENC28J60_DBGLEVEL > 0
+# define DEBUG
+#endif
+

...
+
+#define MY_TX_TIMEOUT  ((500*HZ)/1000)

That is a really short TX timeout, should be 2 seconds at least not 1/2 sec.
Having it less than a second causes increased wakeups.

+
+/* Max TX retries in case of collision as suggested by errata datasheet */
+#define MAX_TX_RETRYCOUNT	16
+
+/* Driver local data */
+struct enc28j60_net_local {

Rename something shorter like enc28j60_net or just enc28j60?

+	struct net_device_stats stats;

net_device_stats are now in net_device.

+	struct net_device *netdev;
+	struct spi_device *spi;
+	struct semaphore semlock;	/* protect spi_transfer_buf */
Use mutex (or spin_lock) rather than semaphore

+	uint8_t *spi_transfer_buf;
+	struct sk_buff *tx_skb;
+	struct work_struct tx_work;
+	struct work_struct irq_work;

Not sure why you need to have workqueue's for
tx_work and irq_work, rather than using a spin_lock
and doing directly.

+	int bank;			/* current register bank selected */
bank is really unsigned.
	
+	uint16_t next_pk_ptr;		/* next packet pointer within FIFO */
+	int max_pk_counter;		/* statistics: max packet counter */
+	int tx_retry_count;
these are used as unsigned.

+	int hw_enable;
+};
+
+/* Selects Full duplex vs. Half duplex mode */
+static int full_duplex = 0;

Use ethtool for this.

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

If you order functions correctly in code, you don't have to waste lots
of space with all these forward declarations.

...

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

If you use structure initializer you can avoid having to do
the memset


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

...

+/*
+ * Register word read
+ */
+static inline int enc28j60_regw_read(struct enc28j60_net_local *priv,
+				     uint8_t address)
+{

I wouldn't bother marking these as "inline" since the compiler
will decide to inline in most cases.  By telling the compiler to
inline it may generate bigger/slower code.


+	int rl, rh;
+
+	enc28j60_set_bank(priv, address);
+	rl = spi_read_op(priv, ENC28J60_READ_CTRL_REG, address);
+	rh = spi_read_op(priv, ENC28J60_READ_CTRL_REG, address + 1);
+
+	return (rh << 8) | rl;
+}

...

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

Should return -EINVAL/-EBUSY/... instead of printing message.

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
...

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

If you use dev->stats, then you don't need your own get_stats function.


...

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

Rather than having same address, please use random_ether_addr()
to avoid problems with two devices with same ethernet address.

...

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

Why not declare the transfer buffer as an array in spi?

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



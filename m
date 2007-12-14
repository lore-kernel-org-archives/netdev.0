From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: Re: [PATCH 1/2] add driver for enc28j60 ethernet chip
Date: Fri, 14 Dec 2007 10:21:51 +0100
Message-ID: <47624B2F.9010503@eptar.com>
References: <475EA546.7030202@eptar.com> <20071211090648.24ee1742@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay04.albacom.net ([217.220.57.147]:47046 "EHLO
	fe-relay04.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbXLNJVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 04:21:19 -0500
In-Reply-To: <20071211090648.24ee1742@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,
thank you for your suggestions.
I already applied trivial fixes, but I have questions on some points, 
see inline.

Stephen Hemminger wrote:
> General comments:
>   * device driver does no carrier detection. This makes it useless
>     for bridging, bonding, or any form of failover.
>
>   * use msglevel method (via ethtool) to control debug messages
>     rather than kernel configuration. This allows enabling debugging
>     without recompilation which is important in distributions.
>
>   * Please add ethtool support
>
>   * Consider using NAPI
>
>   
Can you point me to a possibly simple driver that uses ethtool and NAPI? 
Or other example that I can use for reference.
May be the skeleton should be updated.

>  * use netdev_priv(netdev) rather than netdev->priv

I can't find where I used netdev->priv, may be do you mean priv->netdev?


> My comments:
>
> diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
> new file mode 100644
> index 0000000..6182473
> --- /dev/null
> +++ b/drivers/net/enc28j60.c
> @@ -0,0 +1,1400 @@
> +/*
> + * Microchip ENC28J60 ethernet driver (MAC + PHY)
> + *
> + * Copyright (C) 2007 Eurek srl
> + * Author: Claudio Lanconelli <lanconelli.claudio@eptar.com>
> + * based on enc28j60.c written by David Anders for 2.4 kernel version
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * $Id: enc28j60.c,v 1.10 2007/12/10 16:59:37 claudio Exp $
> + */
> +
> +#include <linux/autoconf.h>
>
> Use msglvl instead see netdevice.h
>   
Ok
> +
> +#if CONFIG_ENC28J60_DBGLEVEL > 1
> +# define VERBOSE_DEBUG
> +#endif
> +#if CONFIG_ENC28J60_DBGLEVEL > 0
> +# define DEBUG
> +#endif
> +
>
> ...
> +
> +#define MY_TX_TIMEOUT  ((500*HZ)/1000)
>
> That is a really short TX timeout, should be 2 seconds at least not 1/2 sec.
> Having it less than a second causes increased wakeups.
>   
Ok
> +
> +/* Max TX retries in case of collision as suggested by errata datasheet */
> +#define MAX_TX_RETRYCOUNT	16
> +
> +/* Driver local data */
> +struct enc28j60_net_local {
>
> Rename something shorter like enc28j60_net or just enc28j60?
>   
Ok, renamed enc28j60_net
> +	struct net_device_stats stats;
>
> net_device_stats are now in net_device.
>
> +	struct net_device *netdev;
> +	struct spi_device *spi;
> +	struct semaphore semlock;	/* protect spi_transfer_buf */
> Use mutex (or spin_lock) rather than semaphore
>   
Ok
> +	uint8_t *spi_transfer_buf;
> +	struct sk_buff *tx_skb;
> +	struct work_struct tx_work;
> +	struct work_struct irq_work;
>
> Not sure why you need to have workqueue's for
> tx_work and irq_work, rather than using a spin_lock
> and doing directly.
>   
I need irq_work for sure because it needs to go sleep. Any
access to enc28j60 registers are through SPI blocking transaction, 
spi_sync().
I'm not sure if the hard_start_xmit() can go sleep, so I used a work 
queue to tx too.
> +	int bank;			/* current register bank selected */
> bank is really unsigned.
> 	
> +	uint16_t next_pk_ptr;		/* next packet pointer within FIFO */
> +	int max_pk_counter;		/* statistics: max packet counter */
> +	int tx_retry_count;
> these are used as unsigned.
>
> +	int hw_enable;
> +};
> +
> +/* Selects Full duplex vs. Half duplex mode */
> +static int full_duplex = 0;
>
> Use ethtool for this.
>   
Ok
> +
> +static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev);
> +static int enc28j60_net_close(struct net_device *dev);
> +static struct net_device_stats *enc28j60_net_get_stats(struct net_device *dev);
> +static void enc28j60_set_multicast_list(struct net_device *dev);
> +static void enc28j60_net_tx_timeout(struct net_device *ndev);
> +
> +static int enc28j60_chipset_init(struct net_device *dev);
> +static void enc28j60_hw_disable(struct enc28j60_net_local *priv);
> +static void enc28j60_hw_enable(struct enc28j60_net_local *priv);
> +static void enc28j60_hw_rx(struct enc28j60_net_local *priv);
> +static void enc28j60_hw_tx(struct enc28j60_net_local *priv);
>
> If you order functions correctly in code, you don't have to waste lots
> of space with all these forward declarations.
>
> ...
>   
Ok
> +			const char *msg);
> +
> +/*
> + * SPI read buffer
> + * wait for the SPI transfer and copy received data to destination
> + */
> +static int
> +spi_read_buf(struct enc28j60_net_local *priv, int len, uint8_t *data)
> +{
> +	uint8_t *rx_buf;
> +	uint8_t *tx_buf;
> +	struct spi_transfer t;
> +	struct spi_message msg;
> +	int ret, slen;
> +
> +	slen = 1;
> +	memset(&t, 0, sizeof(t));
> +	t.tx_buf = tx_buf = priv->spi_transfer_buf;
> +	t.rx_buf = rx_buf = priv->spi_transfer_buf + 4;
> +	t.len = slen + len;
>
> If you use structure initializer you can avoid having to do
> the memset
>   
Ok
>
> +
> +	down(&priv->semlock);
> +	tx_buf[0] = ENC28J60_READ_BUF_MEM;
> +	tx_buf[1] = tx_buf[2] = tx_buf[3] = 0;	/* don't care */
> +
> +	spi_message_init(&msg);
> +	spi_message_add_tail(&t, &msg);
> +	ret = spi_sync(priv->spi, &msg);
> +	if (ret == 0) {
> +		memcpy(data, &rx_buf[slen], len);
> +		ret = msg.status;
> +	}
> +	up(&priv->semlock);
> +	if (ret != 0)
> +		dev_dbg(&priv->netdev->dev, "%s: failed: ret = %d\n",
> +			__FUNCTION__, ret);
> +
> +	return ret;
> +}
>
> ...
>
> +/*
> + * Register word read
> + */
> +static inline int enc28j60_regw_read(struct enc28j60_net_local *priv,
> +				     uint8_t address)
> +{
>
> I wouldn't bother marking these as "inline" since the compiler
> will decide to inline in most cases.  By telling the compiler to
> inline it may generate bigger/slower code.
>   
Ok
>
> +	int rl, rh;
> +
> +	enc28j60_set_bank(priv, address);
> +	rl = spi_read_op(priv, ENC28J60_READ_CTRL_REG, address);
> +	rh = spi_read_op(priv, ENC28J60_READ_CTRL_REG, address + 1);
> +
> +	return (rh << 8) | rl;
> +}
>
> ...
>
> +/*
> + * Program the hardware MAC address from dev->dev_addr.
> + */
> +static void enc28j60_set_hw_macaddr(struct enc28j60_net_local *priv)
> +{
> +	struct net_device *ndev = priv->netdev;
> +
> +	if (!priv->hw_enable) {
> +		/* NOTE: MAC address in ENC28J60 is byte-backward */
> +		enc28j60_regb_write(priv, MAADR5, ndev->dev_addr[0]);
> +		enc28j60_regb_write(priv, MAADR4, ndev->dev_addr[1]);
> +		enc28j60_regb_write(priv, MAADR3, ndev->dev_addr[2]);
> +		enc28j60_regb_write(priv, MAADR2, ndev->dev_addr[3]);
> +		enc28j60_regb_write(priv, MAADR1, ndev->dev_addr[4]);
> +		enc28j60_regb_write(priv, MAADR0, ndev->dev_addr[5]);
> +
> +		dev_dbg(&ndev->dev,
> +			"%s() [%s] Setting MAC address to "
> +			"%02x:%02x:%02x:%02x:%02x:%02x\n",
> +			__FUNCTION__, ndev->name, ndev->dev_addr[0],
> +			ndev->dev_addr[1], ndev->dev_addr[2], ndev->dev_addr[3],
> +			ndev->dev_addr[4], ndev->dev_addr[5]);
> +	} else
> +		dev_dbg(&ndev->dev,
> +			"%s() Warning: hw must be disabled to set hw "
> +			"Mac address\n", __FUNCTION__);
>
> Should return -EINVAL/-EBUSY/... instead of printing message.
>   
Ok
> +}
> +
> +/*
> + * Store the new hardware address in dev->dev_addr, and update the MAC.
> + */
> +static int enc28j60_set_mac_address(struct net_device *dev, void *addr)
> +{
> +	struct sockaddr *address = addr;
> +	struct enc28j60_net_local *priv = netdev_priv(dev);
> +
> +	if (!is_valid_ether_addr(address->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	memcpy(dev->dev_addr, address->sa_data, dev->addr_len);
> +	enc28j60_set_hw_macaddr(priv);
> +
> +	return 0;
> +}
> ...
>
> +
> +/*
> + * Get the current statistics.
> + * This may be called with the card open or closed.
> + */
> +static struct net_device_stats *enc28j60_net_get_stats(struct net_device *dev)
> +{
> +	struct enc28j60_net_local *priv = netdev_priv(dev);
> +
> +	return &priv->stats;
> +}
>
> If you use dev->stats, then you don't need your own get_stats function.
>   
Ok
>
> ...
>
> +static int enc28j60_hw_init(struct enc28j60_net_local *priv)
> +{
> +	uint8_t reg;
> +
> +	dev_dbg(&priv->spi->dev, "%s() - %s\n",
> +		__FUNCTION__, full_duplex ? "FullDuplex" : "HalfDuplex");
> +	/* first soft reset the chip */
> +	enc28j60_soft_reset(priv);
> +
> +	dev_vdbg(&priv->spi->dev, "%s() bank0\n", __FUNCTION__);
> +
> +	/* Clear ECON1 */
> +	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, ECON1, 0x00);
> +	priv->bank = 0;
> +	priv->hw_enable = 0;
> +	priv->tx_retry_count = 0;
> +
> +	enc28j60_regb_write(priv, ECON2, ECON2_AUTOINC);
> +	enc28j60_rxfifo_init(priv, RXSTART_INIT, RXEND_INIT);
> +	enc28j60_txfifo_init(priv, TXSTART_INIT, TXEND_INIT);
> +
> +	/*
> +	 * Check the RevID.
> +	 * If it's 0x00 or 0xFF probably the enc28j60 is not mounted or
> +	 * damaged
> +	 */
> +	reg = enc28j60_regb_read(priv, EREVID);
> +	if (reg == 0x00 || reg == 0xff)
> +		return 0;
> +
> +	dev_vdbg(&priv->spi->dev, "%s() bank1\n", __FUNCTION__);
> +
> +	/* default filter mode: (unicast OR broadcast) AND crc valid */
> +	enc28j60_regb_write(priv, ERXFCON,
> +			    ERXFCON_UCEN | ERXFCON_CRCEN | ERXFCON_BCEN);
> +
> +	dev_vdbg(&priv->spi->dev, "%s() bank2\n", __FUNCTION__);
> +	/* enable MAC receive */
> +	enc28j60_regb_write(priv, MACON1,
> +			    MACON1_MARXEN | MACON1_TXPAUS | MACON1_RXPAUS);
> +	/* enable automatic padding and CRC operations */
> +	if (full_duplex) {
> +		enc28j60_regb_write(priv, MACON3,
> +				    MACON3_PADCFG0 | MACON3_TXCRCEN |
> +				    MACON3_FRMLNEN | MACON3_FULDPX);
> +		/* set inter-frame gap (non-back-to-back) */
> +		enc28j60_regb_write(priv, MAIPGL, 0x12);
> +		/* set inter-frame gap (back-to-back) */
> +		enc28j60_regb_write(priv, MABBIPG, 0x15);
> +	} else {
> +		enc28j60_regb_write(priv, MACON3,
> +				    MACON3_PADCFG0 | MACON3_TXCRCEN |
> +				    MACON3_FRMLNEN);
> +		enc28j60_regb_write(priv, MACON4, 1 << 6);	/* DEFER bit */
> +		/* set inter-frame gap (non-back-to-back) */
> +		enc28j60_regw_write(priv, MAIPGL, 0x0C12);
> +		/* set inter-frame gap (back-to-back) */
> +		enc28j60_regb_write(priv, MABBIPG, 0x12);
> +	}
> +	/*
> +	 * MACLCON1 (default)
> +	 * MACLCON2 (default)
> +	 * Set the maximum packet size which the controller will accept
> +	 */
> +	enc28j60_regw_write(priv, MAMXFLL, MAX_FRAMELEN);
> +
> +	dev_vdbg(&priv->spi->dev, "%s() bank3\n", __FUNCTION__);
> +	/* NOTE: MAC address in ENC28J60 is byte-backward */
> +	enc28j60_regb_write(priv, MAADR5, ENC28J60_MAC0);
> +	enc28j60_regb_write(priv, MAADR4, ENC28J60_MAC1);
> +	enc28j60_regb_write(priv, MAADR3, ENC28J60_MAC2);
> +	enc28j60_regb_write(priv, MAADR2, ENC28J60_MAC3);
> +	enc28j60_regb_write(priv, MAADR1, ENC28J60_MAC4);
> +	enc28j60_regb_write(priv, MAADR0, ENC28J60_MAC5);
>
> Rather than having same address, please use random_ether_addr()
> to avoid problems with two devices with same ethernet address.
>   
Ok
> ...
>
> +static int __devinit enc28j60_probe(struct spi_device *spi)
> +{
> +	struct net_device *dev;
> +	struct enc28j60_net_local *priv;
> +	int ret = 0;
> +
> +	dev_dbg(&spi->dev, "%s() start\n", __FUNCTION__);
> +
> +	dev = alloc_etherdev(sizeof(struct enc28j60_net_local));
> +	if (!dev) {
> +		ret = -ENOMEM;
> +		goto error_alloc;
> +	}
> +	priv = netdev_priv(dev);
> +
> +	priv->netdev = dev;	/* priv to netdev reference */
> +	priv->spi = spi;	/* priv to spi reference */
> +	priv->spi_transfer_buf = kmalloc(SPI_TRANSFER_BUF_LEN, GFP_KERNEL);
>
> Why not declare the transfer buffer as an array in spi?
>   
I don't understand exactly what do you mean here.
spi field point to struct spi_device from SPI subsystem.
Other SPI client driver uses an allocated buffer too.

Cheers,
Claudio Lanconelli

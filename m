From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]netdev: add driver for enc424j600 ethernet chip on SPI bus
Date: Sat, 29 Jan 2011 12:58:43 +0100
Message-ID: <20110129115842.GA8272@electric-eye.fr.zoreil.com>
References: <AANLkTikSNjq7Ncp4=hLp7-_cayyMad0uQzuHehPr1kSf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mohan@thotakaa.com, blue.cube@seznam.cz,
	lanconelli.claudio@eptar.com,
	Sriram Subramanian <sriram@thotakaa.com>,
	"vbalaji.acs" <vbalaji.acs@gmail.com>
To: Balaji Venkatachalam <balaji.v@thotakaa.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38542 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab1A2MAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 07:00:38 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTikSNjq7Ncp4=hLp7-_cayyMad0uQzuHehPr1kSf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Balaji Venkatachalam <balaji.v@thotakaa.com> :
[...]
> +static int enc424j600_spi_trans(struct enc424j600_net *priv, int len)
> +{
> +	/*modified to suit half duplexed spi */
> +	struct spi_transfer tt = {
> +		.tx_buf = priv->spi_tx_buf,
> +		.len = SPI_OPLEN,
> +	};
> +	struct spi_transfer tr = {
> +		.rx_buf = priv->spi_rx_buf,
> +		.len = len,
> +	};
> +	struct spi_message m;
> +	int ret;
> +
> +	spi_message_init(&m);
> +
> +	spi_message_add_tail(&tt, &m);
> +	spi_message_add_tail(&tr, &m);
> +
> +	ret = spi_sync(priv->spi, &m);
> +
> +	if (ret == 0)
> +		memcpy(priv->spi_rx_buf, tr.rx_buf, len);
> +
> +	if (ret)
> +		dev_err(&priv->spi->dev,
> +			"spi transfer failed: ret = %d\n", ret);
> +	return ret;

	if (ret) {
		dev_err(&priv->spi->dev,
			"spi transfer failed: ret = %d\n", ret);
		goto out;
	}
	memcpy(priv->spi_rx_buf, tr.rx_buf, len);
out:
	return ret;

> +}
> +
> +/*
> + * Read data from chip SRAM.
> + * window = 0 for Receive Buffer
> + * 		  =	1 for User Defined area
> + * 		  =	2 for General Purpose area
> + */
> +static int enc424j600_read_sram(struct enc424j600_net *priv,
> +				u8 *dst, int len, u16 srcaddr, int window)
> +{
> +	int ret;
> +
> +	if (len > SPI_TRANSFER_BUF_LEN - 1 || len <= 0)
> +		return -EINVAL;
> +
> +	/* First set the write pointer as per selected window */
> +	if (window == RXWINDOW)
> +		priv->spi_tx_buf[0] = WRXRDPT;
> +	else if (window == USERWINDOW)
> +		priv->spi_tx_buf[0] = WUDARDPT;
> +	else if (window == GPWINDOW)
> +		priv->spi_tx_buf[0] = WGPRDPT;
> +
> +	priv->spi_tx_buf[1] = srcaddr & 0xFF;
> +	priv->spi_tx_buf[2] = srcaddr >> 8;
> +	ret = spi_write(priv->spi, priv->spi_tx_buf, 3);
> +
> +	/* Transfer the data */
> +	if (window == RXWINDOW)
> +		priv->spi_tx_buf[0] = RRXDATA;
> +	else if (window == USERWINDOW)
> +		priv->spi_tx_buf[0] = RUDADATA;
> +	else if (window == GPWINDOW)
> +		priv->spi_tx_buf[0] = RGPDATA;

May be a local :
	u8 *tx_buf = priv->spi_tx_buf;

> +
> +	ret = enc424j600_spi_trans(priv, len + 1);
> +	/*READ*/
> +	    /* Copy the data from the rx buffer */
        ^^^^
> +	    memcpy(dst, &priv->spi_rx_buf[0], len);
        ^^^^

tab vs spaces

> +
> +	return ret;
> +}
> +
> +/*
> + * Write data to chip SRAM.
> + * window = 1 for RX
> + * window = 2 for User Data
> + * window = 3 for GP
> + */
> +static int enc424j600_write_sram(struct enc424j600_net *priv,
> +				 const u8 *src, int len, u16 dstaddr,
> +				 int window)
> +{
> +	int ret;
> +
> +	if (len > SPI_TRANSFER_BUF_LEN - 1 || len <= 0)
> +		return -EINVAL;
> +
> +	/* First set the general purpose write pointer */
> +	if (window == RXWINDOW)
> +		priv->spi_tx_buf[0] = WRXWRPT;
> +	else if (window == USERWINDOW)
> +		priv->spi_tx_buf[0] = WUDAWRPT;
> +	else if (window == GPWINDOW)
> +		priv->spi_tx_buf[0] = WGPWRPT;
> +
> +	priv->spi_tx_buf[1] = dstaddr & 0xFF;
> +	priv->spi_tx_buf[2] = dstaddr >> 8;
> +	ret = spi_write(priv->spi, priv->spi_tx_buf, 3);
> +
> +	/* Copy the data to the tx buffer */
> +	memcpy(&priv->spi_tx_buf[1], src, len);
> +
> +	/* Transfer the data */
> +	if (window == RXWINDOW)
> +		priv->spi_tx_buf[0] = WRXDATA;
> +	else if (window == USERWINDOW)
> +		priv->spi_tx_buf[0] = WUDADATA;
> +	else if (window == GPWINDOW)
> +		priv->spi_tx_buf[0] = WGPDATA;
> +
> +	ret = spi_write(priv->spi, priv->spi_tx_buf, len + 1);
> +
> +	return ret;
> +}
> +
> +/*
> + * Select the current register bank if necessary to be able to read @addr.
> + */
> +static void enc424j600_set_bank(struct enc424j600_net *priv, u8 addr)
> +{
> +	u8 b = (addr & BANK_MASK) >> BANK_SHIFT;
> +
> +	/* These registers are present in all banks, no need to switch bank */
> +	if (addr >= EUDASTL && addr <= ECON1H)
> +		return;
> +	if (priv->bank == b)
> +		return;
> +
> +	priv->spi_tx_buf[0] = BXSEL(b);
> +
> +	enc424j600_spi_trans(priv, 1);
> +	/*WRITE*/ priv->bank = b;

Please put this comment on a separate line (or remove it completely ?).

> +}
> +
> +/*
> + * Set bits in an 8bit SFR.
> + */
> +static void enc424j600_set_bits(struct enc424j600_net *priv, u8 addr, u8 mask)
> +{
> +	enc424j600_set_bank(priv, addr);
> +	priv->spi_tx_buf[0] = BFS(addr);
> +	priv->spi_tx_buf[1] = mask;
> +	spi_write(priv->spi, priv->spi_tx_buf, 2);
> +}

static void enc424j600_write_bits(struct enc424j600_net *priv, u8 addr,
				  u8 bits, u8 mask)
{
	enc424j600_set_bank(priv, addr);
	priv->spi_tx_buf[0] = bits;
	priv->spi_tx_buf[1] = mask;
	spi_write(priv->spi, priv->spi_tx_buf, 2);
}

enc424j600_write_bits(priv, addr, BFS(addr), mask); ?

> +
> +/*
> + * Clear bits in an 8bit SFR.
> + */
> +static void enc424j600_clear_bits(struct enc424j600_net *priv, u8
> addr, u8 mask)
> +{
> +	enc424j600_set_bank(priv, addr);
> +	priv->spi_tx_buf[0] = BFC(addr);
> +	priv->spi_tx_buf[1] = mask;
> +	spi_write(priv->spi, priv->spi_tx_buf, 2);
> +}

enc424j600_write_bits(priv, addr, BFC(addr), mask); ?


> +
> +/*
> + * Write a 8bit special function register.
> + * The @sfr parameters takes address of the register.
> + * Uses banked write instruction.
> + */
> +static int enc424j600_write_8b_sfr(struct enc424j600_net *priv, u8
> sfr, u8 data)
> +{
> +	int ret;
> +	enc424j600_set_bank(priv, sfr);

Please add an empty line after 'int ret'.

> +
> +	priv->spi_tx_buf[0] = WCR(sfr & ADDR_MASK);
> +	priv->spi_tx_buf[1] = data & 0xFF;
> +	ret = spi_write(priv->spi, priv->spi_tx_buf, 2);
> +
> +	return ret;
> +}
> +
> +/*
> + * Read a 8bit special function register.
> + * The @sfr parameters takes address of the register.
> + * Uses banked read instruction.
> + */
> +static int enc424j600_read_8b_sfr(struct enc424j600_net *priv,
> +				  u8 sfr, u8 *data)
> +{
> +	int ret;
> +
> +	enc424j600_set_bank(priv, sfr);
> +	priv->spi_tx_buf[0] = RCR(sfr & ADDR_MASK);
> +	ret = enc424j600_spi_trans(priv, 2);
> +	/*READ*/ *data = priv->spi_rx_buf[0];

Please put this comment on a separate line (or remove it completely ?).

> +
> +	return ret;
> +}
> +
> +/*
> + * Write a 16bit special function register.
> + * The @sfr parameters takes address of the low byte of the register.
> + * Takes care of the endiannes & buffers.
> + * Uses banked write instruction.
> + */
> +
> +static int enc424j600_write_16b_sfr(struct enc424j600_net *priv,
> +				    u8 sfr, u16 data)
> +{
> +	int ret;
> +	enc424j600_set_bank(priv, sfr);

Please add an empty line after 'int ret'.

> +
> +	priv->spi_tx_buf[0] = WCR(sfr & ADDR_MASK);
> +	priv->spi_tx_buf[1] = data & 0xFF;
> +	priv->spi_tx_buf[2] = data >> 8;
> +	ret = spi_write(priv->spi, priv->spi_tx_buf, 3);
> +	if (ret && netif_msg_drv(priv))
> +		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
> +		       __func__, ret);

Use netif_err ?

> +
> +	return ret;
> +}
> +
> +/*
> + * Read a 16bit special function register.
> + * The @sfr parameters takes address of the low byte of the register.
> + * Takes care of the endiannes & buffers.
> + * Uses banked read instruction.
> + */
> +static int enc424j600_read_16b_sfr(struct enc424j600_net *priv,
> +				   u8 sfr, u16 *data)
> +{
> +	int ret;
> +	enc424j600_set_bank(priv, sfr);

Please add an empty line after 'int ret'.

> +
> +	priv->spi_tx_buf[0] = RCR(sfr & ADDR_MASK);
> +	priv->spi_tx_buf[1] = 0;
> +	priv->spi_tx_buf[2] = 0;
> +	priv->spi_tx_buf[3] = 0;
> +	ret = enc424j600_spi_trans(priv, 3);
> +	/*READ*/ *data = priv->spi_rx_buf[0] | priv->spi_rx_buf[1] << (u16) 8;

Please put this comment on a separate line (or remove it completely ?).

> +
> +	return ret;
> +}
> +
> +static unsigned long msec20_to_jiffies;
> +
> +/*
> + * Wait for bits in register to become equal to @readyMask, but at most 20ms.
> + */
> +static int checktimeout_16bit(struct enc424j600_net *priv,
> +			      u8 reg, u16 mask, u16 readyMask)
> +{
> +	unsigned long timeout = jiffies + msec20_to_jiffies;
> +	u16 value;

Please add an empty line after 'u16 value'.

> +	/* 20 msec timeout read */
> +	enc424j600_read_16b_sfr(priv, reg, &value);
> +	while ((value & mask) != readyMask) {
> +		if (time_after(jiffies, timeout)) {
> +			if (netif_msg_drv(priv))
> +				dev_dbg(&priv->spi->dev,
> +					"reg %02x ready timeout!\n", reg);

Use netif_err (or friend).

> +			return -ETIMEDOUT;
> +		}
> +		cpu_relax();
> +		enc424j600_read_16b_sfr(priv, reg, &value);
> +	}
> +
> +	return 0;
> +}
> +
> +static int checktimeout_8bit(struct enc424j600_net *priv,
> +			     u8 reg, u8 mask, u8 readyMask)
> +{
> +	unsigned long timeout = jiffies + msec20_to_jiffies;
> +	u8 value;

Please add an empty line after 'u8 value'.

> +	/* 20 msec timeout read */
> +	enc424j600_read_8b_sfr(priv, reg, &value);
> +	while ((value & mask) != readyMask) {
> +		if (time_after(jiffies, timeout)) {
> +			if (netif_msg_drv(priv))
> +				dev_dbg(&priv->spi->dev,
> +					"reg %02x ready timeout!\n", reg);
> +			return -ETIMEDOUT;
> +		}
> +		cpu_relax();
> +		enc424j600_read_8b_sfr(priv, reg, &value);
> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * Reset the enc424j600.
> + */
> +static int enc424j600_soft_reset(struct enc424j600_net *priv)
> +{
> +	int ret;
> +	u16 eudast;
> +	if (netif_msg_hw(priv))
> +		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);

Please add an empty line after 'u16 eudast'.

[...]
> +/*Debug routine to dump useful register contents*/
> +static void enc424j600_dump_regs(struct enc424j600_net *priv, const char *msg)
> +{
[...]

Could the same goal be achieved with ethtool_ops.get_regs ?

Otherwise you can grep for debugfs.h below drivers/net.

[...]
> +static int enc424j600_net_open(struct net_device *dev)
> +{
> +	struct enc424j600_net *priv = netdev_priv(dev);
> +
> +	if (netif_msg_drv(priv))
> +		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
> +
> +	if (!is_valid_ether_addr(dev->dev_addr)) {
> +		if (netif_msg_ifup(priv))
> +			dev_err(&dev->dev, "invalid MAC address %pM\n",
> +				dev->dev_addr);
> +		return -EADDRNOTAVAIL;
> +	}
> +	/* Reset the hardware here (and take it out of low power mode) */
> +	enc424j600_lowpower(priv, false);
> +	enc424j600_hw_disable(priv);
> +	if (!enc424j600_hw_init(priv)) {
> +		if (netif_msg_ifup(priv))
> +			dev_err(&dev->dev, "hw_reset() failed\n");
> +		return -EINVAL;

Propagate the return status code of enc424j600_hw_init ?

> +	}
> +	/* Update the MAC address (in case user has changed it) */
> +	enc424j600_set_hw_macaddr(dev);
> +	/* Enable interrupts */
> +	enc424j600_hw_enable(priv);
> +	/* check link status */
> +	enc424j600_check_link_status(priv);
> +	/* We are now ready to accept transmit requests from
> +	 * the queueing layer of the networking.
> +	 */
> +	netif_start_queue(dev);
> +
> +	return 0;
> +}
[...]
> +static const struct ethtool_ops enc424j600_ethtool_ops = {
> +	.get_settings = enc424j600_get_settings,
> +	.set_settings = enc424j600_set_settings,
> +	.get_drvinfo = enc424j600_get_drvinfo,
> +	.get_msglevel = enc424j600_get_msglevel,
> +	.set_msglevel = enc424j600_set_msglevel,

Please <tab>=<space>

> +};
> +
> +static int enc424j600_chipset_init(struct net_device *dev)
> +{
> +	struct enc424j600_net *priv = netdev_priv(dev);
> +
> +	enc424j600_get_hw_macaddr(dev);
> +	return enc424j600_hw_init(priv);
> +
> +}

Remove the empty line after the return statement.

> +
> +static const struct net_device_ops enc424j600_netdev_ops = {
> +	.ndo_open = enc424j600_net_open,
> +	.ndo_stop = enc424j600_net_close,
> +	.ndo_start_xmit = enc424j600_send_packet,
> +	.ndo_set_multicast_list = enc424j600_set_multicast_list,
> +	.ndo_set_mac_address = enc424j600_set_mac_address,
> +	.ndo_tx_timeout = enc424j600_tx_timeout,
> +	.ndo_change_mtu = eth_change_mtu,
> +	.ndo_validate_addr = eth_validate_addr,
> +};
> +
> +static int __devinit enc424j600_probe(struct spi_device *spi)
> +{
> +	struct net_device *dev;
> +	struct enc424j600_net *priv;
> +	int ret = 0;

	int ret = -ENOMEM;

Then simplify code below.

> +
> +	if (netif_msg_drv(&debug))
> +		dev_info(&spi->dev, DRV_NAME " Ethernet driver %s loaded\n",
> +			 DRV_VERSION);
> +
> +	dev = alloc_etherdev(sizeof(struct enc424j600_net));
> +	if (!dev) {
> +		if (netif_msg_drv(&debug))
> +			dev_err(&spi->dev, DRV_NAME
> +				": unable to alloc new ethernet\n");
> +		ret = -ENOMEM;
> +		goto error_alloc;
> +	}
> +	priv = netdev_priv(dev);
> +
> +	priv->netdev = dev;	/* priv to netdev reference */
> +	priv->spi = spi;	/* priv to spi reference */
> +	priv->msg_enable = netif_msg_init(debug.msg_enable,
> +					  ENC424J600_MSG_DEFAULT);
> +	mutex_init(&priv->lock);
> +	INIT_WORK(&priv->tx_work, enc424j600_tx_work_handler);
> +	INIT_WORK(&priv->setrx_work, enc424j600_setrx_work_handler);
> +	INIT_WORK(&priv->irq_work, enc424j600_irq_work_handler);
> +	INIT_WORK(&priv->restart_work, enc424j600_restart_work_handler);
> +	dev_set_drvdata(&spi->dev, priv);	/* spi to priv reference */

The three comments above are useless.

> +	SET_NETDEV_DEV(dev, &spi->dev);
> +	/*TODO: chip DMA features to be utilized */
> +	/* If requested, allocate DMA buffers */
> +	if (enc424j600_enable_dma) {
> +		spi->dev.coherent_dma_mask = ~0;
> +
> +		/*
> +		 * Minimum coherent DMA allocation is PAGE_SIZE, so allocate
> +		 * that much and share it between Tx and Rx DMA buffers.
> +		 */
> +#if SPI_TRANSFER_BUF_LEN > PAGE_SIZE / 2
> +#error "A problem in DMA buffer allocation"
> +#endif
> +		priv->spi_tx_buf = dma_alloc_coherent(&spi->dev,
> +						      PAGE_SIZE,
> +						      &priv->spi_tx_dma,
> +						      GFP_DMA);
> +
> +		if (priv->spi_tx_buf) {
> +			priv->spi_rx_buf = (u8 *) (priv->spi_tx_buf +
> +						   (PAGE_SIZE / 2));
			priv->spi_rx_buf =
				(u8 *) (priv->spi_tx_buf + (PAGE_SIZE / 2));

> +			priv->spi_rx_dma = (dma_addr_t) (priv->spi_tx_dma +
> +							 (PAGE_SIZE / 2));


> +		} else {
> +			/* Fall back to non-DMA */
> +			enc424j600_enable_dma = 0;
> +		}
> +	}
> +
> +	/* Allocate non-DMA buffers */
> +	if (!enc424j600_enable_dma) {
> +		priv->spi_tx_buf = kmalloc(SPI_TRANSFER_BUF_LEN, GFP_KERNEL);
> +		if (!priv->spi_tx_buf) {
> +			ret = -ENOMEM;
> +			goto error_tx_buf;

Please: 
			goto error_what_must_be_done;
instead of:
			goto error_where_it_comes_from;

> +		}
> +		priv->spi_rx_buf = kmalloc(SPI_TRANSFER_BUF_LEN, GFP_KERNEL);
> +		if (!priv->spi_rx_buf) {
> +			ret = -ENOMEM;
> +			goto error_rx_buf;
> +		}
> +	}
> +
> +	if (!enc424j600_chipset_init(dev)) {
> +		if (netif_msg_probe(priv))
> +			dev_info(&spi->dev, DRV_NAME " chip not found\n");
> +		ret = -EIO;
> +		goto error_irq;
> +	}
> +
> +	/* Board setup must set the relevant edge trigger type;
> +	 * level triggers won't currently work.
> +	 */
> +	ret = request_irq(spi->irq, enc424j600_irq, 0, DRV_NAME, priv);
> +	if (ret < 0) {
> +		if (netif_msg_probe(priv))
> +			dev_err(&spi->dev, DRV_NAME ": request irq %d failed "
> +				"(ret = %d)\n", spi->irq, ret);
> +		goto error_irq;
> +	}
> +
> +	dev->if_port = IF_PORT_10BASET;
> +	dev->irq = spi->irq;
> +	dev->netdev_ops = &enc424j600_netdev_ops;
> +	dev->watchdog_timeo = TX_TIMEOUT;
> +	SET_ETHTOOL_OPS(dev, &enc424j600_ethtool_ops);
> +
> +	enc424j600_lowpower(priv, true);
> +
> +	ret = register_netdev(dev);
> +	if (ret) {
> +		if (netif_msg_probe(priv))
> +			dev_err(&spi->dev, "register netdev " DRV_NAME
> +				" failed (ret = %d)\n", ret);
> +		goto error_register;
> +	}
> +	dev_info(&dev->dev, DRV_NAME " driver registered\n");
> +
> +	return 0;

out:
	return ret;

> +
> +error_register:
> +	free_irq(spi->irq, priv);
> +error_irq:
> +	free_netdev(dev);
> +	if (!enc424j600_enable_dma)
> +		kfree(priv->spi_rx_buf);
> +error_rx_buf:
> +	if (!enc424j600_enable_dma)
> +		kfree(priv->spi_tx_buf);
> +error_tx_buf:
> +	if (enc424j600_enable_dma) {
> +		dma_free_coherent(&spi->dev, PAGE_SIZE,
> +				  priv->spi_tx_buf, priv->spi_tx_dma);
> +	}
> +error_alloc:
> +	return ret;
> +}

-- 
Ueimor

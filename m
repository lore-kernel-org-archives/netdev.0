From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next v6 1/3] ieee802154: cc2520: adds driver for TI
 CC2520 radio
Date: Fri, 20 Jun 2014 10:32:20 +0200
Message-ID: <20140620083218.GA4116@omega>
References: <1403243294-15400-1-git-send-email-varkab@cdac.in>
 <1403243294-15400-2-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	davem@davemloft.net, devicetree@vger.kernel.org, sowjanyap@cdac.in,
	venkatas@cdac.in, santoshk@cdac.in, Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:51029 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932937AbaFTIc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 04:32:27 -0400
Content-Disposition: inline
In-Reply-To: <1403243294-15400-2-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Varka,

sorry for my careful reviewing...,, but I had also some patch series
which was at v8 or something like that. :-)

On Fri, Jun 20, 2014 at 11:18:12AM +0530, Varka Bhadram wrote:
> This patch adds the driver support for the cc2520 radio.
> 
> Driver support:
>         - Tx and Rx of IEEE-802.15.4 packets.
>         - Energy Detection on channel.
>         - Setting the Channel for the radio. [b/w 11 - 26 channels]
>         - Start and Stop the radio
>         - h/w address filtering.
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>  drivers/net/ieee802154/cc2520.c | 1045 +++++++++++++++++++++++++++++++++++++++
>  include/linux/spi/cc2520.h      |   26 +
>  2 files changed, 1071 insertions(+)
>  create mode 100644 drivers/net/ieee802154/cc2520.c
>  create mode 100644 include/linux/spi/cc2520.h
> 
> diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/cc2520.c
> new file mode 100644
> index 0000000..fff7fd2
> --- /dev/null
> +++ b/drivers/net/ieee802154/cc2520.c
> @@ -0,0 +1,1045 @@
> +/* Driver for TI CC2520 802.15.4 Wireless-PAN Networking controller
> + *
> + * Copyright (C) 2014 Varka Bhadram <varkab@cdac.in>
> + *		      Md.Jamal Mohiuddin <mjmohiuddin@cdac.in>
> + *		      P Sowjanya <sowjanyap@cdac.in>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + */
> +

...

> +
> +/* Driver private information */
> +struct cc2520_private {
> +	struct spi_device *spi;		/* spi device structure */
> +	struct ieee802154_dev *dev;	/* Ieee802.15.4 device */

why lowercase IEEE in the comment? :-)

> +	u8 *buf;			/* SPI TX/Rx data buffer */
> +	struct mutex buffer_mutex;	/* SPI buffer mutex */
> +	unsigned is_tx:1;		/* Flag for sync b/w Tx and Rx */

bool/int?

> +	int fifo_pin;			/* FIFO GPIO pin number */
> +	struct work_struct fifop_irqwork;/* Workqueue for FIFOP */
> +	spinlock_t lock;		/* Spin lock */

Everyone knows that this is a spinlock and I know checkpatch print some
warning if there is a lock without comment. But they mean more "spinlock
for what" in your case is_tx.

...

> +
> +static int cc2520_rx(struct cc2520_private *priv)
> +{
> +	u8 len = 0, lqi = 0, bytes = 1;
> +	struct sk_buff *skb;
> +
> +	cc2520_read_rxfifo(priv, &len, bytes, &lqi);
> +
> +	if (len < 2 || len > IEEE802154_MTU)
> +		return -EINVAL;
> +
> +	skb = alloc_skb(len, GFP_KERNEL);
> +	if (!skb)
> +		return -ENOMEM;
> +
> +	if (cc2520_read_rxfifo(priv, skb_put(skb, len), len, &lqi)) {
> +		pr_debug("frame reception failed\n");

why pr_debug here? Use dev_dbg like the others, then we know which
device this message prints.

> +		kfree_skb(skb);
> +		return -EINVAL;
> +	}
> +
> +	skb_trim(skb, skb->len - 2);
> +
> +	ieee802154_rx_irqsafe(priv->dev, skb, lqi);
> +
> +	dev_vdbg(&priv->spi->dev, "RXFIFO: %x %x\n", len, lqi);
> +
> +	return 0;
> +}
> +
...
> +
> +	ret = cc2520_register(priv);
> +	if (ret)
> +		goto err_hw_init;
> +
> +	return 0;
> +
> +err_hw_init:
> +	mutex_destroy(&priv->buffer_mutex);
> +	flush_work(&priv->fifop_irqwork);
> +
> +err_ret:
> +	return ret;
> +}
> +
> +static int cc2520_remove(struct spi_device *spi)
> +{
> +	struct cc2520_private *priv = spi_get_drvdata(spi);
> +
> +	ieee802154_unregister_device(priv->dev);
> +	ieee802154_free_device(priv->dev);
> +
> +	mutex_destroy(&priv->buffer_mutex);
> +	flush_work(&priv->fifop_irqwork);

You need to call ieee802154_free_device at this point. The reason is
that ieee802154_free_device free's your priv allocated data drom
ieee802154_alloc_device. Did you test a "rmmod cc2520" with cc2520 as
module support?

Please do that and also verify that you need not to mask all interrupts
before unloading (I had some experience with the at86rf230 chip). Means
test "rmmod cc2520" while transmit some packages.

- Alex

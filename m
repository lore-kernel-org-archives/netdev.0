From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next 1/3] ieee802154: cc2520:
 driver for TI cc2520 radio
Date: Mon, 16 Jun 2014 09:38:55 +0200
Message-ID: <20140616073853.GA20343@omega>
References: <1402894318-30349-1-git-send-email-varkab@cdac.in>
 <1402894318-30349-2-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Varka Bhadram <varkab@cdac.in>,
	linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1402894318-30349-2-git-send-email-varkab@cdac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Varka,

On Mon, Jun 16, 2014 at 10:21:56AM +0530, Varka Bhadram wrote:
> 

Maybe some more information about this chip in the commit msg?

> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>  drivers/net/ieee802154/cc2520.c |  805 +++++++++++++++++++++++++++++++++++++++
>  include/linux/spi/cc2520.h      |  176 +++++++++
>  2 files changed, 981 insertions(+)
>  create mode 100644 drivers/net/ieee802154/cc2520.c
>  create mode 100644 include/linux/spi/cc2520.h
> 
> diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/cc2520.c
> new file mode 100644
> index 0000000..e8b5993
> --- /dev/null
> +++ b/drivers/net/ieee802154/cc2520.c
> @@ -0,0 +1,805 @@
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
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/gpio.h>
> +#include <linux/delay.h>
> +#include <linux/spi/spi.h>
> +#include <linux/spi/cc2520.h>
> +#include <linux/workqueue.h>
> +#include <linux/interrupt.h>
> +
> +#include <linux/skbuff.h>
> +
> +#include <linux/pinctrl/consumer.h>
> +
> +#include <linux/of_device.h>
> +#include <linux/of_platform.h>
> +#include <linux/of_gpio.h>
> +
> +#include <net/mac802154.h>
> +#include <net/wpan-phy.h>
> +
> +#define	SPI_COMMAND_BUFFER	3
> +#define	HIGH			1
> +#define	LOW			0
> +#define	STATE_IDLE		0
> +
> +/*Driver private information */
> +struct cc2520_private {
> +	struct spi_device *spi;
> +
> +	struct ieee802154_dev *dev;
> +
> +	u8 *buf;
> +	struct mutex buffer_mutex;
> +
> +	unsigned is_tx:1;
> +	int fifo_irq;
> +
> +	int fifo_pin;
> +	int fifop_pin;
> +
> +	struct work_struct fifop_irqwork;
> +
> +	spinlock_t lock;
> +
> +	struct completion tx_complete;
> +};
> +
> +/*Generic Functions*/
> +static int cc2520_cmd_strobe(struct cc2520_private *priv,
> +						u8 cmd)
> +{
> +	int ret;
> +	u8 status = 0xff;
> +	struct spi_message msg;
> +	struct spi_transfer xfer = {
> +		.len = 0,
> +		.tx_buf = priv->buf,
> +		.rx_buf = priv->buf,
> +	};
> +
> +	spi_message_init(&msg);
> +	spi_message_add_tail(&xfer, &msg);

I see, you maybe looked at others drivers like at86rf230 and see what
they do there. I really don't like the lowlevel spi calls in the others
drivers. There are spi helper functions like 'spi_write_then_read' look
in drivers/spi/spi.c for the helper functions. Then you don't need the
buffer_mutex also.

> +
> +	mutex_lock(&priv->buffer_mutex);
> +	priv->buf[xfer.len++] = cmd;
> +	dev_vdbg(&priv->spi->dev,
> +			"command strobe buf[0] = %02x\n",
> +			priv->buf[0]);
> +
> +	ret = spi_sync(priv->spi, &msg);
> +	if (!ret)
> +		status = priv->buf[0];
> +	dev_vdbg(&priv->spi->dev,
> +			"buf[0] = %02x\n", priv->buf[0]);
> +	mutex_unlock(&priv->buffer_mutex);
> +
> +	return ret;
> +}
> +

....

> +
> +static void cc2520_unregister(struct cc2520_private *priv)
> +{
> +	ieee802154_unregister_device(priv->dev);
> +	ieee802154_free_device(priv->dev);
> +}

Only used in remove callback of module. It's small enough to do this in
the remove callback.

> +
> +static void cc2520_fifop_irqwork(struct work_struct *work)
> +{
> +	struct cc2520_private *priv
> +		= container_of(work, struct cc2520_private, fifop_irqwork);
> +
> +	dev_dbg(&priv->spi->dev, "fifop interrupt received\n");
> +
> +	if (gpio_get_value(priv->fifo_pin))
> +		cc2520_rx(priv);
> +	else
> +		dev_err(&priv->spi->dev, "rxfifo overflow\n");
> +
> +	cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHRX);
> +	cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHRX);
> +}
> +
> +static irqreturn_t cc2520_fifop_isr(int irq, void *data)
> +{
> +	struct cc2520_private *priv = data;
> +
> +	schedule_work(&priv->fifop_irqwork);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static irqreturn_t cc2520_sfd_isr(int irq, void *data)
> +{
> +	struct cc2520_private *priv = data;
> +
> +	spin_lock(&priv->lock);

You need to use here spin_lock_irqsave and spin_unlock_irqrestore here.
Please verify you locking with PROVE_LOCKING enabled in your kernel.

In your xmit callback you use a irqsave spinlocks there. You need always
save to the "strongest" context which is a interrupt in your case.

> +	if (priv->is_tx) {
> +		dev_dbg(&priv->spi->dev, "SFD for TX\n");
> +		priv->is_tx = 0;
> +		complete(&priv->tx_complete);
> +	} else
> +		dev_dbg(&priv->spi->dev, "SFD for RX\n");

make brackets in the else branch if you have brackets in the "if" branch.

You don't need to lock all the things here I think:

--snip
	spin_lock_irqsave(&priv->lock, flags);
	if (priv->is_tx) {
		priv->is_tx = 0;
		spin_unlock_irqrestore(&priv->lock, flags);
		dev_dbg(&priv->spi->dev, "SFD for TX\n");
		complete(&priv->tx_complete);
	} else {
		spin_unlock_irqrestore(&priv->lock, flags);
		dev_dbg(&priv->spi->dev, "SFD for RX\n");
	}
--snap

> +	spin_unlock(&priv->lock);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static int cc2520_hw_init(struct cc2520_private *priv)
> +{
> +	u8 status = 0, state = 0xff;
> +	int ret;
> +	int timeout = 100;
> +
> +	ret = cc2520_read_register(priv, CC2520_FSMSTAT1, &state);
> +	if (ret)
> +		goto err_ret;
> +
> +	if (state != STATE_IDLE) {
> +		ret = -EINVAL;
> +		return ret;

return -EINVAL? saves the brackets ;)

> +	}
> +
> +	do {
> +		ret = cc2520_get_status(priv, &status);
> +		if (ret)
> +			goto err_ret;
> +
> +		if (timeout-- <= 0) {
> +			dev_err(&priv->spi->dev, "oscillator start failed!\n");
> +			return ret;
> +		}
> +		udelay(1);
> +	} while (!(status & CC2520_STATUS_XOSC32M_STABLE));
> +
> +	dev_vdbg(&priv->spi->dev, "oscillator successfully brought up\n");
> +
> +	/*Registers default value: section 28.1 in Datasheet*/
> +	ret = cc2520_write_register(priv, CC2520_TXPOWER, 0xF7);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_CCACTRL0, 0x1A);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_MDMCTRL0, 0x85);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_MDMCTRL1, 0x14);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_RXCTRL, 0x3f);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_FSCTRL, 0x5a);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_FSCAL1, 0x2b);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_AGCCTRL1, 0x11);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_ADCTEST0, 0x10);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_ADCTEST1, 0x0e);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_ADCTEST2, 0x03);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_FRMCTRL0, 0x60);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_FRMCTRL1, 0x03);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_FRMFILT0, 0x00);
> +	if (ret)
> +		goto err_ret;
> +
> +	ret = cc2520_write_register(priv, CC2520_FIFOPCTRL, 127);
> +	if (ret)
> +		goto err_ret;
> +
> +	return 0;
> +
> +err_ret:
> +	return ret;
> +}
> +
> +static struct cc2520_platform_data *
> +cc2520_get_platform_data(struct spi_device *spi)
> +{
> +	struct cc2520_platform_data *pdata;
> +	struct device_node __maybe_unused *np = spi->dev.of_node;
> +	struct cc2520_private *priv = spi_get_drvdata(spi);
> +
> +	if (!IS_ENABLED(CONFIG_OF) || !np)
> +		return spi->dev.platform_data;
> +
> +	pdata = devm_kzalloc(&spi->dev, sizeof(*pdata), GFP_KERNEL);
> +	if (!pdata)
> +		goto done;
> +
> +	pdata->fifo = of_get_named_gpio(np, "fifo-gpio", 0);
> +	priv->fifo_pin = pdata->fifo;
> +
> +	pdata->fifop = of_get_named_gpio(np, "fifop-gpio", 0);
> +	priv->fifop_pin = pdata->fifop;
> +
> +	pdata->sfd = of_get_named_gpio(np, "sfd-gpio", 0);
> +	pdata->cca = of_get_named_gpio(np, "cca-gpio", 0);
> +	pdata->vreg = of_get_named_gpio(np, "vreg-gpio", 0);
> +	pdata->reset = of_get_named_gpio(np, "reset-gpio", 0);
> +
> +	spi->dev.platform_data = pdata;
> +
> +done:
> +	return pdata;
> +}
> +
> +/*Driver probe function*/
> +static int cc2520_probe(struct spi_device *spi)
> +{
> +	struct cc2520_private *priv;
> +	struct pinctrl *pinctrl;
> +	struct cc2520_platform_data *pdata;
> +	struct device_node __maybe_unused *np = spi->dev.of_node;
> +	int ret;
> +
> +	priv = kzalloc(sizeof(struct cc2520_private), GFP_KERNEL);
> +	if (!priv) {
> +		ret = -ENOMEM;
> +		goto err_free_local;
> +	}

why not devm_ calls?

> +
> +	spi_set_drvdata(spi, priv);
> +
> +	pinctrl = devm_pinctrl_get_select_default(&spi->dev);
> +	if (IS_ERR(pinctrl))
> +		dev_warn(&spi->dev,
> +			"pinctrl pins are not configured from the driver");
> +
> +	pdata = cc2520_get_platform_data(spi);
> +	if (!pdata) {
> +		dev_err(&spi->dev, "no platform data\n");
> +		return -EINVAL;
memory leak of priv here.

> +	}
> +
> +	mutex_init(&priv->buffer_mutex);
> +	INIT_WORK(&priv->fifop_irqwork, cc2520_fifop_irqwork);

I really don't like also the workqueue here. The at86rf230 use also a
workqueue but the mrf24j40 uses 'devm_request_threaded_irq'. A threaded
irq can also handle sync spi calls.

> +	spin_lock_init(&priv->lock);
> +	init_completion(&priv->tx_complete);
> +
> +	priv->spi = spi;
> +
> +	priv->buf = kzalloc(SPI_COMMAND_BUFFER, GFP_KERNEL);
> +	if (!priv->buf) {
> +		ret = -ENOMEM;
> +		goto err_free_buf;
> +	}
> +
> +	/*Request all the gpio's*/
> +	if (gpio_is_valid(pdata->fifo)) {
> +		ret = devm_gpio_request_one(&spi->dev, pdata->fifo, 
> +					GPIOF_IN, "fifo");
> +		if (ret)
> +			goto err_hw_init;
> +	}
> +
> +	if (gpio_is_valid(pdata->cca)) {
> +		ret = devm_gpio_request_one(&spi->dev, pdata->cca,
> +					GPIOF_IN, "cca");
> +		if (ret)
> +			goto err_hw_init;
> +	}
> +
> +	if (gpio_is_valid(pdata->fifop)) {
> +		ret = devm_gpio_request_one(&spi->dev, pdata->fifop,
> +					GPIOF_IN, "fifop");
> +		if (ret)
> +			goto err_hw_init;
> +	}
> +
> +	if (gpio_is_valid(pdata->sfd)) {
> +		ret = devm_gpio_request_one(&spi->dev, pdata->sfd,
> +					GPIOF_IN, "sfd");
> +		if (ret)
> +			goto err_hw_init;
> +	}
> +
> +	if (gpio_is_valid(pdata->reset)) {
> +		ret = devm_gpio_request_one(&spi->dev, pdata->reset,
> +					GPIOF_OUT_INIT_LOW, "reset");
> +		if (ret)
> +			goto err_hw_init;
> +	}
> +
> +	if (gpio_is_valid(pdata->vreg)) {
> +		ret = devm_gpio_request_one(&spi->dev, pdata->vreg,
> +					GPIOF_OUT_INIT_LOW, "vreg");
> +		if (ret)
> +			goto err_hw_init;
> +	}

You should check on the not optional pins if you can request them. You
use in the above code the pins vreg, reset, fifo_irq, sfd. And this
failed if the gpio's are not valid.

means:

if (!gpio_is_valid(pdata->vreg)) {
	dev_err(....)
	ret = -EINVAL;
	goto ...;
}

on all pins which are needed to use your chip.

> +
> +	gpio_set_value(pdata->vreg, HIGH);
> +	udelay(100);
> +
> +	gpio_set_value(pdata->reset, HIGH);
> +	udelay(200);
> +
> +	ret = cc2520_hw_init(priv);
> +	if (ret)
> +		goto err_hw_init;
> +
> +	/*Set up fifop interrupt */
> +	priv->fifo_irq = gpio_to_irq(pdata->fifop);

why is fifo_irq in your "private data"? This is only used in this function.

> +	ret = devm_request_irq(&spi->dev,
> +				priv->fifo_irq,
> +				cc2520_fifop_isr,
> +				IRQF_TRIGGER_RISING,
> +				dev_name(&spi->dev),
> +				priv);
> +	if (ret) {
> +		dev_err(&spi->dev, "could not get fifop irq\n");
> +		goto err_hw_init;
> +	}
> +
> +	/*Set up sfd interrupt*/
> +	ret = devm_request_irq(&spi->dev,
> +				gpio_to_irq(pdata->sfd),
> +				cc2520_sfd_isr,
> +				IRQF_TRIGGER_FALLING,
> +				dev_name(&spi->dev),
> +				priv);
> +	if (ret) {
> +		dev_err(&spi->dev, "could not get sfd irq\n");
> +		goto err_hw_init;
> +	}
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
> +err_free_buf:
> +	kfree(priv->buf);
> +
> +err_free_local:
> +	kfree(priv);
> +
> +	return ret;
> +}
> +
> +/*Driver remove function*/
> +static int cc2520_remove(struct spi_device *spi)
> +{
> +	struct cc2520_private *priv = spi_get_drvdata(spi);
> +
> +	cc2520_unregister(priv);
> +
> +	mutex_destroy(&priv->buffer_mutex);
> +	flush_work(&priv->fifop_irqwork);
> +
> +	kfree(priv->buf);
> +	kfree(priv);
> +
> +	return 0;
> +}
> +
> +static const struct spi_device_id cc2520_ids[] = {
> +	{"cc2520", 0},
You don't need to set the driver_data to 0. Simple:
	{ "cc2520", },

> +	{},
> +};
> +MODULE_DEVICE_TABLE(spi, cc2520_ids);
> +
> +static const struct of_device_id cc2520_of_ids[] = {
> +	{.compatible = "ti,cc2520", },
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, cc2520_of_ids);
> +
> +/*SPI Driver Structure*/
> +static struct spi_driver cc2520_driver = {
> +	.driver = {
> +		.name = "cc2520",
> +		.bus = &spi_bus_type,
> +		.owner = THIS_MODULE,
> +		.of_match_table = of_match_ptr(cc2520_of_ids),
> +	},
> +	.id_table = cc2520_ids,
> +	.probe = cc2520_probe,
> +	.remove = cc2520_remove,
> +};
> +module_spi_driver(cc2520_driver);
> +
> +MODULE_DESCRIPTION("CC2520 Transceiver Driver");
> +MODULE_LICENSE("GPL v2");
> diff --git a/include/linux/spi/cc2520.h b/include/linux/spi/cc2520.h
> new file mode 100644
> index 0000000..68a2c88
> --- /dev/null
> +++ b/include/linux/spi/cc2520.h

In this location of header files are platform_data structs only. I think
you should leave the cc2520_platform_data in this file and move the rest
of declaration to you cc2520.c file.

> @@ -0,0 +1,176 @@
> +#ifndef __CC2520_H
> +#define __CC2520_H
> +
> +#define RSSI_VALID		0
> +#define RSSI_OFFSET		78
> +#define CC2520_FREG_MASK	0x3F
> +
> +struct cc2520_platform_data {
> +	int fifo;
> +	int fifop;
> +	int cca;
> +	int sfd;
> +	int reset;
> +	int vreg;
> +};
> +

- Alex

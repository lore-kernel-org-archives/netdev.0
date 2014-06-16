From: Varka Bhadram <varkab@cdac.in>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next 1/3] ieee802154: cc2520:
 driver for TI cc2520 radio
Date: Mon, 16 Jun 2014 14:21:19 +0530
Message-ID: <539EB007.9000302@cdac.in>
References: <1402894318-30349-1-git-send-email-varkab@cdac.in> <1402894318-30349-2-git-send-email-varkab@cdac.in> <20140616073853.GA20343@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: Alexander Aring <alex.aring@gmail.com>,
	Varka Bhadram <varkabhadram@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140616073853.GA20343@omega>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alex,

Thanks for the comments.

I will create a patch for the required changes with Reported-by 
Alexander Aring  <...> reply if this is okay for you.


On 06/16/2014 01:08 PM, Alexander Aring wrote:
> Hi Varka,
>
> On Mon, Jun 16, 2014 at 10:21:56AM +0530, Varka Bhadram wrote:
> Maybe some more information about this chip in the commit msg?
I will provide the proper commit messages in next version
>
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
> I see, you maybe looked at others drivers like at86rf230 and see what
> they do there. I really don't like the lowlevel spi calls in the others
> drivers. There are spi helper functions like 'spi_write_then_read' look
> in drivers/spi/spi.c for the helper functions. Then you don't need the
> buffer_mutex also.
In at86rf230 driver first it hold the mutex lock for buffer then 
__at86rf230_read_subreg()/ __at86rf230_write()
functions called. One more thing is that at the low level spi core is 
holding the lock for the buffer data.
We can remove the buffer mutex.
>> +
>> +	mutex_lock(&priv->buffer_mutex);
>> +	priv->buf[xfer.len++] = cmd;
>> +	dev_vdbg(&priv->spi->dev,
>> +			"command strobe buf[0] = %02x\n",
>> +			priv->buf[0]);
>> +
>> +	ret = spi_sync(priv->spi, &msg);
>> +	if (!ret)
>> +		status = priv->buf[0];
>> +	dev_vdbg(&priv->spi->dev,
>> +			"buf[0] = %02x\n", priv->buf[0]);
>> +	mutex_unlock(&priv->buffer_mutex);
>> +
>> +	return ret;
>> +}
>> +
> ....
>
>> +
>> +static void cc2520_unregister(struct cc2520_private *priv)
>> +{
>> +	ieee802154_unregister_device(priv->dev);
>> +	ieee802154_free_device(priv->dev);
>> +}
> Only used in remove callback of module. It's small enough to do this in
> the remove callback.
>
Ya its nice . We can save the cpu context switching time also....
>> +
>> +static void cc2520_fifop_irqwork(struct work_struct *work)
>> +{
>> +	struct cc2520_private *priv
>> +		= container_of(work, struct cc2520_private, fifop_irqwork);
>> +
>> +	dev_dbg(&priv->spi->dev, "fifop interrupt received\n");
>> +
>> +	if (gpio_get_value(priv->fifo_pin))
>> +		cc2520_rx(priv);
>> +	else
>> +		dev_err(&priv->spi->dev, "rxfifo overflow\n");
>> +
>> +	cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHRX);
>> +	cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHRX);
>> +}
>> +
>> +static irqreturn_t cc2520_fifop_isr(int irq, void *data)
>> +{
>> +	struct cc2520_private *priv = data;
>> +
>> +	schedule_work(&priv->fifop_irqwork);
>> +
>> +	return IRQ_HANDLED;
>> +}
>> +
>> +static irqreturn_t cc2520_sfd_isr(int irq, void *data)
>> +{
>> +	struct cc2520_private *priv = data;
>> +
>> +	spin_lock(&priv->lock);
> You need to use here spin_lock_irqsave and spin_unlock_irqrestore here.
> Please verify you locking with PROVE_LOCKING enabled in your kernel.
>
> In your xmit callback you use a irqsave spinlocks there. You need always
> save to the "strongest" context which is a interrupt in your case.
This type of mechanism is needed when you want to remember the interrupt 
status for the
IRQ/system.
>> +	if (priv->is_tx) {
>> +		dev_dbg(&priv->spi->dev, "SFD for TX\n");
>> +		priv->is_tx = 0;
>> +		complete(&priv->tx_complete);
>> +	} else
>> +		dev_dbg(&priv->spi->dev, "SFD for RX\n");
> make brackets in the else branch if you have brackets in the "if" branch.
>
> You don't need to lock all the things here I think:
>
> --snip
> 	spin_lock_irqsave(&priv->lock, flags);
> 	if (priv->is_tx) {
> 		priv->is_tx = 0;
> 		spin_unlock_irqrestore(&priv->lock, flags);
> 		dev_dbg(&priv->spi->dev, "SFD for TX\n");
> 		complete(&priv->tx_complete);
> 	} else {
> 		spin_unlock_irqrestore(&priv->lock, flags);
> 		dev_dbg(&priv->spi->dev, "SFD for RX\n");
> 	}
> --snap
>
Ya this can be the good approach...
>> +	spin_unlock(&priv->lock);
>> +
>> +	return IRQ_HANDLED
>> +/*Driver probe function*/
>> +static int cc2520_probe(struct spi_device *spi)
>> +{
>> +	struct cc2520_private *priv;
>> +	struct pinctrl *pinctrl;
>> +	struct cc2520_platform_data *pdata;
>> +	struct device_node __maybe_unused *np = spi->dev.of_node;
>> +	int ret;
>> +
>> +	priv = kzalloc(sizeof(struct cc2520_private), GFP_KERNEL);
>> +	if (!priv) {
>> +		ret = -ENOMEM;
>> +		goto err_free_local;
>> +	}
> why not devm_ calls?
I will surely change it to devm_....
>> +
>> +	spi_set_drvdata(spi, priv);
>> +
>> +	pinctrl = devm_pinctrl_get_select_default(&spi->dev);
>> +
>> +	if (gpio_is_valid(pdata->vreg)) {
>> +		ret = devm_gpio_request_one(&spi->dev, pdata->vreg,
>> +					GPIOF_OUT_INIT_LOW, "vreg");
>> +		if (ret)
>> +			goto err_hw_init;
>> +	}
> You should check on the not optional pins if you can request them. You
> use in the above code the pins vreg, reset, fifo_irq, sfd. And this
> failed if the gpio's are not valid.
>
> means:
>
> if (!gpio_is_valid(pdata->vreg)) {
> 	dev_err(....)
> 	ret = -EINVAL;
> 	goto ...;
> }
>
> on all pins which are needed to use your chip.
>
>> +
>> +	gpio_set_value(pdata->vreg, HIGH);
>> +	udelay(100);
>> +
>> +	gpio_set_value(pdata->reset, HIGH);
>> +	udelay(200);
>> +
>> +	ret = cc2520_hw_init(priv);
>> +	if (ret)
>> +		goto err_hw_init;
>> +
>> +	/*Set up fifop interrupt */
>> +	priv->fifo_irq = gpio_to_irq(pdata->fifop);
> why is fifo_irq in your "private data"? This is only used in this function.

Ya this is my mistake. Previously i used in other place also.

>> +	ret = devm_request_irq(&spi->dev,
>> +				priv->fifo_irq,
>> +				cc2520_fifop_isr,
>> +				IRQF_TRIGGER_RISING,
>> +				dev_name(&spi->dev),
>> +				priv);
>> +	if (ret) {
>> +		dev_err(&spi->dev, "could not get fifop irq\n");
>> +		goto err_hw_init;
>> +	}
>> +
>> +	/*Set up sfd interrupt*/
>> +	ret = devm_request_irq(&spi->dev,
>> +				gpio_to_irq(pdata->sfd),
>> +				cc2520_sfd_isr,
>> +				IRQF_TRIGGER_FALLING,
>> +				dev_name(&spi->dev),
>> +				priv);
>> +	if (ret) {
>> +		dev_err(&spi->dev, "could not get sfd irq\n");
>> +		goto err_hw_init;
>> +	}
>> +
>> +	ret = cc2520_register(priv);
>> +	if (ret)
>> +		goto err_hw_init;
>> +
>> +	return 0;
>> +
>> +err_hw_init:
>> +	mutex_destroy(&priv->buffer_mutex);
>> +	flush_work(&priv->fifop_irqwork);
>> +
>> +err_free_buf:
>> +	kfree(priv->buf);
>> +
>> +err_free_local:
>> +	kfree(priv);
>> +
>> +	return ret;
>> +}
>> +
>> +/*Driver remove function*/
>> +static int cc2520_remove(struct spi_device *spi)
>> +{
>> +	struct cc2520_private *priv = spi_get_drvdata(spi);
>> +
>> +	cc2520_unregister(priv);
>> +
>> +	mutex_destroy(&priv->buffer_mutex);
>> +	flush_work(&priv->fifop_irqwork);
>> +
>> +	kfree(priv->buf);
>> +	kfree(priv);
>> +
>> +	return 0;
>> +}
>> +
>> +static const struct spi_device_id cc2520_ids[] = {
>> +	{"cc2520", 0},
> You don't need to set the driver_data to 0. Simple:
> 	{ "cc2520", },
this does not make any difference.
>> +	{},
>> +};
>> +MODULE_DEVICE_TABLE(spi, cc2520_ids);
>> +
>> +static const struct of_device_id cc2520_of_ids[] = {
>> +	{.compatible = "ti,cc2520", },
>> +	{},
>> +};
>> +MODULE_DEVICE_TABLE(of, cc2520_of_ids);
>> +
>> +/*SPI Driver Structure*/
>> +static struct spi_driver cc2520_driver = {
>> +	.driver = {
>> +		.name = "cc2520",
>> +		.bus = &spi_bus_type,
>> +		.owner = THIS_MODULE,
>> +		.of_match_table = of_match_ptr(cc2520_of_ids),
>> +	},
>> +	.id_table = cc2520_ids,
>> +	.probe = cc2520_probe,
>> +	.remove = cc2520_remove,
>> +};
>> +module_spi_driver(cc2520_driver);
>> +
>> +MODULE_DESCRIPTION("CC2520 Transceiver Driver");
>> +MODULE_LICENSE("GPL v2");
>> diff --git a/include/linux/spi/cc2520.h b/include/linux/spi/cc2520.h
>> new file mode 100644
>> index 0000000..68a2c88
>> --- /dev/null
>> +++ b/include/linux/spi/cc2520.h
> In this location of header files are platform_data structs only. I think
> you should leave the cc2520_platform_data in this file and move the rest
> of declaration to you cc2520.c file.
>
I will move the code
>> @@ -0,0 +1,176 @@
>> +#ifndef __CC2520_H
>> +#define __CC2520_H
>> +
>> +#define RSSI_VALID		0
>> +#define RSSI_OFFSET		78
>> +#define CC2520_FREG_MASK	0x3F
>> +
>> +struct cc2520_platform_data {
>> +	int fifo;
>> +	int fifop;
>> +	int cca;
>> +	int sfd;
>> +	int reset;
>> +	int vreg;
>> +};
>> +
> - Alex


-Varka Bhadram

-------------------------------------------------------------------------------------------------------------------------------
[ C-DAC is on Social-Media too. Kindly follow us at:
Facebook: https://www.facebook.com/CDACINDIA & Twitter: @cdacindia ]

This e-mail is for the sole use of the intended recipient(s) and may
contain confidential and privileged information. If you are not the
intended recipient, please contact the sender by reply e-mail and destroy
all copies and the original message. Any unauthorized review, use,
disclosure, dissemination, forwarding, printing or copying of this email
is strictly prohibited and appropriate legal action will be taken.
-------------------------------------------------------------------------------------------------------------------------------

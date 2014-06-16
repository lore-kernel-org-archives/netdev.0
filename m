From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next 1/3] ieee802154: cc2520:
 driver for TI cc2520 radio
Date: Mon, 16 Jun 2014 20:58:33 +0200
Message-ID: <20140616185830.GA30538@omega>
References: <1402894318-30349-1-git-send-email-varkab@cdac.in>
 <1402894318-30349-2-git-send-email-varkab@cdac.in>
 <20140616073853.GA20343@omega>
 <539EB007.9000302@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Varka Bhadram <varkabhadram@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: Varka Bhadram <varkab@cdac.in>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <539EB007.9000302@cdac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Jun 16, 2014 at 02:21:19PM +0530, Varka Bhadram wrote:
...
> >>+
> >>+static void cc2520_unregister(struct cc2520_private *priv)
> >>+{
> >>+	ieee802154_unregister_device(priv->dev);
> >>+	ieee802154_free_device(priv->dev);
> >>+}
> >Only used in remove callback of module. It's small enough to do this in
> >the remove callback.
> >

There is no context switch here. It's a little bit faster because you
don't put some things on the stack. Alternative would be to add a inline
keyword to this function.

> Ya its nice . We can save the cpu context switching time also....
> >>+
> >>+static void cc2520_fifop_irqwork(struct work_struct *work)
> >>+{
> >>+	struct cc2520_private *priv
> >>+		= container_of(work, struct cc2520_private, fifop_irqwork);
> >>+
> >>+	dev_dbg(&priv->spi->dev, "fifop interrupt received\n");
> >>+
> >>+	if (gpio_get_value(priv->fifo_pin))
> >>+		cc2520_rx(priv);
> >>+	else
> >>+		dev_err(&priv->spi->dev, "rxfifo overflow\n");
> >>+
> >>+	cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHRX);
> >>+	cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHRX);
> >>+}
> >>+
> >>+static irqreturn_t cc2520_fifop_isr(int irq, void *data)
> >>+{
> >>+	struct cc2520_private *priv = data;
> >>+
> >>+	schedule_work(&priv->fifop_irqwork);
> >>+
> >>+	return IRQ_HANDLED;
> >>+}
> >>+
> >>+static irqreturn_t cc2520_sfd_isr(int irq, void *data)
> >>+{
> >>+	struct cc2520_private *priv = data;
> >>+
> >>+	spin_lock(&priv->lock);
> >You need to use here spin_lock_irqsave and spin_unlock_irqrestore here.
> >Please verify you locking with PROVE_LOCKING enabled in your kernel.
> >
> >In your xmit callback you use a irqsave spinlocks there. You need always
> >save to the "strongest" context which is a interrupt in your case.
> This type of mechanism is needed when you want to remember the interrupt
> status for the
> IRQ/system.

Yes you need I spinlock here, but spin_lock isn't irqsave but you need a
spin_lock function which is irqsave. This is
spin_lock_irqsave/spin_unlock_irqrestore.

You use these function in xmit callback for locking and that makes no
sense. You need to use spin_lock_irqsave/spin_unlock_irqrestore there of
course. But using in one function
spin_lock_irqsave/spin_unlock_irqrestore and in the other function
spin_lock/spin_unlock for the same spinlock is wrong.
In your case the strongest context is an irq, so you need for your
locking irqsave functions.

Please compile your kernel with PROVE_LOCKING and test your driver, then
you will see some warnings about deadlocks.

> >>+	if (priv->is_tx) {
> >>+		dev_dbg(&priv->spi->dev, "SFD for TX\n");
> >>+		priv->is_tx = 0;
> >>+		complete(&priv->tx_complete);
> >>+	} else
> >>+		dev_dbg(&priv->spi->dev, "SFD for RX\n");
> >make brackets in the else branch if you have brackets in the "if" branch.
> >
> >You don't need to lock all the things here I think:
> >
> >--snip
> >	spin_lock_irqsave(&priv->lock, flags);
> >	if (priv->is_tx) {
> >		priv->is_tx = 0;
> >		spin_unlock_irqrestore(&priv->lock, flags);
> >		dev_dbg(&priv->spi->dev, "SFD for TX\n");
> >		complete(&priv->tx_complete);
> >	} else {
> >		spin_unlock_irqrestore(&priv->lock, flags);
> >		dev_dbg(&priv->spi->dev, "SFD for RX\n");
> >	}
> >--snap
> >
> Ya this can be the good approach...
> >>+	spin_unlock(&priv->lock);
> >>+
> >>+	return IRQ_HANDLED
> >>+/*Driver probe function*/
> >>+static int cc2520_probe(struct spi_device *spi)
> >>+{
> >>+	struct cc2520_private *priv;
> >>+	struct pinctrl *pinctrl;
> >>+	struct cc2520_platform_data *pdata;
> >>+	struct device_node __maybe_unused *np = spi->dev.of_node;
> >>+	int ret;
> >>+
> >>+	priv = kzalloc(sizeof(struct cc2520_private), GFP_KERNEL);
> >>+	if (!priv) {
> >>+		ret = -ENOMEM;
> >>+		goto err_free_local;
> >>+	}
> >why not devm_ calls?
> I will surely change it to devm_....
> >>+
> >>+	spi_set_drvdata(spi, priv);
> >>+
> >>+	pinctrl = devm_pinctrl_get_select_default(&spi->dev);
> >>+
> >>+	if (gpio_is_valid(pdata->vreg)) {
> >>+		ret = devm_gpio_request_one(&spi->dev, pdata->vreg,
> >>+					GPIOF_OUT_INIT_LOW, "vreg");
> >>+		if (ret)
> >>+			goto err_hw_init;
> >>+	}
> >You should check on the not optional pins if you can request them. You
> >use in the above code the pins vreg, reset, fifo_irq, sfd. And this

s/above/below

> >failed if the gpio's are not valid.
> >
> >means:
> >
> >if (!gpio_is_valid(pdata->vreg)) {
> >	dev_err(....)
> >	ret = -EINVAL;
> >	goto ...;
> >}
> >
> >on all pins which are needed to use your chip.
> >
> >>+
> >>+	gpio_set_value(pdata->vreg, HIGH);
> >>+	udelay(100);
> >>+
> >>+	gpio_set_value(pdata->reset, HIGH);
> >>+	udelay(200);
> >>+
> >>+	ret = cc2520_hw_init(priv);
> >>+	if (ret)
> >>+		goto err_hw_init;
> >>+
> >>+	/*Set up fifop interrupt */
> >>+	priv->fifo_irq = gpio_to_irq(pdata->fifop);
...
> >>+static const struct spi_device_id cc2520_ids[] = {
> >>+	{"cc2520", 0},
> >You don't need to set the driver_data to 0. Simple:
> >	{ "cc2520", },
> this does not make any difference.

Yes, but saves code. :-)

Usual prefer coding is:

"(no difference + more code) < (no difference + less code)"

- Alex

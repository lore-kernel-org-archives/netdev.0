From: Mike Sinkovsky <msink@permonline.ru>
Subject: Re: [PATCH v5 2/2] Ethernet driver for the WIZnet W5100 chip
Date: Mon, 02 Apr 2012 15:40:18 +0600
Message-ID: <4F797402.1050109@permonline.ru>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru> <1333090806-27988-2-git-send-email-msink@permonline.ru> <20120331212303.GB19965@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120331212303.GB19965@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

01.04.2012 3:23, Mark Brown wrote:
> On Fri, Mar 30, 2012 at 01:00:06PM +0600, Mike Sinkovsky wrote:
>
>> +config WIZNET_W5100
>> +	tristate "WIZnet W5100 Ethernet support"
>> +	depends on ARM || BLACKFIN
>
> What are the architecture dependencies here?

Original driver from chip manufacturer was written for ARM, and now we 
use it on Blackfin.
Completely untested on other arch's, but should work. Maybe.


>> +static irqreturn_t w5100_interrupt(int irq, void *ndev_instance)
>> +{
>> +	struct net_device *ndev = ndev_instance;
>> +	struct w5100_priv *priv = netdev_priv(ndev);
>> +
>> +	int ir = w5100_read(priv, W5100_S0_IR);
>> +	w5100_write(priv, W5100_S0_IR, ir);
>> +
>> +	if (ir&  S0_IR_RECV) {
>> +		if (napi_schedule_prep(&priv->napi)) {
>> +			w5100_write(priv, W5100_IMR, 0);
>> +			mmiowb();
>> +			__napi_schedule(&priv->napi);
>> +		}
>> +	}
>> +
>> +	if (ir&  S0_IR_SENDOK) {
>> +		if (unlikely(netif_queue_stopped(ndev)))
>> +			netif_wake_queue(ndev);
>> +	}
>> +
>> +	return IRQ_HANDLED;
>
> This unconditionally acknowledges the interrupt even if one wasn't
> reported by the device.

Hm? Don't get you.
W5100_S0_IR register is R/W1C - writing back clears it.
Or what do you mean?


>> +	irq = platform_get_irq(pdev, 0);
>> +	if (irq<  0)
>> +		return irq;
>> +	ret = devm_request_irq(&pdev->dev, irq, w5100_interrupt,
>> +			       IRQ_TYPE_LEVEL_LOW, name, ndev);
>> +	if (ret<  0)
>> +		return ret;
>> +	priv->irq = irq;
>> +
>> +	link = platform_get_resource(pdev, IORESOURCE_IO, 0);
>> +	if (!link) {
>> +		priv->link_gpio = -1;
>
> This is rather an abuse of the resource API and will run into trouble on
> device tree based systems.  You should use platform data for non-DT
> systems.

Ok, will move it to struct wiznet_platform_data.
But here is downside - this gpio is optional, and if board doesn't have 
it - it must be initialized as negative value, not just omitted.


>> +		if (request_irq(priv->link_irq, w5100_detect_link,
>> +				IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING,
>> +				link_name, priv->ndev)<  0)
>
> Suggest using request_any_context_irq() to increase the range of
> supported interrupt controllers.

Could it be anything but hard irq?
But there is another bug - it should be devm_request_irq...
:)


>> +err_register:
>> +	free_netdev(ndev);
>> +	platform_set_drvdata(pdev, NULL);
>> +	dev_info(&pdev->dev, "probe failed (%d)\n", err);
>
> This will be done for you by the driver core.

You mean platform_set_drvdata() and dev_info()? Maybe.
I'm sure platform_driver will not do free_netdev() for me.


-- 
Mike

From: Mike Sinkovsky <msink@permonline.ru>
Subject: Re: [PATCH v6 1/2] Ethernet driver for the WIZnet W5300 chip
Date: Wed, 04 Apr 2012 12:18:12 +0600
Message-ID: <4F7BE7A4.1060202@permonline.ru>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru> <1333450726-24455-2-git-send-email-msink@permonline.ru> <20120403133619.GA3960@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120403133619.GA3960@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

03.04.2012 19:36, Mark Brown =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=
:
> On Tue, Apr 03, 2012 at 04:58:45PM +0600, Mike Sinkovsky wrote:
>
>> +static irqreturn_t w5300_detect_link(int irq, void *ndev_instance)
>> +{
>> +	struct net_device *ndev =3D ndev_instance;
>> +	struct w5300_priv *priv =3D netdev_priv(ndev);
>> +
>> +	if (netif_running(ndev)) {
>> +		if (gpio_get_value(priv->link_gpio) !=3D 0) {
>> +			netif_info(priv, link, ndev, "link is up\n");
>> +			netif_carrier_on(ndev);
>> +		} else {
>> +			netif_info(priv, link, ndev, "link is down\n");
>> +			netif_carrier_off(ndev);
>> +		}
>> +	}
>> +
>> +	return IRQ_HANDLED;
>> +}
>
> This relies on ndev being valid and on the gpio being requested but..=
=2E
>
>> +	priv->link_gpio =3D data->link_gpio;
>> +	if (gpio_is_valid(priv->link_gpio)) {
>> +		char *link_name =3D devm_kzalloc(&pdev->dev, 16, GFP_KERNEL);
>> +		if (!link_name)
>> +			return -ENOMEM;
>> +		snprintf(link_name, 16, "%s-link", name);
>> +		priv->link_irq =3D gpio_to_irq(priv->link_gpio);
>> +		if (devm_request_threaded_irq(&pdev->dev,
>> +				priv->link_irq, NULL, w5300_detect_link,
>> +				IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING,
>> +				link_name, priv->ndev)<  0)
>> +			priv->link_gpio =3D -EINVAL;
>> +	}
>
> ...you use devm_request_threaded_irq() here and rely on it for cleanu=
p.
> Are you sure there's no possibility of the interrupt firing after you
> start to tear down the device?
>
> By using a specifically threaded IRQ you're also adding a performance
> overhead for no good reason if you can call netdev_carrier_*() from I=
RQ
> context and the GPIO is capable of generating a hard IRQ.  If you use
> request_any_context_irq() instead then the driver will get a hard IRQ=
 if
> that's supported.

There isn't devm* variant of request_any_context_irq(), and using plain=
=20
version looks inconsistent with other resources handling.
Anyway, this is not performance critical procedure, and latency around=20
100 millisecond is acceptable. Some our boards even don't have this gpi=
o=20
at all, and nothing bad happens, just userspace doesn't know is carrier=
=20
on or off.

Some gpio cannot generate irq at all, and if goal is to support any - I=
=20
can easily convert this to background polling from delayed_work=20
procedure. If it is required for generalized mainstream driver.


--=20
Mike

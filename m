From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH 3/3 v2] net: smsc911x: add wake-up event interrupt support
Date: Wed, 31 Aug 2016 10:32:20 -0500
Message-ID: <e1d1090d-0d4d-2af5-363d-1cf2e5ea82cd@arm.com>
References: <1472043582-7653-1-git-send-email-linus.walleij@linaro.org>
 <1472043582-7653-3-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
        Kamlakant Patel <kamlakant.patel@broadcom.com>,
        Pavel Fedin <p.fedin@samsung.com>,
        Sudeep Holla <sudeep.holla@arm.com>,
        Tony Lindgren <tony@atomide.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Linus Walleij <linus.walleij@linaro.org>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:35650 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933887AbcHaPcW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 11:32:22 -0400
In-Reply-To: <1472043582-7653-3-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 08/24/2016 07:59 AM, Linus Walleij wrote:
> The SMSC911x have a line out of the chip called "PME",
> Power Management Event. When connected to an asynchronous
> interrupt controller this is able to wake the system up
> from sleep in response to certain network events.
>
> This is the first attempt to support this in the Linux
> driver: the Qualcomm APQ8060 Dragonboard has this line
> routed to a GPIO line on the primary SoC padring, and as
> such it can be armed as a wakeup interrupt.
>
> The patch is inspired by the wakeup code in the RTC
> subsystem.
>
> The code looks for an additional interrupt - apart from the
> ordinary device interrupt - and in case that is present,
> we register an interrupt handler to respons to this,
> and flag the device and this interrupt as a wakeup.


Having looked at a couple of the supported smsc chips, it seems they can 
route the wakeup through the chip's interrupt as well. If you add code 
to support this, it should work on a lot of the smsc911x devices rather 
than just the dragonboard.


Thanks,




>
> Cc: Sudeep Holla <sudeep.holla@arm.com>
> Cc: Tony Lindgren <tony@atomide.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> ---
> ChangeLog v1->v2:
> - Call pm_wakeup_event() in the wakeup IRQ thread to
>   account for the wakeup event.
> - Drop the enable/disable_irq_wake() calls from suspend/resume:
>   this is handled from the irq core when you call
>   dev_pm_set_wake_irq() as we do.
> ---
>  drivers/net/ethernet/smsc/smsc911x.c | 42 ++++++++++++++++++++++++++++++++++++
>  1 file changed, 42 insertions(+)
>
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 8ab8d4b9614b..8fffc1dc2bdd 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -63,6 +63,7 @@
>  #include <linux/pm_runtime.h>
>  #include <linux/property.h>
>  #include <linux/gpio/consumer.h>
> +#include <linux/pm_wakeirq.h>
>
>  #include "smsc911x.h"
>
> @@ -151,6 +152,9 @@ struct smsc911x_data {
>  	/* Reset GPIO */
>  	struct gpio_desc *reset_gpiod;
>
> +	/* PME interrupt */
> +	int pme_irq;
> +
>  	/* clock */
>  	struct clk *clk;
>  };
> @@ -1881,6 +1885,19 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
>  	return serviced;
>  }
>
> +static irqreturn_t smsc911x_pme_irq_thread(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct smsc911x_data *pdata __maybe_unused = netdev_priv(dev);
> +
> +	SMSC_TRACE(pdata, pm, "wakeup event");
> +	pm_wakeup_event(&dev->dev, 50);
> +	/* This signal is active for 50 ms, wait for it to deassert */
> +	usleep_range(50000, 100000);
> +
> +	return IRQ_HANDLED;
> +}
> +
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  static void smsc911x_poll_controller(struct net_device *dev)
>  {
> @@ -2501,6 +2518,31 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
>  		goto out_disable_resources;
>  	}
>
> +	irq = platform_get_irq(pdev, 1);
> +	if (irq == -EPROBE_DEFER) {
> +		retval = -EPROBE_DEFER;
> +		goto out_disable_resources;
> +	/* It's perfectly fine to not have a PME IRQ */
> +	} else if (irq > 0) {
> +		/*
> +		 * The Power Management Event (PME) IRQ appears as
> +		 * a pulse waking up the system from sleep in response to  a
> +		 * network event.
> +		 */
> +		retval = request_threaded_irq(irq, NULL,
> +					      smsc911x_pme_irq_thread,
> +					      IRQF_ONESHOT, "smsc911x-pme",
> +					      dev);
> +		if (retval) {
> +			SMSC_WARN(pdata, probe,
> +			"Unable to claim requested PME irq: %d", irq);
> +			goto out_disable_resources;
> +		}
> +		pdata->pme_irq = irq;
> +		device_init_wakeup(&pdev->dev, true);
> +		dev_pm_set_wake_irq(&pdev->dev, irq);
> +	}
> +
>  	netif_carrier_off(dev);
>
>  	retval = register_netdev(dev);
>

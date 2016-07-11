From: Sudeep Holla <sudeep.holla@arm.com>
Subject: Re: [PATCH 3/3] RFC: net: smsc911x: add wake-up event interrupt
 support
Date: Mon, 11 Jul 2016 11:23:25 +0100
Message-ID: <5783739D.4090706@arm.com>
References: <1467968852-6175-1-git-send-email-linus.walleij@linaro.org>
 <1467968852-6175-3-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Sudeep Holla <sudeep.holla@arm.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Jeremy Linton <jeremy.linton@arm.com>,
	Kamlakant Patel <kamlakant.patel@broadcom.com>,
	Pavel Fedin <p.fedin@samsung.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Tony Lindgren <tony@atomide.com>,
	"Rafael J . Wysocki" <rjw@rjwysocki.net>,
	John Stultz <john.stultz@linaro.org>
To: Linus Walleij <linus.walleij@linaro.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:51902 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753073AbcGKKXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 06:23:30 -0400
In-Reply-To: <1467968852-6175-3-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/07/16 10:07, Linus Walleij wrote:
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
>
> Cc: Sudeep Holla <sudeep.holla@arm.com>
> Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>
> Cc: Tony Lindgren <tony@atomide.com>
> Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
> Cc: John Stultz <john.stultz@linaro.org>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> ---
> Added some wakeup people at CC who can (hopefully) tell me if
> I'm doing this right or not.
> ---
>   drivers/net/ethernet/smsc/smsc911x.c | 48 ++++++++++++++++++++++++++++++++++++
>   1 file changed, 48 insertions(+)
>
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 125d58ac22bd..e43755ae130a 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c

[...]

> @@ -2525,6 +2540,33 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
>   		goto out_disable_resources;
>   	}
>
> +	irq = platform_get_irq(pdev, 1);
> +	if (irq == -EPROBE_DEFER) {
> +		retval = -EPROBE_DEFER;
> +		goto out_disable_resources;
> +	/* It's perfectly fine to not have a PME IRQ */
> +	} else if (irq > 0) {
> +		char *pme_name;
> +
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
>   	netif_carrier_off(dev);
>
>   	retval = register_netdev(dev);
> @@ -2613,6 +2655,9 @@ static int smsc911x_suspend(struct device *dev)
>   		PMT_CTRL_PM_MODE_D1_ | PMT_CTRL_WOL_EN_ |
>   		PMT_CTRL_ED_EN_ | PMT_CTRL_PME_EN_);
>
> +	if (pdata->pme_irq && device_may_wakeup(dev))
> +		enable_irq_wake(pdata->pme_irq);
> +

Based on my understanding of dev_pm_{set,clear}_wake_irq, we don't need
this and the below hunk. It's taken care in device_wakeup_arm_wake_irqs
which is called from suspend_enter---->dpm_suspend_noirq path once you
have done the setup with dev_pm_set_wake_irq and is enabled both of
which is true in your case.

>   	return 0;
>   }
>
> @@ -2622,6 +2667,9 @@ static int smsc911x_resume(struct device *dev)
>   	struct smsc911x_data *pdata = netdev_priv(ndev);
>   	unsigned int to = 100;
>
> +	if (pdata->pme_irq && device_may_wakeup(dev))
> +		disable_irq_wake(pdata->pme_irq);
> +

Same as above.

-- 
Regards,
Sudeep

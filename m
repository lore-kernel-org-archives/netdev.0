From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [PATCH] net: smsc911x: adopt pinctrl support
Date: Sat, 13 Apr 2013 20:32:45 +0200
Message-ID: <CAAwP0s2BD_nVXPyTi+EsgnqStdFUbHELJRjU_sP5E_w-XiWnRw@mail.gmail.com>
References: <1365873745.3812.37.camel@mars>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sebastien Guiriec <s-guiriec@ti.com>,
	Daniel Mack <daniel@zonque.org>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Christoph Fritz <chf.fritz@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:49398 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753088Ab3DMSdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 14:33:07 -0400
In-Reply-To: <1365873745.3812.37.camel@mars>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 13, 2013 at 7:22 PM, Christoph Fritz
<chf.fritz@googlemail.com> wrote:
> This patch is derived from 2d4b4520a "i2c: omap: adopt pinctrl support":
> Some GPIO expanders need some early pin control muxing. Due to
> legacy boards sometimes the driver uses subsys_initcall instead of
> module_init. This patch takes advantage of defer probe feature
> and pin control in order to wait until pin control probing before
> GPIO driver probing.
>
> Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
> ---
>  drivers/net/ethernet/smsc/smsc911x.c |   15 +++++++++++++++
>  1 file changed, 15 insertions(+)
>
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index da5cc9a..3e3547c 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -59,6 +59,7 @@
>  #include <linux/of_device.h>
>  #include <linux/of_gpio.h>
>  #include <linux/of_net.h>
> +#include <linux/pinctrl/consumer.h>
>  #include "smsc911x.h"
>
>  #define SMSC_CHIPNAME          "smsc911x"
> @@ -144,6 +145,8 @@ struct smsc911x_data {
>
>         /* regulators */
>         struct regulator_bulk_data supplies[SMSC911X_NUM_SUPPLIES];
> +
> +       struct pinctrl *pins;
>  };
>
>  /* Easy access to information */
> @@ -2433,6 +2436,18 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
>         if (retval < 0)
>                 goto out_disable_resources;
>
> +       pdata->pins = devm_pinctrl_get_select_default(&pdev->dev);
> +       if (IS_ERR(pdata->pins)) {
> +               if (PTR_ERR(pdata->pins) == -EPROBE_DEFER) {
> +                       retval = -EPROBE_DEFER;
> +                       goto out_disable_resources;
> +               }
> +
> +               dev_warn(&pdev->dev, "No pins for smsc911x error: %li\n",
> +                        PTR_ERR(pdata->pins));
> +               pdata->pins = NULL;
> +       }
> +
>         /* configure irq polarity and type before connecting isr */
>         if (pdata->config.irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
>                 intcfg |= INT_CFG_IRQ_POL_;
> --
> 1.7.10.4
>
>
>

Hi Christoph,

This is handled from the device core after from v3.9.

Please take a loot at this:
http://marc.info/?l=linux-kernel&m=135887740715083&w=2

Best regards,
Javier

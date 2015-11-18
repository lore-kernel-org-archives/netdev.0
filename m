From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] dsa: mv88e6xxx.c: Hardware reset the chip
 if available
Date: Wed, 18 Nov 2015 15:51:22 -0800
Message-ID: <564D0EFA.7050806@gmail.com>
References: <1447889365-25256-1-git-send-email-andrew@lunn.ch> <1447889365-25256-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33265 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756183AbbKRXwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 18:52:22 -0500
Received: by pabfh17 with SMTP id fh17so62069616pab.0
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 15:52:22 -0800 (PST)
In-Reply-To: <1447889365-25256-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/11/15 15:29, Andrew Lunn wrote:
> The device tree binding now allows a gpio to be specified which is
> attached to the switch chips reset line. If it is defined, perform
> a hardware reset on the switch during setup.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index b06dba05594a..c0bbbe7713c5 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -19,6 +19,7 @@
>  #include <linux/list.h>
>  #include <linux/module.h>
>  #include <linux/netdevice.h>
> +#include <linux/gpio/consumer.h>
>  #include <linux/phy.h>
>  #include <net/dsa.h>
>  #include <net/switchdev.h>
> @@ -2323,7 +2324,10 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>  	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
> +	int gpio = ds->pd->reset;
> +	int flags = ds->pd->reset_flags;
>  	unsigned long timeout;
> +	int on = 1;
>  	int ret;
>  	int i;
>  
> @@ -2336,6 +2340,16 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
>  	/* Wait for transmit queues to drain. */
>  	usleep_range(2000, 4000);
>  
> +	/* If there is a gpio connected to the reset pin, toggle it */
> +	if (gpio_is_valid(gpio)) {
> +		if (flags && OF_GPIO_ACTIVE_LOW)
> +			on = !on;
> +		gpio_set_value_cansleep(gpio, on);
> +		usleep_range(10000, 20000);
> +		gpio_set_value_cansleep(gpio, !on);
> +		usleep_range(10000, 20000);
> +	}

We are embedding reset logic here about the delays and polarity, while
there is now a proper abstraction for this within the reset controller
subsystem under drivers/reset/core.c. Could we utilize that facility
instead which would make us more robust wrt. non-GPIO reset lines (for
instance some SF2 switches on DSL gateways could definitively benefit
from this).

There does not seem to be a reset controller GPIO binding and generic
driver, but this seems like an appropriate candidate?
-- 
Florian

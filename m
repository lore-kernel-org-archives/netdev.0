From: Phil Reid <preid@electromag.com.au>
Subject: Re: [PATCH net-next 2/2] dsa: mv88e6xxx.c: Hardware reset the chip if
 available
Date: Thu, 19 Nov 2015 10:08:22 +0800
Message-ID: <564D2F16.1020701@electromag.com.au>
References: <1447889365-25256-1-git-send-email-andrew@lunn.ch>
 <1447889365-25256-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy2.45ru.net.au ([203.30.46.146]:48403 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755154AbbKSCIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 21:08:32 -0500
In-Reply-To: <1447889365-25256-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/11/2015 7:29 AM, Andrew Lunn wrote:
> The device tree binding now allows a gpio to be specified which is
> attached to the switch chips reset line. If it is defined, perform
> a hardware reset on the switch during setup.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>   drivers/net/dsa/mv88e6xxx.c | 14 ++++++++++++++
>   1 file changed, 14 insertions(+)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index b06dba05594a..c0bbbe7713c5 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -19,6 +19,7 @@
>   #include <linux/list.h>
>   #include <linux/module.h>
>   #include <linux/netdevice.h>
> +#include <linux/gpio/consumer.h>
>   #include <linux/phy.h>
>   #include <net/dsa.h>
>   #include <net/switchdev.h>
> @@ -2323,7 +2324,10 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
>   {
>   	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>   	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
> +	int gpio = ds->pd->reset;
> +	int flags = ds->pd->reset_flags;
>   	unsigned long timeout;
> +	int on = 1;
>   	int ret;
>   	int i;
>
> @@ -2336,6 +2340,16 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
>   	/* Wait for transmit queues to drain. */
>   	usleep_range(2000, 4000);
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
> +
This is a general query about what is the preferred method of allocating gpios.
The gpiod* family of functions provided similar functionality and automatically
deal with active low / high outputs, direction, inital value  etc...
I raise this more for knowledge on what method I should use for my patches.


>   	/* Reset the switch. Keep the PPU active if requested. The PPU
>   	 * needs to be active to support indirect phy register access
>   	 * through global registers 0x18 and 0x19.
>

Other than that the concept looks good and something I has been looking at adding.

Would it be worth considering placing the chip in reset on driver remove?
I have an battery powered hardware platform using one of this marvell devices and
for certain configurations we don't need the switch active. So unloading the
module to place the device in reset and would save power.
Reloading would reinitialise the port.





-- 
Regards
Phil Reid

ElectroMagnetic Imaging Technology Pty Ltd
Development of Geophysical Instrumentation & Software
www.electromag.com.au

3 The Avenue, Midland WA 6056, AUSTRALIA
Ph: +61 8 9250 8100
Fax: +61 8 9250 7100
Email: preid@electromag.com.au

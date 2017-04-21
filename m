From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next] mdio_bus: Issue GPIO RESET to PHYs.
Date: Thu, 20 Apr 2017 18:23:41 -0700
Message-ID: <fa24ae98-3d4f-4b11-bbb4-485b9ed41ed7@gmail.com>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <64d6494d-41d2-0faf-a434-057f796637fe@ti.com>
 <daa29a99-0a17-d316-57eb-3e6162938d8d@ti.com>
 <f372db02-a919-55b4-9200-20726cd13482@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: tony@atomide.com, nsekhar@ti.com, jsarha@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, davem@davemloft.net,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35334 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034248AbdDUBXr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 21:23:47 -0400
In-Reply-To: <f372db02-a919-55b4-9200-20726cd13482@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roger,

On 04/20/2017 07:11 AM, Roger Quadros wrote:
> Some boards [1] leave the PHYs at an invalid state
> during system power-up or reset thus causing unreliability
> issues with the PHY which manifests as PHY not being detected
> or link not functional. To fix this, these PHYs need to be RESET
> via a GPIO connected to the PHY's RESET pin.
> 
> Some boards have a single GPIO controlling the PHY RESET pin of all
> PHYs on the bus whereas some others have separate GPIOs controlling
> individual PHY RESETs.
> 
> In both cases, the RESET de-assertion cannot be done in the PHY driver
> as the PHY will not probe till its reset is de-asserted.
> So do the RESET de-assertion in the MDIO bus driver.
> 
> [1] - am572x-idk, am571x-idk, a437x-idk
> 
> Signed-off-by: Roger Quadros <rogerq@ti.com>

A few comments on the binding and the code, sorry for this late review.

> +Example :
> +This example shows these optional properties, plus other properties
> +required for the TI Davinci MDIO driver.
> +
> +	davinci_mdio: ethernet@0x5c030000 {
> +		compatible = "ti,davinci_mdio";
> +		reg = <0x5c030000 0x1000>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		reset-gpios = <&gpio2 5 GPIO_ACTIVE_LOW>;
> +		reset-delay-us = <2>;   /* PHY datasheet states 1uS min */

us is micro seconds, uS is micro siemens.

> +
> +		ethphy0: ethernet-phy@1 {
> +			reg = <1>;
> +		};
> +
> +		ethphy1: ethernet-phy@3 {
> +			reg = <3>;
> +		};
> +	};

>  
> +	/* de-assert bus level PHY GPIO resets */
> +	for (i = 0; i < bus->num_reset_gpios; i++) {
> +		gpiod = devm_gpiod_get_index(&bus->dev, "reset", i,
> +					     GPIOD_OUT_LOW);
> +		if (IS_ERR(gpiod)) {
> +			err = PTR_ERR(gpiod);
> +			if (err != -ENOENT) {
> +				pr_err("mii_bus %s couldn't get reset GPIO\n",
> +				       bus->id);

Could we use dev_err(&bus->dev) here to better identify which MDIO bus
is returning the problem?

> +				return err;

Should we somehow "unwind" the reset lines we were able to successfully
take out of reset and therefore put back into reset state? How about
mdiobus_unregister()? Should we have similar code there, if not for
correctness to be more power efficient?

> +			}
> +		} else {
> +			gpiod_set_value_cansleep(gpiod, 1);
> +			udelay(bus->reset_delay_us);
> +			gpiod_set_value_cansleep(gpiod, 0);

Does that work even if the polarity of the reset line is active low?

Thanks!
-- 
Florian

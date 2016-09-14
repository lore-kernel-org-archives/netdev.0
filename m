From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 3/3] phy,leds: add support for led triggers on phy link
 state change
Date: Wed, 14 Sep 2016 16:16:15 -0700
Message-ID: <de5b8b94-7bf8-0814-3f60-a268adb4dfde@gmail.com>
References: <1473890149-2066-1-git-send-email-zach.brown@ni.com>
 <1473890149-2066-4-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: mlindner@marvell.com, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
        Larry.Finger@lwfinger.net
To: Zach Brown <zach.brown@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34308 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760295AbcINXQU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 19:16:20 -0400
In-Reply-To: <1473890149-2066-4-git-send-email-zach.brown@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2016 02:55 PM, Zach Brown wrote:
> From: Josh Cartwright <josh.cartwright@ni.com>
> 
> Create an option CONFIG_LED_TRIGGER_PHY (default n), which will
> create a set of led triggers for each instantiated PHY device.  There is
> one LED trigger per link-speed, per-phy.
> 
> This allows for a user to configure their system to allow a set of LEDs
> to represent link state changes on the phy.

The part that seems to be missing from this changeset (not an issue) is
how you can "accelerate" the triggers, or rather make sure that the
trigger configuration potentially calls back into the PHY driver when
the requested trigger is actually supported by the on-PHY LEDs.

Other than that, just minor nits here and there.

> 
> Signed-off-by: Josh Cartwright <josh.cartwright@ni.com>
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> Signed-off-by: Zach Brown <zach.brown@ni.com>
> ---

> +config LED_TRIGGER_PHY
> +	bool "Support LED triggers for tracking link state"
> +	depends on LEDS_TRIGGERS
> +	---help---
> +	  Adds support for a set of LED trigger events per-PHY.  Link
> +	  state change will trigger the events, for consumption by an
> +	  LED class driver.  There are triggers for each link speed,
> +	  and are of the form:
> +	       <mii bus id>:<phy>:<speed>
> +
> +	  Where speed is one of: 10Mb, 100Mb, Gb, 2.5Gb, or 10GbE.

I would do s/10GbE/10Gb/ just to be consistent with the other speeds, or
maybe, to avoid too much duplicationg of how we represent speeds, use
the same set of strings that drivers/net/phy/phy.c::phy_speed_to_str uses.


> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index c6f6683..3345767 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -936,6 +936,7 @@ void phy_state_machine(struct work_struct *work)
>  			phydev->state = PHY_NOLINK;
>  			netif_carrier_off(phydev->attached_dev);
>  			phydev->adjust_link(phydev->attached_dev);
> +			phy_led_trigger_change_speed(phydev);

Since we have essentially two actions to take when performing link state
changes:

- call the adjust_link callback
- call into the LED trigger

we might consider encapsulating this into a function that could be named
phy_adjust_link() and does both of these. That would be a preliminary
patch to this this one.

>  
> @@ -345,6 +347,8 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
>  
>  	dev->state = PHY_DOWN;
>  
> +	phy_led_triggers_register(dev);
> +
>  	mutex_init(&dev->lock);
>  	INIT_DELAYED_WORK(&dev->state_queue, phy_state_machine);
>  	INIT_WORK(&dev->phy_queue, phy_change);

Humm, should it be before the PHY state machine workqueue creation or
after? Just wondering if there is a remote chance we could get an user
to immediately program a trigger and this could create a problem, maybe
not so much.

> diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
> new file mode 100644
> index 0000000..6c40414
> --- /dev/null
> +++ b/drivers/net/phy/phy_led_triggers.c
> @@ -0,0 +1,109 @@
> +/* Copyright (C) 2016 National Instruments Corp.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +#include <linux/leds.h>
> +#include <linux/phy.h>
> +
> +void phy_led_trigger_change_speed(struct phy_device *phy)
> +{
> +	struct phy_led_trigger *plt;
> +
> +	if (!phy->link) {
> +		if (phy->last_triggered) {
> +			led_trigger_event(&phy->last_triggered->trigger,
> +					  LED_OFF);
> +			phy->last_triggered = NULL;
> +		}
> +		return;
> +	}
> +
> +	switch (phy->speed) {
> +	case SPEED_10:
> +		plt = &phy->phy_led_trigger[0];
> +		break;
> +	case SPEED_100:
> +		plt = &phy->phy_led_trigger[1];
> +		break;
> +	case SPEED_1000:
> +		plt = &phy->phy_led_trigger[2];
> +		break;
> +	case SPEED_2500:
> +		plt = &phy->phy_led_trigger[3];
> +		break;
> +	case SPEED_10000:
> +		plt = &phy->phy_led_trigger[4];
> +		break;

We could use a table here indexed by the speed, or have a function that
does phy_speed_to_led_trigger(unsigned int speed) for instance, which
would be more robust to adding other speeds in the future.

> +	default:
> +		plt = NULL;
> +		break;
> +	}
> +
> +	if (plt != phy->last_triggered) {
> +		led_trigger_event(&phy->last_triggered->trigger, LED_OFF);
> +		led_trigger_event(&plt->trigger, LED_FULL);
> +		phy->last_triggered = plt;
> +	}
> +}
> +EXPORT_SYMBOL_GPL(phy_led_trigger_change_speed);
> +
> +static int phy_led_trigger_register(struct phy_device *phy,
> +				    struct phy_led_trigger *plt, int i)
> +{
> +	static const char * const name_suffix[] = {
> +		"10Mb",
> +		"100Mb",
> +		"Gb",
> +		"2.5Gb",
> +		"10GbE",

Same comment as initially, the 10GbE is slightly inconsistent here wrt
the other speed encodings.


>  
> @@ -402,6 +403,14 @@ struct phy_device {
>  
>  	int link_timeout;
>  
> +#ifdef CONFIG_LED_TRIGGER_PHY
> +	/*
> +	 * A led_trigger per SPEED_*
> +	 */
> +	struct phy_led_trigger phy_led_trigger[5];

Same comment, we would probably want to have a define/enum value for the
maximum number of speeds supported.


> +#include <linux/leds.h>
> +
> +struct phy_led_trigger {
> +	struct led_trigger trigger;
> +	char name[64];

Can we size this buffer based on MII_BUS_ID_SIZE, the amount of
characters needed to represent a PHY device, and the maximum trigger
name size?

> +#else
> +
> +static inline int phy_led_triggers_register(struct phy_device *phy)
> +{
> +	return 0;
> +}
> +static inline void phy_led_triggers_unregister(struct phy_device *phy) { }
> +static inline void phy_led_trigger_change_speed(struct phy_device *phy) { }

Kudos for adding stubs!
-- 
Florian

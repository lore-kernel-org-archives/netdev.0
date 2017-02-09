From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v3 net-next 2/2] net: dsa: mv88e6xxx: Add mv88e6390 watchdog interrupt support
Date: Thu, 09 Feb 2017 10:46:55 -0500
Message-ID: <87a89v4b9s.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1486595023-28371-1-git-send-email-andrew@lunn.ch> <1486595023-28371-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:35626 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751760AbdBIPsr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 10:48:47 -0500
In-Reply-To: <1486595023-28371-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thanks for the v3.

Andrew Lunn <andrew@lunn.ch> writes:

> +static int mv88e6390_watchdog_setup(struct mv88e6xxx_chip *chip)
> +{
> +	return mv88e6xxx_g2_update(chip, GLOBAL2_WDOG_CONTROL,
> +				   GLOBAL2_WDOG_INT_ENABLE |
> +				   GLOBAL2_WDOG_CUT_THROUGH |
> +				   GLOBAL2_WDOG_QUEUE_CONTROLLER |
> +				   GLOBAL2_WDOG_EGRESS |
> +				   GLOBAL2_WDOG_FORCE_IRQ);
> +}
> +
> +static int mv88e6390_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
> +{
> +	int err;
> +	u16 reg;
> +
> +	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, GLOBAL2_WDOG_EVENT);
> +	err = mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);

You don't check for errors when reading or writing.

> +
> +	dev_info(chip->dev, "Watchdog event: 0x%04x",
> +		 reg & GLOBAL2_WDOG_DATA_MASK);
> +
> +	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, GLOBAL2_WDOG_HISTORY);
> +	err = mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
> +
> +	dev_info(chip->dev, "Watchdog history: 0x%04x",
> +		 reg & GLOBAL2_WDOG_DATA_MASK);
> +
> +	/* Trigger a software reset to try to recover the switch */
> +	if (chip->info->ops->reset)
> +		chip->info->ops->reset(chip);

A SMI device (here Global2) should not need to deal with other ops.

> +
> +	mv88e6390_watchdog_setup(chip);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static void mv88e6390_watchdog_free(struct mv88e6xxx_chip *chip)
> +{
> +	mv88e6xxx_g2_update(chip, GLOBAL2_WDOG_CONTROL,
> +			    GLOBAL2_WDOG_INT_ENABLE);
> +}

Sorry but this is a bit cluttered. We are mixing library routines to
access a chip register with the watchdog/irq logic.

It looks like all you need in global2.c is library functions to access
the watchdog register (indirect, in case of 88E6390).

    /* Offset 0x1B: Watch Dog Control Register */

    int mv88e6097_g2_watchdog_read(...)
    int mv88e6097_g2_watchdog_enable(...)
    int mv88e6097_g2_watchdog_disable(...)
    int mv88e6390_g2_watchdog_read(...)
    int mv88e6390_g2_watchdog_enable(...)
    int mv88e6390_g2_watchdog_disable(...)

The above seems to be all we need to have implemented in global2.c.

Then chip.c can glue all that nicely together, playing with ops and
irq threads.


Thanks,

        Vivien

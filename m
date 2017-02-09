From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v3 net-next 1/2] net: dsa: mv88e6xxx: Add watchdog interrupt handler
Date: Thu, 09 Feb 2017 10:52:15 -0500
Message-ID: <878tpfuztc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1486595023-28371-1-git-send-email-andrew@lunn.ch> <1486595023-28371-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37362 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753482AbdBIQC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 11:02:29 -0500
In-Reply-To: <1486595023-28371-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> +static int mv88e6097_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
> +{
> +	u16 reg;
> +
> +	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);

We should not ignore read errors.

> +
> +	dev_info(chip->dev, "Watchdog event: 0x%04x", reg);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static void mv88e6097_watchdog_free(struct mv88e6xxx_chip *chip)
> +{
> +	u16 reg;
> +
> +	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
> +
> +	reg &= ~(GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE |
> +		 GLOBAL2_WDOG_CONTROL_QC_ENABLE);
> +
> +	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, reg);

Same here.

> +}
> +
> +static int mv88e6097_watchdog_setup(struct mv88e6xxx_chip *chip)
> +{
> +	return mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL,
> +				  GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE |
> +				  GLOBAL2_WDOG_CONTROL_QC_ENABLE |
> +				  GLOBAL2_WDOG_CONTROL_SWRESET);
> +}

Those above should be simple Global 2 routines to access the
WDOG_CONTROL register data and functions.

> +const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops = {
> +	.irq_action = mv88e6097_watchdog_action,
> +	.irq_setup = mv88e6097_watchdog_setup,
> +	.irq_free = mv88e6097_watchdog_free,
> +};
> +
> +static irqreturn_t mv88e6xxx_g2_watchdog_thread_fn(int irq, void *dev_id)
> +{
> +	struct mv88e6xxx_chip *chip = dev_id;
> +	irqreturn_t ret = IRQ_NONE;
> +
> +	mutex_lock(&chip->reg_lock);
> +	if (chip->info->ops->watchdog_ops->irq_action)
> +		ret = chip->info->ops->watchdog_ops->irq_action(chip, irq);
> +	mutex_unlock(&chip->reg_lock);
> +
> +	return ret;
> +}
> +
> +static void mv88e6xxx_g2_watchdog_free(struct mv88e6xxx_chip *chip)
> +{
> +	mutex_lock(&chip->reg_lock);
> +	if (chip->info->ops->watchdog_ops->irq_free)
> +		chip->info->ops->watchdog_ops->irq_free(chip);
> +	mutex_unlock(&chip->reg_lock);
> +
> +	free_irq(chip->watchdog_irq, chip);
> +	irq_dispose_mapping(chip->watchdog_irq);
> +}
> +
> +static int mv88e6xxx_g2_watchdog_setup(struct mv88e6xxx_chip *chip)
> +{
> +	int err;
> +
> +	chip->watchdog_irq = irq_find_mapping(chip->g2_irq.domain,
> +					      GLOBAL2_INT_SOURCE_WATCHDOG);
> +	if (chip->watchdog_irq < 0)
> +		return chip->watchdog_irq;
> +
> +	err = request_threaded_irq(chip->watchdog_irq, NULL,
> +				   mv88e6xxx_g2_watchdog_thread_fn,
> +				   IRQF_ONESHOT | IRQF_TRIGGER_FALLING,
> +				   "mv88e6xxx-watchdog", chip);
> +	if (err)
> +		return err;
> +
> +	mutex_lock(&chip->reg_lock);
> +	if (chip->info->ops->watchdog_ops->irq_setup)
> +		err = chip->info->ops->watchdog_ops->irq_setup(chip);
> +	mutex_unlock(&chip->reg_lock);
> +
> +	return err;
> +}

We should not mix routines to access the chip registers with driver
logic. That makes the code hard to read and maintain and lead us to drop
error checkings for instance.

The above boilerplate for watchdog/irq access can be added in chip.c
wrapping simple chip->info->ops->watchdog_* functions.

See my comments in 2/2.

Thanks,

        Vivien

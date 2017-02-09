From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v3 net-next 1/2] net: dsa: mv88e6xxx: Add watchdog interrupt handler
Date: Thu, 09 Feb 2017 11:33:23 -0500
Message-ID: <877f4z8gto.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1486595023-28371-1-git-send-email-andrew@lunn.ch> <1486595023-28371-2-git-send-email-andrew@lunn.ch> <878tpfuztc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170209161231.GC29882@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41316 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752348AbdBIQen (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 11:34:43 -0500
In-Reply-To: <20170209161231.GC29882@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> > +static int mv88e6097_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
>> > +{
>> > +	u16 reg;
>> > +
>> > +	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
>> 
>> We should not ignore read errors.
>
> We are in the middle of an interrupt handler. If we get a read error
> here, we are probable one step from a "Kernel Panic -- not syncing:
> attempted to kill idle task".
>
> About the only thing which makes sense is to print a warning
> message. But that really should happen in one central place,
> mv88e6xxx_smi_read(), so it covers all reads everywhere.
>
>> > +	dev_info(chip->dev, "Watchdog event: 0x%04x", reg);
>> > +
>> > +	return IRQ_HANDLED;
>> > +}
>> > +
>> > +static void mv88e6097_watchdog_free(struct mv88e6xxx_chip *chip)
>> > +{
>> > +	u16 reg;
>> > +
>> > +	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
>> > +
>> > +	reg &= ~(GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE |
>> > +		 GLOBAL2_WDOG_CONTROL_QC_ENABLE);
>> > +
>> > +	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, reg);
>> 
>> Same here.
>
> Again, and do what? We are in the process of unbinding/unloading the
> kernel module. We are going to keep going whatever, and there is no
> mechanism to say an error occurred at this point, other than a printk.
> Again, such a printk should be in mv88e6xxx_smi_write().

I do agree with the fact that there is not much left to do if such error
occurs in that context. But still, functions implemented in global2.c
(or whatever internal SMI device file) should be written regardless when
or how they will be used, in an interrupt handler, in driver probe, etc.

These should be just self-documented basic access functions to Marvell
chip registers. chip.c then implements the interface and glue with DSA,
watchdog class, etc.

Mixing this with other layers logic results in losing the robust and
self documented code that we are trying to implement here.

Thanks,

        Vivien

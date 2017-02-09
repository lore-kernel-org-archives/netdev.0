From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next 1/2] net: dsa: mv88e6xxx: Add watchdog
 interrupt handler
Date: Thu, 9 Feb 2017 17:12:31 +0100
Message-ID: <20170209161231.GC29882@lunn.ch>
References: <1486595023-28371-1-git-send-email-andrew@lunn.ch>
 <1486595023-28371-2-git-send-email-andrew@lunn.ch>
 <878tpfuztc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33009 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753182AbdBIQlF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 11:41:05 -0500
Content-Disposition: inline
In-Reply-To: <878tpfuztc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 10:52:15AM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > +static int mv88e6097_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
> > +{
> > +	u16 reg;
> > +
> > +	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
> 
> We should not ignore read errors.

Hi Vivien

We are in the middle of an interrupt handler. If we get a read error
here, we are probable one step from a "Kernel Panic -- not syncing:
attempted to kill idle task".

About the only thing which makes sense is to print a warning
message. But that really should happen in one central place,
mv88e6xxx_smi_read(), so it covers all reads everywhere.

> > +	dev_info(chip->dev, "Watchdog event: 0x%04x", reg);
> > +
> > +	return IRQ_HANDLED;
> > +}
> > +
> > +static void mv88e6097_watchdog_free(struct mv88e6xxx_chip *chip)
> > +{
> > +	u16 reg;
> > +
> > +	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
> > +
> > +	reg &= ~(GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE |
> > +		 GLOBAL2_WDOG_CONTROL_QC_ENABLE);
> > +
> > +	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, reg);
> 
> Same here.

Again, and do what? We are in the process of unbinding/unloading the
kernel module. We are going to keep going whatever, and there is no
mechanism to say an error occurred at this point, other than a printk.
Again, such a printk should be in mv88e6xxx_smi_write().

       Andrew

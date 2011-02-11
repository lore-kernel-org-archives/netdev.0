From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 1/3] tg3: Avoid setting power.can_wakeup for devices
 that cannot wake up
Date: Thu, 10 Feb 2011 16:00:15 -0800
Message-ID: <20110211000015.GA4254@mcarlson.broadcom.com>
References: <201102101751.56508.rjw@sisk.pl>
 <201102101753.09504.rjw@sisk.pl>
 <20110210204844.GA4158@mcarlson.broadcom.com>
 <201102102208.42410.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Michael Chan" <mchan@broadcom.com>,
	"Linux PM mailing list" <linux-pm@lists.linux-foundation.org>,
	"Thomas Fjellstrom" <thomas@fjellstrom.ca>,
	"Jay Cliburn" <jcliburn@gmail.com>,
	"Chris Snook" <chris.snook@gmail.com>,
	"Jie Yang" <jie.yang@atheros.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4035 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757366Ab1BKAAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 19:00:37 -0500
In-Reply-To: <201102102208.42410.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 10, 2011 at 01:08:42PM -0800, Rafael J. Wysocki wrote:
> On Thursday, February 10, 2011, Matt Carlson wrote:
> > On Thu, Feb 10, 2011 at 08:53:09AM -0800, Rafael J. Wysocki wrote:
> > > From: Rafael J. Wysocki <rjw@sisk.pl>
> > > 
> > > The tg3 driver uses device_init_wakeup() in such a way that the
> > > device's power.can_wakeup flag may be set even though the PCI
> > > subsystem cleared it before, in which case the device cannot wake
> > > up the system from sleep states.  Modify the driver to only change
> > > the power.can_wakeup flag if the device is not capable of generating
> > > wakeup signals.
> > > 
> > > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> > > ---
> > >  drivers/net/tg3.c |    6 ++++--
> > >  1 file changed, 4 insertions(+), 2 deletions(-)
> > > 
> > > Index: linux-2.6/drivers/net/tg3.c
> > > ===================================================================
> > > --- linux-2.6.orig/drivers/net/tg3.c
> > > +++ linux-2.6/drivers/net/tg3.c
> > > @@ -12403,9 +12403,11 @@ static void __devinit tg3_get_eeprom_hw_
> > >  			tp->tg3_flags3 |= TG3_FLG3_RGMII_EXT_IBND_TX_EN;
> > >  	}
> > >  done:
> > > -	device_init_wakeup(&tp->pdev->dev, tp->tg3_flags & TG3_FLAG_WOL_CAP);
> > > -	device_set_wakeup_enable(&tp->pdev->dev,
> > > +	if (tp->tg3_flags & TG3_FLAG_WOL_CAP)
> > > +		device_set_wakeup_enable(&tp->pdev->dev,
> > >  				 tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
> > > +	else
> > > +		device_set_wakeup_capable(&tp->pdev->dev, false);
> > 
> > I did this because I couldn't see where 'can_wakeup' gets set.  I don't
> > see a call to device_init_wakeup() that would be relevant to tg3
> > devices.  I do see a couple calls to device_set_wakeup_capable() in
> > acpi/glue.c and acpi/scan.c.  Is that the place?
> 
> No, it's pci_pm_init() or platform_pci_wakeup_init() and they both use
> device_set_wakeup_capable() rather tha device_init_wakeup(), which is just a
> combination of device_set_wakeup_capable() and device_set_wakeup_enable()
> anyway.
> 
> And there's no why reason PCI drivers should use device_pm_init() at all.

O.K.

Acked-by: Matt Carlson <mcarlson@broadcom.com>

> > >  }
> > >  
> > >  static int __devinit tg3_issue_otp_command(struct tg3 *tp, u32 cmd)
> > 
> > This is something I was always curious about too.  The TG3_FLAG_WOL_CAP
> > tracks whether or not the device can handle WOL.  Is it safe to do away
> > with this flag and lean on the 'can_wakeup' flag instead?
> 
> I don't think so.  power.can_wakeup only tracks the capability to generate
> wakeup signals from the PCI perspective and it is set by PCI if the device
> appears to be able to generate wakeup signals.
> 
> So, I think the driver should work as in the $subject patch - reset the
> power.can_wakeup flag if TG3_FLAG_WOL_CAP is unset and don't touch it
> otherwise.

That makes sense.  Thanks.


From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 1/3] tg3: Avoid setting power.can_wakeup for devices
 that cannot wake up
Date: Thu, 10 Feb 2011 12:48:44 -0800
Message-ID: <20110210204844.GA4158@mcarlson.broadcom.com>
References: <201102101751.56508.rjw@sisk.pl>
 <201102101753.09504.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Linux PM mailing list" <linux-pm@lists.linux-foundation.org>,
	"Thomas Fjellstrom" <thomas@fjellstrom.ca>,
	"Jay Cliburn" <jcliburn@gmail.com>,
	"Chris Snook" <chris.snook@gmail.com>,
	"Jie Yang" <jie.yang@atheros.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2616 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917Ab1BJUtD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 15:49:03 -0500
In-Reply-To: <201102101753.09504.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 10, 2011 at 08:53:09AM -0800, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> The tg3 driver uses device_init_wakeup() in such a way that the
> device's power.can_wakeup flag may be set even though the PCI
> subsystem cleared it before, in which case the device cannot wake
> up the system from sleep states.  Modify the driver to only change
> the power.can_wakeup flag if the device is not capable of generating
> wakeup signals.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> ---
>  drivers/net/tg3.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/drivers/net/tg3.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/tg3.c
> +++ linux-2.6/drivers/net/tg3.c
> @@ -12403,9 +12403,11 @@ static void __devinit tg3_get_eeprom_hw_
>  			tp->tg3_flags3 |= TG3_FLG3_RGMII_EXT_IBND_TX_EN;
>  	}
>  done:
> -	device_init_wakeup(&tp->pdev->dev, tp->tg3_flags & TG3_FLAG_WOL_CAP);
> -	device_set_wakeup_enable(&tp->pdev->dev,
> +	if (tp->tg3_flags & TG3_FLAG_WOL_CAP)
> +		device_set_wakeup_enable(&tp->pdev->dev,
>  				 tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
> +	else
> +		device_set_wakeup_capable(&tp->pdev->dev, false);

I did this because I couldn't see where 'can_wakeup' gets set.  I don't
see a call to device_init_wakeup() that would be relevant to tg3
devices.  I do see a couple calls to device_set_wakeup_capable() in
acpi/glue.c and acpi/scan.c.  Is that the place?

>  }
>  
>  static int __devinit tg3_issue_otp_command(struct tg3 *tp, u32 cmd)

This is something I was always curious about too.  The TG3_FLAG_WOL_CAP
tracks whether or not the device can handle WOL.  Is it safe to do away
with this flag and lean on the 'can_wakeup' flag instead?  My concern is
that some other part of the system might enable that flag after
tg3_get_invariants() has run.  If that happens and the device isn't
really WOL capable bad things can occur.


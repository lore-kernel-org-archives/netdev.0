From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] igb/e1000e/e1000/e100: make wol usable
Date: Wed, 22 Jul 2009 16:43:03 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0907221642110.9900@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090721210115.GL8515@gospo.rdu.redhat.com>
 <273D38FBE7C6FE46A1689FCD014A0B8B55D57764@azsmsx505.amr.corp.intel.com>
 <20090722022745.GM8515@gospo.rdu.redhat.com>
 <5f2db9d90907212025k31c3a941v5fd1be9ed171e4c1@mail.gmail.com>
 <20090722193400.GN8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"stable@kernel.org" <stable@kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24859 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755206AbZGVXnE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 19:43:04 -0400
In-Reply-To: <20090722193400.GN8515@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jul 2009, Andy Gospodarek wrote:

> On Tue, Jul 21, 2009 at 08:25:31PM -0700, Alexander Duyck wrote:
> > My understanding was that the can_wakeup was supposed to be
> > initialized by pci_pm_init or platform_pci_wakeup_init based on the
> > pci-e capabilities.  Is this not the case?  It seems like this is
> > where you should be looking to determine why the the can_wakeup isn't
> > being initialized correctly.
> > 
> > The patch below won't solve the problem either.  The problem is that
> > the can_wakeup value is being disabled when the EEPROM doesn't support
> > WOL.
> 
> The lack of EEPROM support for this was not the problem at all.
> Ultimately it turns out that can_wakeup is set in pci_pm_init, so calls
> to device_init_wakeup and device_set_wakeup_capable should not be needed
> in any driver.
> 
> > If you have to do this in the drivers, then my suggestion is to take a
> > look at how ixgbe is doing it.  You essentially need to initialize
> > can_wakeup to true, and then set the should_wakeup attribute based on
> > the EEPROM setting or via ethtool.  This way you can still toggle the
> > should_wakeup option without being blocked by the EEPROM disabling it.
> 
> The first patch does exactly that (and ixgbe was part of my inspiration
> for it).  Since can_wakeup and should_wakeup are both set in
> device_init_wakeup it's a suitable alternative in driver probe
> functions, but probably not ideal when drivers check for
> device_can_wakeup in their ethtool set_wol functions.
> 
> Anyway, I knew I would find a bug or unnecessary code between e1000e and
> friends or ixgbe, so it looks like ixgbe has an unnecessary call to
> device_init_wakeup.  Feel free to consider this patch as an alternative.
> 
> 
> 
> [PATCH] ixgbe: remove unnecessary call to device_init_wakeup
> 
> Calls to device_init_wakeup should not be necessary in drivers that use
> device_set_wakeup_enable since pci_pm_init will set the can_wakeup flag
> for the device when initialized.
> 
> I can't test this since I don't have any of the 82599 KX4 interfaces
> (the only ones capable of WOL), but I did instrument ixgbe_probe and
> know that can_wakeup=1 when device_init_wakeup is removed.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> 
> ---
> 
>  ixgbe_main.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 79f60e8..2f15abf 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -5640,7 +5640,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
>  		adapter->wol = 0;
>  		break;
>  	}
> -	device_init_wakeup(&adapter->pdev->dev, true);
>  	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
>  
>  	/* pick up the PCI bus settings for reporting later */

Works just fine on two different 82599 mezz cards that support WoL.  
Thanks Andy for finding and fixing.

Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

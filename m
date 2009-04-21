From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] e100: do not go D3 in shutdown unless system is powering off
Date: Wed, 22 Apr 2009 00:17:19 +0200
Message-ID: <200904220017.19670.rjw@sisk.pl>
References: <1240237621-11415-1-git-send-email-cascardo@holoscopio.com> <200904202114.01932.rjw@sisk.pl> <20090421215248.GF6147@vespa.holoscopio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net
To: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:38381 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148AbZDUWSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 18:18:11 -0400
In-Reply-To: <20090421215248.GF6147@vespa.holoscopio.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 21 April 2009, Thadeu Lima de Souza Cascardo wrote:
> On Mon, Apr 20, 2009 at 09:13:59PM +0200, Rafael J. Wysocki wrote:
> > On Monday 20 April 2009, Thadeu Lima de Souza Cascardo wrote:
> > > After experimenting with kexec with the last merges after 2.6.29, I've
> > > had some problems when probing e100. It would not read the eeprom. After
> > > some bisects, I realized this has been like that since forever (at least
> > > 2.6.18). The problem is that shutdown is doing the same thing that
> > > suspend does and puts the device in D3 state. I couldn't find a way to
> > > get the device back to a sane state in the probe function. So, based on
> > > some similar patches from Rafael J. Wysocki for e1000, e1000e and ixgbe,
> > > I wrote this one for e100.
> > > 
> > > Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
> > > ---
> > >  drivers/net/e100.c |   27 +++++++++++++++++++++------
> > >  1 files changed, 21 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> > > index c0f8443..3db7b29 100644
> > > --- a/drivers/net/e100.c
> > > +++ b/drivers/net/e100.c
> > > @@ -2728,7 +2728,7 @@ static void __devexit e100_remove(struct pci_dev *pdev)
> > >  #define E100_82552_SMARTSPEED   0x14   /* SmartSpeed Ctrl register */
> > >  #define E100_82552_REV_ANEG     0x0200 /* Reverse auto-negotiation */
> > >  #define E100_82552_ANEG_NOW     0x0400 /* Auto-negotiate now */
> > > -static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
> > > +static int __e100_shutdown(struct pci_dev *pdev, bool *enable_wake)
> > >  {
> > >  	struct net_device *netdev = pci_get_drvdata(pdev);
> > >  	struct nic *nic = netdev_priv(netdev);
> > > @@ -2749,19 +2749,31 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
> > >  			           E100_82552_SMARTSPEED, smartspeed |
> > >  			           E100_82552_REV_ANEG | E100_82552_ANEG_NOW);
> > >  		}
> > > -		if (pci_enable_wake(pdev, PCI_D3cold, true))
> > > -			pci_enable_wake(pdev, PCI_D3hot, true);
> > > +		*enable_wake = true;
> > >  	} else {
> > > -		pci_enable_wake(pdev, PCI_D3hot, false);
> > > +		*enable_wake = false;
> > >  	}
> > >  
> > >  	pci_disable_device(pdev);
> > > -	pci_set_power_state(pdev, PCI_D3hot);
> > >  
> > >  	return 0;
> > >  }
> > >  
> > > +static void __e100_power_off(struct pci_dev *pdev, bool wake)
> > > +{
> > > +	pci_enable_wake(pdev, PCI_D3hot, wake);
> > > +	pci_set_power_state(pdev, PCI_D3hot);
> > > +}
> > > +
> > >  #ifdef CONFIG_PM
> > > +static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
> > > +{
> > > +	bool wake;
> > > +	int retval = __e100_shutdown(pdev, &wake);
> > 
> > I'd call pci_prepare_to_sleep() here if wake is 'true' instead of the
> > __e100_power_off(), because there is a chance the platform will prefer some
> > other power state to put the device into.
> > 
> > In fact, looking at the entire driver's code, I think you could just call
> > pci_prepare_to_sleep(pdev) here instead of __e100_power_off(pdev, wake)
> > and discard the value of wake.
> > 
> 
> If there is no advantage in using pci_enable_wake with false in the case
> the device cannot WOL or ASF, I will just use pci_prepare_to_sleep and
> drop this enable_wake/wake variable in both suspend and shutdown. Any
> reason we should use pci_enable_wake with false?

In principle there is one.  Namely, if you call it with 'false', it will call
the platform (eg. ACPI) to disable the wake-up functionality of the device,
which generally may be necessary.

Also, pci_prepare_to_sleep() is really designed for suspend/hibernation,
because it first finds the appropriate state to put the device into and that
depends on the target sleep state of the system.

So, I'd recommend using pci_prepare_to_sleep() in .suspend() and the
pci_enable_wake()/pci_set_power_state() combo in .shutdown() (if the system
is going for power off).

Thanks,
Rafael

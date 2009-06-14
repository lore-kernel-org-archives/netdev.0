From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [PATCH] Make e100 suspend handler support PCI cards lacking PM
	capability
Date: Sun, 14 Jun 2009 14:51:28 +0200
Message-ID: <20090614125128.GA32034@rhlx01.hs-esslingen.de>
References: <20081229102515.GA17171@rhlx01.hs-esslingen.de> <20090603063025.GA32600@rhlx01.hs-esslingen.de> <20090613191931.GA31019@rhlx01.hs-esslingen.de> <200906140028.16025.rjw@sisk.pl>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@lisas.de, akpm@linux-foundation.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:56257 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763AbZFNMv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 08:51:26 -0400
Content-Disposition: inline
In-Reply-To: <200906140028.16025.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, Jun 14, 2009 at 12:28:15AM +0200, Rafael J. Wysocki wrote:
> On Saturday 13 June 2009, Andreas Mohr wrote:
> > Hi all,
> > 
> > after having added non-MII PHY card support to e100, I noticed that
> > the suspend handler rejects power-management non-capable PCI cards,
> 
> Well, that means we have a bug somewhere in the PCI PM core.

I don't know. I had shortly investigated the same thing,
but it very much seemed that this is by design, pci_set_power_state()
is documented to reject non-PM cards (in power/pci.txt, and in
pci.c, too). Thus I didn't work in this area.

And from a cleanliness point of view pci_set_power_state()
acting on a non-PM card with no special non-PM ACPI support _should_
return an error status I guess.
(especially since docs say that pci_set_power_state() should
be used for PM cards)

> > causing a S2R request to immediately get back up to the desktop,
> > losing network access in the process (rtnl mutex deadlock).
> 
> That's bad.

Indeed, and I have no idea what the problem was.
rtnl_is_locked() always was false within suspend/resume,
thus it had to be a userspace-triggered effect sometime
_after_ (non-)resume happened
(probably due to the network controller being down and thus inoperable
after .suspend).

BTW, after that failed .suspend, .resume was not called. I assume this to
be correct behaviour.

> >  static int __e100_power_off(struct pci_dev *pdev, bool wake)
> >  {
> > +	/* some older devices don't support PCI PM
> > +	 * (e.g. mac_82557_D100_B combo card with 80c24 PHY)
> > +	 * - skip those! (they most likely won't support WoL either)
> > +	 */
> > +	if (!pci_find_capability(pdev, PCI_CAP_ID_PM))
> > +		return 0;
> 
> Devices without PCI_CAP_ID_PM may still be power-manageable by ACPI, so
> returning 0 at this point is not a general solution.

Oh, interesting.

BTW, any idea why we have several drivers doing some seemingly useless

        /* Find power-management capability. */
        pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
        if (pm_cap == 0) {
                printk(KERN_ERR PFX "Cannot find PowerManagement capability, "
                       "aborting.\n");
                err = -EIO;
                goto err_out_free_res;
        }

?

- it's code bloat
- it needlessly rejects non-PM cards
- it annoys the hell out of users of a non-PM card


> > +
> >  	if (wake) {
> >  		return pci_prepare_to_sleep(pdev);
> 
> pci_prepare_to_sleep() is supposed to return 0 for your device.  I'll have a
> look at it.

No, wake is false for my card, thus that's not the branch to
investigate.

And that's probably the reason why the patch in the next mail
didn't work.
(I #if 0'ed my e100 changes, and then patched pci.c,
and it did properly contain the patched parts,
and the kernel rebuild then failed to suspend)

pci_legacy_suspend(): e100_suspend+0x0/0x20 [e100] returns -5
pm_op(): pci_pm_suspend+0x0/0xd7 returns -5
PM: Device 0000:02:07.0 failed to suspend: error -5
PM: Some devices failed to suspend

Most likely your patch didn't change pci_set_power_state() processing,
I'd think.

Now what to do next?
Note that I won't be able to test anything for about a week now,
unfortunately.

Thanks for your info!

Andreas Mohr

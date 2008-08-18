From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] forcedeth 10de:0373 doesn't work on resume
Date: Mon, 18 Aug 2008 23:39:39 +0200
Message-ID: <200808182339.40403.rjw@sisk.pl>
References: <4898AA28.8000507@simon.arlott.org.uk> <200808182313.10235.rjw@sisk.pl> <48A9E8B3.4040800@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, jgarzik@redhat.com,
	netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, ranma+kernel@tdiedrich.de
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:47582 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752798AbYHRVgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2008 17:36:21 -0400
In-Reply-To: <48A9E8B3.4040800@simon.arlott.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 18 of August 2008, Simon Arlott wrote:
> On 18/08/08 22:13, Rafael J. Wysocki wrote:
> > On Monday, 18 of August 2008, Andrew Morton wrote:
> >> On Tue, 05 Aug 2008 20:29:44 +0100
> >> Simon Arlott <simon@fire.lp0.eu> wrote:
> >> >
> >> 
> >> [two weeks pass...]
> > 
> > [Must have missed this message.]
> > 
> > I have a box with forcedeth that evidently works after a resume from
> > hibernation.  Unfortunately, so far I haven't been able to make the box
> 
> With hibernation would it re-initialise the devices differently?

Yes.  Usually the BIOS does something to devices in that case.

> > resume from suspend to RAM.  I'll do my best to try again tomorrow, but there's
> > a little hope. :-(
> 
> Mine doesn't either, try standby?

OK, I will.

> >> > My NIC stops working after resuming from standby, it's not receiving any interrupts:
> >> > Commit 25d90810ff49d2a63475776f24c74c6bb49b045f ([netdrvr] forcedeth: reorder suspend/resume code) 
> >> > introduces pci_disable_device to nv_suspend, but there's no corresponding pci_enable_device in 
> >> > nv_resume - so I added one (copied from e1000):
> >> > 
> >> > diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> >> > index 01b38b0..db4f875 100644
> >> > --- a/drivers/net/forcedeth.c
> >> > +++ b/drivers/net/forcedeth.c
> >> > @@ -5922,6 +5922,13 @@ static int nv_resume(struct pci_dev *pdev)
> >> >  
> >> >  	pci_set_power_state(pdev, PCI_D0);
> >> >  	pci_restore_state(pdev);
> >> > +	rc = pci_enable_device(pdev);
> >> > +	if (rc) {
> >> > +		printk(KERN_ERR "forcedeth: Cannot enable PCI device from suspend\n");
> >> > +		return rc;
> >> > +	}
> >> > +	pci_set_master(pdev);
> >> > +
> >> >  	/* ack any pending wake events, disable PME */
> >> >  	pci_enable_wake(pdev, PCI_D0, 0);
> >> >  
> >> 
> >> That seems like a sensible change.
> >> 
> 
> With this applied, I can resume from standby *without MSI* and the 
> NIC still works. I haven't tested it without MSI and without the 
> patch... mostly because I got a BUG when I tried to recompile.

That's interesting.  I'll try to reproduce it.

> >> > This results in interrupts being re-enabled after suspend:
> >> > However, the NIC still doesn't work after resume.
> > 
> > Simon, I'd prefer the full dmesg to the grepped forcedeth messages.
> > 
> 
> Attached. (The previous email has all the standby/resume log output.)
> 
> > I guess this was resume from suspend to RAM?
> 
> Standby - resume from RAM is completely broken for my system.
> 
> >> Is it still broken in current kernels?
> > 
> > It probably is.
> 
> If I have MSI enabled, it still doesn't work.

Hm.  I wonder if that's specific to forcedeth or other drivers may be affected.

Thanks,
Rafael

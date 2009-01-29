From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Thu, 29 Jan 2009 23:22:05 +0100
Message-ID: <200901292322.06339.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901281757240.3123@localhost.localdomain> <20090129021944.GA12879@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Parag Warudkar" <parag.lkml@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:44940 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753445AbZA2WW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 17:22:26 -0500
In-Reply-To: <20090129021944.GA12879@xw6200.broadcom.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 January 2009, Matt Carlson wrote:
> On Wed, Jan 28, 2009 at 06:10:37PM -0800, Linus Torvalds wrote:
> > 
> > 
> > On Wed, 28 Jan 2009, Parag Warudkar wrote:
> > > 
> > > Sure, diff -u below. There are differences but not sure if they are 
> > > abnormal or expected.
> > 
> > Well, they're all in the "extended set", ie not the basic registers that 
> > the PCI layer saves. The PCI layer normally just saves the low 16 dwords, 
> > along with the PCI[EX] capability thing.
> > 
> > None of the PCI save/restore routines have ever saved the extended state 
> > (well, "ever" is a strong word - I think we long ago used to pass in how 
> > many bytes we wanted saved, but got rid of it), and it certainly didn't 
> > change with the recent PCI suspend/resume changes.
> > 
> > I get the feeling that it's some odd tg3 issue. That tg3 driver does have 
> > that special
> > 
> >         /* Make sure register accesses (indirect or otherwise)
> >          * will function correctly.
> >          */
> >         pci_write_config_dword(tp->pdev,
> >                                TG3PCI_MISC_HOST_CTRL,
> >                                tp->misc_host_ctrl);
> > 
> > in its own version of setting the power state, and maybe that really 
> > _must_ happen before we actually set the state back to PCI_D0. That sounds 
> > very odd, but hey..
> > 
> > I added Matt Carlson to the cc, since he seems to be the main tg3 
> > authority here.
> > 
> > Matt: the whole discussion is on netdev and the kernel mailing list, but 
> > the short version is that -rc3 suspends and resumes for Parag again 
> > (unlike -rc2), but tg3 doesn't appear to resume properly. The generic PCI 
> > layer now does more at resume time (very early, when interrupts are still 
> > off), see
> > 
> >  - pci_pm_resume_noirq ->
> >      pci_pm_default_resume_noirq() ->
> >        pci_restore_standard_config()
> > 
> > for more of the details (basically it always does that 
> > "pci_restore_state()" and tries to bring the device back to PCI_D0).
> 
> Thanks Linus.  I'm looking over the diffs Parag sent and I already see
> some suspicious register settings.  Let me think about this some more
> and then I'll jump into the discussion.

FWIW, I can't reproduce the problem with tg3 on my testbox.  Suspend to RAM
and resume seem to work correctly on it.

Thanks,
Rafael

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] net: forcedeth use pci_choose_state instead of PCI_D3hot - v2
Date: Sun, 17 Aug 2008 23:47:35 +0200
Message-ID: <200808172347.36582.rjw@sisk.pl>
References: <1218954333-12819-1-git-send-email-yhlu.kernel@gmail.com> <200808172134.20230.rjw@sisk.pl> <86802c440808171358y55361a52pa6d0aacf44a1875f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@redhat.com>, "Ingo Molnar" <mingo@elte.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: "Yinghai Lu" <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:41655 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886AbYHQVo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Aug 2008 17:44:28 -0400
In-Reply-To: <86802c440808171358y55361a52pa6d0aacf44a1875f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, 17 of August 2008, Yinghai Lu wrote:
> On Sun, Aug 17, 2008 at 12:34 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> > On Sunday, 17 of August 2008, Rafael J. Wysocki wrote:
> >> On Sunday, 17 of August 2008, Yinghai Lu wrote:
> >> > On Sun, Aug 17, 2008 at 9:55 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> >> > > On Sunday, 17 of August 2008, Rafael J. Wysocki wrote:
> >> > >> On Sunday, 17 of August 2008, Yinghai Lu wrote:
> >> > >> > after
> >> > >> >
> >> > >> > | commit f735a2a1a4f2a0f5cd823ce323e82675990469e2
> >> > >> > | Author: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> >> > >> > | Date:   Sun May 18 15:02:37 2008 +0200
> >> > >> > |
> >> > >> > |    [netdrvr] forcedeth: setup wake-on-lan before shutting down
> >> > >> > |
> >> > >> > |    When hibernating in 'shutdown' mode, after saving the image the suspend hook
> >> > >> > |    is not called again.
> >> > >> > |    However, if the device is in promiscous mode, wake-on-lan will not work.
> >> > >> > |    This adds a shutdown hook to setup wake-on-lan before the final shutdown.
> >> > >> > |
> >> > >> > |    Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> >> > >> > |    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> >> > >> >
> >> > >> > my servers with nvidia mcp55 nic doesn't work with msi in second kernel by kexec
> >> > >> >
> >> > >> > after remove pci_set_power_state(, PCI_D3hot) that nic/msi will work again.
> >> > >> >
> >> > >> > check with e1000 is using pci_choose_state in _shutdown.
> >> > >
> >> > > This is wrong.
> >> > >
> >> > >> > So change that pci_choose_state(pdev, ...), and it works.
> >> > >>
> >> > >> Well, this doesn't look like a good solution to me, because you're putting
> >> > >> PMSG_SUSPEND in there, which is not correct for shutdown.  The right thing to
> >> > >> do would be to avoid changing the device power state if nv_shutdown() is
> >> > >> used for kexec or to rework the initialization of the adapter to handle the
> >> > >> case when it's initially in D3.
> >> > >>
> >> > >> Does it help if you just remove the pci_set_power_state(pdev, PCI_D3hot)
> >> > >> altogether?
> >> > >
> >> > > Ah, sorry.  I see it does.
> >> > >
> >> > > Actually, I think you can use pci_prepare_to_sleep() instead of
> >> > > pci_enable_wake() / pci_set_power_state() combo.  It wasn't designed for this
> >> > > purpose, but should work nevertheless.
> >> > >
> >> > > Can you please check if the appended patch works instead of your one?
> >> > >
> >> > > Rafael
> >> > >
> >> > > ---
> >> > > Fix the problem that boxes with NVidia MCP55 don't work with MSI
> >> > > in a kexeced kernel.
> >> > >
> >> > > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> >> > > ---
> >> > >  drivers/net/forcedeth.c |    4 +---
> >> > >  1 file changed, 1 insertion(+), 3 deletions(-)
> >> > >
> >> > > Index: linux-2.6/drivers/net/forcedeth.c
> >> > > ===================================================================
> >> > > --- linux-2.6.orig/drivers/net/forcedeth.c
> >> > > +++ linux-2.6/drivers/net/forcedeth.c
> >> > > @@ -5975,10 +5975,8 @@ static void nv_shutdown(struct pci_dev *
> >> > >        if (netif_running(dev))
> >> > >                nv_close(dev);
> >> > >
> >> > > -       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> >> > > -       pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
> >> > >        pci_disable_device(pdev);
> >> > > -       pci_set_power_state(pdev, PCI_D3hot);
> >> > > +       pci_prepare_to_sleep(pdev);
> >> > >  }
> >> > >  #else
> >> > >  #define nv_suspend NULL
> >> > >
> >> > >
> >> >
> >> > your patch doesn't work...  it seems that silicon has problem with D3Hot
> >>
> >> Okay, so perhaps it's better to do something like this:
> >>
> >> ---
> >>  drivers/net/forcedeth.c |    8 +++++---
> >>  1 file changed, 5 insertions(+), 3 deletions(-)
> >>
> >> Index: linux-2.6/drivers/net/forcedeth.c
> >> ===================================================================
> >> --- linux-2.6.orig/drivers/net/forcedeth.c
> >> +++ linux-2.6/drivers/net/forcedeth.c
> >> @@ -5975,10 +5975,12 @@ static void nv_shutdown(struct pci_dev *
> >>       if (netif_running(dev))
> >>               nv_close(dev);
> >>
> >> -     pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> >> -     pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
> >>       pci_disable_device(pdev);
> >> -     pci_set_power_state(pdev, PCI_D3hot);
> >> +     if (system_state == SYS_POWER_OFF) {
> >
> > Sorry, it should be SYSTEM_POWER_OFF here.  Corrected patch is appended.
> >
> >> +             if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
> >> +                     pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> >> +             pci_set_power_state(pdev, PCI_D3hot);
> >> +     }
> >>  }
> >>  #else
> >>  #define nv_suspend NULL
> >> --
> >
> > ---
> >  drivers/net/forcedeth.c |    8 +++++---
> >  1 file changed, 5 insertions(+), 3 deletions(-)
> >
> > Index: linux-2.6/drivers/net/forcedeth.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/forcedeth.c
> > +++ linux-2.6/drivers/net/forcedeth.c
> > @@ -5975,10 +5975,12 @@ static void nv_shutdown(struct pci_dev *
> >        if (netif_running(dev))
> >                nv_close(dev);
> >
> > -       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> > -       pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
> >        pci_disable_device(pdev);
> > -       pci_set_power_state(pdev, PCI_D3hot);
> > +       if (system_state == SYSTEM_POWER_OFF) {
> > +               if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
> > +                       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> > +               pci_set_power_state(pdev, PCI_D3hot);
> > +       }
> >  }
> >  #else
> >  #define nv_suspend NULL
> >
> 
> why not like e1000 to
> pci_set_power_state(pdev, pci_choose_state(pdev, PMSG_SUSPEND));
> 
> pci_choose_state would check if platform support those state...

... but ->shutdown() only involves the platform in the
'system_state == SYSTEM_POWER_OFF' case!

In fact, using pci_choose_state() in ->shutdown() is a very convoluted way of
checking the 'system_state' value, and not a 100% reliable one. :-)

Namely, the fact that pci_choose_state() returns you D0 instead of D3hot for
'system_state != SYSTEM_POWER_OFF' is a pure coincidence (accidentally, there
is an ACPI handle for the device, but there need not be one) and you should
not rely on that in general.  Generally speaking, pci_choose_state() is not to
be used outside of the drivers' ->suspend() routines.

[Yes, this means e1000 will have to be fixed, as I said before.]

Apart from this, pci_choose_state() is broken and will shortly be deprecated.
Moreover, in future all direct references to PMSG_SUSPEND from the drivers
will be removed.

Thanks,
Rafael

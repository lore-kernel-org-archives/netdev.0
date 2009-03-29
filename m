From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Updated patch] Re: [PATCH] igb: fix kexec with igb
Date: Sun, 29 Mar 2009 13:19:13 +0200
Message-ID: <200903291319.15269.rjw@sisk.pl>
References: <49B1F934.5050006@kernel.org> <200903282227.28895.rjw@sisk.pl> <9929d2390903281930r59fe204bk30b511674eebd6a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yinghai@kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:60803 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734AbZC2LTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2009 07:19:16 -0400
In-Reply-To: <9929d2390903281930r59fe204bk30b511674eebd6a3@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 29 March 2009, Jeff Kirsher wrote:
> On Sat, Mar 28, 2009 at 2:27 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> > On Tuesday 24 March 2009, Yinghai Lu wrote:
> >> Rafael J. Wysocki wrote:
> >> > On Thursday 12 March 2009, Yinghai Lu wrote:
> >> >> Rafael J. Wysocki wrote:
> >> >>> On Sunday 08 March 2009, Rafael J. Wysocki wrote:
> >> >>>> On Sunday 08 March 2009, Yinghai Lu wrote:
> >> >>>>> Rafael J. Wysocki wrote:
> >> >>>>>> On Saturday 07 March 2009, Yinghai Lu wrote:
> >> >>>>>>> On Fri, Mar 6, 2009 at 11:18 PM, Jesse Brandeburg
> >> >>>>>>> <jesse.brandeburg@gmail.com> wrote:
> >> >>>>>>>> On Fri, Mar 6, 2009 at 8:33 PM, Yinghai Lu <yinghai@kernel.org> wrote:
> >> >>>>>>>>> Impact: could probe igb
> >> >>>>>>>>>
> >> >>>>>>>>> Found one system with 82575EB, in the kernel that is kexeced, probe igb
> >> >>>>>>>>> failed with -2.
> >> >>>>>>>>>
> >> >>>>>>>>> it looks like the same behavior happened on forcedeth.
> >> >>>>>>>>>
> >> >>>>>>>>> try to check system_state to make sure if put it on D3
> >> >>>>>>>>>
> >> >>>>>>>>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> >> >>>>>>>>>
> >> >>>>>>>>> ---
> >> >>>>>>>>>  drivers/net/igb/igb_main.c |   19 ++++++++++++++-----
> >> >>>>>>>>>  1 file changed, 14 insertions(+), 5 deletions(-)
> >> >>>>>>>> I see the point of the patch, but I know for a fact that ixgbe when
> >> >>>>>>>> enabled for MSI-X also doesn't work with kexec.
> >> >>>>>>>>
> >> >>>>>>>> so my questions are:
> >> >>>>>>>> are you going to change every driver?
> >> >>>>>>> i tend to only change driver that i have related HW.
> >> >>>>>>>
> >> >>>>>>>> why can't this be fixed in core kernel code instead?
> >> >>>>>>> will check it.
> >> >>>>>>>
> >> >>>>>>>> Shouldn't pci_enable_device take it out of D3?
> >> >>>>>>>> Or maybe it should be taken out of D3 immediately if someone tries to
> >> >>>>>>>> ioremap any of the BARx registers?
> >> >>>>>>> looks like second kernel can not detect the state any more.
> >> >>>>>> In fact pci_enable_device() calls pci_set_power_state(dev, PCI_D0) as the first
> >> >>>>>> thing.  The question is why it doesn't work as expected.
> >> >>>>> not sure... please check the version for forcedeth that you made.
> >> >>>>>
> >> >>>>> commit 3cb5599a84c557c0dd9a19feb63a3788268cf249
> >> >>>>> Author: Rafael J. Wysocki <rjw@sisk.pl>
> >> >>>>> Date:   Fri Sep 5 14:00:19 2008 -0700
> >> >>>>>
> >> >>>>>     forcedeth: fix kexec regression
> >> >>>>>
> >> >>>>>     Fix regression tracked as http://bugzilla.kernel.org/show_bug.cgi?id=11361
> >> >>>>>     and caused by commit f735a2a1a4f2a0f5cd823ce323e82675990469e2 ("[netdrvr]
> >> >>>>>     forcedeth: setup wake-on-lan before shutting down") that makes network
> >> >>>>>     adapters integrated into the NVidia MCP55 chipsets fail to work in kexeced
> >> >>>>>     kernels.  The problem appears to be that if the adapter is put into D3_hot
> >> >>>>>     during ->shutdown(), it cannot be brought back into D0 after kexec (ref.
> >> >>>>>     http://marc.info/?l=linux-kernel&m=121900062814967&w=4).  Therefore, only
> >> >>>>>     put forcedeth into D3 during ->shutdown() if the system is to be powered
> >> >>>>>     off.
> >> >>>> Thanks, I remember now.
> >> >>> In which case you need to rework igb_shutdown() rather than igb_suspend().
> >> >>>
> >> >>> Something like the patch below, perhaps (totally untested).
> >> >> it works, David, can you picked it up
> >> >
> >> > Still, Yinghai, can you please also test the patch below?  It fixes all
> >> > shortcomings in the driver's suspend and shutdown methods I was talking about
> >> > in one of the previous messages.  If it works, IMO it will be a preferable fix
> >> > (in particular, it would be good to check if WoL still works with it,
> >> > but I don't have the hardware).
> >> >
> >> > Thanks,
> >> > Rafael
> >> >
> >> > ---
> >> > From: Rafael J. Wysocki <rjw@sisk.pl>
> >> > Subject: net/igb: Fix kexec with igb (rev. 3)
> >> > Impact: Fix
> >> >
> >> > Yinghai Lu found one system with 82575EB where, in the kernel that is
> >> > kexeced, probe igb failed with -2, the reason being that the adapter
> >> > could not be brought back from D3 by the kexec kernel, most probably
> >> > due to quirky hardware (it looks like the same behavior happened on
> >> > forcedeth).
> >> >
> >> > Prevent igb from putting the adapter into D3 during shutdown except
> >> > when we going to power off the system.  For this purpose, seperate
> >> > igb_shutdown() from igb_suspend() and use the appropriate PCI PM
> >> > callbacks in both of them.
> >> >
> >> > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> >> > Reported-by: Yinghai Lu <yinghai@kernel.org>
> >> > ---
> >> >  drivers/net/igb/igb_main.c |   42 ++++++++++++++++++++++++++++++------------
> >> >  1 file changed, 30 insertions(+), 12 deletions(-)
> >> >
> >> > Index: linux-2.6/drivers/net/igb/igb_main.c
> >> > ===================================================================
> >> > --- linux-2.6.orig/drivers/net/igb/igb_main.c
> >> > +++ linux-2.6/drivers/net/igb/igb_main.c
> >> > @@ -4277,7 +4277,7 @@ int igb_set_spd_dplx(struct igb_adapter
> >> >  }
> >> >
> >> >
> >> > -static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
> >> > +static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake)
> >> >  {
> >> >     struct net_device *netdev = pci_get_drvdata(pdev);
> >> >     struct igb_adapter *adapter = netdev_priv(netdev);
> >> > @@ -4336,15 +4336,9 @@ static int igb_suspend(struct pci_dev *p
> >> >             wr32(E1000_WUFC, 0);
> >> >     }
> >> >
> >> > -   /* make sure adapter isn't asleep if manageability/wol is enabled */
> >> > -   if (wufc || adapter->en_mng_pt) {
> >> > -           pci_enable_wake(pdev, PCI_D3hot, 1);
> >> > -           pci_enable_wake(pdev, PCI_D3cold, 1);
> >> > -   } else {
> >> > +   *enable_wake = wufc || adapter->en_mng_pt;
> >> > +   if (!*enable_wake)
> >> >             igb_shutdown_fiber_serdes_link_82575(hw);
> >> > -           pci_enable_wake(pdev, PCI_D3hot, 0);
> >> > -           pci_enable_wake(pdev, PCI_D3cold, 0);
> >> > -   }
> >> >
> >> >     /* Release control of h/w to f/w.  If f/w is AMT enabled, this
> >> >      * would have already happened in close and is redundant. */
> >> > @@ -4352,12 +4346,29 @@ static int igb_suspend(struct pci_dev *p
> >> >
> >> >     pci_disable_device(pdev);
> >> >
> >> > -   pci_set_power_state(pdev, pci_choose_state(pdev, state));
> >> > -
> >> >     return 0;
> >> >  }
> >> >
> >> >  #ifdef CONFIG_PM
> >> > +static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
> >> > +{
> >> > +   int retval;
> >> > +   bool wake;
> >> > +
> >> > +   retval = __igb_shutdown(pdev, &wake);
> >> > +   if (retval)
> >> > +           return retval;
> >> > +
> >> > +   if (wake) {
> >> > +           pci_prepare_to_sleep(pdev);
> >> > +   } else {
> >> > +           pci_wake_from_d3(pdev, false);
> >> > +           pci_set_power_state(pdev, PCI_D3hot);
> >> > +   }
> >> > +
> >> > +   return 0;
> >> > +}
> >> > +
> >> >  static int igb_resume(struct pci_dev *pdev)
> >> >  {
> >> >     struct net_device *netdev = pci_get_drvdata(pdev);
> >> > @@ -4412,7 +4423,14 @@ static int igb_resume(struct pci_dev *pd
> >> >
> >> >  static void igb_shutdown(struct pci_dev *pdev)
> >> >  {
> >> > -   igb_suspend(pdev, PMSG_SUSPEND);
> >> > +   bool wake;
> >> > +
> >> > +   __igb_shutdown(pdev, &wake);
> >> > +
> >> > +   if (system_state == SYSTEM_POWER_OFF) {
> >> > +           pci_wake_from_d3(pdev, wake);
> >> > +           pci_set_power_state(pdev, PCI_D3hot);
> >> > +   }
> >> >  }
> >> >
> >> >  #ifdef CONFIG_NET_POLL_CONTROLLER
> >>
> >> it works too.
> >
> > Great, thanks for testing.
> >
> > Jeff, Jesse, is the patch fine with you?
> >
> > Rafael
> 
> Let me talk with Jesse on Monday about it.  I know that Jesse's
> concern's were that there were more than one driver afflicted with the
> same or similar issue and that it made more sense to fix this in the
> core for all drivers.  For instance ixgbe, IIRC, but because Yinghai
> did not have any other hardware, it was unclear if this was an issue
> on other drivers.

I think it was, at least theoretically.  We should generally avoid powering
off things on shutdown when it's not really necessary.  Also, the use of
pci_enable_wake() in these drivers is not really correct.

And in fact this is why I'm asking, because I have analogouns patches for some
other drivers in the works too.  If you are fine with the approach, I'll post
the whole series.

> After discussing this with Jesse, one of us will respond.  I will
> apply this patch to my tree anyway and if we are alright with the
> patch, I will push it out with my other patches to Dave.

Thanks!

Best,
Rafael

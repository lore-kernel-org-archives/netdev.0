From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Updated patch] Re: [PATCH] igb: fix kexec with igb
Date: Sat, 28 Mar 2009 19:30:21 -0700
Message-ID: <9929d2390903281930r59fe204bk30b511674eebd6a3@mail.gmail.com>
References: <49B1F934.5050006@kernel.org> <200903212305.00077.rjw@sisk.pl>
	 <49C96042.8040909@kernel.org> <200903282227.28895.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yinghai Lu <yinghai@kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:20618 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774AbZC2CaX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 22:30:23 -0400
In-Reply-To: <200903282227.28895.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 28, 2009 at 2:27 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Tuesday 24 March 2009, Yinghai Lu wrote:
>> Rafael J. Wysocki wrote:
>> > On Thursday 12 March 2009, Yinghai Lu wrote:
>> >> Rafael J. Wysocki wrote:
>> >>> On Sunday 08 March 2009, Rafael J. Wysocki wrote:
>> >>>> On Sunday 08 March 2009, Yinghai Lu wrote:
>> >>>>> Rafael J. Wysocki wrote:
>> >>>>>> On Saturday 07 March 2009, Yinghai Lu wrote:
>> >>>>>>> On Fri, Mar 6, 2009 at 11:18 PM, Jesse Brandeburg
>> >>>>>>> <jesse.brandeburg@gmail.com> wrote:
>> >>>>>>>> On Fri, Mar 6, 2009 at 8:33 PM, Yinghai Lu <yinghai@kernel.=
org> wrote:
>> >>>>>>>>> Impact: could probe igb
>> >>>>>>>>>
>> >>>>>>>>> Found one system with 82575EB, in the kernel that is kexec=
ed, probe igb
>> >>>>>>>>> failed with -2.
>> >>>>>>>>>
>> >>>>>>>>> it looks like the same behavior happened on forcedeth.
>> >>>>>>>>>
>> >>>>>>>>> try to check system_state to make sure if put it on D3
>> >>>>>>>>>
>> >>>>>>>>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>> >>>>>>>>>
>> >>>>>>>>> ---
>> >>>>>>>>> =C2=A0drivers/net/igb/igb_main.c | =C2=A0 19 +++++++++++++=
+-----
>> >>>>>>>>> =C2=A01 file changed, 14 insertions(+), 5 deletions(-)
>> >>>>>>>> I see the point of the patch, but I know for a fact that ix=
gbe when
>> >>>>>>>> enabled for MSI-X also doesn't work with kexec.
>> >>>>>>>>
>> >>>>>>>> so my questions are:
>> >>>>>>>> are you going to change every driver?
>> >>>>>>> i tend to only change driver that i have related HW.
>> >>>>>>>
>> >>>>>>>> why can't this be fixed in core kernel code instead?
>> >>>>>>> will check it.
>> >>>>>>>
>> >>>>>>>> Shouldn't pci_enable_device take it out of D3?
>> >>>>>>>> Or maybe it should be taken out of D3 immediately if someon=
e tries to
>> >>>>>>>> ioremap any of the BARx registers?
>> >>>>>>> looks like second kernel can not detect the state any more.
>> >>>>>> In fact pci_enable_device() calls pci_set_power_state(dev, PC=
I_D0) as the first
>> >>>>>> thing. =C2=A0The question is why it doesn't work as expected.
>> >>>>> not sure... please check the version for forcedeth that you ma=
de.
>> >>>>>
>> >>>>> commit 3cb5599a84c557c0dd9a19feb63a3788268cf249
>> >>>>> Author: Rafael J. Wysocki <rjw@sisk.pl>
>> >>>>> Date: =C2=A0 Fri Sep 5 14:00:19 2008 -0700
>> >>>>>
>> >>>>> =C2=A0 =C2=A0 forcedeth: fix kexec regression
>> >>>>>
>> >>>>> =C2=A0 =C2=A0 Fix regression tracked as http://bugzilla.kernel=
=2Eorg/show_bug.cgi?id=3D11361
>> >>>>> =C2=A0 =C2=A0 and caused by commit f735a2a1a4f2a0f5cd823ce323e=
82675990469e2 ("[netdrvr]
>> >>>>> =C2=A0 =C2=A0 forcedeth: setup wake-on-lan before shutting dow=
n") that makes network
>> >>>>> =C2=A0 =C2=A0 adapters integrated into the NVidia MCP55 chipse=
ts fail to work in kexeced
>> >>>>> =C2=A0 =C2=A0 kernels. =C2=A0The problem appears to be that if=
 the adapter is put into D3_hot
>> >>>>> =C2=A0 =C2=A0 during ->shutdown(), it cannot be brought back i=
nto D0 after kexec (ref.
>> >>>>> =C2=A0 =C2=A0 http://marc.info/?l=3Dlinux-kernel&m=3D121900062=
814967&w=3D4). =C2=A0Therefore, only
>> >>>>> =C2=A0 =C2=A0 put forcedeth into D3 during ->shutdown() if the=
 system is to be powered
>> >>>>> =C2=A0 =C2=A0 off.
>> >>>> Thanks, I remember now.
>> >>> In which case you need to rework igb_shutdown() rather than igb_=
suspend().
>> >>>
>> >>> Something like the patch below, perhaps (totally untested).
>> >> it works, David, can you picked it up
>> >
>> > Still, Yinghai, can you please also test the patch below? =C2=A0It=
 fixes all
>> > shortcomings in the driver's suspend and shutdown methods I was ta=
lking about
>> > in one of the previous messages. =C2=A0If it works, IMO it will be=
 a preferable fix
>> > (in particular, it would be good to check if WoL still works with =
it,
>> > but I don't have the hardware).
>> >
>> > Thanks,
>> > Rafael
>> >
>> > ---
>> > From: Rafael J. Wysocki <rjw@sisk.pl>
>> > Subject: net/igb: Fix kexec with igb (rev. 3)
>> > Impact: Fix
>> >
>> > Yinghai Lu found one system with 82575EB where, in the kernel that=
 is
>> > kexeced, probe igb failed with -2, the reason being that the adapt=
er
>> > could not be brought back from D3 by the kexec kernel, most probab=
ly
>> > due to quirky hardware (it looks like the same behavior happened o=
n
>> > forcedeth).
>> >
>> > Prevent igb from putting the adapter into D3 during shutdown excep=
t
>> > when we going to power off the system. =C2=A0For this purpose, sep=
erate
>> > igb_shutdown() from igb_suspend() and use the appropriate PCI PM
>> > callbacks in both of them.
>> >
>> > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
>> > Reported-by: Yinghai Lu <yinghai@kernel.org>
>> > ---
>> > =C2=A0drivers/net/igb/igb_main.c | =C2=A0 42 +++++++++++++++++++++=
+++++++++------------
>> > =C2=A01 file changed, 30 insertions(+), 12 deletions(-)
>> >
>> > Index: linux-2.6/drivers/net/igb/igb_main.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- linux-2.6.orig/drivers/net/igb/igb_main.c
>> > +++ linux-2.6/drivers/net/igb/igb_main.c
>> > @@ -4277,7 +4277,7 @@ int igb_set_spd_dplx(struct igb_adapter
>> > =C2=A0}
>> >
>> >
>> > -static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
>> > +static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake=
)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 struct net_device *netdev =3D pci_get_drvdata(pdev);
>> > =C2=A0 =C2=A0 struct igb_adapter *adapter =3D netdev_priv(netdev);
>> > @@ -4336,15 +4336,9 @@ static int igb_suspend(struct pci_dev *p
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wr32(E1000_WUFC, 0);
>> > =C2=A0 =C2=A0 }
>> >
>> > - =C2=A0 /* make sure adapter isn't asleep if manageability/wol is=
 enabled */
>> > - =C2=A0 if (wufc || adapter->en_mng_pt) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_enable_wake(pdev, PCI_D3h=
ot, 1);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_enable_wake(pdev, PCI_D3c=
old, 1);
>> > - =C2=A0 } else {
>> > + =C2=A0 *enable_wake =3D wufc || adapter->en_mng_pt;
>> > + =C2=A0 if (!*enable_wake)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 igb_shutdown_fiber_serde=
s_link_82575(hw);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_enable_wake(pdev, PCI_D3h=
ot, 0);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_enable_wake(pdev, PCI_D3c=
old, 0);
>> > - =C2=A0 }
>> >
>> > =C2=A0 =C2=A0 /* Release control of h/w to f/w. =C2=A0If f/w is AM=
T enabled, this
>> > =C2=A0 =C2=A0 =C2=A0* would have already happened in close and is =
redundant. */
>> > @@ -4352,12 +4346,29 @@ static int igb_suspend(struct pci_dev *p
>> >
>> > =C2=A0 =C2=A0 pci_disable_device(pdev);
>> >
>> > - =C2=A0 pci_set_power_state(pdev, pci_choose_state(pdev, state));
>> > -
>> > =C2=A0 =C2=A0 return 0;
>> > =C2=A0}
>> >
>> > =C2=A0#ifdef CONFIG_PM
>> > +static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
>> > +{
>> > + =C2=A0 int retval;
>> > + =C2=A0 bool wake;
>> > +
>> > + =C2=A0 retval =3D __igb_shutdown(pdev, &wake);
>> > + =C2=A0 if (retval)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return retval;
>> > +
>> > + =C2=A0 if (wake) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_prepare_to_sleep(pdev);
>> > + =C2=A0 } else {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_wake_from_d3(pdev, false)=
;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_set_power_state(pdev, PCI=
_D3hot);
>> > + =C2=A0 }
>> > +
>> > + =C2=A0 return 0;
>> > +}
>> > +
>> > =C2=A0static int igb_resume(struct pci_dev *pdev)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 struct net_device *netdev =3D pci_get_drvdata(pdev);
>> > @@ -4412,7 +4423,14 @@ static int igb_resume(struct pci_dev *pd
>> >
>> > =C2=A0static void igb_shutdown(struct pci_dev *pdev)
>> > =C2=A0{
>> > - =C2=A0 igb_suspend(pdev, PMSG_SUSPEND);
>> > + =C2=A0 bool wake;
>> > +
>> > + =C2=A0 __igb_shutdown(pdev, &wake);
>> > +
>> > + =C2=A0 if (system_state =3D=3D SYSTEM_POWER_OFF) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_wake_from_d3(pdev, wake);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_set_power_state(pdev, PCI=
_D3hot);
>> > + =C2=A0 }
>> > =C2=A0}
>> >
>> > =C2=A0#ifdef CONFIG_NET_POLL_CONTROLLER
>>
>> it works too.
>
> Great, thanks for testing.
>
> Jeff, Jesse, is the patch fine with you?
>
> Rafael

Let me talk with Jesse on Monday about it.  I know that Jesse's
concern's were that there were more than one driver afflicted with the
same or similar issue and that it made more sense to fix this in the
core for all drivers.  For instance ixgbe, IIRC, but because Yinghai
did not have any other hardware, it was unclear if this was an issue
on other drivers.

After discussing this with Jesse, one of us will respond.  I will
apply this patch to my tree anyway and if we are alright with the
patch, I will push it out with my other patches to Dave.

--=20
Cheers,
Jeff

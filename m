From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH] igb: fix kexec with igb
Date: Sun, 8 Mar 2009 15:35:31 -0700
Message-ID: <86802c440903081535n7cca1b79t85d4b1bfd677483b@mail.gmail.com>
References: <49B1F934.5050006@kernel.org> <49B40A03.7060703@kernel.org>
	 <200903082208.42957.rjw@sisk.pl> <200903082232.36660.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:12569 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224AbZCHWfd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2009 18:35:33 -0400
In-Reply-To: <200903082232.36660.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 8, 2009 at 2:32 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Sunday 08 March 2009, Rafael J. Wysocki wrote:
>> On Sunday 08 March 2009, Yinghai Lu wrote:
>> > Rafael J. Wysocki wrote:
>> > > On Saturday 07 March 2009, Yinghai Lu wrote:
>> > >> On Fri, Mar 6, 2009 at 11:18 PM, Jesse Brandeburg
>> > >> <jesse.brandeburg@gmail.com> wrote:
>> > >>> On Fri, Mar 6, 2009 at 8:33 PM, Yinghai Lu <yinghai@kernel.org=
> wrote:
>> > >>>> Impact: could probe igb
>> > >>>>
>> > >>>> Found one system with 82575EB, in the kernel that is kexeced,=
 probe igb
>> > >>>> failed with -2.
>> > >>>>
>> > >>>> it looks like the same behavior happened on forcedeth.
>> > >>>>
>> > >>>> try to check system_state to make sure if put it on D3
>> > >>>>
>> > >>>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>> > >>>>
>> > >>>> ---
>> > >>>> =A0drivers/net/igb/igb_main.c | =A0 19 ++++++++++++++-----
>> > >>>> =A01 file changed, 14 insertions(+), 5 deletions(-)
>> > >>> I see the point of the patch, but I know for a fact that ixgbe=
 when
>> > >>> enabled for MSI-X also doesn't work with kexec.
>> > >>>
>> > >>> so my questions are:
>> > >>> are you going to change every driver?
>> > >> i tend to only change driver that i have related HW.
>> > >>
>> > >>> why can't this be fixed in core kernel code instead?
>> > >> will check it.
>> > >>
>> > >>> Shouldn't pci_enable_device take it out of D3?
>> > >>> Or maybe it should be taken out of D3 immediately if someone t=
ries to
>> > >>> ioremap any of the BARx registers?
>> > >>
>> > >> looks like second kernel can not detect the state any more.
>> > >
>> > > In fact pci_enable_device() calls pci_set_power_state(dev, PCI_D=
0) as the first
>> > > thing. =A0The question is why it doesn't work as expected.
>> >
>> > not sure... please check the version for forcedeth that you made.
>> >
>> > commit 3cb5599a84c557c0dd9a19feb63a3788268cf249
>> > Author: Rafael J. Wysocki <rjw@sisk.pl>
>> > Date: =A0 Fri Sep 5 14:00:19 2008 -0700
>> >
>> > =A0 =A0 forcedeth: fix kexec regression
>> >
>> > =A0 =A0 Fix regression tracked as http://bugzilla.kernel.org/show_=
bug.cgi?id=3D11361
>> > =A0 =A0 and caused by commit f735a2a1a4f2a0f5cd823ce323e8267599046=
9e2 ("[netdrvr]
>> > =A0 =A0 forcedeth: setup wake-on-lan before shutting down") that m=
akes network
>> > =A0 =A0 adapters integrated into the NVidia MCP55 chipsets fail to=
 work in kexeced
>> > =A0 =A0 kernels. =A0The problem appears to be that if the adapter =
is put into D3_hot
>> > =A0 =A0 during ->shutdown(), it cannot be brought back into D0 aft=
er kexec (ref.
>> > =A0 =A0 http://marc.info/?l=3Dlinux-kernel&m=3D121900062814967&w=3D=
4). =A0Therefore, only
>> > =A0 =A0 put forcedeth into D3 during ->shutdown() if the system is=
 to be powered
>> > =A0 =A0 off.
>>
>> Thanks, I remember now.
>
> In which case you need to rework igb_shutdown() rather than igb_suspe=
nd().
>
> Something like the patch below, perhaps (totally untested).
>
> Thanks,
> Rafael
>
> ---
> =A0drivers/net/igb/igb_main.c | =A0 24 +++++++++++++++++++-----
> =A01 file changed, 19 insertions(+), 5 deletions(-)
>
> Index: linux-2.6/drivers/net/igb/igb_main.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/drivers/net/igb/igb_main.c
> +++ linux-2.6/drivers/net/igb/igb_main.c
> @@ -4299,7 +4299,7 @@ int igb_set_spd_dplx(struct igb_adapter
> =A0}
>
>
> -static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
> +static int __igb_shutdown(struct pci_dev *pdev, bool enable_wake)
> =A0{
> =A0 =A0 =A0 =A0struct net_device *netdev =3D pci_get_drvdata(pdev);
> =A0 =A0 =A0 =A0struct igb_adapter *adapter =3D netdev_priv(netdev);
> @@ -4359,7 +4359,7 @@ static int igb_suspend(struct pci_dev *p
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* make sure adapter isn't asleep if manageability/wol=
 is enabled */
> - =A0 =A0 =A0 if (wufc || adapter->en_mng_pt) {
> + =A0 =A0 =A0 if ((wufc || adapter->en_mng_pt) && enable_wake) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pci_enable_wake(pdev, PCI_D3hot, 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pci_enable_wake(pdev, PCI_D3cold, 1);
> =A0 =A0 =A0 =A0} else {
> @@ -4374,12 +4374,21 @@ static int igb_suspend(struct pci_dev *p
>
> =A0 =A0 =A0 =A0pci_disable_device(pdev);
>
> - =A0 =A0 =A0 pci_set_power_state(pdev, pci_choose_state(pdev, state)=
);
> -
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> =A0#ifdef CONFIG_PM
> +static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
> +{
> + =A0 =A0 =A0 int retval;
> +
> + =A0 =A0 =A0 retval =3D __igb_shutdown(pdev, true);
> + =A0 =A0 =A0 if (!retval)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_set_power_state(pdev, PCI_D3hot);
> +
> + =A0 =A0 =A0 return retval;
> +}
> +
> =A0static int igb_resume(struct pci_dev *pdev)
> =A0{
> =A0 =A0 =A0 =A0struct net_device *netdev =3D pci_get_drvdata(pdev);
> @@ -4434,7 +4443,12 @@ static int igb_resume(struct pci_dev *pd
>
> =A0static void igb_shutdown(struct pci_dev *pdev)
> =A0{
> - =A0 =A0 =A0 igb_suspend(pdev, PMSG_SUSPEND);
> + =A0 =A0 =A0 if (system_state =3D=3D SYSTEM_POWER_OFF) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __igb_shutdown(pdev, true);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_set_power_state(pdev, PCI_D3hot);

you don't need to use pci_choose_state(pdev, state), but use PCI-D3hot =
directly?

YH

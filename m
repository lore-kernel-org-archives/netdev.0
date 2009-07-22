From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] igb/e1000e/e1000/e100: make wol usable
Date: Tue, 21 Jul 2009 20:25:31 -0700
Message-ID: <5f2db9d90907212025k31c3a941v5fd1be9ed171e4c1@mail.gmail.com>
References: <20090721210115.GL8515@gospo.rdu.redhat.com>
	 <273D38FBE7C6FE46A1689FCD014A0B8B55D57764@azsmsx505.amr.corp.intel.com>
	 <20090722022745.GM8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"stable@kernel.org" <stable@kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:29583 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756499AbZGVDZc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 23:25:32 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1481395qwh.37
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 20:25:32 -0700 (PDT)
In-Reply-To: <20090722022745.GM8515@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My understanding was that the can_wakeup was supposed to be
initialized by pci_pm_init or platform_pci_wakeup_init based on the
pci-e capabilities.  Is this not the case?  It seems like this is
where you should be looking to determine why the the can_wakeup isn't
being initialized correctly.

The patch below won't solve the problem either.  The problem is that
the can_wakeup value is being disabled when the EEPROM doesn't support
WOL.

If you have to do this in the drivers, then my suggestion is to take a
look at how ixgbe is doing it.  You essentially need to initialize
can_wakeup to true, and then set the should_wakeup attribute based on
the EEPROM setting or via ethtool.  This way you can still toggle the
should_wakeup option without being blocked by the EEPROM disabling it.

Thanks,

Alex

On Tue, Jul 21, 2009 at 7:27 PM, Andy Gospodarek<andy@greyhouse.net> wr=
ote:
> On Tue, Jul 21, 2009 at 02:59:31PM -0700, Ronciak, John wrote:
>> >-----Original Message-----
>> >From: Andy Gospodarek [mailto:andy@greyhouse.net]
>> >Sent: Tuesday, July 21, 2009 2:01 PM
>> >To: netdev@vger.kernel.org
>> >Cc: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W;
>> >Waskiewicz Jr, Peter P; Ronciak, John; stable@kernel.org
>> >Subject: [PATCH] igb/e1000e/e1000/e100: make wol usable
>> >
>> >
>> >It seems that the patches that intended to use the new calls to che=
ck
>> >status and capabilities for WOL and fix it up:
>> >
>> > =A0 =A0commit bc79fc8409b3dccbde072e8113cc1fb3fd876fc5
>> > =A0 =A0Author: Rafael J. Wysocki <rjw@sisk.pl>
>> > =A0 =A0Date: =A0 Wed Oct 29 14:22:18 2008 -0700
>> >
>> > =A0 =A0 =A0 =A0e100: adapt to the reworked PCI PM
>> >
>> > =A0 =A0commit e1b86d8479f90aadee57a3d07d8e61c815c202d9
>> > =A0 =A0Author: Rafael J. Wysocki <rjw@sisk.pl>
>> > =A0 =A0Date: =A0 Fri Nov 7 20:30:37 2008 +0000
>> >
>> > =A0 =A0 =A0 =A0igb: Use device_set_wakeup_enable
>> >
>> > =A0 =A0commit de1264896c8012a261c1cba17e6a61199c276ad3
>> > =A0 =A0Author: Rafael J. Wysocki <rjw@sisk.pl>
>> > =A0 =A0Date: =A0 Fri Nov 7 20:30:19 2008 +0000
>> >
>> > =A0 =A0 =A0 =A0e1000: Use device_set_wakeup_enable
>> >
>> > =A0 =A0commit 6ff68026f4757d68461b7fbeca5c944e1f5f8b44
>> > =A0 =A0Author: Rafael J. Wysocki <rjw@sisk.pl>
>> > =A0 =A0Date: =A0 Wed Nov 12 09:52:32 2008 +0000
>> >
>> > =A0 =A0 =A0 =A0e1000e: Use device_set_wakeup_enable
>> >
>> >Unfortunately they left out some important bits. =A0This should mak=
e sure
>> >the e100, igb, e1000e, and e1000-based devices can actually enable =
WOL
>> >rather than their current state which is reported as not supported.
>> >
>> >This looks like it has been broken since 2.6.28.
>> >
>> >Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>> >---
>> >
>> > e100.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
>> > e1000/e1000_main.c | =A0 =A01 +
>> > e1000e/netdev.c =A0 =A0| =A0 =A01 +
>> > igb/igb_main.c =A0 =A0 | =A0 =A01 +
>> > 4 files changed, 4 insertions(+)
>> >
>> >diff --git a/drivers/net/e100.c b/drivers/net/e100.c
>> >index 569df19..8824952 100644
>> >--- a/drivers/net/e100.c
>> >+++ b/drivers/net/e100.c
>> >@@ -2816,6 +2816,7 @@ static int __devinit e100_probe(struct
>> >pci_dev *pdev,
>> > =A0 =A0 if ((nic->mac >=3D mac_82558_D101_A4) &&
>> > =A0 =A0 =A0 =A0(nic->eeprom[eeprom_id] & eeprom_id_wol)) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 nic->flags |=3D wol_magic;
>> >+ =A0 =A0 =A0 =A0 =A0 =A0device_init_wakeup(&pdev->dev, true);
>> > =A0 =A0 =A0 =A0 =A0 =A0 device_set_wakeup_enable(&pdev->dev, true)=
;
>> > =A0 =A0 }
>> >
>> >diff --git a/drivers/net/e1000/e1000_main.c
>> >b/drivers/net/e1000/e1000_main.c
>> >index d7df00c..229d874 100644
>> >--- a/drivers/net/e1000/e1000_main.c
>> >+++ b/drivers/net/e1000/e1000_main.c
>> >@@ -1208,6 +1208,7 @@ static int __devinit e1000_probe(struct
>> >pci_dev *pdev,
>> >
>> > =A0 =A0 /* initialize the wol settings based on the eeprom setting=
s */
>> > =A0 =A0 adapter->wol =3D adapter->eeprom_wol;
>> >+ =A0 =A0device_init_wakeup(&adapter->pdev->dev, adapter->wol);
>> > =A0 =A0 device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol=
);
>> >
>> > =A0 =A0 /* print bus type/speed/width info */
>> >diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netde=
v.c
>> >index 63415bb..5c2edaa 100644
>> >--- a/drivers/net/e1000e/netdev.c
>> >+++ b/drivers/net/e1000e/netdev.c
>> >@@ -5196,6 +5196,7 @@ static int __devinit e1000_probe(struct
>> >pci_dev *pdev,
>> >
>> > =A0 =A0 /* initialize the wol settings based on the eeprom setting=
s */
>> > =A0 =A0 adapter->wol =3D adapter->eeprom_wol;
>> >+ =A0 =A0device_init_wakeup(&adapter->pdev->dev, adapter->wol);
>> > =A0 =A0 device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol=
);
>> >
>> > =A0 =A0 /* save off EEPROM version number */
>> >diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.=
c
>> >index adb09d3..8512a40 100644
>> >--- a/drivers/net/igb/igb_main.c
>> >+++ b/drivers/net/igb/igb_main.c
>> >@@ -1475,6 +1475,7 @@ static int __devinit igb_probe(struct
>> >pci_dev *pdev,
>> >
>> > =A0 =A0 /* initialize the wol settings based on the eeprom setting=
s */
>> > =A0 =A0 adapter->wol =3D adapter->eeprom_wol;
>> >+ =A0 =A0device_init_wakeup(&adapter->pdev->dev, adapter->wol);
>> > =A0 =A0 device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol=
);
>> >
>> > =A0 =A0 /* reset the hardware with the new settings */
>> Andy,
>>
>> WoL not supported is reported back when WoL is disabled in the EEPRO=
M. =A0So if this is happening to you, that system (or at least =A0that =
interface) has WoL disabled. =A0How are you testing this?
>>
>> Cheers,
>> John
>
> John,
>
> I'm not doing anything differently than what the eeprom is reporting =
as
> support with these patches. In every one of the drivers above, the
> enabling of ethtool first calls device_can_wakeup. =A0That inline fun=
ction
> is pretty simple and all it does is return the value of
> dev->power.can_wakeup. =A0If never set, dev->power.can_wakeup is fals=
e and
> wol status can never be set.
>
> The proper way to set it would be to call dev_init_wakeup first (or
> simply call it). =A0Take a look at the code and you will see what I'm
> talking about.
>
> Now that I'm looking at it again, this patch would probably be better
> anyway:
>
> Replace device_set_wakeup_enable calls with device_init_wakeup, so th=
at
> calls to device_can_wakeup in each drivers' code will not fail each
> time. =A0The intent of the calls to device_can_wakeup were added to e=
nsure
> the device was enabled for WOL, but without the proper call to
> device_init_wakeup, any call to device_can_wakeup will always return
> false.
>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>
> =A0e100.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0e1000/e1000_main.c | =A0 =A02 +-
> =A0e1000e/netdev.c =A0 =A0| =A0 =A02 +-
> =A0igb/igb_main.c =A0 =A0 | =A0 =A02 +-
> =A04 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index 569df19..1d82d25 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -2816,7 +2816,7 @@ static int __devinit e100_probe(struct pci_dev =
*pdev,
> =A0 =A0 =A0 =A0if ((nic->mac >=3D mac_82558_D101_A4) &&
> =A0 =A0 =A0 =A0 =A0 (nic->eeprom[eeprom_id] & eeprom_id_wol)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nic->flags |=3D wol_magic;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 device_set_wakeup_enable(&pdev->dev, tr=
ue);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 device_init_wakeup(&pdev->dev, true);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* ack any pending wake events, disable PME */
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000=
_main.c
> index d7df00c..5f22a85 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -1208,7 +1208,7 @@ static int __devinit e1000_probe(struct pci_dev=
 *pdev,
>
> =A0 =A0 =A0 =A0/* initialize the wol settings based on the eeprom set=
tings */
> =A0 =A0 =A0 =A0adapter->wol =3D adapter->eeprom_wol;
> - =A0 =A0 =A0 device_set_wakeup_enable(&adapter->pdev->dev, adapter->=
wol);
> + =A0 =A0 =A0 device_init_wakeup(&adapter->pdev->dev, adapter->wol);
>
> =A0 =A0 =A0 =A0/* print bus type/speed/width info */
> =A0 =A0 =A0 =A0DPRINTK(PROBE, INFO, "(PCI%s:%s:%s) ",
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.=
c
> index 63415bb..62de3ad 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -5196,7 +5196,7 @@ static int __devinit e1000_probe(struct pci_dev=
 *pdev,
>
> =A0 =A0 =A0 =A0/* initialize the wol settings based on the eeprom set=
tings */
> =A0 =A0 =A0 =A0adapter->wol =3D adapter->eeprom_wol;
> - =A0 =A0 =A0 device_set_wakeup_enable(&adapter->pdev->dev, adapter->=
wol);
> + =A0 =A0 =A0 device_init_wakeup(&adapter->pdev->dev, adapter->wol);
>
> =A0 =A0 =A0 =A0/* save off EEPROM version number */
> =A0 =A0 =A0 =A0e1000_read_nvm(&adapter->hw, 5, 1, &adapter->eeprom_ve=
rs);
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index adb09d3..f761e67 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -1475,7 +1475,7 @@ static int __devinit igb_probe(struct pci_dev *=
pdev,
>
> =A0 =A0 =A0 =A0/* initialize the wol settings based on the eeprom set=
tings */
> =A0 =A0 =A0 =A0adapter->wol =3D adapter->eeprom_wol;
> - =A0 =A0 =A0 device_set_wakeup_enable(&adapter->pdev->dev, adapter->=
wol);
> + =A0 =A0 =A0 device_init_wakeup(&adapter->pdev->dev, adapter->wol);
>
> =A0 =A0 =A0 =A0/* reset the hardware with the new settings */
> =A0 =A0 =A0 =A0igb_reset(adapter);
>
>
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

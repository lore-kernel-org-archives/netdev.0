From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH] sky2: override for PCI legacy power management
Date: Wed, 21 Mar 2012 14:22:01 -0600
Message-ID: <CAErSpo67PEaZ6JuMUntWLfR8SUpQgZERD_cKV6rWd=FF0tZ6DQ@mail.gmail.com>
References: <4F69BE2E.7070903@t-online.de> <20120321083205.360a7a3b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Knut Petersen <Knut_Petersen@t-online.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>, arekm@maven.pl,
	Jared <nitro@legroom.net>, dilieto@lineone.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:54379 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760115Ab2CUUWW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2012 16:22:22 -0400
Received: by lahj13 with SMTP id j13so1167615lah.19
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 13:22:21 -0700 (PDT)
In-Reply-To: <20120321083205.360a7a3b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 21, 2012 at 9:32 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> Some BIOS's don't setup power management correctly (what else is
> new) and don't allow use of PCI Express power control. Add a special
> exception module parameter to allow working around this issue.
> Based on slightly different patch by Knut Petersen.
>
> Reported-by: Arkadiusz Miskiewicz <arekm@maven.pl>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Is there a problem report URL you can include here?

It looks like this requires a user to figure out that he might be
suffering from this problem, then use this module parameter to work
around it.  How would a user figure that out?  Can we do it
automatically to save him the trouble?

> ---
> Patch against -net (ie. 3.3.0)
>
> --- a/drivers/net/ethernet/marvell/sky2.c =A0 =A0 =A0 2012-01-10 10:5=
6:56.855156017 -0800
> +++ b/drivers/net/ethernet/marvell/sky2.c =A0 =A0 =A0 2012-03-21 08:2=
5:52.400929532 -0700
> @@ -95,6 +95,10 @@ static int disable_msi =3D 0;
> =A0module_param(disable_msi, int, 0);
> =A0MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt =
(MSI)");
>
> +static int legacy_pme =3D 0;
> +module_param(legacy_pme, int, 0);
> +MODULE_PARM_DESC(legacy_pme, "Legacy power management");
> +
> =A0static DEFINE_PCI_DEVICE_TABLE(sky2_id_table) =3D {
> =A0 =A0 =A0 =A0{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* S=
K-9Sxx */
> =A0 =A0 =A0 =A0{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* S=
K-9Exx */
> @@ -867,6 +871,13 @@ static void sky2_wol_init(struct sky2_po
> =A0 =A0 =A0 =A0/* Disable PiG firmware */
> =A0 =A0 =A0 =A0sky2_write16(hw, B0_CTST, Y2_HW_WOL_OFF);
>
> + =A0 =A0 =A0 /* Needed by some broken BIOSes, use PCI rather than PC=
I-e for WOL */
> + =A0 =A0 =A0 if (legacy_pme) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 reg1 =3D sky2_pci_read32(hw, PCI_DE=
V_REG1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg1 |=3D PCI_Y2_PME_LEGACY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sky2_pci_write32(hw, PCI_DEV_REG1, reg1=
);
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/* block receiver */
> =A0 =A0 =A0 =A0sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_S=
ET);
> =A0 =A0 =A0 =A0sky2_read32(hw, B0_CTST);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/

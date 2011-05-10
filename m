From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v2 1/5] ssb: Change fallback sprom to callback mechanism.
Date: Wed, 11 May 2011 01:12:30 +0200
Message-ID: <BANLkTinZkCPQh84wy66nDmHpgwCO3Pvu3w@mail.gmail.com>
References: <1305063094-26656-1-git-send-email-hauke@hauke-m.de>
	<1305063094-26656-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:55734 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab1EJXMc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 19:12:32 -0400
In-Reply-To: <1305063094-26656-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/10 Hauke Mehrtens <hauke@hauke-m.de>:
> Some embedded devices like the Netgear WNDR3300 have two SSB based
> cards without an own sprom on the pci bus. We have to provide two
> different fallback sproms for these and this was not possible with th=
e
> old solution. In the bcm47xx architecture the sprom data is stored in
> the nvram in the main flash storage. The architecture code will be ab=
le
> to fill the sprom with the stored data based on the bus where the
> device was found.
>
> The bcm63xx code should do the same thing as before, just using the n=
ew
> API.
>
> Acked-by: Michael Buesch <mb@bu3sch.de>
> CC: netdev@vger.kernel.org
> CC: linux-wireless@vger.kernel.org
> CC: Florian Fainelli <florian@openwrt.org>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>
> v2: * fix some checkpatch errors and warnings
> =C2=A0 =C2=A0* spelling issues
>
> =C2=A0arch/mips/bcm63xx/boards/board_bcm963xx.c | =C2=A0 16 +++++++++=
-
> =C2=A0drivers/ssb/pci.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 16 +++++++---
> =C2=A0drivers/ssb/sprom.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 43 +++++++++++++++++----------=
--
> =C2=A0drivers/ssb/ssb_private.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A03 +-
> =C2=A0include/linux/ssb/ssb.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A04 ++-
> =C2=A05 files changed, 55 insertions(+), 27 deletions(-)
>
> diff --git a/arch/mips/bcm63xx/boards/board_bcm963xx.c b/arch/mips/bc=
m63xx/boards/board_bcm963xx.c
> index 8dba8cf..40b223b 100644
> --- a/arch/mips/bcm63xx/boards/board_bcm963xx.c
> +++ b/arch/mips/bcm63xx/boards/board_bcm963xx.c
> @@ -643,6 +643,17 @@ static struct ssb_sprom bcm63xx_sprom =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.boardflags_lo =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0=3D 0x2848,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.boardflags_hi =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0=3D 0x0000,
> =C2=A0};
> +
> +int bcm63xx_get_fallback_sprom(struct ssb_bus *bus, struct ssb_sprom=
 *out)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (bus->bustype =3D=3D SSB_BUSTYPE_PCI) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(out, &bcm63=
xx_sprom, sizeof(struct ssb_sprom));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_ERR PF=
X "unable to fill SPROM for given bustype.\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
> =C2=A0#endif
>
> =C2=A0/*
> @@ -793,8 +804,9 @@ void __init board_prom_init(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!board_get_mac_address(bcm63xx_sprom.i=
l0mac)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memcpy(bcm63xx=
_sprom.et0mac, bcm63xx_sprom.il0mac, ETH_ALEN);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memcpy(bcm63xx=
_sprom.et1mac, bcm63xx_sprom.il0mac, ETH_ALEN);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ssb_arch_set_f=
allback_sprom(&bcm63xx_sprom) < 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 printk(KERN_ERR "failed to register fallback SPROM\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ssb_arch_regis=
ter_fallback_sprom(
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &bcm63xx_get_fallback_sprom) < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 printk(KERN_ERR PFX "failed to register fallback SPROM\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0#endif
> =C2=A0}
> diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
> index 6f34963..7ad4858 100644
> --- a/drivers/ssb/pci.c
> +++ b/drivers/ssb/pci.c
> @@ -662,7 +662,6 @@ static int sprom_extract(struct ssb_bus *bus, str=
uct ssb_sprom *out,
> =C2=A0static int ssb_pci_sprom_get(struct ssb_bus *bus,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ssb_sprom *sprom)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 const struct ssb_sprom *fallback;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 *buf;
>
> @@ -707,10 +706,17 @@ static int ssb_pci_sprom_get(struct ssb_bus *bu=
s,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* All CRC attempts failed.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 * Maybe there is no SPROM on the device?
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* If we have a fallback, use that. */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 fallback =3D ssb_get_fallback_sprom();
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (fallback) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(sprom, fallback, sizeof(*spr=
om));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* Now we ask the arch code if there is some sprom
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* available for this device in some other storage */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 err =3D ssb_fill_sprom_with_fallback(bus, sprom);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (err) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ssb_printk(KERN_WARNING PFX "WARNIN=
G: Using"
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0" fallback SPROM failed (err %d)\n",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0err);

I was recently told we should not duplicate message levels info with
own prefixes ("WARNING: ").

--=20
Rafa=C5=82

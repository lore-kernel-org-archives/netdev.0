From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 9/9] phy: fixed_phy: Set phy capabilities even
 when link is down
Date: Sun, 23 Aug 2015 11:40:07 -0700
Message-ID: <55DA1387.9020009@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-10-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:34376 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbbHWSkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 14:40:09 -0400
Received: by oiey141 with SMTP id y141so68200525oie.1
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 11:40:09 -0700 (PDT)
In-Reply-To: <1440323220-20438-10-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/23/15 02:47, Andrew Lunn a =C3=A9crit :
> What features a phy supports is masked in genphy_config_init() by
> looking at the PHYs BMSR register.
>=20
> If the link is down, fixed_phy_update_regs() will only set the auto-
> negotiation capable bit in BMSR. Thus genphy_config_init() comes to
> the conclusion the PHY can only perform 10/Half, and masks out the
> higher speed features. If however the link it up, BMSR is set to
> indicate the speed the PHY is capable of auto-negotiating, and
> genphy_config_init() does not mask out the high speed features.
>=20
> To fix this, when the link is down, have fixed_phy_update_regs() leav=
e
> the link status and auto-negotiation complete bit unset, but set all
> the other bits depending on the fixed phy speed.

This kinds of revert what Staas did in commit
868a4215be9a6d80548ccb74763b883dc99d32a2 ("net: phy: fixed_phy: handle
link-down case"). When the link is down, it does not seem to me like we
can rely on the previous speed and duplex parameters to be considered v=
alid.

Your change does fix a valid use case though... humm.

>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/phy/fixed_phy.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.=
c
> index 14ab80899e77..ff4869222c27 100644
> --- a/drivers/net/phy/fixed_phy.c
> +++ b/drivers/net/phy/fixed_phy.c
> @@ -57,9 +57,8 @@ static int fixed_phy_update_regs(struct fixed_phy *=
fp)
>  	if (gpio_is_valid(fp->link_gpio))
>  		fp->status.link =3D !!gpio_get_value_cansleep(fp->link_gpio);
> =20
> -	if (!fp->status.link)
> -		goto done;
> -	bmsr |=3D BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
> +	if (fp->status.link)
> +		bmsr |=3D BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
> =20
>  	if (fp->status.duplex) {
>  		bmcr |=3D BMCR_FULLDPLX;
> @@ -111,7 +110,6 @@ static int fixed_phy_update_regs(struct fixed_phy=
 *fp)
>  	if (fp->status.asym_pause)
>  		lpa |=3D LPA_PAUSE_ASYM;
> =20
> -done:
>  	fp->regs[MII_PHYSID1] =3D 0;
>  	fp->regs[MII_PHYSID2] =3D 0;
> =20
>=20


--=20
=46lorian

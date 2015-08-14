From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Fri, 14 Aug 2015 10:01:49 -0700
Message-ID: <55CE1EFD.9090505@gmail.com>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: shh.xie@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33625 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209AbbHNRBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 13:01:53 -0400
Received: by obbhe7 with SMTP id he7so66195298obb.0
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 10:01:52 -0700 (PDT)
In-Reply-To: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/13/15 21:23, shh.xie@gmail.com a =C3=A9crit :
> From: Shaohui Xie <Shaohui.Xie@freescale.com>
>=20
> Currently, if phy state is PHY_RUNNING, we always register a CHANGE
> when phy works in polling or interrupt ignored, this will make the
> adjust_link being called even the phy link did Not changed.

Right, which is why most drivers do implement a caching scheme.

>=20
> checking the phy link to make sure the link did changed before we
> register a CHANGE, if link did not changed, we do nothing.

With your change we will end-up with virtually polling a PHY twice as
fast as we used to with the RUNNING -> CHANGELINK -> RUNNING transition
(current state transitions), which is probably fine, but puts a bit mor=
e
pressure on the (slow) MDIO bus since we end-up with two additional
reads to latch the link status register.

PS: I would appreciate if you could CC me on future libphy submissions.

>=20
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
>  drivers/net/phy/phy.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 84b1fba..d972851 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -814,6 +814,7 @@ void phy_state_machine(struct work_struct *work)
>  	bool needs_aneg =3D false, do_suspend =3D false;
>  	enum phy_state old_state;
>  	int err =3D 0;
> +	int old_link;
> =20
>  	mutex_lock(&phydev->lock);
> =20
> @@ -899,11 +900,18 @@ void phy_state_machine(struct work_struct *work=
)
>  		phydev->adjust_link(phydev->attached_dev);
>  		break;
>  	case PHY_RUNNING:
> -		/* Only register a CHANGE if we are
> -		 * polling or ignoring interrupts
> +		/* Only register a CHANGE if we are polling or ignoring
> +		 * interrupts and link changed since latest checking.
>  		 */
> -		if (!phy_interrupt_is_valid(phydev))
> -			phydev->state =3D PHY_CHANGELINK;
> +		if (!phy_interrupt_is_valid(phydev)) {
> +			old_link =3D phydev->link;
> +			err =3D phy_read_status(phydev);
> +			if (err)
> +				break;
> +
> +			if (old_link !=3D phydev->link)
> +				phydev->state =3D PHY_CHANGELINK;
> +		}
>  		break;
>  	case PHY_CHANGELINK:
>  		err =3D phy_read_status(phydev);
>=20


--=20
=46lorian

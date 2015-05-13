From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Make sure PHY_RESUMING state change is always
 processed
Date: Tue, 12 May 2015 19:44:44 -0700
Message-ID: <5552BA9C.8060707@gmail.com>
References: <1431482104-1030-1-git-send-email-tim.beale@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tim Beale <tim.beale@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:36675 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933969AbbEMCor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 22:44:47 -0400
Received: by obbkp3 with SMTP id kp3so19942205obb.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 19:44:46 -0700 (PDT)
In-Reply-To: <1431482104-1030-1-git-send-email-tim.beale@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/12/15 18:55, Tim Beale a =C3=A9crit :
> If phy_start_aneg() was called while the phydev is in the PHY_RESUMIN=
G
> state, then its state would immediately transition to PHY_AN (or
> PHY_FORCING). This meant the phy_state_machine() never processed the
> PHY_RESUMING state change, which meant interrupts weren't enabled for=
 the
> PHY. If the PHY used low-power mode (i.e. using BMCR_PDOWN), then the
> physical link wouldn't get powered up again.
>=20
> There seems no point for phy_start_aneg() to make the PHY_RESUMING --=
>
> PHY_AN transition, as the state machine will do this anyway. I'm not =
sure
> about the case where autoneg is disabled, as my patch will change
> behaviour so that the PHY goes to PHY_NOLINK instead of PHY_FORCING. =
An
> alternative solution would be to move the phy_config_interrupt() and
> phy_resume() work out of the state machine and into phy_start().
>=20
> The background behind this: we're running linux v3.16.7 and from user=
-space
> we want to enable the eth port (i.e. do a SIOCSIFFLAGS ioctl with the
> IFF_UP flag) and immediately afterward set the interface's speed/dupl=
ex.
> Enabling the interface calls .ndo_open() then phy_start() and the PHY
> transitions PHY_HALTED --> PHY_RESUMING. Setting the speed/duplex end=
s up
> calling phy_ethtool_sset(), which calls phy_start_aneg() (meanwhile t=
he
> phy_state_machine() hasn't processed the PHY_RESUMING state change ye=
t).

This looks correct at first glance but I would like to give it a try
first before acking this. Thanks!

>=20
> Signed-off-by: Tim Beale <tim.beale@alliedtelesis.co.nz>
> ---
>  drivers/net/phy/phy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 52cd8db..9855b96 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -465,7 +465,7 @@ int phy_start_aneg(struct phy_device *phydev)
>  	if (err < 0)
>  		goto out_unlock;
> =20
> -	if (phydev->state !=3D PHY_HALTED) {
> +	if (phydev->state !=3D PHY_HALTED && phydev->state !=3D PHY_RESUMIN=
G) {
>  		if (AUTONEG_ENABLE =3D=3D phydev->autoneg) {
>  			phydev->state =3D PHY_AN;
>  			phydev->link_timeout =3D PHY_AN_TIMEOUT;
>=20


--=20
=46lorian

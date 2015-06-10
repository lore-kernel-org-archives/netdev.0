From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC] net: phy: Introduced the PHY_AN_PENDING state
Date: Tue, 09 Jun 2015 22:17:59 -0700
Message-ID: <5577C887.2030604@gmail.com>
References: <20150610043635.GA6430@pendev.apac.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Keng Soon Cheah <keng.soon.cheah@ni.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150610043635.GA6430@pendev.apac.corp.natinst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 06/09/15 21:36, Keng Soon Cheah a =C3=A9crit :
> The PHY_AN_PENDING state is put as a gate to enter the PHY_AN state
> where it will wait for any uncomplete auto-negotiation session to
> finish before starting a new one.
>=20
> This extra state could be used to workaround some auto-negotation
> issues from certain vendors.

The typical way to work around these problems are to fix them at the PH=
Y
driver level, see below.

>=20
> an_pending_timeout module parameter is used to enable the AN_PENDING
> transition state. Set it to 0 to disable AN_PENDING state transition,
> set it to any non-zero value to specify the timeout period for
> PHY_AN_PENDING state in second. The default value is 0.
>=20
> an_pending_guard module parameter serves as a guard band to delay
> the auto-negotiation firing after the previous auto-negotiation
> finish.
>=20
> Signed-off-by: Keng Soon Cheah <keng.soon.cheah@ni.com>
>=20
> Conflicts:
>=20
> 	drivers/net/phy/phy.c
> ---
> We observed failure in the ethernet link operation when our board pai=
rs
> with some network switch model. The problem happens when an
> auto-negotiation is started around the time the previous auto-negotia=
tion
> complete. We believe this might be an interoperatibility issue betwee=
n
> the PHYs but we need a short-term solution in software to workaround =
the
> issue.
>=20
> We found that we are able to avoid from hitting the problem by waitin=
g any
> pending auto-negotiation to complete before starting a new one and th=
is
> patch is designed to serve the purpose.

That sounds like a bug in the PHY state machine and/or the PHY driver i=
f
you are allowed to restart auto-negotiation while one is pending. Now
that the PHY state machine has debug prints built-in, could you capture
a trace of this failing case?

Is this observed with the generic PHY driver or a custom PHY driver?

>=20
> A PHY_AN_PENDING state is introduced and it will act as a gate to ent=
er
> the PHY_AN state. This state will check for auto-negotiation completi=
on
> or timeout after an_pending_timeout period, then it will wait for
> an_pending_guard before triggering another auto-negotiation.
>=20
> The following diagram shows the timing diagram
>=20
>=20
>            an_pending_timeout           an_pending_guard
>    V                                                       V auto-neg=
o
>    |--------------------------------->|....................|
>                                       ^
>                        auto-negotiation complete/timeout
>=20
> We do not have plan to submit this patch upstream (unless the communi=
ty
> feels this patch is useful in general) but we would like to seek for
> feedback or advice if this patch could introduce new problems.

As usual with state machines, introducing a new state needs to be
carefully done in order to make sure that all transitions are correct,
so far I would rather work on finding the root cause/extending the
timeout and/or making it configurable on a PHY-driver basis rather than
having this additional state which is more error prone.

Thanks!

>=20
> ---
>  drivers/net/phy/phy.c |   44 +++++++++++++++++++++++++++++++++++++++=
++++-
>  include/linux/phy.h   |    3 ++-
>  2 files changed, 45 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index b2197b5..35e6484 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -38,6 +38,16 @@
> =20
>  #include <asm/irq.h>
> =20
> +static unsigned int an_pending_timeout;
> +module_param(an_pending_timeout, uint, 0644);
> +MODULE_PARM_DESC(an_pending_timeout,
> +	"Timeout period for PHY_AN_PENDING state in second. 0 to disable PH=
Y_AN_PENDING state (default)");
> +
> +static unsigned int an_pending_guard;
> +module_param(an_pending_guard, uint, 0644);
> +MODULE_PARM_DESC(an_pending_guard,
> +	"Guard band period before firing auto-negotiation from PHY_AN_PENDI=
NG state in second. Default to 0");
> +
>  static const char *phy_speed_to_str(int speed)
>  {
>  	switch (speed) {
> @@ -82,7 +92,6 @@ static const char *phy_state_to_str(enum phy_state =
st)
>  	return NULL;
>  }
> =20
> -
>  /**
>   * phy_print_status - Convenience function to print out the current =
phy status
>   * @phydev: the phy_device struct
> @@ -485,6 +494,18 @@ int phy_start_aneg(struct phy_device *phydev)
> =20
>  	/* Invalidate LP advertising flags */
>  	phydev->lp_advertising =3D 0;
> +	if (an_pending_timeout) {
> +		switch (phydev->state) {
> +		case PHY_AN_PENDING:
> +		case PHY_HALTED:
> +			break;
> +		default:
> +			phydev->state =3D PHY_AN_PENDING;
> +			phydev->link_timeout =3D an_pending_timeout;
> +			goto out_unlock;
> +		}
> +
> +	}
> =20
>  	err =3D phydev->drv->config_aneg(phydev);
>  	if (err < 0)
> @@ -831,6 +852,27 @@ void phy_state_machine(struct work_struct *work)
>  		phydev->link_timeout =3D PHY_AN_TIMEOUT;
> =20
>  		break;
> +	case PHY_AN_PENDING:
> +		/* Check if negotiation is done.  Break if there's an error */
> +		err =3D phy_aneg_done(phydev);
> +		if (err < 0)
> +			break;
> +
> +		/* If AN is done, we'll proceed with the real aneg triggering */
> +		if (err > 0) {
> +			if (phydev->link_timeout > 0)
> +				phydev->link_timeout =3D -(an_pending_guard);
> +			else if (phydev->link_timeout < 0)
> +				phydev->link_timeout++;
> +		} else
> +			phydev->link_timeout--;
> +
> +		if (0 =3D=3D phydev->link_timeout) {
> +			needs_aneg =3D true;
> +
> +			phydev->link_timeout =3D PHY_AN_TIMEOUT;
> +		}
> +		break;
>  	case PHY_AN:
>  		err =3D phy_read_status(phydev);
>  		if (err < 0)
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index a26c3f8..a63afdc 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -308,7 +308,8 @@ enum phy_state {
>  	PHY_FORCING,
>  	PHY_CHANGELINK,
>  	PHY_HALTED,
> -	PHY_RESUMING
> +	PHY_RESUMING,
> +	PHY_AN_PENDING
>  };
> =20
>  /**
>=20


--=20
=46lorian

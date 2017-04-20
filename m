From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: Re: [PATCH v1] net: phy: fix auto-negotiation stall due to unavailable interrupt
Date: Thu, 20 Apr 2017 18:33:38 +0300
Message-ID: <40A85DD3-9569-409E-B732-37CAC0E45515@gmail.com>
References: <1492686004-30527-1-git-send-email-al.kochet@gmail.com> <1492686004-30527-2-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:32853 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970664AbdDTPdm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:33:42 -0400
In-Reply-To: <1492686004-30527-2-git-send-email-al.kochet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Alexandre!

Just found that you've fixed similar problem for Micrel PHY:
=
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/=
?id=3D99f81afc139c6edd14d77a91ee91685a414a1c66

Could you please test if my patch[1] fix your problem?

As reverting your patch will speedup MAC startup time for boards with =
Micrel PHY
on 3~5 sec (auto-negotiation time[2]). Could you check that also?

Regards,
Alexander.

[1] https://lkml.org/lkml/2017/4/20/357
[2] http://www.ieee802.org/3/af/public/jan02/brown_1_0102.pdf


> 20 =D0=B0=D0=BF=D1=80. 2017 =D0=B3., =D0=B2 14:00, Alexander Kochetkov =
<al.kochet@gmail.com> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0):
>=20
> The Ethernet link on an interrupt driven PHY was not coming up if the =
Ethernet
> cable was plugged before the Ethernet interface was brought up.
>=20
> The patch trigger PHY state machine to update link state if PHY was =
requested to
> do auto-negotiation and auto-negotiation complete flag already set.
>=20
> During power-up cycle the PHY do auto-negotiation, generate interrupt =
and set
> auto-negotiation complete flag. Interrupt is handled by PHY state =
machine but
> doesn't update link state because PHY is in PHY_READY state. After =
some time
> MAC bring up, start and request PHY to do auto-negotiation. If there =
are no new
> settings to advertise genphy_config_aneg() doesn't start PHY =
auto-negotiation.
> PHY continue to stay in auto-negotiation complete state and doesn't =
fire
> interrupt. At the same time PHY state machine expect that PHY started
> auto-negotiation and is waiting for interrupt from PHY and it won't =
get it.
>=20
> Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
> Cc: stable <stable@vger.kernel.org> # v4.9+
> ---
> drivers/net/phy/phy.c |   40 ++++++++++++++++++++++++++++++++++++----
> include/linux/phy.h   |    1 +
> 2 files changed, 37 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 7cc1b7d..2d9975b 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -591,16 +591,18 @@ int phy_mii_ioctl(struct phy_device *phydev, =
struct ifreq *ifr, int cmd)
> EXPORT_SYMBOL(phy_mii_ioctl);
>=20
> /**
> - * phy_start_aneg - start auto-negotiation for this PHY device
> + * phy_start_aneg_priv - start auto-negotiation for this PHY device
>  * @phydev: the phy_device struct
> + * @sync: indicate whether we should wait for the workqueue =
cancelation
>  *
>  * Description: Sanitizes the settings (if we're not autonegotiating
>  *   them), and then calls the driver's config_aneg function.
>  *   If the PHYCONTROL Layer is operating, we change the state to
>  *   reflect the beginning of Auto-negotiation or forcing.
>  */
> -int phy_start_aneg(struct phy_device *phydev)
> +static int phy_start_aneg_priv(struct phy_device *phydev, bool sync)
> {
> +	bool trigger =3D 0;
> 	int err;
>=20
> 	mutex_lock(&phydev->lock);
> @@ -625,10 +627,40 @@ int phy_start_aneg(struct phy_device *phydev)
> 		}
> 	}
>=20
> +	/* Re-schedule a PHY state machine to check PHY status because
> +	 * negotiation may already be done and aneg interrupt may not be
> +	 * generated.
> +	 */
> +	if (phy_interrupt_is_valid(phydev) && (phydev->state =3D=3D =
PHY_AN)) {
> +		err =3D phy_aneg_done(phydev);
> +		if (err > 0) {
> +			trigger =3D true;
> +			err =3D 0;
> +		}
> +	}
> +
> out_unlock:
> 	mutex_unlock(&phydev->lock);
> +
> +	if (trigger)
> +		phy_trigger_machine(phydev, sync);
> +
> 	return err;
> }
> +
> +/**
> + * phy_start_aneg - start auto-negotiation for this PHY device
> + * @phydev: the phy_device struct
> + *
> + * Description: Sanitizes the settings (if we're not autonegotiating
> + *   them), and then calls the driver's config_aneg function.
> + *   If the PHYCONTROL Layer is operating, we change the state to
> + *   reflect the beginning of Auto-negotiation or forcing.
> + */
> +int phy_start_aneg(struct phy_device *phydev)
> +{
> +	return phy_start_aneg_priv(phydev, true);
> +}
> EXPORT_SYMBOL(phy_start_aneg);
>=20
> /**
> @@ -656,7 +688,7 @@ void phy_start_machine(struct phy_device *phydev)
>  *   state machine runs.
>  */
>=20
> -static void phy_trigger_machine(struct phy_device *phydev, bool sync)
> +void phy_trigger_machine(struct phy_device *phydev, bool sync)
> {
> 	if (sync)
> 		cancel_delayed_work_sync(&phydev->state_queue);
> @@ -1151,7 +1183,7 @@ void phy_state_machine(struct work_struct *work)
> 	mutex_unlock(&phydev->lock);
>=20
> 	if (needs_aneg)
> -		err =3D phy_start_aneg(phydev);
> +		err =3D phy_start_aneg_priv(phydev, false);
> 	else if (do_suspend)
> 		phy_suspend(phydev);
>=20
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 7fc1105..b19ae66 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -840,6 +840,7 @@ int phy_drivers_register(struct phy_driver =
*new_driver, int n,
> void phy_mac_interrupt(struct phy_device *phydev, int new_link);
> void phy_start_machine(struct phy_device *phydev);
> void phy_stop_machine(struct phy_device *phydev);
> +void phy_trigger_machine(struct phy_device *phydev, bool sync);
> int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd =
*cmd);
> int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd =
*cmd);
> int phy_ethtool_ksettings_get(struct phy_device *phydev,
> --=20
> 1.7.9.5
>=20

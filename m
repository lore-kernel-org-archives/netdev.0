From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: Re: [PATCH] net: phy: fix auto-negotiation stall due to unavailable interrupt
Date: Wed, 19 Apr 2017 17:05:53 +0300
Message-ID: <24E19B31-CCD8-4032-B17B-D226D4DB881D@gmail.com>
References: <1492609604-16359-1-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492609604-16359-1-git-send-email-al.kochet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just found similar problem fixed in another PHY. See commit 99f81afc139c
("phy: micrel: Disable auto negotiation on startup=C2=BB)

> 19 =D0=B0=D0=BF=D1=80. 2017 =D0=B3., =D0=B2 16:46, Alexander Kochetkov =
<al.kochet@gmail.com> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0):
>=20
> The problem I fix related to SMSC LAN8710/LAN8720 PHY handled using
> interrupts. During power-up cycle the PHY do auto-negotiation, =
generate
> interrupt and set BMSR_ANEGCOMPLETE flag. Interrupt is handled by PHY
> state machine but doesn't update link because PHY is in PHY_READY =
state.
> After some time MAC bring up and connect with PHY. It start PHY using
> phy_start(). During startup PHY change state to PHY_AN but doesn't
> set BMCR_ANRESTART flag due to genphy_config_aneg() doesn't update =
MII_BMCR
> because there no new to advertising. As a result, state machine wait =
for
> interrupt from PHY and nether get "link is up". Because =
BMSR_ANEGCOMPLETE
> already set the patch schedule check link without waiting interrupt.
> In case genphy_config_aneg() update MII_BMCR and set BMCR_ANRESTART
> flag, BMSR_ANEGCOMPLETE will be cleared and state machine will =
continue
> on auto-negotiation interrupt.
>=20
> Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
> ---
> drivers/net/phy/phy.c |   12 ++++++++++++
> 1 file changed, 12 insertions(+)
>=20
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 7cc1b7d..da8f03d 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -1169,6 +1169,18 @@ void phy_state_machine(struct work_struct =
*work)
> 	if (phydev->irq =3D=3D PHY_POLL)
> 		queue_delayed_work(system_power_efficient_wq, =
&phydev->state_queue,
> 				   PHY_STATE_TIME * HZ);
> +
> +	/* Re-schedule a PHY state machine to check PHY status because
> +	 * negotiation already done and aneg interrupt may not be =
generated.
> +	 */
> +	if (needs_aneg && (phydev->irq > 0) && (phydev->state =3D=3D =
PHY_AN)) {
> +		err =3D phy_aneg_done(phydev);
> +		if (err > 0)
> +			queue_delayed_work(system_power_efficient_wq,
> +					   &phydev->state_queue, 0);
> +		if (err < 0)
> +			phy_error(phydev);
> +	}
> }
>=20
> /**
> --=20
> 1.7.9.5
>=20

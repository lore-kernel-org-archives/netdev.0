From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: enable rx/tx in sky2_phy_reinit()
Date: Tue, 22 Jun 2010 23:57:56 +0900
Message-ID: <AANLkTilzHA_URoZONtMf6A9-IRV4wA2ncr0b8Jff1ge9@mail.gmail.com>
References: <20100617022158.GA4135@jenkins.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Brandon Philips <brandon@ifup.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:59953 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755622Ab0FVO55 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 10:57:57 -0400
Received: by gwaa12 with SMTP id a12so1049334gwa.19
        for <netdev@vger.kernel.org>; Tue, 22 Jun 2010 07:57:57 -0700 (PDT)
In-Reply-To: <20100617022158.GA4135@jenkins.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested, and verified that it fixes the bug reported.

Tested-by: Mike McCormack <mikem@ring3k.org>

On 17 June 2010 11:21, Brandon Philips <brandon@ifup.org> wrote:
> sky2_phy_reinit is called by the ethtool helpers sky2_set_settings,
> sky2_nway_reset and sky2_set_pauseparam when netif_running.
>
> However, at the end of sky2_phy_init GM_GP_CTRL has GM_GPCR_RX_ENA an=
d
> GM_GPCR_TX_ENA cleared. So, doing these commands causes the device to
> stop working:
>
> $ ethtool -r eth0
> $ ethtool -A eth0 autoneg off
>
> Fix this issue by enabling Rx/Tx after running sky2_phy_init in
> sky2_phy_reinit.
>
> Signed-off-by: Brandon Philips <bphilips@suse.de>
> Tested-by: Brandon Philips <bphilips@suse.de>
> Cc: stable@kernel.org
>
> ---
> =C2=A0drivers/net/sky2.c | =C2=A0 19 ++++++++++++++-----
> =C2=A01 files changed, 14 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 2111c7b..7985165 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -717,11 +717,24 @@ static void sky2_phy_power_down(struct sky2_hw =
*hw, unsigned port)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRIT=
E_OFF);
> =C2=A0}
>
> +/* Enable Rx/Tx */
> +static void sky2_enable_rx_tx(struct sky2_port *sky2)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct sky2_hw *hw =3D sky2->hw;
> + =C2=A0 =C2=A0 =C2=A0 unsigned port =3D sky2->port;
> + =C2=A0 =C2=A0 =C2=A0 u16 reg;
> +
> + =C2=A0 =C2=A0 =C2=A0 reg =3D gma_read16(hw, port, GM_GP_CTRL);
> + =C2=A0 =C2=A0 =C2=A0 reg |=3D GM_GPCR_RX_ENA | GM_GPCR_TX_ENA;
> + =C2=A0 =C2=A0 =C2=A0 gma_write16(hw, port, GM_GP_CTRL, reg);
> +}
> +
> =C2=A0/* Force a renegotiation */
> =C2=A0static void sky2_phy_reinit(struct sky2_port *sky2)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_bh(&sky2->phy_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sky2_phy_init(sky2->hw, sky2->port);
> + =C2=A0 =C2=A0 =C2=A0 sky2_enable_rx_tx(sky2);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_bh(&sky2->phy_lock);
> =C2=A0}
>
> @@ -2040,7 +2053,6 @@ static void sky2_link_up(struct sky2_port *sky2=
)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sky2_hw *hw =3D sky2->hw;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned port =3D sky2->port;
> - =C2=A0 =C2=A0 =C2=A0 u16 reg;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0static const char *fc_name[] =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0[FC_NONE] =C2=A0=
 =C2=A0 =C2=A0 =3D "none",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0[FC_TX] =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =3D "tx",
> @@ -2048,10 +2060,7 @@ static void sky2_link_up(struct sky2_port *sky=
2)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0[FC_BOTH] =C2=A0=
 =C2=A0 =C2=A0 =3D "both",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0};
>
> - =C2=A0 =C2=A0 =C2=A0 /* enable Rx/Tx */
> - =C2=A0 =C2=A0 =C2=A0 reg =3D gma_read16(hw, port, GM_GP_CTRL);
> - =C2=A0 =C2=A0 =C2=A0 reg |=3D GM_GPCR_RX_ENA | GM_GPCR_TX_ENA;
> - =C2=A0 =C2=A0 =C2=A0 gma_write16(hw, port, GM_GP_CTRL, reg);
> + =C2=A0 =C2=A0 =C2=A0 sky2_enable_rx_tx(sky2);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0gm_phy_write(hw, port, PHY_MARV_INT_MASK, =
PHY_M_DEF_MSK);
>
> --
> 1.7.1
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>

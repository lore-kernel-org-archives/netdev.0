From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: improve bcmgenet_mii_setup()
Date: Fri, 3 Oct 2014 21:18:37 -0700
Message-ID: <CAGVrzcb7Szb2BcDChHkkwzD6j8SVoxsVDtPBLcjVKfnaZOzF=g@mail.gmail.com>
References: <20141003192501.C79311004A1@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:32922 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaJDETT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 00:19:19 -0400
Received: by mail-ie0-f172.google.com with SMTP id rl12so845269iec.3
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 21:19:18 -0700 (PDT)
In-Reply-To: <20141003192501.C79311004A1@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-10-03 12:25 GMT-07:00 Petri Gynther <pgynther@google.com>:
> bcmgenet_mii_setup() is called from the PHY state machine every 1-2 seconds
> when the PHYs are in PHY_POLL mode.

At some point, I would to make sure we can avoid polling the PHY
completely and just rely on link interrupts, and use that scheme for
the MoCA PHYs too.

>
> Improve bcmgenet_mii_setup() so that it touches the MAC registers only when
> the link is up and there was a change to link, speed, duplex, or pause status.
>
> Signed-off-by: Petri Gynther <pgynther@google.com>

Tested-by: Florian Fainelli <f.fainelli@gmail.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c |  3 +-
>  drivers/net/ethernet/broadcom/genet/bcmgenet.h |  3 +-
>  drivers/net/ethernet/broadcom/genet/bcmmii.c   | 73 ++++++++++++++++----------
>  3 files changed, 48 insertions(+), 31 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index d51729c..e0a6238 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -2162,9 +2162,10 @@ static void bcmgenet_netif_stop(struct net_device *dev)
>          */
>         cancel_work_sync(&priv->bcmgenet_irq_work);
>
> -       priv->old_pause = -1;
>         priv->old_link = -1;
> +       priv->old_speed = -1;
>         priv->old_duplex = -1;
> +       priv->old_pause = -1;
>  }
>
>  static int bcmgenet_close(struct net_device *dev)
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> index ad95fe5..321b1db 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> @@ -548,8 +548,9 @@ struct bcmgenet_priv {
>         u16 gphy_rev;
>
>         /* PHY device variables */
> -       int old_duplex;
>         int old_link;
> +       int old_speed;
> +       int old_duplex;
>         int old_pause;
>         phy_interface_t phy_interface;
>         int phy_addr;
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> index 75b26cba..9ff799a 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> @@ -82,24 +82,33 @@ static void bcmgenet_mii_setup(struct net_device *dev)
>         struct bcmgenet_priv *priv = netdev_priv(dev);
>         struct phy_device *phydev = priv->phydev;
>         u32 reg, cmd_bits = 0;
> -       unsigned int status_changed = 0;
> +       bool status_changed = false;
>
>         if (priv->old_link != phydev->link) {
> -               status_changed = 1;
> +               status_changed = true;
>                 priv->old_link = phydev->link;
>         }
>
>         if (phydev->link) {
> -               /* program UMAC and RGMII block based on established link
> -                * speed, pause, and duplex.
> -                * the speed set in umac->cmd tell RGMII block which clock
> -                * 25MHz(100Mbps)/125MHz(1Gbps) to use for transmit.
> -                * receive clock is provided by PHY.
> -                */
> -               reg = bcmgenet_ext_readl(priv, EXT_RGMII_OOB_CTRL);
> -               reg &= ~OOB_DISABLE;
> -               reg |= RGMII_LINK;
> -               bcmgenet_ext_writel(priv, reg, EXT_RGMII_OOB_CTRL);
> +               /* check speed/duplex/pause changes */
> +               if (priv->old_speed != phydev->speed) {
> +                       status_changed = true;
> +                       priv->old_speed = phydev->speed;
> +               }
> +
> +               if (priv->old_duplex != phydev->duplex) {
> +                       status_changed = true;
> +                       priv->old_duplex = phydev->duplex;
> +               }
> +
> +               if (priv->old_pause != phydev->pause) {
> +                       status_changed = true;
> +                       priv->old_pause = phydev->pause;
> +               }
> +
> +               /* done if nothing has changed */
> +               if (!status_changed)
> +                       return;
>
>                 /* speed */
>                 if (phydev->speed == SPEED_1000)
> @@ -110,36 +119,39 @@ static void bcmgenet_mii_setup(struct net_device *dev)
>                         cmd_bits = UMAC_SPEED_10;
>                 cmd_bits <<= CMD_SPEED_SHIFT;
>
> -               if (priv->old_duplex != phydev->duplex) {
> -                       status_changed = 1;
> -                       priv->old_duplex = phydev->duplex;
> -               }
> -
>                 /* duplex */
>                 if (phydev->duplex != DUPLEX_FULL)
>                         cmd_bits |= CMD_HD_EN;
>
> -               if (priv->old_pause != phydev->pause) {
> -                       status_changed = 1;
> -                       priv->old_pause = phydev->pause;
> -               }
> -
>                 /* pause capability */
>                 if (!phydev->pause)
>                         cmd_bits |= CMD_RX_PAUSE_IGNORE | CMD_TX_PAUSE_IGNORE;
> -       }
>
> -       if (!status_changed)
> -               return;
> +               /*
> +                * Program UMAC and RGMII block based on established
> +                * link speed, duplex, and pause. The speed set in
> +                * umac->cmd tell RGMII block which clock to use for
> +                * transmit -- 25MHz(100Mbps) or 125MHz(1Gbps).
> +                * Receive clock is provided by the PHY.
> +                */
> +               reg = bcmgenet_ext_readl(priv, EXT_RGMII_OOB_CTRL);
> +               reg &= ~OOB_DISABLE;
> +               reg |= RGMII_LINK;
> +               bcmgenet_ext_writel(priv, reg, EXT_RGMII_OOB_CTRL);
>
> -       if (phydev->link) {
>                 reg = bcmgenet_umac_readl(priv, UMAC_CMD);
>                 reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
>                                CMD_HD_EN |
>                                CMD_RX_PAUSE_IGNORE | CMD_TX_PAUSE_IGNORE);
>                 reg |= cmd_bits;
>                 bcmgenet_umac_writel(priv, reg, UMAC_CMD);
> +       } else {
> +               /* done if nothing has changed */
> +               if (!status_changed)
> +                       return;
>
> +               /* needed for MoCA fixed PHY to reflect correct link status */
> +               netif_carrier_off(dev);
>         }
>
>         phy_print_status(phydev);
> @@ -318,6 +330,12 @@ static int bcmgenet_mii_probe(struct net_device *dev)
>         /* Communicate the integrated PHY revision */
>         phy_flags = priv->gphy_rev;
>
> +       /* Initialize link state variables that bcmgenet_mii_setup() uses */
> +       priv->old_link = -1;
> +       priv->old_speed = -1;
> +       priv->old_duplex = -1;
> +       priv->old_pause = -1;
> +
>         phydev = of_phy_connect(dev, priv->phy_dn, bcmgenet_mii_setup,
>                                 phy_flags, priv->phy_interface);
>         if (!phydev) {
> @@ -325,9 +343,6 @@ static int bcmgenet_mii_probe(struct net_device *dev)
>                 return -ENODEV;
>         }
>
> -       priv->old_link = -1;
> -       priv->old_duplex = -1;
> -       priv->old_pause = -1;
>         priv->phydev = phydev;
>
>         /* Configure port multiplexer based on what the probed PHY device since
> --
> 2.1.0.rc2.206.gedb03e5
>



-- 
Florian

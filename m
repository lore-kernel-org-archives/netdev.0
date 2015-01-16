From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 2/2] sh_eth: Fix ethtool operation crash when net
 device is down
Date: Fri, 16 Jan 2015 10:45:19 -0800
Message-ID: <CAGVrzcbj2JANTECtxgDUrb7c_20nyoW4n5ARndHGKYuQu-0kQg@mail.gmail.com>
References: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk> <1421430685.1222.192.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ct178-internal@lists.codethink.co.uk,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@lists.codethink.co.uk>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:55333 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbbAPSqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:46:00 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so4941953igb.1
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 10:45:59 -0800 (PST)
In-Reply-To: <1421430685.1222.192.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-01-16 9:51 GMT-08:00 Ben Hutchings <ben.hutchings@codethink.co.uk>:
> The driver connects and disconnects the PHY device whenever the
> net device is brought up and down.  The ethtool get_settings,
> set_settings and nway_reset operations will dereference a null
> or dangling pointer if called while it is down.
>
> I think it would be preferable to keep the PHY connected, but there
> may be good reasons not to.

phy_disconnect() is the canonical way to stop the PHY library state
machine, and avoid deferred work to be done and call the driver's
adjust_link function. This also boils down to calling phy_detach()
which can put the PHY in a low-power mode when implemented.

>
> As an immediate fix for this bug:
> - Set the phydev pointer to NULL after disconnecting the PHY
> - Change those three operations to return -ENODEV while the PHY is
>   not connected
>
> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> ---
>  drivers/net/ethernet/renesas/sh_eth.c |   10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 0c4d5b5..28e3822 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1827,6 +1827,9 @@ static int sh_eth_get_settings(struct net_device *ndev,
>         unsigned long flags;
>         int ret;
>
> +       if (!mdp->phydev)
> +               return -ENODEV;

Since the PHY is disconnected, would not checking for netif_running()
make sense here, unless there is a good reason to still allow
phy_ethtool_gset() to be called?

> +
>         spin_lock_irqsave(&mdp->lock, flags);
>         ret = phy_ethtool_gset(mdp->phydev, ecmd);
>         spin_unlock_irqrestore(&mdp->lock, flags);
> @@ -1841,6 +1844,9 @@ static int sh_eth_set_settings(struct net_device *ndev,
>         unsigned long flags;
>         int ret;
>
> +       if (!mdp->phydev)
> +               return -ENODEV;
> +
>         spin_lock_irqsave(&mdp->lock, flags);
>
>         /* disable tx and rx */
> @@ -1875,6 +1881,9 @@ static int sh_eth_nway_reset(struct net_device *ndev)
>         unsigned long flags;
>         int ret;
>
> +       if (!mdp->phydev)
> +               return -ENODEV;
> +
>         spin_lock_irqsave(&mdp->lock, flags);
>         ret = phy_start_aneg(mdp->phydev);
>         spin_unlock_irqrestore(&mdp->lock, flags);
> @@ -2184,6 +2193,7 @@ static int sh_eth_close(struct net_device *ndev)
>         if (mdp->phydev) {
>                 phy_stop(mdp->phydev);
>                 phy_disconnect(mdp->phydev);
> +               mdp->phydev = NULL;
>         }
>
>         free_irq(ndev->irq, ndev);
> --
> 1.7.10.4
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian

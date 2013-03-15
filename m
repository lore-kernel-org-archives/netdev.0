From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH] net: fec: restart the FEC when PHY speed changes
Date: Fri, 15 Mar 2013 12:37:50 +0800
Message-ID: <CAHrpEqSCizXm=yhZFzQ_6FJmyrrV3PU2dnyR96+rn=azOvdD1g@mail.gmail.com>
References: <1363273921-5035-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:44576 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706Ab3COEhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 00:37:53 -0400
Received: by mail-wg0-f49.google.com with SMTP id ds1so1687374wgb.28
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 21:37:51 -0700 (PDT)
In-Reply-To: <1363273921-5035-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked

2013/3/14 Lucas Stach <l.stach@pengutronix.de>:
> Proviously we would only restart the FEC when PHY link or duplex state
> changed. PHY does not always bring down the link for speed changes, in
> which case we would not detect any change and keep FEC running.
>
> Switching link speed without restarting the FEC results in the FEC being
> stuck in an indefinite state, generating error conditions for every
> packet.
>
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
>  drivers/net/ethernet/freescale/fec.c |   26 +++++++++++++++-----------
>  drivers/net/ethernet/freescale/fec.h |    1 +
>  2 files changed, 16 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index 069a155..61d2e62 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -934,24 +934,28 @@ static void fec_enet_adjust_link(struct net_device *ndev)
>                 goto spin_unlock;
>         }
>
> -       /* Duplex link change */
>         if (phy_dev->link) {
> -               if (fep->full_duplex != phy_dev->duplex) {
> -                       fec_restart(ndev, phy_dev->duplex);
> -                       /* prevent unnecessary second fec_restart() below */
> +               if (!fep->link) {
>                         fep->link = phy_dev->link;
>                         status_change = 1;
>                 }
> -       }
>
> -       /* Link on or off change */
> -       if (phy_dev->link != fep->link) {
> -               fep->link = phy_dev->link;
> -               if (phy_dev->link)
> +               if (fep->full_duplex != phy_dev->duplex)
> +                       status_change = 1;
> +
> +               if (phy_dev->speed != fep->speed) {
> +                       fep->speed = phy_dev->speed;
> +                       status_change = 1;
> +               }
> +
> +               /* if any of the above changed restart the FEC */
> +               if (status_change)
>                         fec_restart(ndev, phy_dev->duplex);
> -               else
> +       } else {
> +               if (fep->link) {
>                         fec_stop(ndev);
> -               status_change = 1;
> +                       status_change = 1;
> +               }
>         }
>
>  spin_unlock:
> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
> index f539007..eb43729 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -240,6 +240,7 @@ struct fec_enet_private {
>         phy_interface_t phy_interface;
>         int     link;
>         int     full_duplex;
> +       int     speed;
>         struct  completion mdio_done;
>         int     irq[FEC_IRQ_NUM];
>         int     bufdesc_ex;
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

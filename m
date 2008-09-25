From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: [PATCH] gianfar: Don't reset TBI<->SerDes link if it's already
 up
Date: Thu, 25 Sep 2008 16:06:54 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809251605030.7680@t2.domain.actdsltmp>
References: <1222287839-6545-1-git-send-email-tpiepho@freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Fleming Andy <afleming@freescale.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48236 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbYIYXKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 19:10:25 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m8PNAN1d000518
	for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 16:10:23 -0700 (MST)
In-Reply-To: <1222287839-6545-1-git-send-email-tpiepho@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just realized that this patch won't apply cleanly without another patch that
I haven't sent yet.

Please ignore, I'll repost both patches as a series when I get an ack for the
one not posted yet.

On Wed, 24 Sep 2008, Trent Piepho wrote:
> The link may be up already via the chip's reset strapping, or though action
> of U-Boot, or from the last time the interface was brought up.  Resetting
> the link causes it to go down for several seconds.  This can significantly
> increase the time from power-on to DHCP completion and a device being
> accessible to the network.
>
> Signed-off-by: Trent Piepho <tpiepho@freescale.com>
> Acked-by: Andy Fleming <afleming@freescale.com>
> ---
> drivers/net/gianfar.c |    9 +++++++++
> 1 files changed, 9 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 1a4a85b..dd7d8e5 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -578,6 +578,14 @@ static void gfar_configure_serdes(struct net_device *dev)
> 	if (bus)
> 		mutex_lock(&bus->mdio_lock);
>
> +	/* If the link is already up, we must already be ok, and don't need to
> +	 * configure and reset the TBI<->SerDes link.  Maybe U-Boot configured
> +	 * everything for us?  Resetting it takes the link down and requires
> +	 * several seconds for it to come back.
> +	 */
> +	if (gfar_local_mdio_read(regs, tbipa, MII_BMSR) & BMSR_LSTATUS)
> +		goto done;
> +
> 	/* Single clk mode, mii mode off(for serdes communication) */
> 	gfar_local_mdio_write(regs, tbipa, MII_TBICON, TBICON_CLK_SELECT);
>
> @@ -588,6 +596,7 @@ static void gfar_configure_serdes(struct net_device *dev)
> 	gfar_local_mdio_write(regs, tbipa, MII_BMCR, BMCR_ANENABLE |
> 			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
>
> +	done:
> 	if (bus)
> 		mutex_unlock(&bus->mdio_lock);
> }
>

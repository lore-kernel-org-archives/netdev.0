From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH] net: fec: add the initial to set the physical mac
 address
Date: Tue, 27 Aug 2013 16:18:54 +0200
Message-ID: <1377613134.4246.12.camel@weser.hi.pengutronix.de>
References: <1377170269-8988-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, b45643@freescale.com, davem@davemloft.net,
	netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com, R49496@freescale.com,
	stephen@networkplumber.org
To: Fugang Duan <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46463 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086Ab3H0OWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 10:22:12 -0400
In-Reply-To: <1377170269-8988-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, den 22.08.2013, 19:17 +0800 schrieb Fugang Duan:
> For imx6slx evk platform, the fec driver cannot work since there
> have no valid mac address set in physical mac registers.
> 
> For imx serial platform, fec/enet IPs both need the physical MAC
> address initial, otherwise it cannot work.
> 
> After acquiring the valid MAC address from devices tree/pfuse/
> kernel command line/random mac address, and then set it to the
> physical MAC address registers.
> 
Yeah, we have also seen that we need to set this explicitly. The strange
thing is that I recall this used to work without calling
fec_set_mac_address() explicitly, so either the netdev core was calling
it at some point, or our userspace was. I didn't got around to
investigate this further.
So anyway:
Reviewed-by: Lucas Stach <l.stach@pengutronix.de>

> Signed-off-by: Fugang Duan  <B38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 4349a9e..9b5e08c 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1867,10 +1867,12 @@ fec_set_mac_address(struct net_device *ndev, void *p)
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	struct sockaddr *addr = p;
>  
> -	if (!is_valid_ether_addr(addr->sa_data))
> -		return -EADDRNOTAVAIL;
> +	if (p) {
> +		if (!is_valid_ether_addr(addr->sa_data))
> +			return -EADDRNOTAVAIL;
>  
> -	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
> +		memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
> +	}
>  
>  	writel(ndev->dev_addr[3] | (ndev->dev_addr[2] << 8) |
>  		(ndev->dev_addr[1] << 16) | (ndev->dev_addr[0] << 24),
> @@ -1969,6 +1971,7 @@ static int fec_enet_init(struct net_device *ndev)
>  
>  	/* Get the Ethernet address */
>  	fec_get_mac(ndev);
> +	fec_set_mac_address(ndev, NULL);
>  
>  	/* Set receive and transmit descriptor base. */
>  	fep->rx_bd_base = cbd_base;

-- 
Pengutronix e.K.                           | Lucas Stach                 |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] net: fec: fix kernel oops when plug/unplug cable
 many times
Date: Sun, 28 Apr 2013 21:11:46 +0100
Message-ID: <1367179906.6971.36.camel@deadeye.wl.decadent.org.uk>
References: <1367118287-12175-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <romieu@fr.zoreil.com>, <r.schwebel@pengutronix.de>,
	<davem@davemloft.net>, <l.stach@pengutronix.de>,
	<netdev@vger.kernel.org>, <festevam@gmail.com>,
	<shawn.guo@linaro.org>, <lznuaa@gmail.com>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46353 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756344Ab3D1UMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 16:12:09 -0400
In-Reply-To: <1367118287-12175-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-04-28 at 11:04 +0800, Frank Li wrote:
> reproduce steps
>  1. flood ping from other machine
>  	ping -f -s 41000 IP
>  2. run below script
>     while [ 1 ]; do ethtool -s eth0 autoneg off;
>     sleep 3;ethtool -s eth0 autoneg on; sleep 4; done;
> 
> You can see oops in one hour.
> 
> The reason is fec_restart clear BD but NAPI may use it.
> The solution is disable NAPI and stop xmit when reset BD.
> disable NAPI may sleep, so fec_restart can't be call in
> atomic context.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec.c |   39 ++++++++++++++++++++++++++++-----
>  drivers/net/ethernet/freescale/fec.h |    3 +-
>  2 files changed, 35 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index 73195f6..9128a3c 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -403,6 +403,11 @@ fec_restart(struct net_device *ndev, int duplex)
>  	const struct platform_device_id *id_entry =
>  				platform_get_device_id(fep->pdev);
>  	int i;
> +	if (netif_running(ndev)) {
> +		napi_disable(&fep->napi);
> +		netif_stop_queue(ndev);
> +	}
[...]

I would advise against calling netif_stop_queue() outside of the TX path
(for reasons explained in commit 29c69a488264).  If you're sure the
carrier state is off at this point, it should be OK, though.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

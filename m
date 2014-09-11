From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/2] net: arc_emac: enable tx interrupts
Date: Thu, 11 Sep 2014 10:24:33 -0700
Message-ID: <5411DAD1.7060507@gmail.com>
References: <1410382203-10395-1-git-send-email-b.galvani@gmail.com> <1410382203-10395-2-git-send-email-b.galvani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Romain Perier <romain.perier@gmail.com>,
	=?UTF-8?B?SGVpa28gU3TDvGJuZXI=?= <heiko@sntech.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Tobias Klauser <tklauser@distanz.ch>,
	Jingoo Han <jg1.han@samsung.com>,
	Max Schwarz <max.schwarz@online.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Beniamino Galvani <b.galvani@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:45968 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbaIKRYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 13:24:41 -0400
In-Reply-To: <1410382203-10395-2-git-send-email-b.galvani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2014 01:50 PM, Beniamino Galvani wrote:
> In the current implementation the cleaning of tx ring is done by the
> NAPI poll handler, which is scheduled after rx interrupts. Thus, in
> absence of received packets the reclaim of used tx buffers is never
> executed, blocking further transmission.
> 
> This can be easily reproduced starting the transmission of a UDP flow
> with iperf, which blocks almost immediately because skbs are not
> returned to the stack and the socket send buffer becomes full.
> 
> The patch enables tx interrupts so that the tx reclaim is scheduled
> after completed transmissions.

Based on what the driver does and how TX reclaim is performed, your fix
makes complete sense to me.

> 
> Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/arc/emac_main.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> index dbea847..1d08f63 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -300,7 +300,7 @@ static int arc_emac_poll(struct napi_struct *napi, int budget)
>  	work_done = arc_emac_rx(ndev, budget);
>  	if (work_done < budget) {
>  		napi_complete(napi);
> -		arc_reg_or(priv, R_ENABLE, RXINT_MASK);
> +		arc_reg_or(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
>  	}
>  
>  	return work_done;
> @@ -329,9 +329,9 @@ static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
>  	/* Reset all flags except "MDIO complete" */
>  	arc_reg_set(priv, R_STATUS, status);
>  
> -	if (status & RXINT_MASK) {
> +	if (status & (RXINT_MASK | TXINT_MASK)) {
>  		if (likely(napi_schedule_prep(&priv->napi))) {
> -			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
> +			arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
>  			__napi_schedule(&priv->napi);
>  		}
>  	}
> @@ -442,7 +442,7 @@ static int arc_emac_open(struct net_device *ndev)
>  	arc_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
>  
>  	/* Enable interrupts */
> -	arc_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
> +	arc_reg_set(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
>  
>  	/* Set CONTROL */
>  	arc_reg_set(priv, R_CTRL,
> @@ -513,7 +513,7 @@ static int arc_emac_stop(struct net_device *ndev)
>  	netif_stop_queue(ndev);
>  
>  	/* Disable interrupts */
> -	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
> +	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
>  
>  	/* Disable EMAC */
>  	arc_reg_clr(priv, R_CTRL, EN_MASK);
> 

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] sfc: Remove requirement to set tx-usecs-irq for
 shared channels when modifying coalescing parameters
Date: Mon, 05 Sep 2011 15:12:01 +0100
Message-ID: <1315231921.3028.11.camel@bwh-desktop>
References: <1314784356-30619-1-git-send-email-ripduman.sohan@cl.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, shodgson@solarflare.com,
	netdev@vger.kernel.org
To: Ripduman Sohan <ripduman.sohan@cl.cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40088 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287Ab1IEOMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 10:12:05 -0400
In-Reply-To: <1314784356-30619-1-git-send-email-ripduman.sohan@cl.cam.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-08-31 at 10:52 +0100, Ripduman Sohan wrote:
> Shared TX/RX channels possess a single channel timer controlled by the
> rx-usecs-irq parameter.  Changing coalescing parameters required
> explicitly setting the tx-usecs-irq parameter to 0.  Ethtool (to HEAD
> of tree) does not do this and instead retrieves and re-submits the
> current tx-usecs-irq value resulting in an unsupported operation
> error.  I found this behaviour counter-intuitive and was only able to
> work out correct moderation parameters by studying the driver code.
> 
> This patch relaxes the requirement to set tx-usecs-irq to 0 by only
> erring if the presented tx-usecs-irq value differs from the current
> value.  I acknowledge, however, that there may be existing scripts
> relying on the old behaviour and so this condition is only triggered
> if a value for tx-usecs-irq is actually presented.

After you first reminded me about this in email, I had a good look at
our ethtool coalescing control functions and tried to fix them
thoroughly.

Eli Cohen also recently queried about the semantics of the fields in
struct ethtool_coalesce
<http://thread.gmane.org/gmane.linux.network/202368>, so I updated the
kernel-doc comments for it (19e2f6f..a27fc96).

So I have some changes of my own in preparation, which I'll send as
follow-ups.

> ---
>  drivers/net/sfc/efx.c     |    6 +++---
>  drivers/net/sfc/efx.h     |    1 +
>  drivers/net/sfc/ethtool.c |    4 +++-
>  3 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> index faca764..9a313cd 100644
> --- a/drivers/net/sfc/efx.c
> +++ b/drivers/net/sfc/efx.c
> @@ -1556,7 +1556,7 @@ static void efx_remove_all(struct efx_nic *efx)
>   *
>   **************************************************************************/
>  
> -static unsigned irq_mod_ticks(int usecs, int resolution)
> +unsigned efx_irq_mod_ticks(int usecs, int resolution)
>  {
>  	if (usecs <= 0)
>  		return 0; /* cannot receive interrupts ahead of time :-) */
> @@ -1570,8 +1570,8 @@ void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs, int rx_usecs,
>  			     bool rx_adaptive)
>  {
>  	struct efx_channel *channel;
> -	unsigned tx_ticks = irq_mod_ticks(tx_usecs, EFX_IRQ_MOD_RESOLUTION);
> -	unsigned rx_ticks = irq_mod_ticks(rx_usecs, EFX_IRQ_MOD_RESOLUTION);
> +	unsigned tx_ticks = efx_irq_mod_ticks(tx_usecs, EFX_IRQ_MOD_RESOLUTION);
> +	unsigned rx_ticks = efx_irq_mod_ticks(rx_usecs, EFX_IRQ_MOD_RESOLUTION);
>  
>  	EFX_ASSERT_RESET_SERIALISED(efx);
>  

I would rather add a efx_get_irq_moderation() function for use in
ethtool.c.

> diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
> index b0d1209..ddfcc7e 100644
> --- a/drivers/net/sfc/efx.h
> +++ b/drivers/net/sfc/efx.h
> @@ -113,6 +113,7 @@ extern int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok);
>  extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
>  extern void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs,
>  				    int rx_usecs, bool rx_adaptive);
> +extern unsigned efx_irq_mod_ticks(int usecs, int resolution);
>  
>  /* Dummy PHY ops for PHY drivers */
>  extern int efx_port_dummy_op_int(struct efx_nic *efx);
> diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
> index bc4643a..0a52447 100644
> --- a/drivers/net/sfc/ethtool.c
> +++ b/drivers/net/sfc/ethtool.c
> @@ -644,7 +644,9 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
>  	efx_for_each_channel(channel, efx) {
>  		if (efx_channel_has_rx_queue(channel) &&
>  		    efx_channel_has_tx_queues(channel) &&
> -		    tx_usecs) {
> +		    tx_usecs &&
> +		    efx_irq_mod_ticks(tx_usecs, EFX_IRQ_MOD_RESOLUTION) !=
> +		    channel->irq_moderation) {
>  			netif_err(efx, drv, efx->net_dev, "Channel is shared. "
>  				  "Only RX coalescing may be set\n");
>  			return -EOPNOTSUPP;

channel->irq_moderation will be the value selected by the adaptive
moderation algorithm.  efx->rx_irq_moderation is the appropriate value
to use here.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

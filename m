From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 19:35:53 +0100
Message-ID: <1307039753.2812.16.camel@bwh-desktop>
References: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24951 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542Ab1FBSf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 14:35:57 -0400
In-Reply-To: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-02 at 14:03 -0400, Neil Horman wrote:
> The bonding driver is multiqueue enabled, in which each queue represents a slave
> to enable optional steering of output frames to given slaves against the default
> output policy.  However, it needs to reset the skb->queue_mapping prior to
> queuing to the physical device or the physical slave (if it is multiqueue) could
> wind up transmitting on an unintended tx queue (one that was reserved for
> specific traffic classes for instance)
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>  drivers/net/bonding/bond_main.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 17b4dd9..812c70c 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4200,6 +4200,11 @@ static inline int bond_slave_override(struct bonding *bond,
>  	/* If the slave isn't UP, use default transmit policy. */
>  	if (slave && slave->queue_id && IS_UP(slave->dev) &&
>  	    (slave->link == BOND_LINK_UP)) {
> +		/*
> + 		 * Reset the queue mapping to allow the underlying slave	
> + 		 * the chance to re-select an appropriate tx queue
> + 		 */
> +		skb_set_queue_mapping(skb, 0);
>  		res = bond_dev_queue_xmit(bond, skb, slave->dev);
>  	}
>  

So far as I can see, this has no effect, because dev_queue_xmit() always
sets queue_mapping (in dev_pick_tx()).

What is the problem you're seeing?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device (v2)
Date: Fri, 03 Jun 2011 15:43:36 +0100
Message-ID: <1307112216.2789.16.camel@bwh-desktop>
References: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com>
	 <1307107607-3015-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46391 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350Ab1FCOnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 10:43:40 -0400
In-Reply-To: <1307107607-3015-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-03 at 09:26 -0400, Neil Horman wrote:
> The bonding driver is multiqueue enabled, in which each queue represents a slave
> to enable optional steering of output frames to given slaves against the default
> output policy.  However, it needs to reset the skb->queue_mapping prior to
> queuing to the physical device or the physical slave (if it is multiqueue) could
> wind up transmitting on an unintended tx queue
> 
> Change Notes:
> v2) Based on first pass review, updated the patch to restore the origional queue
> mapping that was found in bond_select_queue, rather than simply resetting to
> zero.  This preserves the value of queue_mapping when it was set on receive in
> the forwarding case which is desireable.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>  drivers/net/bonding/bond_main.c |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 17b4dd9..8761d86 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -400,6 +400,11 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
>  {
>  	skb->dev = slave_dev;
>  	skb->priority = 1;
> +	/*
> +	 *restore the origional mapping
> +	 */
> +	skb_set_queue_mapping(skb, (u16)skb->cb[0]);
> +
>  	if (unlikely(netpoll_tx_running(slave_dev)))
>  		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
>  	else
> @@ -4216,6 +4221,11 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
>  	 */
>  	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
>  
> +	/*
> + 	 * Save the origional txq to restore before passing to the driver
> + 	 */
> +	skb->cb[0] = txq;
> +

This is throwing away the top 8 bits.  It's unlikely to hurt in
practice, but queue numbers are currently 16-bit and we already have
hardware with >256 queues (even though we don't currently expose them
all to the kernel).

Please use ((u16 *)skb->cb)[0].

Ben.

>  	if (unlikely(txq >= dev->real_num_tx_queues)) {
>  		do {
>  			txq -= dev->real_num_tx_queues;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


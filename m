From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 9/9] s2io: implement 64 bit stats
Date: Thu, 09 Jun 2011 02:52:09 +0100
Message-ID: <1307584329.22348.525.camel@localhost>
References: <20110609005356.160260858@vyatta.com>
	 <20110609005417.817071451@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:32828 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988Ab1FIBwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 21:52:13 -0400
In-Reply-To: <20110609005417.817071451@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-08 at 17:54 -0700, Stephen Hemminger wrote:
> plain text document attachment (s2io-stats.patch)
> Convert s2io driver to 64 bit statistics interface.
> This driver keeps it private set of counters so change those
> to the 64 bit netlink type.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/drivers/net/s2io.c	2011-06-07 17:35:37.372117743 -0700
> +++ b/drivers/net/s2io.c	2011-06-07 17:44:14.102680070 -0700
> @@ -4897,7 +4897,8 @@ static void s2io_updt_stats(struct s2io_
>   *  Return value:
>   *  pointer to the updated net_device_stats structure.
>   */
> -static struct net_device_stats *s2io_get_stats(struct net_device *dev)
> +static struct rtnl_link_stats64 *s2io_get_stats(struct net_device *dev,
> +						struct rtnl_link_stats64 *net_stats)
>  {
>  	struct s2io_nic *sp = netdev_priv(dev);
>  	struct mac_info *mac_control = &sp->mac_control;
> @@ -4916,40 +4917,32 @@ static struct net_device_stats *s2io_get
>  	 */
>  	delta = ((u64) le32_to_cpu(stats->rmac_vld_frms_oflow) << 32 |
>  		le32_to_cpu(stats->rmac_vld_frms)) - sp->stats.rx_packets;
> -	sp->stats.rx_packets += delta;
> -	dev->stats.rx_packets += delta;
> +	sp->stats.tx_packets += delta;

This is now adding to tx_packets, not rx_packets.

>  	delta = ((u64) le32_to_cpu(stats->tmac_frms_oflow) << 32 |
>  		le32_to_cpu(stats->tmac_frms)) - sp->stats.tx_packets;
>  	sp->stats.tx_packets += delta;
> -	dev->stats.tx_packets += delta;
>  
>  	delta = ((u64) le32_to_cpu(stats->rmac_data_octets_oflow) << 32 |
>  		le32_to_cpu(stats->rmac_data_octets)) - sp->stats.rx_bytes;
>  	sp->stats.rx_bytes += delta;
> -	dev->stats.rx_bytes += delta;
[...]

It seems to me that the delta calculations and sp->stats are no longer
necessary.  These can be just:

	net_stats->rx_packets = ((u64) le32_to_cpu(stats->rmac_vld_frms_oflow) << 32 |
				 le32_to_cpu(stats->rmac_vld_frms));
 	net_stats->tx_packets = ((u64) le32_to_cpu(stats->tmac_frms_oflow) << 32 |
				 le32_to_cpu(stats->tmac_frms));
	net_stats->rx_bytes = ((u64) le32_to_cpu(stats->rmac_data_octets_oflow) << 32 |
		 	       le32_to_cpu(stats->rmac_data_octets));
	...

[...]
> @@ -7447,7 +7437,7 @@ static int rx_osm_handler(struct ring_in
>  		if (err_mask != 0x5) {
>  			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%x\n",
>  				  dev->name, err_mask);
> -			dev->stats.rx_crc_errors++;
> +			sp->stats.rx_crc_errors++;
[...]

This won't be atomic on 32-bit systems.  If this isn't double-counting
CRC errors (I suspect it is) then there needs to be a separate unsigned
long counter that's folded in by s2io_get_stats().

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


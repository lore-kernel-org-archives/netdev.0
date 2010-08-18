From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH net-next-2.6] vxge: Implement 64bit stats
Date: Wed, 18 Aug 2010 10:25:31 -0500
Message-ID: <20100818152531.GB9202@exar.com>
References: <1282138974.2194.83.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37236 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186Ab0HRPYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 11:24:42 -0400
Received: by iwn7 with SMTP id 7so775024iwn.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 08:24:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1282138974.2194.83.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 18, 2010 at 06:42:54AM -0700, Eric Dumazet wrote:
> vxge_get_stats() is racy, since it clears a block of memory (net_stats)
> possibly still used by other cpus.
> 
> We can update this driver to full 64bit stats, since ndo_get_stats64()
> provides a private block to store results, and driver maintains 64bit
> counters already.
> 
> We also remove net_stats field from struct vxge_sw_stats

It looks sane.  Assuming you have not tested it already, I'll give it a
quick sanity check.

Thanks,
Jon

> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  drivers/net/vxge/vxge-main.c |   22 +++++++---------------
>  drivers/net/vxge/vxge-main.h |    1 -
>  2 files changed, 7 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
> index c7c5605..ac90196 100644
> --- a/drivers/net/vxge/vxge-main.c
> +++ b/drivers/net/vxge/vxge-main.c
> @@ -2914,26 +2914,18 @@ static int vxge_change_mtu(struct net_device *dev, int new_mtu)
>  }
>  
>  /**
> - * vxge_get_stats
> + * vxge_get_stats64
>   * @dev: pointer to the device structure
> + * @stats: pointer to struct rtnl_link_stats64
>   *
> - * Updates the device statistics structure. This function updates the device
> - * statistics structure in the net_device structure and returns a pointer
> - * to the same.
>   */
> -static struct net_device_stats *
> -vxge_get_stats(struct net_device *dev)
> +static struct rtnl_link_stats64 *
> +vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
>  {
> -	struct vxgedev *vdev;
> -	struct net_device_stats *net_stats;
> +	struct vxgedev *vdev = netdev_priv(dev);
>  	int k;
>  
> -	vdev = netdev_priv(dev);
> -
> -	net_stats = &vdev->stats.net_stats;
> -
> -	memset(net_stats, 0, sizeof(struct net_device_stats));
> -
> +	/* net_stats already zeroed by caller */
>  	for (k = 0; k < vdev->no_of_vpath; k++) {
>  		net_stats->rx_packets += vdev->vpaths[k].ring.stats.rx_frms;
>  		net_stats->rx_bytes += vdev->vpaths[k].ring.stats.rx_bytes;
> @@ -3102,7 +3094,7 @@ vxge_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
>  static const struct net_device_ops vxge_netdev_ops = {
>  	.ndo_open               = vxge_open,
>  	.ndo_stop               = vxge_close,
> -	.ndo_get_stats          = vxge_get_stats,
> +	.ndo_get_stats64        = vxge_get_stats64,
>  	.ndo_start_xmit         = vxge_xmit,
>  	.ndo_validate_addr      = eth_validate_addr,
>  	.ndo_set_multicast_list = vxge_set_multicast,
> diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
> index 2e3b064..d4be07e 100644
> --- a/drivers/net/vxge/vxge-main.h
> +++ b/drivers/net/vxge/vxge-main.h
> @@ -172,7 +172,6 @@ struct vxge_msix_entry {
>  
>  struct vxge_sw_stats {
>  	/* Network Stats (interface stats) */
> -	struct net_device_stats net_stats;
>  
>  	/* Tx */
>  	u64 tx_frms;
> 
> 

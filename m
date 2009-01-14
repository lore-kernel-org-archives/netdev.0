From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 3/4] virtio_net: Add a set_rx_mode interface
Date: Wed, 14 Jan 2009 10:15:11 +0000
Message-ID: <1231928111.4944.291.camel@localhost.localdomain>
References: <1231881799.9095.188.camel@bling>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53596 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755535AbZANKPX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 05:15:23 -0500
In-Reply-To: <1231881799.9095.188.camel@bling>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-13 at 14:23 -0700, Alex Williamson wrote:

Just to be sure - this patch (i.e. without the MAC table) keeps think
working as before? i.e. the dev->uc_count check means that you don't
need to put the device into promiscuous mode to receive any packets?

> Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> ---
> 
>  drivers/net/virtio_net.c   |   18 ++++++++++++++++++
>  include/linux/virtio_net.h |    4 ++++
>  2 files changed, 22 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index de348de..b18dd4c 100644
> --- a/drivers/net/virtio_net
> +++ b/drivers/net/virtio_net.c
> @@ -664,6 +664,23 @@ static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
>  	return ethtool_op_set_tx_hw_csum(dev, data);
>  }
>  
> +static void virtnet_set_rx_mode(struct net_device *dev)
> +{
> +	struct virtnet_info *vi = netdev_priv(dev);
> +	u8 promisc, allmulti;
> +
> +	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
> +	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
> +
> +	virtnet_send_command(vi, VIRTIO_NET_CTRL_RX_MODE,
> +			     VIRTIO_NET_CTRL_RX_MODE_PROMISC,
> +			     &promisc, sizeof(promisc));
> +
> +	virtnet_send_command(vi, VIRTIO_NET_CTRL_RX_MODE,
> +			     VIRTIO_NET_CTRL_RX_MODE_ALLMULTI,
> +			     &allmulti, sizeof(allmulti));

Why two commands? Why not e.g.

        virtnet_send_command(vi, VIRTIO_NET_SET_RX_MODE,
                             &rx_mode, sizeof(rx_mode));

Also, print warning on failure?

>  static struct ethtool_ops virtnet_ethtool_ops = {
>  	.set_tx_csum = virtnet_set_tx_csum,
>  	.set_sg = ethtool_op_set_sg,
> @@ -687,6 +704,7 @@ static const struct net_device_ops virtnet_netdev = {
>  	.ndo_start_xmit      = start_xmit,
>  	.ndo_validate_addr   = eth_validate_addr,
>  	.ndo_set_mac_address = virtnet_set_mac_address,
> +	.ndo_set_rx_mode     = virtnet_set_rx_mode,

Don't think we want to hook this unless we know the host supports it -
i.e. unless the command queue is available.

>  	.ndo_change_mtu	     = virtnet_change_mtu,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller = virtnet_netpoll,
> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index 1de7c86..80cd7d3 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
> @@ -56,4 +56,8 @@ struct virtio_net_hdr_mrg_rxbuf {
>  #define VIRTIO_NET_OK     0
>  #define VIRTIO_NET_ERR    1
>  
> +#define VIRTIO_NET_CTRL_RX_MODE    0

I'd probably call the command VIRTIO_NET_CMD_SET_RX_MODE

> + #define VIRTIO_NET_CTRL_RX_MODE_PROMISC      0
> + #define VIRTIO_NET_CTRL_RX_MODE_ALLMULTI     1

and these VIRTIO_NET_RX_MODE_PROMISC/ALLMULTI

Also, kill the leading whitespace - I didn't even think that would
build :)

Cheers,
Mark.


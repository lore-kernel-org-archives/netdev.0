From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v2 1/5] net: virtio dynamically disable/enable
 LRO
Date: Tue, 22 Nov 2016 01:23:00 +0200
Message-ID: <20161122012202-mutt-send-email-mst@kernel.org>
References: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
 <20161120024934.19187.8294.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, kubakici@wp.pl,
        shm@cumulusnetworks.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50748 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754263AbcKUXXC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 18:23:02 -0500
Content-Disposition: inline
In-Reply-To: <20161120024934.19187.8294.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 19, 2016 at 06:49:34PM -0800, John Fastabend wrote:
> This adds support for dynamically setting the LRO feature flag. The
> message to control guest features in the backend uses the
> CTRL_GUEST_OFFLOADS msg type.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/virtio_net.c |   45 ++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 44 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index ca5239a..8189e5b 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1419,6 +1419,41 @@ static void virtnet_init_settings(struct net_device *dev)
>  	.set_settings = virtnet_set_settings,
>  };
>  
> +static int virtnet_set_features(struct net_device *netdev,
> +				netdev_features_t features)
> +{
> +	struct virtnet_info *vi = netdev_priv(netdev);
> +	struct virtio_device *vdev = vi->vdev;
> +	struct scatterlist sg;
> +	u64 offloads = 0;
> +
> +	if (features & NETIF_F_LRO)
> +		offloads |= (1 << VIRTIO_NET_F_GUEST_TSO4) |
> +			    (1 << VIRTIO_NET_F_GUEST_TSO6);
> +
> +	if (features & NETIF_F_RXCSUM)
> +		offloads |= (1 << VIRTIO_NET_F_GUEST_CSUM);
> +
> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS)) {
> +		sg_init_one(&sg, &offloads, sizeof(uint64_t));
> +		if (!virtnet_send_command(vi,
> +					  VIRTIO_NET_CTRL_GUEST_OFFLOADS,
> +					  VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET,
> +					  &sg)) {
> +			dev_warn(&netdev->dev,
> +				 "Failed to set guest offloads by virtnet command.\n");
> +			return -EINVAL;
> +		}
> +	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS) &&
> +		   !virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
> +		dev_warn(&netdev->dev,
> +			 "No support for setting offloads pre version_1.\n");
> +		return -EINVAL;
> +	}

I don't get this last warning. VIRTIO_NET_F_CTRL_GUEST_OFFLOADS
was exposes by legacy devices, I don't think it's related to
VIRTIO_F_VERSION_1.


> +
> +	return 0;
> +}
> +
>  static const struct net_device_ops virtnet_netdev = {
>  	.ndo_open            = virtnet_open,
>  	.ndo_stop   	     = virtnet_close,
> @@ -1435,6 +1470,7 @@ static void virtnet_init_settings(struct net_device *dev)
>  #ifdef CONFIG_NET_RX_BUSY_POLL
>  	.ndo_busy_poll		= virtnet_busy_poll,
>  #endif
> +	.ndo_set_features	= virtnet_set_features,
>  };
>  
>  static void virtnet_config_changed_work(struct work_struct *work)
> @@ -1810,6 +1846,12 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
>  		dev->features |= NETIF_F_RXCSUM;
>  
> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) &&
> +	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6)) {
> +		dev->features |= NETIF_F_LRO;
> +		dev->hw_features |= NETIF_F_LRO;
> +	}
> +
>  	dev->vlan_features = dev->features;
>  
>  	/* MTU range: 68 - 65535 */
> @@ -2047,7 +2089,8 @@ static int virtnet_restore(struct virtio_device *vdev)
>  	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, \
>  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ, \
>  	VIRTIO_NET_F_CTRL_MAC_ADDR, \
> -	VIRTIO_NET_F_MTU
> +	VIRTIO_NET_F_MTU, \
> +	VIRTIO_NET_F_CTRL_GUEST_OFFLOADS
>  
>  static unsigned int features[] = {
>  	VIRTNET_FEATURES,

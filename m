From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: Fix DMA-from-the-stack in
 virtnet_set_mac_address()
Date: Tue, 6 Dec 2016 05:00:08 +0200
Message-ID: <20161206050003-mutt-send-email-mst@kernel.org>
References: <fe889e578d5dffa9ae0834b449a35fcfd1e10694.1480990173.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        Jason Wang <jasowang@redhat.com>,
        Laura Abbott <labbott@redhat.com>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56800 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751064AbcLFDAO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 22:00:14 -0500
Content-Disposition: inline
In-Reply-To: <fe889e578d5dffa9ae0834b449a35fcfd1e10694.1480990173.git.luto@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 05, 2016 at 06:10:58PM -0800, Andy Lutomirski wrote:
> With CONFIG_VMAP_STACK=y, virtnet_set_mac_address() can be passed a
> pointer to the stack and it will OOPS.  Copy the address to the heap
> to prevent the crash.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Reported-by: zbyszek@in.waw.pl
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> 
> Very lightly tested.
> 
>  drivers/net/virtio_net.c | 19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 7276d5a95bd0..cbf1c613c67a 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -969,12 +969,17 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	struct virtio_device *vdev = vi->vdev;
>  	int ret;
> -	struct sockaddr *addr = p;
> +	struct sockaddr *addr;
>  	struct scatterlist sg;
>  
> -	ret = eth_prepare_mac_addr_change(dev, p);
> +	addr = kmalloc(sizeof(*addr), GFP_KERNEL);
> +	if (!addr)
> +		return -ENOMEM;
> +	memcpy(addr, p, sizeof(*addr));
> +
> +	ret = eth_prepare_mac_addr_change(dev, addr);
>  	if (ret)
> -		return ret;
> +		goto out;
>  
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
>  		sg_init_one(&sg, addr->sa_data, dev->addr_len);
> @@ -982,7 +987,8 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
>  					  VIRTIO_NET_CTRL_MAC_ADDR_SET, &sg)) {
>  			dev_warn(&vdev->dev,
>  				 "Failed to set mac address by vq command.\n");
> -			return -EINVAL;
> +			ret = -EINVAL;
> +			goto out;
>  		}
>  	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC) &&
>  		   !virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
> @@ -996,8 +1002,11 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
>  	}
>  
>  	eth_commit_mac_addr_change(dev, p);
> +	ret = 0;
>  
> -	return 0;
> +out:
> +	kfree(addr);
> +	return ret;
>  }
>  
>  static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
> -- 
> 2.9.3

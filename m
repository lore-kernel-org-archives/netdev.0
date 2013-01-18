From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH v3 2/2] virtio-net: introduce a new control to set macaddr
Date: Fri, 18 Jan 2013 12:00:42 +0100
Message-ID: <20130118110042.GB22481@stefanha-thinkpad.redhat.com>
References: <1358419212-32356-1-git-send-email-akong@redhat.com>
 <1358419212-32356-3-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org,
	davem@davemloft.net
To: akong@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358419212-32356-3-git-send-email-akong@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 17, 2013 at 06:40:12PM +0800, akong@redhat.com wrote:
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 395ab4f..837c978 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -802,14 +802,32 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	struct virtio_device *vdev = vi->vdev;
>  	int ret;
> +	struct scatterlist sg;
> +	char save_addr[ETH_ALEN];
> +	unsigned char save_aatype;
> +
> +	memcpy(save_addr, dev->dev_addr, ETH_ALEN);
> +	save_aatype = dev->addr_assign_type;
>  
>  	ret = eth_mac_addr(dev, p);
>  	if (ret)
>  		return ret;
>  
> -	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
> +		sg_init_one(&sg, dev->dev_addr, dev->addr_len);
> +		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
> +					  VIRTIO_NET_CTRL_MAC_ADDR_SET,
> +					  &sg, 1, 0)) {
> +			dev_warn(&vdev->dev,
> +				 "Failed to set mac address by vq command.\n");
> +			memcpy(dev->dev_addr, save_addr, ETH_ALEN);
> +			dev->addr_assign_type = save_aatype;
> +			return -EINVAL;
> +		}

eth_mac_addr() doesn't allow callers to implement error handling nicely.
Although you didn't duplicate it's code directly, this patch still leaks
internals of eth_mac_addr().

How about splitting eth_mac_addr() in a separate patch:

int eth_prepare_mac_addr_change(struct net_device *dev, void *p)
{
        struct sockaddr *addr = p;
        if (!(dev->priv_flags & IFF_LIVE_ADDR_CHANGE) && netif_running(dev))
                return -EBUSY;
        if (!is_valid_ether_addr(addr->sa_data))
                return -EADDRNOTAVAIL;
	return 0;
}

void eth_commit_mac_addr_change(struct net_device *dev, void *p)
{
        struct sockaddr *addr = p;
        memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
        /* if device marked as NET_ADDR_RANDOM, reset it */
        dev->addr_assign_type &= ~NET_ADDR_RANDOM;
}

/* Default implementation of MAC address changing */
int eth_mac_addr(struct net_device *dev, void *p)
{
	int ret;
	ret = eth_prepare_mac_addr_change(dev, p);
	if (ret < 0)
		return ret;
	eth_commit_mac_addr_change(dev, p);
	return 0;
}

Now virtio_net.c does:

ret = eth_prepare_mac_addr_change(dev, p);
if (ret < 0)
	return ret;

if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
	sg_init_one(&sg, dev->dev_addr, dev->addr_len);
	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
				  VIRTIO_NET_CTRL_MAC_ADDR_SET,
				  &sg, 1, 0)) {
		dev_warn(&vdev->dev,
			 "Failed to set mac address by vq command.\n");
		return -EINVAL;
	}
} ...

eth_commit_mac_addr_change(dev, p);
return 0;

Stefan

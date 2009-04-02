From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: virtio_net: MAC address releated breakage if there is no MAC area in config
Date: Thu, 2 Apr 2009 19:23:48 +0200
Message-ID: <200904021923.48907.borntraeger@de.ibm.com>
References: <200904021333.25119.borntraeger@de.ibm.com> <1238688385.6124.255.camel@bling>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1238688385.6124.255.camel@bling>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Thursday 02 April 2009 18:06:25 schrieb Alex Williamson:
> On Thu, 2009-04-02 at 13:33 +0200, Christian Borntraeger wrote:
> > I read this as the mac config field is optional (similar to all the optional
> > fields we added in virtio_blk later).
[...]
> Sorry for the breakage.  My interpretation of the virtio-net config
> space was that the mac field was always present and the host had
> programmed a valid value when the F_MAC feature is available.  However,
> from the history of the flag, it seems like you're interpretation is
> likely correct.  Setting the config value from the randomly generated
> mac was largely opportunistic since there's no userspace that doesn't
> provide a mac by default.  So perhaps we can drop that and gate the
> set_mac_address entry point as shown below.  How does this look?
> Thanks,

that patch would solve the my problem. Thanks.

In addition, I will change our hypervisor sample code, to provide the
config space even if we do not set a MAC address in the host. Better
safe than sorry.

[...]
> virtio_net: Set the mac config only when VIRITO_NET_F_MAC
> 
> VIRTIO_NET_F_MAC indicates the presence of the mac field in config
> space, not the validity of the value it contains.  Allow the mac to be
> changed at runtime, but only push the change into config space with the
> VIRTIO_NET_F_MAC feature present.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>

> --
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index a6f1e19..9c82a39 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -575,8 +575,9 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
>  	if (ret)
>  		return ret;
> 
> -	vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
> -			  dev->dev_addr, dev->addr_len);
> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
> +		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
> +		                  dev->dev_addr, dev->addr_len);
> 
>  	return 0;
>  }
> @@ -876,11 +877,8 @@ static int virtnet_probe(struct virtio_device *vdev)
>  		vdev->config->get(vdev,
>  				  offsetof(struct virtio_net_config, mac),
>  				  dev->dev_addr, dev->addr_len);
> -	} else {
> +	} else
>  		random_ether_addr(dev->dev_addr);
> -		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
> -				  dev->dev_addr, dev->addr_len);
> -	}
> 
>  	/* Set up our device-specific information */
>  	vi = netdev_priv(dev);


From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [V2 PATCH] virtio-net: init link state correctly
Date: Fri, 5 Nov 2010 10:47:11 +0200
Message-ID: <20101105084711.GC3464@redhat.com>
References: <20101105025008.3277.87697.stgit@dhcp-91-158.nay.redhat.com>
 <19667.29541.897732.941476@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, davem@davemloft.net, markmc@redhat.com,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <19667.29541.897732.941476@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 05, 2010 at 11:00:53AM +0800, Jason Wang wrote:
> Jason Wang writes:
> 
> CC netdev missed in the original patch.

You'll have to repost it properly. Patches with a >
at start can't be applied :)
You can add my ack when you do.

>  > For device that supports VIRTIO_NET_F_STATUS, there's no need to
>  > assume the link is up and we need to call nerif_carrier_off() before
>  > querying device status, otherwise we may get wrong operstate after
>  > diver was loaded because the link watch event was not fired as
>  > expected.
>  > 
>  > For device that does not support VIRITO_NET_F_STATUS, we could not get
>  > its status through virtnet_update_status() and what we can only do is
>  > always assuming the link is up.
>  > 
>  > Signed-off-by: Jason Wang <jasowang@redhat.com>
>  > ---
>  >  drivers/net/virtio_net.c |   12 +++++++++---
>  >  1 files changed, 9 insertions(+), 3 deletions(-)
>  > 
>  > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>  > index bb6b67f..b6d4028 100644
>  > --- a/drivers/net/virtio_net.c
>  > +++ b/drivers/net/virtio_net.c
>  > @@ -986,9 +986,15 @@ static int virtnet_probe(struct virtio_device *vdev)
>  >  		goto unregister;
>  >  	}
>  >  
>  > -	vi->status = VIRTIO_NET_S_LINK_UP;
>  > -	virtnet_update_status(vi);
>  > -	netif_carrier_on(dev);
>  > +	/* Assume link up if device can't report link status,
>  > +	   otherwise get link status from config. */
>  > +	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS)) {
>  > +		netif_carrier_off(dev);
>  > +		virtnet_update_status(vi);
>  > +	} else {
>  > +		vi->status = VIRTIO_NET_S_LINK_UP;
>  > +		netif_carrier_on(dev);
>  > +	}
>  >  
>  >  	pr_debug("virtnet: registered device %s\n", dev->name);
>  >  	return 0;
>  > 
>  > --
>  > To unsubscribe from this list: send the line "unsubscribe kvm" in
>  > the body of a message to majordomo@vger.kernel.org
>  > More majordomo info at  http://vger.kernel.org/majordomo-info.html

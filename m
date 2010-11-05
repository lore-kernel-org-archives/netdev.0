From: Jason Wang <jasowang@redhat.com>
Subject: [V2 PATCH] virtio-net: init link state correctly
Date: Fri, 5 Nov 2010 11:00:53 +0800
Message-ID: <19667.29541.897732.941476@gargle.gargle.HOWL>
References: <20101105025008.3277.87697.stgit@dhcp-91-158.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, davem@davemloft.net, markmc@redhat.com,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753047Ab0KEDBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 23:01:09 -0400
In-Reply-To: <20101105025008.3277.87697.stgit@dhcp-91-158.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Wang writes:

CC netdev missed in the original patch.
 > For device that supports VIRTIO_NET_F_STATUS, there's no need to
 > assume the link is up and we need to call nerif_carrier_off() before
 > querying device status, otherwise we may get wrong operstate after
 > diver was loaded because the link watch event was not fired as
 > expected.
 > 
 > For device that does not support VIRITO_NET_F_STATUS, we could not get
 > its status through virtnet_update_status() and what we can only do is
 > always assuming the link is up.
 > 
 > Signed-off-by: Jason Wang <jasowang@redhat.com>
 > ---
 >  drivers/net/virtio_net.c |   12 +++++++++---
 >  1 files changed, 9 insertions(+), 3 deletions(-)
 > 
 > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
 > index bb6b67f..b6d4028 100644
 > --- a/drivers/net/virtio_net.c
 > +++ b/drivers/net/virtio_net.c
 > @@ -986,9 +986,15 @@ static int virtnet_probe(struct virtio_device *vdev)
 >  		goto unregister;
 >  	}
 >  
 > -	vi->status = VIRTIO_NET_S_LINK_UP;
 > -	virtnet_update_status(vi);
 > -	netif_carrier_on(dev);
 > +	/* Assume link up if device can't report link status,
 > +	   otherwise get link status from config. */
 > +	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS)) {
 > +		netif_carrier_off(dev);
 > +		virtnet_update_status(vi);
 > +	} else {
 > +		vi->status = VIRTIO_NET_S_LINK_UP;
 > +		netif_carrier_on(dev);
 > +	}
 >  
 >  	pr_debug("virtnet: registered device %s\n", dev->name);
 >  	return 0;
 > 
 > --
 > To unsubscribe from this list: send the line "unsubscribe kvm" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html

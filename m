From: Amos Kong <akong@redhat.com>
Subject: Re: [PATCH v3 2/2] virtio-net: introduce a new control
	to set macaddr
Date: Sun, 20 Jan 2013 10:20:27 +0800
Message-ID: <20130120022027.GA2184@t430s.redhat.com>
References: <1358419212-32356-1-git-send-email-akong@redhat.com>
	<1358419212-32356-3-git-send-email-akong@redhat.com>
	<20130118110042.GB22481@stefanha-thinkpad.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org,
	davem@davemloft.net
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <20130118110042.GB22481@stefanha-thinkpad.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 18, 2013 at 12:00:42PM +0100, Stefan Hajnoczi wrote:
> On Thu, Jan 17, 2013 at 06:40:12PM +0800, akong@redhat.com wrote:
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index 395ab4f..837c978 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -802,14 +802,32 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
> >  	struct virtnet_info *vi = netdev_priv(dev);
> >  	struct virtio_device *vdev = vi->vdev;
> >  	int ret;
> > +	struct scatterlist sg;
> > +	char save_addr[ETH_ALEN];
> > +	unsigned char save_aatype;
> > +
> > +	memcpy(save_addr, dev->dev_addr, ETH_ALEN);
> > +	save_aatype = dev->addr_assign_type;
> >  
> >  	ret = eth_mac_addr(dev, p);
> >  	if (ret)
> >  		return ret;
> >  
> > -	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
> > +	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
> > +		sg_init_one(&sg, dev->dev_addr, dev->addr_len);
> > +		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
> > +					  VIRTIO_NET_CTRL_MAC_ADDR_SET,
> > +					  &sg, 1, 0)) {
> > +			dev_warn(&vdev->dev,
> > +				 "Failed to set mac address by vq command.\n");
> > +			memcpy(dev->dev_addr, save_addr, ETH_ALEN);
> > +			dev->addr_assign_type = save_aatype;
> > +			return -EINVAL;
> > +		}
> 
> eth_mac_addr() doesn't allow callers to implement error handling nicely.
> Although you didn't duplicate it's code directly, this patch still leaks
> internals of eth_mac_addr().
> 
> How about splitting eth_mac_addr() in a separate patch:

Agree, then we can have nice error handling.
I will send a V4 and include this patch.
Thanks.
 
> int eth_prepare_mac_addr_change(struct net_device *dev, void *p)
> {
>         struct sockaddr *addr = p;
>         if (!(dev->priv_flags & IFF_LIVE_ADDR_CHANGE) && netif_running(dev))
>                 return -EBUSY;
>         if (!is_valid_ether_addr(addr->sa_data))
>                 return -EADDRNOTAVAIL;
> 	return 0;
> }

...

> Now virtio_net.c does:
> 
> ret = eth_prepare_mac_addr_change(dev, p);
> if (ret < 0)
> 	return ret;
> 
> if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
> 	sg_init_one(&sg, dev->dev_addr, dev->addr_len);

         trivial issue, %s/dev->dev_addr/addr->sa_data

> 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
> 				  VIRTIO_NET_CTRL_MAC_ADDR_SET,
> 				  &sg, 1, 0)) {
> 		dev_warn(&vdev->dev,
> 			 "Failed to set mac address by vq command.\n");
> 		return -EINVAL;
> 	}
> } ...
> 
> eth_commit_mac_addr_change(dev, p);
> return 0;
> 
> Stefan

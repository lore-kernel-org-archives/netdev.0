From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 5/6] net: use core MTU range checking in virt
 drivers
Date: Wed, 19 Oct 2016 10:15:21 -0400
Message-ID: <20161019141521.GB18569@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161019023333.15760-6-jarod@redhat.com>
 <20161019165629-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161019165629-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2016 at 04:59:46PM +0300, Michael S. Tsirkin wrote:
> On Tue, Oct 18, 2016 at 10:33:32PM -0400, Jarod Wilson wrote:
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index fad84f3..4885a42 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -1419,17 +1419,6 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
> >  	.set_settings = virtnet_set_settings,
> >  };
> >  
> > -#define MIN_MTU 68
> > -#define MAX_MTU 65535
> > -
> > -static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
> > -{
> > -	if (new_mtu < MIN_MTU || new_mtu > MAX_MTU)
> > -		return -EINVAL;
> > -	dev->mtu = new_mtu;
> > -	return 0;
> > -}
> > -
> >  static const struct net_device_ops virtnet_netdev = {
> >  	.ndo_open            = virtnet_open,
> >  	.ndo_stop   	     = virtnet_close,
> > @@ -1437,7 +1426,6 @@ static const struct net_device_ops virtnet_netdev = {
> >  	.ndo_validate_addr   = eth_validate_addr,
> >  	.ndo_set_mac_address = virtnet_set_mac_address,
> >  	.ndo_set_rx_mode     = virtnet_set_rx_mode,
> > -	.ndo_change_mtu	     = virtnet_change_mtu,
> >  	.ndo_get_stats64     = virtnet_stats,
> >  	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
> >  	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
> > @@ -1748,6 +1736,9 @@ static bool virtnet_validate_features(struct virtio_device *vdev)
> >  	return true;
> >  }
> >  
> > +#define MIN_MTU ETH_MIN_MTU
> > +#define MAX_MTU 65535
> > +
> 
> Do we need a common macro for this?

Probably. That value crops up in multiple drivers.

> >  static int virtnet_probe(struct virtio_device *vdev)
> >  {
> >  	int i, err;
> > @@ -1821,6 +1812,10 @@ static int virtnet_probe(struct virtio_device *vdev)
> >  
> >  	dev->vlan_features = dev->features;
> >  
> > +	/* MTU range: 68 - 65535 */
> > +	dev->min_mtu = MIN_MTU;
> > +	dev->max_mtu = MAX_MTU;
> > +
> >  	/* Configuration may specify what MAC to use.  Otherwise random. */
> >  	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
> >  		virtio_cread_bytes(vdev,
> > @@ -1875,8 +1870,10 @@ static int virtnet_probe(struct virtio_device *vdev)
> >  		mtu = virtio_cread16(vdev,
> >  				     offsetof(struct virtio_net_config,
> >  					      mtu));
> > -		if (virtnet_change_mtu(dev, mtu))
> > +		if (mtu >= dev->min_mtu && mtu <= dev->max_mtu) {
> > +			dev->mtu = mtu;
> >  			__virtio_clear_bit(vdev, VIRTIO_NET_F_MTU);
> 
> I think the logic is wrong here:
> 
> If mtu is legal, we set it but do not tell host.
> If it's out of range we tell host we use it
> but don't actually.
> 
> Should be the reverse.

Ah, yes, looks like it should be:

                if (mtu < dev->min_mtu || mtu > dev->max_mtu)
                        __virtio_clear_bit(vdev, VIRTIO_NET_F_MTU);
                else
                        dev->mtu = mtu;

-- 
Jarod Wilson
jarod@redhat.com

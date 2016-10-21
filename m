From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next v2 6/9] net: use core MTU range checking in virt
	drivers
Date: Thu, 20 Oct 2016 22:37:20 -0400
Message-ID: <20161021023720.GA11396@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
	<20161020175524.6184-1-jarod@redhat.com>
	<20161020175524.6184-7-jarod@redhat.com>
	<20161020231559-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Aaron Conole <aconole@bytheb.org>,
	David Kershner <david.kershner@unisys.com>,
	Wei Liu <wei.liu2@citrix.com>, "VMware,
	Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	Haiyang Zhang <haiyangz@microsoft.com>, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Paul Durrant <paul.durrant@citrix.com>,
	Shrikrishna Khare <skhare@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20161020231559-mutt-send-email-mst@kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2016 at 11:23:54PM +0300, Michael S. Tsirkin wrote:
> On Thu, Oct 20, 2016 at 01:55:21PM -0400, Jarod Wilson wrote:
...
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index fad84f3..720809f 100644
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
> > +#define MAX_MTU ETH_MAX_MTU
> > +
> 
> Can we drop these btw?

Bah. Yeah. Should have just used them directly. I didn't add ETH_MAX_MTU
until after doing the virtio_net changes, so I missed that.

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
> > +		if (mtu < dev->min_mtu || mtu > dev->max_mtu)
> 
> In fact the > max_mtu branch does not make sense since a 16 bit
> value can't exceed MAX_MTU.

Hm. mtu is declared as an int, not sure if there's any sort of type
promotion to be worried about (not an area I know much/anything about).
Certainly something that could be looked into as a minor optimization,
though it's only in a probe path and shouldn't hurt anything, so ... meh?

-- 
Jarod Wilson
jarod@redhat.com

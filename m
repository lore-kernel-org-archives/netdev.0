From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC v5 net-next 4/6] virtio-net: add basic interrupt
	coalescing support
Date: Tue, 10 Feb 2015 11:40:19 +0100
Message-ID: <20150210104019.GD9505@redhat.com>
References: <1423471165-34243-1-git-send-email-jasowang@redhat.com>
	<1423471165-34243-5-git-send-email-jasowang@redhat.com>
	<87386ey2iy.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87386ey2iy.fsf@rustcorp.com.au>
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

On Tue, Feb 10, 2015 at 12:02:37PM +1030, Rusty Russell wrote:
> Jason Wang <jasowang@redhat.com> writes:
> > This patch enables the interrupt coalescing setting through ethtool.
> 
> The problem is that there's nothing network specific about interrupt
> coalescing.  I can see other devices wanting exactly the same thing,
> which means we'd deprecate this in the next virtio standard.
> 
> I think the right answer is to extend like we did with
> vring_used_event(), eg:
> 
> 1) Add a new feature VIRTIO_F_RING_COALESCE.
> 2) Add another a 32-bit field after vring_used_event(), eg:
>         #define vring_used_delay(vr) (*(u32 *)((vr)->avail->ring[(vr)->num + 2]))
> 
> This loses the ability to coalesce by number of frames, but we can still
> do number of sg entries, as we do now with used_event, and we could
> change virtqueue_enable_cb_delayed() to take a precise number if we
> wanted.

But do we expect delay to be update dynamically?
If not, why not stick it in config space?

> My feeling is that this should be a v1.0-only feature though
> (eg. feature bit 33).
> 
> Cheers,
> Rusty.

Yes, e.g. we can't extend config space for legacy virtio pci.

> > Cc: Rusty Russell <rusty@rustcorp.com.au>
> > Cc: Michael S. Tsirkin <mst@redhat.com>
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > ---
> >  drivers/net/virtio_net.c        | 67 +++++++++++++++++++++++++++++++++++++++++
> >  include/uapi/linux/virtio_net.h | 12 ++++++++
> >  2 files changed, 79 insertions(+)
> >
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index cc5f5de..2b958fb 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -145,6 +145,11 @@ struct virtnet_info {
> >  
> >  	/* Budget for polling tx completion */
> >  	u32 tx_work_limit;
> > +
> > +	__u32 rx_coalesce_usecs;
> > +	__u32 rx_max_coalesced_frames;
> > +	__u32 tx_coalesce_usecs;
> > +	__u32 tx_max_coalesced_frames;
> >  };
> >  
> >  struct padded_vnet_hdr {
> > @@ -1404,12 +1409,73 @@ static void virtnet_get_channels(struct net_device *dev,
> >  	channels->other_count = 0;
> >  }
> >  
> > +static int virtnet_set_coalesce(struct net_device *dev,
> > +				struct ethtool_coalesce *ec)
> > +{
> > +	struct virtnet_info *vi = netdev_priv(dev);
> > +	struct scatterlist sg;
> > +	struct virtio_net_ctrl_coalesce c;
> > +
> > +	if (!vi->has_cvq ||
> > +	    !virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_COALESCE))
> > +		return -EOPNOTSUPP;
> > +	if (vi->rx_coalesce_usecs != ec->rx_coalesce_usecs ||
> > +	    vi->rx_max_coalesced_frames != ec->rx_max_coalesced_frames) {
> > +		c.coalesce_usecs = ec->rx_coalesce_usecs;
> > +		c.max_coalesced_frames = ec->rx_max_coalesced_frames;
> > +		sg_init_one(&sg, &c, sizeof(c));
> > +		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_COALESCE,
> > +					  VIRTIO_NET_CTRL_COALESCE_RX_SET,
> > +					  &sg)) {
> > +			dev_warn(&dev->dev, "Fail to set rx coalescing\n");
> > +			return -EINVAL;
> > +		}
> > +		vi->rx_coalesce_usecs = ec->rx_coalesce_usecs;
> > +		vi->rx_max_coalesced_frames = ec->rx_max_coalesced_frames;
> > +	}
> > +
> > +	if (vi->tx_coalesce_usecs != ec->tx_coalesce_usecs ||
> > +	    vi->tx_max_coalesced_frames != ec->tx_max_coalesced_frames) {
> > +		c.coalesce_usecs = ec->tx_coalesce_usecs;
> > +		c.max_coalesced_frames = ec->tx_max_coalesced_frames;
> > +		sg_init_one(&sg, &c, sizeof(c));
> > +		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_COALESCE,
> > +					  VIRTIO_NET_CTRL_COALESCE_TX_SET,
> > +					  &sg)) {
> > +			dev_warn(&dev->dev, "Fail to set tx coalescing\n");
> > +			return -EINVAL;
> > +		}
> > +		vi->tx_coalesce_usecs = ec->tx_coalesce_usecs;
> > +		vi->tx_max_coalesced_frames = ec->tx_max_coalesced_frames;
> > +	}
> > +
> > +	vi->tx_work_limit = ec->tx_max_coalesced_frames_irq;
> > +
> > +	return 0;
> > +}
> > +
> > +static int virtnet_get_coalesce(struct net_device *dev,
> > +				struct ethtool_coalesce *ec)
> > +{
> > +	struct virtnet_info *vi = netdev_priv(dev);
> > +
> > +	ec->rx_coalesce_usecs = vi->rx_coalesce_usecs;
> > +	ec->rx_max_coalesced_frames = vi->rx_max_coalesced_frames;
> > +	ec->tx_coalesce_usecs = vi->tx_coalesce_usecs;
> > +	ec->tx_max_coalesced_frames = vi->tx_max_coalesced_frames;
> > +	ec->tx_max_coalesced_frames_irq = vi->tx_work_limit;
> > +
> > +	return 0;
> > +}
> > +
> >  static const struct ethtool_ops virtnet_ethtool_ops = {
> >  	.get_drvinfo = virtnet_get_drvinfo,
> >  	.get_link = ethtool_op_get_link,
> >  	.get_ringparam = virtnet_get_ringparam,
> >  	.set_channels = virtnet_set_channels,
> >  	.get_channels = virtnet_get_channels,
> > +	.set_coalesce = virtnet_set_coalesce,
> > +	.get_coalesce = virtnet_get_coalesce,
> >  };
> >  
> >  #define MIN_MTU 68
> > @@ -2048,6 +2114,7 @@ static unsigned int features[] = {
> >  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
> >  	VIRTIO_NET_F_CTRL_MAC_ADDR,
> >  	VIRTIO_F_ANY_LAYOUT,
> > +	VIRTIO_NET_F_CTRL_COALESCE,
> >  };
> >  
> >  static struct virtio_driver virtio_net_driver = {
> > diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
> > index b5f1677..332009d 100644
> > --- a/include/uapi/linux/virtio_net.h
> > +++ b/include/uapi/linux/virtio_net.h
> > @@ -34,6 +34,7 @@
> >  /* The feature bitmap for virtio net */
> >  #define VIRTIO_NET_F_CSUM	0	/* Host handles pkts w/ partial csum */
> >  #define VIRTIO_NET_F_GUEST_CSUM	1	/* Guest handles pkts w/ partial csum */
> > +#define VIRTIO_NET_F_CTRL_COALESCE 3	/* Set coalescing */
> >  #define VIRTIO_NET_F_MAC	5	/* Host has given MAC address. */
> >  #define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
> >  #define VIRTIO_NET_F_GUEST_TSO4	7	/* Guest can handle TSOv4 in. */
> > @@ -202,4 +203,15 @@ struct virtio_net_ctrl_mq {
> >   #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MIN        1
> >   #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MAX        0x8000
> >  
> > +struct virtio_net_ctrl_coalesce {
> > +	__u32 coalesce_usecs;
> > +	__u32 max_coalesced_frames;
> > +};
> > +
> > +#define VIRTIO_NET_CTRL_COALESCE 6
> > + #define VIRTIO_NET_CTRL_COALESCE_TX_SET 0
> > + #define VIRTIO_NET_CTRL_COALESCE_TX_GET 1
> > + #define VIRTIO_NET_CTRL_COALESCE_RX_SET 2
> > + #define VIRTIO_NET_CTRL_COALESCE_RX_GET 3
> > +
> >  #endif /* _LINUX_VIRTIO_NET_H */
> > -- 
> > 1.8.3.1

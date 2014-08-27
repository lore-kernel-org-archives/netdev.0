From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/1] add selftest for virtio-net
Date: Wed, 27 Aug 2014 16:28:24 +0200
Message-ID: <20140827142824.GA18900@redhat.com>
References: <1409103921-2879-1-git-send-email-hjxiaohust@gmail.com>
	<53FD6542.10708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Hengjinxiao <hjxiaohust@gmail.com>, famz@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-api@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <53FD6542.10708@redhat.com>
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

On Wed, Aug 27, 2014 at 12:57:38PM +0800, Jason Wang wrote:
> On 08/27/2014 09:45 AM, Hengjinxiao wrote:
> > Selftest is an important part of network driver, this patch adds selftest for
> > virtio-net, including loopback test, negotiate test and reset test. Loopback 
> > test checks whether virtio-net can send and receive packets normally. Negotiate test
> > executes feature negotiation between virtio-net driver in Guest OS and virtio-net 
> > device in Host OS. Reset test resets virtio-net.
> 
> Thanks for the patch. Feature negotiation part brings some complicity
> and need more through. And this could be extended for CVE regression in
> the future. And you probably also need to send a patch of virtio spec to
> implement the loop back mode.
> 
> See comments inline.
> >
> > Signed-off-by: Hengjinxiao <hjxiaohust@gmail.com>
> >
> > ---
> >  drivers/net/virtio_net.c        | 233 +++++++++++++++++++++++++++++++++++++++-
> >  include/uapi/linux/virtio_net.h |   9 ++
> >  2 files changed, 241 insertions(+), 1 deletion(-)
> >
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index 59caa06..f83f6e4 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -28,6 +28,7 @@
> >  #include <linux/cpu.h>
> >  #include <linux/average.h>
> >  #include <net/busy_poll.h>
> > +#include <linux/pci.h>
> >  
> >  static int napi_weight = NAPI_POLL_WEIGHT;
> >  module_param(napi_weight, int, 0444);
> > @@ -51,6 +52,23 @@ module_param(gso, bool, 0444);
> >  #define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, 256)
> >  
> >  #define VIRTNET_DRIVER_VERSION "1.0.0"
> > +#define __VIRTNET_TESTING  0
> > +
> 
> Why need this marco?
> > +enum {
> > +	VIRTNET_LOOPBACK_TEST,
> > +	VIRTNET_FEATURE_NEG_TEST,
> > +	VIRTNET_RESET_TEST,
> > +};
> > +
> > +static const struct {
> > +	const char string[ETH_GSTRING_LEN];
> > +} virtnet_gstrings_test[] = {
> > +	[VIRTNET_LOOPBACK_TEST]	= { "loopback test   (offline)" },
> > +	[VIRTNET_FEATURE_NEG_TEST]	= { "negotiate test  (offline)" },
> > +	[VIRTNET_RESET_TEST]	= { "reset test     (offline)" },
> > +};
> > +
> > +#define VIRTNET_NUM_TEST	ARRAY_SIZE(virtnet_gstrings_test)
> >  
> >  struct virtnet_stats {
> >  	struct u64_stats_sync tx_syncp;
> > @@ -104,6 +122,8 @@ struct virtnet_info {
> >  	struct send_queue *sq;
> >  	struct receive_queue *rq;
> >  	unsigned int status;
> > +	unsigned long flags;
> > +	atomic_t lb_count;
> >  
> >  	/* Max # of queue pairs supported by the device */
> >  	u16 max_queue_pairs;
> > @@ -436,6 +456,19 @@ err_buf:
> >  	return NULL;
> >  }
> >  
> > +void virtnet_check_lb_frame(struct virtnet_info *vi,
> > +				   struct sk_buff *skb)
> > +{
> > +	unsigned int frame_size = skb->len;
> > +
> > +	if (*(skb->data + 3) == 0xFF) {
> > +		if ((*(skb->data + frame_size / 2 + 10) == 0xBE) &&
> > +		   (*(skb->data + frame_size / 2 + 12) == 0xAF)) {
> > +			atomic_dec(&vi->lb_count);
> > +		}
> > +	}
> > +}
> > +
> >  static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
> >  {
> >  	struct virtnet_info *vi = rq->vq->vdev->priv;
> > @@ -485,7 +518,12 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
> >  	} else if (hdr->hdr.flags & VIRTIO_NET_HDR_F_DATA_VALID) {
> >  		skb->ip_summed = CHECKSUM_UNNECESSARY;
> >  	}
> > -
> > +	/* loopback self test for ethtool */
> > +	if (test_bit(__VIRTNET_TESTING, &vi->flags)) {
> > +		virtnet_check_lb_frame(vi, skb);
> > +		dev_kfree_skb_any(skb);
> > +		return;
> > +	}
> 
> Not sure it's a good choice for adding such in fast path. We may need a
> test specific rx interrupt handler (and disable NAPI) for this.

I agree here.
Since it's an offline test, there's no need to mix
it up with the main mode.



> >  	skb->protocol = eth_type_trans(skb, dev);
> >  	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
> >  		 ntohs(skb->protocol), skb->len, skb->pkt_type);
> > @@ -813,6 +851,9 @@ static int virtnet_open(struct net_device *dev)
> >  {
> >  	struct virtnet_info *vi = netdev_priv(dev);
> >  	int i;
> > +	/* disallow open during test */
> > +	if (test_bit(__VIRTNET_TESTING, &vi->flags))
> > +		return -EBUSY;
> >  
> >  	for (i = 0; i < vi->max_queue_pairs; i++) {
> >  		if (i < vi->curr_queue_pairs)
> > @@ -1363,12 +1404,158 @@ static void virtnet_get_channels(struct net_device *dev,
> >  	channels->other_count = 0;
> >  }
> >  
> > +static int virtnet_reset(struct virtnet_info *vi);
> > +

Pls avoid forward declarations.
Also this seems to duplicate a bunch of code.
Please don't duplicate code, use functions to
reuse it.

> > +static void virtnet_create_lb_frame(struct sk_buff *skb,
> > +					unsigned int frame_size)
> > +{
> > +	memset(skb->data, 0xFF, frame_size);
> > +	frame_size &= ~1;
> > +	memset(&skb->data[frame_size / 2], 0xAA, frame_size / 2 - 1);
> > +	memset(&skb->data[frame_size / 2 + 10], 0xBE, 1);
> > +	memset(&skb->data[frame_size / 2 + 12], 0xAF, 1);
> > +}
> > +
> > +static int virtnet_start_loopback(struct virtnet_info *vi)
> > +{
> > +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_LOOPBACK,
> > +				  VIRTIO_NET_CTRL_LOOPBACK_SET, NULL, NULL)) {
> > +		dev_warn(&vi->dev->dev, "Failed to set loopback.\n");
> > +		return -EINVAL;
> > +	}
> > +	return 0;
> 
> You may need to test the feature bit of loop back first and report the
> card does not support loop back in some way.
> > +}
> > +
> > +static int virtnet_run_loopback_test(struct virtnet_info *vi)
> > +{
> > +	int i;
> > +	netdev_tx_t rc;
> > +	struct sk_buff *skb;
> > +	unsigned int size = GOOD_COPY_LEN;
> > +
> > +	for (i = 0; i < 100; i++) {
> > +		skb = netdev_alloc_skb(vi->dev, size);
> > +		if (!skb)
> > +			return -ENOMEM;
> > +
> > +		skb->queue_mapping = 0;
> > +		skb_put(skb, size);
> > +		virtnet_create_lb_frame(skb, size);
> > +		rc = start_xmit(skb, vi->dev);
> 
> virtio_net does not use tx interrupt to free old xmit skbs. It poll tx
> completion only during xmit_skb(). So at least the last skb is leaked
> since it was not freed. A possible solution is using tx interrupt here.
> > +		if (rc != NETDEV_TX_OK)
> > +			return -EPIPE;
> 
> It looks to me that start_xmit() never return other value than NETDEV_TX_OK.
> > +		atomic_inc(&vi->lb_count);
> > +	}
> > +	/* Give queue time to settle before testing results. */
> > +	msleep(20);
> 
> Need to make sure this value is also ok for qemu. ixgbe use 200 to 64
> packets.

Yea this looks very ugly.
Do we really need hard-coded timeouts?

> > +	return atomic_read(&vi->lb_count) ? -EIO : 0;
> > +}
> > +
> > +static int virtnet_stop_loopback(struct virtnet_info *vi)
> > +{
> > +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_LOOPBACK,
> > +				  VIRTIO_NET_CTRL_LOOPBACK_UNSET, NULL, NULL)) {
> > +		dev_warn(&vi->dev->dev, "Failed to unset loopback.\n");
> > +		return -EINVAL;
> > +	}
> > +	return 0;
> > +}
> > +
> > +static int virtnet_loopback_test(struct virtnet_info *vi, u64 *data)
> > +{
> > +	*data = virtnet_start_loopback(vi);
> > +	if (*data)
> > +		goto out;
> > +	*data = virtnet_run_loopback_test(vi);
> > +	if (*data)
> 
> Do we need to stop loopback here?
> > +		goto out;
> > +	*data = virtnet_stop_loopback(vi);
> > +out:
> > +	return *data;
> > +}
> > +
> > +static void virtnet_feature_neg_test(struct virtnet_info *vi)
> > +{
> > +	struct virtio_device *dev = vi->vdev;
> > +	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
> > +	int i;
> > +	u32 device_features;
> > +
> > +	/* Figure out what features the device supports. */
> > +	device_features = dev->config->get_features(dev);
> > +
> > +	/* Features supported by both device and driver into dev->features. */
> > +	memset(dev->features, 0, sizeof(dev->features));
> > +	for (i = 0; i < drv->feature_table_size; i++) {
> > +		unsigned int f = drv->feature_table[i];
> > +
> > +		BUG_ON(f >= 32);
> > +		if (device_features & (1 << f))
> > +			set_bit(f, dev->features);
> > +	}
> > +
> > +	/* Transport features always preserved to pass to finalize_features. */
> > +	for (i = VIRTIO_TRANSPORT_F_START; i < VIRTIO_TRANSPORT_F_END; i++)
> > +		if (device_features & (1 << i))
> > +			set_bit(i, dev->features);
> > +
> > +	dev->config->finalize_features(dev);
> > +}
> 
> A problem of the function is it may be called during DRIVER_OK, not sure
> this is ok since spec suggest to do the feature negotiation after DRIVER
> bit but before DRIVER_OK bit. And this function duplicates some of the
> code from virtio core, may consider a method to share between them.
> 
> Another issue is the test never fail which needs more thought.
> > +
> > +static int virtnet_get_sset_count(struct net_device *netdev, int sset)
> > +{
> > +	switch (sset) {
> > +	case ETH_SS_TEST:
> > +		return VIRTNET_NUM_TEST;
> > +	default:
> > +		return -EOPNOTSUPP;
> > +	}
> > +}
> > +
> > +static void virtnet_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
> > +{
> > +	switch (stringset) {
> > +	case ETH_SS_TEST:
> > +		memcpy(buf, &virtnet_gstrings_test,
> > +			sizeof(virtnet_gstrings_test));
> > +		break;
> > +	default:
> > +		break;
> > +	}
> > +}
> > +
> > +static void virtnet_self_test(struct net_device *netdev,
> > +			    struct ethtool_test *eth_test, u64 *data)
> > +{
> > +	struct virtnet_info *vi = netdev_priv(netdev);
> > +	bool if_running = netif_running(netdev);
> > +
> > +	set_bit(__VIRTNET_TESTING, &vi->flags);
> > +	memset(data, 0, sizeof(u64) * VIRTNET_NUM_TEST);
> > +
> > +	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
> > +		if (!if_running) {
> > +			dev_warn(&vi->dev->dev, "Failed to execute self test.\n");
> > +			eth_test->flags |= ETH_TEST_FL_FAILED;
> > +			return;
> > +		}
> > +		if (virtnet_loopback_test(vi, &data[VIRTNET_LOOPBACK_TEST]))
> > +			eth_test->flags |= ETH_TEST_FL_FAILED;
> > +		virtnet_feature_neg_test(vi);
> > +		virtnet_reset(vi);
> > +	}
> > +	clear_bit(__VIRTNET_TESTING, &vi->flags);
> > +}
> > +
> >  static const struct ethtool_ops virtnet_ethtool_ops = {
> >  	.get_drvinfo = virtnet_get_drvinfo,
> >  	.get_link = ethtool_op_get_link,
> >  	.get_ringparam = virtnet_get_ringparam,
> >  	.set_channels = virtnet_set_channels,
> >  	.get_channels = virtnet_get_channels,
> > +	.self_test = virtnet_self_test,
> > +	.get_strings		= virtnet_get_strings,
> > +	.get_sset_count = virtnet_get_sset_count,
> >  };
> >  
> >  #define MIN_MTU 68
> > @@ -1957,6 +2144,50 @@ static int virtnet_restore(struct virtio_device *vdev)
> >  }
> >  #endif
> >  
> > +static int virtnet_reset(struct virtnet_info *vi)
> 
> If this is needed, better split this into anther patch.
> > +{
> > +	struct virtio_device *vdev = vi->vdev;
> > +	int err, i;
> > +	u8 status;
> > +
> > +	mutex_lock(&vi->config_lock);
> > +	vi->config_enable = false;
> > +	mutex_unlock(&vi->config_lock);
> > +
> > +	cancel_delayed_work_sync(&vi->refill);
> > +
> > +	if (netif_running(vi->dev))
> > +		for (i = 0; i < vi->max_queue_pairs; i++) {
> > +			napi_disable(&vi->rq[i].napi);
> > +			netif_napi_del(&vi->rq[i].napi);
> > +		}
> > +
> > +	remove_vq_common(vi);
> > +	flush_work(&vi->config_work);
> > +
> > +	virtnet_feature_neg_test(vi);
> 
> Is this used for feature negotiation? If yes, need a better name and can
> we reuse virtio core function to do this?
> > +	err = init_vqs(vi);
> > +	if (err)
> > +		return err;
> > +	if (netif_running(vi->dev)) {
> > +		for (i = 0; i < vi->curr_queue_pairs; i++)
> > +			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
> > +				schedule_delayed_work(&vi->refill, 0);
> > +
> > +		for (i = 0; i < vi->max_queue_pairs; i++)
> > +			virtnet_napi_enable(&vi->rq[i]);
> > +	}
> > +
> > +	mutex_lock(&vi->config_lock);
> > +	vi->config_enable = true;
> > +	mutex_unlock(&vi->config_lock);
> > +
> > +	virtnet_set_queues(vi, vi->curr_queue_pairs);
> > +	status = vdev->config->get_status(vdev);
> > +	vdev->config->set_status(vdev, status | VIRTIO_CONFIG_S_DRIVER_OK);
> > +	return 0;
> > +}
> > +
> >  static struct virtio_device_id id_table[] = {
> >  	{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
> >  	{ 0 },
> > diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
> > index 172a7f0..1f31f90 100644
> > --- a/include/uapi/linux/virtio_net.h
> > +++ b/include/uapi/linux/virtio_net.h
> > @@ -201,4 +201,13 @@ struct virtio_net_ctrl_mq {
> >   #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MIN        1
> >   #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MAX        0x8000
> >  
> > + /*
> > +  * Control Loopback(5 is used by VIRTIO_NET_CTRL_GUEST_OFFLOADS in latest qemu)
> > +  *
> > +  * The command VIRTIO_NET_CTRL_LOOPBACK_SET is used to require the device come
> > +  * into loopback state.
> > +  */
> > +#define VIRTIO_NET_CTRL_LOOPBACK   6
> > + #define VIRTIO_NET_CTRL_LOOPBACK_SET        0
> > + #define VIRTIO_NET_CTRL_LOOPBACK_UNSET        1
> >  #endif /* _LINUX_VIRTIO_NET_H */

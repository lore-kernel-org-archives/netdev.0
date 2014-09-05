From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/1] add selftest for virtio-net v1.0
Date: Fri, 05 Sep 2014 11:31:45 +0800
Message-ID: <54092EA1.6060504@redhat.com>
References: <1409881866-14780-1-git-send-email-hjxiaohust@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: famz@redhat.com, mst@redhat.com
To: Hengjinxiao <hjxiaohust@gmail.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1409881866-14780-1-git-send-email-hjxiaohust@gmail.com>
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

On 09/05/2014 09:51 AM, Hengjinxiao wrote:
> 	Selftest is an important part of network driver, this patch adds selftest for
> virtio-net, including loopback test, negotiate test and reset test. Loopback 
> test checks whether virtio-net can send and receive packets normally. Negotiate test
> executes feature negotiation between virtio-net driver in Guest OS and virtio-net 
> device in Host OS. Reset test resets virtio-net.
> 	Following last patch, this version has deleted some useless codes and fixed bugs
> as you suggest.
> 	Any corrections are welcome.
>
> Signed-off-by: Hengjinxiao <hjxiaohust@gmail.com>

Some of the lines were indented correctly, some others exceeded 80
characters per line. Please see Documentation/SubmittingPatches for more
guide lines. More important, some of the comments in V1 were still not
addressed.

I suggest split this patch into series:

- patch that introduces virtio core helpers
- patch that introduces new virtio-net helpers
- patch that implements a skeleton of the selftest
- patch that implements loopback test
- patch that implements feature negotation test

Thanks
>
> ---
>  drivers/net/virtio_net.c        | 241 ++++++++++++++++++++++++++++++++++++++--
>  drivers/virtio/virtio.c         |  20 +++-
>  include/linux/virtio.h          |   2 +
>  include/uapi/linux/virtio_net.h |   9 ++
>  4 files changed, 256 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 59caa06..22d8228 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -28,6 +28,7 @@
>  #include <linux/cpu.h>
>  #include <linux/average.h>
>  #include <net/busy_poll.h>
> +#include <linux/pci.h>

Why pci.h is needed?
>  
>  static int napi_weight = NAPI_POLL_WEIGHT;
>  module_param(napi_weight, int, 0444);
> @@ -51,6 +52,17 @@ module_param(gso, bool, 0444);
>  #define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, 256)
>  
>  #define VIRTNET_DRIVER_VERSION "1.0.0"
> +#define __VIRTNET_TESTING  0
> +
> +static const struct {
> +	const char string[ETH_GSTRING_LEN];
> +} virtnet_gstrings_test[] = {
> +	{ "loopback test   (offline)" },
> +	{ "negotiate test  (offline)" },
> +	{ "reset test     (offline)" },
> +};
> +
> +#define VIRTNET_NUM_TEST	ARRAY_SIZE(virtnet_gstrings_test)
>  
>  struct virtnet_stats {
>  	struct u64_stats_sync tx_syncp;
> @@ -104,6 +116,8 @@ struct virtnet_info {
>  	struct send_queue *sq;
>  	struct receive_queue *rq;
>  	unsigned int status;
> +	unsigned long flags;
> +	atomic_t lb_count;
>  
>  	/* Max # of queue pairs supported by the device */
>  	u16 max_queue_pairs;
> @@ -436,6 +450,19 @@ err_buf:
>  	return NULL;
>  }
>  
> +void virtnet_check_lb_frame(struct virtnet_info *vi,
> +				   struct sk_buff *skb)
> +{
> +	unsigned int frame_size = skb->len;
> +
> +	if (*(skb->data + 3) == 0xFF) {
> +		if ((*(skb->data + frame_size / 2 + 10) == 0xBE) &&
> +		   (*(skb->data + frame_size / 2 + 12) == 0xAF)) {
> +			atomic_dec(&vi->lb_count);
> +		}
> +	}
> +}
> +
>  static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>  {
>  	struct virtnet_info *vi = rq->vq->vdev->priv;
> @@ -485,7 +512,12 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>  	} else if (hdr->hdr.flags & VIRTIO_NET_HDR_F_DATA_VALID) {
>  		skb->ip_summed = CHECKSUM_UNNECESSARY;
>  	}
> -
> +	/* loopback self test for ethtool */
> +	if (test_bit(__VIRTNET_TESTING, &vi->flags)) {
> +		virtnet_check_lb_frame(vi, skb);
> +		dev_kfree_skb_any(skb);
> +		return;
> +	}

Again, we really need a selftest specific handler and don't put anything
in the ordinary fast path.
>  	skb->protocol = eth_type_trans(skb, dev);
>  	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
>  		 ntohs(skb->protocol), skb->len, skb->pkt_type);
> @@ -813,6 +845,9 @@ static int virtnet_open(struct net_device *dev)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	int i;
> +	/* disallow open during test */
> +	if (test_bit(__VIRTNET_TESTING, &vi->flags))
> +		return -EBUSY;
>  
>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		if (i < vi->curr_queue_pairs)
> @@ -1363,12 +1398,166 @@ static void virtnet_get_channels(struct net_device *dev,
>  	channels->other_count = 0;
>  }
>  
> +static int virtnet_reset(struct virtnet_info *vi, u64 *data);
> +
> +static void virtnet_create_lb_frame(struct sk_buff *skb,
> +					unsigned int frame_size)
> +{
> +	memset(skb->data, 0xFF, frame_size);
> +	frame_size &= ~1;
> +	memset(&skb->data[frame_size / 2], 0xAA, frame_size / 2 - 1);
> +	memset(&skb->data[frame_size / 2 + 10], 0xBE, 1);
> +	memset(&skb->data[frame_size / 2 + 12], 0xAF, 1);
> +}
> +
> +static int virtnet_start_loopback(struct virtnet_info *vi)
> +{
> +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_LOOPBACK,
> +				  VIRTIO_NET_CTRL_LOOPBACK_SET, NULL, NULL)) {
> +		dev_warn(&vi->dev->dev, "Failed to set loopback.\n");
> +		return -EINVAL;
> +	}
> +	for (i = 0; i < vi->curr_queue_pairs; i++)
> +		napi_disable(&vi->rq[i].napi);
> +	return 0;
> +}
> +
> +static int virtnet_run_loopback_test(struct virtnet_info *vi)
> +{
> +	int i;
> +	struct sk_buff *skb;
> +	unsigned int size = GOOD_COPY_LEN;
> +
> +	for (i = 0; i < 100; i++) {
> +		skb = netdev_alloc_skb(vi->dev, size);
> +		if (!skb)
> +			return -ENOMEM;
> +
> +		skb->queue_mapping = 0;
> +		skb_put(skb, size);
> +		virtnet_create_lb_frame(skb, size);
> +		start_xmit(skb, vi->dev);
> +		atomic_inc(&vi->lb_count);
> +	}
> +	free_old_xmit_skbs(&vi->sq[skb->queue_mapping]);

You could not assume the packets were all sent at this time. It may be
delayed by several reasons e.g host load or zerocopy enabled.
> +	/* Give queue time to settle before testing results. */
> +	msleep(20);
> +	for (i = 0; i < vi->curr_queue_pairs; i++) {
> +		void *buf;
> +		unsigned int len, received = 0;
> +
> +		while ((received < 100) &&
> +			(buf = virtqueue_get_buf(vi->rq[i].vq, &len)) != NULL) {

Please use a test specific rx handler for this. And the code here
duplicates the code of virtnet_receive(), you can just pass 100 as
budget to that function.
> +			receive_buf(&vi->rq[i], buf, len);
> +			--vi->rq[i].num;
> +			received++;
> +		}
> +		if ((vi->rq[i].vq)->num_free <
> +				virtqueue_get_vring_size(vi->rq[i].vq) / 2)
> +			if (!try_fill_recv(&vi->rq[i], GFP_ATOMIC))
> +				schedule_delayed_work(&vi->refill, 0);

You disable NAPI but schedule the refill work, it won't be work until
you enable the NAPI. What's more serious is that if there's a refill
work who want to run at the same time of the beginning of the loopback
test, the virtqueue will never get refilled and the test may fail.

Mixing selftest with real workload brings a lot of complexity. Lots of
thing get easier when you using a dedicated vq handler for selftest:

- Don't bother fast path.
- The rx virtqueue will be empty and completely refilled, so if you're
testing 100 packets which is smaller than 256, no need to care about the
refill, (if you detect a fill need, it was probably a bug)
- You can use polling for rx  by just disabling the rx notifiy.
- The tx virtqueue will be empty and you can just detach all skbs at the
end of test.
> +	}
> +	return atomic_read(&vi->lb_count) ? -EIO : 0;
> +}
> +
> +static int virtnet_stop_loopback(struct virtnet_info *vi)
> +{
> +	int i;
> +
> +	for (i = 0; i < vi->curr_queue_pairs; i++)
> +		virtnet_napi_enable(&vi->rq[i]);
> +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_LOOPBACK,
> +				  VIRTIO_NET_CTRL_LOOPBACK_UNSET, NULL, NULL)) {
> +		dev_warn(&vi->dev->dev, "Failed to unset loopback.\n");
> +		return -EINVAL;
> +	}
> +	return 0;
> +}
> +
> +static int virtnet_loopback_test(struct virtnet_info *vi, u64 *data)
> +{
> +	*data = virtnet_start_loopback(vi);
> +	if (*data)
> +		goto out;
> +	*data = virtnet_run_loopback_test(vi);
> +	if (*data)
> +		goto out;

Again, you may also need to stop the loopback test in this case?
> +	*data = virtnet_stop_loopback(vi);
> +out:
> +	return *data;
> +}
> +
> +static int virtnet_feature_neg_test(struct virtnet_info *vi, u64 *data)
> +{
> +	struct virtio_device *dev = vi->vdev;
> +	u8 status;
> +
> +	status = dev->config->get_status(dev);
> +	if (status & VIRTIO_CONFIG_S_DRIVER_OK) {
> +		u8 test_status = status & ~VIRTIO_CONFIG_S_DRIVER_OK;
> +
> +		dev->config->set_status(dev, test_status);
> +	}
> +	*data = virtio_feature_negotiate(dev);
> +	dev->config->set_status(dev, status);
> +	return *data;
> +}
> +
> +static int virtnet_get_sset_count(struct net_device *netdev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_TEST:
> +		return VIRTNET_NUM_TEST;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static void virtnet_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
> +{
> +	switch (stringset) {
> +	case ETH_SS_TEST:
> +		memcpy(buf, &virtnet_gstrings_test,
> +			sizeof(virtnet_gstrings_test));
> +		break;
> +	default:
> +		break;
> +	}
> +}
> +
> +static void virtnet_self_test(struct net_device *netdev,
> +			    struct ethtool_test *eth_test, u64 *data)
> +{
> +	struct virtnet_info *vi = netdev_priv(netdev);
> +
> +	memset(data, 0, sizeof(u64) * VIRTNET_NUM_TEST);
> +	if (netif_running(netdev)) {
> +		set_bit(__VIRTNET_TESTING, &vi->flags);
> +		if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
> +			if (virtnet_loopback_test(vi, &data[0]))
> +				eth_test->flags |= ETH_TEST_FL_FAILED;
> +			if (virtnet_feature_neg_test(vi, &data[1]))
> +				eth_test->flags |= ETH_TEST_FL_FAILED;
> +			if (virtnet_reset(vi, &data[2]))
> +				eth_test->flags |= ETH_TEST_FL_FAILED;

virtnet_reset() sounds like a generic helper, better not use a ehttool
specific parameter.
> +		}
> +		clear_bit(__VIRTNET_TESTING, &vi->flags);
> +	} else {
> +		dev_warn(&vi->dev->dev,
> +			"%s is down, Loopback test will fail.\n", netdev->name);
> +		eth_test->flags |= ETH_TEST_FL_FAILED;
> +	}
> +}
> +
>  static const struct ethtool_ops virtnet_ethtool_ops = {
>  	.get_drvinfo = virtnet_get_drvinfo,
>  	.get_link = ethtool_op_get_link,
>  	.get_ringparam = virtnet_get_ringparam,
>  	.set_channels = virtnet_set_channels,
>  	.get_channels = virtnet_get_channels,
> +	.self_test = virtnet_self_test,
> +	.get_strings		= virtnet_get_strings,
> +	.get_sset_count = virtnet_get_sset_count,
>  };
>  
>  #define MIN_MTU 68
> @@ -1890,14 +2079,10 @@ static void virtnet_remove(struct virtio_device *vdev)
>  	free_netdev(vi->dev);
>  }
>  
> -#ifdef CONFIG_PM_SLEEP
> -static int virtnet_freeze(struct virtio_device *vdev)
> +static void virtnet_stop(struct virtnet_info *vi)

Please split those introduction of new helpers into separate patches.
>  {
> -	struct virtnet_info *vi = vdev->priv;
>  	int i;
>  
> -	unregister_hotcpu_notifier(&vi->nb);
> -
>  	/* Prevent config work handler from accessing the device */
>  	mutex_lock(&vi->config_lock);
>  	vi->config_enable = false;
> @@ -1906,24 +2091,20 @@ static int virtnet_freeze(struct virtio_device *vdev)
>  	netif_device_detach(vi->dev);
>  	cancel_delayed_work_sync(&vi->refill);
>  
> -	if (netif_running(vi->dev)) {
> +	if (netif_running(vi->dev))
>  		for (i = 0; i < vi->max_queue_pairs; i++) {
>  			napi_disable(&vi->rq[i].napi);
>  			napi_hash_del(&vi->rq[i].napi);
>  			netif_napi_del(&vi->rq[i].napi);
>  		}
> -	}

Those removing of braces seems unrelated to the topic, please drop them.
>  
>  	remove_vq_common(vi);
>  
>  	flush_work(&vi->config_work);
> -
> -	return 0;
>  }
>  
> -static int virtnet_restore(struct virtio_device *vdev)
> +static int virtnet_start(struct virtnet_info *vi)
>  {
> -	struct virtnet_info *vi = vdev->priv;
>  	int err, i;
>  
>  	err = init_vqs(vi);
> @@ -1944,7 +2125,27 @@ static int virtnet_restore(struct virtio_device *vdev)
>  	mutex_lock(&vi->config_lock);
>  	vi->config_enable = true;
>  	mutex_unlock(&vi->config_lock);
> +	return 0;
> +}
> +
> +#ifdef CONFIG_PM_SLEEP
> +static int virtnet_freeze(struct virtio_device *vdev)
> +{
> +	struct virtnet_info *vi = vdev->priv;
>  
> +	unregister_hotcpu_notifier(&vi->nb);
> +	virtnet_stop(vi);
> +	return 0;
> +}
> +
> +static int virtnet_restore(struct virtio_device *vdev)
> +{
> +	struct virtnet_info *vi = vdev->priv;
> +	int err;
> +
> +	err = virtnet_start(vi);
> +	if (err)
> +		return err;
>  	rtnl_lock();
>  	virtnet_set_queues(vi, vi->curr_queue_pairs);
>  	rtnl_unlock();
> @@ -1957,6 +2158,22 @@ static int virtnet_restore(struct virtio_device *vdev)
>  }
>  #endif
>  
> +static int virtnet_reset(struct virtnet_info *vi, u64 *data)
> +{
> +	struct virtio_device *vdev = vi->vdev;
> +	u8 status;
> +
> +	virtnet_stop(vi);
> +	virtio_feature_negotiate(vdev);
> +	*data = virtnet_start(vi);
> +	if (*data)
> +		return *data;
> +	virtnet_set_queues(vi, vi->curr_queue_pairs);
> +	status = vdev->config->get_status(vdev);
> +	vdev->config->set_status(vdev, status | VIRTIO_CONFIG_S_DRIVER_OK);
> +	return 0;
> +}
> +
>  static struct virtio_device_id id_table[] = {
>  	{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
>  	{ 0 },
> diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
> index fed0ce1..2fc396c 100644
> --- a/drivers/virtio/virtio.c
> +++ b/drivers/virtio/virtio.c
> @@ -117,11 +117,10 @@ void virtio_check_driver_offered_feature(const struct virtio_device *vdev,
>  }
>  EXPORT_SYMBOL_GPL(virtio_check_driver_offered_feature);
>  
> -static int virtio_dev_probe(struct device *_d)
> +int virtio_feature_negotiate(struct virtio_device *dev)
>  {
> -	int err, i;
> -	struct virtio_device *dev = dev_to_virtio(_d);
>  	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
> +	int i;
>  	u32 device_features;
>  
>  	/* We have a driver! */
> @@ -134,7 +133,8 @@ static int virtio_dev_probe(struct device *_d)
>  	memset(dev->features, 0, sizeof(dev->features));
>  	for (i = 0; i < drv->feature_table_size; i++) {
>  		unsigned int f = drv->feature_table[i];
> -		BUG_ON(f >= 32);
> +		if (f >= 32)
> +			return -EINVAL;
>  		if (device_features & (1 << f))
>  			set_bit(f, dev->features);
>  	}
> @@ -145,7 +145,19 @@ static int virtio_dev_probe(struct device *_d)
>  			set_bit(i, dev->features);
>  
>  	dev->config->finalize_features(dev);
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(virtio_feature_negotiate);
>  
> +static int virtio_dev_probe(struct device *_d)

Need another patch for this.
> +{
> +	int err;
> +	struct virtio_device *dev = dev_to_virtio(_d);
> +	struct virtio_driver *drv = drv_to_virtio(dev->dev.driver);
> +
> +	err = virtio_feature_negotiate(dev);
> +	if (err)
> +		return err;
>  	err = drv->probe(dev);
>  	if (err)
>  		add_status(dev, VIRTIO_CONFIG_S_FAILED);
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index b46671e..49d8ab4 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -98,6 +98,8 @@ struct virtio_device {
>  	void *priv;
>  };
>  
> +int virtio_feature_negotiate(struct virtio_device *dev);
> +
>  static inline struct virtio_device *dev_to_virtio(struct device *_dev)
>  {
>  	return container_of(_dev, struct virtio_device, dev);
> diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
> index 172a7f0..1f31f90 100644
> --- a/include/uapi/linux/virtio_net.h
> +++ b/include/uapi/linux/virtio_net.h
> @@ -201,4 +201,13 @@ struct virtio_net_ctrl_mq {
>   #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MIN        1
>   #define VIRTIO_NET_CTRL_MQ_VQ_PAIRS_MAX        0x8000
>  
> + /*
> +  * Control Loopback(5 is used by VIRTIO_NET_CTRL_GUEST_OFFLOADS in latest qemu)
> +  *
> +  * The command VIRTIO_NET_CTRL_LOOPBACK_SET is used to require the device come
> +  * into loopback state.
> +  */
> +#define VIRTIO_NET_CTRL_LOOPBACK   6
> + #define VIRTIO_NET_CTRL_LOOPBACK_SET        0
> + #define VIRTIO_NET_CTRL_LOOPBACK_UNSET        1
>  #endif /* _LINUX_VIRTIO_NET_H */

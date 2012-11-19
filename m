From: Jason Wang <jasowang@redhat.com>
Subject: Re: [rfc net-next v6 2/3] virtio_net: multiqueue support
Date: Mon, 19 Nov 2012 15:40:30 +0800
Message-ID: <50A9E26E.3070305@redhat.com>
References: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
	<1351591403-23065-3-git-send-email-jasowang@redhat.com>
	<87y5igyhyg.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87y5igyhyg.fsf@rustcorp.com.au>
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

On 11/05/2012 09:08 AM, Rusty Russell wrote:
> Jason Wang <jasowang@redhat.com> writes:
>> +struct virtnet_info {
>> +	u16 num_queue_pairs;		/* # of RX/TX vq pairs */
>> +	u16 total_queue_pairs;
>> +
>> +	struct send_queue *sq;
>> +	struct receive_queue *rq;
>> +	struct virtqueue *cvq;
>> +
>> +	struct virtio_device *vdev;
>> +	struct net_device *dev;
>> +	unsigned int status;
> status seems unused?
>

It's used for tacking the status of the device (e.g in 
virtnet_config_changed_work() ).
>> +static const struct ethtool_ops virtnet_ethtool_ops;
> Strange hoist, but I can't tell from the patch if this is necessary.
> Assume it is.

Sorry, this line should belong to patch 3/3.
>
>> +static inline int vq2txq(struct virtqueue *vq)
>> +{
>> +	int index = virtqueue_get_queue_index(vq);
>> +	return index == 1 ? 0 : (index - 3) / 2;
>> +}
>> +
>> +static inline int txq2vq(int txq)
>> +{
>> +	return txq ? 2 * txq + 3 : 1;
>> +}
>> +
>> +static inline int vq2rxq(struct virtqueue *vq)
>> +{
>> +	int index = virtqueue_get_queue_index(vq);
>> +	return index ? (index - 2) / 2 : 0;
>> +}
>> +
>> +static inline int rxq2vq(int rxq)
>> +{
>> +	return rxq ? 2 * rxq + 2 : 0;
>> +}
>> +
>>   static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
> I know skb_vnet_hdr() does it, but I generally dislike inline in C
> files; gcc is generally smart enough these days, and inline suppresses
> unused function warnings.

Ok, I will remove the inline here.
> I guess these mappings have to work even when we're switching from mq to
> single queue mode; otherwise we could simplify them using a 'bool mq'
> flag.

Yes, it still work when switching to sq. And what makes it looks strange 
is because we reserve the virtqueues for single queue mode and also 
reserve vq 3. But it does not bring much benefit, need more thought.
>
>> +static int virtnet_set_queues(struct virtnet_info *vi)
>> +{
>> +	struct scatterlist sg;
>> +	struct virtio_net_ctrl_steering s;
>> +	struct net_device *dev = vi->dev;
>> +
>> +	if (vi->num_queue_pairs == 1) {
>> +		s.current_steering_rule = VIRTIO_NET_CTRL_STEERING_SINGLE;
>> +		s.current_steering_param = 1;
>> +	} else {
>> +		s.current_steering_rule =
>> +			VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX;
>> +		s.current_steering_param = vi->num_queue_pairs;
>> +	}
> (BTW, VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX etc not defined anywhere?)

It's defined in include/uapi/linux/virtio_net.h
>
> Hmm, it's not clear that anything other than RX_FOLLOWS_TX will ever
> make sense, so this is really just turning mq on and off.

Currently, when multiqueue is enabled for tuntap, it does tx follow rx. 
So when guest driver specify the RX_FOLLOWS_TX, qemu would just enable 
multiqueue for tuntap and this policy could be done by tuntap.
>
> Unfortunately, we can't turn feature bits on and off after startup, so
> if we want this level of control (and I think we do), there does need to
> be a mechanism.
>
> Michael?  I'd prefer this to be further simplfied, to just
> disable/enable.  We can extend it later, but for now the second
> parameter is redundant, ie.:
>
>          struct virtio_net_ctrl_steering {
>                  u8 mode; /* 0 == off, 1 == on */
>          } __attribute__((packed));
>

We may need more policy in the future, so maybe a 
VIRTIO_NET_CTRL_STEERING_NONE is ok?
>> @@ -924,11 +1032,10 @@ static void virtnet_get_ringparam(struct net_device *dev,
>>   {
>>   	struct virtnet_info *vi = netdev_priv(dev);
>>   
>> -	ring->rx_max_pending = virtqueue_get_vring_size(vi->rvq);
>> -	ring->tx_max_pending = virtqueue_get_vring_size(vi->svq);
>> +	ring->rx_max_pending = virtqueue_get_vring_size(vi->rq[0].vq);
>> +	ring->tx_max_pending = virtqueue_get_vring_size(vi->sq[0].vq);
>>   	ring->rx_pending = ring->rx_max_pending;
>>   	ring->tx_pending = ring->tx_max_pending;
>> -
>>   }
> This assumes all vqs are the same size.  I think this should probably
> check: for mq mode, use the first vq, otherewise use the 0th.

Ok, but I don't see the reason that we need different size for mq.
>
> For bonus points, check this assertion at probe time.
>
>> +	/*
>> +	 * We expect 1 RX virtqueue followed by 1 TX virtqueue, followd by
>> +	 * possible control virtqueue, followed by 1 reserved vq, followed
>> +	 * by RX/TX queue pairs used in multiqueue mode.
>> +	 */
>> +	if (vi->total_queue_pairs == 1)
>> +		total_vqs = 2 + virtio_has_feature(vi->vdev,
>> +						   VIRTIO_NET_F_CTRL_VQ);
>> +	else
>> +		total_vqs = 2 * vi->total_queue_pairs + 2;
> What's the allergy to odd numbers?  Why the reserved queue?

It was suggested by Michael to let the vq calculation easier, but it 
seems does not help much. So it's better not reserve virtqueue in next 
version.
>> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>> +		vi->has_cvq = true;
>> +
>> +	/* Use single tx/rx queue pair as default */
>> +	vi->num_queue_pairs = 1;
>> +	vi->total_queue_pairs = num_queue_pairs;
>> +
>> +	/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
>> +	err = virtnet_setup_vqs(vi);
>>   	if (err)
>>   		goto free_stats;
>>   
>> +	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) &&
>> +	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
>> +		dev->features |= NETIF_F_HW_VLAN_FILTER;
> We should be using has_cvq here...

Sure.
>
>> -#ifdef CONFIG_PM
>> -static int virtnet_freeze(struct virtio_device *vdev)
>> +static void virtnet_stop(struct virtnet_info *vi)
> I think you still want this under CONFIG_PM, right?  Doesn't seem used
> elsewhere.

Yes, will fix this.
>
> Cheers,
> Rusty.
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

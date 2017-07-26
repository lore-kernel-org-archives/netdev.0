From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2 5/5] virtio-net: switch off offloads on demand
 if possible on XDP set
Date: Wed, 26 Jul 2017 11:19:47 +0800
Message-ID: <2a9b8132-4438-bf65-6421-b6b3b4630cb4@redhat.com>
References: <1500454489-16805-1-git-send-email-jasowang@redhat.com>
 <1500454489-16805-6-git-send-email-jasowang@redhat.com>
 <20170725002700-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170725002700-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年07月25日 05:29, Michael S. Tsirkin wrote:
> On Wed, Jul 19, 2017 at 04:54:49PM +0800, Jason Wang wrote:
>> Current XDP implementation wants guest offloads feature to be disabled
>> on device. This is inconvenient and means guest can't benefit from
>> offloads if XDP is not used. This patch tries to address this
>> limitation by disabling the offloads on demand through control guest
>> offloads. Guest offloads will be disabled and enabled on demand on XDP
>> set.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Doesn't look like my comments on v1 were addressed.
> Copying here:
>
> In fact, since we no longer reset when XDP is set,
> here device might have offloads enabled, buffers are
> used but not consumed, then XDP is set.
>
> This can result in
> - packet scattered across multiple buffers
>    (handled correctly but need to update the comment)

We drop all gso packet now, so this won't happen.

> - packet may have VIRTIO_NET_HDR_F_NEEDS_CSUM, in that case
>    the spec says "The checksum on the packet is incomplete".
>    (probably needs to be handled by calculating the checksum).

This needs to be fixed, but it was not introduced by this commit but:

b00f70b0dacb virtio-net: unbreak csumed packets for XDP_PASS which 
allows NEEDS_CSUM for mergeable buffer
bb91accf2733 virtio-net: XDP support for small buffers which forbid 
checksumed packet for small buffer

Will post a patch to checksum the packet.

Thanks

>
> Jason, as David applied this patch already, can you comment
> on the issues please?
>
>> ---
>>   drivers/net/virtio_net.c | 70 ++++++++++++++++++++++++++++++++++++++++++++----
>>   1 file changed, 65 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index b3fc01d..5fbd15e 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -57,6 +57,11 @@ DECLARE_EWMA(pkt_len, 0, 64)
>>   
>>   #define VIRTNET_DRIVER_VERSION "1.0.0"
>>   
>> +const unsigned long guest_offloads[] = { VIRTIO_NET_F_GUEST_TSO4,
>> +					 VIRTIO_NET_F_GUEST_TSO6,
>> +					 VIRTIO_NET_F_GUEST_ECN,
>> +					 VIRTIO_NET_F_GUEST_UFO };
>> +
>>   struct virtnet_stats {
>>   	struct u64_stats_sync tx_syncp;
>>   	struct u64_stats_sync rx_syncp;
>> @@ -164,10 +169,13 @@ struct virtnet_info {
>>   	u8 ctrl_promisc;
>>   	u8 ctrl_allmulti;
>>   	u16 ctrl_vid;
>> +	u64 ctrl_offloads;
>>   
>>   	/* Ethtool settings */
>>   	u8 duplex;
>>   	u32 speed;
>> +
>> +	unsigned long guest_offloads;
>>   };
>>   
>>   struct padded_vnet_hdr {
>> @@ -1896,6 +1904,47 @@ static int virtnet_restore_up(struct virtio_device *vdev)
>>   	return err;
>>   }
>>   
>> +static int virtnet_set_guest_offloads(struct virtnet_info *vi, u64 offloads)
>> +{
>> +	struct scatterlist sg;
>> +	vi->ctrl_offloads = cpu_to_virtio64(vi->vdev, offloads);
>> +
>> +	sg_init_one(&sg, &vi->ctrl_offloads, sizeof(vi->ctrl_offloads));
>> +
>> +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_GUEST_OFFLOADS,
>> +				  VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET, &sg)) {
>> +		dev_warn(&vi->dev->dev, "Fail to set guest offload. \n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static int virtnet_clear_guest_offloads(struct virtnet_info *vi)
>> +{
>> +	u64 offloads = 0;
>> +
>> +	if (!vi->guest_offloads)
>> +		return 0;
>> +
>> +	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_CSUM))
>> +		offloads = 1ULL << VIRTIO_NET_F_GUEST_CSUM;
>> +
>> +	return virtnet_set_guest_offloads(vi, offloads);
>> +}
>> +
>> +static int virtnet_restore_guest_offloads(struct virtnet_info *vi)
>> +{
>> +	u64 offloads = vi->guest_offloads;
>> +
>> +	if (!vi->guest_offloads)
>> +		return 0;
>> +	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_CSUM))
>> +		offloads |= 1ULL << VIRTIO_NET_F_GUEST_CSUM;
>> +
>> +	return virtnet_set_guest_offloads(vi, offloads);
>> +}
>> +
>>   static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
>>   			   struct netlink_ext_ack *extack)
>>   {
>> @@ -1905,10 +1954,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
>>   	u16 xdp_qp = 0, curr_qp;
>>   	int i, err;
>>   
>> -	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
>> -	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
>> -	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||
>> -	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_UFO)) {
>> +	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS)
>> +	    && (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
>> +	        virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
>> +	        virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||
>> +		virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_UFO))) {
>>   		NL_SET_ERR_MSG_MOD(extack, "Can't set XDP while host is implementing LRO, disable LRO first");
>>   		return -EOPNOTSUPP;
>>   	}
>> @@ -1955,6 +2005,12 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
>>   	for (i = 0; i < vi->max_queue_pairs; i++) {
>>   		old_prog = rtnl_dereference(vi->rq[i].xdp_prog);
>>   		rcu_assign_pointer(vi->rq[i].xdp_prog, prog);
>> +		if (i == 0) {
>> +			if (!old_prog)
>> +				virtnet_clear_guest_offloads(vi);
>> +			if (!prog)
>> +				virtnet_restore_guest_offloads(vi);
>> +		}
>>   		if (old_prog)
>>   			bpf_prog_put(old_prog);
>>   		virtnet_napi_enable(vi->rq[i].vq, &vi->rq[i].napi);
>> @@ -2588,6 +2644,10 @@ static int virtnet_probe(struct virtio_device *vdev)
>>   		netif_carrier_on(dev);
>>   	}
>>   
>> +	for (i = 0; i < ARRAY_SIZE(guest_offloads); i++)
>> +		if (virtio_has_feature(vi->vdev, guest_offloads[i]))
>> +			set_bit(guest_offloads[i], &vi->guest_offloads);
>> +
>>   	pr_debug("virtnet: registered device %s with %d RX and TX vq's\n",
>>   		 dev->name, max_queue_pairs);
>>   
>> @@ -2684,7 +2744,7 @@ static struct virtio_device_id id_table[] = {
>>   	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, \
>>   	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ, \
>>   	VIRTIO_NET_F_CTRL_MAC_ADDR, \
>> -	VIRTIO_NET_F_MTU
>> +	VIRTIO_NET_F_MTU, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS
>>   
>>   static unsigned int features[] = {
>>   	VIRTNET_FEATURES,
>> -- 
>> 2.7.4

From: Jason Wang <jasowang@redhat.com>
Subject: Re: [V2 RFC net-next PATCH 2/2] virtio_net: export more statistics
	through ethtool
Date: Wed, 06 Jun 2012 17:37:24 +0800
Message-ID: <4FCF24D4.5000209@redhat.com>
References: <20120606075208.29081.75284.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120606075217.29081.30713.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120606082752.GA12767@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120606082752.GA12767@redhat.com>
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

On 06/06/2012 04:27 PM, Michael S. Tsirkin wrote:
> On Wed, Jun 06, 2012 at 03:52:17PM +0800, Jason Wang wrote:
>> Satistics counters is useful for debugging and performance optimization, so this
>> patch lets virtio_net driver collect following and export them to userspace
>> through "ethtool -S":
>>
>> - number of packets sent/received
>> - number of bytes sent/received
>> - number of callbacks for tx/rx
>> - number of kick for tx/rx
>> - number of bytes/packets queued for tx
>>
>> As virtnet_stats were per-cpu, so both per-cpu and gloabl satistics were
>> collected like:
>>
>> NIC statistics:
>>       tx_bytes[0]: 1731209929
>>       tx_packets[0]: 60685
>>       tx_kicks[0]: 63
>>       tx_callbacks[0]: 73
>>       tx_queued_bytes[0]: 1935749360
>>       tx_queued_packets[0]: 80652
>>       rx_bytes[0]: 2695648
>>       rx_packets[0]: 40767
>>       rx_kicks[0]: 1
>>       rx_callbacks[0]: 2077
>>       tx_bytes[1]: 9105588697
>>       tx_packets[1]: 344150
>>       tx_kicks[1]: 162
>>       tx_callbacks[1]: 905
>>       tx_queued_bytes[1]: 8901049412
>>       tx_queued_packets[1]: 324184
>>       rx_bytes[1]: 23679828
>>       rx_packets[1]: 358770
>>       rx_kicks[1]: 6
>>       rx_callbacks[1]: 17717
>>       tx_bytes: 10836798626
>>       tx_packets: 404835
>>       tx_kicks: 225
>>       tx_callbacks: 978
>>       tx_queued_bytes: 10836798772
>>       tx_queued_packets: 404836
>>       rx_bytes: 26375476
>>       rx_packets: 399537
>>       rx_kicks: 7
>>       rx_callbacks: 19794
>>
>> TODO:
>>
>> - more statistics
>> - calculate the pending bytes/pkts
>>
> Do we need that? pending is (queued - packets), no?
>   

No, if we choose to calculate by tools.
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>>
>> ---
>> Changes from v1:
>>
>> - style&  typo fixs
>> - convert the statistics fields to array
>> - use unlikely()
>> ---
>>   drivers/net/virtio_net.c |  115 +++++++++++++++++++++++++++++++++++++++++++++-
>>   1 files changed, 113 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 6e4aa6f..909a0a7 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -44,8 +44,14 @@ module_param(gso, bool, 0444);
>>   enum virtnet_stats_type {
>>   	VIRTNET_TX_BYTES,
>>   	VIRTNET_TX_PACKETS,
>> +	VIRTNET_TX_KICKS,
>> +	VIRTNET_TX_CBS,
>> +	VIRTNET_TX_Q_BYTES,
>> +	VIRTNET_TX_Q_PACKETS,
>>   	VIRTNET_RX_BYTES,
>>   	VIRTNET_RX_PACKETS,
>> +	VIRTNET_RX_KICKS,
>> +	VIRTNET_RX_CBS,
>>   	VIRTNET_NUM_STATS,
>>   };
>>
>> @@ -54,6 +60,21 @@ struct virtnet_stats {
>>   	u64 data[VIRTNET_NUM_STATS];
>>   };
>>
>> +static struct {
> static const?
>

Sorry, forget this.
>> +	char string[ETH_GSTRING_LEN];
>> +} virtnet_stats_str_attr[] = {
>> +	{ "tx_bytes" },
>> +	{ "tx_packets" },
>> +	{ "tx_kicks" },
>> +	{ "tx_callbacks" },
>> +	{ "tx_queued_bytes" },
>> +	{ "tx_queued_packets" },
>> +	{ "rx_bytes" },
>> +	{ "rx_packets" },
>> +	{ "rx_kicks" },
>> +	{ "rx_callbacks" },
>> +};
>> +
>>   struct virtnet_info {
>>   	struct virtio_device *vdev;
>>   	struct virtqueue *rvq, *svq, *cvq;
>> @@ -146,6 +167,11 @@ static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
>>   static void skb_xmit_done(struct virtqueue *svq)
>>   {
>>   	struct virtnet_info *vi = svq->vdev->priv;
>> +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> +
>> +	u64_stats_update_begin(&stats->syncp);
>> +	stats->data[VIRTNET_TX_CBS]++;
>> +	u64_stats_update_end(&stats->syncp);
>>
>>   	/* Suppress further interrupts. */
>>   	virtqueue_disable_cb(svq);
>> @@ -465,6 +491,7 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
>>   {
>>   	int err;
>>   	bool oom;
>> +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>>
>>   	do {
>>   		if (vi->mergeable_rx_bufs)
>> @@ -481,13 +508,24 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
>>   	} while (err>  0);
>>   	if (unlikely(vi->num>  vi->max))
>>   		vi->max = vi->num;
>> -	virtqueue_kick(vi->rvq);
>> +	if (virtqueue_kick_prepare(vi->rvq)) {
> if (unlikely())
> also move stats here where they are actually used?

Sure.
>> +		virtqueue_notify(vi->rvq);
>> +		u64_stats_update_begin(&stats->syncp);
>> +		stats->data[VIRTNET_RX_KICKS]++;
>> +		u64_stats_update_end(&stats->syncp);
>> +	}
>>   	return !oom;
>>   }
>>
>>   static void skb_recv_done(struct virtqueue *rvq)
>>   {
>>   	struct virtnet_info *vi = rvq->vdev->priv;
>> +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> +
>> +	u64_stats_update_begin(&stats->syncp);
>> +	stats->data[VIRTNET_RX_CBS]++;
>> +	u64_stats_update_end(&stats->syncp);
>> +
>>   	/* Schedule NAPI, Suppress further interrupts if successful. */
>>   	if (napi_schedule_prep(&vi->napi)) {
>>   		virtqueue_disable_cb(rvq);
>> @@ -630,7 +668,9 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
>>   static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>>   {
>>   	struct virtnet_info *vi = netdev_priv(dev);
>> +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>>   	int capacity;
>> +	bool kick;
>>
>>   	/* Free up any pending old buffers before queueing new ones. */
>>   	free_old_xmit_skbs(vi);
>> @@ -655,7 +695,17 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>>   		kfree_skb(skb);
>>   		return NETDEV_TX_OK;
>>   	}
>> -	virtqueue_kick(vi->svq);
>> +
>> +	kick = virtqueue_kick_prepare(vi->svq);
>> +	if (unlikely(kick))
>> +		virtqueue_notify(vi->svq);
>> +
>> +	u64_stats_update_begin(&stats->syncp);
>> +	if (unlikely(kick))
>> +		stats->data[VIRTNET_TX_KICKS]++;
>> +	stats->data[VIRTNET_TX_Q_BYTES] += skb->len;
>> +	stats->data[VIRTNET_TX_Q_PACKETS]++;
>> +	u64_stats_update_end(&stats->syncp);
>>
>>   	/* Don't wait up for transmitted skbs to be freed. */
>>   	skb_orphan(skb);
>> @@ -943,10 +993,71 @@ static void virtnet_get_drvinfo(struct net_device *dev,
>>
>>   }
>>
>> +static void virtnet_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
>> +{
>> +	int i, cpu;
>> +	switch (stringset) {
>> +	case ETH_SS_STATS:
>> +		for_each_possible_cpu(cpu)
>> +			for (i = 0; i<  VIRTNET_NUM_STATS; i++) {
>> +				sprintf(buf, "%s[%u]",
>> +					virtnet_stats_str_attr[i].string, cpu);
>> +				buf += ETH_GSTRING_LEN;
> I would do
> 	 ret = snprintf(buf, ETH_GSTRING_LEN, ...)
> 	 BUG_ON(ret>= ETH_GSTRING_LEN);
> here to make it more robust.

Ok.
>> +			}
>> +		for (i = 0; i<  VIRTNET_NUM_STATS; i++) {
>> +			memcpy(buf, virtnet_stats_str_attr[i].string,
>> +				ETH_GSTRING_LEN);
>> +			buf += ETH_GSTRING_LEN;
>> +		}
> 		So why not just memcpy the whole array there?
> 		memcpy(buf, virtnet_stats_str_attr,
> 		       sizeof virtnet_stats_str_attr);
>
>> +		break;
>> +	}
>> +}
>> +
>> +static int virtnet_get_sset_count(struct net_device *dev, int sset)
>> +{
>> +	switch (sset) {
>> +	case ETH_SS_STATS:
> also add
> 	BUILD_BUG_ON(VIRTNET_NUM_STATS != (sizeof virtnet_stats_str_attr) / ETH_GSTRING_LEN);
>

Ok.
>> +		return VIRTNET_NUM_STATS * (num_possible_cpus() + 1);
>> +	default:
>> +		return -EOPNOTSUPP;
>> +	}
>> +}
>> +
>> +static void virtnet_get_ethtool_stats(struct net_device *dev,
>> +				      struct ethtool_stats *stats, u64 *buf)
>> +{
>> +	struct virtnet_info *vi = netdev_priv(dev);
>> +	int cpu, i;
>> +	unsigned int start;
>> +	struct virtnet_stats sample, total;
>> +
>> +	memset(&total, 0, sizeof(total));
> sizeof total
> when operand is a variable,
> to distinguish from when it is a type.

Sure.
>> +
>> +	for_each_possible_cpu(cpu) {
>> +		struct virtnet_stats *s = per_cpu_ptr(vi->stats, cpu);
>> +		do {
>> +			start = u64_stats_fetch_begin(&s->syncp);
>> +			memcpy(&sample.data,&s->data,
>> +			       sizeof(u64) * VIRTNET_NUM_STATS);
>> +		} while (u64_stats_fetch_retry(&s->syncp, start));
>> +
>> +		for (i = 0; i<  VIRTNET_NUM_STATS; i++) {
>> +			*buf = sample.data[i];
>> +			total.data[i] += sample.data[i];
>> +			buf++;
>> +		}
>> +	}
>> +
>> +	memcpy(buf,&total.data, sizeof(u64) * VIRTNET_NUM_STATS);
>> +}
>> +
>>   static const struct ethtool_ops virtnet_ethtool_ops = {
>>   	.get_drvinfo = virtnet_get_drvinfo,
>>   	.get_link = ethtool_op_get_link,
>>   	.get_ringparam = virtnet_get_ringparam,
>> +	.get_ethtool_stats = virtnet_get_ethtool_stats,
>> +	.get_strings = virtnet_get_strings,
>> +	.get_sset_count = virtnet_get_sset_count,
>>   };
>>
>>   #define MIN_MTU 68

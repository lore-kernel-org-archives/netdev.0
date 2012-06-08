From: Jason Wang <jasowang@redhat.com>
Subject: Re: [V2 RFC net-next PATCH 2/2] virtio_net: export more statistics
	through ethtool
Date: Fri, 08 Jun 2012 11:35:25 +0800
Message-ID: <4FD172FD.5070200@redhat.com>
References: <20120606075208.29081.75284.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120606075217.29081.30713.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120607221911.GD16235@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120607221911.GD16235@redhat.com>
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

On 06/08/2012 06:19 AM, Michael S. Tsirkin wrote:
> On Wed, Jun 06, 2012 at 03:52:17PM +0800, Jason Wang wrote:
>> >  Satistics counters is useful for debugging and performance optimization, so this
>> >  patch lets virtio_net driver collect following and export them to userspace
>> >  through "ethtool -S":
>> >  
>> >  - number of packets sent/received
>> >  - number of bytes sent/received
>> >  - number of callbacks for tx/rx
>> >  - number of kick for tx/rx
>> >  - number of bytes/packets queued for tx
>> >  
>> >  As virtnet_stats were per-cpu, so both per-cpu and gloabl satistics were
>> >  collected like:
>> >  
>> >  NIC statistics:
>> >        tx_bytes[0]: 1731209929
>> >        tx_packets[0]: 60685
>> >        tx_kicks[0]: 63
>> >        tx_callbacks[0]: 73
>> >        tx_queued_bytes[0]: 1935749360
>> >        tx_queued_packets[0]: 80652
>> >        rx_bytes[0]: 2695648
>> >        rx_packets[0]: 40767
>> >        rx_kicks[0]: 1
>> >        rx_callbacks[0]: 2077
>> >        tx_bytes[1]: 9105588697
>> >        tx_packets[1]: 344150
>> >        tx_kicks[1]: 162
>> >        tx_callbacks[1]: 905
>> >        tx_queued_bytes[1]: 8901049412
>> >        tx_queued_packets[1]: 324184
>> >        rx_bytes[1]: 23679828
>> >        rx_packets[1]: 358770
>> >        rx_kicks[1]: 6
>> >        rx_callbacks[1]: 17717
>> >        tx_bytes: 10836798626
>> >        tx_packets: 404835
>> >        tx_kicks: 225
>> >        tx_callbacks: 978
>> >        tx_queued_bytes: 10836798772
>> >        tx_queued_packets: 404836
>> >        rx_bytes: 26375476
>> >        rx_packets: 399537
>> >        rx_kicks: 7
>> >        rx_callbacks: 19794
>> >  
>> >  TODO:
>> >  
>> >  - more statistics
>> >  - calculate the pending bytes/pkts
>> >  
>> >  Signed-off-by: Jason Wang<jasowang@redhat.com>
>> >  
>> >  ---
>> >  Changes from v1:
>> >  
>> >  - style&  typo fixs
>> >  - convert the statistics fields to array
>> >  - use unlikely()
>> >  ---
>> >    drivers/net/virtio_net.c |  115 +++++++++++++++++++++++++++++++++++++++++++++-
>> >    1 files changed, 113 insertions(+), 2 deletions(-)
>> >  
>> >  diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> >  index 6e4aa6f..909a0a7 100644
>> >  --- a/drivers/net/virtio_net.c
>> >  +++ b/drivers/net/virtio_net.c
>> >  @@ -44,8 +44,14 @@ module_param(gso, bool, 0444);
>> >    enum virtnet_stats_type {
>> >    	VIRTNET_TX_BYTES,
>> >    	VIRTNET_TX_PACKETS,
>> >  +	VIRTNET_TX_KICKS,
>> >  +	VIRTNET_TX_CBS,
>> >  +	VIRTNET_TX_Q_BYTES,
>> >  +	VIRTNET_TX_Q_PACKETS,
>> >    	VIRTNET_RX_BYTES,
>> >    	VIRTNET_RX_PACKETS,
>> >  +	VIRTNET_RX_KICKS,
>> >  +	VIRTNET_RX_CBS,
>> >    	VIRTNET_NUM_STATS,
>> >    };
>> >  
>> >  @@ -54,6 +60,21 @@ struct virtnet_stats {
>> >    	u64 data[VIRTNET_NUM_STATS];
>> >    };
>> >  
>> >  +static struct {
>> >  +	char string[ETH_GSTRING_LEN];
>> >  +} virtnet_stats_str_attr[] = {
>> >  +	{ "tx_bytes" },
>> >  +	{ "tx_packets" },
>> >  +	{ "tx_kicks" },
>> >  +	{ "tx_callbacks" },
>> >  +	{ "tx_queued_bytes" },
>> >  +	{ "tx_queued_packets" },
>> >  +	{ "rx_bytes" },
>> >  +	{ "rx_packets" },
>> >  +	{ "rx_kicks" },
>> >  +	{ "rx_callbacks" },
>> >  +};
>> >  +
>> >    struct virtnet_info {
>> >    	struct virtio_device *vdev;
>> >    	struct virtqueue *rvq, *svq, *cvq;
>> >  @@ -146,6 +167,11 @@ static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
>> >    static void skb_xmit_done(struct virtqueue *svq)
>> >    {
>> >    	struct virtnet_info *vi = svq->vdev->priv;
>> >  +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> >  +
>> >  +	u64_stats_update_begin(&stats->syncp);
>> >  +	stats->data[VIRTNET_TX_CBS]++;
>> >  +	u64_stats_update_end(&stats->syncp);
>> >  
>> >    	/* Suppress further interrupts. */
>> >    	virtqueue_disable_cb(svq);
>> >  @@ -465,6 +491,7 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
>> >    {
>> >    	int err;
>> >    	bool oom;
>> >  +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> >  
>> >    	do {
>> >    		if (vi->mergeable_rx_bufs)
>> >  @@ -481,13 +508,24 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
>> >    	} while (err>  0);
>> >    	if (unlikely(vi->num>  vi->max))
>> >    		vi->max = vi->num;
>> >  -	virtqueue_kick(vi->rvq);
>> >  +	if (virtqueue_kick_prepare(vi->rvq)) {
>> >  +		virtqueue_notify(vi->rvq);
>> >  +		u64_stats_update_begin(&stats->syncp);
>> >  +		stats->data[VIRTNET_RX_KICKS]++;
>> >  +		u64_stats_update_end(&stats->syncp);
>> >  +	}
>> >    	return !oom;
>> >    }
>> >  
>> >    static void skb_recv_done(struct virtqueue *rvq)
>> >    {
>> >    	struct virtnet_info *vi = rvq->vdev->priv;
>> >  +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> >  +
>> >  +	u64_stats_update_begin(&stats->syncp);
>> >  +	stats->data[VIRTNET_RX_CBS]++;
>> >  +	u64_stats_update_end(&stats->syncp);
>> >  +
>> >    	/* Schedule NAPI, Suppress further interrupts if successful. */
>> >    	if (napi_schedule_prep(&vi->napi)) {
>> >    		virtqueue_disable_cb(rvq);
>> >  @@ -630,7 +668,9 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
>> >    static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>> >    {
>> >    	struct virtnet_info *vi = netdev_priv(dev);
>> >  +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> >    	int capacity;
>> >  +	bool kick;
>> >  
>> >    	/* Free up any pending old buffers before queueing new ones. */
>> >    	free_old_xmit_skbs(vi);
>> >  @@ -655,7 +695,17 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>> >    		kfree_skb(skb);
>> >    		return NETDEV_TX_OK;
>> >    	}
>> >  -	virtqueue_kick(vi->svq);
>> >  +
>> >  +	kick = virtqueue_kick_prepare(vi->svq);
>> >  +	if (unlikely(kick))
>> >  +		virtqueue_notify(vi->svq);
>> >  +
>> >  +	u64_stats_update_begin(&stats->syncp);
>> >  +	if (unlikely(kick))
>> >  +		stats->data[VIRTNET_TX_KICKS]++;
>> >  +	stats->data[VIRTNET_TX_Q_BYTES] += skb->len;
>> >  +	stats->data[VIRTNET_TX_Q_PACKETS]++;
> is this statistic interesting?
> how about decrementing when we free?
> this way we see how many are pending..
>

Currently we didn't have per-vq statistics but per-cpu, so the skb could 
be sent by one vcpu and freed by another.
Pehaps another reason to use per-queue satistics.

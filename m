From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: Reporting traffic queue distribution
	statistics through ethtool
Date: Thu, 11 Jul 2013 19:33:31 +0300
Message-ID: <20130711163330.GA23092@redhat.com>
References: <1368735869-31076-1-git-send-email-sriram.narasimhan@hp.com>
	<20130519112800.GG19883@redhat.com>
	<228BD1969E90E94D8805535E22CE8EFF063CF133@G9W0717.americas.hpqcorp.net>
	<20130519200320.GA27407@redhat.com>
	<228BD1969E90E94D8805535E22CE8EFF063CF195@G9W0717.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: "Narasimhan, Sriram" <sriram.narasimhan@hp.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <228BD1969E90E94D8805535E22CE8EFF063CF195@G9W0717.americas.hpqcorp.net>
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

On Sun, May 19, 2013 at 10:56:16PM +0000, Narasimhan, Sriram wrote:
> Hi Michael,
> 
> Comments inline...
> 
> -----Original Message-----
> From: Michael S. Tsirkin [mailto:mst@redhat.com] 
> Sent: Sunday, May 19, 2013 1:03 PM
> To: Narasimhan, Sriram
> Cc: rusty@rustcorp.com.au; virtualization@lists.linux-foundation.org; kvm@vger.kernel.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jason Wang
> Subject: Re: [PATCH] virtio-net: Reporting traffic queue distribution statistics through ethtool
> 
> On Sun, May 19, 2013 at 04:09:48PM +0000, Narasimhan, Sriram wrote:
> > Hi Michael,
> > 
> > I was getting all packets on the same inbound queue which
> > is why I added this support to virtio-net (and some more
> > instrumentation at tun as well).  But, it turned out to be
> > my misconfiguration - I did not enable IFF_MULTI_QUEUE on
> > the tap device, so the real_num_tx_queues on tap netdev was 
> > always 1 (no tx distribution at tap).
> 
> Interesting that qemu didn't fail.
> 
> [Sriram] void tun_set_real_num_tx_queues() does not return 
> the EINVAL return from netif_set_real_num_tx_queues() for 
> txq > dev->num_tx_queues (which would be the case if the
> tap device were not created with IFF_MULTI_QUEUE).  I think
> it would be better to fix the code to disable the new 
> queue and fail tun_attach() in this scenario.  If you 
> agree, I can go ahead and create a separate patch for that.
>    
> 
> > I am thinking about 
> > adding a -q option to tunctl to specify multi-queue flag on
> > the tap device.
> 
> Absolutely.
> 
> [Sriram] OK, let me do that.
> 
> > Yes, number of exits will be most useful.  I will look into
> > adding the other statistics you mention.
> > 
> > Sriram  
> 
> Pls note you'll need to switch to virtqueue_kick_prepare
> to detect exits: virtqueue_kick doesn't let you know
> whether there was an exit.
> 
> Also, it's best to make this a separate patch from the one
> adding per-queue stats.
> 
> [Sriram] OK, I will cover only the per-queue statistics in
> this patch. Also, I will address the indentation/data 
> structure name points that you mentioned in your earlier
> email and send a new revision for this patch.
> 
> Sriram

Still plan to look into this?
Might be nice to have for 3.12.


> > -----Original Message-----
> > From: Michael S. Tsirkin [mailto:mst@redhat.com] 
> > Sent: Sunday, May 19, 2013 4:28 AM
> > To: Narasimhan, Sriram
> > Cc: rusty@rustcorp.com.au; virtualization@lists.linux-foundation.org; kvm@vger.kernel.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> > Subject: Re: [PATCH] virtio-net: Reporting traffic queue distribution statistics through ethtool
> > 
> > On Thu, May 16, 2013 at 01:24:29PM -0700, Sriram Narasimhan wrote:
> > > This patch allows virtio-net driver to report traffic distribution
> > > to inbound/outbound queues through ethtool -S.  The per_cpu
> > > virtnet_stats is split into receive and transmit stats and are
> > > maintained on a per receive_queue and send_queue basis.
> > > virtnet_stats() is modified to aggregate interface level statistics
> > > from per-queue statistics.  Sample output below:
> > > 
> > 
> > Thanks for the patch. The idea itself looks OK to me.
> > Ben Hutchings already sent some comments
> > so I won't repeat them. Some minor more comments
> > and questions below.
> > 
> > > NIC statistics:
> > >      rxq0: rx_packets: 4357802
> > >      rxq0: rx_bytes: 292642052
> > >      txq0: tx_packets: 824540
> > >      txq0: tx_bytes: 55256404
> > >      rxq1: rx_packets: 0
> > >      rxq1: rx_bytes: 0
> > >      txq1: tx_packets: 1094268
> > >      txq1: tx_bytes: 73328316
> > >      rxq2: rx_packets: 0
> > >      rxq2: rx_bytes: 0
> > >      txq2: tx_packets: 1091466
> > >      txq2: tx_bytes: 73140566
> > >      rxq3: rx_packets: 0
> > >      rxq3: rx_bytes: 0
> > >      txq3: tx_packets: 1093043
> > >      txq3: tx_bytes: 73246142
> > 
> > Interesting. This example implies that all packets are coming in
> > through the same RX queue - is this right?
> > If yes that's worth exploring - could be a tun bug -
> > and shows how this patch is useful.
> > 
> > > Signed-off-by: Sriram Narasimhan <sriram.narasimhan@hp.com>
> > 
> > BTW, while you are looking at the stats, one other interesting
> > thing to add could be checking more types of stats: number of exits,
> > queue full errors, etc.
> > 
> > > ---
> > >  drivers/net/virtio_net.c |  157 +++++++++++++++++++++++++++++++++++++---------
> > >  1 files changed, 128 insertions(+), 29 deletions(-)
> > > 
> > > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > > index 3c23fdc..3c58c52 100644
> > > --- a/drivers/net/virtio_net.c
> > > +++ b/drivers/net/virtio_net.c
> > > @@ -41,15 +41,46 @@ module_param(gso, bool, 0444);
> > >  
> > >  #define VIRTNET_DRIVER_VERSION "1.0.0"
> > >  
> > > -struct virtnet_stats {
> > > -	struct u64_stats_sync tx_syncp;
> > > +struct virtnet_rx_stats {
> > >  	struct u64_stats_sync rx_syncp;
> > > -	u64 tx_bytes;
> > > +	u64 rx_packets;
> > > +	u64 rx_bytes;
> > > +};
> > > +
> > > +struct virtnet_tx_stats {
> > > +	struct u64_stats_sync tx_syncp;
> > >  	u64 tx_packets;
> > > +	u64 tx_bytes;
> > > +};
> > >  
> > > -	u64 rx_bytes;
> > > -	u64 rx_packets;
> > 
> > I think maintaining the stats in a per-queue data structure like this is
> > fine.  if # of CPUs == # of queues which is typical, we use same amount
> > of memory.  And each queue access is under a lock,
> > or from napi thread, so no races either.
> > 
> > > +struct virtnet_ethtool_stats {
> > > +	char desc[ETH_GSTRING_LEN];
> > > +	int type;
> > > +	int size;
> > > +	int offset;
> > > +};
> > > +
> > > +enum {VIRTNET_STATS_TX, VIRTNET_STATS_RX};
> > > +
> > > +#define VIRTNET_RX_STATS_INFO(_struct, _field) \
> > > +	{#_field, VIRTNET_STATS_RX, FIELD_SIZEOF(_struct, _field), \
> > > +	offsetof(_struct, _field)}
> > > +
> > > +#define VIRTNET_TX_STATS_INFO(_struct, _field) \
> > > +	{#_field, VIRTNET_STATS_TX, FIELD_SIZEOF(_struct, _field), \
> > > +	offsetof(_struct, _field)}
> > > +
> > > +static const struct virtnet_ethtool_stats virtnet_et_rx_stats[] = {
> > > +	VIRTNET_RX_STATS_INFO(struct virtnet_rx_stats, rx_packets),
> > > +	VIRTNET_RX_STATS_INFO(struct virtnet_rx_stats, rx_bytes)
> > > +};
> > > +#define VIRTNET_RX_STATS_NUM (ARRAY_SIZE(virtnet_et_rx_stats))
> > > +
> > > +static const struct virtnet_ethtool_stats virtnet_et_tx_stats[] = {
> > > +	VIRTNET_TX_STATS_INFO(struct virtnet_tx_stats, tx_packets),
> > > +	VIRTNET_TX_STATS_INFO(struct virtnet_tx_stats, tx_bytes)
> > >  };
> > > +#define VIRTNET_TX_STATS_NUM (ARRAY_SIZE(virtnet_et_tx_stats))
> > 
> > I'd prefer a full name: virtnet_ethtool_tx_stats, or
> > just virtnet_tx_stats.
> > 
> > >  
> > >  /* Internal representation of a send virtqueue */
> > >  struct send_queue {
> > > @@ -61,6 +92,9 @@ struct send_queue {
> > >  
> > >  	/* Name of the send queue: output.$index */
> > >  	char name[40];
> > > +
> > > +	/* Active send queue statistics */
> > > +	struct virtnet_tx_stats stats;
> > >  };
> > >  
> > >  /* Internal representation of a receive virtqueue */
> > > @@ -81,6 +115,9 @@ struct receive_queue {
> > >  
> > >  	/* Name of this receive queue: input.$index */
> > >  	char name[40];
> > > +
> > > +	/* Active receive queue statistics */
> > > +	struct virtnet_rx_stats stats;
> > >  };
> > >  
> > >  struct virtnet_info {
> > > @@ -109,9 +146,6 @@ struct virtnet_info {
> > >  	/* enable config space updates */
> > >  	bool config_enable;
> > >  
> > > -	/* Active statistics */
> > > -	struct virtnet_stats __percpu *stats;
> > > -
> > >  	/* Work struct for refilling if we run low on memory. */
> > >  	struct delayed_work refill;
> > >  
> > > @@ -330,7 +364,7 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
> > >  {
> > >  	struct virtnet_info *vi = rq->vq->vdev->priv;
> > >  	struct net_device *dev = vi->dev;
> > > -	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
> > > +	struct virtnet_rx_stats *stats = &rq->stats;
> > >  	struct sk_buff *skb;
> > >  	struct page *page;
> > >  	struct skb_vnet_hdr *hdr;
> > > @@ -650,8 +684,7 @@ static void free_old_xmit_skbs(struct send_queue *sq)
> > >  {
> > >  	struct sk_buff *skb;
> > >  	unsigned int len;
> > > -	struct virtnet_info *vi = sq->vq->vdev->priv;
> > > -	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
> > > +	struct virtnet_tx_stats *stats = &sq->stats;
> > >  
> > >  	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
> > >  		pr_debug("Sent skb %p\n", skb);
> > > @@ -841,24 +874,25 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
> > >  					       struct rtnl_link_stats64 *tot)
> > >  {
> > >  	struct virtnet_info *vi = netdev_priv(dev);
> > > -	int cpu;
> > > +	int i;
> > >  	unsigned int start;
> > >  
> > > -	for_each_possible_cpu(cpu) {
> > > -		struct virtnet_stats *stats = per_cpu_ptr(vi->stats, cpu);
> > > +	for (i = 0; i < vi->max_queue_pairs; i++) {
> > > +		struct virtnet_tx_stats *tstats = &vi->sq[i].stats;
> > > +		struct virtnet_rx_stats *rstats = &vi->rq[i].stats;
> > >  		u64 tpackets, tbytes, rpackets, rbytes;
> > >  
> > >  		do {
> > > -			start = u64_stats_fetch_begin_bh(&stats->tx_syncp);
> > > -			tpackets = stats->tx_packets;
> > > -			tbytes   = stats->tx_bytes;
> > > -		} while (u64_stats_fetch_retry_bh(&stats->tx_syncp, start));
> > > +			start = u64_stats_fetch_begin_bh(&tstats->tx_syncp);
> > > +			tpackets = tstats->tx_packets;
> > > +			tbytes   = tstats->tx_bytes;
> > > +		} while (u64_stats_fetch_retry_bh(&tstats->tx_syncp, start));
> > >  
> > >  		do {
> > > -			start = u64_stats_fetch_begin_bh(&stats->rx_syncp);
> > > -			rpackets = stats->rx_packets;
> > > -			rbytes   = stats->rx_bytes;
> > > -		} while (u64_stats_fetch_retry_bh(&stats->rx_syncp, start));
> > > +			start = u64_stats_fetch_begin_bh(&rstats->rx_syncp);
> > > +			rpackets = rstats->rx_packets;
> > > +			rbytes   = rstats->rx_bytes;
> > > +		} while (u64_stats_fetch_retry_bh(&rstats->rx_syncp, start));
> > >  
> > >  		tot->rx_packets += rpackets;
> > >  		tot->tx_packets += tpackets;
> > > @@ -1177,12 +1211,83 @@ static void virtnet_get_channels(struct net_device *dev,
> > >  	channels->other_count = 0;
> > >  }
> > >  
> > > +static void virtnet_get_stat_strings(struct net_device *dev,
> > > +					u32 stringset,
> > > +					u8 *data)
> > > +{
> > > +	struct virtnet_info *vi = netdev_priv(dev);
> > > +	int i, j;
> > > +
> > > +	switch (stringset) {
> > > +	case ETH_SS_STATS:
> > > +		for (i = 0; i < vi->max_queue_pairs; i++) {
> > > +			for (j = 0; j < VIRTNET_RX_STATS_NUM; j++) {
> > > +				sprintf(data, "rxq%d: %s", i,
> > > +					virtnet_et_rx_stats[j].desc);
> > > +				data += ETH_GSTRING_LEN;
> > > +			}
> > > +			for (j = 0; j < VIRTNET_TX_STATS_NUM; j++) {
> > > +				sprintf(data, "txq%d: %s", i,
> > > +					virtnet_et_tx_stats[j].desc);
> > > +				data += ETH_GSTRING_LEN;
> > > +			}
> > > +		}
> > > +		break;
> > > +	}
> > > +}
> > > +
> > > +static int virtnet_get_sset_count(struct net_device *dev, int stringset)
> > > +{
> > > +	struct virtnet_info *vi = netdev_priv(dev);
> > > +	switch (stringset) {
> > > +	case ETH_SS_STATS:
> > > +		return vi->max_queue_pairs *
> > > +			(VIRTNET_RX_STATS_NUM + VIRTNET_TX_STATS_NUM);
> > > +	default:
> > > +		return -EINVAL;
> > > +	}
> > > +}
> > > +
> > > +static void virtnet_get_ethtool_stats(struct net_device *dev,
> > > +					struct ethtool_stats *stats,
> > > +					u64 *data)
> > > +{
> > > +	struct virtnet_info *vi = netdev_priv(dev);
> > > +	unsigned int i, base;
> > > +	unsigned int start;
> > > +
> > > +	for (i = 0, base = 0; i < vi->max_queue_pairs; i++) {
> > > +		struct virtnet_tx_stats *tstats = &vi->sq[i].stats;
> > > +		struct virtnet_rx_stats *rstats = &vi->rq[i].stats;
> > > +
> > > +		do {
> > > +			start = u64_stats_fetch_begin_bh(&rstats->rx_syncp);
> > > +			data[base] = rstats->rx_packets;
> > > +			data[base+1] = rstats->rx_bytes;
> > 
> > nitpicking:
> > We normally has spaces around +, like this:
> > 			data[base + 1] = rstats->rx_bytes;
> > 
> > > +		} while (u64_stats_fetch_retry_bh(&rstats->rx_syncp, start));
> > > +
> > > +		base += VIRTNET_RX_STATS_NUM;
> > > +
> > > +		do {
> > > +			start = u64_stats_fetch_begin_bh(&tstats->tx_syncp);
> > > +			data[base] = tstats->tx_packets;
> > > +			data[base+1]   = tstats->tx_bytes;
> > 
> > 
> > nitpicking:
> > Here, something strange happened to indentation.
> > 
> > > +		} while (u64_stats_fetch_retry_bh(&tstats->tx_syncp, start));
> > > +
> > > +		base += VIRTNET_TX_STATS_NUM;
> > > +	}
> > > +}
> > > +
> > > +
> > >  static const struct ethtool_ops virtnet_ethtool_ops = {
> > >  	.get_drvinfo = virtnet_get_drvinfo,
> > >  	.get_link = ethtool_op_get_link,
> > >  	.get_ringparam = virtnet_get_ringparam,
> > >  	.set_channels = virtnet_set_channels,
> > >  	.get_channels = virtnet_get_channels,
> > > +	.get_strings = virtnet_get_stat_strings,
> > > +	.get_sset_count = virtnet_get_sset_count,
> > > +	.get_ethtool_stats = virtnet_get_ethtool_stats,
> > >  };
> > >  
> > >  #define MIN_MTU 68
> > > @@ -1531,14 +1636,11 @@ static int virtnet_probe(struct virtio_device *vdev)
> > >  	vi->dev = dev;
> > >  	vi->vdev = vdev;
> > >  	vdev->priv = vi;
> > > -	vi->stats = alloc_percpu(struct virtnet_stats);
> > >  	err = -ENOMEM;
> > > -	if (vi->stats == NULL)
> > > -		goto free;
> > >  
> > >  	vi->vq_index = alloc_percpu(int);
> > >  	if (vi->vq_index == NULL)
> > > -		goto free_stats;
> > > +		goto free;
> > >  
> > >  	mutex_init(&vi->config_lock);
> > >  	vi->config_enable = true;
> > > @@ -1616,8 +1718,6 @@ free_vqs:
> > >  	virtnet_del_vqs(vi);
> > >  free_index:
> > >  	free_percpu(vi->vq_index);
> > > -free_stats:
> > > -	free_percpu(vi->stats);
> > >  free:
> > >  	free_netdev(dev);
> > >  	return err;
> > > @@ -1653,7 +1753,6 @@ static void virtnet_remove(struct virtio_device *vdev)
> > >  	flush_work(&vi->config_work);
> > >  
> > >  	free_percpu(vi->vq_index);
> > > -	free_percpu(vi->stats);
> > >  	free_netdev(vi->dev);
> > >  }
> > 
> > Thanks!
> > 
> > > -- 
> > > 1.7.1

From: Simon Xiao <sixiao@microsoft.com>
Subject: RE: [PATCH net-next,1/1] hv_netvsc: use per_cpu stats to calculate
 TX/RX data
Date: Thu, 14 May 2015 06:02:03 +0000
Message-ID: <CY1PR03MB1376AB7B2D08F4D3692E25EAC4D80@CY1PR03MB1376.namprd03.prod.outlook.com>
References: <1431471002-12392-1-git-send-email-sixiao@microsoft.com>
 <20150514.005226.1136173357215274046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150514.005226.1136173357215274046.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, May 13, 2015 9:52 PM
> To: Simon Xiao
> Cc: KY Srinivasan; Haiyang Zhang; devel@linuxdriverproject.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next,1/1] hv_netvsc: use per_cpu stats to calculate
> TX/RX data
> 
> From: sixiao@microsoft.com
> Date: Tue, 12 May 2015 15:50:02 -0700
> 
> > From: Simon Xiao <sixiao@microsoft.com>
> >
> > Current code does not lock anything when calculating the TX and RX stats.
> > As a result, the RX and TX data reported by ifconfig are not accuracy
> > in a system with high network throughput and multiple CPUs (in my
> > test, RX/TX = 83% between 2 HyperV VM nodes which have 8 vCPUs and 40G
> Ethernet).
> >
> > This patch fixed the above issue by using per_cpu stats.
> > netvsc_get_stats64() summarizes TX and RX data by iterating over all
> > CPUs to get their respective stats.
> >
> > Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> > Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> > ---
> >  drivers/net/hyperv/hyperv_net.h |  9 +++++
> > drivers/net/hyperv/netvsc_drv.c | 80
> > ++++++++++++++++++++++++++++++++++++-----
> >  2 files changed, 81 insertions(+), 8 deletions(-)
> >
> > diff --git a/drivers/net/hyperv/hyperv_net.h
> > b/drivers/net/hyperv/hyperv_net.h index 41071d3..5a92b36 100644
> > --- a/drivers/net/hyperv/hyperv_net.h
> > +++ b/drivers/net/hyperv/hyperv_net.h
> > @@ -611,6 +611,12 @@ struct multi_send_data {
> >  	u32 count; /* counter of batched packets */  };
> >
> > +struct netvsc_stats {
> > +	u64 packets;
> > +	u64 bytes;
> > +	struct u64_stats_sync s_sync;
> > +};
> > +
> >  /* The context of the netvsc device  */  struct net_device_context {
> >  	/* point back to our device context */ @@ -618,6 +624,9 @@ struct
> > net_device_context {
> >  	struct delayed_work dwork;
> >  	struct work_struct work;
> >  	u32 msg_enable; /* debug level */
> > +
> > +	struct netvsc_stats __percpu *tx_stats;
> > +	struct netvsc_stats __percpu *rx_stats;
> >  };
> >
> >  /* Per netvsc device */
> > diff --git a/drivers/net/hyperv/netvsc_drv.c
> > b/drivers/net/hyperv/netvsc_drv.c index 5993c7e..310b902 100644
> > --- a/drivers/net/hyperv/netvsc_drv.c
> > +++ b/drivers/net/hyperv/netvsc_drv.c
> > @@ -391,7 +391,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct
> net_device *net)
> >  	u32 skb_length;
> >  	u32 pkt_sz;
> >  	struct hv_page_buffer page_buf[MAX_PAGE_BUFFER_COUNT];
> > -
> > +	struct netvsc_stats *tx_stats =
> > +this_cpu_ptr(net_device_ctx->tx_stats);
> >
> >  	/* We will atmost need two pages to describe the rndis
> >  	 * header. We can only transmit MAX_PAGE_BUFFER_COUNT number
> @@
> > -580,8 +580,10 @@ do_send:
> >
> >  drop:
> >  	if (ret == 0) {
> > -		net->stats.tx_bytes += skb_length;
> > -		net->stats.tx_packets++;
> > +		u64_stats_update_begin(&tx_stats->s_sync);
> > +		tx_stats->packets++;
> > +		tx_stats->bytes += skb_length;
> > +		u64_stats_update_end(&tx_stats->s_sync);
> >  	} else {
> >  		if (ret != -EAGAIN) {
> >  			dev_kfree_skb_any(skb);
> > @@ -644,13 +646,17 @@ int netvsc_recv_callback(struct hv_device
> *device_obj,
> >  				struct ndis_tcp_ip_checksum_info *csum_info)
> {
> >  	struct net_device *net;
> > +	struct net_device_context *net_device_ctx;
> >  	struct sk_buff *skb;
> > +	struct netvsc_stats *rx_stats;
> >
> >  	net = ((struct netvsc_device *)hv_get_drvdata(device_obj))->ndev;
> >  	if (!net || net->reg_state != NETREG_REGISTERED) {
> >  		packet->status = NVSP_STAT_FAIL;
> >  		return 0;
> >  	}
> > +	net_device_ctx = netdev_priv(net);
> > +	rx_stats = this_cpu_ptr(net_device_ctx->rx_stats);
> >
> >  	/* Allocate a skb - TODO direct I/O to pages? */
> >  	skb = netdev_alloc_skb_ip_align(net, packet->total_data_buflen); @@
> > -686,8 +692,10 @@ int netvsc_recv_callback(struct hv_device *device_obj,
> >  	skb_record_rx_queue(skb, packet->channel->
> >  			    offermsg.offer.sub_channel_index);
> >
> > -	net->stats.rx_packets++;
> > -	net->stats.rx_bytes += packet->total_data_buflen;
> > +	u64_stats_update_begin(&rx_stats->s_sync);
> > +	rx_stats->packets++;
> > +	rx_stats->bytes += packet->total_data_buflen;
> > +	u64_stats_update_end(&rx_stats->s_sync);
> >
> >  	/*
> >  	 * Pass the skb back up. Network stack will deallocate the skb when
> > it @@ -753,6 +761,46 @@ static int netvsc_change_mtu(struct net_device
> *ndev, int mtu)
> >  	return 0;
> >  }
> >
> > +static struct rtnl_link_stats64 *netvsc_get_stats64(struct net_device *net,
> > +						    struct rtnl_link_stats64 *t) {
> > +	struct net_device_context *ndev_ctx = netdev_priv(net);
> > +	int cpu;
> > +
> > +	for_each_possible_cpu(cpu) {
> > +		struct netvsc_stats *tx_stats = per_cpu_ptr(ndev_ctx->tx_stats,
> > +							    cpu);
> > +		struct netvsc_stats *rx_stats = per_cpu_ptr(ndev_ctx->rx_stats,
> > +							    cpu);
> > +		u64 tx_packets, tx_bytes, rx_packets, rx_bytes;
> > +		unsigned int start;
> > +
> > +		do {
> > +			start = u64_stats_fetch_begin_irq(&tx_stats->s_sync);
> > +			tx_packets = tx_stats->packets;
> > +			tx_bytes = tx_stats->bytes;
> > +		} while (u64_stats_fetch_retry_irq(&tx_stats->s_sync, start));
> > +
> > +		do {
> > +			start = u64_stats_fetch_begin_irq(&rx_stats->s_sync);
> > +			rx_packets = rx_stats->packets;
> > +			rx_bytes = rx_stats->bytes;
> > +		} while (u64_stats_fetch_retry_irq(&rx_stats->s_sync, start));
> > +
> > +		t->tx_bytes	+= tx_bytes;
> > +		t->tx_packets	+= tx_packets;
> > +		t->rx_bytes	+= rx_bytes;
> > +		t->rx_packets	+= rx_packets;
> > +	}
> > +
> > +	t->tx_dropped	= net->stats.tx_dropped;
> > +	t->tx_errors	= net->stats.tx_dropped;
> > +
> > +	t->rx_dropped	= net->stats.rx_dropped;
> > +	t->rx_errors	= net->stats.rx_errors;
> > +
> > +	return t;
> > +}
> >
> >  static int netvsc_set_mac_addr(struct net_device *ndev, void *p)  {
> > @@ -804,6 +852,7 @@ static const struct net_device_ops device_ops = {
> >  	.ndo_validate_addr =		eth_validate_addr,
> >  	.ndo_set_mac_address =		netvsc_set_mac_addr,
> >  	.ndo_select_queue =		netvsc_select_queue,
> > +	.ndo_get_stats64 =		netvsc_get_stats64,
> >  #ifdef CONFIG_NET_POLL_CONTROLLER
> >  	.ndo_poll_controller =		netvsc_poll_controller,
> >  #endif
> > @@ -855,6 +904,14 @@ static void netvsc_link_change(struct work_struct *w)
> >  		netdev_notify_peers(net);
> >  }
> >
> > +static void netvsc_free_netdev(struct net_device *netdev) {
> > +	struct net_device_context *net_device_ctx = netdev_priv(netdev);
> > +
> > +	free_percpu(net_device_ctx->tx_stats);
> > +	free_percpu(net_device_ctx->rx_stats);
> > +	free_netdev(netdev);
> > +}
> >
> >  static int netvsc_probe(struct hv_device *dev,
> >  			const struct hv_vmbus_device_id *dev_id) @@ -883,6
> +940,13 @@
> > static int netvsc_probe(struct hv_device *dev,
> >  		netdev_dbg(net, "netvsc msg_enable: %d\n",
> >  			   net_device_ctx->msg_enable);
> >
> > +	net_device_ctx->tx_stats = netdev_alloc_pcpu_stats(struct
> netvsc_stats);
> > +	if (!net_device_ctx->tx_stats)
> > +		return -ENOMEM;
> > +	net_device_ctx->rx_stats = netdev_alloc_pcpu_stats(struct
> netvsc_stats);
> > +	if (!net_device_ctx->rx_stats)
> > +		return -ENOMEM;
> 
> Both of these return statements leak.
> 
> The first one leaks the net_device, the second one leaks the net_device and the -
> >tx_stats memory.
> 
> You have to have cleanup paths here.

Thanks David. I will fix this and submit the new patch again.

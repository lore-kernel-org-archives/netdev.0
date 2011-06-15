From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: per cpu 64 bit stats
Date: Wed, 15 Jun 2011 21:33:16 +0300
Message-ID: <20110615183316.GB7197@redhat.com>
References: <20110615114337.09fe62f6@s6510.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54121 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779Ab1FOSdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2011 14:33:36 -0400
Content-Disposition: inline
In-Reply-To: <20110615114337.09fe62f6@s6510.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2011 at 11:43:37AM -0400, Stephen Hemminger wrote:
> Use per-cpu variables to maintain 64 bit statistics.
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Interesting. Does this help speed at all?

> --- a/drivers/net/virtio_net.c	2011-06-14 15:18:46.448596355 -0400
> +++ b/drivers/net/virtio_net.c	2011-06-15 09:54:22.914426067 -0400
> @@ -40,6 +40,15 @@ module_param(gso, bool, 0444);
>  
>  #define VIRTNET_SEND_COMMAND_SG_MAX    2
>  
> +struct virtnet_stats {
> +	struct u64_stats_sync syncp;
> +	u64 tx_bytes;
> +	u64 tx_packets;
> +
> +	u64 rx_bytes;
> +	u64 rx_packets;
> +};
> +
>  struct virtnet_info {
>  	struct virtio_device *vdev;
>  	struct virtqueue *rvq, *svq, *cvq;
> @@ -56,6 +65,9 @@ struct virtnet_info {
>  	/* Host will merge rx buffers for big packets (shake it! shake it!) */
>  	bool mergeable_rx_bufs;
>  
> +	/* Active statistics */
> +	struct virtnet_stats __percpu *stats;
> +
>  	/* Work struct for refilling if we run low on memory. */
>  	struct delayed_work refill;
>  
> @@ -209,7 +221,6 @@ static int receive_mergeable(struct virt
>  			skb->dev->stats.rx_length_errors++;
>  			return -EINVAL;
>  		}
> -
>  		page = virtqueue_get_buf(vi->rvq, &len);
>  		if (!page) {
>  			pr_debug("%s: rx error: %d buffers missing\n",
> @@ -217,6 +228,7 @@ static int receive_mergeable(struct virt
>  			skb->dev->stats.rx_length_errors++;
>  			return -EINVAL;
>  		}
> +
>  		if (len > PAGE_SIZE)
>  			len = PAGE_SIZE;
>

Let's not tweak whitespace unnecessarily.
  
> @@ -230,6 +242,7 @@ static int receive_mergeable(struct virt
>  static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> +	struct virtnet_stats __percpu *stats = this_cpu_ptr(vi->stats);
>  	struct sk_buff *skb;
>  	struct page *page;
>  	struct skb_vnet_hdr *hdr;
> @@ -265,8 +278,11 @@ static void receive_buf(struct net_devic
>  
>  	hdr = skb_vnet_hdr(skb);
>  	skb->truesize += skb->data_len;
> -	dev->stats.rx_bytes += skb->len;
> -	dev->stats.rx_packets++;
> +
> +	u64_stats_update_begin(&stats->syncp);
> +	stats->rx_bytes += skb->len;
> +	stats->rx_packets++;
> +	u64_stats_update_begin(&stats->syncp);
>  
>  	if (hdr->hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
>  		pr_debug("Needs csum!\n");
> @@ -515,11 +531,16 @@ static unsigned int free_old_xmit_skbs(s
>  {
>  	struct sk_buff *skb;
>  	unsigned int len, tot_sgs = 0;
> +	struct virtnet_stats __percpu *stats = this_cpu_ptr(vi->stats);
>  
>  	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
>  		pr_debug("Sent skb %p\n", skb);
> -		vi->dev->stats.tx_bytes += skb->len;
> -		vi->dev->stats.tx_packets++;
> +
> +		u64_stats_update_begin(&stats->syncp);
> +		stats->tx_bytes += skb->len;
> +		stats->tx_packets++;
> +		u64_stats_update_begin(&stats->syncp);
> +
>  		tot_sgs += skb_vnet_hdr(skb)->num_sg;
>  		dev_kfree_skb_any(skb);
>  	}
> @@ -641,6 +662,40 @@ static int virtnet_set_mac_address(struc
>  	return 0;
>  }
>  
> +static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
> +					       struct rtnl_link_stats64 *tot)
> +{
> +	struct virtnet_info *vi = netdev_priv(dev);
> +	int cpu;
> +	unsigned int start;
> +
> +	for_each_possible_cpu(cpu) {
> +		struct virtnet_stats __percpu *stats
> +			= per_cpu_ptr(vi->stats, cpu);
> +		u64 tpackets, tbytes, rpackets, rbytes;
> +
> +		do {
> +			start = u64_stats_fetch_begin(&stats->syncp);
> +			tpackets = stats->tx_packets;
> +			tbytes   = stats->tx_bytes;
> +			rpackets = stats->rx_packets;
> +			rbytes   = stats->rx_bytes;
> +		} while (u64_stats_fetch_retry(&stats->syncp, start));
> +
> +		tot->rx_packets += rpackets;
> +		tot->tx_packets += tpackets;
> +		tot->rx_bytes   += rbytes;
> +		tot->tx_bytes   += tbytes;
> +	}
> +
> +	tot->tx_dropped = dev->stats.tx_dropped;
> +	tot->rx_dropped = dev->stats.rx_dropped;
> +	tot->rx_length_errors = dev->stats.rx_length_errors;
> +	tot->rx_frame_errors = dev->stats.rx_frame_errors;
> +
> +	return tot;
> +}
> +
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  static void virtnet_netpoll(struct net_device *dev)
>  {
> @@ -650,6 +705,14 @@ static void virtnet_netpoll(struct net_d
>  }
>  #endif
>  
> +static void virtnet_free(struct net_device *dev)
> +{
> +	struct virtnet_info *vi = netdev_priv(dev);
> +
> +	free_percpu(vi->stats);
> +	free_netdev(dev);
> +}
> +
>  static int virtnet_open(struct net_device *dev)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> @@ -835,6 +898,7 @@ static const struct net_device_ops virtn
>  	.ndo_set_mac_address = virtnet_set_mac_address,
>  	.ndo_set_rx_mode     = virtnet_set_rx_mode,
>  	.ndo_change_mtu	     = virtnet_change_mtu,
> +	.ndo_get_stats64     = virtnet_stats,
>  	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
>  	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> @@ -895,6 +959,8 @@ static int virtnet_probe(struct virtio_d
>  	/* Set up network device as normal. */
>  	dev->netdev_ops = &virtnet_netdev;
>  	dev->features = NETIF_F_HIGHDMA;
> +	dev->destructor = virtnet_free;
> +
>  	SET_ETHTOOL_OPS(dev, &virtnet_ethtool_ops);
>  	SET_NETDEV_DEV(dev, &vdev->dev);
>  
> @@ -939,6 +1005,11 @@ static int virtnet_probe(struct virtio_d
>  	vi->vdev = vdev;
>  	vdev->priv = vi;
>  	vi->pages = NULL;
> +	vi->stats = alloc_percpu(struct virtnet_stats);
> +	err = -ENOMEM;
> +	if (vi->stats == NULL)
> +		goto free;
> +
>  	INIT_DELAYED_WORK(&vi->refill, refill_work);
>  	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
>  	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
> @@ -958,7 +1029,7 @@ static int virtnet_probe(struct virtio_d
>  
>  	err = vdev->config->find_vqs(vdev, nvqs, vqs, callbacks, names);
>  	if (err)
> -		goto free;
> +		goto free_stats;
>  
>  	vi->rvq = vqs[0];
>  	vi->svq = vqs[1];
> @@ -1003,6 +1074,8 @@ unregister:
>  	cancel_delayed_work_sync(&vi->refill);
>  free_vqs:
>  	vdev->config->del_vqs(vdev);
> +free_stats:
> +	free_percpu(vi->stats);
>  free:
>  	free_netdev(dev);
>  	return err;

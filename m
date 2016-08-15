From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC 2/2] netvsc: use RCU for VF net device reference
Date: Mon, 15 Aug 2016 12:06:22 +0200
Message-ID: <87lgzyjqht.fsf@vitty.brq.redhat.com>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
	<1470913137-29167-3-git-send-email-vkuznets@redhat.com>
	<20160813113559.617b7c55@xeon-e3> <20160813113820.697695a0@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, devel@linuxdriverproject.org,
	linux-kernel@vger.kernel.org,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160813113820.697695a0@xeon-e3> (Stephen Hemminger's message of
	"Sat, 13 Aug 2016 11:38:20 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <stephen@networkplumber.org> writes:

> Rather than keeping a pointer, a flag, and reference count, use RCU and existing
> device reference count to protect the synthetic to VF relationship.

Thanks! I like the idea. Some nitpicks below ...

>
> One other change is that injected packets must be accounted for on the synthetic
> device otherwise the statistics will be lost. The VF device driver (for most devices)
> creates the statistics based on device registers and therefore would ignore any direct
> manipulation of network device stats.
>
> Also, rx_dropped is not atomic_long.
>
> Signed-off-by: Stephen Hemminger <sthemmin@linuxonhyperv.com>
>
> --- a/drivers/net/hyperv/hyperv_net.h	2016-08-13 11:25:59.764085593 -0700
> +++ b/drivers/net/hyperv/hyperv_net.h	2016-08-13 11:25:59.736085464 -0700
> @@ -689,6 +689,9 @@ struct netvsc_device {
>  	wait_queue_head_t wait_drain;
>  	bool destroy;
>
> +	/* State to manage the associated VF interface. */
> +	struct net_device *vf_netdev __rcu;
> +
>  	/* Receive buffer allocated by us but manages by NetVSP */
>  	void *recv_buf;
>  	u32 recv_buf_size;
> @@ -739,10 +742,6 @@ struct netvsc_device {
>  	/* Serial number of the VF to team with */
>  	u32 vf_serial;
>  	atomic_t open_cnt;
> -	/* State to manage the associated VF interface. */
> -	bool vf_inject;
> -	struct net_device *vf_netdev;
> -	atomic_t vf_use_cnt;
>  };
>
>  static inline struct netvsc_device *
> --- a/drivers/net/hyperv/netvsc.c	2016-08-13 11:25:59.764085593 -0700
> +++ b/drivers/net/hyperv/netvsc.c	2016-08-13 11:25:59.736085464 -0700
> @@ -77,13 +77,10 @@ static struct netvsc_device *alloc_net_d
>  	init_waitqueue_head(&net_device->wait_drain);
>  	net_device->destroy = false;
>  	atomic_set(&net_device->open_cnt, 0);
> -	atomic_set(&net_device->vf_use_cnt, 0);
> +
>  	net_device->max_pkt = RNDIS_MAX_PKT_DEFAULT;
>  	net_device->pkt_align = RNDIS_PKT_ALIGN_DEFAULT;
>
> -	net_device->vf_netdev = NULL;
> -	net_device->vf_inject = false;
> -
>  	return net_device;
>  }
>
> --- a/drivers/net/hyperv/netvsc_drv.c	2016-08-13 11:25:59.764085593 -0700
> +++ b/drivers/net/hyperv/netvsc_drv.c	2016-08-13 11:31:47.733685146 -0700
> @@ -668,59 +668,45 @@ int netvsc_recv_callback(struct hv_devic
>  {
>  	struct net_device *net = hv_get_drvdata(device_obj);
>  	struct net_device_context *net_device_ctx = netdev_priv(net);
> -	struct sk_buff *skb;
> -	struct sk_buff *vf_skb;
> -	struct netvsc_stats *rx_stats;
> +	struct netvsc_stats *rx_stats = this_cpu_ptr(net_device_ctx->rx_stats);
>  	struct netvsc_device *netvsc_dev = net_device_ctx->nvdev;
> -	u32 bytes_recvd = packet->total_data_buflen;
> -	int ret = 0;
> +	struct net_device *vf_netdev;
> +	struct sk_buff *skb;
>
>  	if (!net || net->reg_state != NETREG_REGISTERED)
>  		return NVSP_STAT_FAIL;
>
> -	if (READ_ONCE(netvsc_dev->vf_inject)) {
> -		atomic_inc(&netvsc_dev->vf_use_cnt);
> -		if (!READ_ONCE(netvsc_dev->vf_inject)) {
> -			/*
> -			 * We raced; just move on.
> -			 */
> -			atomic_dec(&netvsc_dev->vf_use_cnt);
> -			goto vf_injection_done;
> -		}
> +	vf_netdev = rcu_dereference(netvsc_dev->vf_netdev);
> +	if (vf_netdev) {
> +		/* Inject this packet into the VF interface.  On
> +		 * Hyper-V, multicast and broadcast packets are only
> +		 * delivered on the synthetic interface (after
> +		 * subjecting these to policy filters on the
> +		 * host). Deliver these via the VF interface in the
> +		 * guest if up, otherwise drop.
> +		 */
> +		if (!netif_running(vf_netdev))
> +			goto drop;

Why drop? In case VF is not running I guess it would be better to
receive the packet through netvsc interface.

>
> -		/*
> -		 * Inject this packet into the VF inerface.
> -		 * On Hyper-V, multicast and brodcast packets
> -		 * are only delivered on the synthetic interface
> -		 * (after subjecting these to policy filters on
> -		 * the host). Deliver these via the VF interface
> -		 * in the guest.
> +		/* Account for this on the synthetic interface
> +		 * otherwise likely to be not accounted for since
> +		 * device statistics on the VF are driver dependent.
>  		 */
> -		vf_skb = netvsc_alloc_recv_skb(netvsc_dev->vf_netdev, packet,
> -					       csum_info, *data, vlan_tci);
> -		if (vf_skb != NULL) {
> -			++netvsc_dev->vf_netdev->stats.rx_packets;
> -			netvsc_dev->vf_netdev->stats.rx_bytes += bytes_recvd;
> -			netif_receive_skb(vf_skb);
> -		} else {
> -			++net->stats.rx_dropped;
> -			ret = NVSP_STAT_FAIL;
> -		}
> -		atomic_dec(&netvsc_dev->vf_use_cnt);
> -		return ret;
> +		++net->stats.multicast;

And if the packet is broadcast and not multicast?

> +		net = vf_netdev;
>  	}
>
> -vf_injection_done:
> -	rx_stats = this_cpu_ptr(net_device_ctx->rx_stats);
> -
>  	/* Allocate a skb - TODO direct I/O to pages? */
>  	skb = netvsc_alloc_recv_skb(net, packet, csum_info, *data, vlan_tci);
>  	if (unlikely(!skb)) {
> +drop:
>  		++net->stats.rx_dropped;
>  		return NVSP_STAT_FAIL;
>  	}
> -	skb_record_rx_queue(skb, channel->
> -			    offermsg.offer.sub_channel_index);
> +
> +	if (likely(!vf_netdev))
> +		skb_record_rx_queue(skb,
> +				    channel->offermsg.offer.sub_channel_index);
>
>  	u64_stats_update_begin(&rx_stats->syncp);
>  	rx_stats->packets++;
> @@ -989,6 +975,7 @@ static struct rtnl_link_stats64 *netvsc_
>
>  	t->rx_dropped	= net->stats.rx_dropped;
>  	t->rx_errors	= net->stats.rx_errors;
> +	t->multicast 	= net->stats.multicast;
>
>  	return t;
>  }
> @@ -1170,8 +1157,7 @@ static void netvsc_notify_peers(struct w
>  	gwrk = container_of(wrk, struct garp_wrk, dwrk);
>
>  	netdev_notify_peers(gwrk->netdev);
> -
> -	atomic_dec(&gwrk->netvsc_dev->vf_use_cnt);
> +	dev_put(gwrk->netdev);
>  }
>
>  static struct net_device *get_netvsc_net_device(char *mac)
> @@ -1222,7 +1208,7 @@ static int netvsc_register_vf(struct net
>  	netdev_info(ndev, "VF registering: %s\n", vf_netdev->name);
>
>  	dev_hold(vf_netdev);
> -	netvsc_dev->vf_netdev = vf_netdev;
> +	rcu_assign_pointer(netvsc_dev->vf_netdev, vf_netdev);
>  	return NOTIFY_OK;
>  }
>
> @@ -1248,7 +1234,6 @@ static int netvsc_vf_up(struct net_devic
>  		return NOTIFY_DONE;
>
>  	netdev_info(ndev, "VF up: %s\n", vf_netdev->name);
> -	netvsc_dev->vf_inject = true;
>
>  	/*
>  	 * Open the device before switching data path.
> @@ -1268,7 +1253,7 @@ static int netvsc_vf_up(struct net_devic
>  	 * notify peers; take a reference to prevent
>  	 * the VF interface from vanishing.
>  	 */
> -	atomic_inc(&netvsc_dev->vf_use_cnt);
> +	dev_hold(vf_netdev);

PATCH net 4/4 of my series drops gwrk.dwrk completely so depending on
the patch order this may not be needed...

>  	net_device_ctx->gwrk.netdev = vf_netdev;
>  	net_device_ctx->gwrk.netvsc_dev = netvsc_dev;
>  	schedule_work(&net_device_ctx->gwrk.dwrk);
> @@ -1298,14 +1283,7 @@ static int netvsc_vf_down(struct net_dev
>  		return NOTIFY_DONE;
>
>  	netdev_info(ndev, "VF down: %s\n", vf_netdev->name);
> -	netvsc_dev->vf_inject = false;
> -	/*
> -	 * Wait for currently active users to
> -	 * drain out.
> -	 */
>
> -	while (atomic_read(&netvsc_dev->vf_use_cnt) != 0)
> -		udelay(50);
>  	netvsc_switch_datapath(ndev, false);
>  	netdev_info(ndev, "Data path switched from VF: %s\n", vf_netdev->name);
>  	rndis_filter_close(netvsc_dev);
> @@ -1313,7 +1291,7 @@ static int netvsc_vf_down(struct net_dev
>  	/*
>  	 * Notify peers.
>  	 */
> -	atomic_inc(&netvsc_dev->vf_use_cnt);
> +	dev_hold(ndev);
>  	net_device_ctx->gwrk.netdev = ndev;
>  	net_device_ctx->gwrk.netvsc_dev = netvsc_dev;
>  	schedule_work(&net_device_ctx->gwrk.dwrk);
> @@ -1342,7 +1320,7 @@ static int netvsc_unregister_vf(struct n
>  		return NOTIFY_DONE;
>  	netdev_info(ndev, "VF unregistering: %s\n", vf_netdev->name);
>
> -	netvsc_dev->vf_netdev = NULL;
> +	RCU_INIT_POINTER(netvsc_dev->vf_netdev, NULL);
>  	dev_put(vf_netdev);
>  	return NOTIFY_OK;
>  }

I'd also suggest you split your patch into two - switch to using RCU and
stats changes as these changes are more or less independent.

-- 
  Vitaly

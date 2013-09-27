From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: switch to use XPS to choose txq
Date: Fri, 27 Sep 2013 17:35:29 +0300
Message-ID: <20130927143529.GA30007@redhat.com>
References: <1380261444-40918-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1380261444-40918-1-git-send-email-jasowang@redhat.com>
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

On Fri, Sep 27, 2013 at 01:57:24PM +0800, Jason Wang wrote:
> We used to use a percpu structure vq_index to record the cpu to queue
> mapping, this is suboptimal since it duplicates the work of XPS and
> loses all other XPS functionality such as allowing use to configure
> their own transmission steering strategy.
> 
> So this patch switches to use XPS and suggest a default mapping when
> the number of cpus is equal to the number of queues. With XPS support,
> there's no need for keeping per-cpu vq_index and .ndo_select_queue(),
> so they were removed also.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

More lines deleted that added is good :)
But how does the result perform?
About the same?

> ---
>  drivers/net/virtio_net.c |   55 +++++++--------------------------------------
>  1 files changed, 9 insertions(+), 46 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index defec2b..4102c1b 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -127,9 +127,6 @@ struct virtnet_info {
>  	/* Does the affinity hint is set for virtqueues? */
>  	bool affinity_hint_set;
>  
> -	/* Per-cpu variable to show the mapping from CPU to virtqueue */
> -	int __percpu *vq_index;
> -
>  	/* CPU hot plug notifier */
>  	struct notifier_block nb;
>  };
> @@ -1063,7 +1060,6 @@ static int virtnet_vlan_rx_kill_vid(struct net_device *dev,
>  static void virtnet_clean_affinity(struct virtnet_info *vi, long hcpu)
>  {
>  	int i;
> -	int cpu;
>  
>  	if (vi->affinity_hint_set) {
>  		for (i = 0; i < vi->max_queue_pairs; i++) {
> @@ -1073,20 +1069,11 @@ static void virtnet_clean_affinity(struct virtnet_info *vi, long hcpu)
>  
>  		vi->affinity_hint_set = false;
>  	}
> -
> -	i = 0;
> -	for_each_online_cpu(cpu) {
> -		if (cpu == hcpu) {
> -			*per_cpu_ptr(vi->vq_index, cpu) = -1;
> -		} else {
> -			*per_cpu_ptr(vi->vq_index, cpu) =
> -				++i % vi->curr_queue_pairs;
> -		}
> -	}
>  }
>  
>  static void virtnet_set_affinity(struct virtnet_info *vi)
>  {
> +	cpumask_var_t cpumask;
>  	int i;
>  	int cpu;
>  
> @@ -1100,15 +1087,21 @@ static void virtnet_set_affinity(struct virtnet_info *vi)
>  		return;
>  	}
>  
> +	if (!alloc_cpumask_var(&cpumask, GFP_KERNEL))
> +		return;
> +
>  	i = 0;
>  	for_each_online_cpu(cpu) {
>  		virtqueue_set_affinity(vi->rq[i].vq, cpu);
>  		virtqueue_set_affinity(vi->sq[i].vq, cpu);
> -		*per_cpu_ptr(vi->vq_index, cpu) = i;
> +		cpumask_clear(cpumask);
> +		cpumask_set_cpu(cpu, cpumask);
> +		netif_set_xps_queue(vi->dev, cpumask, i);
>  		i++;
>  	}
>  
>  	vi->affinity_hint_set = true;
> +	free_cpumask_var(cpumask);
>  }
>  
>  static int virtnet_cpu_callback(struct notifier_block *nfb,
> @@ -1217,28 +1210,6 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
>  	return 0;
>  }
>  
> -/* To avoid contending a lock hold by a vcpu who would exit to host, select the
> - * txq based on the processor id.
> - */
> -static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
> -{
> -	int txq;
> -	struct virtnet_info *vi = netdev_priv(dev);
> -
> -	if (skb_rx_queue_recorded(skb)) {
> -		txq = skb_get_rx_queue(skb);
> -	} else {
> -		txq = *__this_cpu_ptr(vi->vq_index);
> -		if (txq == -1)
> -			txq = 0;
> -	}
> -
> -	while (unlikely(txq >= dev->real_num_tx_queues))
> -		txq -= dev->real_num_tx_queues;
> -
> -	return txq;
> -}
> -
>  static const struct net_device_ops virtnet_netdev = {
>  	.ndo_open            = virtnet_open,
>  	.ndo_stop   	     = virtnet_close,
> @@ -1250,7 +1221,6 @@ static const struct net_device_ops virtnet_netdev = {
>  	.ndo_get_stats64     = virtnet_stats,
>  	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
>  	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
> -	.ndo_select_queue     = virtnet_select_queue,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller = virtnet_netpoll,
>  #endif
> @@ -1559,10 +1529,6 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	if (vi->stats == NULL)
>  		goto free;
>  
> -	vi->vq_index = alloc_percpu(int);
> -	if (vi->vq_index == NULL)
> -		goto free_stats;
> -
>  	mutex_init(&vi->config_lock);
>  	vi->config_enable = true;
>  	INIT_WORK(&vi->config_work, virtnet_config_changed_work);
> @@ -1589,7 +1555,7 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
>  	err = init_vqs(vi);
>  	if (err)
> -		goto free_index;
> +		goto free_stats;
>  
>  	netif_set_real_num_tx_queues(dev, 1);
>  	netif_set_real_num_rx_queues(dev, 1);
> @@ -1640,8 +1606,6 @@ free_recv_bufs:
>  free_vqs:
>  	cancel_delayed_work_sync(&vi->refill);
>  	virtnet_del_vqs(vi);
> -free_index:
> -	free_percpu(vi->vq_index);
>  free_stats:
>  	free_percpu(vi->stats);
>  free:
> @@ -1678,7 +1642,6 @@ static void virtnet_remove(struct virtio_device *vdev)
>  
>  	flush_work(&vi->config_work);
>  
> -	free_percpu(vi->vq_index);
>  	free_percpu(vi->stats);
>  	free_netdev(vi->dev);
>  }
> -- 
> 1.7.1

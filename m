From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: Re: [PATCH V7 1/3] virtio-net: fix the set affinity bug when CPU
	IDs are not consecutive
Date: Fri, 25 Jan 2013 17:05:11 +0800
Message-ID: <51024AC7.9030109@cn.fujitsu.com>
References: <1359102981-3401-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<510249C6.2000105@redhat.com>
Reply-To: gaowanlong@cn.fujitsu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <erdnetdev@gmail.com>, "David S. Miller" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <510249C6.2000105@redhat.com>
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

On 01/25/2013 05:00 PM, Jason Wang wrote:
> On 01/25/2013 04:36 PM, Wanlong Gao wrote:
>> As Michael mentioned, set affinity and select queue will not work very
>> well when CPU IDs are not consecutive, this can happen with hot unplug.
>> Fix this bug by traversal the online CPUs, and create a per cpu variable
>> to find the mapping from CPU to the preferable virtual-queue.
>>
>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>> Cc: Jason Wang <jasowang@redhat.com>
>> Cc: Eric Dumazet <erdnetdev@gmail.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: virtualization@lists.linux-foundation.org
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
>> Acked-by: Michael S. Tsirkin <mst@redhat.com>
>> ---
>> V6->V7:
>> 	serialize virtnet_set_queues to avoid a race with cpu hotplug (Jason)
>> V5->V6:
>> 	remove {get|put}_online_cpus from virtnet_del_vqs (Jason)
>> V4->V5:
>> 	Add get/put_online_cpus to avoid CPUs go up and down during operations (Rusty)
>>
>> V3->V4:
>> 	move vq_index into virtnet_info	(Jason)
>> 	change the mapping value when not setting affinity (Jason)
>> 	address the comments about select_queue (Rusty)
>>
>>  drivers/net/virtio_net.c | 58 +++++++++++++++++++++++++++++++++++++++---------
>>  1 file changed, 47 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index a6fcf15..0f3afa8 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -123,6 +123,9 @@ struct virtnet_info {
>>  
>>  	/* Does the affinity hint is set for virtqueues? */
>>  	bool affinity_hint_set;
>> +
>> +	/* Per-cpu variable to show the mapping from CPU to virtqueue */
>> +	int __percpu *vq_index;
>>  };
>>  
>>  struct skb_vnet_hdr {
>> @@ -1016,6 +1019,7 @@ static int virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
>>  static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
>>  {
>>  	int i;
>> +	int cpu;
>>  
>>  	/* In multiqueue mode, when the number of cpu is equal to the number of
>>  	 * queue pairs, we let the queue pairs to be private to one cpu by
>> @@ -1029,16 +1033,29 @@ static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
>>  			return;
>>  	}
>>  
>> -	for (i = 0; i < vi->max_queue_pairs; i++) {
>> -		int cpu = set ? i : -1;
>> -		virtqueue_set_affinity(vi->rq[i].vq, cpu);
>> -		virtqueue_set_affinity(vi->sq[i].vq, cpu);
>> -	}
>> +	if (set) {
>> +		i = 0;
>> +		for_each_online_cpu(cpu) {
>> +			virtqueue_set_affinity(vi->rq[i].vq, cpu);
>> +			virtqueue_set_affinity(vi->sq[i].vq, cpu);
>> +			*per_cpu_ptr(vi->vq_index, cpu) = i;
>> +			i++;
>> +		}
>>  
>> -	if (set)
>>  		vi->affinity_hint_set = true;
>> -	else
>> +	} else {
>> +		for(i = 0; i < vi->max_queue_pairs; i++) {
>> +			virtqueue_set_affinity(vi->rq[i].vq, -1);
>> +			virtqueue_set_affinity(vi->sq[i].vq, -1);
>> +		}
>> +
>> +		i = 0;
>> +		for_each_online_cpu(cpu)
>> +			*per_cpu_ptr(vi->vq_index, cpu) =
>> +				++i % vi->curr_queue_pairs;
>> +
>>  		vi->affinity_hint_set = false;
>> +	}
>>  }
> 
> Sorry, looks like the issue of v6 still exists, we need set per-cpu
> index unconditionally here (and also in 2/3), the cpus != queues check
> may bypass this setting.

This fixed in 2/3, when cpus != queues, it will go into virtnet_clean_affinity(in 2/3),
then vq index is set in virtnet_clean_affinity. Am I missing something?

Thanks,
Wanlong Gao

>>  
>>  static void virtnet_get_ringparam(struct net_device *dev,
>> @@ -1082,6 +1099,7 @@ static int virtnet_set_channels(struct net_device *dev,
>>  	if (queue_pairs > vi->max_queue_pairs)
>>  		return -EINVAL;
>>  
>> +	get_online_cpus();
>>  	err = virtnet_set_queues(vi, queue_pairs);
>>  	if (!err) {
>>  		netif_set_real_num_tx_queues(dev, queue_pairs);
>> @@ -1089,6 +1107,7 @@ static int virtnet_set_channels(struct net_device *dev,
>>  
>>  		virtnet_set_affinity(vi, true);
>>  	}
>> +	put_online_cpus();
>>  
>>  	return err;
>>  }
>> @@ -1127,12 +1146,19 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
>>  
>>  /* To avoid contending a lock hold by a vcpu who would exit to host, select the
>>   * txq based on the processor id.
>> - * TODO: handle cpu hotplug.
>>   */
>>  static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
>>  {
>> -	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
>> -		  smp_processor_id();
>> +	int txq;
>> +	struct virtnet_info *vi = netdev_priv(dev);
>> +
>> +	if (skb_rx_queue_recorded(skb)) {
>> +		txq = skb_get_rx_queue(skb);
>> +	} else {
>> +		txq = *__this_cpu_ptr(vi->vq_index);
>> +		if (txq == -1)
>> +			txq = 0;
>> +	}
>>  
>>  	while (unlikely(txq >= dev->real_num_tx_queues))
>>  		txq -= dev->real_num_tx_queues;
>> @@ -1371,7 +1397,10 @@ static int init_vqs(struct virtnet_info *vi)
>>  	if (ret)
>>  		goto err_free;
>>  
>> +	get_online_cpus();
>>  	virtnet_set_affinity(vi, true);
>> +	put_online_cpus();
>> +
>>  	return 0;
>>  
>>  err_free:
>> @@ -1453,6 +1482,10 @@ static int virtnet_probe(struct virtio_device *vdev)
>>  	if (vi->stats == NULL)
>>  		goto free;
>>  
>> +	vi->vq_index = alloc_percpu(int);
>> +	if (vi->vq_index == NULL)
>> +		goto free_stats;
>> +
>>  	mutex_init(&vi->config_lock);
>>  	vi->config_enable = true;
>>  	INIT_WORK(&vi->config_work, virtnet_config_changed_work);
>> @@ -1476,7 +1509,7 @@ static int virtnet_probe(struct virtio_device *vdev)
>>  	/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
>>  	err = init_vqs(vi);
>>  	if (err)
>> -		goto free_stats;
>> +		goto free_index;
>>  
>>  	netif_set_real_num_tx_queues(dev, 1);
>>  	netif_set_real_num_rx_queues(dev, 1);
>> @@ -1520,6 +1553,8 @@ free_recv_bufs:
>>  free_vqs:
>>  	cancel_delayed_work_sync(&vi->refill);
>>  	virtnet_del_vqs(vi);
>> +free_index:
>> +	free_percpu(vi->vq_index);
>>  free_stats:
>>  	free_percpu(vi->stats);
>>  free:
>> @@ -1554,6 +1589,7 @@ static void virtnet_remove(struct virtio_device *vdev)
>>  
>>  	flush_work(&vi->config_work);
>>  
>> +	free_percpu(vi->vq_index);
>>  	free_percpu(vi->stats);
>>  	free_netdev(vi->dev);
>>  }
> 
> 

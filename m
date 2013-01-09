From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V3 1/2] virtio-net: fix the set affinity bug when CPU
	IDs are not consecutive
Date: Wed, 09 Jan 2013 11:06:07 +0800
Message-ID: <50ECDE9F.2030901@redhat.com>
References: <1357639660-6660-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<50EBF44C.9040401@redhat.com> <50ECCD76.9010508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <erdnetdev@gmail.com>
To: gaowanlong@cn.fujitsu.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <50ECCD76.9010508@cn.fujitsu.com>
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

On 01/09/2013 09:52 AM, Wanlong Gao wrote:
> On 01/08/2013 06:26 PM, Jason Wang wrote:
>> On 01/08/2013 06:07 PM, Wanlong Gao wrote:
>>> As Michael mentioned, set affinity and select queue will not work very
>>> well when CPU IDs are not consecutive, this can happen with hot unplug.
>>> Fix this bug by traversal the online CPUs, and create a per cpu variable
>>> to find the mapping from CPU to the preferable virtual-queue.
>>>
>>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>>> Cc: Jason Wang <jasowang@redhat.com>
>>> Cc: Eric Dumazet <erdnetdev@gmail.com>
>>> Cc: virtualization@lists.linux-foundation.org
>>> Cc: netdev@vger.kernel.org
>>> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
>>> ---
>>>  drivers/net/virtio_net.c | 39 +++++++++++++++++++++++++++++----------
>>>  1 file changed, 29 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>>> index a6fcf15..a77f86c 100644
>>> --- a/drivers/net/virtio_net.c
>>> +++ b/drivers/net/virtio_net.c
>>> @@ -41,6 +41,8 @@ module_param(gso, bool, 0444);
>>>  #define VIRTNET_SEND_COMMAND_SG_MAX    2
>>>  #define VIRTNET_DRIVER_VERSION "1.0.0"
>>>  
>>> +DEFINE_PER_CPU(int, vq_index) = -1;
>>> +
>> I think this should not be a global one, consider we may have more than
>> one virtio-net cards with different max queues.
> Yes, would you move this into virtio_info?

Yes, I think it's better.
>>>  struct virtnet_stats {
>>>  	struct u64_stats_sync tx_syncp;
>>>  	struct u64_stats_sync rx_syncp;
>>> @@ -1016,6 +1018,7 @@ static int virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
>>>  static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
>>>  {
>>>  	int i;
>>> +	int cpu;
>>>  
>>>  	/* In multiqueue mode, when the number of cpu is equal to the number of
>>>  	 * queue pairs, we let the queue pairs to be private to one cpu by
>>> @@ -1029,16 +1032,29 @@ static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
>>>  			return;
>>>  	}
>>>  
>>> -	for (i = 0; i < vi->max_queue_pairs; i++) {
>>> -		int cpu = set ? i : -1;
>>> -		virtqueue_set_affinity(vi->rq[i].vq, cpu);
>>> -		virtqueue_set_affinity(vi->sq[i].vq, cpu);
>>> -	}
>>> +	if (set) {
>>> +		i = 0;
>>> +		for_each_online_cpu(cpu) {
>>> +			virtqueue_set_affinity(vi->rq[i].vq, cpu);
>>> +			virtqueue_set_affinity(vi->sq[i].vq, cpu);
>>> +			per_cpu(vq_index, cpu) = i;
>>> +			i++;
>>> +			if (i >= vi->max_queue_pairs)
>>> +				break;
>> Can this happen? we check only set when the number are equal.
> will remove.
>
>>> +		}
>>>  
>>> -	if (set)
>>>  		vi->affinity_hint_set = true;
>>> -	else
>>> +	} else {
>>> +		for(i = 0; i < vi->max_queue_pairs; i++) {
>>> +			virtqueue_set_affinity(vi->rq[i].vq, -1);
>>> +			virtqueue_set_affinity(vi->sq[i].vq, -1);
>>> +		}
>>> +
>>> +		for_each_online_cpu(cpu)
>>> +			per_cpu(vq_index, cpu) = -1;
>>> +
>> This looks suboptimal since it may leads only txq zero is used.
> So, which value is best for txq when we don't set affinity?
> just remain to smp_processor_id()?

The value which will let us use all queues are ok.

How about this?
 
i = 0;
for_each_online_cpu(cpu)
    per_cpu(vq_index, cpu) = ++i % vi->curr_queues;
> Thanks,
> Wanlong Gao
>
>>>  		vi->affinity_hint_set = false;
>>> +	}
>>>  }
>>>  
>>>  static void virtnet_get_ringparam(struct net_device *dev,
>>> @@ -1127,12 +1143,15 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
>>>  
>>>  /* To avoid contending a lock hold by a vcpu who would exit to host, select the
>>>   * txq based on the processor id.
>>> - * TODO: handle cpu hotplug.
>>>   */
>>>  static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
>>>  {
>>> -	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
>>> -		  smp_processor_id();
>>> +	int txq = 0;
>>> +
>>> +	if (skb_rx_queue_recorded(skb))
>>> +		txq = skb_get_rx_queue(skb);
>>> +	else if ((txq = per_cpu(vq_index, smp_processor_id())) == -1)
>>> +		txq = 0;
>>>  
>>>  	while (unlikely(txq >= dev->real_num_tx_queues))
>>>  		txq -= dev->real_num_tx_queues;
>>

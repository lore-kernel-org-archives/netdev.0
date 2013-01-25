From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: Re: [PATCH V6 2/3] virtio-net: split out clean affinity function
Date: Fri, 25 Jan 2013 15:22:03 +0800
Message-ID: <5102329B.4050806@cn.fujitsu.com>
References: <1358767524-17934-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<1358767524-17934-2-git-send-email-gaowanlong@cn.fujitsu.com>
	<5101FBE0.7040505@redhat.com> <51020800.4080900@cn.fujitsu.com>
	<5102145D.7030607@redhat.com> <51021ABB.8050508@cn.fujitsu.com>
	<5102224C.3050909@redhat.com> <51022956.3050406@cn.fujitsu.com>
	<51022E7E.3040905@redhat.com>
Reply-To: gaowanlong@cn.fujitsu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <erdnetdev@gmail.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <51022E7E.3040905@redhat.com>
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

On 01/25/2013 03:04 PM, Jason Wang wrote:
> On 01/25/2013 02:42 PM, Wanlong Gao wrote:
>> On 01/25/2013 02:12 PM, Jason Wang wrote:
>>> On 01/25/2013 01:40 PM, Wanlong Gao wrote:
>>>> On 01/25/2013 01:13 PM, Jason Wang wrote:
>>>>> On 01/25/2013 12:20 PM, Wanlong Gao wrote:
>>>>>> On 01/25/2013 11:28 AM, Jason Wang wrote:
>>>>>>> On 01/21/2013 07:25 PM, Wanlong Gao wrote:
>>>>>>>> Split out the clean affinity function to virtnet_clean_affinity().
>>>>>>>>
>>>>>>>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>>>>>>>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>>>>>>>> Cc: Jason Wang <jasowang@redhat.com>
>>>>>>>> Cc: Eric Dumazet <erdnetdev@gmail.com>
>>>>>>>> Cc: virtualization@lists.linux-foundation.org
>>>>>>>> Cc: netdev@vger.kernel.org
>>>>>>>> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
>>>>>>>> ---
>>>>>>>> V5->V6: NEW
>>>>>>>>
>>>>>>>>  drivers/net/virtio_net.c | 67 +++++++++++++++++++++++++++---------------------
>>>>>>>>  1 file changed, 38 insertions(+), 29 deletions(-)
>>>>>>>>
>>>>>>>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>>>>>>>> index 70cd957..1a35a8c 100644
>>>>>>>> --- a/drivers/net/virtio_net.c
>>>>>>>> +++ b/drivers/net/virtio_net.c
>>>>>>>> @@ -1016,48 +1016,57 @@ static int virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
>>>>>>>>  	return 0;
>>>>>>>>  }
>>>>>>>>  
>>>>>>>> -static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
>>>>>>>> +static void virtnet_clean_affinity(struct virtnet_info *vi, long hcpu)
>>>>>>>>  {
>>>>>>>>  	int i;
>>>>>>>>  	int cpu;
>>>>>>>>  
>>>>>>>> -	/* In multiqueue mode, when the number of cpu is equal to the number of
>>>>>>>> -	 * queue pairs, we let the queue pairs to be private to one cpu by
>>>>>>>> -	 * setting the affinity hint to eliminate the contention.
>>>>>>>> -	 */
>>>>>>>> -	if ((vi->curr_queue_pairs == 1 ||
>>>>>>>> -	     vi->max_queue_pairs != num_online_cpus()) && set) {
>>>>>>>> -		if (vi->affinity_hint_set)
>>>>>>>> -			set = false;
>>>>>>>> -		else
>>>>>>>> -			return;
>>>>>>>> -	}
>>>>>>>> -
>>>>>>>> -	if (set) {
>>>>>>>> -		i = 0;
>>>>>>>> -		for_each_online_cpu(cpu) {
>>>>>>>> -			virtqueue_/set_affinity(vi->rq[i].vq, cpu);
>>>>>>>> -			virtqueue_set_affinity(vi->sq[i].vq, cpu);
>>>>>>>> -			*per_cpu_ptr(vi->vq_index, cpu) = i;
>>>>>>>> -			i++;
>>>>>>>> -		}
>>>>>>>> -
>>>>>>>> -		vi->affinity_hint_set = true;
>>>>>>>> -	} else {
>>>>>>>> -		for(i = 0; i < vi->max_queue_pairs; i++) {
>>>>>>>> +	if (vi->affinity_hint_set) {
>>>>>>>> +		for (i = 0; i < vi->max_queue_pairs; i++) {
>>>>>>>>  			virtqueue_set_affinity(vi->rq[i].vq, -1);
>>>>>>>>  			virtqueue_set_affinity(vi->sq[i].vq, -1);
>>>>>>>>  		}
>>>>>>>>  
>>>>>>>>  		i = 0;
>>>>>>>> -		for_each_online_cpu(cpu)
>>>>>>>> +		for_each_online_cpu(cpu) {
>>>>>>>> +			if (cpu == hcpu)
>>>>>>>> +				continue;
>>>>>>>>  			*per_cpu_ptr(vi->vq_index, cpu) =
>>>>>>>>  				++i % vi->curr_queue_pairs;
>>>>>>>> +		}
>>>>>>>>  
>>>>>>> Some questions here:
>>>>>>>
>>>>>>> - Did we need reset the affinity of the queue here like the this?
>>>>>>>
>>>>>>> virtqueue_set_affinity(vi->sq[*per_cpu_ptr(vi->vq_index, hcpu)], -1);
>>>>>>> virtqueue_set_affinity(vi->rq[*per_cpu_ptr(vi->vq_index, hcpu)], -1);
>>>>>> I think no, we are going to unset the affinity of all the set queues,
>>>>>> include hcpu.
>>>>>>
>>>>>>> - Looks like we need also reset the percpu index when
>>>>>>> vi->affinity_hint_set is false.
>>>>>> Yes, follow this and the comment on [1/3].
>>>>>>
>>>>>>> - Does this really need this reset? Consider we're going to reset the
>>>>>>> percpu in CPU_DEAD?
>>>>>> I think resetting when CPU_DOWN_PREPARE can avoid selecting the wrong queue
>>>>>> on the dying CPU.
>>>>> Didn't understand this. What does 'wrong queue' here mean? Looks like
>>>>> you didn't change the preferable queue of the dying CPU and just change
>>>>> all others.
>>>> How about setting the vq index to -1 on hcpu when doing DOWN_PREPARE?
>>>> So that let it select txq to 0 when the CPU is dying.
>>> Looks safe, so look like what you're going to solve here is the the race
>>> between cpu hotplug and virtnet_set_channels(). A possible better
>>> solution is to serialize them by protecting virtnet_set_queues() by
>>> get_online_cpus() also. After this, we can make sure the number of
>>> channels were not changed during cpu hotplug, and looks like there's no
>>> need to reset the preferable queues in DOWN_PREPARE.
>>>
>>> What's your opinion?
>> IMHO, serialize every time will take lock and may slow down this path,
>> but the hot unplug path will be more cold than it. So I prefer reset the
>> preferable queues in DOWN_PREPARE but not serialize them. Agree?
> 
> I think it's ok since we're in control path. And the point is when
> you're trying to reset the affinity / preferable queues during cpu
> hotplug callback, there will be another request in
> virtnet_set_channels() which changing the number of queues. So the the
> result of cpus == queues may out of date. Anyway you need some
> synchronization.

Agree, then I will add {get|put}_online_cpus to serialize this, thank you.

Regards,
Wanlong Gao

> 
>>
>> Thanks,
>> Wanlong Gao
>>
>>> Thanks
>>>> Thanks,
>>>> Wanlong Gao
>>>>
>>>>>> Thanks,
>>>>>> Wanlong Gao
>>>>>>
>>>>>>> Thanks
>>>>>>>>  		vi->affinity_hint_set = false;
>>>>>>>>  	}
>>>>>>>>  }
>>>>>>>>  
>>>>>>>> +static void virtnet_set_affinity(struct virtnet_info *vi)
>>>>>>>> +{
>>>>>>>> +	int i;
>>>>>>>> +	int cpu;
>>>>>>>> +
>>>>>>>> +	/* In multiqueue mode, when the number of cpu is equal to the number of
>>>>>>>> +	 * queue pairs, we let the queue pairs to be private to one cpu by
>>>>>>>> +	 * setting the affinity hint to eliminate the contention.
>>>>>>>> +	 */
>>>>>>>> +	if (vi->curr_queue_pairs == 1 ||
>>>>>>>> +	    vi->max_queue_pairs != num_online_cpus()) {
>>>>>>>> +		if (vi->affinity_hint_set)
>>>>>>>> +			virtnet_clean_affinity(vi, -1);
>>>>>>>> +		else
>>>>>>>> +			return;
>>>>>>>> +	}
>>>>>>>> +
>>>>>>>> +	i = 0;
>>>>>>>> +	for_each_online_cpu(cpu) {
>>>>>>>> +		virtqueue_set_affinity(vi->rq[i].vq, cpu);
>>>>>>>> +		virtqueue_set_affinity(vi->sq[i].vq, cpu);
>>>>>>>> +		*per_cpu_ptr(vi->vq_index, cpu) = i;
>>>>>>>> +		i++;
>>>>>>>> +	}
>>>>>>>> +
>>>>>>>> +	vi->affinity_hint_set = true;
>>>>>>>> +}
>>>>>>>> +
>>>>>>>>  static void virtnet_get_ringparam(struct net_device *dev,
>>>>>>>>  				struct ethtool_ringparam *ring)
>>>>>>>>  {
>>>>>>>> @@ -1105,7 +1114,7 @@ static int virtnet_set_channels(struct net_device *dev,
>>>>>>>>  		netif_set_real_num_rx_queues(dev, queue_pairs);
>>>>>>>>  
>>>>>>>>  		get_online_cpus();
>>>>>>>> -		virtnet_set_affinity(vi, true);
>>>>>>>> +		virtnet_set_affinity(vi);
>>>>>>>>  		put_online_cpus();
>>>>>>>>  	}
>>>>>>>>  
>>>>>>>> @@ -1274,7 +1283,7 @@ static void virtnet_del_vqs(struct virtnet_info *vi)
>>>>>>>>  {
>>>>>>>>  	struct virtio_device *vdev = vi->vdev;
>>>>>>>>  
>>>>>>>> -	virtnet_set_affinity(vi, false);
>>>>>>>> +	virtnet_clean_affinity(vi, -1);
>>>>>>>>  
>>>>>>>>  	vdev->config->del_vqs(vdev);
>>>>>>>>  
>>>>>>>> @@ -1398,7 +1407,7 @@ static int init_vqs(struct virtnet_info *vi)
>>>>>>>>  		goto err_free;
>>>>>>>>  
>>>>>>>>  	get_online_cpus();
>>>>>>>> -	virtnet_set_affinity(vi, true);
>>>>>>>> +	virtnet_set_affinity(vi);
>>>>>>>>  	put_online_cpus();
>>>>>>>>  
>>>>>>>>  	return 0;
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

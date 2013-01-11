From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V3 1/2] virtio-net: fix the set affinity bug when CPU
	IDs are not consecutive
Date: Fri, 11 Jan 2013 16:37:45 +0800
Message-ID: <50EFCF59.5090800@redhat.com>
References: <1357639660-6660-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<87k3rn2qwb.fsf@rustcorp.com.au> <50ECCDF3.9050403@cn.fujitsu.com>
	<87a9sh3lru.fsf@rustcorp.com.au>
	<1357845142.2712.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <erdnetdev@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1357845142.2712.11.camel@bwh-desktop.uk.solarflarecom.com>
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

On 01/11/2013 03:12 AM, Ben Hutchings wrote:
> On Thu, 2013-01-10 at 11:19 +1030, Rusty Russell wrote:
>> Wanlong Gao <gaowanlong@cn.fujitsu.com> writes:
>>> On 01/09/2013 07:31 AM, Rusty Russell wrote:
>>>> Wanlong Gao <gaowanlong@cn.fujitsu.com> writes:
>>>>>   */
>>>>>  static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
>>>>>  {
>>>>> -	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
>>>>> -		  smp_processor_id();
>>>>> +	int txq = 0;
>>>>> +
>>>>> +	if (skb_rx_queue_recorded(skb))
>>>>> +		txq = skb_get_rx_queue(skb);
>>>>> +	else if ((txq = per_cpu(vq_index, smp_processor_id())) == -1)
>>>>> +		txq = 0;
>>>> You should use __get_cpu_var() instead of smp_processor_id() here, ie:
>>>>
>>>>         else if ((txq = __get_cpu_var(vq_index)) == -1)
>>>>
>>>> And AFAICT, no reason to initialize txq to 0 to start with.
>>>>
>>>> So:
>>>>
>>>>         int txq;
>>>>
>>>>         if (skb_rx_queue_recorded(skb))
>>>> 		txq = skb_get_rx_queue(skb);
>>>>         else {
>>>>                 txq = __get_cpu_var(vq_index);
>>>>                 if (txq == -1)
>>>>                         txq = 0;
>>>>         }
>>> Got it, thank you.
>>>
>>>> Now, just to confirm, I assume this can happen even if we use vq_index,
>>>> right, because of races with virtnet_set_channels?
>>> I still can't understand this race, could you explain more? thank you.
>> I assume that someone can call virtnet_set_channels() while we are
>> inside virtnet_select_queue(), so they reduce dev->real_num_tx_queues,
>> causing virtnet_set_channels to do:
>>
>> 	while (unlikely(txq >= dev->real_num_tx_queues))
>> 		txq -= dev->real_num_tx_queues;
>>
>> Otherwise, when is this loop called?
> In fact, this race can result in the TX scheduler using a queue that has
> been disabled, or other weirdness (consider what happens if
> real_num_tx_queues increases between those two uses).
>
> virtnet_set_channels() really must disable TX temporarily:
>
> 	netif_tx_lock(dev);
> 	netif_device_detach(dev);
> 	netif_tx_unlock(dev);
> 	...
> 	netif_device_attach(dev);
>
> Ben.
>

Michael, I think the future plan is trying to use multiqueue by default
instead of doing switching between the modes? If yes, we can temporarily
disable the tx instead of doing extra hacks.

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v2 8/9] xen-netback: Timeout packets in RX path
Date: Mon, 16 Dec 2013 17:16:17 +0000
Message-ID: <52AF3561.9020904@citrix.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com> <1386892097-15502-9-git-send-email-zoltan.kiss@citrix.com> <20131213154406.GO21900@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131213154406.GO21900@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/12/13 15:44, Wei Liu wrote:
> On Thu, Dec 12, 2013 at 11:48:16PM +0000, Zoltan Kiss wrote:
>> A malicious or buggy guest can leave its queue filled indefinitely, in which
>> case qdisc start to queue packets for that VIF. If those packets came from an
>> another guest, it can block its slots and prevent shutdown. To avoid that, we
>> make sure the queue is drained in every 10 seconds
>>
>
> Oh I see where the 10 second constraint in previous patch comes from.
>
> Could you define a macro for this constant then use it everywhere.
Well, they are not entirely the same thing, but worth making them the 
same. How about using "unmap_timeout > (rx_drain_timeout_msecs/1000)" in 
xenvif_free()? Then netback won't complain about a stucked page if an 
another guest is permitted to hold on to it.

>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> ---
> [...]
>> +static void xenvif_wake_queue(unsigned long data)
>> +{
>> +	struct xenvif *vif = (struct xenvif *)data;
>> +
>> +	netdev_err(vif->dev, "timer fires\n");
>
> What timer? This error message needs to be more specific.
I forgot to remove this, I used it for debugging only. The other message 
2 line below is more important

>
>> +	if (netif_queue_stopped(vif->dev)) {
>> +		netdev_err(vif->dev, "draining TX queue\n");
>> +		netif_wake_queue(vif->dev);
>> +	}
>> +}
>> +
>>   static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>   {
>>   	struct xenvif *vif = netdev_priv(dev);
>> @@ -141,8 +152,13 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>   	 * then turn off the queue to give the ring a chance to
>>   	 * drain.
>>   	 */
>> -	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed))
>> +	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed)) {
>> +		vif->wake_queue.function = xenvif_wake_queue;
>> +		vif->wake_queue.data = (unsigned long)vif;
>>   		xenvif_stop_queue(vif);
>> +		mod_timer(&vif->wake_queue,
>> +			jiffies + rx_drain_timeout_jiffies);
>> +	}
>>
>
> Do you need to use jiffies_64 instead of jiffies?
Well, we don't use time_after_eq here, just set the timer. AFAIK that 
should be OK.

> This timer is only armed when ring is full. So what happens when the
> ring is not full and some other parts of the system holds on to the
> packets forever? Can this happen?
This timer is not to protect the receiving guest, but to protect the 
sender. If the ring is not full, then netback will put the packet there 
and release the skb back.
This patch is to replace delayed copy from classic kernel times. There 
we handled this problem on the sender side: after a timer expired we 
made a local copy of the packet and released back the pages. It had 
stronger guarantees that a guest will always get back its pages, but it 
also caused more unnecessary copies when the system is already loaded 
and we should really thrash the packet. Unfortunately we can't do that 
as the sender is no longer in control.
Instead I choose this more lightweight solution, because practice said 
an another guest's queue is the only place where the packet can get 
stucked, especially if that guest is malicious, buggy, or too slow.
Other parts (e.g. a driver) can also hold on the packet if they are 
buggy, but then we should fix that bug rather than feed it with more 
guest pages.

Zoli

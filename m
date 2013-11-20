From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC net-next PATCH] macvtap: Add packet capture support
Date: Wed, 20 Nov 2013 15:35:22 -0500
Message-ID: <528D1D0A.3010505@redhat.com>
References: <1384970649-29839-1-git-send-email-vyasevic@redhat.com> <20131120181949.GB25569@redhat.com> <528D0F48.60304@redhat.com> <20131120200658.GA11070@redhat.com> <528D1935.9020403@redhat.com> <20131120203027.GA11386@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41254 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754986Ab3KTV1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 16:27:17 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rAKLRDKx025710
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 16:27:16 -0500
In-Reply-To: <20131120203027.GA11386@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2013 03:30 PM, Michael S. Tsirkin wrote:
> On Wed, Nov 20, 2013 at 03:19:01PM -0500, Vlad Yasevich wrote:
>> On 11/20/2013 03:06 PM, Michael S. Tsirkin wrote:
>>> On Wed, Nov 20, 2013 at 02:36:40PM -0500, Vlad Yasevich wrote:
>>>> On 11/20/2013 01:19 PM, Michael S. Tsirkin wrote:
>>>>> On Wed, Nov 20, 2013 at 01:04:09PM -0500, Vlad Yasevich wrote:
>>>>>> Currently it is impossible to capture traffic when using a macvtap
>>>>>> device.  The reason is that all capture handling is done either in
>>>>>> dev_hard_start_xmit() or in __netif_receive_skb_core().  Macvtap
>>>>>> currenlty doesn't use dev_hard_start_xmit(), and at the time the
>>>>>> packet traverses __netif_receive_skb_core, the skb->dev is set to
>>>>>> the lower-level device that doesn't end up matching macvtap.
>>>>>>
>>>>>> To solve the issue, use dev_hard_start_xmit() on the output path.
>>>>>> On the input path, it is toughter to solve since macvtap ends up
>>>>>> consuming the skb so there is nothing more left for
>>>>>> __netif_receive_skb_core() to do.
>>>
>>> Actually I thought I understand what you are saying here, but now I
>>> don't. bridge installs rx handler exactly in the same way.
>>> packet handlers seem to be called before the rx handlers so
>>> everything should just work.
>>>
>>> Is this about the bridge mode again?
>>
>> No.  It has to do with bridge submitting the frame back to the
>> network stack to forward it to the ports, but macvtap ends up
>> stealing it.
> 
> Confused.
> 
>         rx_handler = rcu_dereference(skb->dev->rx_handler);
>         if (rx_handler) {
>                 if (pt_prev) {
>                         ret = deliver_skb(skb, pt_prev, orig_dev);
>                         pt_prev = NULL;
>                 }
>                 switch (rx_handler(&skb)) {
> 
> 		....
> 
> so packet handlers (including packet socket)
> seem to be invoked before rx handlers (including bridge and macvtap).
> 
> What's the issue then?
> 
> I guess I'm missing something obvious.

In case of macvtap0@eth0, before rx_handler is invoked skb->dev == eth0.
During the macvlan rx_handler, skb->dev = macvtap0, and the packet is
stolen and delivered to the socket, thus no capture.

In the case of the bridge (eth0, eth1), during the rx_handler
skb->dev = bridge.  Bridge calls netif_receive_skb() again, when in
promisc mode, and now packet is captured.

-vlad
> 
> 
> 
>> Also, bridge, if running in promisc mode will hand the frame up
>> (as if it received it).  See the IFF_PROMISC code in
>> br_handle_frame_finish().
>> So, if someone is capturing on the bridge itself, this lets it
>> see the packets even though they are not destined for the bridge
>> device.
> 
> Yes, that's quite expected: same thing will happen with
> real hardware: set it to promisc, see lots of packets
> destined at others.
> 
>>>
>>>>  A simple solution is to
>>>>>> pull the code that delivers things to the taps/captures into
>>>>>> its own function and allow macvtap to call it from its receive
>>>>>> routine.
>>>>>>
>>>>>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>>>>>> ---
>>>>>> This is only an RFC.  I'd like to solicit comments on this simple
>>>>>> approach.
>>>>>
>>>>> I'm kind of worried about this. What worries me is that normally
>>>>> if you have a packet socket bound to all interfaces, what it shows is
>>>>> traffic to/from the box.
>>>>>
>>>>> This might be a bug for someone, but I suspect at this point this
>>>>> is part of the ABI.
>>>>>
>>>>> But macvtap bypasses most of the host networking stack,
>>>>> So I worry that suddenly showing these packets would be confusing.
>>>>
>>>> Is it really different from using bridge and tap?  If someone
>>>> does 'tcpdump -i any', they will see packets sent by the guest with
>>>> bridge+tap.
>>>>  It makes sense to do that same thing for macvtap, no?
>>>
>>> I was going by your comments not the code.
>>> Assuming we never showed macvtap traffic this might
>>> be part of ABI.
>>
>> BTW, if we end up doing it with a new rx_handler, it will end up
>> showing exactly the same traffic is this patch does because the
>> common path in __netif_receive_skb_core() will run and deliver
>> to all registered eligible entries in ptype_all.
>>
>> -vlad
> 
> Dave here thinks it's not a problem, I trust him ...
> 
>>>
>>>>>
>>>>> Assuming we want to show this traffic, I think it's preferable to
>>>>> -		if (!ptype->dev || ptype->dev == skb->dev) {
>>>>> +		if (ptype->dev == skb->dev) {
>>>>> so you have to bind to macvtap explicitly to see the traffic.
>>>>>
>>>>>
>>>>> Of course when you start binding to specific macvtaps
>>>>> it doesn't scale well because we'll have a long list
>>>>> on ptype_all suddenly.
>>>>
>>>> How likely is that really?  ptype_all doesn't scale as it.
>>>> Any time you don't set the protocol field, the entry goes
>>>> into ptype_all.  Macvtap doesn't change that.  You can
>>>> create a long list in ptype all if you have lots of guests and
>>>> you want to snoop on each guest separately thus binding to tap
>>>> device.
>>>>
>>>> -vlad
>>>>
>>>>> This might mean we need to keep this list per-device ...
>>>>>
>>>>>> A more complicated solution would have been to give
>>>>>> macvtap its own rx_handler and return RX_HANDLER_ANOTHER during
>>>>>> receive operation to make the packet go through another round of
>>>>>> capturing and hit the macvtap rx_handler.  I thought this would
>>>>>> hurt performance too much for no real gain.
>>>>>>
>>>>>> Thanks
>>>>>> -vlad
>>>>>>
>>>>>>  drivers/net/macvtap.c     |  4 +++-
>>>>>>  include/linux/netdevice.h |  2 ++
>>>>>>  net/core/dev.c            | 33 ++++++++++++++++++++++++++-------
>>>>>>  3 files changed, 31 insertions(+), 8 deletions(-)
>>>>>>
>>>>>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>>>>>> index dc76670..0ed8fae 100644
>>>>>> --- a/drivers/net/macvtap.c
>>>>>> +++ b/drivers/net/macvtap.c
>>>>>> @@ -334,6 +334,7 @@ drop:
>>>>>>   */
>>>>>>  static int macvtap_receive(struct sk_buff *skb)
>>>>>>  {
>>>>>> +	netif_receive_skb_taps(skb, true);
>>>>>>  	skb_push(skb, ETH_HLEN);
>>>>>>  	return macvtap_forward(skb->dev, skb);
>>>>>>  }
>>>>>> @@ -727,8 +728,9 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>>>>>>  		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
>>>>>>  	}
>>>>>>  	if (vlan) {
>>>>>> +		skb->dev = vlan->dev;
>>>>>>  		local_bh_disable();
>>>>>> -		macvlan_start_xmit(skb, vlan->dev);
>>>>>> +		dev_hard_start_xmit(skb, vlan->dev, NULL, NULL);
>>>>>>  		local_bh_enable();
>>>>>>  	} else {
>>>>>>  		kfree_skb(skb);
>>>>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>>>> index 8b3de7c..84880eb 100644
>>>>>> --- a/include/linux/netdevice.h
>>>>>> +++ b/include/linux/netdevice.h
>>>>>> @@ -2383,6 +2383,8 @@ void dev_kfree_skb_any(struct sk_buff *skb);
>>>>>>  int netif_rx(struct sk_buff *skb);
>>>>>>  int netif_rx_ni(struct sk_buff *skb);
>>>>>>  int netif_receive_skb(struct sk_buff *skb);
>>>>>> +struct packet_type *netif_receive_skb_taps(struct sk_buff *skb,
>>>>>> +					   bool last_deliver);
>>>>>>  gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb);
>>>>>>  void napi_gro_flush(struct napi_struct *napi, bool flush_old);
>>>>>>  struct sk_buff *napi_get_frags(struct napi_struct *napi);
>>>>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>>>>> index da9c5e1..50f0ac4 100644
>>>>>> --- a/net/core/dev.c
>>>>>> +++ b/net/core/dev.c
>>>>>> @@ -3484,6 +3484,31 @@ static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
>>>>>>  	}
>>>>>>  }
>>>>>>  
>>>>>> +struct packet_type *netif_receive_skb_taps(struct sk_buff *skb,
>>>>>> +					   bool last_deliver)
>>>>>> +{
>>>>>> +	struct packet_type *ptype, *pt_prev = NULL;
>>>>>> +	struct net_device *orig_dev;
>>>>>> +
>>>>>> +	if (list_empty(&ptype_all))
>>>>>> +		return NULL;
>>>>>> +
>>>>>> +	orig_dev = skb->dev;
>>>>>> +	list_for_each_entry_rcu(ptype, &ptype_all, list) {
>>>>>> +		if (!ptype->dev || ptype->dev == skb->dev) {
>>>>>> +			if (pt_prev)
>>>>>> +				deliver_skb(skb, pt_prev, orig_dev);
>>>>>> +			pt_prev = ptype;
>>>>>> +		}
>>>>>> +	}
>>>>>> +
>>>>>> +	if (last_deliver && pt_prev)
>>>>>> +		deliver_skb(skb, pt_prev, orig_dev);
>>>>>> +
>>>>>> +	return pt_prev;
>>>>>> +}
>>>>>> +EXPORT_SYMBOL_GPL(netif_receive_skb_taps);
>>>>>> +
>>>>>>  static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
>>>>>>  {
>>>>>>  	struct packet_type *ptype, *pt_prev;
>>>>>> @@ -3535,13 +3560,7 @@ another_round:
>>>>>>  	if (pfmemalloc)
>>>>>>  		goto skip_taps;
>>>>>>  
>>>>>> -	list_for_each_entry_rcu(ptype, &ptype_all, list) {
>>>>>> -		if (!ptype->dev || ptype->dev == skb->dev) {
>>>>>> -			if (pt_prev)
>>>>>> -				ret = deliver_skb(skb, pt_prev, orig_dev);
>>>>>> -			pt_prev = ptype;
>>>>>> -		}
>>>>>> -	}
>>>>>> +	pt_prev = netif_receive_skb_taps(skb, false);
>>>>>>  
>>>>>>  skip_taps:
>>>>>>  #ifdef CONFIG_NET_CLS_ACT
>>>>>> -- 
>>>>>> 1.8.4.2

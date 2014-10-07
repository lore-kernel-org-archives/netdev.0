From: Jason Baron <jbaron@akamai.com>
Subject: Re: macvlan: optimizing the receive path?
Date: Tue, 07 Oct 2014 13:35:42 -0400
Message-ID: <5434246E.1000403@akamai.com>
References: <542DB55D.3090601@akamai.com> <20141004.204203.2211720828886085354.davem@davemloft.net> <5432936D.7010906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
To: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:45326 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754295AbaJGRfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:35:43 -0400
In-Reply-To: <5432936D.7010906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2014 09:04 AM, Vlad Yasevich wrote:
> On 10/04/2014 08:42 PM, David Miller wrote:
>> From: Jason Baron <jbaron@akamai.com>
>> Date: Thu, 02 Oct 2014 16:28:13 -0400
>>
>>> --- a/drivers/net/macvlan.c
>>> +++ b/drivers/net/macvlan.c
>>> @@ -321,8 +321,8 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
>>>         skb->dev = dev;
>>>         skb->pkt_type = PACKET_HOST;
>>>  
>>> -       ret = netif_rx(skb);
>>> -
>>> +      macvlan_count_rx(vlan, len, true, 0);
>>> +      return RX_HANDLER_ANOTHER;
>>>  out:
>>>         macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
>>>         return RX_HANDLER_CONSUMED;
>>
>> That last argument to macvlan_count_rx() is a bool and thus should be
>> specified as "false".  Yes I know other areas of this file get it
>> wrong too.
>>

ok. I can fix those up too while here.

>> Also, what about GRO?  Won't we get GRO processing if we do this via
>> netif_rx() but not via the RX_HANDLER_ANOTHER route?  Just curious...
> 
> Wouldn't GRO already happen at the lower level?  For macvlan-to-macvlan,
> you'd typically have large packets so no need for GRO.
> 

Yes, afaict gro is happening a layer below __netif_receive_skb_core().

Here are some results of this optimization on 3.17 using macvlan with
lxc. Test case is (average of 3 runs):

for i in {35,50,65,80,95,110,125,140,155};
do super_netperf $i netperf -H $ip -t TCP_RR;
done

trans./sec (3.17)

494016
612806
673100
696982
710494
716830
714729
713478
711056

trans./sec (3.17 + macvlan patch)

517159  +(4.684733558%)
628382  +(2.541860742%)
669688  -(0.5069080835%)
706181  +(1.319833855%)
716660  +(0.8677995555%)
719581  +(0.3838661811%)
718738  +(0.5609585358%)
718904  +(0.7605470482%)
718344  +(1.02509555%)

On the host I can see that the idle time goes to 0, so this would
appear to be an improvement. I also observed that enqueue_to_backlog()
and process_backlog() are no longer in the 'perf' profiles as
expected.

So if there are no objections, I will post as a formal patch.

Thanks,

-Jason

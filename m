From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 22:32:55 -0700
Message-ID: <4ADE9D07.2020506@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com> <4ADE2735.9000807@candelatech.com> <OFE19FAAE4.E89690B3-ON65257656.001B6B90-65257656.001CA0C0@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org,
	robert@herjulf.net
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51627 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbZJUFdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 01:33:06 -0400
In-Reply-To: <OFE19FAAE4.E89690B3-ON65257656.001B6B90-65257656.001CA0C0@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar2 wrote:
> Ben Greear <greearb@candelatech.com>  wrote on 10/21/2009 02:40:13 AM:
>
> Coming back a bit to this post:
>
>   
>>> -   queue_map = skb_get_queue_mapping(pkt_dev->skb);
>>> +   queue_map = pkt_dev->cur_queue_map;
>>> +   /*
>>> +    * tells skb_tx_hash() to use this tx queue.
>>> +    * We should reset skb->mapping before each xmit() because
>>> +    * xmit() might change it.
>>> +    */
>>> +   skb_record_rx_queue(pkt_dev->skb, queue_map);
>>>      txq = netdev_get_tx_queue(odev, queue_map);
>>>       
>> I think that must be wrong.  The record_rx_queue sets it to queue_map + 1,
>>     
>> but the hard-start-xmit method (in ixgbe/ixgbe_main.c, at least), takes the
>> skb->queue_map and uses it as an index with no subtraction.
>>     
>
> But that should work fine. record_rx_q sets queue_mapping to +1,
> but skb_tx_hash calls skb_get_rx_queue, which does a -1 on this
> value, and updates that value into queue_mapping. Hence it will
> not cross the txq boundary. Drivers can use the queue_map value
> directly without requiring to subtract.
>   
When using pktgen on real physical hardware, there is none of the 
skb_tx_hash or dev_queue_xmit
logic called, just the hard-start-xmit.  That is why it fails to update 
the proper queue with
his first patch. 

On virtual devices like mac-vlans, the logic probably worked ok since it 
goes
through dev_queue_xmit.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com



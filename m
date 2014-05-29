From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/2] macvlan: slight optimization for passthru
 mode
Date: Thu, 29 May 2014 12:16:40 +0800
Message-ID: <5386B4A8.6090302@huawei.com>
References: <1401187996-10252-1-git-send-email-dingtianhong@huawei.com> <1401187996-10252-2-git-send-email-dingtianhong@huawei.com> <53861500.7050803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>, <kaber@trash.net>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:52448 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755478AbaE2ERQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 00:17:16 -0400
In-Reply-To: <53861500.7050803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/29 0:55, Vlad Yasevich wrote:
> On 05/27/2014 06:53 AM, Ding Tianhong wrote:
>> When the maclvan is in passthru mode, there should be one(and only one)
>> macvlan dev, so no need to check the vlan point, remove the judgement and
>> the redundant variables.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  drivers/net/macvlan.c | 15 +++++++--------
>>  1 file changed, 7 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>> index 55faff3..c9ada17 100644
>> --- a/drivers/net/macvlan.c
>> +++ b/drivers/net/macvlan.c
>> @@ -274,7 +274,6 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
>>  	const struct ethhdr *eth = eth_hdr(skb);
>>  	const struct macvlan_dev *vlan;
>>  	const struct macvlan_dev *src;
>> -	struct net_device *dev;
>>  	unsigned int len = 0;
>>  	int ret = NET_RX_DROP;
>>  
>> @@ -300,16 +299,16 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
>>  		return RX_HANDLER_PASS;
>>  	}
>>  
>> -	if (port->passthru)
>> +	if (port->passthru) {
>>  		vlan = list_first_or_null_rcu(&port->vlans,
>>  					      struct macvlan_dev, list);
>> -	else
>> +	} else {
>>  		vlan = macvlan_hash_lookup(port, eth->h_dest);
>> -	if (vlan == NULL)
>> -		return RX_HANDLER_PASS;
>> +		if (vlan == NULL)
>> +			return RX_HANDLER_PASS;
>> +	}
>>  
> 
> I don't think you can do that.  del_link() happens before ndo_uninit(),
> and we unregister the rx_handler in ndo_uninit().  As such it is
> possible to enter the rx_handler while the ports->vlans is empty.
> 
> -vlad

Yes, I miss it, the ports->vlans is already empty when unregister rx_handler, thanks.

Ding

> 
>> -	dev = vlan->dev;
>> -	if (unlikely(!(dev->flags & IFF_UP))) {
>> +	if (unlikely(!(vlan->dev->flags & IFF_UP))) {
>>  		kfree_skb(skb);
>>  		return RX_HANDLER_CONSUMED;
>>  	}
>> @@ -318,7 +317,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
>>  	if (!skb)
>>  		goto out;
>>  
>> -	skb->dev = dev;
>> +	skb->dev = vlan->dev;
>>  	skb->pkt_type = PACKET_HOST;
>>  
>>  	ret = netif_rx(skb);
>>
> 
> 
> 

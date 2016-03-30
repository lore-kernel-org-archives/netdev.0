From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH RFC net-next] net: core: Pass XPS select queue decision to
 skb_tx_hash
Date: Wed, 30 Mar 2016 16:23:41 +0300
Message-ID: <56FBD35D.4090805@dev.mellanox.co.il>
References: <1459290252-4121-1-git-send-email-saeedm@mellanox.com>
 <56FB1B64.40301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: John Fastabend <john.fastabend@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35250 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbcC3NXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 09:23:45 -0400
Received: by mail-wm0-f65.google.com with SMTP id 139so14905816wmn.2
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 06:23:44 -0700 (PDT)
In-Reply-To: <56FB1B64.40301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3/30/2016 3:18 AM, John Fastabend wrote:
> I would prefer to not have another strange quirk users have to 
> remember in order to do tx classification. So with this change 
> depending on the driver the queue selection precedence changes. 
This change doesn't depend on the driver it affects all drivers that 
implement the select queue ndo and use the default fallback 
"pick_tx_queue" which this patch came to fix, or any driver that doesn't 
implement the ndo (the fallback is the default in this case).
> In short I agree with the problem statement but think we can find a 
> better solution. One idea that comes to mind is we can have a tc 
> action to force the queue selection? Now that we have the egress tc 
> hook it would probably be fairly cheap to implement and if users want 
> this behavior they can ask for it explicitly. If your thinking about 
> tc stuff we could fix the tooling to set this action when ever dcb is 
> turned on or hardware rate limiting is enabled, etc. And even if we 
> wanted we could have the driver add the rule in the cases where 
> firmware protocols are configuring the QOS/etc. 
Why would you ask for a bug fix explicitly ? IMHO this how I expect the 
pick _tx_queue routine to behave, why would I disable XPS in order for 
select queue to choose according TC QoS ?
as this patch suggests we can benefit from both without any additional 
tooling !

>>   	if (skb_vlan_tag_present(skb))
>>   		up = skb_vlan_tag_get(skb) >> VLAN_PRIO_SHIFT;
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index cb0d5d0..ad81ffe 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -3130,16 +3130,16 @@ static inline int netif_set_xps_queue(struct net_device *dev,
>>   #endif
>>   
>>   u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
>> -		  unsigned int num_tx_queues);
>> +		  unsigned int num_tx_queues, int txq_hint);
>>   
> [...]
>
> And all this seems like it would only ever be called by drivers select
> queue routines which I really wish we could kill off one of these days
> instead of add to. Now if the signal is something higher in the stack
> and not the driver I think it is OK.
I agree, drivers shouldn't call this function, the only reason drivers 
call this function is to bypass get_xps_queue
and after this patch i don't think driver will need to call it, since it 
will be called even if XPS is configured.

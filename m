From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] net: Account for all vlan headers in skb_mac_gso_segment
Date: Wed, 26 Mar 2014 12:20:50 -0400
Message-ID: <5332FE62.504@redhat.com>
References: <1395849071-15432-1-git-send-email-vyasevic@redhat.com> <1395850483.12610.213.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46737 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755617AbaCZQUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 12:20:54 -0400
In-Reply-To: <1395850483.12610.213.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2014 12:14 PM, Eric Dumazet wrote:
> On Wed, 2014-03-26 at 11:51 -0400, Vlad Yasevich wrote:
>> skb_network_protocol() already accounts for multiple vlan
>> headers that may be present in the skb.  However, skb_mac_gso_segment()
>> doesn't know anything about it and assumes that skb->mac_len
>> is set correctly to skip all mac headers.  That may not
>> always be the case.  If we are simply forwarding the packet (via
>> bridge or macvtap), all vlan headers may not be accounted for.
>>
>> A simple solution is to allow skb_network_protocol to return
>> the vlan depth it has calculated.  This way skb_mac_gso_segment
>> will correctly skip all mac headers.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>  include/linux/netdevice.h |  2 +-
>>  net/core/dev.c            | 12 ++++++++----
>>  net/core/skbuff.c         |  2 +-
>>  3 files changed, 10 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index d855794..18b8c1b 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -3015,7 +3015,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, netdev_features_t features)
>>  {
>>  	return __skb_gso_segment(skb, features, true);
>>  }
>> -__be16 skb_network_protocol(struct sk_buff *skb);
>> +__be16 skb_network_protocol(struct sk_buff *skb, int *depth);
>>  
>>  static inline bool can_checksum_protocol(netdev_features_t features,
>>  					 __be16 protocol)
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index a98f7fa..49c41e6 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2287,7 +2287,7 @@ out:
>>  }
>>  EXPORT_SYMBOL(skb_checksum_help);
>>  
>> -__be16 skb_network_protocol(struct sk_buff *skb)
>> +__be16 skb_network_protocol(struct sk_buff *skb, int *depth)
>>  {
>>  	__be16 type = skb->protocol;
>>  	int vlan_depth = ETH_HLEN;
>> @@ -2314,6 +2314,9 @@ __be16 skb_network_protocol(struct sk_buff *skb)
>>  		vlan_depth += VLAN_HLEN;
>>  	}
>>  
>> +	if (depth)
>> +		*depth = vlan_depth;
> 
> expensive test, just always pass a non NULL pointer, to a dummy stack
> variable.
> 
>> +
>>  	return type;
>>  }
>>  
>> @@ -2327,12 +2330,13 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
>>  {
>>  	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
>>  	struct packet_offload *ptype;
>> -	__be16 type = skb_network_protocol(skb);
>> +	int vlan_depth = 0;
> vlan_depth = ETH_HLEN;

safer to make it skb->mac_len.

> 
>> +	__be16 type = skb_network_protocol(skb, &vlan_depth);
>>  
>>  	if (unlikely(!type))
>>  		return ERR_PTR(-EINVAL);
>>  
>> -	__skb_pull(skb, skb->mac_len);
>> +	__skb_pull(skb, vlan_depth > skb->mac_len ? vlan_depth : skb->mac_len);
> 
> Please remove this test

Couldn't mac_len be larger that ETH_HLEN already?

> 
> 	__skb_pull(skb, vlan_depth);
> 

The other variant of this patch that I tested was simply adjusting
skb->mac_len directly in skb_network_protocol().  I didn't encounter any
issues with it, but didn't like the potential side-effects for GSO
and thus didn't send it.  Can you see any issue with that approach?

Thanks
-vlad

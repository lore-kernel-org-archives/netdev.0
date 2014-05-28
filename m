From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] net: fix wrong mac_len calculation for vlans
Date: Wed, 28 May 2014 17:35:54 +0200
Message-ID: <5386025A.3030104@redhat.com>
References: <1401290644-19439-1-git-send-email-nikolay@redhat.com> <1401291540.3645.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>,
	Daniel Borkman <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9889 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753594AbaE1Pkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 11:40:45 -0400
In-Reply-To: <1401291540.3645.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2014 05:39 PM, Eric Dumazet wrote:
> On Wed, 2014-05-28 at 17:24 +0200, Nikolay Aleksandrov wrote:
> 
>>
>>  net/core/dev.c | 16 +++++++++++++++-
>>  1 file changed, 15 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 9abc503b19b7..94167fc660b1 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2283,8 +2283,8 @@ EXPORT_SYMBOL(skb_checksum_help);
>>  
>>  __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
>>  {
>> +	unsigned int vlan_depth = skb->mac_len;
>>  	__be16 type = skb->protocol;
>> -	int vlan_depth = skb->mac_len;
>>  
>>  	/* Tunnel gso handlers can set protocol to ethernet. */
>>  	if (type == htons(ETH_P_TEB)) {
>> @@ -2297,6 +2297,20 @@ __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
>>  		type = eth->h_proto;
>>  	}
>>  
>> +	/* if skb->protocol is 802.1Q/AD then the header should already be
>> +	 * present at mac_len - VLAN_HLEN (if mac_len > 0), or at
>> +	 * ETH_HLEN otherwise
>> +	 */
>> +	if (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
>> +		if (vlan_depth) {
>> +			if (unlikely(WARN_ON(vlan_depth < VLAN_HLEN)))
>> +				return 0;
>> +			vlan_depth -= VLAN_HLEN;
>> +		} else {
>> +			vlan_depth = ETH_HLEN;
>> +		}
>> +	}
> 
> It would be nice not having 4 tests in fast path for non vlan traffic
> 
>> +
>>  	while (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
>>  		struct vlan_hdr *vh;
>>  
> 
> Like :
> 
>        if (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
>                 if (vlan_depth) {
>                        if (unlikely(WARN_ON(vlan_depth < VLAN_HLEN)))
>                                return 0;
>                        vlan_depth -= VLAN_HLEN;
>                 } else {
>                        vlan_depth = ETH_HLEN;
>                 }
> 		do {
> 			struct vlan_hdr *vh;
> 
> 			if (unlikely(!pskb_may_pull(skb, vlan_depth + VLAN_HLEN)))
>  	                	return 0;
> 
>  	                vh = (struct vlan_hdr *)(skb->data + vlan_depth);
>  	                type = vh->h_vlan_encapsulated_proto;
>  	                vlan_depth += VLAN_HLEN;
> 		} while (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD));
>         }
> 	
> 
> 
Very good suggestion, I'll adjust the patch and post a v2.

Thanks,
 Nik

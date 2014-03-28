From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net] net: Account for all vlan headers in skb_mac_gso_segment
Date: Thu, 27 Mar 2014 21:05:41 -0400
Message-ID: <5334CAE5.6020806@redhat.com>
References: <1395955578-16715-1-git-send-email-vyasevic@redhat.com> <1395958890.12610.324.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756172AbaC1BFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 21:05:43 -0400
In-Reply-To: <1395958890.12610.324.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/2014 06:21 PM, Eric Dumazet wrote:
> On Thu, 2014-03-27 at 17:26 -0400, Vlad Yasevich wrote:
> 
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 869c7af..cac38ba 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -2866,8 +2866,9 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>>  	int err = -ENOMEM;
>>  	int i = 0;
>>  	int pos;
>> +	int dummy;
>>  
>> -	proto = skb_network_protocol(head_skb);
>> +	proto = skb_network_protocol(head_skb, &dummy);
>>  	if (unlikely(!proto))
>>  		return ERR_PTR(-EINVAL);
>>  
> 
> I am wondering if '&dummy' could be replaced by &doffset.
> 
> We have :
> 
> unsigned int doffset = head_skb->data - skb_mac_header(head_skb);
> 
> It looks like this is the same content than 'dummy', right ?
> 

No, that shouldn't be.  doffset is the offset of data past the
ip and tcp headers.  Dummy above will usually be the size of mac header
which at this point is useless to us.   The only time it might
be useful is if we have more encapsulations inside the tcp/udp
headers that skb_network_protocol would actually parse
(may be vlan on top of vxlan, so that vlan tagged frame is put
inside the UDP payload.  not sure if its possible).  But I think
this is already handled.

-vlad

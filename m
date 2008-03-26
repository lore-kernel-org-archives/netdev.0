From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH][ICMP]: Dst entry leak in icmp_send host re-lookup code.
Date: Wed, 26 Mar 2008 12:02:34 +0300
Message-ID: <47EA112A.2070406@openvz.org>
References: <47E91CD0.8000901@openvz.org> <20080326033200.GA31748@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Denis Lunev <den@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50782 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387AbYCZJCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 05:02:43 -0400
In-Reply-To: <20080326033200.GA31748@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Mar 25, 2008 at 06:40:00PM +0300, Pavel Emelyanov wrote:
>> Commit 8b7817f3a959ed99d7443afc12f78a7e1fcc2063 ([IPSEC]: Add ICMP host
>> relookup support) introduced some dst leaks on error paths: the rt
>> pointer can be forgotten to be put. Fix it bu going to a proper label.
>>
>> Found after net namespace's lo refused to unregister :) Many thanks to 
>> Den for valuable help during debugging.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> Thanks for catching this!
> 
>> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
>> index ff9a8e6..db231cb 100644
>> --- a/net/ipv4/icmp.c
>> +++ b/net/ipv4/icmp.c
>> @@ -594,11 +594,11 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>>  			rt = NULL;
>>  			break;
>>  		default:
>> -			goto out_unlock;
>> +			goto ende;
>>  		}
> 
> I'm not sure about this bit though because xfrm_lookup is meant
> to free the route on error.

Well, it indeed does, we've missed that fact. Even though it is
set to NULL, as Denis pointed out, this hunk is now needed here.

David, plz, disregard this patch, I'll send a new one in a moment.

>>  		if (xfrm_decode_session_reverse(skb_in, &fl, AF_INET))
>> -			goto out_unlock;
>> +			goto ende;
>>  
>>  		if (inet_addr_type(net, fl.fl4_src) == RTN_LOCAL)
>>  			err = __ip_route_output_key(net, &rt2, &fl);
>> @@ -608,7 +608,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>>  
>>  			fl2.fl4_dst = fl.fl4_src;
>>  			if (ip_route_output_key(net, &rt2, &fl2))
>> -				goto out_unlock;
>> +				goto ende;
>>  
>>  			/* Ugh! */
>>  			odst = skb_in->dst;
>> @@ -621,7 +621,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>>  		}
>>  
>>  		if (err)
>> -			goto out_unlock;
>> +			goto ende;
> 
> These ones look good.

Thanks :)

> Cheers,


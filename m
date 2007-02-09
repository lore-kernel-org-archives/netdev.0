From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPSEC][4/6] changing "ipip tunnel" and xfrm4_tunnel to
 the API change
Date: Fri, 09 Feb 2007 09:37:33 +0900
Message-ID: <45CBC24D.9040408@miyazawa.org>
References: <20070208170412.2e627947.kazunori@miyazawa.org> <45CB2148.8060307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, Miika Komu <miika@iki.fi>,
	Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:40224 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1945945AbXBIAiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 19:38:14 -0500
In-Reply-To: <45CB2148.8060307@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you Patrick for your review.
I'll fix and send again.

BTW, I'm going to use separete xfrm_tunnel_handler to solve
the issue which you pointed at the moment. But why does
"register twice" corrupt the list even if I use separate lists
for the address family.

Thank you,

Patrick McHardy wrote:
> Kazunori MIYAZAWA wrote:
>> Changing ipip tunnel and xfrm4_tunnel to the API
> 
> Fixing up users after API changes should be done in the same
> patch as the API change itself to avoid breaking compilation
> for people doing a bisection.
> 
>> index f110af5..00fc09f 100644
>> --- a/net/ipv4/xfrm4_tunnel.c
>> +++ b/net/ipv4/xfrm4_tunnel.c
>> @@ -66,12 +66,15 @@ static struct xfrm_tunnel xfrm_tunnel_ha
>>  
>>  static int __init ipip_init(void)
>>  {
>> -	if (xfrm_register_type(&ipip_type, AF_INET) < 0) {
>> -		printk(KERN_INFO "ipip init: can't add xfrm type\n");
>> +	if (xfrm_register_type(&ipip_type, AF_INET) < 0)
>> +		return -EAGAIN;
> 
> Why are you removing the printk?
> 
>> +
>> +	if (xfrm4_tunnel_register(&xfrm_tunnel_handler, AF_INET)) {
>> +		printk(KERN_INFO "ipip init: can't add xfrm handler for AF_INET\n");
>>  		return -EAGAIN;
> 
> Does not unregister ipip_type on error.
> 
>>  	}
>> -	if (xfrm4_tunnel_register(&xfrm_tunnel_handler)) {
>> -		printk(KERN_INFO "ipip init: can't add xfrm handler\n");
>> +	if (xfrm4_tunnel_register(&xfrm_tunnel_handler, AF_INET6)) {
> 
> You register xfrm_tunnel_handler twice, which will corrupt the list.
> 
>> +		printk(KERN_INFO "ipip init: can't add xfrm handler for AF_INET6\n");
>>  		xfrm_unregister_type(&ipip_type, AF_INET);
> 
> Does not unregister AF_INET tunnel handler on error.
> 
>>  		return -EAGAIN;
>>  	}
> 
> The next patch has similar problems.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Kazunori Miyazawa

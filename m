From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] ipv6: Allow accepting RA from local IP
 addresses.
Date: Wed, 25 Jun 2014 17:57:50 -0700 (PDT)
Message-ID: <20140625.175750.2174293066683383417.davem@davemloft.net>
References: <53A9FA0A.70902@yoshifuji.org>
	<53AA3FB2.3080204@candelatech.com>
	<53AB6E32.6010907@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, hideaki@yoshifuji.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, andi@collax.com
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756728AbaFZA5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 20:57:51 -0400
In-Reply-To: <53AB6E32.6010907@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki/吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
Date: Thu, 26 Jun 2014 09:49:54 +0900

> Hi,
> 
> 2014/06/25 12:19, Ben Greear wrote:>
>>
>> On 06/24/2014 03:22 PM, YOSHIFUJI Hideaki wrote:
>>> Hello.
>>>
>>> (2014/06/25 6:14), greearb@candelatech.com wrote:
>>>> From: Ben Greear <greearb@candelatech.com>
>>>>
>>>> This can be used in virtual networking applications, and
>>>> may have other uses as well.  The option is disabled by
>>>> default, so no change to current operating behaviour
>>>
>>>                                     standard compliant behavior?
>>
>> I've no idea.  Can you point me to the proper standard (and
>> pertinent section)?
> 
> I was wrong.
> 
> I found this code was added by commit 9f56220 ("ipv6: Do not
> use routes from locally generated RAs") to fix behavior when
> accept_ra == 2.
> 
> But I do not understand why it is not enough to restrict local
> address on receiving interface.
> 
> Andi, would you explain?

Added Andi to CC: list...

>>
>>>> without the user explicitly changing the behaviour.
>>>>
>>>
>>> Would you include your specific example?
>>
>> I gave one in a response to comments on v1 of this patch.
>>
>> Basically, I make a single OS instance look like a bunch of
>> routers, bridges, and hosts.  Without use of network namespaces,
>> virtual machines, or other such virtualization.  Just clever use
>> of ip rules and routes.  So, I need interfaces to be able to accept
>> RA from other interfaces on the same system.
>>
>> http://www.spinics.net/lists/netdev/msg286764.html
>>
>>
> 
>>>> +static bool ipv6_accept_ra_local(struct inet6_dev *in6_dev, struct
> sk_buf *skb)
>>>> +{
>>>> +	/* Do not accept RA with source-addr found on local machine unless
>>>> +	 * accept_ra_from_local is set to true.
>>>> +	 */
>>>> +	if (!in6_dev->cnf.accept_ra_from_local &&
>>>> +	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
>>>> +			  NULL, 0))
>>>> +		return false;
>>>> +	return true;
>>>> +}
>>>> +
>>>> +
>>>>     static void ndisc_router_discovery(struct sk_buff *skb)
>>>>     {
>>>>     	struct ra_msg *ra_msg = (struct ra_msg *)skb_transport_header(skb);
>>>> @@ -1151,10 +1164,9 @@ static void ndisc_router_discovery(struct
> sk_buff *skb)
>>>>     		goto skip_defrtr;
>>>>     	}
>>>>
>>>> -	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
>>>> -			  NULL, 0)) {
>>>> +	if (!ipv6_accept_ra_local(in6_dev, skb)) {
>>>>     		ND_PRINTK(2, info,
>>>> -			  "RA: %s, chk_addr failed for dev: %s\n",
>>>> +			  "RA: %s, accept_ra_local failed for dev: %s\n",
>>>>     			  __func__, skb->dev->name);
>>>>     		goto skip_defrtr;
>>>>     	}
>>>
>>> Hmm, without global knob, I see little benefit by
>>> having new helper.
>>
>> A previous reviewer requested it.  I don't care either
>> way, seems fine to open-code it to me.
>>
>>> At least, it should be called ipv6_chk_addr_ra(),
>>> ipv6_check_ra_saddr(), ipv6_is_nonlocal_ra() or
>>> something else.
>>>
>>> I think we do not need to change debugging output,
>>> or we could say "RA from local address detected;
>>> default router ignored." or something like.
>>
>> That does seem like a more useful error message.
>>
>> Thanks,
>> Ben
>>
> 
> --yoshfuji
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v2 2/2] ipv6:  Allow accepting RA from local IP addresses.
Date: Thu, 26 Jun 2014 09:49:54 +0900
Message-ID: <53AB6E32.6010907@miraclelinux.com>
References: <1403644488-21709-1-git-send-email-greearb@candelatech.com> <1403644488-21709-2-git-send-email-greearb@candelatech.com> <53A9FA0A.70902@yoshifuji.org> <53AA3FB2.3080204@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Ben Greear <greearb@candelatech.com>,
	YOSHIFUJI Hideaki <hideaki@yoshifuji.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og110.obsmtp.com ([64.18.2.173]:57369 "HELO
	exprod7og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754866AbaFZAzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 20:55:44 -0400
Received: by mail-pb0-f41.google.com with SMTP id ma3so2390520pbc.14
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 17:55:43 -0700 (PDT)
In-Reply-To: <53AA3FB2.3080204@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2014/06/25 12:19, Ben Greear wrote:>
>
> On 06/24/2014 03:22 PM, YOSHIFUJI Hideaki wrote:
>> Hello.
>>
>> (2014/06/25 6:14), greearb@candelatech.com wrote:
>>> From: Ben Greear <greearb@candelatech.com>
>>>
>>> This can be used in virtual networking applications, and
>>> may have other uses as well.  The option is disabled by
>>> default, so no change to current operating behaviour
>>
>>                                     standard compliant behavior?
>
> I've no idea.  Can you point me to the proper standard (and
> pertinent section)?

I was wrong.

I found this code was added by commit 9f56220 ("ipv6: Do not
use routes from locally generated RAs") to fix behavior when
accept_ra == 2.

But I do not understand why it is not enough to restrict local
address on receiving interface.

Andi, would you explain?

>
>>> without the user explicitly changing the behaviour.
>>>
>>
>> Would you include your specific example?
>
> I gave one in a response to comments on v1 of this patch.
>
> Basically, I make a single OS instance look like a bunch of
> routers, bridges, and hosts.  Without use of network namespaces,
> virtual machines, or other such virtualization.  Just clever use
> of ip rules and routes.  So, I need interfaces to be able to accept
> RA from other interfaces on the same system.
>
> http://www.spinics.net/lists/netdev/msg286764.html
>
>

>>> +static bool ipv6_accept_ra_local(struct inet6_dev *in6_dev, struct
sk_buf *skb)
>>> +{
>>> +	/* Do not accept RA with source-addr found on local machine unless
>>> +	 * accept_ra_from_local is set to true.
>>> +	 */
>>> +	if (!in6_dev->cnf.accept_ra_from_local &&
>>> +	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
>>> +			  NULL, 0))
>>> +		return false;
>>> +	return true;
>>> +}
>>> +
>>> +
>>>     static void ndisc_router_discovery(struct sk_buff *skb)
>>>     {
>>>     	struct ra_msg *ra_msg = (struct ra_msg *)skb_transport_header(skb);
>>> @@ -1151,10 +1164,9 @@ static void ndisc_router_discovery(struct
sk_buff *skb)
>>>     		goto skip_defrtr;
>>>     	}
>>>
>>> -	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
>>> -			  NULL, 0)) {
>>> +	if (!ipv6_accept_ra_local(in6_dev, skb)) {
>>>     		ND_PRINTK(2, info,
>>> -			  "RA: %s, chk_addr failed for dev: %s\n",
>>> +			  "RA: %s, accept_ra_local failed for dev: %s\n",
>>>     			  __func__, skb->dev->name);
>>>     		goto skip_defrtr;
>>>     	}
>>
>> Hmm, without global knob, I see little benefit by
>> having new helper.
>
> A previous reviewer requested it.  I don't care either
> way, seems fine to open-code it to me.
>
>> At least, it should be called ipv6_chk_addr_ra(),
>> ipv6_check_ra_saddr(), ipv6_is_nonlocal_ra() or
>> something else.
>>
>> I think we do not need to change debugging output,
>> or we could say "RA from local address detected;
>> default router ignored." or something like.
>
> That does seem like a more useful error message.
>
> Thanks,
> Ben
>

--yoshfuji

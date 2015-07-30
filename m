From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCHv3] net/ipv6: add sysctl option accept_ra_min_hop_limit
Date: Thu, 30 Jul 2015 09:45:26 +0900
Message-ID: <55B973A6.1060607@miraclelinux.com>
References: <1438164858-5253-1-git-send-email-liuhangbin@gmail.com>	<55B8AD62.1050002@miraclelinux.com> <CAPwn2JT6e=f0q=Q5rbqF_6ZejLyj+Ysyk1eP5KTBkGLz-Mpfqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35023 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754645AbbG3Apb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 20:45:31 -0400
Received: by pabkd10 with SMTP id kd10so13817305pab.2
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 17:45:30 -0700 (PDT)
In-Reply-To: <CAPwn2JT6e=f0q=Q5rbqF_6ZejLyj+Ysyk1eP5KTBkGLz-Mpfqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hangbin Liu wrote:
>>> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
>>> index 0a05b35..acda056 100644
>>> --- a/net/ipv6/ndisc.c
>>> +++ b/net/ipv6/ndisc.c
>>> @@ -1226,13 +1226,11 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>>>       if (rt)
>>>               rt6_set_expires(rt, jiffies + (HZ * lifetime));
>>>       if (ra_msg->icmph.icmp6_hop_limit) {
>>> -             /* Only set hop_limit on the interface if it is higher than
>>> -              * the current hop_limit.
>>> -              */
>>> -             if (in6_dev->cnf.hop_limit < ra_msg->icmph.icmp6_hop_limit) {
>>> +             if (in6_dev->cnf.accept_ra_min_hop_limit <= ra_msg->icmph.icmp6_hop_limit &&
>>> +                 ra_msg->icmph.icmp6_hop_limit != 0) {
>>>                       in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
>>>               } else {
>>> -                     ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than current\n");
>>> +                     ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than minimum\n");
>>>               }
>>>               if (rt)
>>>                       dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
>>>
>>
>> Please see my comments against your previous patch.
> 
> I pasted you comments here so we don't need to discuss in two mails :)
> 
>>
>> ra_msg->icmph.icmp6_hop_limit != 0 is checkd by outer "if".
> 
> Yes, thanks for your reminding :)
> 
>>
>> You do not need to update cnf.hop_limit if it is already equal to
>> hop limit received.
> 
> We need to update cnf.hop_limit if min_hop_limit <= icmp6_hop_limit. e.g.
> current hop limit is 64, min hop limit is 1 and ra hop limit is 32, then we need
> update current hop limit to 32.

OK

> 
>>
>> How about ignoring hop limit without message is configured value is
>> larger than 255, BTW?
> 
> Although set accept_ra_min_hop_limit great than 255 is meaningless,  there
> is also no need to check it since icmp6_hop_limit will not larger than 255. so
> 
> +               if (in6_dev->cnf.accept_ra_min_hop_limit <= 255 &&
> +                   in6_dev->cnf.accept_ra_min_hop_limit <=
> ra_msg->icmph.icmp6_hop_limit )
>                         in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
> 
> is  duplicated check. How do you think?

How about checking in6_dev->cnf.accept_ra_min_hop_limit by outer if, then?


if (in6_dev->cnf.accept_ra_min_hop_limit < 256 &&
    ra_msg->icmph.icmp6_hop_limit) {
...
}

> 
>>
>>>               if (rt)
>>>                       dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
>>>
>>
>> This can be inside the inner "if".
> 
> OK, will move it.
> 
> 
> Best Regards
> Hangbin
> 

Regards,

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION

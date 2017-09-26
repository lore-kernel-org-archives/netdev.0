From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net] ipv6: remove incorrect WARN_ON() in fib6_del()
Date: Mon, 25 Sep 2017 18:16:05 -0700
Message-ID: <CAEA6p_CvtmNaYcgSSyFNEbip1ckKwLjJH3PJTOqym0hCt-x2uw@mail.gmail.com>
References: <20170925173522.99892-1-tracywwnj@gmail.com> <20170926005618.z4ymlry7jl47nkjm@kafai-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:52579 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965435AbdIZBQJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 21:16:09 -0400
Received: by mail-ua0-f169.google.com with SMTP id n38so5487716uai.9
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 18:16:09 -0700 (PDT)
In-Reply-To: <20170926005618.z4ymlry7jl47nkjm@kafai-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 5:56 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Mon, Sep 25, 2017 at 05:35:22PM +0000, Wei Wang wrote:
>> From: Wei Wang <weiwan@google.com>
>>
>> fib6_del() generates WARN_ON() when rt->dst.obsolete > 0. This does not
>> make sense because it is possible that the route passed in is already
>> deleted by some other thread and rt->dst.obsolete is set to
>> DST_OBSOLETE_DEAD.
>> So this commit deletes this WARN_ON() and also remove the
>> "#ifdef RT6_DEBUG >= 2" condition so that if the route is already
>> obsolete, we return right at the beginning of fib6_del().
>>
>>
>> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
>> index e5308d7cbd75..693bcd7ef6d2 100644
>> --- a/net/ipv6/ip6_fib.c
>> +++ b/net/ipv6/ip6_fib.c
>> @@ -1592,13 +1592,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
>>       struct net *net = info->nl_net;
>>       struct rt6_info **rtp;
>>
>> -#if RT6_DEBUG >= 2
>> -     if (rt->dst.obsolete > 0) {
>> -             WARN_ON(fn);
> fn should have already been set to NULL if it is removed
> from the fib6 tree?
>

That is true. rt->rt6i_node (fn) should already be marked as NULL.
That means the check on rt->dst.obsolete is redundant.
I will remove it in v2.
Thanks Martin.


>> -             return -ENOENT;
>> -     }
>> -#endif
>> -     if (!fn || rt == net->ipv6.ip6_null_entry)
>> +     if (!fn || rt->dst.obsolete > 0 || rt == net->ipv6.ip6_null_entry)
>>               return -ENOENT;
>>
>>       WARN_ON(!(fn->fn_flags & RTN_RTINFO));
>> --
>> 2.14.1.821.g8fa685d3b7-goog
>>

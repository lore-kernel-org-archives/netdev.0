From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: check and errout if res->fi is NULL when
 RTM_F_FIB_MATCH is set
Date: Tue, 15 Aug 2017 21:55:32 -0700
Message-ID: <CAJieiUiDzph45Uzxfp=7rGKarZXpPQ4T488ykBQoZC3VPKSJvg@mail.gmail.com>
References: <1502851818-17811-1-git-send-email-roopa@cumulusnetworks.com> <577b280e-5bef-ff83-ab72-fe61b42e02f9@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>, idaifish <idaifish@gmail.com>,
        syzkaller@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:37879 "EHLO
        mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750902AbdHPEzd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 00:55:33 -0400
Received: by mail-vk0-f41.google.com with SMTP id r199so8765475vke.4
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 21:55:33 -0700 (PDT)
In-Reply-To: <577b280e-5bef-ff83-ab72-fe61b42e02f9@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 7:56 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 8/15/17 8:50 PM, Roopa Prabhu wrote:
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index 7effa62..49a018f 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -2763,14 +2763,21 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>>       if (rtm->rtm_flags & RTM_F_LOOKUP_TABLE)
>>               table_id = rt->rt_table_id;
>>
>> -     if (rtm->rtm_flags & RTM_F_FIB_MATCH)
>> +     if (rtm->rtm_flags & RTM_F_FIB_MATCH) {
>> +             if (!res.fi) {
>> +                     err = fib_props[res->type].error;
>> +                     if (!err)
>> +                             err = -EINVAL;
>
> I think -EHOSTUNREACH is a better error than EINVAL. Nothing about the
> user inputs are invalid; rather the lookup is failing, but indirectly.

 I have been going back and forth on this looking at other examples.
I would have preferred ip_route_input_rcu returned the right error
code for this....but i prefer not to touch that given it may break
something else.

EHOSTUNREACH is only returned for RTN_UNREACHABLE routes.

        [RTN_UNREACHABLE] = {

                .error  = -EHOSTUNREACH,

                .scope  = RT_SCOPE_UNIVERSE,

        },

In the example i am using it was failing due to a daddr being zero. so
seemed like -EINVAL would fit.

If EHOSTUNREACH can cover most errors, I am fine with changing it to
-EHOSTUNREACH.

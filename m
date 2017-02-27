From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv6: check for ip6_null_entry in __ip6_del_rt_siblings()
Date: Mon, 27 Feb 2017 12:55:44 -0800
Message-ID: <CAM_iQpUufKs9-fwvUo16c_RYDbCOC3cJeSPma3TqF2VBLxNr5g@mail.gmail.com>
References: <1488222425-1256-1-git-send-email-xiyou.wangcong@gmail.com> <1488227660.9415.207.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36501 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752045AbdB0U5A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 15:57:00 -0500
Received: by mail-wm0-f66.google.com with SMTP id r18so15284933wmd.3
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:56:05 -0800 (PST)
In-Reply-To: <1488227660.9415.207.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2017 at 12:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-02-27 at 11:07 -0800, Cong Wang wrote:
>> Andrey reported a NULL pointer deref bug in ipv6_route_ioctl()
>> -> ip6_route_del() -> __ip6_del_rt_siblings() code path. This is
>> because ip6_null_entry is returned in this path since ip6_null_entry
>> is kinda default for a ipv6 route table root node. Quote from
>> David Ahern:
>>
>>  ip6_null_entry is the root of all ipv6 fib tables making it integrated
>>  into the table ...
>>
>> We should ignore any attempt of trying to delete it, like we do in
>> __ip6_del_rt() path and several others.
>>
>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/ipv6/route.c | 7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index f54f426..9da77e9 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -2169,10 +2169,13 @@ int ip6_del_rt(struct rt6_info *rt)
>>  static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
>>  {
>>       struct nl_info *info = &cfg->fc_nlinfo;
>> +     struct net *net = info->nl_net;
>>       struct sk_buff *skb = NULL;
>>       struct fib6_table *table;
>>       int err;
>>
>> +     if (rt == net->ipv6.ip6_null_entry)
>> +             return -ENOENT;
>
> It looks the caller did a dst_hold(&rt->dst);
>
> So this new error path would leave a refcount leak.

Interesting, this error path is not new for __ip6_del_rt_siblings()
so the leak was already there before mine, but you are probably
right we have a leak here.

I will send a separate patch to address this leak.

>
> Note that I was not able to trigger the crash on old kernels, so it
> would be nice to get a precise idea of bug origin.

Right, I miss:
Fixes: 0ae8133586ad ("net: ipv6: Allow shorthand delete of all
nexthops in multipath route")

Thanks!

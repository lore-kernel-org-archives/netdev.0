From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv6: check for ip6_null_entry in __ip6_del_rt_siblings()
Date: Mon, 27 Feb 2017 13:04:16 -0800
Message-ID: <CAM_iQpVimUuJZqTkgZOoVtS9O8gL+2rr-SUNgd67Y3L-3bZVZw@mail.gmail.com>
References: <1488222425-1256-1-git-send-email-xiyou.wangcong@gmail.com>
 <1488227660.9415.207.camel@edumazet-glaptop3.roam.corp.google.com> <0ec7c6bd-0705-ea30-650e-b8d269dc587b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35400 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751737AbdB0Vez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 16:34:55 -0500
Received: by mail-wr0-f195.google.com with SMTP id q39so11945196wrb.2
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 13:34:24 -0800 (PST)
In-Reply-To: <0ec7c6bd-0705-ea30-650e-b8d269dc587b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2017 at 1:00 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 2/27/17 12:34 PM, Eric Dumazet wrote:
>> On Mon, 2017-02-27 at 11:07 -0800, Cong Wang wrote:
>>> Andrey reported a NULL pointer deref bug in ipv6_route_ioctl()
>>> -> ip6_route_del() -> __ip6_del_rt_siblings() code path. This is
>>> because ip6_null_entry is returned in this path since ip6_null_entry
>>> is kinda default for a ipv6 route table root node. Quote from
>>> David Ahern:
>>>
>>>  ip6_null_entry is the root of all ipv6 fib tables making it integrated
>>>  into the table ...
>>>
>>> We should ignore any attempt of trying to delete it, like we do in
>>> __ip6_del_rt() path and several others.
>>>
>>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>> ---
>>>  net/ipv6/route.c | 7 +++++--
>>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>> index f54f426..9da77e9 100644
>>> --- a/net/ipv6/route.c
>>> +++ b/net/ipv6/route.c
>>> @@ -2169,10 +2169,13 @@ int ip6_del_rt(struct rt6_info *rt)
>>>  static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
>>>  {
>>>      struct nl_info *info = &cfg->fc_nlinfo;
>>> +    struct net *net = info->nl_net;
>>>      struct sk_buff *skb = NULL;
>>>      struct fib6_table *table;
>>>      int err;
>>>
>>> +    if (rt == net->ipv6.ip6_null_entry)
>>> +            return -ENOENT;
>>
>> It looks the caller did a dst_hold(&rt->dst);
>>
>> So this new error path would leave a refcount leak.
>>
>> Note that I was not able to trigger the crash on old kernels, so it
>> would be nice to get a precise idea of bug origin.
>>
>
> Cong: do you want to send a v2 catching the null entry in ip6_route_del
> before the refcnt?

Yeah, actually it is introduced by my patch because there is already
an ip6_rt_put() in __ip6_del_rt_siblings(). So v2 is coming...

>
>                 for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
> +                       /* do not allow deletion of the null route */
> +                       if (rt == net->ipv6.ip6_null_entry)
> +                               continue;
>
> Fixes: 0ae8133586ad net: ipv6: Allow shorthand delete of all nexthops in
> multipath route

Note, I moved the check into __ip6_del_rt_siblings() because __ip6_del_rt()
has a same check.

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv6: ignore null_entry in inet6_rtm_getroute() too
Date: Tue, 28 Feb 2017 11:48:56 -0800
Message-ID: <CAM_iQpXEYQbGzJNO6E5kb6pUGTcDuZdupFj8xtiRG5Vx836j8g@mail.gmail.com>
References: <1488307478-10081-1-git-send-email-xiyou.wangcong@gmail.com> <ee659bf6-789f-edc0-a668-db1c4b0abb20@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34475 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdB1Tum (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 14:50:42 -0500
Received: by mail-wr0-f193.google.com with SMTP id u48so2866868wrc.1
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 11:49:17 -0800 (PST)
In-Reply-To: <ee659bf6-789f-edc0-a668-db1c4b0abb20@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 11:01 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 2/28/17 10:44 AM, Cong Wang wrote:
>> Like commit 1f17e2f2c8a8 ("net: ipv6: ignore null_entry on route dumps"),
>> we need to ignore null entry in inet6_rtm_getroute() too.
>>
>> Return -ENOENT here because we return the same errno when deleting
>> the null entry.
>>
>> Fixes: a1a22c1206 ("net: ipv6: Keep nexthop of multipath route on admin down")
>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Cc: David Ahern <dsa@cumulusnetworks.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/ipv6/route.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index f54f426..25590d1 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -3627,6 +3627,12 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
>>               rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
>>       }
>>
>> +     if (rt == net->ipv6.ip6_null_entry) {
>> +             ip6_rt_put(rt);
>> +             err = -ENOENT;
>> +             goto errout;
>> +     }
>> +
>>       skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
>>       if (!skb) {
>>               ip6_rt_put(rt);
>>
>
> hold on. That test exposed something else, not just a getroute problem.
> I accidentally ran 'unsahre -n; ip -6 ro ls' on my host machine instead
> of a VM, so took some time to recover. dumproute already covers the null
> route.
>

Of course, you already stated it in your commit:

    ip6_null_entry is the root of all ipv6 fib tables making it integrated
    into the table and hence passed to the ipv6 route dump code. The
    null_entry route uses the loopback device for dst.dev but may not have
    rt6i_idev set because of the order in which initializations are done --
    ip6_route_net_init is run before addrconf_init has initialized the
    loopback device. Fixing the initialization order is a much bigger problem
    with no obvious solution thus far.

    The BUG is triggered when the loopback is set down and the netif_running
    check added by a1a22c1206 fails. The fill_node descends to checking
    rt->rt6i_idev for ignore_routes_with_linkdown and since rt6i_idev is
    NULL it faults.

    The null_entry route should not be processed in a dump request. Catch
    and ignore. This check is done in rt6_dump_route as it is the highest
    place in the callchain with knowledge of both the route and the network
    namespace.

which is why I omit it.

The rt->rt6i_idev = in6_dev_get(loopback_dev) is apparently not correct,
at that time loopback_dev is just registered and not up or running, its
in6_dev pointer should be NULL, we need to listen to inet6addr event to
make it non-NULL. I thought you apparently knew this...
